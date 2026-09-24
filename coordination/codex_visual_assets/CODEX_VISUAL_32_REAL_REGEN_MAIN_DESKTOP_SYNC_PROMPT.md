# SUPERSEDED — DO NOT EXECUTE

This historical prompt is invalid for current table production because it relies on V1 geometry and/or pre-V2 Azure Bay assumptions.

Current mandatory authority:
- https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md
- https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/tables/table_geometry_v2.json

Do not execute this prompt unless the owner explicitly requests the historical workflow.

---

# BEACH COCKTAILS MERGE — 32 ASSET REAL IMAGE REGENERATION + MAIN MERGE + DESKTOP SYNC

Repository:
https://github.com/Sekiph82/Beach-Cocktails-Merge

Working branch:
codex/visual-assets-production

Desktop destination after completion:
C:\Users\sekip\Desktop\Beach Cocktails - Merge

## TASK

Regenerate ONLY the 32 assets listed below and replace the current PNG files at the exact same canonical paths.

These 32 assets have ALREADY been audited by the owner and ChatGPT.
The defects are already known.

DO NOT:
- audit them again;
- investigate whether they are actually wrong;
- inspect the rest of the repository;
- perform QA or polish passes;
- run finalization;
- read coordination logs or trackers;
- analyze unrelated assets;
- modify gameplay/runtime code while generating the assets.

The current R01 technically-derived replacements are NOT accepted.
All 32 listed assets must receive NEW visual artwork.

## MANDATORY IMAGE-GENERATION RULE

For EVERY asset below:

1. Use one REAL image-generation operation.
2. Generate NEW artwork specifically for that asset.
3. Do not reuse the current rejected PNG as the artwork source.
4. Replace the existing canonical PNG with the newly generated result.
5. Move immediately to the next listed asset.

32 listed assets = 32 separate real image-generation operations.

An asset is NOT complete if no real image-generation operation occurred for it.

FORBIDDEN AS A SUBSTITUTE FOR IMAGE GENERATION:
- Python-generated artwork
- Pillow-generated artwork
- procedural drawing
- recoloring the current asset
- filtering the current asset
- rematerializing the current asset
- compositing existing artwork into a replacement
- code-generated gradients/shapes
- technical derivation
- copying another island's asset
- reusing one generated image for multiple listed assets

Technical post-processing is allowed ONLY AFTER a new image has been generated, and ONLY for:
- exact resizing/cropping;
- transparent-background cleanup;
- applying the required table silhouette/edge mask;
- saving the final PNG at the required canonical path.

Technical processing must not create the artwork itself.

## VISUAL AUTHORITY

Use the matching V04 island master as the visual reference when an island-specific asset is involved.

V04 masters are the PRIMARY visual authority.
Do NOT use V05 production artwork as a visual reference.

Preserve the established premium tropical mobile-game visual language.

# ASSETS

## VA-009
Path:
assets/ui_assets/campaign/island_map/level_connector.png

Problem:
The current connector uses too little of its wide canvas and reads as a tiny isolated fragment.

Generate:
A clean premium tropical level-map connector spanning the useful width of the 520x36 canvas.
It must read clearly at mobile scale.
Turquoise/gold tropical UI language.
No text.
Transparent background.

## VA-010
Path:
assets/ui_assets/campaign/island_map/level_connector_complete.png

Problem:
The completed connector is too similar to the normal connector and also too visually sparse.

Generate:
A completed-state version of the same connector family.
Use the useful horizontal span of the 520x36 canvas.
Make completion immediately visible through brighter gold/turquoise illumination or a premium completed treatment.
It must remain visually related to VA-009 but clearly distinct.
No text.
Transparent background.

## VA-021
Path:
assets/ui_assets/campaign/island_map/star_small_empty.png

Problem:
The current empty star still looks too gold and too filled.

