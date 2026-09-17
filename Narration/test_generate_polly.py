"""Offline checks for spending, resumability, catalog coverage, and file integrity."""
import io
import json
from decimal import Decimal
from pathlib import Path
import re
import tempfile
import unittest

import generate_polly as narration


class FakePolly:
    def __init__(self, fail_at=None):
        self.calls = []
        self.fail_at = fail_at

    def synthesize_speech(self, **request):
        self.calls.append(request)
        if len(self.calls) == self.fail_at:
            raise RuntimeError('Simulated connection loss')
        return {'AudioStream': io.BytesIO(b'fake-audio:' + request['Text'].encode())}


class NarrationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.output = self.root / 'audio'
        self.ledger = self.root / 'ledger.json'
        self.clips = [narration.clip_from_row({'text': text}, 'Joanna', 'generative')
                      for text in ['Hello, friend!', 'We did it together!']]

    def generate(self, client, **kwargs):
        return narration.generate_batch(self.clips, self.output, self.ledger,
                                        kwargs.pop('max_usd', Decimal('1')),
                                        lambda: client, workers=1, **kwargs)

    def test_normalization_and_xml_escaping(self):
        self.assertEqual(narration.normalize_text('  cafe\u0301\n friend '), 'café friend')
        clip = narration.clip_from_row({'text': 'Red & blue <paint>.'}, 'Joanna', 'generative')
        self.assertIn('&amp;', clip.ssml)
        self.assertIn('&lt;paint&gt;', clip.ssml)
        self.assertEqual(clip.billable_characters, len(clip.text))
        with self.assertRaises(narration.NarrationError):
            narration.clip_from_row({'text': 'Too long. ' * 400}, 'Joanna', 'generative')

    def test_budget_failure_makes_no_paid_requests(self):
        client = FakePolly()
        with self.assertRaisesRegex(narration.NarrationError, 'Budget would be exceeded'):
            self.generate(client, max_usd=Decimal('0.000001'))
        self.assertEqual(client.calls, [])
        self.assertFalse((self.output / narration.MANIFEST_NAME).exists())

    def test_spending_accounts_for_aws_ssml_character_count(self):
        class CountedPolly(FakePolly):
            def synthesize_speech(self, **request):
                response = super().synthesize_speech(**request)
                response['RequestCharacters'] = 20
                return response
        self.generate(CountedPolly())
        ledger = narration.read_ledger(self.ledger)
        self.assertEqual(narration.ledger_total(ledger), Decimal('0.0012'))
        self.assertTrue(all(Decimal(a['reservedUSD']) >= Decimal(a['estimatedUSD'])
                            for a in ledger['attempts']))
        # Older ledgers still honor the AWS count if the text-only estimate was low.
        ledger['attempts'][0]['estimatedUSD'] = '0.00001'
        self.assertEqual(narration.ledger_total(ledger), Decimal('0.0012'))

    def test_resume_reuses_hash_verified_recordings(self):
        client = FakePolly()
        first = self.generate(client)
        self.assertEqual(first['cached'], 2)
        self.generate(client)
        self.assertEqual(len(client.calls), 2)
        self.assertTrue(narration.verify(self.output, self.ledger)['integrityVerified'])

    def test_tampered_audio_needs_an_explicit_paid_retry(self):
        client = FakePolly()
        self.generate(client)
        (self.output / self.clips[0].filename).write_bytes(b'changed')
        with self.assertRaisesRegex(narration.NarrationError, 'hash mismatch'):
            narration.verify(self.output, self.ledger)
        with self.assertRaisesRegex(narration.NarrationError, 'another paid attempt'):
            self.generate(client)
        self.assertEqual(len(client.calls), 2)
        self.generate(client, retry_failed=True)
        self.assertEqual(len(client.calls), 3)

    def test_partial_failure_preserves_manifest_and_reserves_failed_cost(self):
        self.output.mkdir()
        previous = b'{"previous": "release"}'
        manifest = self.output / narration.MANIFEST_NAME
        manifest.write_bytes(previous)
        with self.assertRaisesRegex(narration.NarrationError, 'Generation stopped'):
            self.generate(FakePolly(fail_at=2))
        self.assertEqual(manifest.read_bytes(), previous)
        ledger = narration.read_ledger(self.ledger)
        self.assertEqual([a['status'] for a in ledger['attempts']], ['done', 'failed'])
        self.assertEqual(narration.ledger_total(ledger), sum(c.estimated_usd for c in self.clips))
        client = FakePolly()
        self.generate(client, retry_failed=True)
        self.assertEqual(len(client.calls), 1)
        self.assertEqual(len(json.loads(manifest.read_text())['clips']), 2)

    def test_conflicting_catalog_entries_cannot_silently_change_a_voice(self):
        path = self.root / 'catalog.json'
        path.write_text(json.dumps([{'text': 'Hi!', 'spokenText': 'Hi, friend!'},
                                    {'text': 'Hi!', 'spokenText': 'Goodbye!'}]))
        with self.assertRaisesRegex(narration.NarrationError, 'Conflicting narration'):
            narration.load_catalog([path])

    def test_catalog_covers_all_sixty_story_pages_and_static_spoken_calls(self):
        root = narration.PROJECT_DIR
        clips = narration.load_catalog(list((root / 'Narration/Source').glob('narration-source-*.json')))
        keys = {clip.text for clip in clips}
        source = (root / 'StoryTime/StoryBookGame.swift').read_text()
        pages = re.findall(r'StoryBookPage\(number: \d+, text: """(.*?)"""', source, re.S)
        self.assertEqual(len(pages), 60)
        for page in pages:
            self.assertIn(narration.normalize_text(page), keys)
        files = ['ABCsAndPhonics/LiteracyGames.swift', 'ABCsAndPhonics/LetterDraw.swift',
                 '123AndCounting/CountingMenu.swift',
                 'ShapesAndColors/ShapesAndColorsGames.swift', 'BigFeelings/BigFeelingsGames.swift',
                 'NatureExplorers/NatureLearningGames.swift', 'NatureExplorers/NatureUniqueGames.swift',
                 'StoryTime/StoryLanguageGames.swift']
        for filename in files:
            text = (root / filename).read_text()
            for spoken in re.findall(r'(?:narrator\.speak|play\.(?:say|win))\("([^"\\]*)"\)', text):
                self.assertIn(narration.normalize_text(spoken), keys, filename)
        self.assertIn(narration.PREVIEW_TEXT, keys)
        for letter in ['L', 'T', 'I']:
            for spoken in [f'Draw over the big letter {letter}. Or draw it in the air with your grown-up.',
                           f'You explored the lines in {letter}!',
                           f'You made the letter {letter} together!']:
                self.assertIn(spoken, keys)
        self.assertIn('We did it together! You can play again or choose all done.', keys)


if __name__ == '__main__':
    unittest.main()
