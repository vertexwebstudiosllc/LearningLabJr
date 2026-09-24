# Restored Peekaboo Barnyard

The Nature Explorers route now embeds the original SpriteKit barn, background and sliding door images inside the shared game screen, using the same presentation approach as Vehicle Peekaboo. The original three-tap loop is preserved: open the doors, introduce the visitor, then close the doors and prepare another surprise. An accessible action button provides the same interaction. Busy animation states ignore extra taps, door positions use absolute coordinates to avoid drift, and Reduce Motion skips sliding animation. Backgrounding, leaving the screen and session locking stop narration and pause the scene.

Nineteen discoveries include the original nine farm animals, cats and dogs, six baby animals, a farmer and a tractor. Every discovery has a Ruth introduction and a separate pretend-play suggestion. The shuffled deck is saved when a closed barn reserves its next visitor, including on entry; leaving before opening also advances the saved deck. All nineteen are reserved once per cycle, with no immediate repeat at a cycle boundary. The game continues into another shuffled cycle rather than ending after four animals.

The barn retains its original proportions. Only the long lower path is cropped to make the embedded scene more useful on a phone. The old direct speech synthesizer and mixed voice-file playback are removed from this scene; all spoken content uses the app's shared Ruth narrator and respects the parent settings.

## Artwork and prompts

Original scenery: `Assets.xcassets/Barnyard/{barnBackground,barnDoorLeft,barnDoorRight}.imageset/`. Twelve transparent animal assets are reused from `Assets.xcassets/FamilyClean/`. Seven new sprites live in `Assets.xcassets/BarnClean/{pig,duck,goat,rabbit,turkey,tractor,farmer}.imageset/`, each with a same-named PNG.

Tool: built-in `image_gen`. The original local images were viewed before editing. Each asset used its own tool call; final alpha is preserved when copying PNGs into the project. Shared source animal and vehicle illustrations remain unchanged.

Extraction prompt, individually for pig, duck, goat, rabbit, turkey and tractor:

> Use case: background-extraction. Edit target: this {name} sprite for a toddler barn game. Remove ALL dark blurred background and glow. Output actual fully transparent alpha, including gaps around legs/wheels and tail. Keep original animal or vehicle, face, colors and friendly illustration style. Fit the complete subject fully inside the canvas with a small margin, restore clipped tips if needed. No shadow, outline, sticker border, scenery, text, white flecks or glow. Crisp clean cutout for placement on a dark barn interior.

Farmer generation prompt:

> Use case: illustration-story. Asset type: transparent toddler farm game sprite. A warm friendly adult woman farmer with brown skin, dark curly hair, straw hat, teal overalls, coral shirt and brown boots, smiling and waving. Full body, simple rounded storybook illustration with soft shading, matching a cheerful red barn and cute flat farm animals. Clear adult proportions, uncut centered subject with small margin. Actual fully transparent alpha background, clean gaps between limbs. No scenery, shadow, glow, text, border or checkerboard.

Cleanup prompt for goat, tractor and farmer:

> Use case: background-extraction. This {name} sprite still has unwanted background. Make it a TRUE transparent PNG cutout. Remove every bit of the dark/colored glow and backdrop, plus white flecks in the negative space. Alpha must be zero outside the subject, between legs or wheels, and beside arms. Keep subject and colors unchanged. Fit entire subject with a small clear margin. Absolutely no background color, glow, drop shadow, border or checkerboard. A clean isolated {name} only.

Final flat-sprite refinement for tractor and farmer:

> Use case: style-transfer. Recreate only this {name} as a clean FLAT storybook game sprite on a completely transparent background. Square canvas. Preserve its identity, colors, clothing/parts, friendly face and entire silhouette. Remove all lighting effects: absolutely NO colored glow, atmospheric halo, blur, gradients outside the subject, shadow, background or floor. Use solid flat colors with crisp edges. Leave 8% transparent margin around the entire subject. Outside the exact silhouette must be fully transparent alpha, not black or softly fading colors. This is a cutout object for compositing inside a barn.

## Narration

Exact runtime text is in `NatureExplorers/BarnyardContent.swift` and `Narration/Source/narration-source-barnyard.json`. Animal sounds are Ruth's spoken imitations. Introductions name animals and baby vocabulary, notice body features, or describe the farmer and tractor. Pretend-play suggestions are optional and can be repeated without advancing the scene.
