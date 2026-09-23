# BEACH COCKTAILS MERGE — OWNER AUDIT REMEDIATION MASTER PROMPT V01

Repository:
https://github.com/Sekiph82/Beach-Cocktails-Merge

Branch:
codex/visual-assets-production

PRIMARY audit authority for this remediation:
https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/codex/visual-assets-production/coordination/codex_visual_assets/CODEX_VISUAL_OWNER_AUDIT_REPORT_V01.md

Also read and obey:
- coordination/codex_visual_assets/CODEX_VISUAL_ASSET_PROMPT.md
- coordination/codex_visual_assets/CODEX_VISUAL_ASSET_MASTER_LIST.md
- coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md
- coordination/codex_visual_assets/CODEX_VISUAL_ASSET_LOG.md
- coordination/codex_visual_assets/CODEX_VISUAL_PRODUCTION_MASTER_LOG.md
- coordination/codex_visual_assets/CODEX_VISUAL_PUBLISH_AND_LOG_POLICY.md
- coordination/codex_visual_assets/CODEX_VISUAL_FINALIZATION_PROMPT.md

## NON-NEGOTIABLE AUTHORITY

- Use the LIVE tracker and current remote canonical files as the source of truth.
- V04 masters are the PRIMARY visual authority.
- V05 production visuals are owner-rejected and MUST NOT be used as style references.
- Never modify or push `main`.
- Work only on `codex/visual-assets-production`.
- Do not modify gameplay/runtime boundary code.
- Do not modify protected visual geometry/reference sources.
- Use one separate purpose-specific image-generation, image-edit, or technical derivation operation for each distinct affected non-protected asset.
- Do not use atlas slicing for unrelated assets.
- Do not regenerate unrelated assets that already passed owner audit.

The owner audit was made against checkpoint:
`a07fc88524dfca6f1d8881dd1af18148c5529469`.

Before changing anything, inspect the current remote branch. If a newer canonical target has already been replaced after that checkpoint, audit the live file first and do not overwrite newer valid work merely because it appeared in the older audit report.

---

# 1. REMEDIATION SCOPE

The owner audit identified 32 task IDs requiring remediation or targeted re-QA.

## Prior visual audit findings

- VA-009 — `assets/ui_assets/campaign/island_map/level_connector.png`
- VA-010 — `assets/ui_assets/campaign/island_map/level_connector_complete.png`
- VA-021 — `assets/ui_assets/campaign/island_map/star_small_empty.png`
- VA-072 — `assets/ui_assets/campaign/islands/final_island/map_title.png`
- VA-074 — `assets/ui_assets/campaign/islands/final_island/theme_badge.png`
- VA-075 — `assets/ui_assets/campaign/islands/final_island/world_icon.png`
- VA-098 — `assets/ui_assets/campaign/islands/party_beach/map_title.png`

## Table remediation findings

### Azure Bay
- VA-029 — gameplay_table
- VA-030 — gameplay_table_shadow
- VA-034 — table_edge_overlay

### Billionaire Island
- VA-042 — gameplay_table
- VA-043 — gameplay_table_shadow
- VA-047 — table_edge_overlay

### Coconut Beach
- VA-055 — gameplay_table
- VA-056 — gameplay_table_shadow
- VA-060 — table_edge_overlay

### Final Island
- VA-068 — gameplay_table
- VA-069 — gameplay_table_shadow
- VA-073 — table_edge_overlay

### Frozen Paradise
- VA-082 — gameplay_table_shadow
- VA-086 — table_edge_overlay

### Party Beach
- VA-095 — gameplay_table_shadow
- VA-099 — table_edge_overlay

### Sunny Cove
- VA-108 — gameplay_table_shadow
- VA-112 — table_edge_overlay

### Sunset Island
- VA-121 — gameplay_table_shadow
- VA-125 — table_edge_overlay

### Tiki Island
- VA-134 — gameplay_table_shadow
- VA-138 — table_edge_overlay

### Volcano Bay
- VA-146 — gameplay_table
- VA-147 — gameplay_table_shadow
- VA-151 — table_edge_overlay

Do not automatically regenerate these passing gameplay-table surfaces unless current live QA proves they no longer pass:
- VA-081 Frozen Paradise gameplay_table
- VA-094 Party Beach gameplay_table
- VA-107 Sunny Cove gameplay_table
- VA-120 Sunset Island gameplay_table
- VA-133 Tiki Island gameplay_table

Keep as geometry authority:
- VA-321 `assets/ui_assets/tables/table_edge_overlay_master.png`

PRESERVE byte-for-byte:
- VA-322 `assets/ui_assets/tables/table_silhouette_mask.png`
- `assets/ui_assets/tables/table_geometry_v1.json`

---

# 2. TABLE GEOMETRY CONTRACT

The frozen canonical geometry is:

