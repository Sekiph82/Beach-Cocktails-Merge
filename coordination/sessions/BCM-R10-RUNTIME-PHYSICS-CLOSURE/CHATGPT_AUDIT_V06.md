# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit V06

Verdict: **SOURCE_AUDITED_PASS / OWNER_RUNTIME_VERIFICATION_REQUIRED**

Audited implementation:
`0c6f66c4380fc41fb9163cf806dd2daff62b368f`

Builder log:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V06.md`

Locked criteria:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V08.md`

## Independent source audit

The V08 implementation matches the prescribed code contract.

### 1. Exact V08 dataset

Production contains exactly:

```gdscript
const TABLE_EDGE_CONTACT_HALF_WIDTHS := [
    9.0, 10.5, 13.0, 10.0, 14.5, 16.0,
    18.0, 22.5, 22.0, 31.0, 32.0, 34.0
]
```

No runtime recomputation of these values is present.

Result: **PASS**

### 2. Literal-only edge helper

`table_edge_contact_half_width_for_level()` returns the array entry directly.

It does not reference:
- `COLLIDER_RADII`;
- `collider_radius_for_level()`;
- `VISIBLE_BODY_WIDTH_PX`;
- `visual_scale_for_level()`;
- source texture dimensions;
- source contact width;
- Y-dependent scaling.

This closes the V06/V07 algebraic-dependence defect.

Result: **PASS**

### 3. Logical side-bound helper

`GameManager.get_horizontal_edge_contact_bounds_at_y()` now:
- obtains the accepted perspective rail position;
- obtains the literal V08 per-level edge half-width;
- returns rail +/− edge width + solver epsilon.

It no longer routes through collider-radius fallback behavior.

Result: **PASS**

### 4. Normal board clamp

When level is known, `clamp_position_to_board()` uses the V08 edge-contact bounds for lateral X.

Rear Y remains clamped to the exact common `rear_table_y`.

Fallback radius-based bounds remain only for calls where level is unavailable.

Result: **PASS**

### 5. V05 Solution 1 merge clamp

The real production merge path still performs the post-merge X correction using:

`get_horizontal_edge_contact_bounds_at_y(new_drink.position.y, new_drink.level)`

Merge Y is not modified by this correction and inherited momentum handling remains after the clamp.

Result: **PASS**

### 6. Physical side-wall compatibility

`_max_side_wall_clearance()` uses:

`collider_radius - literal_edge_half_width`

to shift physical side wall collision outward while leaving the logical V05 rail coordinates unchanged.

This is the prescribed mechanism for preventing the larger physical CircleShape2D from solver-ejecting a logically valid edge-contact position.

Result: **PASS**

### 7. Frozen geometry and physics contracts

The focused V08 probe independently asserts:
- V05 rear source Y remains 478;
- V05 left rail source points unchanged;
- V05 right rail source points unchanged;
- collider radii unchanged;
- rear target equals `rear_table_y`;
- L01/L06/L12 side contacts use V08 values;
- left/right wall merge use L02 = 10.5;
- center merge clamp is a no-op.

Builder regression reports all active M01-M07, R09, R10 probes PASS.

Result: **PASS by source + builder evidence**

## Important distinction from V07

V07 failed because its hardcoded constants reproduced a collider-derived conversion.

V08 does not claim these values are independently measured geometry. They are explicitly owner-calibration trial constants in runtime pixels.

That distinction is valid under the V08 locked criteria.

The production conversion chain from source PNG width to collider-derived scale has been completely removed from the table-edge contact model.

## Remaining acceptance gate

The locked V08 criteria require a normal GUI/F5 owner check.

Codex retained:
`docs/evidence/r10/v08_gui_edge_contacts_720x1280.png`

but a scripted builder capture is not owner acceptance.

The owner must now verify in normal gameplay that:
1. cocktails visibly sit materially closer to the accepted side/table edge;
2. side merges no longer leave the objectionable gap;
3. the accepted playable envelope itself still looks correct;
4. gameplay/merge flow remains acceptable.

Until that visual check is accepted, R10 cannot receive final AUDITED_PASS.

## Final state

- Exact V08 code contract: **PASS**
- V06/V07 collider-dependence defect: **RESOLVED**
- Regression suite: **PASS by builder evidence**
- Owner visual closure: **PENDING**

Final verdict: **SOURCE_AUDITED_PASS / OWNER_RUNTIME_VERIFICATION_REQUIRED**

Do not begin M08+ until owner visual acceptance is recorded.
