# Validation

`prepare_validation.py` creates a disposable project in `/private/tmp/LearningLabJr-validation`. It points the application target at the real source tree and gives the two test targets copies of the fixtures in this folder. The original Xcode project and its user settings are not changed. This also avoids a macOS file-coordination lock encountered when opening the original project from the command line.

Use Xcode with an **iOS 26.1 simulator** for the StoreKit UI tests. The installed iOS 26.5 runtime exhibited `SKInternalErrorDomain Code=3` and `notEntitled`; Apple has acknowledged a related StoreKit testing issue. These errors should not be worked around by bypassing production entitlements. [Apple developer discussion](https://developer.apple.com/forums/thread/826971).

```sh
python3 Validation/prepare_validation.py
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcrun simctl list devices available
# Replace the destination ID with an iOS 26.1 iPhone or iPad simulator.
xcodebuild \
  -project /private/tmp/LearningLabJr-validation/LearningLabJr.xcodeproj \
  -scheme LearningLabJr \
  -destination 'platform=iOS Simulator,id=YOUR_SIMULATOR_ID' \
  -derivedDataPath /private/tmp/LearningLabJr-build \
  -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM= \
  test
```

The source fixtures use `.swift.txt` so the application's synchronized source group does not compile test code into the app. The preparation script copies them to `.swift` files in their own test targets. The inventory JSON is generated from menu metadata, and native tests independently verify the compiled curriculum.

The parent Xcode project's app target excludes development files in both Debug and Release using `EXCLUDED_SOURCE_FILE_NAMES` patterns `$(inherited)`, `*.md`, `*.swift.txt`, `*.py`, `*.pyc`, `narration-source-*.json`, and `polly-*`. This keeps the research notes, test fixtures, narration source catalogs, generation tool, and cost ledger out of the app bundle. The generated MP3s and `NarrationAudioManifest.json` are included. The test targets still receive their own compiled fixture copies. If recreating the project, preserve this app-target setting.

Coverage:

- Six categories, exactly twelve activities each, 72 globally unique IDs and names, and complete learning/age/caregiver metadata.
- Actual compiled-bundle lookup of nature and story artwork, including all sixty book pages and namespace-qualified Space images.
- Session expiry, background elapsed time, restart, stop, and extreme duration input.
- Voice quality ranking, saved choice, missing-voice fallback, and exclusion of novelty, personal, and non-English voices.
- Restored SpriteKit garage reveal/name/close cycles and claw item pickups, with original artwork and Ruth recordings for every loaded item.
- Picnic Words checks six visible food choices, three named baskets with tap narration, all six packing orders, wrong/duplicate selection handling, 220 unique target triples, recent-list exclusion, reentry and app relaunch.
- Sound Hop (Syllable Hop) checks 30 picture words split evenly across one/two/three syllables, 2,000 selections excluding the last 20 words, beat limits, retry/reset, continuous play, reentry and app relaunch.
- Letter Hide & Seek checks all 26 shuffled targets, exactly three matches and three distinct distractors, wrong/repeated-tap handling, fresh entry, replay, and every Ruth narration line.
- Rhyme Garden checks 30 distinct pairs, picture assets, 2,000 selections avoiding the recent 20 pairs, both narration orders, and continuing play across game exit and app relaunch.
- ABC Adventure covers nine groups with all 26 letters, 78 picture words, changed per-letter selections on replay/reentry, repeated window taps, and all Ruth prompt variants.
- Word Builder checks the 45-word bank, 2,000 selections with a persistent 20-word exclusion window, picture and Ruth coverage, and a 22-word UI playthrough with reentry and app restart.
- Beginning Sounds checks all 26 target letters, matching pictures and bundled assets, both answer-order recordings, wrong-answer retry, fresh entry, and replay.
- Letter Twins verifies all 26 unique targets, two distinct answer choices, wrong-answer retry, fresh entry, replay, and complete Ruth prompt coverage.
- Letter Draw completes all 26 unique letters, rejects skipping, and starts with a different letter on reentry/replay.
- Sound Baskets covers all 26 target letters, available artwork, stable two-letter choices, stale/wrong drop rejection, tap-only narration, real drag-and-drop, reentry, and replay.
- Menu-to-game navigation, the four-book library, and the six premium phonics routes using StoreKit's local test session.
- Wrong and correct parent-gate responses, access to the parent learning guide, and a complete three-round Touch & Count session followed by replay.
- Bundled Polly manifest lookup and every MP3 opening with a valid duration; all 60 story pages and literal narration calls are covered by the source checks.
- Parent narration preview uses the bundled narrator and starts/stops while spoken game directions remain off.
- Debug route checks assert that every narration key encountered has a bundled recording.
- Shape Post checks cover ten distinct targets, three openings per round, drop-zone acceptance at phone/tablet widths, symbol availability and Ruth audio. Its landscape UI test rejects taps, incorrect and outside drops, then drags all ten shapes and replays.

UI navigation smoke tests establish that screens open; they do not establish that every possible interaction in every game has been tested. TestFlight purchases, device audio/VoiceOver, toddler/caregiver playtesting, and App Store materials still need release review.

- Color Laundry: eleven-color shuffled cycles, no immediate repeat across cycles, incorrect/duplicate selection protection, persistent per-session counts and Ruth coverage. UI checks cover two full drag cycles and fresh entry, rejecting taps, incorrect/outside drops and repeat posting.

- Little Color Lab: nine levels, three recipes per level, order-independent mixing, selection toggles, repeat-discovery protection, level transitions and replay. Native checks verify exact Ruth coverage; UI tests complete all 27 discoveries.

- Pattern Train: sixty distinct repeating sequences per session, progressively longer 5–15-shape trains, two visible repetitions before each blank, correct answers/choices, retry and repeated-tap protection, Ruth hints and replay. UI coverage completes all sixty trains across five stages.
