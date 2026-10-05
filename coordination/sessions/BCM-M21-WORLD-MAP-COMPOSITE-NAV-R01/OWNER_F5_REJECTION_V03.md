# BCM-M21 Owner F5 Rejection V03 / Composite World Map Ruling

Date: 2026-10-05
Status: **OWNER_F5_REJECTED_V03**

## Owner checklist result

1. Desktop review window / canonical viewport: **PASS**
2. World Map: **FAIL**
   - many islands are visually in the wrong places;
   - current baked-background + separate hotspot architecture is rejected.
3. Sunny Cove Island Map opening: **FAIL**
   - Sunny Cove does not open from the production World Map.
4-10. **NOT EVALUATED**
   - owner stopped because Sunny Cove Island Map could not be opened.

## New owner World Map direction

The World Map must be rebuilt as a true multi-part composition.

Use a new clean/empty 720×1280 background and render the ten existing transparent island PNGs from:

`assets/ui_assets/campaign/world_map/`

Required island art:
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

The old baked ten-island background is no longer the layout authority.

Each visible island and its interactive region must share the same authoritative transform/center. There must be no displaced invisible hotspot.

Map positions are authorized to change in this remediation.

## Preserve

Do not change:
- island ids/order/unlock rules;
- campaign/save/progression truth;
- Sunny Cove 100-level content;
- owner-approved R04 gameplay surfaces/geometries;
- gameplay physics/scoring/To-Go/VIP;
- Island Map background families;
- M22+ sequencing.

## Sunny Cove navigation

The visible Sunny Cove island must open Sunny Cove Island Map through real mouse/touch input in the production navigation chain.

A direct `select_island("sunny_cove")` unit call is not sufficient evidence.

## Old background

Do not delete `world_map_background.png` in this remediation. It remains rollback evidence until the new composite map is owner-accepted. It must no longer be the production World Map background after the remediation.
