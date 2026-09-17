"""Generate conversational alternatives without replacing the app's recordings."""
import argparse
from decimal import Decimal
import html
import json
from pathlib import Path
import shutil

import generate_polly as polly


SAMPLES = [
    ('Find the duck', {
        'text': polly.PREVIEW_TEXT,
        'spokenText': "Hi, friend! Ooh, let's look for a little duck. Can you find it? There it is! You found the duck!",
        # Leave the model room to infer a conversational contour; avoid changing
        # the rate every sentence. Pause only for the child's response.
        'ssml': '<speak>Hi, friend! Ooh, let\'s look for a little duck. Can you find it?'
                '<break time="650ms"/>There it is! You found the duck!</speak>',
    }),
    ('Count together', {
        'text': "Let's count together. One, two, three! Three little ducks. Can you show me three fingers?",
        'spokenText': "Ready? Let's count our little ducks together! One, two, three! Three little ducks. Can you show me three fingers?",
        'ssml': '<speak>Ready? Let\'s count our little ducks together!'
                '<break time="200ms"/><prosody rate="95%">One, two, three!</prosody>'
                ' Three little ducks. Can you show me three fingers?</speak>',
    }),
    ('Finish a game', {
        'text': 'We did it together! You can play again or choose all done.',
        'spokenText': "We did it together! That was fun. Want to play again? Or are you all done for now?",
        'ssml': '<speak>We did it together! That was fun.'
                '<break time="200ms"/>Want to play again? Or are you all done for now?</speak>',
    }),
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--generate', action='store_true')
    parser.add_argument('--output-dir', type=Path, default=Path('/private/tmp/LearningLabJr-Friendly-Voices'))
    parser.add_argument('--max-usd', type=Decimal, default=Decimal('0.20'))
    args = parser.parse_args()
    clips = [polly.clip_from_row(dict(row, category='audition'), voice, 'generative')
             for voice in ['Joanna', 'Salli', 'Ruth'] for _, row in SAMPLES]
    ledger = args.output_dir / 'polly-generation-ledger.json'
    if not args.generate:
        print(json.dumps(polly.plan(clips, args.output_dir, polly.read_ledger(ledger)), indent=2))
        return
    polly.generate_batch(clips, args.output_dir, ledger, args.max_usd,
                         lambda: polly.polly_client('admin', 'us-east-1'))
    result = polly.verify(args.output_dir, ledger, allow_duplicate_text=True)
    sections = []
    production = polly.PROJECT_DIR / 'NarrationAudio'
    original = json.loads((production / polly.MANIFEST_NAME).read_text())
    baseline = next(c for c in original['clips'] if c['text'] == polly.PREVIEW_TEXT)
    shutil.copyfile(production / baseline['file'], args.output_dir / 'original-preview.mp3')
    sections.append('<h2>Current app voice — reference</h2><audio controls src="original-preview.mp3"></audio>')
    for voice in ['Joanna', 'Salli', 'Ruth']:
        sections.append(f'<h2>{voice} — conversational revision</h2>')
        for (label, _), clip in zip(SAMPLES, [c for c in clips if c.voice == voice]):
            sections.append(f'<section><h3>{html.escape(label)}</h3><p>{html.escape(clip.spoken_text)}</p>'
                            f'<audio controls preload="none" src="{clip.filename}"></audio></section>')
    page = ('<!doctype html><meta charset="utf-8"><title>Friendlier narration samples</title>'
            '<style>body{font:18px system-ui;max-width:780px;margin:40px auto;padding:20px;line-height:1.5}'
            'section{padding:8px 0 20px}audio{width:100%}</style>'
            '<h1>Friendlier narration samples</h1><p>Compare the original with three voices reading more '
            'conversational scripts. Listen for warmth, clear counting, and comfortable pacing. '
            'These samples have not been human reviewed. The app library is unchanged.</p>' + ''.join(sections))
    polly.atomic_write(args.output_dir / 'index.html', page.encode())
    print(json.dumps(result, indent=2))
    print(args.output_dir / 'index.html')


if __name__ == '__main__':
    main()