- viewport: 720x1280
- rear left: (130, 398)
- rear right: (590, 398)
- front right: (720, 1280)
- front left: (0, 1280)
- rear width: 460 px
- centerline x: 360
- launch y: 947
- danger y: 900

IMPORTANT:
`table_silhouette_mask.png` stores its actual table silhouette in BLACK/WHITE RGB.
Its alpha channel is fully opaque.

Therefore:
- derive the canonical silhouette from the WHITE RGB region of `table_silhouette_mask.png`;
- do NOT compare generated-table alpha against the mask file's alpha channel;
- generated `gameplay_table.png` alpha must match the WHITE RGB silhouette pixel-for-pixel.

The current audited gameplay tables all had 0 silhouette-difference pixels and 100% IoU. Preserve that exact geometry.

---

# 3. GAMEPLAY TABLE SURFACE REMEDIATION

Affected:
VA-029, VA-042, VA-055, VA-068, VA-146.

Each must remain exactly 720x1280 RGBA and use the exact canonical trapezoid alpha silhouette.

The table content must be a TABLE MATERIAL/SURFACE treatment, not a miniature environment.

Forbidden inside the table surface:
- scenic backgrounds;
- beaches or resort vistas;
- architecture;
- buildings;
- marinas/yachts as scene illustrations;
- paths/boardwalk scenes;
- literal furniture;
- horizon/sky;
- volcano landscapes;
- unexplained blank/white filler;
- visual noise that competes with gameplay pieces.

Island material authority:

### Azure Bay — VA-029
Sapphire marina/coastal-luxury MATERIAL language.
Use refined wood/stone/lacquer/inlay with restrained sapphire/turquoise nautical accents.
No marina scene.
No blank white trapezoid.

### Billionaire Island — VA-042
Marble + walnut + gold + yacht-resort luxury MATERIAL language.
Premium, clean, restrained.
No resort scene.
No blank white region.

### Coconut Beach — VA-055
Coconut grove / woven / palm / organic wood MATERIAL language.
Use wood grain, rope/woven accents, coconut/palm motifs only as surface/trim.
No boardwalk/beach scene.

### Final Island — VA-068
Exotic blackwood + pearl/turquoise/gold visual climax.
Must feel like the ultimate final-island table.
No tropical landscape inserted into the tabletop.
Must remain clearly distinct from Billionaire and Sunset.

### Volcano Bay — VA-146
Restrained obsidian/basalt MATERIAL with controlled lava accents.
No volcano landscape.
No scenic water/rocks.
No excessive glowing gameplay noise.

After regeneration:
- exact alpha silhouette vs WHITE RGB mask: 0 differing pixels;
- no missing silhouette pixels;
- no pixels outside silhouette;
- exact 720x1280;
- RGBA;
- transparent outside silhouette.

---

# 4. TABLE SHADOW REMEDIATION

Affected:
VA-030, VA-043, VA-056, VA-069, VA-082, VA-095, VA-108, VA-121, VA-134, VA-147.

The current owner audit found that ALL TEN shadow files fail semantic-role QA.

A `gameplay_table_shadow.png` is a SHADOW asset, not an island illustration.

Requirements:
- transparent 720x1280 RGBA;
- visually reads as a cast/contact shadow only;
- subdued, low-chroma, mostly neutral;
- soft perspective-appropriate falloff;
- aligned with the frozen table footprint;
- must support table grounding without covering gameplay;
- must not redefine or extend the playable boundary.

Forbidden:
- island scenery;
- water or beach illustration;
- buildings;
- yachts;
- resort views;
- furniture;
- tiki bar/chairs;
- neon cyan/magenta slab;
- bright orange slab;
- ice/water slab;
- decorative frame;
- scenic volcano/water art.

Do not derive the shadow by simply darkening an island V04 scene.
Create the correct functional shadow role.

---

# 5. TABLE EDGE OVERLAY REMEDIATION

Affected:
VA-034, VA-047, VA-060, VA-073, VA-086, VA-099, VA-112, VA-125, VA-138, VA-151.

The owner audit found ALL TEN island edge overlays geometrically inconsistent with the frozen system.

Current measured alpha IoU against VA-321:
- Azure Bay 22.9%
- Billionaire Island 26.0%
- Coconut Beach 31.1%
- Final Island 20.9%
- Frozen Paradise 14.9%
- Party Beach 10.4%
- Sunny Cove 8.8%
- Sunset Island 22.4%
- Tiki Island 27.8%
- Volcano Bay 35.9%

This is not acceptable.

Use:
- VA-321 `table_edge_overlay_master.png`
- protected `table_silhouette_mask.png`
- protected `table_geometry_v1.json`

as the geometry authority.

The island overlay may change:
- material;
- trim;
- texture;
- color;
- restrained theme ornamentation.

It may NOT change:
- rear edge location;
- side-edge slope;
- front edge;
- playable silhouette;
- perspective;
- boundary shape.

