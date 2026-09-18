# BCM-R11 — Table Edge / Glass Distance Fix

**Date:** 2026-09-19
**Godot:** 4.7.2
**Changed files:** `scripts/drink.gd`, `scripts/game_manager.gd`, `scripts/merge_queue.gd`, `scripts/shot_controller.gd`
**Unchanged:** table rail coordinates, background artwork, drink-to-drink physics, momentum behavior, `TASKS.md`

---

## 1. Reported problems

1. As the cocktail level increased, the gap between the glass and the table edge increased.
2. After a merge near the edge, the new larger glass visibly moved inward.
3. A **light** touch could move a settled glass toward the edge, while a **hard** hit pushed it inward — the same event produced two different results.

---

## 2. Root cause — two separate bugs

### Bug A: The boundary check used the wrong shape

The `GameManager.project_visual_hull_inside_table()` function tried to keep `BOUNDARY_CONTACT_HULL_SOURCE_PX`, meaning the **entire glass silhouette** (from rim to base), inside the table boundary.

The table edge lines are **sloped** because of perspective. The inward normal of the left rail is approximately `(0.909, 0.417)` — it points both right and down. Against this normal, the extreme point of the silhouette is the glass's **top edge**, not its base.

Result: when the rim touched the line, the base remained one glass-height farther inside. The gap was `glass height × rail slope`. Because the glass height increases with level, the gap also increased with level.

**Conceptual error:** the perspective table edge is a line drawn on the table **plane**. Only the part that touches the plane can be constrained by that line. The glass body, rim, straw and decoration are above the plane and must overhang the line — that is also how a real glass at a table edge looks.

### Bug B: Boundary enforcement depended on speed

Inside `Drink._integrate_forces()`:

```gdscript
if motion_state == MotionState.SETTLED:
    if state.linear_velocity.length() > 8.0:
        motion_state = MotionState.SLIDING
    else:
        return          # <-- the boundary check never ran
```

Every movement below 8 px/s skipped the boundary check entirely. Therefore:

- **Light contact** → speed below 8 → no boundary enforcement → the glass could move freely toward (or even beyond) the edge.
- **Hard contact** → speed above 8 → transitions to `SLIDING` → the silhouette projection activates → the glass is pushed back inward by Bug A's large-gap rule.

This is exactly the cause of symptom 3.

### Additional finding

The `StaticBody2D` rails built by `_build_walls()` use layer 2 / mask 2, while the glasses use layer 1 / mask 1. Therefore those rails do not collide with anything; they are diagnostic only. The only real boundary response was the projection function. That structure was correct and was not changed.

---

## 3. Measurements (720×1280 viewport, left rail `LeftRail_0`, pixels)

### Distance between the rear edge and the visible bottom of the glass

| Level | Original | Intermediate step (ellipse) | **Final** |
|---|---:|---:|---:|
| L1 | 38.3 | 14.3 | **12.0** |
| L3 | 66.3 | 26.7 | **12.0** |
| L5 | 95.8 | 39.2 | **12.0** |
| L7 | 136.3 | 56.4 | **12.0** |
| L9 | 138.6 | 53.9 | **12.0** |
| L11 | 198.0 | 79.2 | **12.0** |
| L12 | 187.6 | 72.2 | **12.0** |

### Distance between the side edge and the bottom corner of the glass

| Level | Original | **Final** |
|---|---:|---:|
| L1 | 18.6 | **0.00** |
| L5 | 54.4 | **0.00** |
| L8 | 117.4 | **0.00** |
| L12 | 96.3 | **0.00** |

The final values were verified for all 12 levels and all six rail segments.

---

## 4. Solution architecture

Three separate concepts are used instead of one shape:

| Shape | Role | Status |
|---|---|---|
| `CircleShape2D`, `COLLIDER_RADII[L]` | glass↔glass physics | **unchanged** |
| **Table footprint** — a zero-height horizontal line segment through the lowest point of the glass | the only shape used for table-boundary response | **new** |
| Full silhouette (straw, fruit, umbrella) | visual only | no longer constrains anything |

The footprint's **zero height** is critical. Any height would place the glass that far in front of a rail, and because the hull grows with level, that distance would grow with level too — bringing the original bug back. With zero height, the lowest visible pixel of every level sits exactly on the rail, and asymmetric drawings are handled correctly.

