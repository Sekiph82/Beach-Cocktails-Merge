# BCM-M06-R06 — Rear-Table Full-Width Geometry Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

Authority: latest owner runtime screenshot/annotation dated 2026-09-17 showing the rear-left and rear-right visible tabletop are still not fully playable.

## PASS requirements
1. The actual visible tabletop interior, including the rear-left and rear-right regions, is playable.
2. Rear playfield boundaries are measured from the active owner-approved background/runtime render, not copied from the previous M06 production constants.
3. At least 5 independently measured Y samples per side are retained across rear/far, upper-mid, mid, lower-mid and near tabletop depths.
4. The geometry representation may be piecewise-linear/polyline/curve; it must not force a single straight interpolation if that materially cuts off visible wood.
5. The production left/right boundary at each sampled Y stays within a small documented tolerance of the independently measured visible inner tabletop edge.
6. L01/L06/L12 can reach both left and right rear regions until their physical glass/body footprint is tangent to the real visible edge.
7. No extra wall-thickness inset is double-counted.
8. HUD does not participate in physics boundaries.
9. Garnish/straw/fruit/leaf extents do not reduce the physical playfield.
10. The rear boundary/top-stop model does not leave an unexplained visible strip of playable wood that cocktails cannot occupy.
11. Cocktail glass/container body remains on the tabletop; decorative garnish may overhang naturally.
12. Perspective behavior is preserved across 720x1280, 720x1440 and 800x1280.
13. Danger Y and launch Y remain unchanged unless explicitly required by owner evidence.
14. 700 px/s launch, 180 px/s² deceleration, momentum, merge, scoring, To-Go, persistence and Game Over remain unchanged.
15. Retained evidence includes clean screenshots and overlays showing independently measured visible edges versus production boundaries at all sample depths.
16. Retained evidence includes rear-left/rear-right contact placements for L01/L06/L12, not merely numerical rail values.
17. Full M01-M07 regression, Godot import/startup and `git diff --check` pass.
18. No canonical PNG, TASKS.md, ChatGPT-owned file, historical log or M08+ work is modified.

Any material failure blocks AUDITED_PASS.