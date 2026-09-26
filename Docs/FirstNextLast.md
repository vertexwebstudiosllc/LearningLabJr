# First, Next, Last

A branching imagination game replaces the fixed routine-ordering exercise. An illustrated child is the story’s main character. Three first-action choices are sampled from six pretend adventures: space, an island, a castle, a magical garden, a toy band, and snow. The selected first action determines the next three choices. That second selection determines the final three choices. Every offered option is valid; there are no wrong-answer messages.

The story graph has six starts, eighteen middle actions, and twenty-four endings. Each middle action offers three endings, making 54 complete paths. Some endings can follow several middle actions. All narration refers to “our friend,” so each story works with all eight diverse character illustrations.

The scene changes with each chosen action. Once the child chooses an ending, all three sentences appear as picture-page buttons. Read our story opens the first page. Next page and Back let the child hear Ruth tell the story in order at their own pace. A specific page can also be opened directly. The child can make another story or finish whenever a story is complete.

Characters rotate without repetition within a deck; changing characters is available before the first action. The last selected first action is left out of the next story’s initial options. Reentry clears unfinished story selections, avoids that first action, and starts with a different character. Only recent character and opening IDs are stored locally.

The illustrations use existing clean cutouts and SwiftUI drawing, including custom castle, dragon, treasure chest, and seed props. Ruth narration adds 50 bundled generative clips, reusing recorded question lines and character introductions. There is no live speech-generation request during gameplay.

Validation traverses all 54 paths, verifies three valid choices at every step and coherent theme branches, rejects stale selections, checks storybook bounds and session resets, verifies Ruth coverage, and renders scenes and props. Simulator coverage builds four stories, previews each action, reads pages in both directions, changes characters, finishes, replays, and reenters.
