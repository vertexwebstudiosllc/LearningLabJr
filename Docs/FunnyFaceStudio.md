# Funny Face Studio

Children match six example puppet faces by changing their own puppet's eyebrows, eyes, and mouth. The example stays on the left with “Match this / EXAMPLE”; the child's face stays on the right with “Your face / TAP TO CHANGE”. The same character and colors appear on both sides so children can compare the actual features.

Tapping a feature on the face cycles its style. Large labeled buttons below the two faces offer the same interaction, with VoiceOver names, current styles, and descriptions of the example. Each matched part earns a star and a checkmark. Children can keep experimenting until all active parts match; success locks the face and reveals an explicit next button. No camera, photo upload, or assessment of the child's own expression is involved.

The first two faces use three facial features. Rounds three and four introduce round and star glasses; rounds five and six also add party and top hats. Every active feature starts different from the example. Each expression appears once in a shuffled session, and replay/reentry avoids the previous first and last expressions. Inactive accessories, stale taps, repeated callbacks, and early/duplicate advancement are rejected.

The native vector renderer keeps every style distinct and fits two faces across phone and tablet game areas. Face hit regions have a large-control alternative; the shared game scaffold handles landscape directions and scrolling. Animations honor Reduce Motion and a completed match provides system success feedback.

Four new matching narration lines are included in the source catalog. They currently use the shared installed-voice fallback; recorded completion narration remains bundled. The explicit fallback flag only exempts these new lines from Debug's recording assertion and preserves the normal mute, VoiceOver, session lock, voice preference, and speech ownership behavior. A later Polly generation can add recordings without changing the game.

Native validation covers 200 full sessions, independent feature changes, progressive accessories, invalid/stale/duplicate actions, replay exclusions, distinct drawings for every feature style, and bundled completion narration. UI validation matches all six faces through the same feature controls families use and checks accessory progression, completion, replay, and reentry. The caregiver tip encourages looking at one part at a time while reminding families to ask how a real person feels.
