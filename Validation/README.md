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
- Beginning Sounds checks all 26 target letters, matching pictures and bundled assets, both answer-order recordings, wrong-answer retry, fresh entry, and replay.
- Letter Twins verifies all 26 unique targets, two distinct answer choices, wrong-answer retry, fresh entry, replay, and complete Ruth prompt coverage.
- Letter Draw completes all 26 unique letters, rejects skipping, and starts with a different letter on reentry/replay.
- Sound Baskets covers all 26 target letters, available artwork, stable two-letter choices, stale/wrong drop rejection, tap-only narration, real drag-and-drop, reentry, and replay.
- Menu-to-game navigation, the four-book library, and the six premium phonics routes using StoreKit's local test session.
- Wrong and correct parent-gate responses, access to the parent learning guide, and a complete three-round Touch & Count session followed by replay.
- Bundled Polly manifest lookup and every MP3 opening with a valid duration; all 60 story pages and literal narration calls are covered by the source checks.
- Parent narration preview uses the bundled narrator and starts/stops while spoken game directions remain off.
- Debug route checks assert that every narration key encountered has a bundled recording.
- Landscape Shape Post completion and replay, with opening controls at least 64 points high. The test scrolls the actual scroll view in either direction instead of swiping the whole application window.

UI navigation smoke tests establish that screens open; they do not establish that every possible interaction in every game has been tested. TestFlight purchases, device audio/VoiceOver, toddler/caregiver playtesting, and App Store materials still need release review.