Generate:
A premium tropical empty/inactive star.
Keep the established star-family silhouette, but make the center clearly unfilled/inactive using subdued pearl, cream, muted metal or low-luminance treatment.
It must be immediately distinguishable from star_small_filled.png.
Transparent background.

# AZURE BAY

## VA-029
Path:
assets/ui_assets/campaign/islands/azure_bay/gameplay_table.png

Problem:
The current table has a large blank/white region and does not provide a complete usable table surface.

Generate:
A completely new Azure Bay gameplay table surface.
Sapphire marina/coastal-luxury material language.
Refined premium wood, stone or lacquer.
Turquoise/sapphire inlay.
Restrained nautical-luxury accents.
Elegant, clean gameplay surface.

No marina scenery, yachts as scene illustrations, buildings, horizon, beach/environment scenery or blank white areas.

This is a TABLE SURFACE, not a miniature landscape.
Fit the generated artwork into the existing frozen gameplay-table silhouette exactly.

## VA-030
Path:
assets/ui_assets/campaign/islands/azure_bay/gameplay_table_shadow.png

Problem:
The current asset contains marina/yacht scenery instead of a table shadow.

Generate:
A new subtle Azure Bay table cast/contact shadow.
Soft, premium, restrained cool-neutral shadow.
No scenery, objects, decorations or water illustration.
Transparent background.
Aligned to the existing gameplay table footprint.

## VA-034
Path:
assets/ui_assets/campaign/islands/azure_bay/table_edge_overlay.png

Problem:
The current overlay uses the wrong rounded/frame geometry.

Generate:
A new Azure Bay edge treatment.
Premium sapphire/turquoise coastal-luxury trim with restrained gold accents.
Keep the existing canonical table-edge shape exactly.
Do not create an oval, rounded ring or independent frame.

# BILLIONAIRE ISLAND

## VA-042
Path:
assets/ui_assets/campaign/islands/billionaire_island/gameplay_table.png

Problem:
The current table contains a large blank/white region and incomplete surface artwork.

Generate:
A completely new Billionaire Island gameplay table surface.
Dark walnut, premium marble, restrained polished gold.
Ultra-luxury yacht-resort material language.
Sophisticated, expensive and clean.

No resort scenery, yacht illustration, landscape or blank white area.
This must be a usable gameplay TABLE MATERIAL.

## VA-043
Path:
assets/ui_assets/campaign/islands/billionaire_island/gameplay_table_shadow.png

Problem:
The current file contains a luxury resort scene instead of a shadow.

Generate:
A completely new soft premium table cast/contact shadow.
Subtle warm-neutral tone.
No scenery, decoration or objects.
Transparent background.

## VA-047
Path:
assets/ui_assets/campaign/islands/billionaire_island/table_edge_overlay.png

Problem:
The current overlay geometry does not follow the canonical gameplay table.

Generate:
A new Billionaire Island canonical edge overlay.
Dark walnut + marble + elegant gold luxury trim.
Keep the existing canonical table-edge shape exactly.
Only the visual material/style should change.

# COCONUT BEACH

## VA-055
Path:
assets/ui_assets/campaign/islands/coconut_beach/gameplay_table.png

Problem:
The current asset contains a boardwalk/beach/environment composition instead of an isolated gameplay table surface.

Generate:
A new Coconut Beach gameplay table.
Natural tropical hardwood, woven/rattan accents, rope details, coconut/palm-inspired restrained surface motifs, warm organic resort craftsmanship.

No beach scene, boardwalk scene, buildings, landscape or furniture illustration.
The gameplay area must remain visually clean.

## VA-056
Path:
assets/ui_assets/campaign/islands/coconut_beach/gameplay_table_shadow.png

Problem:
The current file contains beach/boardwalk scenery instead of a shadow.

Generate:
A completely new soft warm-neutral table cast/contact shadow.
No scenery, palm illustration or objects.
Transparent background.

## VA-060
Path:
assets/ui_assets/campaign/islands/coconut_beach/table_edge_overlay.png

