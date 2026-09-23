# BEACH COCKTAILS MERGE — OWNER VISUAL AUDIT REPORT V01

Audit branch: `codex/visual-assets-production`  
Audit checkpoint HEAD: `a07fc88524dfca6f1d8881dd1af18148c5529469`

This report consolidates:
1. the earlier 20-random-asset audit;
2. the focused state-pair + island-identity audit;
3. the dedicated ten-island table audit.

The V04 masters remain the PRIMARY visual authority.
The owner-rejected V05 production visuals must not be used as style references.

---

## A. PRIOR AUDIT FINDINGS TO CARRY INTO REMEDIATION

### Required remediation / targeted re-QA

- VA-009 `campaign/island_map/level_connector.png`
  - 520x36 canvas but the visible connector is too sparse/small.
  - Must remain clearly readable at runtime scale.
- VA-010 `campaign/island_map/level_connector_complete.png`
  - Too visually close to VA-009 and similarly sparse.
  - Completed state must be materially distinct.
- VA-021 `campaign/island_map/star_small_empty.png`
  - Empty star is still too gold/filled-looking.
  - Must read immediately as inactive/empty next to VA-022.
- VA-072 `campaign/islands/final_island/map_title.png`
- VA-074 `campaign/islands/final_island/theme_badge.png`
- VA-075 `campaign/islands/final_island/world_icon.png`
  - Final Island identity is too generic tropical-luxury.
  - Must strongly express exotic blackwood + pearl/turquoise/gold visual climax.
  - Must remain clearly distinct from Billionaire Island and Sunset Island.
- VA-098 `campaign/islands/party_beach/map_title.png`
  - Central area contains a grey/white cloudy generation artifact.
  - Runtime title area must be clean and intentional.

### Earlier audit context

The earlier random sample passed technical PNG/dimension/RGBA checks.
The focused audit found state families generally strong, including:
- locked/unlocked/current/completed/finale/milestone nodes;
- daily reward states;
- toggle off/on;
- chest open/closed;
- shop normal/featured;
- global button states.

Do not regenerate these unrelated passing families.

---

# B. TABLE AUDIT

## Authoritative geometry

Protected files:
- `assets/ui_assets/tables/table_silhouette_mask.png`
- `assets/ui_assets/tables/table_geometry_v1.json`

Global table overlay geometry authority:
- VA-321 `assets/ui_assets/tables/table_edge_overlay_master.png`

Important technical detail:
- `table_silhouette_mask.png` stores the actual silhouette as BLACK/WHITE RGB.
- Its alpha channel is fully opaque.
- Therefore table alpha QA must compare the generated table alpha against the WHITE RGB silhouette, not against the mask file's alpha channel.

Canonical geometry:
- viewport: 720x1280
- rear left: (130, 398)
- rear right: (590, 398)
- front right: (720, 1280)
- front left: (0, 1280)
- rear width: 460 px
- perspective centerline: x=360
- launch y: 947
- danger y: 900

## Gameplay table geometry result

All ten current `gameplay_table.png` alpha silhouettes match the canonical WHITE mask region:
- 0 differing silhouette pixels
- 100.0% mask IoU

Therefore the frozen table geometry itself was preserved in these files.

However, several table SURFACE CONTENTS are visually wrong.

---

## C. PER-ISLAND TABLE RESULTS

### Azure Bay

- VA-029 `gameplay_table.png` — REMEDIATE
  - Geometry is correct.
  - Approximately 47.10% of visible table pixels are near-white.
  - Large blank/white trapezoid area exists instead of a complete sapphire marina/coastal-luxury table material.
- VA-030 `gameplay_table_shadow.png` — REMEDIATE
  - Contains a full scenic marina/yacht image.
  - This is not a table shadow.
- VA-034 `table_edge_overlay.png` — REMEDIATE
  - Independent rounded frame geometry rather than the frozen trapezoid edge system.

### Billionaire Island

- VA-042 `gameplay_table.png` — REMEDIATE
  - Geometry is correct.
  - Approximately 41.38% near-white visible area.
  - Surface is incomplete/blank instead of a complete marble/walnut/gold luxury material.
