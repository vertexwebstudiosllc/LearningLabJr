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
- Wrong and correct parent-gate responses, access to the parent learning guide, and a complete twenty-round Touch & Count session followed by replay.
- Bundled Polly manifest lookup and every MP3 opening with a valid duration; all 60 story pages and literal narration calls are covered by the source checks.
- Parent narration preview uses the bundled narrator and starts/stops while spoken game directions remain off.
- Debug route checks assert that every narration key encountered has a bundled recording.
- Shape Post checks cover ten distinct targets, three openings per round, drop-zone acceptance at phone/tablet widths, symbol availability and Ruth audio. Its landscape UI test rejects taps, incorrect and outside drops, then drags all ten shapes and replays.

UI navigation smoke tests establish that screens open; they do not establish that every possible interaction in every game has been tested. TestFlight purchases, device audio/VoiceOver, toddler/caregiver playtesting, and App Store materials still need release review.

- Color Laundry: eleven-color shuffled cycles, no immediate repeat across cycles, incorrect/duplicate selection protection, persistent per-session counts and Ruth coverage. UI checks cover two full drag cycles and fresh entry, rejecting taps, incorrect/outside drops and repeat posting.

- Little Color Lab: nine levels, three recipes per level, order-independent mixing, selection toggles, repeat-discovery protection, level transitions and replay. Native checks verify exact Ruth coverage; UI tests complete all 27 discoveries.

- Pattern Train: sixty distinct repeating sequences per session, progressively longer 5–15-shape trains, two visible repetitions before each blank, correct answers/choices, retry and repeated-tap protection, Ruth hints and replay. UI coverage completes all sixty trains across five stages.

- Build a Shape Town: twenty pictures with 3–5 pieces, any-order dropping at phone/tablet widths, wrong/outside/duplicate rejection, interchangeable identical pieces, Ruth coverage and a full twenty-picture UI session with replay.

- Nesting Shapes: ten-shape cycles, three distinct requested colors from seven choices, fresh per-shape color sequences, incorrect/stale selection protection, saved palette memory and Ruth coverage. UI checks complete two cycles and reenter the game.

- Shape Trails: twenty-five distinct closed outlines, ordered checkpoints, complete guide/progress paths, geometry at three widths, guarded advancement, Ruth coverage, finger tracing, tap-to-trace completion and replay.

Mosaic Garden coverage checks twelve unique pictures, exposed paint regions at three widths, any-color filling, repainting without duplicate progress, shuffled progression, completion, and replay. The UI fixture also checks Ruth recording coverage during play.

Shape Bubble Pop coverage checks thirty distinct clues per session across three stages, three valid targets among six bubbles, distractors that match only one attribute, invalid/duplicate taps, completion/replay, menu replacement, symbol availability, and exact Ruth coverage.

Little Road Trip coverage checks twenty-four unique ordered journeys, connected routes without repeated cells, increasing lengths and grid sizes, all four directions, invalid/duplicate move guards, complete playthrough/replay, and Ruth coverage.

Shape Safari coverage checks thirty illustrated examples, three shuffled ten-shape passes, nonrepeating matching pairs, wrong/duplicate taps, complete progression/replay, and exact Ruth narration coverage.

Number Picnic coverage checks three complete shuffled passes through one to ten, no repeated counts within each pass or adjacent counts across passes, valid shuffled answers, wrong/duplicate answer guards, asset availability, full playthrough/replay, and Ruth coverage.

Touch & Count coverage checks four 3×3, six 4×4 and ten 5×5 mixed-animal boards; distinct counts and targets within each stage; no immediate repeats across boundaries; target-only counting, distractor/duplicate/outside taps, arbitrary tap order, progression/replay, 44-point touch targets, assets and Ruth narration through 25. Board construction is checked exhaustively for every animal and quantity in each grid size.

Four counting activities now have native coverage for all 74 levels and dedicated full UI playthroughs, including replay. Coverage checks randomized missing-amount addition/subtraction, treasure addition in steps of five from 0–100, more/fewer comparisons, and exact dot tickets.

Counting picture variety: twelve-fruit and twelve-animal collections, eight illustration themes, full collection use before repeats, and no repeats within three consecutive rounds. Native coverage checks assets, symbols, unchanged quantities and all dynamic Ruth phrases. The themed and food/animal layout tests exercise three rounds per game with screenshots; Number Picnic and Touch & Count retain full-session UI tests.

Picnic Share checks every supported equation and Ruth phrase, balanced ten-round sessions, three unique valid answer choices, wrong answers, automatic advancement after success, replay and fresh session generation.

