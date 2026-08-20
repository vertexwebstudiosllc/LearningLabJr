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

The parent Xcode project's app target excludes development files in both Debug and Release using `EXCLUDED_SOURCE_FILE_NAMES = "$(inherited) *.md *.swift.txt prepare_validation.py"`. This two-line project change keeps the research notes and fixtures out of the app bundle. The test targets still receive their own compiled fixture copies. If recreating the project, preserve this app-target setting.

Coverage:

- Six categories, exactly twelve activities each, 72 globally unique IDs and names, and complete learning/age/caregiver metadata.
- Actual compiled-bundle lookup of nature and story artwork, including all sixty book pages and namespace-qualified Space images.
- Session expiry, background elapsed time, restart, stop, and extreme duration input.
- Voice quality ranking, saved choice, missing-voice fallback, and exclusion of novelty, personal, and non-English voices.
- Menu-to-game navigation, the four-book library, and the six premium phonics routes using StoreKit's local test session.
- Wrong and correct parent-gate responses, access to the parent learning guide, and a complete three-round Touch & Count session followed by replay.
- Parent narration preview starts/stops while spoken game directions remain off.
- Landscape Shape Post completion and replay, with opening controls at least 64 points high. The test scrolls the actual scroll view in either direction instead of swiping the whole application window.

UI navigation smoke tests establish that screens open; they do not establish that every possible interaction in every game has been tested. TestFlight purchases, device audio/VoiceOver, toddler/caregiver playtesting, and App Store materials still need release review.
