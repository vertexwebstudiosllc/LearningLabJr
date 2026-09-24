# Animal Families

Eighteen rounds introduce six families: cow/calf, horse/foal, sheep/lamb, chicken/chick, cat/kitten and dog/puppy. Rounds 1–6 match a grown-up to one of two babies; rounds 7–12 match a baby to one of three grown-ups; rounds 13–18 match Ruth's spoken animal-sound imitation to one of three illustrated families. Sound clues can be replayed and are also shown as text. These are spoken imitations, not wildlife recordings.

Each stage uses every family once in shuffled order, with independently shuffled distractors and answer positions. Stage boundaries avoid the previous animal; replay and reentry avoid the previous opening animal. A wrong answer offers a specific hint without advancing or penalizing the child. A correct answer shows both animals together and reinforces the baby name; the child chooses when to continue.

## Artwork

All twelve project sprites are in `Assets.xcassets/FamilyClean/{cow,calf,horse,foal,sheep,lamb,chicken,chick,cat,kitten,dog,puppy}.imageset/`, with a same-named PNG. Existing shared originals remain unchanged. The cat and dog originals serve as kitten and puppy artwork; newly generated adult companions have longer bodies and more mature proportions.

Tool: built-in `image_gen`, using one call per asset. Original local images were visually inspected first. Final PNG alpha is preserved when copied into the asset catalog.

Background extraction prompt, separately for cow, horse, sheep, chicken, calf, foal, lamb, chick, cat and dog:

> Use case: background-extraction. Edit target: provided {name} illustration for toddler Animal Families game. Remove the entire baked-in checkerboard or dark blurred glow background and sticker border. Replace with real transparent alpha including between legs, around tail, all gaps. Preserve animal silhouette, complete face, colors, pose and illustration style. No backdrop, no glow, no shadow, no border, no text. Center entire animal uncut with small transparent margin. Output transparent PNG.

Adult companion prompt, separately for cat and dog:

> Use case: illustration-story. Asset type: toddler Animal Families adult {name} sprite. Use provided {name} baby illustration as a style and family-color reference, not an edit target. Create a distinctly GROWN-UP {name}, with mature longer body and legs, smaller head relative to body, calmer friendly face. Match {cat: gray tabby and white fur, green eyes; dog: orange-brown and white fur, floppy ears, brown eyes}. Entire animal in standing three-quarter pose, clearly an adult compared with reference baby. Same warm polished children's illustration. Real fully transparent alpha background, including gaps between legs. No glow, no shadow, no border, no text, no scenery. Centered uncut with small transparent margin.

Adult cutout refinement prompt:

> Use case: background-extraction. Edit only the background of this adult {name} cutout. Remove ALL remaining white and black mottled backdrop between and around legs, under belly and outside fur, along with colored edge fringe. All negative space must be smooth clean FULLY TRANSPARENT alpha, with no opaque flecks or checkerboard. Keep complete animal, face, pose, fur and colors unchanged. No shadow, outline or glow. Transparent PNG with pristine cutout edges.

## Narration

`Narration/Source/narration-source-animal-families.json` contains exact runtime prompts, hints, discoveries and the completion text. They use the existing bundled Amazon Polly Ruth voice and playful delivery. No account or connection is needed during gameplay.