Problem:
The current asset is an independent decorative frame and does not preserve the canonical table-edge geometry.

Generate:
A new Coconut Beach edge overlay.
Organic tropical hardwood, rope, woven/rattan and restrained coconut accents.
Use the existing canonical table-edge shape exactly.
Do not invent a new frame shape.

# FINAL ISLAND

## VA-068
Path:
assets/ui_assets/campaign/islands/final_island/gameplay_table.png

Problem:
The current table contains scenic/environment imagery and does not strongly express Final Island identity.

Generate:
A completely new Final Island gameplay table surface.

Required identity:
EXOTIC BLACKWOOD + PEARL + TURQUOISE + GOLD.

This must feel like the visual climax and ultimate table of the game.
Premium exotic blackwood base.
Pearl highlights/inlays.
Turquoise gemstone or enamel accents.
Elegant gold detailing.

No landscape, buildings, waterfall, tropical scenery or miniature environment.
The center must remain clean enough for gameplay pieces.

## VA-069
Path:
assets/ui_assets/campaign/islands/final_island/gameplay_table_shadow.png

Problem:
The current asset contains scenic/platform artwork instead of a shadow.

Generate:
A completely new sophisticated neutral/deep cast/contact table shadow.
No scenery or decorative illustration.
Transparent background.

## VA-072
Path:
assets/ui_assets/campaign/islands/final_island/map_title.png

Problem:
The current image looks like generic tropical luxury and does not clearly communicate Final Island.

Generate:
A completely new Final Island map-title frame.
Exotic blackwood + pearl + turquoise + gold visual climax.
It must look more prestigious and final than every previous island.
Do not bake title text into the image.
Keep the central runtime-title area clean.

## VA-073
Path:
assets/ui_assets/campaign/islands/final_island/table_edge_overlay.png

Problem:
The current edge artwork does not follow the canonical table geometry.

Generate:
A new Final Island canonical edge overlay.
Exotic blackwood + pearl + turquoise gemstones/enamel + elegant gold.
This should be the richest table-edge treatment in the game.
Do not alter the canonical table shape.

## VA-074
Path:
assets/ui_assets/campaign/islands/final_island/theme_badge.png

Problem:
The current badge looks too generic and does not communicate the final/ultimate island strongly enough.

Generate:
A completely new Final Island theme badge.
Exotic blackwood, pearl, turquoise gemstone and gold.
Rare, prestigious and climactic.
Clearly different from Billionaire Island and Sunset Island.
Transparent background.

## VA-075
Path:
assets/ui_assets/campaign/islands/final_island/world_icon.png

Problem:
The current world icon looks too similar to generic luxury/sunset tropical imagery.

Generate:
A completely new Final Island world icon.
Exotic blackwood + pearl + turquoise + gold ultimate-island visual language.
It should communicate the final prestigious destination at small mobile-map scale.
Transparent background.

# FROZEN PARADISE

## VA-082
Path:
assets/ui_assets/campaign/islands/frozen_paradise/gameplay_table_shadow.png

Problem:
The current asset looks like a glowing ice/water slab instead of a table shadow.

Generate:
A new subtle cool blue-grey cast/contact table shadow.
Soft and restrained.
No ice landscape, water slab or crystal scene objects.
Transparent background.

## VA-086
Path:
assets/ui_assets/campaign/islands/frozen_paradise/table_edge_overlay.png

Problem:
The current overlay creates an independent icy rectangular/ring frame.

Generate:
A new Frozen Paradise edge overlay using the canonical table-edge geometry.
Crystalline ice, frosted silver, subtle sapphire/ice-blue highlights.
Keep the existing table shape.
Do not create a new rectangular or circular frame.

# PARTY BEACH

## VA-095
Path:
assets/ui_assets/campaign/islands/party_beach/gameplay_table_shadow.png

Problem:
The current asset looks like a bright cyan/magenta neon slab instead of a shadow.

