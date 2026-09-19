# Shapes & Colors and Big Feelings implementation

Each category exposes exactly 12 stable `LearningActivity` records and 12 dedicated SwiftUI destinations. The former copied phonics menus and coming-soon destinations have been removed from these two categories.

The intended experience is ages 2–4 with caregiver support. Pattern Train, Mirror Wings, Little Road Trip, and Friendship Bridge are marked 3–4. The activities are short opportunities for shared play, not assessments, diagnostic tools, or claims of proven developmental benefit.

## Shapes & Colors

| Game | Distinct interaction | Natural finish |
| --- | --- | --- |
| Shape Post | Drag a shape stamp into one of three outline openings | Ten distinct shapes in shuffled order |
| Color Laundry | Sort shirts into three accumulating color baskets | Six shirts |
| Little Color Lab | Select two primary paints, mix, and discover combinations | Orange, green, and purple discovered |
| Pattern Train | Extend AB and AAB repeating shape patterns | Three trains |
| Build a Shape Town | Assemble spatially positioned shape pieces into pictures | House, rocket, and tree |
| Nesting Shapes | Order and layer large, medium, and small shapes | Three nests |
| Shape Trails | Follow sequential broad touch points by dragging or tapping | Circle, square, and triangle traced |
| Mosaic Garden | Select a palette and freely paint individual petals | Six painted petals and explicit finish |
| Mirror Wings | Paint a wing spot and reveal its reflected partner | Three spot pairs and explicit finish |
| Shape Safari | Find geometric forms in everyday object illustrations | Two objects per shape, three shapes |
| Rainbow Windows | Open colored windows to reveal and hear color–object associations | Six windows |
| Little Road Trip | Navigate a connected grid route using position words | Car reaches home |

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
| My Cozy Toolbox | Explore hand press, listening, and comfortable stretching | Three tools explored or modeled |
| Body Clue Buddies | Explore body sensations in any order with a grown-up | Four body areas noticed |
| Friendship Bridge | Role-play asking, waiting or choosing, and shared planning | Three bridge conversations |
| Cozy Evening Path | Sequence Teddy's pictured evening routine | Four routine steps |
| See You Soon | Select goodbye and comfort choices, then reveal a pretend reunion | One complete pretend goodbye story |

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
