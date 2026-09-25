# Beach Cocktails Merge — Canonical Table Geometry Contract V2

Status: **OWNER-DIRECTED CONSTITUTIONAL GEOMETRY CONTRACT**
Supersedes: `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V1.md`
Runtime baseline: accepted R11 table-edge behavior on `main`

## 1. Constitutional rule

All islands and all levels use ONE table geometry.

The following may vary by island:
- surface material;
- color;
- trim;
- inlay;
- motif;
- decorative texture;
- non-geometric lighting/reflection.

The following may NOT vary by island:
- playable table boundary;
- perspective;
- rear edge;
- launch alignment;
- danger line;
- front tabletop art transition;
- table-leg/progression layout relationship.

AI-generated artwork never defines gameplay geometry. Artwork must conform to this contract.

## 2. Critical V1 correction

V1 treated the tabletop as a four-corner art polygon ending at the viewport bottom:
`(130,398) -> (590,398) -> (720,1280) -> (0,1280)`.

That shape is **not the live R11 gameplay boundary** and leaves no canvas below the tabletop for the required table body and visible legs.

V2 separates:
1. the authoritative R11 playable boundary;
2. the visible tabletop/art surface;
3. the non-playable front apron + legs;
4. the L01-L12 progression area between the legs.

The legacy V1 mask and V1 JSON are historical evidence only and are NOT geometry authority for new table art.

## 3. Base viewport and source mapping

Canonical portrait viewport: **720 x 1280**.
Runtime background source space: **1024 x 1536**.

At 720 x 1280 the current cover transform is:
- scale = **5/6 = 0.8333333333**;
- horizontal offset = **-66.6666667 px**;
- vertical offset = **0 px**.

## 4. Authoritative R11 playable boundary

The authoritative runtime rails remain the accepted constants in `scripts/game_manager.gd`.

Source-space left rail:
- (199,478)
- (149,587)
- (124,644)
- (85,734)
- (60,800)
- (20,1000)
- (8,1186)

Source-space right rail:
- (833,478)
- (880,587)
- (905,644)
- (942,734)
- (964,800)
- (1002,1000)
- (1016,1186)

Derived 720 x 1280 viewport samples:

Left:
- (99.167,398.333)
- (57.500,489.167)
- (36.667,536.667)
- (4.167,611.667)
- (-16.667,666.667)
- (-50.000,833.333)
- (-60.000,988.333)

Right:
- (627.500,398.333)
- (666.667,489.167)
- (687.500,536.667)
- (718.333,611.667)
- (736.667,666.667)
- (768.333,833.333)
- (780.000,988.333)

Rear rail Y = **398.333** in the 720 x 1280 viewport.
Danger line Y = **900.000**.
Launch line Y = **946.667**.
Perspective centerline = **x 360**.

Do not retune these R11 values merely to fit generated artwork.

## 5. Tabletop versus full table artwork

`gameplay_table.png` remains a **720 x 1280 transparent RGBA asset**, but it is a FULL TABLE ART asset, not a tabletop-only alpha mask.

The table surface must visually track the R11 rail envelope from the rear edge down to the accepted near-table reference at **y = 988.333**.

That is the canonical **front tabletop art transition**.

The region below approximately **y = 988.333** is NOT gameplay surface. It is reserved for:
- front apron / table thickness;
- two visible front table legs;
- structural braces/details;
- the progression composition between the legs.

## 6. Mandatory visible legs

Every island `gameplay_table.png` must show **two clearly visible front legs/supports**.

Rules:
- legs begin below the tabletop/front apron;
- legs do not redefine the playable boundary;
- legs do not enter the playable tabletop;
- legs preserve one common structural placement across all islands;
- island identity may change the leg material/trim only;
- the exact lower apron/two-leg footprint is now frozen from the owner-approved Azure Bay V2 master in `assets/ui_assets/tables/table_structure_mask_v2.png` and applies to all islands.

## 7. L01-L12 progression zone

The current runtime already renders the twelve cocktail progression icons in a HUD `CanvasLayer`.

At 720 x 1280:
- progression panel rect ~= **x 12..708, y 1039.465..1272**;
- icon row centers ~= **y 1124.300** and **y 1186.363**;
- icon column centers ~= **x 197.547, 262.335, 326.643, 390.951, 455.419, 520.689**.

The two table legs must visually frame this progression area.

Hard requirement:
- the central L01-L12 icon corridor must remain unobstructed;
- no opaque leg/apron artwork may cover the progression icon centers;
- progression remains HUD/UI and does not become physics space.

The owner-approved Azure Bay V2 master has frozen the structural placement. `assets/ui_assets/tables/table_structure_mask_v2.png` is the canonical lower-structure footprint.

## 8. Asset-role rules

### gameplay_table.png
- 720 x 1280 transparent RGBA;
- full table artwork;
- playable tabletop aligned to this V2 contract;
- visible front apron/thickness;
- two visible front legs;
- island-specific material treatment;
- no scenery replacing the table;
- no baked progression cocktails.

### gameplay_table_shadow.png
- 720 x 1280 transparent RGBA;
- shadow only;
- supports the full table structure visually;
- never defines gameplay geometry.

### table_edge_overlay.png
- 720 x 1280 transparent RGBA;
- follows the V2 tabletop edge/rail language;
- center remains open;
- does not include an unrelated frame or scene;
- does not redefine playable geometry.

## 9. Legacy mask rule

These V1-era files remain in the repository for history until explicitly replaced:
- `assets/ui_assets/tables/table_geometry_v1.json`
- `assets/ui_assets/tables/table_silhouette_mask.png`
- `assets/ui_assets/tables/table_edge_overlay_master.png`

They are **NOT V2 geometry authority**.

Do NOT force new `gameplay_table.png` alpha to the old V1 tabletop-only mask. Doing so removes the front apron and legs and recreates the defect V2 exists to solve.

## 10. Runtime preservation

The accepted R11 table-edge behavior is frozen unless the owner explicitly authorizes a physics change.

Do not change as part of visual-table production:
- R11 rail source points;
- `REAR_EDGE_MARGIN`;
- footprint projection semantics;
- drink collider radii;
- merge physics;
- launch/deceleration behavior.

Artwork conforms to gameplay geometry, not vice versa.

## 11. Production order

1. Keep R11 runtime geometry unchanged.
2. Generate Azure Bay V2 `gameplay_table.png` using this contract.
3. Show the owner the isolated asset and an in-game/progression composition preview.
4. Owner approves or rejects.
5. Azure Bay V2 structural placement is frozen in the canonical V2 masks/master assets under `assets/ui_assets/tables/`.
6. Use the canonical edge-extraction mask and shadow master for every converted island.
7. Apply the exact same geometry/structure to the other nine island skins.
8. Audit visually before promotion.

No other island table becomes geometry authority.

## 12. Acceptance

A table fails if:
- the playable tabletop moves relative to the R11 rail envelope;
- the front tabletop art extends to y=1280 and eliminates the leg zone;
- legs are missing;
- legs cover the L01-L12 progression icons;
- the image is a scene/slab/platform rather than a table;
- the island skin changes table geometry;
- V1 bottom-corner geometry is used as authority.

This V2 contract is constitutional project truth for table visuals until the owner explicitly replaces it.
