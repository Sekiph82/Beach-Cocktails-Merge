# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Execution Prompt V08

Status: **ISSUED — SUPERSEDES V01-V07**

Implement exactly the code contract in:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V08.md`

This V08 is intentionally prescriptive. Do not redesign the solution.

## Read first
- AGENTS.md
- coordination/AUDIT_POLICY.md
- TASKS.md
- coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_V05.md
- coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V08.md

## Required production patch

### scripts/drink.gd

Replace the current V07 edge-contact dataset with exactly:

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

Use exactly:

```gdscript
static func table_edge_contact_half_width_for_level(p_level: int, _y_pos: float) -> float:
    if p_level < 1 or p_level > TABLE_EDGE_CONTACT_HALF_WIDTHS.size():
        return 0.0
    return TABLE_EDGE_CONTACT_HALF_WIDTHS[p_level - 1]
```

Do not calculate these values from collider radius, visual scale, visible body width, texture dimensions or source-pixel measurements.

### scripts/game_manager.gd

Use exactly this logical edge helper:

```gdscript
func get_horizontal_edge_contact_bounds_at_y(y_pos: float, level: int) -> Vector2:
    var rails := get_table_rail_bounds_at_y(y_pos)
    var edge_half_width := Drink.table_edge_contact_half_width_for_level(level, y_pos)
    return Vector2(
        rails.x + edge_half_width + TABLE_SOLVER_EPSILON,
        rails.y - edge_half_width - TABLE_SOLVER_EPSILON
    )
```

Use this clamp behavior:

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

Keep physical side-wall compatibility using exactly:

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

Do NOT change the V05 rail coordinates.

### scripts/merge_queue.gd

Preserve Solution 1 and use exactly:

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

Do not modify merge Y.
Do not zero inherited velocity.

## Frozen requirements

Preserve:
- V05 playable envelope;
- rear_target_y = rear_table_y;
- COLLIDER_RADII;
- CAST_SHAPE CCD;
- auto-fire fix;
- HUD;
- To-Go;
- held drink;
- NEXT;
- progression;
- 700 px/s launch;
- 180 px/s² deceleration;
- economy/persistence/Game Over/restart.

Do not modify canonical PNGs.
Do not edit TASKS.md.
Do not edit ChatGPT-owned files.
Do not start M08+.

## Tests

Create/update a V08 focused probe with this literal independent expected array:

```gdscript
const EXPECTED_V08_EDGE_HALF_WIDTHS := [
    9.0, 10.5, 13.0, 10.0, 14.5, 16.0,
    18.0, 22.5, 22.0, 31.0, 32.0, 34.0
]
```

Verify:
- production array exact match;
- collider radii unchanged;
- rails unchanged;
- L01/L06/L12 left/right contacts;
- wall merge left/right;
- center no-op;
- exact rear target;
- full active regression.

Retain a normal GUI/F5 capture for owner verification.

Write:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V06.md`

Push implementation and log.

Return log URL + implementation SHA + final regression result + AWAITING_AUDIT, then STOP.
