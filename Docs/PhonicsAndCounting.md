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
| Number Picnic | Count twelve kinds of fruit; select a numeral supported by dots in rows of five | 30 rounds: three shuffled passes through 1–10, with no repeats within a pass or across its boundary |
| Touch & Count | Tap twelve kinds of animals in any order; each shows its counting-order number and cannot count twice | 27 levels progressing from 2 to 10, with three groups per count |
| Picnic Share | Share one piece of fruit per friend, then two equally; filled plates stop accepting more | 20 levels, 2–6 friends |
| Sleepy Sheep | Tuck each animal in once and count the remaining flock down to zero | 18 levels, 2–10 animals |
| Treasure Trail | Choose the pile with more or less treasure; equal-size coins in rows of ten, numerals and Ruth quantity buttons | 46 shuffled comparisons covering every number 10–100; tens first, then nearby quantities |
| Which Has More? | Compare aligned groups of twelve rotating fruits; find more first, then fewer, with closer differences later | 20 comparisons, quantities 1–8 |
| Five-Frame Garden | Build requested groups and correct preplanted groups in one or two five-frames with eight flower designs | 20 levels, targets 1–10 |
| Ticket Train | Match exactly one ticket dot per passenger using twelve animal passengers and varied dot layouts | 24 levels, 2–9 passengers |
| Twin Towers | Build from empty, then shorten an oversized tower to match a model; eight matching picture themes | 18 levels, targets 2–10 |
| Dot Detective | Inspect a dot pattern, optionally hide/peek, then find its matching card; eight illustrated card themes | 18 levels, 1–6 dots in three layouts |
| Frog Hops | Count actions as a frog moves toward eight illustrated pond scenes; check, reset and retry freely | 24 trips, 2–9 hops |
| Counting Drum | Request spoken beats, then echo their count on eight illustrated drums; replay remains available without a timing score | 18 levels, 1–6 beats |

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

### Counting picture variety

Number Picnic uses shuffled 1–10 counting passes; the other eleven games retain their difficulty progression. Number Picnic, Picnic Share and Which Has More? draw from twelve fruits: apple, orange, strawberry, pear, peach, plum, lemon, lime, mango, pineapple, blueberry and raspberry. Touch & Count, Sleepy Sheep and Ticket Train use twelve animal friends: duck, sheep, rabbit, cat, dog, cow, horse, goat, pig, chick, turtle and penguin. Sleepy Sheep keeps its menu name while welcoming other sleepy animals.

Collections are shuffled at session creation and exhausted before repeating, with no repeats within any three consecutive rounds. Eight visual themes vary trail treasures, tower decorations, dot-card illustrations, drum faces and pond scenery. The garden uses eight colored petal designs. Every round keeps a stable picture/style across its countable items; comparisons use equal-size pictures, tower blocks retain equal dimensions, and card decorations are identical across choices. Replay creates a fresh picture order. Ruth names the selected foods and animals where applicable.
