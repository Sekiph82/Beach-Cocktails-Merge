# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Execution Prompt V09

Status: **ISSUED — SUPERSEDES V08 TABLE-BOUNDARY MODEL**

Implement the locked solution in:

`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V09.md`

This round is specifically the new architecture:

**per-level directional visual contact hull + actual rail-segment normals + custom containment in `_integrate_forces()`.**

## Read first

- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_V06.md
- coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V09.md

## Mandatory implementation direction

1. Keep the existing CircleShape2D radii unchanged for drink-to-drink physics.
2. Stop using the drink circle as the table-boundary contact representation.
3. Ensure drink circles no longer physically collide with table StaticBody2D rails.
4. Author an explicit convex visual contact hull for every L01-L12 from the actual glass/container body, excluding garnish unless intentionally required.
5. Convert those source-space hulls into the current rendered body-local runtime geometry.
6. Represent each accepted left/right/rear rail segment with its true inward normal.
7. Implement one authoritative hull-vs-rail containment solver using half-plane penetration against segment normals.
8. Run that solver from `Drink._integrate_forces()`.
9. On penetration, project position inward only by the required visual penetration and remove only outward normal velocity; preserve tangential velocity.
10. Handle corners with a small iterative pass.
11. Replace merge-time scalar X clamp with the same hull projection solver after the new merged level exists.
12. Do not move V05 rails.
13. Do not use `TABLE_EDGE_CONTACT_HALF_WIDTHS`, collider radius, or physical-wall offset compensation as authoritative boundary clearance.
14. The rear rail remains geometrically at `rear_table_y`, but V09 intentionally stops forcing every drink CENTER to equal `rear_table_y`; rear contact is now hull-to-line contact.
15. Preserve all other frozen gameplay/HUD behavior.

## Evidence

Provide:
- per-level hull authoring evidence for L01-L12;
- diagnostic overlay/capture with hull, rails, normals and circle comparison for L01/L06/L12;
- focused automated tests from the locked criteria;
- normal 720x1280 GUI capture;
- full active regression.

Write:

`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V07.md`

Push implementation + log and return:
- log URL
- implementation SHA
- regression result
- `AWAITING_AUDIT`

Then STOP.
