# Validation results

Verified on September 16, 2026. All three recorded simulator runs below finished with `** TEST SUCCEEDED **`, and every executed test reported zero failures.

| Run | Device and runtime | Passed tests | Verified coverage |
| --- | --- | --- | --- |
| September 15 — full validation | iPhone simulator, iOS 26.1 | 15: six native tests and nine UI tests | All 72 activity routes across six categories; curriculum, artwork, session timing, voice selection, parent gate and guide, narration preview, and Touch & Count completion/replay |
| September 16 — final interaction validation | iPhone simulator, iOS 26.1 | Eight: six native tests and two UI tests | Native regression checks, including `AppleClean` and `dolphinClean` in the compiled bundle; landscape Shape Post completion/replay; Touch & Count completion/replay |
| September 16 — final iPad validation | iPad simulator, iOS 26.1 | Four UI tests | Story Time routes and advancing a book to page two; parent gate and learning guide; narration preview with spoken directions still off; landscape Shape Post completion/replay |

These are **27 successful test executions with overlapping coverage**, representing 16 distinct test methods. The six native tests were repeated, and several UI tests ran on both device families. The 72 routes are visited within six category smoke tests; they are not 72 independent gameplay tests. The September 16 runs are targeted regressions, not a second complete run of every route.

## What the checks establish

The native tests verify exactly 12 complete activity records in each of six categories, with 72 unique IDs and titles. They check session expiry, elapsed background time, restart/stop behavior, and extreme duration inputs. Voice-selection tests cover quality ranking, saved preferences, missing-voice fallback, and exclusions for novelty, personal, and non-English voices. Bundle artwork checks cover nature/story menu images, required game art, all 60 book pages, namespace-qualified Space assets, and the two cleaned assets included in the final run.

The route tests open every activity and check for the expected playable screen rather than a coming-soon placeholder. The phonics run uses a local StoreKit test subscription to exercise the six premium routes. Story coverage opens the four-book library and advances one book to page two; it does not navigate every page of every book.

The parent-gate test verifies rejection of an incorrect answer and access to the learning guide after a correct answer. The narration-preview test verifies that the preview can start and stop while the spoken-directions setting remains off. It checks UI behavior and preference preservation, not the audible quality of a voice.

Touch & Count is completed through three rounds and replayed. Shape Post is completed in landscape through all six stamps and replayed to zero progress. The Shape Post test also checks that each opening button is at least 64 points high. These completion checks cover those two games; they do not establish completion or replay correctness for every mechanic in all 72 activities.

## Environment and resolved validation obstacles

The successful runs used the disposable validation project described in [Validation/README.md](../Validation/README.md), with sequential test execution on iOS 26.1 simulators. The installed iOS 26.5 simulator runtime had previously produced StoreKit `SKInternalErrorDomain Code=3` / `notEntitled` failures. Using the 26.1 runtime and sequential execution unblocked validation without bypassing production entitlements. The build SDK still appears as iOS Simulator 26.5 in the logs; the runtime used for these successful tests was 26.1.

The earlier landscape Shape Post test could not reveal an offscreen opening reliably. Explicit opening identifiers and a test helper that scrolls the actual scroll view in either direction resolved that failure. The final iPhone and iPad landscape tests both passed. Landscape screenshot attachments nevertheless show rotation/cropping artifacts; they are diagnostic captures and should not be treated as approved release imagery or proof of visual polish across orientations.

Separate inspection of the built app bundle confirmed that Markdown documents, `.swift.txt` test fixtures, and the validation preparation script are excluded. As recorded in [Validation/README.md](../Validation/README.md), the original parent Xcode project has a two-line `EXCLUDED_SOURCE_FILE_NAMES` setting covering Debug and Release. That project file is outside this Git root, so the setting must be preserved when transferring or recreating the project.

The build is not warning-free. Existing asset-symbol collisions, unassigned asset-catalog children, legacy API deprecation warnings, and stale `.venv` linker search paths remain. They did not prevent these tests from passing. The logs also contain a post-run diagnostic `simctl` lookup error after the passing test suites; the overall recorded test result is still successful.

## Evidence

The following local artifacts were inspected for this report. They are temporary-machine evidence rather than files committed to the repository.

