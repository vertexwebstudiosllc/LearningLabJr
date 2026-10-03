# Landscape layouts

The home screen places the logo, children and Parents Corner to the left of a three-column, two-row category grid. All six categories fit the safe viewport. Category menus use a left introduction and a separate scrolling activity grid.

Games share a bounded landscape layout: title, directions, narration and Play Together are on the left; the complete play area is on the right. Completion and replay controls also stay in the left pane. Play Together opens the caregiver tip without pushing the game below the screen. Portrait and large accessibility text retain vertical scrolling.

`gameViewportSize` gives child views the available landscape play area. Letter Twins, Shape Post, Number Picnic, Picture Hunt, Habitat Helpers and Funny Face Studio arrange their controls specifically for that space. `GameFittedContent` uniformly fits other boards while retaining their content identity. `gameContentScale` lets global-coordinate drags convert screen displacement to the fitted board. Drop targets should be measured in the same coordinate space as the gesture.

Make a Sentence shows one browsable history sentence in landscape; its complete history remains available in a separate sheet, so a growing story never shrinks the current game indefinitely.

`LandscapeLayoutUITests` checks complete home and game control bounds after rotation settles, including accessory rounds, retry hints and group completion. `LandscapeInteractionUITests` checks scaled dragging and sentence-history navigation. The Shape Post landscape smoke test verifies all ten drags, completion and replay.
