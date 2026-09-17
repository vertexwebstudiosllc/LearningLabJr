#!/usr/bin/env python3
"""Build offline narration with Amazon Polly. No AWS access unless generate/audition is explicit.

Examples:
    python3 Narration/generate_polly.py
    python3 Narration/generate_polly.py audition --dry-run
    python3 Narration/generate_polly.py generate --profile admin --max-usd 10
    python3 Narration/generate_polly.py verify

Generation costs are conservative estimates, before tax, without free-tier discounts.
Failed/interrupted requests retain their full estimate. --retry-failed explicitly
allows another paid attempt. Budget is cumulative for the selected ledger.
"""
from __future__ import annotations

import argparse
import contextlib
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation
import fcntl
import hashlib
import html
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import threading
import time
import unicodedata
import xml.etree.ElementTree as ET

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_DIR = SCRIPT_DIR.parent
MANIFEST_NAME = 'NarrationAudioManifest.json'
# https://aws.amazon.com/polly/pricing/ — checked 2026-09-16; no free tier assumed.
USD_PER_MILLION = {'standard': Decimal('4'), 'neural': Decimal('16'),
                   'generative': Decimal('30'), 'long-form': Decimal('100')}
DELIVERY_RATES = {'gentle': 90, 'playful': 100, 'clear': 95, 'story': 94}
PREVIEW_TEXT = "Hi, friend! Let's look together. Can you find the little duck? There it is! You found it."
AUDITION_SCRIPTS = [
    {'text': PREVIEW_TEXT, 'category': 'audition', 'delivery': 'playful'},
    {'text': "Let's count together. One, two, three! Three little ducks. Can you show me three fingers?",
     'category': 'audition', 'delivery': 'clear'},
    {'text': 'The little bunny looked up at the moon. A soft breeze moved through the trees. Good night, little bunny.',
     'category': 'audition', 'delivery': 'story'},
]


class NarrationError(Exception):
    """A reviewable configuration, spending, cache, or generation failure."""


def normalize_text(value: str) -> str:
    return ' '.join(unicodedata.normalize('NFC', value).split())


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def json_bytes(value: object) -> bytes:
    return (json.dumps(value, ensure_ascii=False, indent=2) + '\n').encode('utf-8')


