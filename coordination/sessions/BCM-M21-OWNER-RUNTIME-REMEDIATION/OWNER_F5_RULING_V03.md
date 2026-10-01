# BCM-M21 Owner F5 Ruling V03 — Final Visual/UX Corrections

Date: 2026-10-01
Status: **OWNER-AUTHORITATIVE**

Owner manual F5 checklist result after V02-R01 technical PASS:

- 1 FAIL / owner change — debug view must be 800×1422, not 486×864.
- 2 PASS — Main Menu → PLAY → World Map.
- 3 FAIL — island hotspots are acceptable, but runtime inter-island route lines are visually wrong.
- 4 FAIL — Sunny Cove opens, but its World Map position must be lower-left and Sunny Cove must have its own Island Map background.
- 5 FAIL — correct Sunny Cove table asset exists, but another runtime layer visually covers it. Owner requests removal of decor_left/decor_right/decor_back.
- 6 PASS — gameplay is playable with mouse.
- 7 PASS — no timer / no TIME UP.
- 8 PASS — Pause → Resume.
- 9 FAIL — WIN result opens, but active cocktail sprites remain visible above the result modal.
- 10 PASS — restart persistence.

## Locked owner decisions

### Debug size
Keep canonical viewport 720×1280. Set desktop/Godot debug override to exactly **800×1422**.

### World Map route rendering
The canonical World Map background already contains the white dotted route network.

Therefore:
- runtime `IslandRoute` / yellow `Line2D` route drawing is forbidden;
- no replacement runtime route polyline is added;
- only baked white dotted routes remain visible.

### World Map island centers
`data/campaign/islands.json.map_position` is authoritative for hotspot centers.

For Sunny Cove:
- normalized position = `[0.16, 0.83]`;
- it must render in the lower-left area of the World Map.

Remove/disable hard-coded `BAKED_ISLAND_CENTERS` overrides that conflict with data positions.

### Island Map background
Canonical island maps must use each island theme's `island_map_background`.

Sunny Cove must use:
`res://assets/ui_assets/campaign/islands/sunny_cove/map_background.png`

The flat dark-blue ColorRect is fallback-only for missing/invalid theme data.

### Sunny Cove gameplay composition
Owner-approved runtime composition contains only:
- gameplay_background
- gameplay_table_shadow
- gameplay_table
- table_edge_overlay
- launch_zone

`decor_left.png`, `decor_right.png`, and `decor_back.png` must not render in production gameplay until separately re-approved.

The visible Sunny Cove wooden table:
`res://assets/ui_assets/campaign/islands/sunny_cove/gameplay_table.png`
must remain unobscured across its playable surface.

If the occluding visual is not one of the three decor assets, identify the exact runtime node/texture that obscures the wooden table and disable/remove it without changing R11 physics geometry.

### WIN result modal
When campaign session becomes terminal:
- all active Drink sprites are frozen and hidden before result modal appears;
- transient merge/delivery effect nodes are cleared/hidden;
- no gameplay-world sprite may draw above the result modal;
- result modal must render in a dedicated topmost CanvasLayer;
- Retry/Next Level/Island Map must continue to work;
- no hidden cocktail may continue physics or be delivered after terminal state.

No release PASS until owner manually confirms these corrections.
