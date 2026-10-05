# BCM-M21-001 — Owner-Approved World Map Production Integration V05

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

GitHub:
`https://github.com/Sekiph82/Beach-Cocktails-Merge`

Branch:
`main`

## Mission

Implement the **owner-approved V04 World Map preview** as the real production World Map and restore real-input Sunny Cove → Island Map navigation.

The visual design phase is finished.

Do not redesign the approved World Map.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/OWNER_WORLD_MAP_VISUAL_ACCEPTANCE_V04.md`
4. `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_PRODUCTION_CRITERIA_V05.md`
5. accepted preview:
   `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/owner-preview-v02/WORLD_MAP_OWNER_PREVIEW_V02.png`
6. accepted layout:
   `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/owner-preview-v02/WORLD_MAP_OWNER_PREVIEW_LAYOUT_V02.json`
7. `scripts/campaign/world_map_controller.gd`
8. `scripts/campaign/island_entry.gd`
9. `scripts/campaign/campaign_navigation_controller.gd`
10. `scripts/campaign/island_map_controller.gd`
11. `scenes/campaign/WorldMapScene.tscn`
12. `data/campaign/islands.json`
13. `tests/m12_world_map_probe.gd`
14. `tests/m13_island_map_probe.gd`
15. `tests/m20_app_shell_probe.gd`

Root `TASKS.md` is read-only.

## Sync first

Before implementation:
- `git status --short --branch`
- `git remote -v`
- `git fetch origin main`
- `git rev-list --left-right --count HEAD...origin/main`

Synchronize under AGENTS rules.

Do not begin from a divergent or dirty ambiguous checkout.

## Frozen visual authority

Owner-approved preview:
`WORLD_MAP_OWNER_PREVIEW_V02.png`

Owner-selected background:
`assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v02.png`

Accepted preview SHA-256:
`d2c9693f5040a5a67b9292a07a0b19873840b23f842d3e6d5e44954760d8895f`

The owner explicitly said the V04 result is excellent and must stay this way.

Therefore:
- do not move the title back over the ocean;
- do not normalize island sizes;
- do not return to rows/columns;
- do not move Sunny Cove away from the upper-right start;
- do not redesign the route;
- do not remove the accepted clouds/boat composition unless a technical input fix requires a non-visible node/input change;
- do not substitute another background.

## Implement the approved composition

Build the production World Map from separate runtime assets.

Use:
- exact owner V02 background;
- existing ten island PNGs;
- existing route assets;
- existing title panel/frame;
- existing clouds;
- existing boat;
- existing compass/back controls as appropriate.

Do NOT flatten the accepted preview into one clickable bitmap.

Do NOT restore the rejected baked-map architecture.

The visible island must be the click/touch target.

## Exact canonical 720×1280 island layout

Use the accepted V04 layout exactly within locked tolerance:

- Sunny Cove: center 540,300; size 225×225; label 540,392
- Tiki Island: center 175,440; size 183×183; label 175,510
- Azure Bay: center 485,545; size 234×234; label 485,642
- Coconut Beach: center 145,645; size 192×192; label 145,720
- Sunset Island: center 410,765; size 213×213; label 410,850
- Party Beach: center 610,870; size 186×186; label 610,940
- Frozen Paradise: center 400,1020; size 228×228; label 400,1112
- Volcano Bay: center 180,920; size 207×207; label 180,1003
- Billionaire Island: center 180,1180; size 177×177; label 180,1247
- Final Island: center 615,1178; size 201×201; label 615,1257

Preserve aspect ratio.

Do not make all islands equal size.

## One layout authority

Keep one canonical layout record per island.

Do not hardcode one center in data, another in IslandEntry, and another hitbox in WorldMapController.

The same record/transform must drive:
- visible art center;
- visible art size;
- hitbox;
- label;
- route anchor.

The evidence JSON is reference evidence, not a production dependency.

## Fix the Sunny Cove blocker through real input

The owner previously could not open Sunny Cove by clicking the production World Map.

First reproduce/trace the current input chain if still reproducible.

Then fix only the actual broken seam.

Required final chain:

visible Sunny Cove art
→ real viewport mouse/touch event
→ IslandEntry pressed
→ WorldMapController selection
→ island_map_requested("sunny_cove")
→ CampaignNavigationController.show_island_map("sunny_cove")
→ IslandMapController.configure_island(...)
→ visible Sunny Cove Island Map with 100 level buttons.

A direct `select_island("sunny_cove")` call is not proof.

Pay special attention to decorative Control/TextureRect mouse filters. Clouds, title, boat, route art, overlays and labels must not steal island input.

## Preserve all non-World-Map truth

Do not alter:
- gameplay physics;
- R04 gameplay surfaces/geometries;
- scoring;
- To-Go;
- VIP;
- campaign rewards;
- level data;
- no-timer ruling;
- save schema;
- island ids/order/unlock semantics;
- M22+ GameFeelFlow/Saltmire work.

## Tests and evidence

Implement/update the focused World Map production test and stale M12 baked-map expectations.

Use actual input events for Sunny Cove.

Run every test in the locked V05 criteria.

Render fresh 720×1280 production screenshots from the actual runtime World Map.

Create:
`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/production-v05/`

Create:
`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/WORLD_MAP_PRODUCTION_LAYOUT_V05.json`

Create:
`docs/codex-logs/CODEX_LOG_M21_WORLD_MAP_PRODUCTION_V05.md`

## Important acceptance boundary

You may verify and report technical/visual evidence.

You may NOT:
- self-approve owner visual parity;
- mark BCM-M21-001 complete;
- edit root TASKS.md;
- start BCM-M21-006.

After implementation, commit and push all intended files.

Verify:
- `git status --short` empty;
- local HEAD = origin/main = remote main;
- ahead/behind 0/0.

Finish exactly:

`AWAITING_GPT_M21_WORLD_MAP_PRODUCTION_AUDIT_V05`