- VA-043 `gameplay_table_shadow.png` — REMEDIATE
  - Contains a full luxury-resort scene.
- VA-047 `table_edge_overlay.png` — REMEDIATE
  - Geometry materially diverges from VA-321/frozen trapezoid.

### Coconut Beach

- VA-055 `gameplay_table.png` — REMEDIATE
  - Geometry is correct.
  - Surface contains a boardwalk/beach/environment composition rather than an isolated tabletop material.
- VA-056 `gameplay_table_shadow.png` — REMEDIATE
  - Contains a full beach/boardwalk scene.
- VA-060 `table_edge_overlay.png` — REMEDIATE
  - Independent frame shape, not canonical frozen edge geometry.

### Final Island

- VA-068 `gameplay_table.png` — REMEDIATE
  - Geometry is correct.
  - Contains scenic/environment contamination.
  - Must use the Final Island identity: exotic blackwood + pearl/turquoise/gold visual climax.
- VA-069 `gameplay_table_shadow.png` — REMEDIATE
  - Contains full scenic/platform art, not a shadow.
- VA-073 `table_edge_overlay.png` — REMEDIATE
  - Geometry diverges from canonical edge authority.

### Frozen Paradise

- VA-081 `gameplay_table.png` — KEEP / QA PASS
  - Coherent crystalline ice table surface and geometry is correct.
- VA-082 `gameplay_table_shadow.png` — REMEDIATE
  - Reads as a bright blue ice/water effect slab, not a cast table shadow.
- VA-086 `table_edge_overlay.png` — REMEDIATE
  - Independent icy rectangular/ring frame, not canonical edge geometry.

### Party Beach

- VA-094 `gameplay_table.png` — KEEP / QA PASS
  - Coherent wood + premium-neon table treatment with correct silhouette.
- VA-095 `gameplay_table_shadow.png` — REMEDIATE
  - Bright cyan/magenta luminous slab, not a table shadow.
- VA-099 `table_edge_overlay.png` — REMEDIATE
  - Oval/ring geometry materially changes the table-edge language.

### Sunny Cove

- VA-107 `gameplay_table.png` — KEEP / QA PASS
  - Coherent bright tropical wood/surface treatment.
- VA-108 `gameplay_table_shadow.png` — REMEDIATE
  - Contains literal furniture/table/stool art instead of a shadow.
- VA-112 `table_edge_overlay.png` — REMEDIATE
  - Oval geometry rather than canonical trapezoid.

### Sunset Island

- VA-120 `gameplay_table.png` — KEEP / QA PASS
  - Coherent warm coral/orange sunset-resin/wood surface treatment.
- VA-121 `gameplay_table_shadow.png` — REMEDIATE
  - Bright orange glowing slab/effect rather than a cast shadow.
- VA-125 `table_edge_overlay.png` — REMEDIATE
  - Rectangular frame geometry instead of the canonical trapezoid edge.

### Tiki Island

- VA-133 `gameplay_table.png` — KEEP / QA PASS
  - Coherent carved-wood Tiki treatment.
- VA-134 `gameplay_table_shadow.png` — REMEDIATE
  - Contains literal tiki bar/table/chair furniture.
- VA-138 `table_edge_overlay.png` — REMEDIATE
  - U-shaped/rounded geometry materially differs from the frozen table edge.

### Volcano Bay

- VA-146 `gameplay_table.png` — REMEDIATE
  - Geometry is correct.
  - Surface contains scenic volcano/environment imagery and excessive gameplay noise.
  - Must become restrained obsidian/basalt material with controlled lava accents.
- VA-147 `gameplay_table_shadow.png` — REMEDIATE
  - Reads as dark water/scenic effect slab, not a clean cast shadow.
- VA-151 `table_edge_overlay.png` — REMEDIATE
  - Rectangular/scenic frame geometry diverges from canonical edge authority.

---

## D. SYSTEMIC TABLE FINDINGS

### Gameplay tables
- Geometry: PASS for all 10.
- Surface-content remediation required: 5/10.
- Keep current surface assets after re-QA:
  - VA-081
  - VA-094
  - VA-107
  - VA-120
  - VA-133

