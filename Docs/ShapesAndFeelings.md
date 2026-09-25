# Shapes & Colors and Big Feelings implementation

Each category exposes exactly 12 stable `LearningActivity` records and 12 dedicated SwiftUI destinations. The former copied phonics menus and coming-soon destinations have been removed from these two categories.

The intended experience is ages 2–4 with caregiver support. Pattern Train, Little Road Trip, and Friendship Bridge are marked 3–4. The activities are short opportunities for shared play, not assessments, diagnostic tools, or claims of proven developmental benefit.

## Shapes & Colors

| Game | Distinct interaction | Natural finish |
| --- | --- | --- |
| Shape Post | Drag a shape stamp into one of three outline openings | Ten distinct shapes in shuffled order |
| Color Laundry | Drag eleven shirt colors into three matching-choice baskets per round | Continuous shuffled cycles, with a Next shirt pause |
| Little Color Lab | Explore primary mixtures, then lighten and darken eight paint colors | Nine levels, three discoveries per level |
| Pattern Train | Extend 5–15-shape trains through five increasingly complex repeating groups | Sixty distinct patterns per session |
| Build a Shape Town | Select tray shapes and drag into dimmed outlines in any order | Twenty pictures, each with three to five shapes |
| Nesting Shapes | Follow three color requests to build nested layers across ten shapes | Continuous shuffled shape cycles |
| Shape Trails | Follow a broad moving guide by dragging or tapping | Twenty-five complete shape outlines |
| Mosaic Garden | Choose eight paints to fill and recolor twelve pictures, beginning with the original flower | Paint all parts, then choose the next picture; no repeats before all twelve |
| Shape Bubble Pop | Pop three matching bubbles among six; progress from colors to shapes to both attributes | Thirty shuffled challenges, gentle floating/pop animation, no timer, completion and replay |
| Shape Safari | Find two illustrated examples of each of ten shapes across three shuffled passes | Thirty levels with a different matching pair for every appearance of a shape |
| Rainbow Windows | Open colored windows to reveal and hear color–object associations | Six windows |
| Little Road Trip | Follow twenty-four connected routes, progressing from 3×3 to 6×6 grids and longer paths | Reach home on each route, choose the next trip, complete all twenty-four and replay |

Colors are accompanied by words and characteristic symbols where possible. Shape outlines and the trace path keep their geometry at different screen sizes. Paint discovery uses a set, so repeating one mixture cannot prematurely complete the game. Art can be repainted until the child chooses to finish.

## Big Feelings

| Game | Distinct interaction | Natural finish |
| --- | --- | --- |
| Funny Face Studio | Adjust eyes, eyebrows, and mouth; give the puppet a feeling word | Three puppets |
| Flower Breaths | Open and settle a flower with comfortable, self-paced breaths | Three optional modeled cycles |
| Teddy's Helping Hands | Choose and act out care in three short stories | Three Teddy stories |
| Roll It Together | Alternate child and caregiver ball passes | Three back-and-forth rolls |
| Wiggle, Slow, Stop | Follow seated or standing movement cards together | Six movement cues |
| My Feeling Weather | Choose a feeling, its size, and a support | One check-in |
| Kindness Garden | Choose, act out, and plant flowers for caring actions | Three different caring actions |
| My Solution Toolbox | Open a picture toolbox and choose one or two helpful items for everyday problems | Eighteen shuffled problems, with a solved scene after each |
| Body Clue Buddies | Identify body parts by tapping a diverse picture buddy | Eighteen clues with a new buddy each time |
| Friendship Bridge | Choose friendly words, then share six kinds of interactive play with a buddy | Twelve shuffled playdates connect a bridge |
| Cozy Evening Path | Choose and act out steps in eight everyday routines | Four to six steps per chosen path |
| See You Soon | Drag a diverse buddy to a goodbye spot, choose fitting words, then play the ending | Eight selectable stories: bedtime, school, daycare, dinner, park, visiting, poo, and pee; school reunions and bathroom flushing/handwashing |

Feeling choices are never graded. `Not sure` is offered for the check-in, and emotion names are not inferred from a face or bodily sensation. Touch and hugs are offered with consent. Watching a grown-up or pretending is accepted. Breathing has no breath holds, countdown, microphone monitoring, or requirement to become calm. The goodbye activity explicitly keeps the real caregiver present. Check-ins live only in view state and are not logged or persisted.

## Shared interaction and verification

