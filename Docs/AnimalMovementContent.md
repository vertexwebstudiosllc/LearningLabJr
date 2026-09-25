# Move Like an Animal

Sixteen shuffled animals replace the original fixed three turns. Every animal appears once before the session ends. Replay, leaving and reentering, and relaunching the app all exclude the last displayed animal from the next opening round. The last animal is saved locally under `nature.animalMovement.lastAnimal`.

The opening directions invite a grown-up to play. A visible reminder stays with every movement, and every prompt offers a movement that works while seated. Children advance at their own pace using Next animal; there is no timer or motion tracking.

| Animal | Movement |
| --- | --- |
| Rabbit | Gentle hand hops or hopping together |
| Cat | Slow arm stretches |
| Dog | Hand tail wags |
| Horse | Alternating knee pats |
| Chicken | Bent-elbow wing flaps |
| Duck | Gentle side-to-side rocking |
| Goat | Fingers climbing the other arm |
| Sheep | Tiny steps or fingers walking across a lap |
| Pig | Nose wiggles and a little sniff |
| Turkey | Fingers spreading like tail feathers |
| Dolphin | A hand making ocean waves |
| Crab | Fingers walking sideways or little side steps together |
| Octopus | Finger wiggles and slow arm waves |
| Seal | Gentle hand sweeps with elbows close |
| Jellyfish | Hands opening and closing |
| Stingray | Soft arm glides |

Artwork reuses transparent cutouts from FamilyClean, BarnClean, OceanClean, and dolphinClean. Native tests check transparent corners and both transparent and opaque pixel coverage for all sixteen images.

The seventeen exact narration scripts are in `Narration/Source/narration-source-animal-movement.json`, using the existing Ruth/Polly workflow. The shared narrator provides replay, mute, playback interruption, and the standard completion recording. Narration coverage tests require a bundled Ruth clip for every script.

Validation covers 200 shuffled sessions, sixteen distinct animals, invalid/stale completion taps, no immediate repeats, transparent artwork, and an end-to-end UI playthrough including replay, reentry, and app relaunch.
