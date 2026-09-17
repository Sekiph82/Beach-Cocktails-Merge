# BCM-M06-R08 — Owner Runtime Rear-Table Physics Audit Criteria V03

Status: **LOCKED BEFORE IMPLEMENTATION — SUPERSEDES V02**

Authority: owner clarification dated 2026-09-17. The rear-stop rule is now mathematically prescribed.

## Non-negotiable mathematical contract
There is ONE common visible rear tabletop boundary for every cocktail level L01-L12.

Godot screen-space Y increases downward. Therefore for a horizontal rear boundary at `rear_table_y`, the cocktail center target MUST be computed from the current cocktail body half-extent in Y:

```text
body_half_extent_y = current visible/physical glass-container body height / 2
rear_target_center_y = rear_table_y + body_half_extent_y
```

Equivalent invariant:

```text
visible_body_top_y = rear_target_center_y - body_half_extent_y
visible_body_top_y == rear_table_y
```

If the current physical body is accurately represented by a circular CollisionShape2D radius, then:

```text
body_half_extent_y = collider_radius
rear_target_center_y = rear_table_y + collider_radius
```

If the collider radius does NOT accurately represent the visible glass/container body's vertical half-extent, Codex must use or derive an evidence-backed body half-extent instead of forcing the wrong radius. Garnish/straw/fruit/flowers must not be included in this body extent.

## Explicit interpretation
- Do NOT hardcode separate rear target Y positions for L01-L12.
- Do NOT assign different rear table boundaries per level.
- Use one common `rear_table_y` and derive each drink's center target from that drink's current body size.
- Larger drinks therefore have a center farther from the rear edge only because their `body_half_extent_y` is larger.
- Smaller drinks have a center closer to the rear edge only because their `body_half_extent_y` is smaller.
- In every case the body edge itself touches the SAME table edge.

## Required end state
1. For every L01-L12, when the cocktail reaches its rear stop, `visible_body_top_y` is tangent to the same `rear_table_y` within a small documented tolerance.
2. No artificial gap remains between the glass/container body and valid rear wood.
3. No glass/container body crosses beyond the common rear boundary.
4. The calculation updates automatically from the current body/collider size. If a drink size changes in future, the rear target must follow from the formula rather than a per-level target table.
5. Rear-left and rear-right behavior must preserve this same tangency rule while respecting the visible side/corner geometry.
6. A subtle center-seeking influence near extreme rear corners may be used only if needed for a rounded/organic corner feel. It must never change the common rear-edge equation above.
7. Any corner guidance must be weak, local and smooth, and must not overpower player momentum, cause snapping, oscillation, sticking or tunneling.
8. Visible glass/container body defines containment. Decorative garnish may overhang naturally.
9. Accepted gameplay contracts remain unchanged: 700 px/s launch, 180 px/s² deceleration, collision/momentum, merge, combo, score, To-Go economy, persistence, Game Over, restart and rapid launch.
10. Current danger and launch world positions remain unchanged unless a genuine dependency is proven and documented.
11. HUD does not define gameplay bounds.
12. Canonical PNGs are not modified.
13. Active M06 tests must directly validate the mathematical invariant for L01-L12, not merely compare production constants to copied expected constants.
14. Evidence must include at least: `rear_table_y`, per-level `body_half_extent_y`, computed `rear_target_center_y`, resulting `visible_body_top_y`, and tangency error for L01-L12.
15. Retained runtime evidence for 720x1280, 720x1440 and 800x1280 must visually demonstrate representative small/mid/large rear-center contacts and rear-left/rear-right behavior.
16. Full active M01-M07 regression, Godot import/startup and `git diff --check` pass.
17. `TASKS.md`, ChatGPT-owned files, historical logs and M08+ work are not modified by Codex.

Any material violation of the mathematical tangency contract or owner-visible mismatch blocks AUDITED_PASS.