- Shared `ToddlerGameScaffold` provides spoken and repeatable prompts, completion, replay, and a caregiver cue. Each destination applies `.learningActivity(activity)`.
- Game response narration uses the shared speech channel. There are no game timers, losing states, streaks, advertisements, or linked external destinations in these implementations.
- Every primary game button has a target of at least 64 points. Direct tracing has a 68-point button alternative to dragging. Painting spots are 66 points and petals 74 points. Adaptive grids and scrollable shared scaffolds support narrow screens and larger text.
- Flower and ball movement obey Reduce Motion. Low-impact shape transitions are immediate. All 24 games reset through a fresh view identity on replay.
- Both folders pass Swift syntax parsing with the installed Xcode toolchain. Full app type checking, simulator runtime, and route audits are performed by the integrating agent; syntax parsing alone does not establish those outcomes.

Before release, conduct caregiver-and-child usability sessions across the stated age range, VoiceOver and large-text checks on physical devices, and qualified early-childhood content review. The implemented completion loops and accessibility affordances are engineering groundwork, not a substitute for those reviews.

## Follow-up interaction audit

A category-level review corrected ambiguous road navigation by highlighting and naming the next square, exposed face-puppet features and their control values to VoiceOver, and made third-paint selection replace the oldest selection instead of silently doing nothing. Shape Trails now uses the same exact path for its guide and progress; the square has equal sides, the circle stays round, and tracing gestures take priority within the tracing board. Completion prompts describe the finished activity instead of requesting another action. Completion counters, set-based discoveries, and replay identities were reviewed for overflow and reset behavior; syntax parsing passed after these corrections. Physical-device gesture and assistive-technology validation remains part of release testing.

### My Solution Toolbox

Eighteen unique everyday problems run once each in a shuffled session. The first problem changes on re-entry, and four picture choices shuffle for each problem. Children open a sheet, hear the problem or individual item names, and select one or two helpful tools in either order. Closing the sheet preserves their selections. Unsuitable tools invite another try; selected tools cannot count twice. Solving closes the toolbox and reveals the outcome before the child advances. Real repairs explicitly involve a grown-up. All prompts, feedback, outcomes, and item labels have bundled generative Ruth recordings.

### Body Clue Buddies

Eighteen distinct clues teach nine body parts, with two clues per part and no consecutive repeated part. Eighteen named buddies include nine boys and nine girls, six skin tones represented across both genders, and varied hair and clothing. Each buddy appears once per session. Questions and people shuffle independently; re-entry changes the first buddy and clue. Both sides of paired body parts accept taps. Tap targets remain at least 44 points with no overlaps from 280–390 point layouts. Two unsuccessful taps offer an outline hint; a hint is also available on demand. Correct answers highlight the part and explain the clue before moving on. All clue, answer, retry, hint, and introduction lines use bundled generative Ruth narration.

### Friendship Bridge

Choose one of eight diverse illustrated buddies, then explore twelve shuffled playdates. Each starts with two valid friendly-word choices and a narrated response. Activities include waving or smiling, sharing building blocks, passing a ball or toy car, matching silly faces or pretend animals, alternating bubble or star turns, and dragging toys or hearts into a shared space. Dragging has a tap-to-pick-up and tap-to-place alternative. Turn checks, single-use bubble checks, and per-action drag tokens prevent accidental double counting or stale drops. Each completed activity adds one bridge piece. Greeting choices change the greeting picture; giving a friend space keeps that friend watching. Replay returns to buddy selection, with a different first playdate. Prompts, choices, replies, activity instructions, retries, and outcomes use bundled generative Ruth recordings.

### Cozy Evening Path: everyday routines

Eight selectable paths cover bedtime, bathroom time, rain, snow, the beach, mornings, picnics, and coming home. The paths contain 35 total steps built from 28 reusable activities. Each step asks for a picture choice, then a small action: dressing or packing with drag-and-drop (plus a tap alternative), washing in order, tapping sparkles, turning story pages, following footprints, or helping with a pretend action. Clothing persists across completed dressing steps. Incorrect choices invite a retry without losing progress; choices shuffle and avoid duplicate symbols. Completed path badges last for the play session. Children can pause and switch paths without receiving completion credit for unfinished routines. Bathroom play uses a clothed cartoon-style teddy, gentle pretend wording, and grown-up help. Family routines can differ. All spoken titles, clues, instructions, feedback, and outcomes have bundled generative Ruth narration.
