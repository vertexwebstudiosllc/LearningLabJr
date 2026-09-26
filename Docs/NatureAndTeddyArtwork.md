# Dinosaur, teddy, and toolbox artwork fixes

Dinosaur Trail now uses six transparent PNG cutouts in `Assets.xcassets/DinosaurClean/`: Triceratops, Stegosaurus, Brontosaurus, T-Rex, Velociraptor, and Spinosaurus. Each is stored in its corresponding `.imageset` with a matching PNG filename. Original artwork remains in `Assets.xcassets/Prehistoric/`.

The built-in image generation tool edited each original separately. Two requests were retried after a network error. The final prompt set was the following template, substituting each dinosaur name:

> Use case: background-extraction. Edit target: supplied {name} toddler dinosaur sprite. Remove ONLY the baked-in white and gray checkerboard background, replacing it with real transparent alpha, including gaps between limbs and body. Preserve original dinosaur silhouette, entire body, face, eyes, pose, horns or plates, texture, colors and friendly 3D illustration style. No added objects, no text, no backdrop or shadow. Keep whole dinosaur centered with a small transparent margin. Return a transparent PNG cutout for an iOS game.

Teddy's girl bow is now centered at the same horizontal coordinate as the head. It renders above hats so dressing Teddy does not hide it.

My Solution Toolbox uses a native toolbox illustration, with a handle and two latches, in both its menu tile and its open-toolbox button. The menu icon inherits the same pink accent and dimensions as neighboring games. This replaces reliance on the unavailable `toolbox.fill` system image.

Validation: 115 native tests passed, including transparency checks for all six dinosaur PNGs and progress/narration coverage for all twelve space discoveries. A simulator walkthrough passed for Dinosaur Trail, four different Moon Mission stories (including wrong choices, previous-page retention, completion, and fresh mission state), the girl teddy, and the toolbox menu and game. All twelve teaching diagrams, the six dinosaur cutouts, and the bow and toolbox artwork were visually reviewed.
