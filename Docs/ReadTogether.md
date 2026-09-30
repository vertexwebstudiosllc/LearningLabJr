# Read Together reader

The reader keeps the complete page illustration and story text in one viewport. Phones show the picture above the words; wider windows show a picture-and-text spread. Images use aspect-fit sizing, so no part of the original artwork is cropped. Page text wraps naturally to the available width; the original words and narration recordings are unchanged.

The heading and page controls become shorter in landscape. The normal reading type is 19 points, with 17-point text in compact spaces, and both scale with the reader’s Dynamic Type setting. At larger accessibility sizes, only the text panel scrolls; the picture and page buttons remain visible.

Swipe left on the illustration or words for the next page, or right for the previous page. Vertical and very short drags do not turn pages. Swiping past the first or last page stays in the book. The arrow buttons, final-page Read again and All done controls, and read-aloud button remain available. Each page change stops the previous narration before the new page is read.

`Validation/ReadTogetherTests.swift.txt` checks all sixty pages for complete artwork, unchanged words and audio, and text fitting at five phone/tablet content sizes. It attaches renders of each book’s longest page in phone portrait, phone landscape and tablet landscape. It also checks swipe interpretation, page boundaries and illustration space with accessibility type.

`Validation/ReadTogetherUITests.swift.txt` exercises all fifteen pages of the free Owen Onion book in portrait and landscape, swipes over both illustration and words, first/last page boundaries, buttons and replay. The fixture records screenshots of the last page in both orientations. Device testing should additionally check VoiceOver page actions, very large text scrolling, narration interruption during rapid page turns, and iPad window resizing.
