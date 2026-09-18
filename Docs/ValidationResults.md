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

Real-device audio review, VoiceOver interaction testing, TestFlight purchase/restore checks, and caregiver/toddler playtesting remain pending. Every game's mechanics, all story content, large-text and motor-access behavior, and representative real-device layouts need release review. Route coverage and two completed gameplay loops do not establish educational efficacy, comprehensive accessibility, or full gameplay quality. App Store privacy materials and release screenshots also need their own review.
