# BCM-M07-R03 — Independent ChatGPT Audit V02

Status: **CHANGES_REQUIRED**

This V02 supersedes the previous conclusion that the wrong visual asset family had been integrated.

## Corrected visual conclusion

The owner supplied a direct screenshot from the running Godot DEBUG build on 2026-09-17 and explicitly confirmed that the intended refreshed visuals are being used. Therefore asset identity is no longer a blocker for M07-R03.

The current screen is materially closer to the intended Beach Cocktails composition than the old prototype presentation. The refreshed BEST SCORE, SCORE, To-Go Orders, NEXT and 2x6 progression artwork are visibly active.

## Owner-annotated runtime findings

The owner marked the following placement defects directly on the running game screenshot. These annotations are now authoritative remediation requirements.

### F-M07-R03-001 — BEST SCORE numeric fit
The live Best Score number must be fully contained inside the dark recessed numeric window. Font size must be recalculated dynamically so any valid score string fits with safe horizontal and vertical padding. The numeric value must not touch or cross the gold/dark frame.

### F-M07-R03-002 — SCORE numeric fit
The live Score number must use the same fit-to-window logic. It must remain completely inside the designated dark rectangular value area for all expected score lengths.

### F-M07-R03-003 — To-Go dynamic content must fit the baked board
The target cocktail, live `Lx + name` text and reward must all remain inside the baked cream To-Go board. The target cocktail must be resized/positioned from its actual alpha-visible bounds. Text must not collide with the target image, title artwork, frame or bottom decoration. The reward must not fall outside the board.

### F-M07-R03-004 — NEXT must use a true safe content rectangle
Each possible cocktail L01-L12 must be fitted independently into the cream NEXT content window using its actual alpha-visible bounds. Relative visual scale intent between cocktail levels should be preserved as much as possible, but absolute priority is that no garnish, straw, fruit, leaves or glass pixels cross the cream content window into the wooden frame/title/border.

### F-M07-R03-005 — Held cocktail requires body-bottom anchoring
For the held launch drink, the visible glass/container base must sit on the owner-indicated launch baseline/halo position. Do not align different cocktails solely by texture-center or full-image alpha bbox, because garnish height varies by level. Use a per-level visible-body bottom anchor or equivalent body-foot measurement so all held cocktails visually rest on the same launch baseline while collider/physics center remains unchanged.

### F-M07-R03-006 — Preserve accepted 2x6 progression presentation
The current 2x6 progression visual is owner-accepted in this screenshot. Preserve the baked strip and current top-row L07-L12 / bottom-row L01-L06 mapping. Do not redesign it or reintroduce runtime cell frames unless later owner feedback asks for it.

### F-M07-R03-007 — Preserve current M06 table/background composition
The owner did not reject the refreshed background/table geometry in this screenshot. M07 remediation must not move the playfield, danger line, launch Y or table geometry merely to solve HUD content-fit problems.

## Verdict

M07-R03 remains **CHANGES_REQUIRED**, but for focused dynamic-content placement and launch-anchor defects only. The refreshed asset family itself is accepted and must be preserved.
