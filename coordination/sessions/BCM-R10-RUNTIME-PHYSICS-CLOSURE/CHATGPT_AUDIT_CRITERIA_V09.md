# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit Criteria V09

Status: **LOCKED BEFORE IMPLEMENTATION — SUPERSEDES V08 FOR TABLE-BOUNDARY CONTACT**

## Purpose

V08 proved that a single per-level scalar edge half-width is not sufficient for irregular cocktails against piecewise/sloped rails.

V09 replaces scalar table-edge contact with a directional visual-contact hull and a custom containment solver.

The accepted table geometry stays fixed.

## Root model

Keep two responsibilities separate:

1. `CircleShape2D` remains the authoritative drink-to-drink gameplay collider.
2. A per-level visual contact hull becomes the authoritative drink-to-table boundary representation.

The table boundary is enforced mathematically in `_integrate_forces()`, along the actual inward normal of each rail segment.

## Frozen requirements

Do not change:
- owner-approved V05 left/right/rear rail coordinates;
- canonical cocktail PNGs;
- drink-to-drink `COLLIDER_RADII`;
- merge scoring/economy/To-Go;
- 700 px/s launch speed;
- 180 px/s² deceleration;
- no-backward-toward-player rule;
- HUD/layout accepted behavior;
- held drink alignment;
- NEXT/progression;
- persistence/Game Over/restart;
- `lock_rotation = true`;
- CAST_SHAPE CCD for drink-to-drink physics.

## Important supersession

The geometric rear boundary remains exactly `rear_table_y`.

However, V09 supersedes the old interpretation that every drink center must stop at `rear_table_y`.

The rail itself stays at `rear_table_y`, but each drink center is positioned so that its visual contact hull touches that rail according to the rear rail normal.

No rail movement is allowed.

## Collision filtering architecture

The drink's existing circle must no longer physically collide with table StaticBody2D walls.

Use body-level collision filtering correctly:

- drinks: collision layer 1, mask 1;
- table physical wall bodies: move to a non-drink layer such as layer 2 and ensure drinks do not mask it;
- drink circles continue to collide with other drinks only;
- table walls may remain in scene for diagnostics/reference, but they are not authoritative collision response for cocktails.

Do NOT add a second solid `CollisionShape2D` to the same `RigidBody2D` and claim it has an independent mask. Collision filtering is body-level.

## Per-level visual contact hulls

Create explicit per-level contact hull data for L01-L12.

Preferred representation:

```gdscript
const BOUNDARY_CONTACT_HULL_SOURCE_PX := [
    PackedVector2Array([...]), # L01
    ...
    PackedVector2Array([...]), # L12
]
```

Requirements:
- 6-12 convex points per level is sufficient;
- points represent the visible glass/container body only;
- exclude garnish unless that garnish should intentionally define table contact;
- points are measured from the actual canonical PNGs;
- points are stored relative to the texture center or another clearly documented source-space reference;
- retain evidence for all 12 levels showing how each hull was authored;
- hull must include asymmetry/offset of the visible glass body;
- do not derive hull geometry from `COLLIDER_RADII`;
- do not reduce the hull to a single width or radius.

The rendered visual transform may be applied when converting source-space hull points into runtime body-local coordinates. That is expected because the hull must match what is actually drawn.

## Runtime hull transform

Provide a method on Drink equivalent to:

```gdscript
func get_boundary_contact_hull_local() -> PackedVector2Array:
    # Convert source-space contact-hull points into current body-local
    # runtime positions using the same sprite offset/scale and visual-root
    # presentation transform that the player actually sees.
```

The exact implementation may account for:
- `_cocktail_sprite.position`;
- `_cocktail_sprite.scale`;
- `_visual_root.scale`;
- no rotation because `lock_rotation = true`.

This method must return points in RigidBody2D-local runtime coordinates.

## Rail-segment representation

Expose the accepted playable boundary as finite segment data in viewport/world coordinates.

At minimum:
- every left polyline segment;
- every right polyline segment;
- the rear segment connecting the top left and top right accepted rail points.

Each segment must provide:
- endpoint `a`;
- endpoint `b`;
- inward unit normal.

Orient normals using a known point inside the playable table rather than assuming winding.

Conceptually:

```gdscript
var tangent := (b - a).normalized()
var normal := Vector2(-tangent.y, tangent.x)
if normal.dot(table_interior_point - a) < 0.0:
    normal = -normal
```

## Authoritative containment solver

Create one authoritative function in GameManager, conceptually:

