# Letter Draw, Sound Baskets, and Picnic Words polish

Letter Draw uses 26 consistent centerline uppercase forms instead of font outlines with independently positioned arrows. Each stroke has a short visual instruction, orange numbered starting dot and direction arrow, dotted active path, and green completed path. Completion checks the current stroke with generous tolerance; a tap or tiny scribble cannot complete it. The alphabet shuffle, clear button, air-drawing alternative, and existing Ruth prompts remain in place.

Sound Baskets starts an in-place picture drag immediately without a long press. Only the picture moves. The page is prevented from scrolling during the drag, and both basket targets accept a small margin beyond their visible edges. Basket taps still play Ruth's letter line, and accessibility placement actions remain available. Wrong drops reset the picture for another try.

Sound Baskets uses the existing clean animal/space cutouts and transparent native drawings for the remaining objects. Picnic Words uses transparent native food drawings and the existing clean apple and carrot artwork. Quilt fabric and the X-ray panel remain intentional parts of those objects. No source artwork or shared art resolver was modified.

Validation: 104 native tests passed, including every letter path and completion check, forgiving basket geometry, and clean-asset resolution. All 26 letter forms and both complete object galleries were visually reviewed. The final simulator walkthrough passed four quick correct/incorrect drag rounds while asserting that the page position stayed fixed, a three-food picnic, and Letter Draw instructions, clear, and air-drawing progression.