| Run | Log | Result bundle |
| --- | --- | --- |
| Full validation | `/private/tmp/LearningLabJr-complete-validation.log` | `/private/tmp/LearningLabJr-complete-validation.xcresult` |
| Final interaction validation | `/private/tmp/LearningLabJr-final-interaction.log` | `/private/tmp/LearningLabJr-final-interaction.xcresult` |
| Final iPad validation | `/private/tmp/LearningLabJr-ipad-final.log` | `/private/tmp/LearningLabJr-ipad-final.xcresult` |

## Remaining release validation

### Polly integration checks — September 17, 2026

- Generated 823 recordings (749 Generative and 74 Neural) with Joanna, including all 60 book pages. All 823 synthesis requests succeeded without retries. File hashes match the generation ledger; MP3 payloads total 20,568,164 bytes.
- AWS returned character counts imply $1.256848 for production and $0.02538 for nine audition clips, approximately $1.28 before tax/credits. This estimate is not an AWS invoice. A subsequent offline plan reports zero requests needed.
- Eight offline generator tests passed, covering spending reservations and AWS character reconciliation, cache reuse, damaged files, failure recovery, source conflicts, XML escaping, and catalog coverage.
- All eight native tests passed, including opening every bundled recording with AVAudioPlayer and checking duration, manifest keys, normalization, and unsafe paths.
- All ten iPhone UI tests passed across the initial run and a targeted retry, covering 72 game routes, recorded parent preview while directions are muted, parent gate, Touch & Count, and landscape Shape Post. Four category tests were interrupted by SIGTERM on the initial run; all four passed when rerun without a concurrent simulator job. No missing-recording assertion occurred in the tested routes.
- The app bundle contains all 823 recordings and its manifest, with no generation scripts, narration source catalogs, or cost ledger.
- Evidence: `/private/tmp/LearningLabJr-polly-full-tests.xcresult` (14 passed, four SIGTERM interruptions) and `/private/tmp/LearningLabJr-polly-route-retry.xcresult` (four passed). Logs use the same basenames with `.log`.
- Both iPad checks passed on retry: bundled parent preview while directions are muted and landscape Shape Post completion/replay. Evidence: `/private/tmp/LearningLabJr-polly-ipad-retry.xcresult` and `.log`. The initial attempt failed before running tests because the simulator service reported an invalid device state.


### Ruth selection and clean-build validation — September 17, 2026

- Switched the default generator and all 823 production recordings to Ruth: 749 Generative clips and 74 Neural pronunciation overrides. Two approved audition recordings were reused exactly; 821 were synthesized successfully. The Ruth library represents $1.257748 in synthesis at published rates; new requests added $1.252408 before tax/credits.
- Natural pacing replaces rate overrides for playful prompts; clear directions use 95%, stories 94%, and gentle prompts 90%. The selected conversational greeting and completion scripts are now shipped. Runtime lookup keys and pronunciation markup remain intact.
- All file hashes verified. The clean app bundle contains exactly 823 Ruth MP3s (18,429,764 bytes), with no Joanna leftovers, generation scripts, source catalogs, ledgers, or project patch. Superseded audio was archived outside the source tree.
- Eight Python checks passed. The parent recorded-preview UI check passed on iPad with game directions muted. All eight native checks passed, including opening all recordings and asserting every manifest voice is Ruth.
- Evidence: `/private/tmp/LearningLabJr-ruth-tests.xcresult` (preview passed; native runner received SIGTERM before connecting) and `/private/tmp/LearningLabJr-ruth-native-retry.xcresult` (all eight native tests passed). The clean build used `/private/tmp/LearningLabJr-ruth-build`.
- The prior full route coverage remains applicable to unchanged lookup keys; this audio-only replacement received targeted playback and bundle checks. The user's selection approves the sample voice, not a listening review of all 823 clips.


### Full-alphabet Letter Draw and Sound Baskets — September 18, 2026

