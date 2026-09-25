# Day & Night routines

The original four-picture exploration is replaced with eighteen unique activities: nine daytime and nine evening/bedtime activities. Each session includes every activity once. Six item-finding rounds lead into six sorting rounds and six three-step routines. Activity order and answer positions are shuffled within each stage. A fresh session avoids both the previous opening activity and the most recently displayed activity, including after leaving or relaunching the app.

| Stage | Daytime | Nighttime |
| --- | --- | --- |
| Find a useful item | Open curtains, choose breakfast fruit, find walking shoes | Find a toothbrush, wash a sleepy face, choose a bedtime book |
| Put three things in place | Pack for the park, set the lunch table, gather art supplies | Put toys away, choose pajamas, make a pretend bed cozy |
| Follow three steps | Wash hands, care for a plant, go outside with a grown-up | An evening wash, a quiet wind-down, say goodnight |

Sorting accepts dragging just the object artwork into the destination. An equivalent tap-an-item, then tap-the-destination action supports children who prefer tapping and accessibility users. Incorrect choices keep the child in the same round and repeat its direction gently. Completed items cannot count twice, and stale drag payloads cannot affect a different round. Next activity appears only after the current activity is complete.

Daytime and nighttime have contrasting room/window illustrations and visible labels. The instructions teach routines in context rather than claiming that reading, tidying, or washing can only happen at one time. Brushing is explicitly described as a morning and bedtime routine with grown-up help. Families are invited to talk about their own routines.

The 79 exact introduction, instruction, retry, and success lines are in `Narration/Source/narration-source-day-night.json` for the shared Ruth/Polly narrator. Completion uses the existing shared recording. Recorded narration coverage remains a required final check after generation.

Native validation checks 200 full sessions, no repeated activities, stage progression, wrong choices, sequence order, duplicate/stale input, asset availability, and Ruth lookup. The UI test completes all eighteen activities, exercises all six drag destinations and the tap alternative, rejects incorrect/out-of-order choices, and checks replay and reentry.