Forbidden overlay reinterpretations:
- oval;
- circular;
- rounded-ring;
- rectangular;
- U-shaped;
- decorative scene frame;
- scenery replacing an edge.

The overlay interior must remain open/transparent for gameplay.

Do not modify VA-321 itself unless a new owner audit explicitly says it failed.

---

# 6. PRIOR AUDIT REMEDIATION

## VA-009 / VA-010 — island-map connectors
- preserve exact 520x36 role;
- visible connector should meaningfully use the intended span;
- no tiny isolated fragment floating in a mostly empty canvas;
- normal and complete variants must be immediately distinguishable at runtime scale;
- completed state may use a stronger lit/gold/turquoise completion treatment while preserving the same connector language.

## VA-021 — star_small_empty
Compare directly against VA-022 `star_small_filled.png`.

The empty state must:
- clearly read inactive/unfilled;
- use a subdued pearl/cream/low-luminance interior;
- retain family identity;
- not look like a slightly dimmed filled gold star.

Check at 128x128 and at smaller runtime display size.

## VA-098 — Party Beach map_title
- remove the grey/white cloudy generation artifact from the center;
- preserve premium neon tropical nightlife identity;
- keep central runtime title area clean and intentional;
- do not bake runtime title text into the asset.

## VA-072 / VA-074 / VA-075 — Final Island identity
Remediate these as one coherent visual family while still using separate purpose-specific operations.

Required identity:
EXOTIC BLACKWOOD + PEARL + TURQUOISE + GOLD VISUAL CLIMAX.

Must be unmistakably the final/ultimate island.
Must remain distinct from:
- Billionaire Island luxury;
- Sunset Island golden-hour/coral aesthetic.

Do not solve this by adding text.
Use material, ornament, silhouette and visual hierarchy.

---

# 7. TRACKER AND LOGGING

Before remediating:
1. fetch the LIVE tracker and LIVE canonical target;
2. determine whether the audited defect still exists in the current remote file;
3. if a newer file already genuinely passes the owner acceptance criteria, document that and do not overwrite it.

For every target that still fails:
- reopen/uncheck the task in the dedicated visual tracker while remediation is active;
- record remediation reason in the official asset log and production master log;
- perform the separate purpose-specific generation/edit/derivation;
- inspect the result visually;
- run required dimension/alpha/geometry/semantic QA;
- promote only the accepted candidate to the canonical path;
- commit;
- push only to `codex/visual-assets-production`;
- verify remote canonical path and remote HEAD;
- only then mark the task complete again.

For replaced assets log:
- task ID;
- old canonical blob SHA when available;
- new canonical blob SHA;
- V04 authority used;
- generation/edit/technical derivation method;
- rejected attempts;
- exact QA performed;
- implementation commit;
- remote branch HEAD.

Do not erase historic log entries.

---

# 8. RATE-LIMIT POLICY

If image generation returns HTTP 429 `usage_limit_reached`:
- do not consume reset credits;
- do not promote ambiguous partial output;
- do not mark blocked remediation tasks complete;
- record the blocker in BOTH official logs;
- commit/push completed safe work only;
- stop at a clean resumable checkpoint.

---

# 9. REMEDIATION QA GATE

Do not declare this remediation complete until all 32 scoped tasks have either:
A) been replaced and passed QA, or
B) been explicitly re-audited on the LIVE branch and documented as already corrected by newer work.

Required final evidence:

### General
- exact master-list dimensions;
- valid PNG;
- correct RGBA/transparency;
- no accidental text/watermark;
- V04 visual authority preserved;
- no V05 reference use;
- unrelated passing assets untouched.

### Tables
- five remediated gameplay surfaces contain material, not scenery;
- ten shadows read as shadows only;
- ten edge overlays follow frozen geometry;
- gameplay-table alpha exactly matches WHITE RGB mask silhouette;
- `table_geometry_v1.json` unchanged;
- `table_silhouette_mask.png` unchanged;
- VA-321 unchanged unless explicitly authorized;
- runtime boundary code unchanged.

Create a remediation-specific QA/contact preview only as evidence after canonical assets are final.
Do not use generated contact sheets as source art.

---

# 10. FINALIZATION ORDER

Do NOT start finalization while remediation is incomplete.

After every scoped remediation passes:
1. re-run state-pair QA for VA-009/010 and VA-021/022;
2. re-run Final Island family comparison against its V04 master and against Billionaire/Sunset;
3. re-run ten-island table family QA;
4. update both official logs and tracker;
5. finish any remaining ordinary LIVE tracker production tasks;
6. derive deferred contact sheets from FINAL canonical assets only;
7. execute `CODEX_VISUAL_FINALIZATION_PROMPT.md`;
8. verify full remote canonical set and remote HEAD.

Never modify or push `main`.
