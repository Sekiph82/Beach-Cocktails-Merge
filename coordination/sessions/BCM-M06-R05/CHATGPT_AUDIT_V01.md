# BCM-M06-R05 — Independent Audit V01

Verdict: **CHANGES_REQUIRED**

Authority: locked M06-R05 criteria plus the later owner runtime screenshot/annotation captured on 2026-09-17 after BCM-M06-R05 and BCM-M07-R05 were implemented.

## What passed
- The previous duplicated half-wall-width inset was removed.
- `get_horizontal_bounds_at_y()` now uses rail + physical radius + small epsilon.
- HUD rectangles are not used in board-boundary calculations.
- Side-wall bodies are offset outward so the intended inward face aligns with the model rail.
- M01-M07 automated regressions reported green.

## Blocking owner-evidence finding
The later owner runtime screenshot shows that substantial visible **rear-left and rear-right tabletop wood remains unreachable**. Drinks are still constrained to a narrower rear corridor than the visible tabletop.

The focused probe does not independently prove the modeled `rails` coincide with the actual visible tabletop boundaries. It proves only that cocktail circles become tangent to the rails returned by `get_table_rail_bounds_at_y()`. Those rails still originate from the old two-endpoint model (`TABLE_FAR_LEFT_SOURCE`, `TABLE_FAR_RIGHT_SOURCE`, `TABLE_NEAR_*`) with linear interpolation.

Therefore the test is self-consistent with the production geometry but does not close the owner-visible defect.

## Required remediation direction
- Re-measure the actual visible inner tabletop boundary from the active owner-approved background/runtime render.
- Do not assume the old far points `(154,472)` and `(870,472)` are correct merely because current tests use them.
- Sample both visible left and right tabletop edges at multiple Y depths, especially the rear third where the defect is visible.
- Use a piecewise/polyline or equivalent perspective-boundary representation if one straight interpolation line cannot follow the artwork closely enough.
- Validate against independent screenshot-space landmark measurements, not values generated from the same production constants.
- Owner acceptance target: the physical glass/body may reach all visibly usable rear-left and rear-right tabletop regions while remaining on wood.

BCM-M06-R05 is not accepted until this owner-visible rear-table restriction is removed.