---

## 5. File-by-file changes

### `scripts/drink.gd`

**a) New function `get_table_footprint_local()` (around line ~285)**

Returns the part of the glass that touches the table: a two-point horizontal segment through the maximum Y value of the `BOUNDARY_CONTACT_HULL_SOURCE_PX` hull, spanning the hull's full X extent.

The X values are read from the hull rather than assuming symmetry — asymmetric drawings such as L1 (left −342, right +279) are aligned correctly.

**b) `_integrate_forces()` reorganized (around line ~497)**

Projection now runs **before** the 8 px/s check and runs in every case. `MERGING` / `TARGET_CAPTURE` / `HELD` states are skipped from the beginning; every other state receives boundary enforcement at every speed. This fixes Bug B's inconsistency.

**c) One projection added to `set_settled()` (around line ~429)**

Godot does not call `_integrate_forces()` for a sleeping body. If a glass is pushed out of bounds on the exact step when it settles, it would otherwise remain there. A projection immediately before sleeping closes that gap.

**d) Removed**

The intermediate `TABLE_FOOT_SQUASH` constant was unnecessary in the final solution and was removed.

### `scripts/game_manager.gd`

**a) New constant (line 55)**

```gdscript
const REAR_EDGE_MARGIN := 12.0
```

The side rails look correct at zero distance. The rear rail, however, is the far lip of the table: a glass whose lowest pixel sits exactly on it has its entire body drawn beyond the table and appears to be standing on the edge. This margin leaves visible wood behind the glass base.

It is a constant in pixels, not a function of collider radius, so it is identical at L1 and L12.

**b) New function `project_footprint_inside_table()`**

Replaces the old hull solver. Differences:

- Input is a two-point segment instead of a 12+ point hull.
- Four iterations instead of eight; with two points, one or two passes already converge.
- The `TABLE_SOLVER_EPSILON` margin was removed. The old solver added it **for every violated rail, on every iteration**, causing cumulative inward movement at rear corners. The new solver applies exact tangency.
- `REAR_EDGE_MARGIN` is applied only to the edge named `RearRail`.

**c) Preserved**

`project_visual_hull_inside_table()` and `get_boundary_contact_hull_local()` were not deleted; they are marked as retired. The M06/R08/R09/R10 overlay and probe files still call them.

### `scripts/merge_queue.gd`

The call inside `_do_merge()` now uses the new function. The new glass is therefore subject to the same footprint rule after a merge. Merge speed, momentum transfer and combo logic are unchanged.

### `scripts/shot_controller.gd`

The call inside `_move_current_to()` now uses the new function. Drag-preview positioning and post-shot settling use the same rule.

---

## 6. Verification

- All four files compile without errors using Godot headless `--check-only`.
- Tangency distances were calculated numerically for 12 levels × 6 rail segments: 0.00 px at side edges and a constant 12.00 px at the rear edge.
- In-game visual verification was performed by the owner (12 px approved).

---

## 7. Tuning point

One number:

```gdscript
# scripts/game_manager.gd, line 55
const REAR_EDGE_MARGIN := 12.0
```

Increasing it leaves more wood at the rear edge; decreasing it moves glasses closer to the edge. It is not level-dependent; changing it affects all 12 levels by the same amount.

If a similar margin is desired at the side edges, the same value can be applied outside the `RearRail` check.

---

## 8. Remaining work

### a) Two probe files will now fail — this is expected

- `tests/r10_v09_visual_hull_containment_probe.gd`
- `tests/r10_v10_visual_hull_containment_probe.gd`

These files verify that the **entire glass silhouette remains inside the table boundary**. **That rule was the source of the defect.** The replacement validation should be: the footprint segment is inside the envelope, and the edge distance is constant per level.

Under `AGENTS.md`, changing accepted milestone criteria is an independent audit decision; these files were not changed.

### b) `scripts/drink.gd` indentation change

When the file was opened in the Godot editor, the editor converted all indentation from four spaces to **tabs** (Godot's own standard). This has no functional effect, but `git diff` shows the entire file as changed. To see the real change:

```
git diff -w -- scripts/
```

Ignoring whitespace, the real change is 136 additions and 15 deletions across the four files.

`scripts/game_manager.gd` still uses four spaces. If desired, the two files can be brought to one standard.