Generate:
A new subtle table cast/contact shadow.
A very restrained cool violet/blue ambience is acceptable, but it must read as a SHADOW.
No neon platform, glowing water slab or scenery.
Transparent background.

## VA-098
Path:
assets/ui_assets/campaign/islands/party_beach/map_title.png

Problem:
The current title frame has a grey/white cloudy generation artifact in the center.

Generate:
A completely new Party Beach map-title frame.
Premium neon tropical nightlife.
Dark tropical luxury.
Cyan, magenta and subtle gold highlights.
Club/resort energy.
Keep the central runtime-title region clean.
No cloudy grey artifact.
No baked-in title text.

## VA-099
Path:
assets/ui_assets/campaign/islands/party_beach/table_edge_overlay.png

Problem:
The current overlay changes the table into an oval/ring geometry.

Generate:
A new Party Beach edge overlay using the exact canonical table-edge shape.
Premium tropical nightlife trim with restrained neon cyan/magenta accents.
Do not alter table geometry.

# SUNNY COVE

## VA-108
Path:
assets/ui_assets/campaign/islands/sunny_cove/gameplay_table_shadow.png

Problem:
The current image contains literal table/furniture/stool artwork instead of a shadow.

Generate:
A completely new soft warm-neutral cast/contact shadow.
No furniture, objects or scenery.
Transparent background.

## VA-112
Path:
assets/ui_assets/campaign/islands/sunny_cove/table_edge_overlay.png

Problem:
The current overlay uses oval geometry instead of the canonical table shape.

Generate:
A new Sunny Cove edge overlay using the existing canonical table-edge geometry.
Bright sunlit tropical wood, polished resort craftsmanship, subtle turquoise/gold accents.
Do not redesign the table shape.

# SUNSET ISLAND

## VA-121
Path:
assets/ui_assets/campaign/islands/sunset_island/gameplay_table_shadow.png

Problem:
The current asset is a bright orange glowing slab rather than a functional table shadow.

Generate:
A new subtle warm-neutral cast/contact shadow.
A very slight warm sunset tint is acceptable.
It must still read clearly as a shadow.
No glowing platform or scenery.
Transparent background.

## VA-125
Path:
assets/ui_assets/campaign/islands/sunset_island/table_edge_overlay.png

Problem:
The current overlay creates a rectangular decorative frame unrelated to the canonical geometry.

Generate:
A new Sunset Island edge overlay using the canonical table-edge shape.
Coral, warm gold, sunset-orange luxury accents and elegant tropical craftsmanship.
Do not change table geometry.

# TIKI ISLAND

## VA-134
Path:
assets/ui_assets/campaign/islands/tiki_island/gameplay_table_shadow.png

Problem:
The current image contains a literal tiki bar/table/chairs instead of a shadow.

Generate:
A completely new soft warm brown/neutral cast/contact shadow.
No furniture, tiki objects or scenery.
Transparent background.

## VA-138
Path:
assets/ui_assets/campaign/islands/tiki_island/table_edge_overlay.png

Problem:
The current overlay creates a rounded/U-shaped independent structure instead of following the gameplay table.

Generate:
A new Tiki Island edge overlay using the canonical table-edge geometry.
Carved tropical hardwood, bamboo/rope details and restrained tiki carving motifs.
Do not alter the existing table shape.

# VOLCANO BAY

## VA-146
Path:
assets/ui_assets/campaign/islands/volcano_bay/gameplay_table.png

Problem:
The current table contains volcano/environment scenery and excessive visual noise.

Generate:
A completely new Volcano Bay gameplay table surface.
Premium dark obsidian, textured basalt, restrained lava-red/orange fissure accents, subtle turquoise contrast where appropriate.
Dramatic but gameplay-readable.

No volcano landscape, water scene, cliffs, horizon or miniature environment.
This must be a TABLE MATERIAL.

## VA-147
Path:
assets/ui_assets/campaign/islands/volcano_bay/gameplay_table_shadow.png

