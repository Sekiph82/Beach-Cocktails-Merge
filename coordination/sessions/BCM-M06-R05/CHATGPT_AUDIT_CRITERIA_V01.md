# BCM-M06-R05 — Full Tabletop Horizontal Playfield Audit Criteria V01

Status: **LOCKED BEFORE REMEDIATION**

Authority: owner screenshot and explicit owner instruction on 2026-09-17: **the whole visible tabletop should be usable gameplay area**. Drinks must not be artificially confined to a narrow center corridor. BEST SCORE/SCORE may be moved higher for visual clearance, but HUD placement must not define physics boundaries.

## Scope
Refine horizontal playfield/wall/clamp geometry only. Preserve the current owner-approved background, danger Y, launch Y, gameplay physics/economy, and canonical PNGs.

## PASS requirements

1. The visible tabletop interior across its full left-right perspective extent is the gameplay area.
2. Physical horizontal limits are derived from the actual visible tabletop boundaries, not from HUD rectangles.
3. BEST SCORE/SCORE do not participate in collision or board-boundary calculations.
4. A drink may approach each tabletop side until its **physical glass/body collider** reaches the playable edge.
5. No additional inward loss equal to wall thickness may be double-counted by both wall placement and clamp math.
6. If StaticBody2D rail thickness is retained, place/offset the wall so its inward collision face corresponds to the intended playable tabletop edge rather than consuming an extra strip of playable wood.
7. `get_horizontal_bounds_at_y()` or equivalent center bounds use the physical body radius plus only a tiny numerical safety epsilon. They must not add an unnecessary extra half-wall-width inset on top of an already bounded collision face.
8. Garnish/straw/fruit/leaf/flower visual extents do not reduce gameplay width. The physical footprint remains based on the glass/container body collider.
9. L01, a representative middle level (at least L06), and L12 can all reach both left and right sides at representative near/mid/far tabletop depths until their body collider is tangent to the playable edge within documented tolerance.
10. No cocktail body crosses off the visible tabletop. Visual garnish may naturally overhang slightly if the body remains physically valid.
11. The table remains perspective-aware; do not convert it to a rectangular invisible box.
12. Far, middle and near left/right playable bounds are independently measured from the current background/render and retained as evidence.
13. The current accepted danger Y and launch Y remain unchanged.
14. Launch position remains valid and full horizontal launch steering uses the widened lower tabletop bounds.
15. Existing 700 px/s launch, 180 px/s² deceleration, collision momentum, merge, L12 cap, scoring, To-Go, persistence and Game Over behavior remain unchanged.
16. No guide line is introduced.
17. Retained evidence includes a clean canonical screenshot plus an overlay showing visible tabletop edges, collision-wall inward faces, and reachable left/right body contact positions.
18. Retained evidence includes left-edge/right-edge contact cases for L01/L06/L12 at multiple depths.
19. Responsive validation covers 720x1280, 720x1440 and 800x1280.
20. M01-M07 regression, Godot import/startup and `git diff --check` pass on the final candidate.
21. TASKS.md and ChatGPT-owned files are not edited by Codex.
22. No M08+ work is started.

Any material failure blocks AUDITED_PASS.
