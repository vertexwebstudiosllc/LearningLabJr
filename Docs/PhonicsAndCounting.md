# ABCs and counting implementation review

These categories each expose exactly 12 destinations. They share presentation and a small session model; each destination has its own interaction. The category arrays supply stable IDs, skills, age guidance, interaction descriptions, and caregiver tips to the shared curriculum browser.

The design rationale and primary research sources are in [ResearchAndReview.md](ResearchAndReview.md). Ages here are product guidance for shared play, not a developmental assessment. A child is never required to complete the older challenges to use the other activities.

## ABCs & Word Play

| Activity | Interaction and content | Guidance |
| --- | --- | --- |
| Letter Twins | Find an identical large uppercase letter among two choices: A, M, S | 2–4 |
| Letter Draw | Explore one large L, T, or I using the existing glyph paths; clear freely or draw in the air with a caregiver | Optional 4+; premium |
| Sound Baskets | Sort milk/moon/sun picture cards into beginning-sound families anchored by moon and sun | Optional 4+; premium |
| Vehicle Peekaboo | Hear a clue, then open the garage of the named fire truck, car, or tractor | 2–4; premium |
| Picnic Words | Browse a food carousel and pack a two-item spoken list in order | 2–4 with help; premium |
| Word Claw | Select an object to aim the claw, then lower it to collect the named object | 2–4; premium |
| Word Builder | Build CAT, SUN, and DOG from left to right using a visible model | Optional 4+; premium |
| Beginning Sounds | Compare spoken word beginnings: moon/milk, sun/sandwich, cat/cow | 3–4 with a caregiver |
| ABC Adventure | Open letter windows to discover picture words and hear their letter names | 3–4 with a caregiver |
| Rhyme Garden | Listen to picture-word pairs: cat/hat, goat/boat, mouse/house | Optional 4+ |
| Letter Hide & Seek | Find all three copies of M, S, or A among distractor letters | 3–4 |
| Syllable Hop | Clap/tap the parts in cow (1), rabbit (2), and octopus (3), with a visible caregiver cue | Optional 4+ |

The original six premium positions are preserved, including the existing entitlement and parent-gate flow. The revised ABC Adventure uses discovery windows so it does not repeat Word Builder's letter-order mechanism. Rhyme Garden and Letter Hide & Seek replace the former vowel/consonant classification quizzes.

Phonological activities narrate whole words. They do not pass isolated letters or invented phoneme spellings to text-to-speech and claim those are accurate speech sounds. First-sound comparisons use regular, unambiguous examples; rhyme examples use matching spoken endings. Syllable counting is supported by a caregiver; the app does not claim to recognize the child's speech or claps.

Word and picture matches were checked against the catalog. The active destinations no longer use a tortoise to depict an elephant, a hare to depict a goat, or a cup to depict ice cream. Existing cat, octopus, milk, apple, orange, duck, and sheep artwork was visually inspected. Existing images are reused without modifying the user's asset files.

## 123s & Counting

| Activity | Distinct interaction | Quantities |
| --- | --- | --- |
| Number Picnic | Count apples, oranges and strawberries; select a numeral supported by dots in rows of five | 24 rounds, progressing from 3 to 10 with three rounds per count |
| Touch & Count | Mark each individual duck once; repeated taps cannot count it twice | 2, 3, 5 |
| Picnic Share | Give each empty plate exactly one apple | 2–4 plates |
| Sleepy Sheep | Tuck sheep into bed and hear the shrinking awake group | 2–4, ending with none |
| Treasure Trail | Follow shuffled numbered stepping stones in counting order | 1–5 |
| Which Has More? | Compare aligned rows of equal-size oranges and choose the larger group | 1–5; no comparison symbols |
| Five-Frame Garden | Toggle flowers in five spaces, then check the requested quantity | 2, 3, 5 |
| Ticket Train | Match a dot ticket to a pictured group of passengers | 1–3 |
| Twin Towers | Add/remove unit blocks to match a model tower's height | Models 2–4; up to 5 blocks |
| Dot Detective | Inspect and optionally hide a dot clue, then identify its matching card | 1–3 |
| Frog Hops | Count a frog's actions, then confirm the requested number | 2–4; recovery after extra hops |
| Counting Drum | Request a spoken beat demonstration, echo it on the drum, then check the beat count | 1–3; no timing score |

Abstract addition, subtraction equations, number bonds, `>`/`<`, and ordering numbers to 20 are absent from the active toddler counting menu. The new activities use concrete small groups, objects, actions, and spatial comparison. Dot cards and visible reference models support children who are still learning numerals.

## Session, input, and accessibility behavior

- Every activity has three finite rounds, explicit Next/All done controls, and a replay reset. Round models reject advancing an unsolved or completed session.
- Success keeps the scene visible and waits for the child. There are no asynchronous delayed round changes in the active literacy games or ordinary counting games.
- Recovery gives a concrete hint. There are no lives, countdown pressure, negative sound effects, or punishments for mistakes.
- Buttons use the shared 64-point action minimum; local picture/letter/quantity targets are larger. Adaptive grids and the scrolling scaffold accommodate compact screens and larger text.
- Picture controls have spoken labels. Selected letters, counted ducks, planted spaces, and awake/asleep sheep expose state through labels and visible marks, beyond color alone.
- Letter Draw retains the existing glyph/path implementation but uses one large letter, a broad drawing surface, forgiving coverage, a clear button, and an air-drawing completion alternative. It is exploration, not handwriting assessment.
- Counting Drum starts playback only on an explicit request, so it does not interrupt the initial directions. Its task cancels on replacement/disappearance, stops when the app becomes inactive, and resets between rounds. The shared narrator handles app-level silence, session locks, VoiceOver, and voice preferences.
- Frog motion honors Reduce Motion. No activity requires dragging or a fast response.

## Verification and retained code

The final tracing audit corrected an invalid point-array read for `CGPathElementType.closeSubpath`: closed contours now sample back to their recorded start without reading nonexistent control points. Standalone CoreGraphics checks passed for closed paths, multiple subpaths, curves with coincident endpoints, invalid sampling steps, and the L/T/I font glyphs. Repeated taps on an opened alphabet window now repeat its spoken phrase, and a stationary finger tap leaves a visible drawing mark. Quantity groups and selected controls have explicit accessibility state.

Swift frontend parsing passed for the modified menus, new literacy games, and tracing file. Executable checks against the actual extracted `CountingPlay` and `LiteracyPlay` classes verified unsolved-advance guards, three-round completion, per-round state clearing, completed-session bounds, and replay. Source inventory checks found 12 unique activity IDs in each category and no missing literal image references in the active implementations. The shared integration build is owned by the main task.

The former `LetterMatch`, `SoundBaskets`, `BeginningSoundsGame`, `AlphabetSequenceGame`, `VowelGardenGame`, `ConsonantCoveGame`, `SyllableHopGame`, and SpriteKit scene source files remain for comparison and possible later reuse. The revised ABCs menu does not route to them, and they are not additional catalog activities. Their previous random rounds, timers, and screen-size assumptions are not part of the new activity implementations.

Simulator interaction tests, real-device audio listening, larger accessibility text checks, and observed toddler/caregiver play remain necessary before describing these activities as release ready. In particular, inspect every spoken prompt in context, test replay after a session lock/background transition, and tune tracing tolerance with real finger input.
