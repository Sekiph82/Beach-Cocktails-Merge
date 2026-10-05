# BCM-M21-001 — Owner-First World Map Visual Preview Prompt V02

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

GitHub:
`https://github.com/Sekiph82/Beach-Cocktails-Merge`

Branch:
`main`

## FIRST RULE

**DO NOT IMPLEMENT THE WORLD MAP YET.**

The owner wants to see the exact World Map composition you intend to build BEFORE any production code, scene, data, hitbox, navigation, or test changes.

Your entire job in this run is:

1. synchronize safely;
2. use the owner-supplied background PNG;
3. use the existing World Map island/assets already in the repository;
4. produce the proposed 720×1280 final World Map visual;
5. publish the preview;
6. STOP for owner approval.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/OWNER_F5_REJECTION_V03.md`
4. `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_OWNER_PREVIEW_CRITERIA_V02.md`
5. current contents of `assets/ui_assets/campaign/world_map/`
6. `data/campaign/islands.json` read-only
7. `scripts/campaign/world_map_controller.gd` read-only
8. `scripts/campaign/island_entry.gd` read-only

Root `TASKS.md` is read-only.

## Owner background

The owner has supplied a new 720×1280 ocean/sky PNG.

Required path:

`assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v01.png`

Use that exact image as the background.

Do not recreate it.
Do not alter it.
Do not use the old baked-island `world_map_background.png` as the preview background.

If this owner file is missing, do not improvise. Stop with:

`OWNER_WORLD_MAP_BACKGROUND_REQUIRED`

## Existing island assets

Use the existing current transparent PNGs:

- sunny_cove.png
- tiki_island.png
- azure_bay.png
- coconut_beach.png
- sunset_island.png
- party_beach.png
- frozen_paradise.png
- volcano_bay.png
- billionaire_island.png
- final_island.png

Progression order must visually remain:

Sunny Cove
→ Tiki Island
→ Azure Bay
→ Coconut Beach
→ Sunset Island
→ Party Beach
→ Frozen Paradise
→ Volcano Bay
→ Billionaire Island
→ Final Island

You may use the existing route, marker, label, compass, boat, cloud and title-panel PNGs if they improve the composition.

## Design objective

Create the actual visual composition you propose to implement later.

This should look like a production mobile World Map, not a wireframe.

Use the owner's background as the full canvas.

The upper sky/horizon/sun area should keep breathing room.

Arrange the ten islands through the ocean in a coherent flowing progression. Prefer a visually natural serpentine journey with good spacing over rigid rows.

Sunny Cove should immediately read as the starting/current island.

Future islands should remain recognizable even when represented as locked/future.

Route graphics must help progression readability without dominating the islands.

Do not add debug boxes, hitboxes, coordinate labels, or engineering overlays to the primary preview PNG.

## Required preview

Generate:

`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/owner-preview-v02/WORLD_MAP_OWNER_PREVIEW_V02.png`

Exact dimensions:
720×1280.

Also generate:

`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/owner-preview-v02/WORLD_MAP_OWNER_PREVIEW_LAYOUT_V02.json`

The JSON is informational only and records the visual positions used in the preview.

## CRITICAL OWNER GATE

Before owner approval you MUST NOT change:

- scripts/campaign/world_map_controller.gd
- scripts/campaign/island_entry.gd
- scripts/campaign/campaign_navigation_controller.gd
- scripts/campaign/island_map_controller.gd
- scenes/campaign/WorldMapScene.tscn
- data/campaign/islands.json
- production map_position values
- navigation/hitbox logic
- World Map production tests
- gameplay/campaign code
- root TASKS.md

This run is VISUAL PREVIEW ONLY.

You may create a preview-generation helper inside the evidence/session area if needed. Do not wire that helper into production.

If the owner background file is currently untracked locally, include that exact source PNG in the preview publication commit so GitHub contains the owner-selected background.

## Publication

Commit/push only:
- owner background asset if newly supplied/untracked;
- preview PNG;
- preview layout JSON;
- optional preview-only generation helper/evidence;
- builder preview log.

Create:

`docs/codex-logs/CODEX_LOG_M21_WORLD_MAP_OWNER_PREVIEW_V02.md`

The log must explicitly prove no production World Map code/scene/data files changed.

Verify:

`git status --short` → empty

local HEAD = origin/main = remote main

ahead/behind = 0/0

## STOP

After publishing the preview, do not implement anything else.

Return the exact path/link of the preview to the owner and finish exactly:

`AWAITING_OWNER_WORLD_MAP_VISUAL_APPROVAL_V02`

Wait for explicit owner approval before any production implementation.
