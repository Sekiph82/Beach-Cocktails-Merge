# BCM-M07-R05 — Post-Full-Tabletop HUD Adaptation Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

## Prerequisite
BCM-M07-R04 must already be completed, committed and pushed before this work starts. This session must preserve every accepted owner rule implemented by M07-R04 and must not redo or overwrite that work.

## Scope
Adapt the HUD only as required after M06-R05 widens the playable tabletop, with the owner-directed goal of keeping the upper tabletop visually open.

## PASS requirements
1. M07-R04 is completed first and its final production behavior is preserved.
2. BEST SCORE and SCORE remain on the left, in logo -> BEST SCORE -> SCORE order.
3. BEST SCORE and SCORE are moved upward as much as practical so they do not visually occupy the upper tabletop accumulation area.
4. Neither panel is clipped off-screen or overlaps the logo, To-Go Orders, or another HUD element.
5. BEST SCORE and SCORE remain HUD-only and do not affect physics/playfield boundaries.
6. Fixed score-font rule from M07-R04 remains unchanged: one fixed production font size per panel, 7-digit safe through `9999999`, no digit-count auto-shrink.
7. To-Go runtime remains target cocktail + reward digits only; no Lx/name text and no leading `+`.
8. To-Go ropes remain visually attached to the viewport top.
9. NEXT L01-L12 containment behavior from M07-R04 remains intact.
10. Held-drink body-bottom anchoring from M07-R04 remains intact.
11. Current baked 2x6 progression artwork and mapping remain unchanged: top L07-L12, bottom L01-L06, no runtime cell frames.
12. Current canonical PNGs are not modified.
13. M06-R05 full-tabletop geometry is not reduced to make room for HUD.
14. Responsive validation covers 720x1280, 720x1440 and 800x1280.
15. Retained clean screenshots demonstrate the upper tabletop is visually open while all HUD remains fully visible.
16. M01-M07 regression, Godot import/startup and `git diff --check` pass.
17. TASKS.md, ChatGPT-owned files and historical logs remain untouched by Codex.
18. No M08+ work begins.

Any material failure blocks AUDITED_PASS.
