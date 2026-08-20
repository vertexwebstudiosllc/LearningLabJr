# Learning Lab Jr: curriculum and code review

Reviewed September 14, 2026. Primary audience: children ages 2–4 playing with a caregiver. Optional early literacy challenges are labeled 4+. These are product design ranges, not developmental assessments.

## Product direction

Keep the six existing learning categories and make each contain twelve distinct activities, for 72 total. More categories would add navigation before addressing the main problem: several existing categories opened the same phonics activities or unfinished screens. Everyday routines, movement, creativity, and problem solving fit naturally into the existing six areas.

| Category | Count | Main purpose | Parent-facing value |
| --- | ---: | --- | --- |
| ABCs & Phonics | 12 | Listening, vocabulary, letters, optional early reading | Language-rich play that grows with the child |
| Shapes & Colors | 12 | Visual matching, spatial reasoning, patterns, making art | A mix of guided discovery and creativity |
| 123s & Counting | 12 | Concrete small quantities, one-to-one correspondence, sharing | Everyday early math without requiring arithmetic symbols |
| Nature Explorers | 12 | Animals, plants, weather, observation, caring for the world | Familiar interests connected to outdoor discovery |
| Story Time | 12 | Shared reading, sequencing, describing, pretending | Conversation and imagination; a parent can participate |
| Big Feelings | 12 | Naming feelings, expressing needs, turn taking, social routines | Useful practice for everyday family moments |

The in-app **Parents Corner → What each game helps us explore** contains the current activity inventory, interaction descriptions, age guidance, and a caregiver prompt for every game. Its entries come from the same metadata used by game destinations.

## Research and its implications

The AAP's guidance for ages 2–4 emphasizes understanding the individual child, selecting content carefully, communicating about media, and avoiding displacement of physical play, conversation, and books. It also cautions against making a device the default response to distress. That supports short activities, a visible stopping point, shared conversation, and optional feelings practice with a caregiver. It does **not** establish that this app improves developmental outcomes. [AAP: 5 C's questions for toddlers and preschoolers](https://www.healthychildren.org/English/family-life/Media/Pages/kids-and-screen-time-5-cs-questions-for-toddlers-and-preschoolers.aspx).

ZERO TO THREE describes early math through everyday number and spatial language. The design implication is to let children touch individual objects, compare visible quantities, share items, and talk about positions and size before asking them to manipulate equations. Counting activities therefore use small concrete sets; symbols such as greater-than and abstract number bonds are removed from the main toddler offering. [ZERO TO THREE: Let's Talk About Math](https://www.zerotothree.org/resource/lets-talk-about-math/).

Khan Academy Kids publicly positions its offering around literacy, math, social-emotional development, and creative play, with no advertising or subscription. This provides a useful competitive reference for breadth and family trust. It also means sheer activity count is unlikely to be a sufficient paid-app proposition. Learning Lab Jr needs understandable learning purposes and a pleasant shared experience. This is a product inference from its positioning, not evidence of download causation. [Khan Academy Kids](https://en.khanacademy.org/kids).

Sago Mini School presents curiosity-led learning across numeracy, literacy, creativity, and problem solving. Its examples include making stories, building, and drawing. This supports mixing interaction types instead of publishing many renamed multiple-choice quizzes. Its own site is evidence of its product positioning, not an independent effectiveness evaluation. [Sago Mini School](https://sagomini.com/school/).

## What could attract parents

The strongest positioning hypothesis is **“72 little discoveries to share together.”** Show actual gameplay and its purpose: one snack for each friend, a paint experiment, a child-created story, and a practice conversation about asking for help. Explain what is included before a purchase. Pair that with offline activities, optional music, no third-party ads, accessible controls, and grown-up access to settings and purchases.

This research does not demonstrate which category will produce the most downloads or willingness to pay. Validate that with family interviews and actual product-page experiments. Useful measures include whether parents understand the value, whether a child can begin with minimal adult instruction, whether they choose different activities voluntarily, and whether stopping is comfortable. Avoid optimizing children's time spent as the main success measure.

## Code findings addressed

- **Wrong destinations and incomplete products:** Shapes, Feelings, and much of Stories were copied phonics menus. Replace them with real category-specific routes and stable curriculum identifiers.
- **Age mismatch:** The counting menu prioritized arithmetic and comparison symbols. Replace that menu with concrete quantity activities. Separate older literacy challenges using visible age guidance.
- **Content correctness:** Existing phonics used mismatched pictures, and animal-family content confused a pony with a baby horse. Check names against actual artwork and correct the family vocabulary.
- **Fragmented interaction design:** Introduce shared cards, responsive menus, large action controls, repeatable spoken instructions, caregiver tips, and finish/replay choices while keeping game mechanics separate.
- **Audio lifecycle:** Centralize new-game narration, replace queued speech on rapid taps, respect VoiceOver and voice preferences, lower music during speech, stop audio when inactive, and honor the item-sound toggle.
- **Voice quality:** Prefer higher-quality installed English voices and offer a parent picker and sample with a gentle speech profile. See [Narration](Narration.md) for selection, offline behavior, and the limits of device speech.
- **Timer races:** The former canceled sleep could still tick or rotate music; the countdown also depended on receiving every timer event. Use cancellation checks and a monotonic deadline, close games on expiry, and provide a calm break screen.
- **Parent settings:** Protect entry to parent controls and use a fresh challenge for purchases and session unlock. Remove unused global difficulty and auto-advance controls rather than presenting settings that do nothing.
- **Store feedback:** Prevent concurrent purchase/restore requests and show recoverable error and pending states. Show the subscription period alongside localized pricing.

Existing illustration assets and the user's pre-existing Space asset-catalog changes are preserved. The original storybooks remain available in the Story Library. Unrouted legacy game implementations can be archived separately after comparing with the new activities; they are not counted as extra games.

Two widely used illustrations had baked checkerboard backgrounds. Separate transparent apple and dolphin cutouts now render through the shared artwork view, while the originals remain intact. [Artwork prompts and provenance](Artwork.md).

## Release quality bar

Automated checks should establish six categories, twelve unique IDs each, complete curriculum metadata, valid assets, compilable Swift, and safe timer boundaries. Simulator checks should exercise category navigation, representative actions, completion/replay, parent gating, and compact/large-screen layouts.

Before claiming professional release readiness, observe real toddlers and caregivers using all 72 activities, including VoiceOver and motor-access needs. Review spoken English and each artwork match, verify subscription behavior with StoreKit and TestFlight, assess the download size on real devices, and confirm App Store listing/privacy materials. A successful build is evidence of integration, not a substitute for these observations.
