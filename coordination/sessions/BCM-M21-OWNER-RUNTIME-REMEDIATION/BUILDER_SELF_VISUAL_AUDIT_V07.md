# Builder Self Visual Audit — BCM-M21 V07

**Status:** PASS for every required builder visual item. This is builder evidence, not owner acceptance or an independent audit.

## Sunny Cove gameplay surface

| Item | Result | Runtime evidence | Visual reason | Iteration |
|---|---|---|---|---|
| SC-01 | PASS | `evidence/runtime/v07/SC-01_single_flattened_surface_720x1280.png` | The full gameplay presentation reads as one coherent Sunny Cove surface. Runtime inventory shows one static gameplay texture and no separately instanced Sunny Cove table, shadow, or edge overlay. | Final V07 surface after fresh composition and runtime review. |
| SC-02 | PASS | `evidence/runtime/v07/SC-02_clear_central_tabletop_720x1280.png` | The tabletop occupies the central play area, narrows toward the rear, and leaves the top HUD and lower apron/progression region clear. | Final V07 geometry calibration. |
| SC-03 | PASS | `evidence/runtime/v07/SC-03_held_spawn_in_front_720x1280.png` | The held cocktail is visible at the front launch area, in front of the table surface and above the apron. | Final V07 geometry calibration. |
| SC-04 | PASS | `evidence/runtime/v07/SC-04_after_10_real_mouse_launches_720x1280.png` | Ten real viewport mouse launches leave the moving/settled cocktails visibly on the tabletop. | Final production-input capture. |
| SC-05 | PASS | `evidence/runtime/v07/SC-05_twelve_glass_crowded_runtime_720x1280.png`; `assets/ui_assets/campaign/islands/sunny_cove/playable_geometry_12_glass_stress_v07.png` | All twelve cocktail levels are visible on the tabletop, with no glass hidden behind or below the frame. The calibrated footprints report inside the V2 playable mask. | Final crowded-state layout and runtime capture. |
| SC-06 | PASS | `evidence/runtime/v07/SC-06_left_rail_contact_runtime_720x1280.png`; `SC-06_right_rail_contact_runtime_720x1280.png`; `SC-06_rear_rail_contact_runtime_720x1280.png` | Left, right, and rear launch trajectories meet the image-locked boundary. The visible bases reach the drawn edge without a visible escape; the rear capture shows tabletop wood behind the glass base. | Final recapture after side-contact timing was corrected and the rear shot isolated. |
| SC-07 | PASS | `evidence/runtime/v07/SC-07_hud_and_progression_clearance_720x1280.png` | The HUD remains above the playable table, and the progression strip remains below the table between the legs without covering active drinks. | Final V07 surface and HUD capture. |
| SC-08 | PASS | `evidence/runtime/v07/SC-08_win_result_clear_720x1280.png`; `evidence/runtime/v07/V07_TERMINAL_VISIBLE_COUNTS.json` | The WIN card is topmost and readable. Terminal cleanup reports zero visible drinks and zero transient world effects. | Final production result capture. |

## World Map markers

The following crops come directly from the final production World Map capture at `evidence/runtime/v07/02_world_map_after_play.png`. Each crop was visually inspected at marker scale. The report at `evidence/runtime/v07/V07_WORLD_MAP_VISUAL_REVIEW.json` records its crop box and marker center.

| Item | Island | Result | Evidence | Visual reason | Iteration |
|---|---|---|---|---|---|
| WM-01 | Sunny Cove | PASS | `evidence/runtime/v07/WM-01_sunny_cove_runtime_crop.png` | Ring and label center on the lagoon island body; OPEN state uses the same marker. | Final capture after marker-anchor calibration. |
| WM-02 | Tiki Island | PASS | `evidence/runtime/v07/WM-02_tiki_island_runtime_crop.png` | Ring and label center on the village/statue island body; lock state shares the marker. | Final capture after marker-anchor calibration. |
| WM-03 | Azure Bay | PASS | `evidence/runtime/v07/WM-03_azure_bay_runtime_crop.png` | Ring and label center on the marina and resort island body; lock state shares the marker. | Final capture after marker-anchor calibration. |
| WM-04 | Coconut Beach | PASS | `evidence/runtime/v07/WM-04_coconut_beach_runtime_crop.png` | Ring and label center on the lagoon/islet body; lock state shares the marker. | Final capture after marker-anchor calibration. |
| WM-05 | Sunset Island | PASS | `evidence/runtime/v07/WM-05_sunset_island_runtime_crop.png` | Ring and label center on the shore and palm island body; lock state shares the marker. | Final capture after marker-anchor calibration. |
| WM-06 | Party Beach | PASS | `evidence/runtime/v07/WM-06_party_beach_runtime_crop.png` | Ring and label center on the venue/island body; lock state shares the marker. | Final capture after marker-anchor calibration. |
| WM-07 | Frozen Paradise | PASS | `evidence/runtime/v07/WM-07_frozen_paradise_runtime_crop.png` | Ring and label center on the snowy island body; lock state shares the marker. | Final capture after marker-anchor calibration. |
| WM-08 | Volcano Bay | PASS | `evidence/runtime/v07/WM-08_volcano_bay_runtime_crop.png` | Ring and label center on the volcanic island body; lock state shares the marker. | Final capture after marker-anchor calibration. |
| WM-09 | Billionaire Island | PASS | `evidence/runtime/v07/WM-09_billionaire_island_runtime_crop.png` | Ring and label center on the resort island body; lock state shares the marker. | Final capture after marker-anchor calibration. |
| WM-10 | Final Island | PASS | `evidence/runtime/v07/WM-10_final_island_runtime_crop.png` | Ring and label center on the rock formation; lock state shares the marker. | Final capture after marker-anchor calibration. |

`01_world_map_calibrated_720x1280.png` and `02_world_map_after_play.png` show the full map. Runtime inspection confirms no `IslandRoute` node and no duplicate island/lock thumbnails. The pale dotted route artwork is baked into the map background.

## Builder evidence summary

- Godot 4.7.2 headless editor import completed with exit code 0.
- Production GUI probe passed with 15 real viewport clicks; gameplay probe passed with 10/10 mouse and 10/10 touch launches.
- Side and rear contact captures passed the image-locked geometry checks; the twelve-glass stress state remained inside the visible tabletop.
- Production-path persistence probe passed with an isolated Godot user-data directory.
- Gameplay, GUI, persistence, and import logs contain no `ERROR:` or `SCRIPT ERROR:` entries.
- `git diff --check` passed.
- Native owner-device F5 acceptance and independent ChatGPT audit remain pending.