def atomic_write(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=f'.{path.name}.', suffix='.tmp', dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def require_string(row: dict, key: str, default: str | None = None) -> str:
    value = row.get(key, default)
    if not isinstance(value, str) or not normalize_text(value):
        raise NarrationError(f'{key} must be a nonempty string')
    return normalize_text(value)


def ssml_for(row: dict, spoken_text: str) -> str:
    if 'ssml' in row:
        result = require_string(row, 'ssml')
    else:
        escaped = html.escape(spoken_text, quote=False)
        delivery = row.get('delivery', 'story')
        if delivery not in DELIVERY_RATES:
            raise NarrationError(f'Unknown delivery: {delivery!r}')
        # Generative prosody requires full sentences. Short labels stay unwrapped;
        # isolated phonemes use explicit Neural SSML supplied by the catalog.
        full_sentence = bool(re.search(r'[.!?][\"\u201d\u2019\']?$', spoken_text)) and len(spoken_text.split()) >= 2
        result = (f'<speak><prosody rate="{DELIVERY_RATES[delivery]}%">{escaped}</prosody></speak>'
                  if full_sentence and DELIVERY_RATES[delivery] != 100 else f'<speak>{escaped}</speak>')
    if re.search(r'<!\s*(DOCTYPE|ENTITY)', result, re.IGNORECASE):
        raise NarrationError('SSML document types and entities are not supported')
    try:
        root = ET.fromstring(result)
    except ET.ParseError as error:
        raise NarrationError(f'Invalid SSML: {error}') from error
    if root.tag != 'speak':
        raise NarrationError('SSML must have a <speak> root')
    if not ''.join(root.itertext()).strip():
        raise NarrationError('SSML must contain spoken text')
    return result


@dataclass(frozen=True)
class Clip:
    text: str
    spoken_text: str
    ssml: str
    voice: str
    engine: str
    category: str

    @property
    def signature(self) -> str:
        # Unambiguous encoding; fixed MP3/24 kHz output is part of this schema.
        data = json.dumps([self.text, self.voice, self.engine, self.ssml], ensure_ascii=False,
                          separators=(',', ':')).encode('utf-8')
        return digest(data)

    @property
    def filename(self) -> str:
        return f'llj-{self.signature[:24]}.mp3'

    @property
    def billable_characters(self) -> int:
        return len(''.join(ET.fromstring(self.ssml).itertext()))

    @property
    def estimated_usd(self) -> Decimal:
        # Reserve an upper bound before transmission. Polly's RequestCharacters
        # can include separators around SSML elements absent from itertext().
        return Decimal(len(self.ssml)) * USD_PER_MILLION[self.engine] / Decimal(1_000_000)

    def manifest_entry(self) -> dict:
        return {'text': self.text, 'file': self.filename, 'spokenText': self.spoken_text,
                'voice': self.voice, 'engine': self.engine, 'category': self.category}


def clip_from_row(row: dict, voice: str, default_engine: str) -> Clip:
    if not isinstance(row, dict):
        raise NarrationError('Each catalog entry must be an object')
    text = require_string(row, 'text')
    spoken = require_string(row, 'spokenText', text)
    engine = require_string(row, 'engine', default_engine)
    if engine not in USD_PER_MILLION:
        raise NarrationError(f'Unsupported engine: {engine}')
    ssml = ssml_for(row, spoken)
    if engine == 'generative' and any(node.tag == 'phoneme' for node in ET.fromstring(ssml).iter()):
        raise NarrationError(f'Phoneme SSML requires an explicit supported engine, such as neural: {text!r}')
    clip = Clip(text, spoken, ssml, voice, engine, require_string(row, 'category', 'shared'))
    if clip.billable_characters > 3000 or len(ssml) > 6000:
        raise NarrationError(f'Polly request is oversized ({clip.billable_characters} billable / '
                             f'{len(ssml)} total characters): {text[:80]!r}')
    return clip


def load_catalog(paths: list[Path], voice: str = 'Ruth', engine: str = 'generative') -> list[Clip]:
    if not paths:
        raise NarrationError('No narration-source-*.json catalogs found')
    clips: dict[str, Clip] = {}
    origins: dict[str, str] = {}
    for path in sorted(paths):
        try:
            rows = json.loads(path.read_text())
        except (OSError, ValueError) as error:
            raise NarrationError(f'Cannot read catalog {path}: {error}') from error
        if not isinstance(rows, list):
            raise NarrationError(f'Catalog {path} must be an array')
        for position, row in enumerate(rows, 1):
            origin = f'{path.name} entry {position}'
            try:
                clip = clip_from_row(row, voice, engine)
            except NarrationError as error:
                raise NarrationError(f'{origin}: {error}') from error
            previous = clips.get(clip.text)
            if previous and (previous.spoken_text, previous.ssml, previous.engine) != (clip.spoken_text, clip.ssml, clip.engine):
                raise NarrationError(f'Conflicting narration for {clip.text!r}: {origins[clip.text]} and {origin}')
            if not previous:
                clips[clip.text], origins[clip.text] = clip, origin
    if not clips:
        raise NarrationError('Catalogs contain no narration')
    return sorted(clips.values(), key=lambda clip: clip.text)


def read_ledger(path: Path) -> dict:
    if not path.exists():
        return {'schemaVersion': 1, 'currency': 'USD', 'attempts': []}
    try:
        ledger = json.loads(path.read_text())
        if ledger.get('schemaVersion') != 1 or not isinstance(ledger.get('attempts'), list):
            raise ValueError('unsupported ledger schema')
        for attempt in ledger['attempts']:
            cost = Decimal(str(attempt['estimatedUSD']))
            if not cost.is_finite() or cost < 0 or attempt['status'] not in {'pending', 'done', 'failed'}:
                raise ValueError('invalid attempt estimate or status')
            for field in ['signature', 'file', 'text', 'voice', 'engine', 'ssml', 'requestedAt']:
                if not isinstance(attempt[field], str) or not attempt[field]:
                    raise ValueError(f'invalid {field}')
        return ledger
    except (OSError, ValueError, TypeError, KeyError, AttributeError, InvalidOperation) as error:
        raise NarrationError(f'Cannot trust spending ledger {path}: {error}') from error


def ledger_total(ledger: dict) -> Decimal:
    return sum((max(Decimal(str(attempt['estimatedUSD'])),
                    Decimal(attempt.get('awsRequestCharacters', 0))
                    * USD_PER_MILLION[attempt['engine']] / Decimal(1_000_000))
                for attempt in ledger['attempts']), Decimal(0))


def safe_audio_path(output_dir: Path, filename: str) -> Path:
    if not re.fullmatch(r'llj-[0-9a-f]{24}\.mp3', filename):
        raise NarrationError(f'Unsafe or unexpected narration filename: {filename!r}')
    candidate = output_dir / filename
    if candidate.is_symlink():
        raise NarrationError(f'Audio must not be a symbolic link: {filename}')
    return candidate


def valid_cache(clip: Clip, output_dir: Path, ledger: dict) -> bool:
    matches = [attempt for attempt in ledger['attempts']
               if attempt['signature'] == clip.signature and attempt['status'] == 'done'
               and attempt['file'] == clip.filename]
    if not matches:
        return False
    path = safe_audio_path(output_dir, clip.filename)
    try:
        data = path.read_bytes()
    except OSError:
        return False
    return bool(data) and any(attempt.get('audioSHA256') == digest(data) for attempt in matches)


def plan(clips: list[Clip], output_dir: Path, ledger: dict) -> dict:
    remaining = [clip for clip in clips if not valid_cache(clip, output_dir, ledger)]
    prior_signatures = {attempt['signature'] for attempt in ledger['attempts']}
    cost = sum((clip.estimated_usd for clip in remaining), Decimal(0))
    return {'clips': len(clips), 'cached': len(clips) - len(remaining), 'requestsNeeded': len(remaining),
            'retryAuthorizationNeeded': sum(clip.signature in prior_signatures for clip in remaining),
            'billableCharactersNeeded': sum(clip.billable_characters for clip in remaining),
            'estimatedNewUSD': str(cost), 'ledgerReservedUSD': str(ledger_total(ledger)),
            'estimatedCumulativeUSD': str(ledger_total(ledger) + cost),
            'humanReviewed': False, 'pricingURL': 'https://aws.amazon.com/polly/pricing/'}


@contextlib.contextmanager
def exclusive_ledger(path: Path):
    """Prevent two generator processes from overspending the same ledger."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.with_suffix(path.suffix + '.lock').open('a') as lockfile:
        try:
            fcntl.flock(lockfile.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise NarrationError('Another generator is using this spending ledger') from error
        try:
            yield
        finally:
            fcntl.flock(lockfile.fileno(), fcntl.LOCK_UN)


class RateLimiter:
    def __init__(self, requests_per_second: float):
        self.interval = 1.0 / requests_per_second
        self.lock = threading.Lock()
        self.next_start = 0.0

    def wait(self, stop: threading.Event) -> bool:
        with self.lock:
            now = time.monotonic()
            scheduled = max(now, self.next_start)
            self.next_start = scheduled + self.interval
        return not stop.wait(max(0.0, scheduled - time.monotonic()))


def polly_client(profile: str, region: str):
    # Intentionally lazy: planning, verification, and unit tests work without boto3.
    try:
        import boto3
        from botocore.config import Config
    except ImportError as error:
        raise NarrationError('Generation needs boto3 in the selected Python environment; planning does not.') from error
    config = Config(connect_timeout=10, read_timeout=90,
                    retries={'total_max_attempts': 1, 'mode': 'standard'}, max_pool_connections=3)
    return boto3.Session(profile_name=profile, region_name=region).client('polly', config=config)


def generate_batch(clips: list[Clip], output_dir: Path, ledger_path: Path, max_usd: Decimal,
                   client_factory, *, workers: int = 3, requests_per_second: float = 4,
                   retry_failed: bool = False) -> dict:
    if not clips:
        raise NarrationError('Refusing to publish an empty narration manifest')
    if workers not in range(1, 4) or not 0 < requests_per_second <= 4:
        raise NarrationError('Use 1–3 workers and a rate greater than zero and at most 4 requests/second')
    if not max_usd.is_finite() or max_usd < 0:
        raise NarrationError('Budget must be a finite, nonnegative USD amount')
    with exclusive_ledger(ledger_path):
        ledger = read_ledger(ledger_path)
        summary = plan(clips, output_dir, ledger)
        if Decimal(summary['estimatedCumulativeUSD']) > max_usd:
            raise NarrationError(f'Budget would be exceeded: ${summary["estimatedCumulativeUSD"]} '
                                 f'cumulative reserved/request estimate; cap ${max_usd}. No calls made.')
        if summary['retryAuthorizationNeeded'] and not retry_failed:
            raise NarrationError(f'{summary["retryAuthorizationNeeded"]} failed, interrupted, missing, or '
                                 'changed recordings need another paid attempt. Review the ledger, then use --retry-failed.')
        remaining = [clip for clip in clips if not valid_cache(clip, output_dir, ledger)]
        client = client_factory() if remaining else None
        output_dir.mkdir(parents=True, exist_ok=True)
        lock = threading.Lock()
        stop = threading.Event()
        limiter = RateLimiter(requests_per_second)
        errors: list[str] = []
        completed = 0

        def save_ledger():
            ledger['updatedAt'] = utc_now()
            atomic_write(ledger_path, json_bytes(ledger))

        def worker(clip: Clip):
            nonlocal completed
            if stop.is_set() or not limiter.wait(stop):
                return
            with lock:
                if stop.is_set():
                    return
                if ledger_total(ledger) + clip.estimated_usd > max_usd:
                    stop.set()
                    raise NarrationError('Cumulative budget cap reached before request')
                attempt = {'signature': clip.signature, 'file': clip.filename,
                           'text': clip.text, 'voice': clip.voice, 'engine': clip.engine,
                           'ssml': clip.ssml, 'status': 'pending', 'requestedAt': utc_now(),
                           'billableCharacters': clip.billable_characters,
                           'estimatedUSD': str(clip.estimated_usd), 'humanReviewed': False}
                ledger['attempts'].append(attempt)
                # Reserve the entire request before it could be billed, including a
                # crash after transmission. SDK retries are disabled by client config.
                save_ledger()
            try:
                response = client.synthesize_speech(Text=clip.ssml, TextType='ssml',
                    VoiceId=clip.voice, Engine=clip.engine, OutputFormat='mp3', SampleRate='24000')
                stream = response.get('AudioStream')
                if stream is None:
                    raise NarrationError('Polly returned no audio stream')
                try:
                    data = stream.read()
                finally:
                    stream.close()
                if not isinstance(data, bytes) or not data:
                    raise NarrationError('Polly returned an empty audio stream')
                atomic_write(safe_audio_path(output_dir, clip.filename), data)
                with lock:
                    attempt.update(status='done', completedAt=utc_now(), audioSHA256=digest(data),
                                   audioBytes=len(data))
                    if 'RequestCharacters' in response:
                        attempt['awsRequestCharacters'] = response['RequestCharacters']
                        attempt['reservedUSD'] = attempt['estimatedUSD']
                        attempt['estimatedUSD'] = str(Decimal(response['RequestCharacters'])
                            * USD_PER_MILLION[clip.engine] / Decimal(1_000_000))
                    save_ledger()
                    completed += 1
                    if completed % 25 == 0 or completed == len(remaining):
                        print(f'Generated {completed}/{len(remaining)} new clips; '
                              f'cumulative reserved estimate ${ledger_total(ledger):.4f}',
                              file=sys.stderr, flush=True)
            except Exception as error:
                stop.set()
                with lock:
                    attempt.update(status='failed', failedAt=utc_now(), error=str(error))
                    save_ledger()
                raise NarrationError(f'{clip.text[:70]!r}: {error}') from error

        with ThreadPoolExecutor(max_workers=workers) as executor:
            futures = [executor.submit(worker, clip) for clip in remaining]
            try:
                for future in as_completed(futures):
                    try:
                        future.result()
                    except Exception as error:
                        stop.set()
                        errors.append(str(error))
            except KeyboardInterrupt:
                stop.set()
                for future in futures:
                    future.cancel()
                raise NarrationError('Generation interrupted; in-flight requests are retained in the ledger. '
                                     'The published manifest was not changed.')
        if errors:
            raise NarrationError('Generation stopped. Completed files and all cost reservations were kept; '
                                 'the published manifest was not changed. ' + '; '.join(errors[:3]))
        incomplete = [clip for clip in clips if not valid_cache(clip, output_dir, ledger)]
        if incomplete:
            raise NarrationError(f'{len(incomplete)} recordings are incomplete; manifest was not changed')
        manifest = {'schemaVersion': 1, 'clips': [clip.manifest_entry() for clip in clips]}
        atomic_write(output_dir / MANIFEST_NAME, json_bytes(manifest))
        return plan(clips, output_dir, ledger)


def verify(output_dir: Path, ledger_path: Path, *, allow_duplicate_text: bool = False) -> dict:
    try:
        manifest = json.loads((output_dir / MANIFEST_NAME).read_text())
    except (OSError, ValueError) as error:
        raise NarrationError(f'Cannot read published manifest: {error}') from error
    if manifest.get('schemaVersion') != 1 or not isinstance(manifest.get('clips'), list) or not manifest['clips']:
        raise NarrationError('Invalid or empty manifest')
    ledger = read_ledger(ledger_path)
    unique_texts = set()
    total_bytes = 0
    for entry in manifest['clips']:
        if not isinstance(entry, dict):
            raise NarrationError('Invalid manifest clip')
        for field in ['text', 'file', 'spokenText', 'voice', 'engine', 'category']:
            if not isinstance(entry.get(field), str) or not entry[field]:
                raise NarrationError(f'Invalid manifest clip field: {field}')
        key = normalize_text(entry['text'])
        if key != entry['text'] or (key in unique_texts and not allow_duplicate_text):
            raise NarrationError(f'Duplicate or non-normalized manifest key: {key!r}')
        unique_texts.add(key)
        path = safe_audio_path(output_dir, entry['file'])
        try:
            data = path.read_bytes()
        except OSError as error:
            raise NarrationError(f'Missing audio: {entry["file"]}') from error
        matches = [attempt for attempt in ledger['attempts']
                   if attempt['status'] == 'done' and attempt['file'] == entry['file']
                   and attempt['text'] == key and attempt['voice'] == entry['voice']
                   and attempt['engine'] == entry['engine']]
        if not data or not any(attempt.get('audioSHA256') == digest(data) for attempt in matches):
            raise NarrationError(f'Audio/ledger hash mismatch: {entry["file"]}')
        total_bytes += len(data)
    return {'clips': len(manifest['clips']), 'uniqueTexts': len(unique_texts),
            'audioBytes': total_bytes, 'reservedUSD': str(ledger_total(ledger)),
            'integrityVerified': True, 'humanReviewed': False}


def write_audition_player(clips: list[Clip], output_dir: Path) -> None:
    cards = []
    for clip in clips:
        cards.append(f'<section><h2>{html.escape(clip.voice)} · {html.escape(clip.engine)}</h2>'
                     f'<p>{html.escape(clip.text)}</p><audio controls preload="none" '
                     f'src="{clip.filename}"></audio></section>')
    page = '<!doctype html><meta charset="utf-8"><title>Learning Lab Jr voice auditions</title>' \
           '<style>body{font:18px system-ui;max-width:850px;margin:40px auto;padding:20px}' \
           'section{padding:20px;border-bottom:1px solid #ccc}audio{width:100%}</style>' \
           '<h1>Voice auditions</h1><p>Listen for warmth, clear words, and comfortable pacing. ' \
           'These automated samples have not been human reviewed.</p>' + ''.join(cards)
    atomic_write(output_dir / 'index.html', page.encode())


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('command', nargs='?', choices=['plan', 'generate', 'audition', 'verify'], default='plan')
    parser.add_argument('--source-dir', type=Path, default=SCRIPT_DIR / 'Source')
    parser.add_argument('--catalog', type=Path, action='append', help='Only these catalog files; repeat as needed')
    parser.add_argument('--output-dir', type=Path, default=PROJECT_DIR / 'NarrationAudio')
    parser.add_argument('--ledger', type=Path)
    parser.add_argument('--profile', default='admin')
    parser.add_argument('--region', default='us-east-1')
    parser.add_argument('--voice', default='Ruth')
    parser.add_argument('--engine', choices=sorted(USD_PER_MILLION), default='generative')
    parser.add_argument('--max-usd', type=Decimal, default=Decimal('10'))
    parser.add_argument('--workers', type=int, choices=[1, 2, 3], default=3)
    parser.add_argument('--requests-per-second', type=float, default=4)
    parser.add_argument('--retry-failed', action='store_true')
    parser.add_argument('--dry-run', action='store_true', help='Plan even when generate/audition is selected')
    parser.add_argument('--audition-dir', type=Path, default=Path('/private/tmp/LearningLabJr-Polly-Auditions'))
    args = parser.parse_args(argv)
    ledger_path = args.ledger or args.source_dir / 'polly-generation-ledger.json'
    output_dir = args.output_dir
    try:
        if args.command == 'verify':
            result = verify(output_dir, ledger_path)
        else:
            if args.command == 'audition':
                output_dir = args.audition_dir
                ledger_path = args.ledger or output_dir / 'polly-generation-ledger.json'
                clips = [clip_from_row(row, voice, args.engine)
                         for voice in ['Joanna', 'Ruth', 'Salli'] for row in AUDITION_SCRIPTS]
            else:
                paths = args.catalog if args.catalog is not None else list(args.source_dir.glob('narration-source-*.json'))
                clips = load_catalog(paths, args.voice, args.engine)
            if args.command == 'plan' or args.dry_run:
                result = plan(clips, output_dir, read_ledger(ledger_path))
                result.update(maxUSD=str(args.max_usd),
                              withinBudget=Decimal(result['estimatedCumulativeUSD']) <= args.max_usd,
                              mode='dry-run', outputDirectory=str(output_dir))
            else:
                result = generate_batch(clips, output_dir, ledger_path, args.max_usd,
                    lambda: polly_client(args.profile, args.region), workers=args.workers,
                    requests_per_second=args.requests_per_second, retry_failed=args.retry_failed)
                if args.command == 'audition':
                    write_audition_player(clips, output_dir)
                    result['auditionPlayer'] = str(output_dir / 'index.html')
                result.update(mode=args.command, outputDirectory=str(output_dir))
        print(json.dumps(result, indent=2))
        return 0
    except (NarrationError, OSError, ValueError) as error:
        print(f'ERROR: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
