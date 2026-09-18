# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit Criteria V08

Status: **LOCKED BEFORE IMPLEMENTATION — SUPERSEDES V01-V07**

Authority: owner request dated 2026-09-18 after V07 strict audit.

## Purpose

V07 failed because its supposedly independent edge-contact constants numerically reproduced the collider-derived runtime scale.

V08 removes that ambiguity completely.

The V08 table-edge contact dataset is an explicit owner-calibration trial in runtime screen pixels. It is intentionally NOT calculated from:
- COLLIDER_RADII;
- VISIBLE_BODY_WIDTH_PX;
- visual_scale_for_level();
- source contact widths;
- texture dimensions;
- any algebraic conversion from collider-defined sprite scale.

## Frozen state

Do not alter:
- V05 owner-approved three-sided playable envelope;
- rear_table_y;
- V05 Solution 1 merge X clamp architecture;
- drink-to-drink COLLIDER_RADII;
- CAST_SHAPE CCD;
- auto-fire fix;
- HUD layout;
- score/best centering;
- To-Go top placement;
- held drink;
- NEXT;
- progression strip;
- launch speed 700;
- deceleration 180;
- economy/persistence/Game Over/restart/rapid launch;
- canonical PNGs.

## Exact V08 runtime edge-contact dataset

Production MUST use exactly this 12-value runtime-pixel dataset:

```gdscript
const TABLE_EDGE_CONTACT_HALF_WIDTHS := [
    9.0,   # L01
    10.5,  # L02
    13.0,  # L03
    10.0,  # L04
    14.5,  # L05
    16.0,  # L06
    18.0,  # L07
    22.5,  # L08
    22.0,  # L09
    31.0,  # L10
    32.0,  # L11
    34.0,  # L12
]
```

These are V08 calibration constants, not measurements reconstructed through collider-defined visual scaling.

No code may recompute or overwrite them.

## Exact production helper

```gdscript
static func table_edge_contact_half_width_for_level(p_level: int, _y_pos: float) -> float:
    if p_level < 1 or p_level > TABLE_EDGE_CONTACT_HALF_WIDTHS.size():
        return 0.0
    return TABLE_EDGE_CONTACT_HALF_WIDTHS[p_level - 1]
```

No reference to COLLIDER_RADII, visible body width, visual scale, texture dimensions, source width, or Y scaling is allowed inside this helper.

## Exact logical side-bound model

Production side bounds MUST continue to use the existing owner-approved rail helper and the explicit V08 edge width:

```gdscript
func get_horizontal_edge_contact_bounds_at_y(y_pos: float, level: int) -> Vector2:
    var rails := get_table_rail_bounds_at_y(y_pos)
    var edge_half_width := Drink.table_edge_contact_half_width_for_level(level, y_pos)
    return Vector2(
        rails.x + edge_half_width + TABLE_SOLVER_EPSILON,
        rails.y - edge_half_width - TABLE_SOLVER_EPSILON
    )
```

Do not route this helper through a collider-radius fallback.

## Exact normal-motion clamp behavior

When a level is known, lateral clamping MUST use the V08 edge-contact bounds.

Rear Y remains unchanged:

```gdscript
func clamp_position_to_board(pos: Vector2, radius: float, level: int = 0) -> Vector2:
    pos.y = clampf(
        pos.y,
        rear_table_y,
        table_bottom_y - radius - TABLE_SOLVER_EPSILON
    )

    var bounds: Vector2
    if level > 0:
        bounds = get_horizontal_edge_contact_bounds_at_y(pos.y, level)
    else:
        bounds = get_horizontal_bounds_at_y(pos.y, radius)

    pos.x = clampf(pos.x, bounds.x, bounds.y)
    return pos
```

This does not change drink-to-drink collider geometry.

## Exact merge behavior

Preserve V05 Solution 1 and use only the V08 level-specific edge bounds:

```gdscript
var merge_bounds := GameManager.instance.get_horizontal_edge_contact_bounds_at_y(
    new_drink.position.y,
    new_drink.level
)
new_drink.position.x = clampf(
    new_drink.position.x,
    merge_bounds.x,
    merge_bounds.y
)
```

Do not change merge Y.
Do not zero inherited velocity.

## Physical side-wall compatibility

The full circular RigidBody collider is intentionally wider than the visual edge-contact footprint.

The physical side StaticBody2D walls must therefore be far enough OUTSIDE the logical V05 rails that the physics solver cannot push a logically valid drink inward.

Keep/use this exact compatibility rule:

```gdscript
func _max_side_wall_clearance(a: Vector2, b: Vector2) -> float:
    var clearance := 0.0

    for sample in [a, b]:
        for level in range(1, Drink.max_level() + 1):
            var collider_radius := Drink.collider_radius_for_level(level)
            var edge_half_width := Drink.table_edge_contact_half_width_for_level(
                level,
                sample.y
            )
            clearance = maxf(
                clearance,
                collider_radius - edge_half_width
            )

    return maxf(clearance, 0.0) + TABLE_SOLVER_EPSILON
```

The logical rail coordinates themselves MUST NOT move.

## Rear rule

Still exactly:

`rear_target_y = rear_table_y`

No radius/height/width/depth offset.

## Required focused tests

V08 tests must assert exact production values against an independent literal expected array:

```gdscript
const EXPECTED_V08_EDGE_HALF_WIDTHS := [
    9.0, 10.5, 13.0, 10.0, 14.5, 16.0,
    18.0, 22.5, 22.0, 31.0, 32.0, 34.0
]
```

Required:
1. all 12 production values equal the V08 literal array;
2. no production helper references collider radius or visual scale for these values;
3. COLLIDER_RADII remain unchanged;
4. V05 rail coordinates remain unchanged;
5. L01/L06/L12 left and right edge contacts use the V08 values;
6. left-wall merge uses V08 L02 = 10.5 px;
7. right-wall merge uses V08 L02 = 10.5 px;
8. center merge clamp is no-op;
9. rear target equals rear_table_y;
10. full regression green.

## Visual acceptance

A normal GUI/F5 owner check is mandatory after implementation.

The owner must determine whether:
- cocktails now sit materially closer to the accepted side/table edge;
- side merge results no longer leave the objectionable visible gap;
- the playable envelope itself remains unchanged.

Headless PASS alone cannot close R10.

Codex must not edit TASKS.md, ChatGPT-owned files, canonical PNGs, historical logs or M08+.