### Shadows
All ten island `gameplay_table_shadow.png` assets FAIL semantic-role QA.

A table shadow must:
- read as a shadow;
- be transparent outside its intended shadow pixels;
- be low-chroma / subdued;
- contain no scenery, buildings, water scenes, furniture, tropical environment, neon slab, ice slab or decorative illustration;
- be aligned to the frozen table geometry;
- never redefine the gameplay boundary.

Remediate:
VA-030, VA-043, VA-056, VA-069, VA-082, VA-095, VA-108, VA-121, VA-134, VA-147.

### Edge overlays
All ten island `table_edge_overlay.png` assets FAIL frozen-geometry consistency.

Measured alpha IoU against VA-321 master overlay:
- Azure Bay: 22.9%
- Billionaire Island: 26.0%
- Coconut Beach: 31.1%
- Final Island: 20.9%
- Frozen Paradise: 14.9%
- Party Beach: 10.4%
- Sunny Cove: 8.8%
- Sunset Island: 22.4%
- Tiki Island: 27.8%
- Volcano Bay: 35.9%

They visually introduce rounded, oval, rectangular, U-shaped or unrelated scenic frames.

Remediate:
VA-034, VA-047, VA-060, VA-073, VA-086, VA-099, VA-112, VA-125, VA-138, VA-151.

### Global table authorities
- VA-321 `table_edge_overlay_master.png` — KEEP. It follows the frozen trapezoid concept and should be the geometry template.
- VA-322 `table_silhouette_mask.png` — PRESERVE byte-for-byte.
- `table_geometry_v1.json` — PRESERVE byte-for-byte.
- Runtime boundaries/scripts — DO NOT MODIFY.

---

# E. CONSOLIDATED REMEDIATION SCOPE

The remediation prompt must cover 32 task IDs.

Prior audit:
- VA-009
- VA-010
- VA-021
- VA-072
- VA-074
- VA-075
- VA-098

Table audit:
- VA-029, VA-030, VA-034
- VA-042, VA-043, VA-047
- VA-055, VA-056, VA-060
- VA-068, VA-069, VA-073
- VA-082, VA-086
- VA-095, VA-099
- VA-108, VA-112
- VA-121, VA-125
- VA-134, VA-138
- VA-146, VA-147, VA-151

Do not regenerate unrelated passing assets.

---

# F. ACCEPTANCE GATES

## General
- exact master-list dimensions;
- valid PNG RGBA;
- required transparency;
- no text/watermarks unless explicitly canonical;
- no V05 style reference;
- V04 masters remain primary style authority;
- one distinct purpose-specific generation/edit/derivation operation per affected non-protected asset;
- no atlas slicing.

## Table gameplay surfaces
- alpha equals the WHITE RGB region of `table_silhouette_mask.png` pixel-for-pixel;
- 0 pixels outside canonical silhouette;
- 0 missing canonical silhouette pixels;
- no blank white filler;
- no scenery/background/furniture/architecture inside the tabletop;
- clean readable material under gameplay pieces;
- island identity is expressed through material, trim and restrained motifs, not a miniature landscape.

## Table shadows
- visually reads as a shadow only;
- no scenic or decorative illustration;
- subdued/low-chroma;
- correct perspective/alignment;
- transparent background;
- does not alter playable-area geometry.

## Table edge overlays
- geometry must derive from VA-321 + protected geometry JSON/mask;
- no oval, circular, rectangular or U-shaped reinterpretation;
- playable boundary remains exactly the frozen trapezoid;
- interior remains open/transparent for gameplay;
- island styling may change material/color/decor only, not geometry.

## Specific prior findings
- VA-009/010: connectors visible across the intended 520x36 role and clearly distinct normal vs complete.
- VA-021: empty state clearly inactive relative to VA-022 filled.
- VA-098: clean Party Beach title frame center, no grey/white generation artifact.
- VA-072/074/075: Final Island strongly and consistently reads as exotic blackwood + pearl/turquoise/gold visual climax.

Finalization must not run until every remediation item passes these gates.
