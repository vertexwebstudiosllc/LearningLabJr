# Syllable and shape game refresh

Syllable Hop renders all 30 words through the explicit clean literacy artwork resolver. Existing clean cutouts, native illustrations, and transparent platform illustrations replace opaque legacy sprites. Word selection, syllable parts, and Ruth recordings remain unchanged.

Shape Post uses one native path implementation for each of its ten stamps and matching openings. Dark filled silhouettes stay visible without depending on SF Symbol availability. Existing generous drop zones and VoiceOver posting actions remain available.

Little Color Lab shows the first selected paint on the left and the second on the right, with names and contrasting text. An unselected half remains white and says “Choose a color,” distinguishing it from selected White paint. Deselection and replacement update the preview immediately. Stirring fills the preview with the resulting color.

Rainbow Windows has twelve rounds: two free exploration rounds followed by ten color-and-shape listening rounds, one for each shape. Each round has six shuffled windows and six hidden objects. Consecutive rounds have disjoint surprise sets. Revealed windows stay bright and can be tapped to hear the object again. Later rounds request each color once in a shuffled order; incorrect choices leave progress unchanged and repeat the clue. All twelve rounds must be completed before the finish screen, and replay creates a fresh session.

Rainbow Windows sequences existing Ruth object recordings with the next clue. Its shared scaffold opts out of automatic prompt playback to prevent it interrupting the sequence; the standard hear-directions button still works. Other games retain automatic narration by default. No new audio generation is required.

Validation: 107 existing native regression tests passed. Four new focused tests passed after correcting the case-sensitive Ruth object-name lookup. These cover all 30 syllable illustrations, clean asset resolution, recorded narration, paint selection changes, silhouette geometry, and 20 complete randomized Rainbow Windows sessions. The simulator walkthrough completed all ten Shape Post drags, selected and mixed paints, completed all twelve Rainbow Windows rounds with wrong-choice checks, and verified replay. Rendered artwork and game screenshots were visually reviewed.
