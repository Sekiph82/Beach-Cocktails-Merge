# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit V07

Verdict: **CHANGES_REQUIRED**

Audited implementation:
`3bf550cb96a73ba9d1918757c4cba1932b07ff1b`

Builder log:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V07.md`

Locked criteria:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V09.md`

## What passed

1. V05 left/right/rear playable rail source coordinates remain unchanged.
2. Existing L01-L12 CircleShape2D radii remain unchanged and remain the drink-to-drink gameplay collider.
3. Drink bodies use layer 1 / mask 1 while diagnostic table walls use layer 2, so the gameplay circle no longer physically collides with table walls.
4. The V08 scalar edge-contact model is removed from production.
5. Explicit convex L01-L12 visual contact hulls exist, with 6-12 points each.
6. Hull source data is not itself generated from COLLIDER_RADII.
7. The accepted left/right/rear rails are exposed as piecewise segments with inward unit normals.
8. `project_visual_hull_inside_table()` performs iterative half-plane projection and removes only outward normal velocity while preserving tangential velocity.
9. `Drink._integrate_forces()` uses the shared hull solver.
10. Merge-time containment uses the same hull solver.
11. Rear contact is now hull-to-line rather than common center-Y stopping, as intentionally superseded by V09.
12. Focused V09 tests exercise asymmetric support, left/right/rear contact, corner constraints, velocity projection, merge projection, and center no-op.
13. Historical scalar-edge tests were explicitly identified as superseded rather than silently counted as passing.

## Critical blocker — runtime contact hull transform does not exactly match the rendered Sprite2D transform

The locked V09 criterion requires `get_boundary_contact_hull_local()` to return the visual hull in the same RigidBody2D-local runtime coordinates as the actually rendered cocktail.

Production currently computes:

```gdscript
var presentation_scale := 1.0
presentation_scale *= _cocktail_sprite.scale.x
presentation_scale *= _visual_root.scale.x
var sprite_origin := _cocktail_sprite.position

for source_point in source_hull:
    local_hull.append(sprite_origin + source_point * presentation_scale)
```

But the node hierarchy is:

```text
RigidBody2D
└── Visual (_visual_root, scaled)
    └── CocktailSprite (position + own scale)
```

Therefore the actual rendered body-local point is:

```text
visual_root_scale * (
    cocktail_sprite.position
    + cocktail_sprite_scale * source_point
)
```

while the V09 hull code computes:

```text
cocktail_sprite.position
+ visual_root_scale
  * cocktail_sprite_scale
  * source_point
```

The sprite position/offset is not multiplied by `_visual_root.scale`.

The difference is:

```text
(1 - visual_root_scale) * cocktail_sprite.position
```

Whenever `_visual_root.scale != Vector2.ONE`, the boundary hull and the visible sprite are therefore not exactly coincident.

This matters because V09 intentionally makes the visual hull the authoritative table-contact representation. The hull must match the rendered glass body, not merely approximate it with a slightly different transform.

## Required correction

Implement the transform composition directly rather than multiplying only the hull points.

Equivalent acceptable implementation:

```gdscript
func get_boundary_contact_hull_local() -> PackedVector2Array:
    var source_hull := boundary_contact_hull_source_for_level(level)
    var local_hull := PackedVector2Array()
    if source_hull.is_empty():
        return local_hull

    var sprite_scale := _cocktail_sprite.scale if _cocktail_sprite != null else Vector2.ONE
    var sprite_position := _cocktail_sprite.position if _cocktail_sprite != null else Vector2.ZERO
    var root_scale := _visual_root.scale if _visual_root != null else Vector2.ONE

    for source_point in source_hull:
        var sprite_local := sprite_position + source_point * sprite_scale
        local_hull.append(sprite_local * root_scale)

    return local_hull
```

Or use the actual node transforms to achieve the same exact body-local result.

Add a focused test that compares several transformed hull points against the equivalent composed Sprite2D + Visual transform at representative Y positions where visual-root scale is not 1.0.

## Additional observation, not a separate blocker

The held-drink anchor changes `CocktailSprite.position`, while `start_sliding()` restores the normal visual offset. A drink launched very close to a side boundary can therefore change hull geometry at fire time and be corrected on the first physics integration. This should be observed during owner runtime testing for a visible lateral pop, but it is not by itself a locked V09 failure yet.

## Regression state

Builder evidence reports the active V09 replacement suite green.

One old M06 scalar-boundary probe parses with exit code 1 because it references removed helpers. The log explicitly retires that probe and replaces its relevant boundary assertions with V09 coverage, which is allowed by the locked V09 criteria.

## Final state

- V09 architecture: **PASS**
- Circle/table responsibility separation: **PASS**
- Rail segment normals + custom containment: **PASS**
- Merge-time shared solver: **PASS**
- Runtime hull/render transform equivalence: **FAIL**
- Owner visual verification: **NOT YET READY**

Final verdict: **CHANGES_REQUIRED**

Fix the hull-transform composition first, rerun focused/full regression, then proceed to owner GUI verification.
