# Make a Sentence

Children build a sentence by choosing a character, action, and object, then add it as a page in an ongoing story. They can change the last word before adding, keep adding sentences without a fixed round limit, hear any individual page, or replay the entire chain in order. Playback preserves an unfinished draft. A new visit starts a new story; leaving stops narration.

All 27 sentence combinations and three instructions reuse existing, complete Ruth recordings. Whole-story playback queues those recordings through the shared narrator, highlights the current sentence, and follows actual audio completion. Stop, leaving the screen, parental voice settings, and backgrounding retain the shared narrator's cancellation behavior. No AWS generation or additional narration expense is required for this change.

Animal and object images use existing clean Picture Hunt artwork. The ball and action icons use native vector symbols, avoiding the opaque legacy assets. Sentence rows have large targets and readable labels; playback scrolling respects Reduce Motion.

Validation: 101 native tests passed, including a 60-sentence chain, draft editing, stale/duplicate input guards, all 27 Ruth clip URLs, and artwork rendering. A narrated simulator walkthrough built three sentences, stopped and replayed the full chain, retained a partially built sentence, added a fourth sentence, and confirmed a fresh story on reentry.
