# What to Do If the Table Artwork Changes — V2

**Constitutional authority:** `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md`
**Machine-readable authority:** `assets/ui_assets/tables/table_geometry_v2.json`
**Runtime baseline:** accepted R11 table-edge behavior in `scripts/game_manager.gd`

## Default rule: geometry first, artwork second

Do **not** measure an arbitrary newly generated table and then retune gameplay to fit it.

The default workflow is the opposite:

1. preserve the accepted R11 playable rails;
2. generate/fit the new table artwork to V2;
3. preserve the canonical 720x1280 composition;
4. keep the tabletop/front-art transition near y=988.333;
5. reserve the lower region for front apron/thickness + two visible legs;
6. keep the existing L01-L12 progression content visible between the legs.

The legacy V1 bottom-corner polygon, V1 JSON, and `table_silhouette_mask.png` are not authority for new table art.

## Runtime geometry frozen by default

Current source-space values in `scripts/game_manager.gd`:
- `ACTUAL_REAR_TABLE_SOURCE_Y = 478`;
- left rail = (199,478), (149,587), (124,644), (85,734), (60,800), (20,1000), (8,1186);
- right rail = (833,478), (880,587), (905,644), (942,734), (964,800), (1002,1000), (1016,1186);
- `DANGER_SOURCE_Y = 1080`;
- `LAUNCH_SOURCE_Y = 1136`;
- `REAR_EDGE_MARGIN = 12`.

At 720x1280 these map approximately to:
- rear Y = 398.333;
- danger Y = 900;
- launch Y = 946.667;
- front tabletop art transition / last rail sample Y = 988.333.

Do not change these values for visual-production convenience.

## Full table artwork

`gameplay_table.png` is a full 720x1280 transparent table asset.

It contains:
- the V2-aligned tabletop;
- front apron/table thickness below the tabletop;
- exactly two visible front legs/supports.

The region below y≈988.333 is non-playable visual structure.

The two legs must frame, not cover, the existing progression UI.

## Progression area

At 720x1280 the current progression panel is approximately:
- x = 12..708;
- y = 1039.465..1272.

Runtime L01-L12 icon centers are approximately:
- X = 197.547, 262.335, 326.643, 390.951, 455.419, 520.689;
- Y = 1124.300 and 1186.363.

No opaque leg/apron art may cover those icon centers.

Exact leg X placement is frozen only after owner approval of the Azure Bay V2 master, then reused for all islands.

## What not to touch for a normal island skin

Do not change:
- `scripts/game_manager.gd` rail points;
- R11 footprint projection;
- `REAR_EDGE_MARGIN`;
- drink collider radii;
- merge momentum;
- launch speed/deceleration;
- progression runtime logic.

Only the art skin changes.

## If the owner explicitly changes gameplay geometry

A physics/geometry change is a separate owner-authorized task.

Then:
1. update `scripts/game_manager.gd` rail/rear/danger/launch values;
2. update `TABLE_GEOMETRY_CONTRACT_V2.md`;
3. update `table_geometry_v2.json`;
4. re-run all R11 table-edge/footprint regression checks;
5. verify L12 rear fit;
6. verify danger and launch placement;
7. verify progression/leg composition;
8. require owner runtime approval.

Never silently change gameplay geometry to rescue a generated image.