Problem:
The current asset looks like dark water/scenic terrain rather than a shadow.

Generate:
A completely new deep charcoal cast/contact shadow.
Soft edges.
No scenery, lava landscape or water.
Transparent background.

## VA-151
Path:
assets/ui_assets/campaign/islands/volcano_bay/table_edge_overlay.png

Problem:
The current overlay forms an unrelated rectangular/scenic frame.

Generate:
A new Volcano Bay edge overlay using the canonical table-edge geometry.
Obsidian/basalt edge construction with restrained glowing lava accents and premium tropical detailing.
Do not change the frozen table geometry.

# TABLE GEOMETRY

For table-related assets only:

Existing table gameplay geometry is frozen and must not change.

Use:
assets/ui_assets/tables/table_silhouette_mask.png
assets/ui_assets/tables/table_edge_overlay_master.png
assets/ui_assets/tables/table_geometry_v1.json

ONLY as geometry/masking authorities.

Do not modify those authority files.

For gameplay_table.png:
generate the NEW artwork first, then fit/mask the generated artwork into the existing canonical table silhouette.

For table_edge_overlay.png:
generate NEW island-specific edge artwork first, then fit/mask it into the canonical edge geometry.

For gameplay_table_shadow.png:
generate a NEW shadow artwork for each island and align it with the same table footprint.

Do not use these geometry files to procedurally create the artwork itself.

# IMAGE REPLACEMENT + GIT

Replace ONLY the 32 canonical PNG files listed above while doing the regeneration.

Do not update trackers.
Do not update coordination logs.
Do not create audit reports.
Do not run finalization.

After all 32 NEW images have been generated and written:

1. Commit the 32 replacements together on:
   codex/visual-assets-production

2. Push codex/visual-assets-production once.

# MERGE TO MAIN

ONLY AFTER all 32 real image-generation operations have completed successfully and the replacement commit is pushed:

1. Fetch the latest remote main.
2. Merge codex/visual-assets-production into main.
3. Preserve the regenerated 32 assets and preserve any unrelated newer valid main changes.
4. Do not redo the image work during the merge.
5. Push the merged main to GitHub.

If the 32-image generation job is incomplete because of HTTP 429, DO NOT merge to main.

# DESKTOP EXACT SYNC

ONLY AFTER the merged main has been successfully pushed to GitHub:

Make this exact local folder:

C:\Users\sekip\Desktop\Beach Cocktails - Merge

match the newly pushed remote GitHub main branch exactly.

The final desktop folder must be a clean exact checkout of:
origin/main

If the folder already exists, synchronize/replace it so there are:
- no stale files from an older version;
- no untracked files;
- no uncommitted local differences;
- no missing repository files.

A fresh clone to that exact path is acceptable.
A hard reset + clean to origin/main is also acceptable.

Final required state:
- desktop HEAD == remote origin/main HEAD;
- git status is clean;
- desktop repository contents match GitHub main exactly.

# HTTP 429

If image generation hits HTTP 429 / usage_limit_reached:

STOP.

Do not create a code-generated substitute.
Do not technically derive the missing image.
Do not mark ungenerated assets complete.
Do not merge anything to main.
Do not sync the desktop folder.

Commit/push only genuinely generated replacements completed before the limit was reached.

Report:
- number of real image-generation operations completed;
- task IDs completed;
- last successfully generated task ID;
- first remaining task ID;
- commit SHA;
- HTTP 429 status.

# SUCCESS REPORT

If all 32 assets complete successfully, report only:

- real image-generation operations completed: 32/32;
- task IDs completed;
- visual branch replacement commit SHA;
- main merge commit SHA / final main HEAD;
- desktop HEAD;
- desktop path:
  C:\Users\sekip\Desktop\Beach Cocktails - Merge
- confirmation that desktop HEAD equals remote main HEAD;
- HTTP 429: yes/no.

Do nothing else.
