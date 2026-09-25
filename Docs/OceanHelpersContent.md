# Ocean Helpers cleanup adventure

Each new adventure offers six unique animals chosen from thirteen. The previous six are saved locally, including when leaving before selecting a character. Replay and reopening exclude that entire previous group. The selected buddy remains with the child for ten rounds. Puzzle animal groups also avoid the previous round's animals, and the selected buddy remains outside the cleanup board.

Rounds 1–3 distinguish trash from animals on six-picture boards, increasing from two to four pieces of trash. Rounds 4–6 use nine-picture boards: first collect the pictured trash type, then remove the remaining trash. Consecutive sorting rounds use different targets. Rounds 7–9 match visible pairs of identical trash, increasing from two pairs to three. Round 10 finishes with five mixed pieces of trash. All pieces and board positions are shuffled for each adventure. Wrong selections give gentle guidance; animals never disappear. No countdowns, penalties or reading requirements are needed to solve the puzzles.

The buddy choices, board composition and positions are randomized; the learning progression remains deliberate rather than making later games arbitrarily harder. All ten named places are visited once per adventure. The final screen celebrates the selected buddy and reports the number of collected pieces. Replay offers another six animals.

## Narration

Runtime content is in `NatureExplorers/OceanCleanupContent.swift`. The 47 exact spoken lines are in `Narration/Source/narration-source-ocean-cleanup.json`, recorded using the app's existing Amazon Polly generative Ruth setup. The shared narrator handles spoken directions, hints, character introductions and completion messages, with replay and parent voice settings. Caregiver text asks children to let adults handle real litter and leave wildlife undisturbed.

## Artwork

The existing transparent `dolphinClean` is reused. Twelve sibling cutouts are saved at `Assets.xcassets/OceanClean/{shark,octopus,seahorse,whale,jellyfish,crab,lobster,squid,stingray,starfish,seal,swordfish}.imageset/`, each with a same-named PNG. Original shared animal images remain unchanged. Cleanup objects use consistent colored system-symbol illustrations; the selected sorting target uses the exact same artwork as its matching pieces.

Tool mode: built-in `image_gen`, one edit per animal after viewing each original. Exact prompt template, with `{animal}` replaced by each of the twelve names above:

> Use case: background-extraction. Edit target: the supplied {animal} illustration for a toddler ocean game. Remove the entire baked checkerboard background and any white sticker border. Preserve the recognizable friendly animal, face, pose and colors. Fit the entire subject on a square canvas with an 8% clear margin. Output true transparent alpha everywhere outside the animal, including gaps between fins, legs and tentacles. Clean crisp edges. No background, glow, shadow, checkerboard, text or extra objects.
