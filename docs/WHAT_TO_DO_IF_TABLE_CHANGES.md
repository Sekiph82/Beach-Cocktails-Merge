# What to Do If the Table Artwork Changes

**Context:** code state after the BCM-R11 table-edge fix.
**Related report:** `docs/BCM-R11_TABLE_EDGE_FIX_REPORT.md`

After R11, table geometry is centralized in one place. Physics, collision, merge and footprint logic do not know the table dimensions — they are all derived from the constants below. Therefore, for a new table artwork, only the measurement values change.

---

## 1. Must change — all in `scripts/game_manager.gd`

| Line | Constant | Action |
|---|---|---|
| 11 | `BACKGROUND_SOURCE_SIZE` | The new PNG's pixel dimensions. If the resolution is unchanged, leave it alone. |
| 24-31 | `TABLE_LEFT_EDGE_SOURCE_POINTS` | Measure the new table's **left** edge on the new PNG and write the point list. |
| 33-40 | `TABLE_RIGHT_EDGE_SOURCE_POINTS` | The same for the **right** edge. |
| 19 | `ACTUAL_REAR_TABLE_SOURCE_Y` | The rear edge Y coordinate. It must be **the same as** `TABLE_LEFT_EDGE_SOURCE_POINTS[0].y`. |
| 42 | `DANGER_SOURCE_Y` | The red dashed danger line. Move it upward if the table becomes shorter. |
| 43 | `LAUNCH_SOURCE_Y` | The launch position. Adjust it in the same way. |

**The number of points is flexible.** The code uses `points.size()`: four points or ten points both work. The left and right lists do not have to have the same number of elements. The only requirement is that Y values are in ascending order.

---

## 2. May also change

### `COLLIDER_RADII` — `scripts/drink.gd`, line 106

This is the second most important item.

The table's **rear edge** is its narrowest point. At present it is 634 px in source space and 528 px on screen. L12 has a diameter of 180 px, so 2.9 of them fit across the rear edge.

If the table becomes narrower, this ratio falls and gameplay can jam: large glasses may not fit at the rear, leaving no room to merge and causing an early Game Over.

> **Rule:** rear-edge width ÷ largest-glass diameter must be ≥ **2.5**

If the values must be reduced, scale the whole array proportionally. `visual_scale_for_level()` automatically scales the sprite — no other change is needed.

This array controls both physics and presentation together.

### `REAR_EDGE_MARGIN` — `scripts/game_manager.gd`, line 55

This is a fixed value in screen pixels (currently 12.0). If the table becomes smaller, 12 px will look proportionally larger; it will probably need to be reduced to 8–10. Adjust it by eye.

---

## 3. Do not touch

- `BOUNDARY_CONTACT_HULL_SOURCE_PX`, `VISIBLE_BODY_WIDTH_PX`, `VISIBLE_BODY_CENTER_OFFSET_PX`, `HELD_BODY_FOOT_SOURCE_PX`
  → Measurements of the cocktail PNGs. They are unrelated to the table.
- `get_table_footprint_local()`, `project_footprint_inside_table()`
  → Geometry-independent. They read the rail list from `get_playable_boundary_edges()`.
- `_build_walls()`, `_layout_danger_line()`, `get_table_rail_bounds_at_y()`, `table_top_y` / `rear_table_y` / `table_bottom_y`
  → All are derived automatically from the constants above.
- HUD panels
  → They are positioned from viewport coordinates, independent of the background. The code will not break; however, if the new artwork's tiki roof / bamboo strip is in a different place, visual alignment must be checked by eye.

---

## 4. Two rules to follow

### Convexity

The solver treats the edge half-planes as an intersection. This requires the table shape to be **convex**: the table must widen continuously downward, with the rate of widening decreasing.

Current left-edge slopes: −0.459, −0.439, −0.433, −0.379, −0.200, −0.065 — progressively flatter. A normal perspective table measurement naturally satisfies this condition.

If the table has an inward notch or indentation, glasses will be pushed out of it.

### Aspect ratio

`background_scale_for_viewport()` uses `cover` behavior: `max(vw/sw, vh/sh)`.

Current artwork: 1024×1536 (ratio 0.667), viewport 720×1280 (ratio 0.5625).
The image is scaled by height, cropping 66.7 px from each side.

If the new image is narrower than 0.5625, the top and bottom will be cropped and the lower table may be cut off. Staying near **2:3** is safest.

---

## 5. Implementation order

1. Open the new PNG in an image editor. Select 5–7 points along the left and right edges and read their pixel coordinates.
   **Coordinates must be in the PNG's own pixel space** — not screen coordinates. `source_to_viewport()` performs the conversion.
2. Update the six constants above and run with F5.
3. Throw the largest glass to the rear and check whether it fits.
   If it does not, scale `COLLIDER_RADII`.
4. Adjust `REAR_EDGE_MARGIN` visually.

---

## 6. Recommended verification

After the change, check:

- [ ] Can a glass of every level touch the left / right / rear edge, with the gap not changing by level?
- [ ] Does the largest glass (L12) fit at the rear edge?
- [ ] Does a new glass after a near-edge merge avoid being thrown inward?
- [ ] Do light and hard contacts with a settled glass produce similar results?
- [ ] Are the danger line and launch ring in the correct places on the table?
- [ ] Can a glass ever leave the table?