```gdscript
func project_visual_hull_inside_table(
    body_transform: Transform2D,
    local_hull: PackedVector2Array,
    velocity: Vector2
) -> Dictionary:
```

It must:
1. evaluate the visual hull against the accepted rail segments;
2. use segment inward normals, not global X half-widths;
3. correct only actual visual penetration;
4. preserve tangential motion;
5. remove only velocity pointing outward through a constraining rail;
6. support corners by iterating multiple passes, e.g. 3 passes;
7. return corrected transform and velocity;
8. never use `COLLIDER_RADII` as boundary clearance;
9. never use `TABLE_EDGE_CONTACT_HALF_WIDTHS` as boundary clearance.

Core logic should be equivalent to:

```gdscript
for iteration in range(3):
    var corrected := false

    for edge in boundary_edges:
        var min_distance := INF

        for local_point in local_hull:
            var world_point := body_transform * local_point
            var d := edge.inward_normal.dot(world_point - edge.a)
            min_distance = minf(min_distance, d)

        if min_distance < 0.0:
            var penetration := -min_distance
            body_transform.origin += edge.inward_normal * (penetration + TABLE_SOLVER_EPSILON)

            var normal_velocity := velocity.dot(edge.inward_normal)
            if normal_velocity < 0.0:
                velocity -= edge.inward_normal * normal_velocity

            corrected = true

    if not corrected:
        break
```

Small implementation refinements are allowed, but the geometry model above is mandatory.

## Drink integration

In `Drink._integrate_forces(state)`:
- keep existing wake/settle/deceleration logic;
- replace scalar table-boundary clamp behavior with the visual-hull containment solver;
- obtain the current local contact hull;
- pass `state.transform` and current velocity to the solver;
- write the corrected transform and velocity back to the physics state;
- continue preserving the no-backward gameplay rule after boundary correction;
- do not globally zero velocity on side contact.

## Merge-time correction

Preserve the successful concept of immediate post-merge containment, but replace V05/V08 scalar X clamping.

After the merged drink exists and its level/hull are known:
- call the SAME visual-hull projection function used by runtime physics;
- project the new drink inside the accepted table polygon;
- preserve merge Y except where the visual hull genuinely violates a boundary;
- preserve inherited momentum except for the outward normal component that would leave the table.

One source of truth only.

## Retire scalar boundary model

V09 must stop using the following as authoritative table containment:
- `TABLE_EDGE_CONTACT_HALF_WIDTHS`;
- `get_horizontal_edge_contact_bounds_at_y()`;
- per-level X scalar clamp;
- circle-radius wall clearance;
- physical-wall outward offset compensation.

These may remain temporarily only if unused by production and clearly marked deprecated, but preferred outcome is removal where safe.

## Diagnostic overlay/evidence

Add a debug/evidence mode or focused test visualization showing for representative levels L01, L06, L12:
- accepted rail segments;
- contact hull;
- active/inward segment normals;
- hull support/contact point;
- circle collider for comparison.

Retain at least one normal GUI capture at 720x1280.

## Required tests

Focused V09 tests must verify:

1. V05 source rail coordinates unchanged.
2. All 12 `COLLIDER_RADII` unchanged.
3. All 12 visual contact hulls exist and have >= 4 points.
4. Hull data does not reference or derive from collider radii.
5. Drink circle collides with drinks, not table walls.
6. L01/L06/L12 can approach left and right sloped rails according to hull geometry.
7. Rear contact is determined by hull-vs-rear-line, not common center Y.
8. At least one asymmetric level demonstrates different support distance for left vs right rail normal.
9. Corner case uses multiple constraints without escaping.
10. Side contact removes only outward normal velocity and preserves meaningful tangential velocity.
11. Merge near left wall is immediately projected by the same hull solver.
12. Merge near right wall is immediately projected by the same hull solver.
13. Center merge remains unchanged.
14. Full active M01-M07/R09/R10 regressions pass or any superseded historical scalar-edge probe is explicitly retired/replaced with justification.
15. No auto-fire regression.

## Owner visual acceptance

Headless tests are not sufficient.

Owner must run the normal game and confirm:
- the visible glass/container reaches the accepted rail naturally;
- no large invisible strip remains;
- drinks do not escape the table;
- side sliding remains natural;
- merges near edges do not pop far inward;
- accepted rail geometry is unchanged.

Codex must not edit TASKS.md, ChatGPT-owned prompt/audit/criteria files, canonical PNGs, or start M08+.
