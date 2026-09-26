# Moon Mission story library

Twelve six-page stories offer two choices at a time. The six categories are Moon, Earth, Mars, Jupiter, Saturn and Sun. Each shuffled cycle offers every category once; the first pair of a new cycle excludes the preceding pair. The deck is saved when choices appear, so leaving without picking also advances the rotation. Each category alternates between its two story variants when offered again.

Children can advance through the illustration or the named action button, revisit a page, hear the current narration again, change missions or finish. All journeys are explicitly pretend. Planets' smiling faces are illustration conventions, not scientific diagrams; relative sizes and distances are not to scale.

## Science references

The original story text uses these NASA facts, checked September 24, 2026:

- [Moon facts](https://science.nasa.gov/moon/facts/): craters from impacts, weaker surface gravity, orbit around Earth and reflected sunlight.
- [Earth facts](https://science.nasa.gov/earth/facts/): oceans, land, atmosphere, rotation and day/night.
- [Mars facts](https://science.nasa.gov/mars/facts/): reddish rusty minerals, rocky terrain, robotic exploration, Phobos and Deimos.
- [Jupiter facts](https://science.nasa.gov/jupiter/jupiter-facts/): largest planet, cloud bands, Great Red Spot and no solid surface like Earth's.
- [Saturn facts](https://science.nasa.gov/saturn/facts/): second-largest planet, rings composed of ice and rock, no solid surface like Earth's.
- [Sun facts](https://science.nasa.gov/sun/facts/): our nearest star, source of light and warmth, planets orbiting the Sun. Stories use pictures and explicitly avoid looking directly at the real Sun.

## Transparent artwork and editing prompts

The seven PNGs in `Assets.xcassets/SpaceClean/{Moon,Rocket,Earth,Mars,Jupiter,Saturn,Sun}.imageset/` were edited using the built-in `image_gen` tool. Original illustrations remain in `Assets.xcassets/Space/`. These are real alpha-channel cutouts; the source checkerboard was part of the image itself.

Moon prompt:

> Use case: background-extraction. Asset type: toddler educational app sprite. Edit target: the provided friendly smiling Moon image. Remove only the baked-in white/light-gray checkerboard backdrop, replacing it with actual fully transparent alpha. Preserve the complete Moon shape, face, craters, colors and soft 3D illustration style. No added shadow or backdrop, no border, no text. Keep entire Moon uncut, centered with a small transparent margin. Save the transparent PNG for use in the app.

Prompt used separately for Rocket, Earth, Mars, Jupiter, Saturn and Sun (substituting the asset name):

> Use case: background-extraction. Asset type: toddler educational app sprite. Edit target: provided {name} illustration. Remove only the baked-in white/light-gray checkerboard backdrop, replacing it with actual fully transparent alpha, including any holes between Saturn's rings and planet. Preserve the complete subject, face, colors, silhouette, and soft 3D illustration style. No backdrop, no drop shadow, no border, no added text. Entire subject uncut and centered with a small transparent margin. Output transparent PNG for app use.

Ruth reads all 72 pages and the choice prompt using the existing Polly story delivery. The authored text lives in `NatureExplorers/SpaceStoryContent.swift`; exact narration entries are in `Narration/Source/narration-source-space-stories.json`.

## Interactive discovery update

Every story now adds a three-step hands-on discovery on page four, followed by a two-picture understanding check on page five. These twelve activities cover impact craters, reflected sunlight, oceans/land/clouds, day and night, rover observations, Mars's two moons, Jupiter's cloud bands, the Great Red Spot, ring materials, a science postcard, sunlight reaching Earth, and plant needs. A simplified diagram changes as each discovery is made. The next-page button stays locked until that activity is complete; a wrong choice gives another chance. Previous-page navigation retains discoveries and a new mission resets them. The final page includes a short takeaway.

Ruth's existing story recordings remain the spoken explanations, including the repeat-directions control and explanation after a discovery or answer. New concise activity instructions, labels, and questions are visible text and accessible to VoiceOver. There is no new system-voice fallback or paid narration generation. Teaching diagrams are schematic and not to scale; the day/night diagram follows a marked place into Earth's shaded side, and the ring close-up represents separate ice and rock pieces.

The existing NASA science references above were checked again for this update. New activities ask children to apply those facts rather than simply advance the story.