Sleepy Sheep has separate native checks for all 100 counts, hop/arrival guards, completion and Ruth coverage. Its full UI test checks the automatic first sheep, each count through 100, completion, replay and fresh re-entry.

Treasure Trail checks all 210 valid start/goal pairs and their Ruth coverage, twenty shuffled goals, three distinct chest choices, rejected wrong amounts/locations, successful left-pile updates, duplicate-drop guards, completion and replay. Its UI test drags actual chests onto both piles.

Which Has More? checks two distinct fruit types per comparison, 20 unique unordered pairings per session, no shared fruit in consecutive rounds, matching artwork/accessibility labels, both comparison modes, and Ruth directions/feedback for mixed fruit groups.

Five-Frame Garden checks 20 distinct five-flower combinations drawn from all 56 possible sets, coverage of petal counts 1–8, matching outline/tray contents, wrong-location and duplicate-drop rejection, five required plants, completion/replay and every Ruth line. Its full UI test plants all 100 flowers.

Build-A-Tower has 24 rounds across counting, size matching and shape matching, with three to ten blocks per stage. Native checks cover 100 sessions, stage boundaries, wrong blocks, outside drops, completion guards and exact Ruth recordings. Its UI playthrough builds all 156 blocks, exercises incorrect drops and checks completion, replay and fresh entry.

Dot Detective has 24 missing-pattern puzzles, three per grid size from 3×3 through 10×10. Native checks cover 100 sessions, unique puzzles, changed opening puzzles, window bounds, exact missing-dot mapping, three distinct equal-count choices, guarded progression and Ruth coverage. The UI test checks every grid size, wrong/correct answers, completed grids, replay and changed opening puzzles on fresh entry.

Frog Hops has eighteen randomized road crossings, six each on 4×4, 5×5 and 6×6 boards. Native checks exercise 100 sessions, unique connected routes, opening-route changes, all invalid board moves, progression, vehicle assets and exact Ruth coverage. Its full UI test checks all 72 hops, blocked cells, row skipping, repeated taps, completion, replay and fresh entry.

Counting Drum uses eighteen unique sequences of two to seven beats across three drums. Native checks cover 100 sessions, every possible error position, replay/reset guards, input locking during demonstrations, Ruth coverage and playable percussion files. Its UI playthrough covers every round, automatic retry, manual demonstration, background/resume, completion and fresh sessions.

Weather Window checks six conditions with five discoveries each, forward/backward wraparound, selecting a condition resetting its overview, invalid input guards, unique exploration counts, fresh entry, artwork availability, and exact Ruth coverage for all thirty pages. The UI test explores every page, exercises actual horizontal swipes and arrow buttons, reselects every condition, and checks reset after leaving the game. Picture swipes take precedence over navigation-back gestures while vertical gestures still scroll.

Move Like an Animal checks sixteen distinct animals across 200 shuffled sessions, no immediate repeats, invalid/stale advancement guards, transparent cutout pixels for every image, and all seventeen Ruth lines. Its UI test completes all sixteen moves and checks the grown-up reminder, replay, reentry, and last-animal persistence across app relaunch.

Day & Night checks eighteen distinct activities (nine daytime and nine nighttime), three progressive interaction stages, 200 full sessions, stable shuffled choices, no repeated opening activity, wrong/duplicate/stale input guards, ordered routines, artwork, and all 79 Ruth lines. Its UI test completes every activity with six real drag-and-drop interactions, tap placement, incorrect/out-of-order choices, replay, and reentry.

Nature Detective checks twenty-four unique animal/insect targets across 200 full sessions, changed opening targets, stable shuffled answers, recent-distractor exclusion, all clue levels, wrong/stale/duplicate actions, early success, transparent image pixels, and complete Ruth coverage. Its UI test solves all 24 mysteries, checks every clue and wrong answers, and verifies replay and reentry.

Cozy Nest: `testCozyProjectsSequenceGuardsVarietyAndRuth` checks 100 complete ten-project sessions and exact Ruth coverage. `testCozyNestTenProjectsAndReplay` builds every project and checks hints, completion, replay, and reentry.

Funny Face Studio: `testFunnyFaceCopyIdentifySequenceAndRuth` validates six distinct renders, 200 sessions, interaction guards, and Ruth coverage. `testFunnyFaceCopyIdentifyAllSixAndReplay` covers copying, identification, answer speakers, gentle retries, completion, replay/reentry, and the shared Mad label.

Flower Breaths: `testFlowerBreathsEightGentleActivitiesAndRuth` checks all eight activities, both play/watch paths, input guards, drop validation, kind-word choices, and Ruth coverage. `testFlowerBreathsAllActivitiesDragWatchAndReplay` covers the full playthrough, blanket drag, all watching options, replay, and reentry.
