# Beach Cocktails Merge — Table Asset Production Rulechain V2

Status: **MANDATORY / CONSTITUTIONAL PRODUCTION PROCEDURE**
Applies to: Azure Bay master and the remaining 9 island table families
Geometry authority:
- `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md`
- `assets/ui_assets/tables/table_geometry_v2.json`

This document defines HOW the three table assets are produced. It is not optional guidance.

## 0. Canonical V2 technical master assets

Azure Bay V2 has owner approval and its structural layout is frozen.

Mandatory technical masters:
- `assets/ui_assets/tables/table_playable_surface_mask_v2.png` — canonical R11/V2 playable tabletop footprint;
- `assets/ui_assets/tables/table_structure_mask_v2.png` — canonical lower apron + two-leg alpha footprint for y >= 989, frozen from the approved Azure Bay V2 master;
- `assets/ui_assets/tables/table_edge_extraction_mask_v2.png` — canonical mask for deriving each island edge overlay from its own final gameplay table;
- `assets/ui_assets/tables/table_shadow_master_v2.png` — canonical fixed shadow pixels for every island.

For each V2-converted island:
- fit the island artwork to the playable-surface master;
- use the structure mask for the lower apron/leg footprint;
- derive the overlay from that island's final gameplay table through the edge-extraction mask;
- use the shadow master exactly.

The legacy V1 geometry/mask/edge master remain historical only.

## 1. Required order

For every island, always produce the three files in this exact order:

1. `gameplay_table.png`
2. `table_edge_overlay.png`
3. `gameplay_table_shadow.png`

Never generate the three independently.

The final accepted `gameplay_table.png` is the visual pixel authority for the other two.

## 2. gameplay_table.png rule

### 2.1 AI role

AI/image generation may create the island-specific material/artwork only.

AI is NOT allowed to define:
- canvas dimensions;
- playable table geometry;
- rail coordinates;
- rear Y;
- front tabletop transition Y;
- leg/progression relationship.

### 2.2 Canonical output

Final output:
- 720 x 1280;
- RGBA;
- transparent outside table artwork;
- perspective centerline x = 360;
- rear playable/tabletop Y ~= 398.333;
- front tabletop art transition Y ~= 988.333;
- R11 playable rail envelope from `table_geometry_v2.json`;
- exactly two visible front legs;
- front apron/table thickness below the tabletop;
- L01-L12 progression corridor between the two legs unobstructed.

### 2.3 Geometry fitting

The raw generated table is only source art.

Before acceptance, deterministically fit the visual tabletop to the V2/R11 rail envelope.

Do not accept generator geometry merely because it looks close.

The final 720x1280 result must be checked against:
- R11 rail samples;
- rear Y;
- front tabletop transition;
- centerline;
- visible leg requirement;
- progression clearance.

Canvas clipping at the lower left/right rail is allowed and expected where the R11 rails extend outside the 720px viewport.

Do NOT narrow the table merely to avoid that clipping.

### 2.4 Island variation

Only these change between islands:
- material;
- color;
- surface motif;
- trim;
- decorative treatment;
- non-geometric lighting.

The physical table geometry stays identical.

## 3. table_edge_overlay.png rule

### 3.1 Never independently generate geometry

Do NOT ask an image generator to redraw the overlay.

The overlay must be technically derived from the FINAL accepted island `gameplay_table.png`.

This prevents:
- rail mismatch;
- rear-edge mismatch;
- duplicated/scaled furniture;
- changed perspective;
- unrelated decorative frames.

### 3.2 Exact derivation recipe

Canvas:
- 720 x 1280 RGBA.

Source:
- final accepted `gameplay_table.png` of the SAME island.

Use `assets/ui_assets/tables/table_edge_extraction_mask_v2.png`, generated from the V2 rail points in `table_geometry_v2.json`, as the canonical extraction mask.

For tabletop edge extraction:
- rear baseline = y 398;
- front tabletop transition = y 989;
- side edge band extends approximately 8 px OUTSIDE the V2 rail and 54 px INSIDE the rail;
- rear band spans approximately y 388..419;
- preserve source alpha;
- do not rescale or warp source pixels after extraction.

For y >= 989:
- copy the final source front apron / structural edge / two-leg artwork exactly where the overlay role requires the visible structural frame;
- never invent a second geometry;
- center gameplay area remains transparent/open.

The overlay and gameplay table always share the same 720x1280 pixel coordinate system.

## 4. gameplay_table_shadow.png rule

### 4.1 Shadow is functional, not illustrated

Never generate scenery for the shadow.

Forbidden:
- water;
- beach;
- furniture art;
- glowing slab;
- island illustration;
- decorative frame.

The shadow is a deterministic technical derivative.

### 4.2 Exact V2 shadow recipe

Canvas:
- 720 x 1280 RGBA.

Perspective center:
- x = 360.

Color:
- RGB = (22, 31, 43);
- low-chroma deep navy/neutral.

Main soft shadow ellipse:
- bounds x = 38..682;
- bounds y = 925..1085.

Dense inner core:
- bounds x = 92..628;
- bounds y = 955..1055.

Left leg-contact ellipse:
- x = 20..190;
- y = 1110..1275.

Right leg-contact ellipse:
- x = 530..700;
- y = 1110..1275.

Construction:
- render mask at 4x resolution;
- main ellipse fill alpha = 118;
- core ellipse fill alpha = 148;
- leg-contact ellipse fill alpha = 82;
- Gaussian blur radius = 136 px at 4x, equivalent to 34 px at final resolution;
- downsample to 720x1280 using Lanczos;
- apply RGB (22,31,43).

The same geometry and shadow recipe is used for all islands. `assets/ui_assets/tables/table_shadow_master_v2.png` is the canonical pixel master and must be used exactly.

Do not add island-specific scenery to the shadow.
Do not change shadow geometry per island.

## 5. Mandatory island sequence

Azure Bay is the structural V2 master.

After Azure Bay is accepted, produce the remaining islands using the same rulechain:
- Billionaire Island
- Coconut Beach
- Final Island
- Frozen Paradise
- Party Beach
- Sunny Cove
- Sunset Island
- Tiki Island
- Volcano Bay

For each island:
1. generate island-specific raw table artwork;
2. fit gameplay_table to the V2 geometry;
3. visually inspect the final table;
4. derive edge overlay FROM that final table;
5. produce shadow with the exact fixed recipe above;
6. composite table + overlay as a fit proof;
7. composite shadow behind table as a fit proof;
8. do not promote any asset if either proof shows misalignment.

## 6. Prohibited shortcuts

Never:
- use a previous island PNG as the geometry authority instead of V2;
- use legacy V1 bottom-corner geometry;
- use the legacy `table_silhouette_mask.png` as current authority;
- independently generate an overlay;
- independently generate a scenic shadow;
- resize a mismatched overlay to force it onto the table;
- modify R11 gameplay physics to rescue generated art;
- omit the two visible legs;
- cover the L01-L12 progression corridor;
- accept a table because it is merely visually close.

## 7. Acceptance gate

A table family passes only when:
- gameplay_table = 720x1280 RGBA;
- tabletop tracks V2/R11;
- front tabletop transition ~= y 988.333;
- two visible legs exist;
- progression corridor is clear;
- overlay is derived from the final table and visibly aligns;
- shadow uses the fixed deterministic recipe;
- no runtime physics change was made;
- owner visual review does not reject the result.

This rulechain remains mandatory until the owner explicitly replaces it.
