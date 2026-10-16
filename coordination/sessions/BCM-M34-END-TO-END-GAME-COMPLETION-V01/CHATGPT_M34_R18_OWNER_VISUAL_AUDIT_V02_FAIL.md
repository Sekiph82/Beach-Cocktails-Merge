# BCM-M34-R18 Owner Visual Audit V02 | FAIL

**Owner supplied authentic Windows screenshot 2026-10-16 07:45, 1536x960 desktop window with central narrow portrait viewport. R18 native GUI acceptance FAIL.** Do not label this GUI PASS.

Screenshot: world map covers entire portrait viewport; debug Studio title, island/level inputs, seed and status labels overlap the World Map masthead and island graphics. Controls such as START/RESET SEED, PAUSE, RESUME, STEP 1 PHYSICS, BUDGET UNKNOWN, EXPORT JSON are packed in a clipped horizontal strip around the top of the portrait viewport. Most right-end actions appear clipped/off-viewport. Neither dedicated legible tool panel nor actual playable test board is visible. Unused black window margins are present outside viewport, suggesting a desktop-friendly standalone UI could use wider window with a viewport adjacent to tools.

Source root cause candidates to validate: R18 `_build_ui()` adds `_dock` before `_navigation` is instantiated and `add_child(_navigation)` is called; a later full-rect sibling can paint over controls in scene-tree order. The single narrow-width HBox has island 190 + level92 + seed110 + two preset buttons, while action HBox contains seven buttons; none have a scroll/wrap/reflow layout. Fixed dock anchors 0.015..0.985, top 0.015..0.405, and status label at x130 y88 are not responsive and collide. Confirm visually in GUI, do not assume only ordering explains all overlap.

Owner evidence supersedes R18 headless PASS for visual acceptance. Gameplay, mouse interaction, switching levels, debug capture and terminal indicators remain UNVERIFIED. M33-004 OPEN.

Correct next task R18-FIX: desktop-specific layout with dedicated side panel or properly anchored accessible collapsible controls, readable all controls even 720x1280 portrait; move high-priority debug UI above map via correct CanvasLayer/z-order and input routing, ensure gameplay board unobstructed; no screenshot-only fake solution, no gameplay/economy changes; run true GUI and screenshot evidence before requesting owner retest. Protect 8 modified tracked and 15 untracked Desktop files and Git policies.
