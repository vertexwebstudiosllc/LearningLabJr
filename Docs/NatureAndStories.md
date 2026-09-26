# Nature Explorers and Story & Language implementation

The two category menus each expose exactly 12 stable activity IDs. Each destination has its own game state and objective. Shared scaffolding supplies narration, replay, a stopping point, and a caregiver prompt; it does not turn every activity into the same quiz. The broader research rationale and release validation requirements are in [ResearchAndReview.md](ResearchAndReview.md).

The default audience is ages 2–4 with a caregiver. Nature Detective, three-step story sequencing, sentence construction, and the longer books are labeled 3–4 with a grown-up. These are design recommendations, not assessments of development. Children can point, imitate, move, or have an adult supply language. Activities never require recorded speech, a microphone, a reading score, or a fast response.

## Nature Explorers

| Stable ID | Activity | Distinct interaction | A complete play session |
| --- | --- | --- | --- |
| `nature.habitats` | Habitat Helpers | Send the featured animal to an illustrated home | Place four animals in the farm or ocean |
| `nature.tracks` | Dinosaur Trail | Follow a connected footprint path | Visit six footprints to reveal a Triceratops and a fact |
| `nature.moon` | Moon Mission | Act out successive parts of a pretend space trip | Put on a spacesuit, launch, land, explore, return |
| `nature.families` | Animal Families | Select an adult, then connect its baby in another column | Connect cow/calf, horse/foal, and sheep/lamb |
| `nature.barn` | Peekaboo Barnyard | Open barn doors and imitate a narrated animal sound | Meet and say goodbye to four animals |
| `nature.garden` | Little Garden | Apply plant care actions and observe a changing pot | Plant, cover, water, provide light, and pretend days pass |
| `nature.cleanup` | Ocean Helpers | Remove unwanted objects while leaving living things | Collect three pieces of litter from the ocean |
| `nature.weather` | Weather Window | Change the weather, then explore the window | Explore sunshine, rain, and wind; finish voluntarily |
| `nature.movement` | Move Like an Animal | Move away from the screen with an adult | Hop, waddle, and swim with arms; seated alternatives included |
| `nature.dayNight` | Day & Night | Switch sky states and discover different details | Explore two daytime and two nighttime details |
| `nature.clues` | Nature Detective | Request an additional clue and identify an animal | Solve three animal descriptions |
| `nature.nest` | A Cozy Nest | Gather materials, weave, and settle eggs | Gather three twigs, weave them, and settle three pretend eggs |

The old Nature menu reused generic counting, size, pattern, and sorting tasks that belonged elsewhere. It also represented a pony as a baby horse. The replacement keeps the category about observation and the natural world; the family activity uses **foal**. Science copy makes clear that plants take days to grow, the Moon can be visible during the day, the Sun is a star, and real nests should be left undisturbed. The space and nest games identify their actions as pretend play.

The legacy `PeekabooBarnyard.swift` SpriteKit source remains in the repository to preserve prior work. The category routes to the new accessible SwiftUI barn activity instead, so the old repeating door animation and unbounded scene loop are not part of the 12-game offering.

## Story & Language

| Stable ID | Activity | Distinct interaction | A complete play session |
| --- | --- | --- | --- |
| `stories.library` | Read Together | Listen and turn illustrated pages | Any of four 15-page books; replay/done on the last page |
| `stories.pictureHunt` | Picture Hunt | Locate named objects in a picnic arrangement | Find Bunny, the apple, and the cup |
| `stories.storyOrder` | First, Next, Last | Create a pretend story with three branching picture choices per step | Six adventures, 54 possible paths, eight diverse characters, and a narrated three-page storybook |
| `stories.puppets` | Puppet Friends | Give two puppet characters alternating speaking turns | Six turns including greeting, shared play, and goodbye |
| `stories.finishSentence` | Finish My Sentence | Complete a spoken sentence with a meaningful picture | Finish three everyday sentences |
| `stories.soundStory` | A Noisy Little Story | Tap sound events in narrated scenes and imitate them | Explore two events on each of three story pages |
| `stories.storyBag` | The Story Bag | Reveal props and invent an open-ended story | Reveal a character and two surprises; tell a story together |
| `stories.sillyScene` | Silly Story Fixer | Remove a nonsensical prop and choose a useful replacement | Repair three silly situations |
| `stories.bunny` | Where Is Bunny? | Move Bunny among actual landing positions around a box | Place Bunny in, on, and beside the box |
| `stories.conversation` | Picnic Chat | Choose a conversational response and hear a contingent reply | Four conversation turns; all responses are valid |
| `stories.storyChoices` | Choose Our Adventure | Branch the story by choosing its place, friend, and event | Hear the resulting beginning, middle, and ending |
| `stories.sentenceBuilder` | Make a Sentence | Assemble a character, verb phrase, and object phrase | Hear and act out the sentence; words can be revised |

The old Story menu contained 21 entries, mostly copied phonics routes and locked “Coming Soon” screens. These have been replaced by actual story/language activities. The four existing illustrated books count as **one reading activity**, not four allegedly different game mechanics. All 60 original pages and their story text remain available. The book reader now provides page narration, readable scrolling text, page progress, 64-point controls, replay, and an explicit done action. It does not force automatic page changes.

## Interaction and implementation review

- All new activities have finite completion conditions and reset their local state on replay. Progression is clamped or guarded against rapid repeated taps at the end of a round.
- Mistakes give spoken guidance without losing a life, points, or time. Open-ended choices are accepted without evaluation. No activity promises a measured learning outcome.
- Sequencing options shuffle between rounds and on replay. Baby-pair positions shuffle on replay. Other visual answer positions vary across their authored rounds; spatial destinations retain stable positions so that their position has meaning.
- Picture/action targets are at least 64 points. Grids adapt to the available width; content scrolls rather than reducing text to tiny sizes. Picture cards use fixed dark text against their light backgrounds so labels remain readable in dark system appearance.
- Prompts are narrated by the shared game scaffold. Local response narration uses the same speech channel, and views stop their narrator when leaving. The shared system honors voice preferences, VoiceOver, backgrounding, and session breaks.
- Weather and sky discoveries appear as text as well as speech. Buttons have meaningful accessibility labels; decorative pictures do not add duplicate VoiceOver announcements.
- The only optional puppet movement respects Reduce Motion. All progress is driven by a child or caregiver action rather than a stress timer or unattended loop.
- Existing images are reused. Weather, action, and position visuals use native SwiftUI shapes and SF Symbols; no downloaded or generated asset licenses are introduced.

## Validation performed

- Swift frontend parsing succeeded for all Nature and Story source files after the implementation and semantic review.
- Verified 12 enum cases and 12 destination routes in each category, with matching metadata IDs.
- Audited asset namespaces: only the Space group enables `provides-namespace`. Active menus, the Moon Mission, Day & Night, and Story Bag explicitly use `Space/` image keys; labels and narration keep their natural display names. Asset-catalog files are unchanged.
- Verified the four book collections each retain pages 1–15 and that all 60 page-image asset folders exist with their referenced image files.
- Reviewed all finite state transitions, replay resets, clue behavior, open-ended branches, picture/word consistency, and compact-width layouts in source.
- Full app build and simulator smoke testing are coordinated in the root implementation task. Frontend parsing and asset checks alone do not establish release readiness; real family usability and accessibility checks remain part of the release bar described in the research review.