- Letter Draw uses a shuffled 26-letter session with no repeated target. Reentry and replay reset progress and exclude both the prior starting letter and the last displayed letter from the new first draw. Letter outlines retain every contour, including both enclosed spaces in B.
- Sound Baskets presents one picture and two letter baskets. Tapping a basket speaks its letter-name sentence; dragging submits the picture. Wrong drops keep the current target, stale drag payloads are rejected, and correct drops unlock Next letter. Accessible placement actions are provided. All 26 target letters appear once, with the same fresh-session behavior as Letter Draw.
- Added 69 Letter Draw and 79 Sound Baskets Ruth entries. All 971 published clips are Ruth (776 Generative, 195 Neural); all hashes verified and all files opened with valid durations. Added audio represents approximately $0.17 in new synthesis including two capitalization corrections; no free-tier discounts assumed. Source coverage checks include every computed prompt and response for these games.
- Ten native tests and both complete iPad UI sessions passed in `/private/tmp/LearningLabJr-alphabet-games-tests.xcresult`. The UI sessions verify all 26 targets, reentry, replay, basket taps that do not submit, a wrong drop, and correct drags. Eight Python checks passed.
- A previous native test exposed a teardown crash in LiteracyPlay on the older simulator runtime. An explicit nonisolated deinitializer avoids the unused executor hop; the same synchronous test now passes. The crash stack matches [Swift issue 88036](https://github.com/swiftlang/swift/issues/88036). Earlier simulator launch/SIGTERM failures are not counted as passing runs.
- The full Sound Baskets iPhone UI test also passed: both letter taps, wrong and correct drags, all 26 unique targets, fresh entry, and replay. Evidence: `/private/tmp/LearningLabJr-soundbaskets-iphone.xcresult`.


### Full-alphabet Letter Twins — September 18, 2026

- Letter Twins now uses 26 shuffled targets without repetition and two distinct, stable answer choices per round. Wrong answers retain the current target. Reentry and replay reset progress, excluding the prior starting and last displayed letters from the new first round.
- Added an active-session guard after the initial UI test caught an unexpected reshuffle during play. Leaving clears the session; repeated appearance callbacks do not reset an active session.
- Added 46 Ruth recordings for the remaining 23 letters, retaining pronunciation markup. All 1,017 manifest entries use Ruth; hashes verified. Additional synthesis estimate: $0.033488 before tax/credits.
- Eleven native tests and the complete iPhone UI test passed in `/private/tmp/LearningLabJr-lettertwins-retry.xcresult`, including all 26 targets, wrong-answer retry, leaving after partial progress, fresh entry, and replay. Eight Python checks passed, including source coverage for every Letter Twins instruction and response. The first failed UI run is retained in `/private/tmp/LearningLabJr-lettertwins-tests.xcresult`.


### Original garage and claw restoration — September 18, 2026

- Vehicle Peekaboo and Word Claw now route to their original SpriteKit scenes, including MechanicGarage/MechanicGarageDoor and ClawGameBackground/Claw artwork. The garage opens on tap, announces the vehicle on the next tap, and closes/selects another on the following tap. Opening/closing animations reject overlapping input.
- Restored the claw's tap-to-pick interaction, correcting alignment so it moves over the selected item before descending. Scene bounds contain the bottom row, and source aspect ratios are preserved for the background and bottom items. Garage CSV display names now map to the actual case-sensitive asset identifiers.
- Both scenes send names to GameNarrator and use Ruth recordings rather than legacy item sound files. Sprite playback pauses with backgrounding/session limits, and narration stops on leaving. Existing premium gates remain in place.
- Added 18 Ruth recordings (two directions plus 16 item names), approximately $0.0081 in synthesis before tax/credits. All 1,035 current recordings passed integrity verification; eight Python checks passed.
- Twelve native checks and the iPhone garage/claw UI interaction test passed in `/private/tmp/LearningLabJr-original-arcade-retry.xcresult`. Native checks verify every original background, vehicle/sports asset and Ruth name recording. UI checks cover two garage reveal/name cycles and two claw pickups. Exported screenshots were visually inspected at `/private/tmp/LearningLabJr-arcade-screenshots`; the original artwork is visible in both scenes. The initial build failure from a missing Combine import was corrected before this passing run.

## Beginning Sounds full alphabet — September 18, 2026

- Replaced the three fixed rounds with 26 shuffled target letters, each appearing once per session. Fresh entry/replay excludes both the previous starting letter and last displayed letter. Incorrect answers keep the current target; completion requires all 26 matches.
- Kept two picture choices, with a different distractor for each target and randomized choice positions. Added simple illustrations for picture pairs missing from the asset library. Pairs match spoken beginnings, including ice cream/ice cube and x-ray/x-ray hand.
- Added Ruth narration for both possible answer orders, success, and retry for every pair. The catalog now contains 1,135 Ruth recordings totaling 25,107,812 bytes. Synthesis for this change, including the initial prompt revision, reserved approximately $0.273 before credits/taxes. Eight Python narration checks passed.
- The first iPhone run passed all 13 native checks but the UI runner received SIGTERM at round 22; its result is `/private/tmp/LearningLabJr-beginning-sounds-tests.xcresult`. The final run passed all 13 native checks and the complete 26-round UI test, including wrong answers, leaving/reentry, and replay, at `/private/tmp/LearningLabJr-beginning-sounds-final.xcresult`. The initial iPhone picture layout was inspected at `/private/tmp/LearningLabJr-beginning-sounds.png`.

## Word Builder expansion — September 18, 2026

- Replaced three fixed words with 45 illustrated words: nine three-letter, sixteen four-letter, and twenty five-letter words. Random selection excludes the 20 most recently presented words, persisted across game exits and app relaunches. Next word remains available after every completed word without a three-round reset.
- Letter spaces use the actual word length. Unique letter buttons can be reused for repeated letters such as EGG and SHEEP; incorrect taps do not advance, and completed words reject further letter taps.
- Added 185 Ruth recordings covering every new direction, spelled-word success line, adjacent-letter transition, and retry. Letter names retain explicit pronunciation markup using Ruth Neural; full directions use Ruth Generative. The 1,320-clip library totals 28,976,304 bytes; this batch reserved approximately $0.1553 before taxes/credits. Eight Python narration checks passed.
- All 14 native checks passed, including available artwork, exact narration coverage and 2,000 random word selections with the 20-word exclusion window. The initial UI fixture omitted Word Builder's premium entitlement and was corrected; no app entitlement behavior changed. The final run passed all 14 native checks and the 22-word UI playthrough, including incorrect taps, variable word lengths, leaving/reentry, and app relaunch: `/private/tmp/LearningLabJr-word-builder-final.xcresult`. The five-letter iPhone layout was visually inspected at `/private/tmp/LearningLabJr-word-builder.png`.

## ABC Adventure full alphabet — September 18, 2026

- Expanded the three fixed groups to nine sequential groups covering A–Z once, with two windows in the final Y/Z group. Each group requires opening every distinct window before advancing; repeated taps replay the word without increasing the count.
- Selects from 78 illustrated picture words, with at least two options per letter. Choices stay fixed within a session. New entry and replay select a different word for each letter than the previous session; selections are saved locally. Existing Beginning Sounds artwork is shared for words without bundled picture assets.
- Added 146 Ruth recordings for every picture phrase, last-window success variant, and missing group prompt. Letter names use explicit pronunciation markup. The catalog contains 1,466 Ruth clips totaling 31,368,664 bytes. Generation reserved approximately $0.0841 before credits/taxes. Eight Python narration checks passed.
- All 15 native checks and the UI test passed at `/private/tmp/LearningLabJr-abc-adventure-final.xcresult`. Native checks cover 100 sessions, per-letter vocabulary and audio coverage. UI checks open all 26 letters twice, compare every replay picture, reject repeated-tap advancement, finish the two-window Y/Z group, and verify fresh entry. The initial UI check was corrected to wait for page transitions before inspecting the next group. The iPhone window layout was visually inspected from the exported test screenshot.

## Rhyme Garden expansion — September 18–19, 2026

- Replaced three fixed rounds with 30 rhyme pairs and continuous Next rhyme play. Random selection excludes the previous 20 pairs, persisted across game exit and app relaunch. Answer positions shuffle once per round; wrong answers keep the current pair and solved rounds disable answer buttons.
- Added 114 Ruth recordings for both answer orders, success and retry. The word-bank checks cover bundled pictures and 2,000 selections with recent-pair exclusion.
- The earlier gameplay-only test passed 22 rounds, wrong answers, recent-pair exclusion, reentry and app relaunch at `/private/tmp/LearningLabJr-hide-seek-gameplay.xcresult`.

## Letter Hide & Seek full alphabet — September 18–19, 2026

- Expanded from three targets to all 26 letters in shuffled order without target repetition. Each board has three target copies and three distinct distractors in stable shuffled positions. Wrong or already-found taps cannot increase the count. Reentry/replay excludes the previous starting and last displayed target.
- Added 73 Ruth recordings for all target directions and feedback. Retry audio reuses letter-specific model guidance.
- The earlier gameplay-only test passed all 26 letters, wrong/repeated taps, reentry, completion and replay at `/private/tmp/LearningLabJr-hide-seek-gameplay.xcresult`. The six-cell iPhone layout was visually inspected at `/private/tmp/LearningLabJr-hide-seek.png`.

## Sound Hop / Syllable Hop expansion — September 18–19, 2026

- Replaced three fixed rounds with 30 picture words, ten each with one, two and three syllables. Continuous Next word play excludes the previous 20 words, persisted across exits and app relaunches. Visible word parts support caregiver clapping; retry narration reads the whole word naturally and gives the clap count.
- Preserved the three-beat limit, explicit checking and reset. Incorrect counts reset to zero; successful checks disable beat controls until Next word. Added 83 Ruth recordings.
- The earlier 22-word gameplay-only test passed all three syllable counts, zero-count retry, tap limit, reset, correct checks, continuing play, reentry and app relaunch at `/private/tmp/LearningLabJr-sound-hop-gameplay.xcresult`. Its iPhone layout was visually inspected at `/private/tmp/LearningLabJr-sound-hop.png`.

## Ruth recording completion — September 19, 2026

- Renewed AWS authentication and generated all 270 pending clips. All 1,736 manifest entries use Ruth, totaling 38,377,504 audio bytes (38.4 MB); the previous 1,466 entries are unchanged. New successful generation reserved approximately $0.4322 before credits/taxes. Two earlier authentication failures retain their conservative reservations in the ledger.
- Eight Python narration checks passed. The standard validation project has runtime recorded-prompt assertions enabled again. All 21 native checks passed with the completed audio library at `/private/tmp/LearningLabJr-three-games-ruth-final.xcresult`, including exact narration keys for every variant and decoding every MP3.
- The final UI rerun did not complete: Hide & Seek unexpectedly returned to its menu at round 24, then the Rhyme Garden and Sound Hop test runners received SIGTERM. A clean simulator retry failed to install the runner because CoreSimulator reported invalid device state and Mach server death (`/private/tmp/LearningLabJr-three-games-ruth-clean.xcresult`). Earlier complete gameplay-only runs passed as recorded above. No app or test logic was changed to suppress these failures; a complete audio-enabled UI rerun remains pending a stable simulator.

## Picnic Words six-food board — September 19, 2026

- Replaced one-food browsing and sequential two-item packing with a fixed three-column, two-row grid of six food pictures and three named baskets. Requested foods fill their matching baskets in any order; tapping baskets speaks their food names. Incorrect choices do not change progress, and packed foods cannot count twice.
- Uses 12 pictured foods and all 220 distinct three-food target sets, with three additional choices sampled for each board. Continuous Next picnic play excludes the most recent 20 target sets across game exits and app relaunches. Target names stay below the baskets after packing.
- Generated 257 Ruth clips for every target-list instruction, basket prompt, packed-food response, retry and completion. Existing recordings are unchanged. The full library contains 1,993 Ruth clips totaling 44,822,012 bytes; generation reserved approximately $0.4282 before credits/taxes. Eight Python source checks passed.
- All 22 native checks passed at `/private/tmp/LearningLabJr-picnic-tests.xcresult`, including every prompt, all six packing orders for all 220 lists, duplicate/wrong selection handling and 1,000 randomized boards with recent-list exclusion. All 1,993 MP3 hashes passed integrity verification, and native playback checks opened every recording.
- iPhone and iPad UI runs passed the initial assertions for all six visible food pictures, basket names and narration lookup, wrong selections, packing out of order, and advancing to new picnics. Both runners were terminated with SIGTERM before finishing the 22-list and relaunch test (`/private/tmp/LearningLabJr-picnic-tests.xcresult`, `/private/tmp/LearningLabJr-picnic-ipad.xcresult`). A full UI run remains pending a stable simulator. Screenshot attempts captured the simulator shutting down, so no visual-review pass is claimed.

## ABCs & Word Play menu styling — September 19, 2026

- All 12 cards now use orange system icons, skill descriptions, and the shared rounded white card treatment used by the other categories. Premium activities retain their own icons with a separate lock badge. Routing, entitlements and Ruth recordings are unchanged.
- The simulator build succeeded, and the exported iPhone menu screenshot was visually reviewed for icon rendering, text wrapping, spacing and consistent colors. The existing category route test navigated several games before its runner terminated with SIGTERM; the full route test did not pass (`/private/tmp/LearningLabJr-phonics-menu-style.xcresult`).

## Shape Post drag matching — September 19, 2026

- Expanded Shape Post from three shapes to circle, square, triangle, rectangle, oval, diamond, star, heart, pentagon and hexagon. Each session shuffles all ten without repetition and shows three distinct openings per target. The other shape games retain their existing shape banks.
- Direct finger dragging moves the stamp and highlights the opening under the finger. Only a drop on the matching opening completes the round; taps, wrong drops and outside drops do not advance. A solved round fills its outline and offers Next shape. VoiceOver exposes a named posting action on each opening. Gesture handling is limited to the stamp and disabled after posting so scrolling remains available.
- Generated 31 Ruth clips for directions, success, retry and completion, reserving $0.03999 before credits/taxes. Eight Python narration checks passed, and all 2,024 MP3 files passed integrity verification.
- All 23 native checks passed at `/private/tmp/LearningLabJr-shape-post-final.xcresult`, including 100 shuffled sessions, drop-zone acceptance/rejection at three widths, system-symbol availability, exact Ruth coverage, and full-catalog audio decoding.
- The final portrait UI check passed all ten correct drags, no repeated targets, tap rejection, wrong/outside drop rejection, completion and replay (`/private/tmp/LearningLabJr-shape-post-portrait.xcresult`). Its screenshot was visually reviewed for the complete board and readable labels. The earlier landscape run passed initial interaction checks but lost the game screen while scrolling to Next shape; landscape completion remains unverified. No full landscape pass is claimed.

## Color Laundry expanded colors — September 19, 2026

- Expanded from three colors and six fixed shirts to eleven colors: red, orange, yellow, green, blue, purple, pink, brown, black, white and gray. Continuous shuffled cycles use each target once before repeating and prevent immediate repeats at cycle boundaries. Each round offers three distinct baskets, including the matching color. Per-color basket counts persist within the session; leaving and reentering resets progress.
- Correct sorting pauses for Next shirt, and wrong or duplicate taps cannot increase counts. Tinted shirt and basket backgrounds keep white visible. Other games' paint options are unchanged.
- Generated 27 additional Ruth recordings, reusing six existing directions/retry recordings. Added generation reserved $0.03108 before credits/taxes. Eight Python narration checks and all 2,051 recording integrity checks passed.
- All 24 native checks and the UI test passed at `/private/tmp/LearningLabJr-color-laundry.xcresult`. Native coverage includes 100 eleven-color cycles, basket membership, cycle boundaries, wrong/duplicate selection protection, counts and exact Ruth coverage. UI coverage includes two full cycles, incorrect choices, disabled solved baskets, continued play and fresh entry. The white-shirt screenshot was visually reviewed for contrast, labels and layout.

## Color Laundry dragging and pink — September 19, 2026

- Replaced the system pink with a brighter pink (RGB 1.0, 0.42, 0.72), shared by the shirt and basket. Changed basket tapping to direct shirt dragging, with generous basket drop zones, hover outlines and reset after incorrect/outside drops. Solved rounds disable further dragging, retain the counts and show Next shirt. Named accessibility actions support posting with VoiceOver.
- The gameplay UI test passed two complete eleven-color cycles, tap rejection, wrong/outside drops, duplicate-drop protection and fresh entry (`/private/tmp/LearningLabJr-laundry-drag-gameplay.xcresult`). Pink artwork and the board layout were visually reviewed from its screenshot.
- Initial attempts to generate drag-specific narration failed because AWS authentication expired; the failed-request reservations remain in the ledger. The final game reuses its existing Ruth directions and feedback and shows a separate on-screen sliding instruction. No new recordings or Apple-voice fallback are required. The temporary gameplay-only test omitted runtime audio assertions while those lines were being considered; the standard fixture has been restored with coverage assertions enabled.
- All 24 native checks passed on the final source (`/private/tmp/LearningLabJr-laundry-drag-native.xcresult`), including exact Ruth coverage, full audio decoding and basket hit testing at three screen widths. The successful gameplay screenshot predates the restoration of the original spoken-prompt wording; the interaction and artwork are unchanged.

## Little Color Lab levels — September 19, 2026

- Added nine sequential levels with three recipes each. Starts with red/yellow/blue producing orange/green/purple, followed by orange, blue, red, yellow, green, purple, pink and brown combined with white and black. Blue shades include sky blue, navy and gray. Other results include peach, cream, ochre, lavender, tan, pink and named light/dark variants. Screen swatches represent simplified pretend-paint mixtures.
- Each level requires all three unique discoveries; pair order does not matter, repeated mixtures do not increase progress, selecting a third paint replaces the oldest selection, and levels reset selections/results/discoveries. Completion supports replay from primary colors. Level introductions stay stable during mixing so result narration is not interrupted by an automatic suggestion change.
- Generated 49 Ruth clips, including level introductions, selections, results and guidance. Successful generation reserved $0.07155 before credits/taxes. The 2,100-clip library totals 46,803,984 bytes. All recordings passed integrity checks and all eight Python narration checks passed.
- All 26 native checks and the complete UI test passed at `/private/tmp/LearningLabJr-color-lab-final.xcresult`, with runtime recorded-narration coverage enabled. UI coverage completes all 27 discoveries across nine levels, checks incomplete selections and verifies replay. Native checks cover recipe membership, reversed selections, repeated discoveries, invalid selections, toggling, third-paint replacement, progression and exact Ruth coverage. The blue-shades results screenshot was visually reviewed.

## Pattern Train progression — September 19, 2026

- Replaced three fixed rounds with sixty distinct repeating sequences per session, sampled from 144 ordered shape groups. Five stages introduce AB, AAB/ABB, ABC, AABB/ABAC, then AABBC/ABACB. Twelve trains per stage increase in completed length from 5 to 15 shapes, including the final answer slot. Every blank follows at least two full visible repetitions. Reentry/replay reshuffles a fresh session; uniqueness is guaranteed within a session, not across separate sessions.
- Numbered cars display in five columns. Three stable answer choices include the correct shape. Correct answers reveal the final car and pause for Next train; incorrect answers retain the current train and offer Ruth's repeating-group hint. A separate help button repeats that hint and shows the group in text. Duplicate taps cannot advance progress.
- Generated 152 Ruth recordings for the complete hint bank, stage instructions and missing feedback. Added generation reserved $0.36921 before credits/taxes. Eight Python narration checks passed; all 2,252 recordings passed integrity verification (52,224,928 bytes total).
- All 28 native checks and the complete sixty-train UI test passed at `/private/tmp/LearningLabJr-pattern-train.xcresult`. Native checks cover 100 generated sessions, unique groups and displayed patterns, every length from 5–15, increasing lengths, answer derivation, choices, progression guards and all Ruth hints. UI checks independently infer the answer from visible shapes, verify no repeated groups, exercise wrong answers/help at each stage, complete all sixty trains and replay. The 15-shape iPhone layout was visually reviewed.

## Build a Shape Town drag pictures — September 19, 2026

- Replaced the three tap-to-add scenes with twenty vector pictures: house, tree, snowman, fish, ice cream, mountains, mushroom, tent, rocket, sailboat, car, bird, truck, train, robot, flower, butterfly, castle, lighthouse and windmill. Each uses three to five pieces; pictures progress from three-piece designs to five-piece designs.
- A tray below the picture supports selecting and directly dragging any available piece. Dimmed colored outlines fill on a matching drop; outside/incorrect drops return to the tray. Geometry, color and orientation determine matching, and identical pieces such as equal wheels can fit either corresponding target. Used tray pieces fade, duplicate placement cannot count twice, and each completed picture pauses before advancing. Small target drop regions are expanded to at least 64 points. Named accessibility actions support selection and placement without dragging.
- Generated 81 Ruth recordings for all picture introductions/completions, shape/color selection directions and missing feedback. Added generation reserved $0.10242 before credits/taxes. Eight Python narration checks passed, and all 2,333 recording hashes verified; the library totals 53,549,836 bytes.
- All 30 native checks and the complete twenty-picture UI test passed at `/private/tmp/LearningLabJr-shape-town.xcresult`. Native coverage places every picture forwards and backwards at three screen widths, checks geometry bounds, invalid/outside/duplicate drops, identical-wheel swaps, progression guards and exact Ruth coverage. UI coverage places every picture in reverse tray order, checks selection without placement, wrong/outside drops, all twenty completions and replay. House, butterfly and windmill screenshots were visually reviewed.

## Nesting Shapes color sequences — September 19, 2026

- Replaced three size-choice rounds with color-based nesting across circle, square, triangle, rectangle, oval, diamond, star, heart, pentagon and hexagon. Every nest requests three distinct colors from red, yellow, blue, orange, green, purple and pink. Equal-sized choice icons keep the choice focused on color while placed layers shrink automatically.
- Continuous shuffled decks use each shape once per ten-nest cycle, with no immediate repeat at cycle boundaries. Each shape receives a different ordered color sequence from its previous appearance. Local palette memory persists across entries; reentry resets progress and starts on a different shape from the last shown. Wrong/stale choices cannot advance, used colors disable, and completed nests pause for Build another nest.
- Generated 80 Ruth clips covering all seventy shape/color prompts and ten completion lines. Added generation reserved $0.05466 before credits/taxes. Eight Python narration checks passed; all 2,413 recordings passed integrity verification, totaling 54,356,444 bytes.
- All 32 native checks and the full two-cycle UI test passed at `/private/tmp/LearningLabJr-nesting-colors.xcresult`. Native checks cover 1,000 nests, shape uniqueness, three-color choices, palette changes, wrong/stale selection rejection, progression and encoded palette memory. UI checks cover all ten shapes twice, requested-color matching, layer colors, wrong selections, changed sequences and reentry. The completed heart-nest screenshot was visually reviewed. A final display-only edit fixes singular wording for one completed nest.

## Shape Trails expansion — September 19, 2026

- Expanded from three shapes to twenty-five distinct closed outlines, including polygons, hearts, stars, crescents and curved shapes. Each session visits all twenty-five before completion and supports replay. Guide and completed strokes share the same geometry, with ordered checkpoints for finger tracing or tapping.
- Kept the moving guide at a 68-point touch target. UI testing exposed an accessibility frame that covered the entire board; the final layout keeps the guide's accessible bounds aligned with its visible control. Wrong/outside touches and stale advances cannot complete checkpoints.
- Generated 45 additional Ruth recordings, reusing existing lines where available. Added generation reserved $0.07224 before credits/taxes. Eight Python narration checks passed; all 2,458 recordings passed integrity verification, totaling 55,258,424 bytes.
- All 34 native checks passed at `/private/tmp/LearningLabJr-shape-trails-final.xcresult`, covering closed geometry, checkpoint order, bounds at three screen widths, progression guards and exact Ruth coverage. The final full twenty-five-shape UI test passed at `/private/tmp/LearningLabJr-shape-trails-verified.xcresult`, including guide bounds, an actual finger drag, tap tracing, distinct shapes, completion and replay, with runtime narration coverage enabled. Completed heart and crescent screenshots were visually reviewed.

Real-device audio review, VoiceOver interaction testing, TestFlight purchase/restore checks, and caregiver/toddler playtesting remain pending. Every game's mechanics, all story content, large-text and motor-access behavior, and representative real-device layouts need release review. Route coverage and two completed gameplay loops do not establish educational efficacy, comprehensive accessibility, or full gameplay quality. App Store privacy materials and release screenshots also need their own review.
