# BCM-M21-001 + BCM-M21-006 — Builder Self Visual Audit V07-R02

**Builder result: PASS**
**Iteration:** 2
**Runtime:** Godot 4.7.2, production ApplicationShell navigation, canonical 720×1280 viewport
**Owner acceptance:** pending; this builder audit does not grant owner acceptance.

## Sunny Cove gameplay

| ID | Result | Evidence | Visual finding |
|---|---|---|---|
| SC-01 | PASS | `evidence/runtime/v07-r02/SC-01_single_flattened_surface_720x1280.png` | One static gameplay image contains the scene, table, frame, legs, and shadow. Runtime inventory shows no independent legacy table layers. |
| SC-02 | PASS | `evidence/runtime/v07-r02/SC-02_clear_central_tabletop_720x1280.png` | The clear tabletop fills the central play area with HUD above and progression controls below. |
| SC-03 | PASS | `evidence/runtime/v07-r02/SC-03_held_spawn_in_front_720x1280.png` | The held glass is visible at the launch area, in front of the table art and clear of UI. |
| SC-04 | PASS | `evidence/runtime/v07-r02/SC-04_after_10_real_mouse_launches_720x1280.png` | Ten viewport mouse launches were dispatched and counted; the captured drinks remain on the tabletop. |
| SC-05 | PASS | `evidence/runtime/v07-r02/SC-05_twelve_glass_crowded_runtime_720x1280.png` | All 12 visible runtime drinks fit inside the image-derived tabletop boundary, above the front rim. |
| SC-06 | PASS | `evidence/runtime/v07-r02/SC-06_left_rail_contact_runtime_720x1280.png`; `SC-06_right_rail_contact_runtime_720x1280.png`; `SC-06_rear_rail_contact_runtime_720x1280.png` | Left, right, and rear contacts meet the visibly traced rails; runtime contact telemetry passes for all three edges. |
| SC-07 | PASS | `evidence/runtime/v07-r02/SC-07_hud_and_progression_clearance_720x1280.png` | HUD remains above the table; the progression strip remains below the tabletop/frame and does not overlap active drinks. |
| SC-08 | PASS | `evidence/runtime/v07-r02/SC-08_win_result_clear_720x1280.png` | WIN is topmost and clean. Terminal visual counts are zero visible drinks and zero transient world effects. |

## World Map identity

The single full-map runtime capture below supports WM-01 through WM-10. Runtime checks verify each marker's visual center matches its click target and that duplicate thumbnails and runtime route nodes remain hidden.

| ID | Result | Island | Visual finding |
|---|---|---|---|
| WM-01 | PASS | Sunny Cove | Lower-left semantic region; ring, label, state, and click target share the island center. |
| WM-02 | PASS | Tiki Island | Ring and label sit on the Tiki destination body in its V04 neighborhood. |
| WM-03 | PASS | Azure Bay | Ring and label sit on the lower-right Azure Bay body in its V04 neighborhood. |
| WM-04 | PASS | Coconut Beach | Ring and label center on the central lagoon beach body. |
| WM-05 | PASS | Sunset Island | Marker remains on the V04 middle-map island body. |
| WM-06 | PASS | Party Beach | Ring and label center on the right-side Party Beach body. |
| WM-07 | PASS | Frozen Paradise | Ring and label center on the upper-right frozen body. |
| WM-08 | PASS | Volcano Bay | Marker remains in the V04 upper-left volcanic region and is refined toward the eruption mass; its center is on the volcanic land body. |
| WM-09 | PASS | Billionaire Island | Ring and label center on the waterfall island body in the V04 neighborhood. |
| WM-10 | PASS | Final Island | Ring and label center on the marina island body in the V04 neighborhood. |

Full-map evidence: `evidence/runtime/v07-r02/02_world_map_after_play.png`
Readable full-frame copy: `evidence/runtime/v07-r02/02_world_map_after_play_REVIEW.jpg`

## Process and semantic gates

- **PROC-01 — PASS:** [surface provenance](../../../../assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface_v07_r02.provenance.json) and [calibration source](../../../../tools/calibrate_sunny_cove_geometry_v07_r02.py) identify only the frozen new scene and its visible pixels as table-shape inputs.
- **PROC-02 — PASS:** the final art SHA-256 is recorded before geometry derivation. Art file timestamp: `2026-10-03T13:25:23.3290131Z`; geometry file timestamp: `2026-10-03T13:29:00.9334674Z`. The profile records the same art hash.
- **MAP-SEM-01 — PASS:** all ten island IDs remain within ±0.025 normalized adjustment of their V04 seed coordinates; no global identity remapping was used. Final coordinates are recorded in the JSON companion.

## Runtime and review evidence

- GUI production flow: 15 viewport clicks passed through Main Menu, Settings, World Map, Island Map, gameplay, WIN, Next, and back navigation.
- Gameplay probe: 10/10 mouse launches, 10/10 touch launches, 12-glass state, left/right/rear contacts, untimed session, Pause/Resume, WIN/Next/Island Map all passed.
- Isolated production-path persistence regression passed onboarding, settings, campaign completion, and restart persistence using a unique project-name/user-data namespace; the owner's normal campaign save was not used.
- Final GUI probe stderr and gameplay probe stderr are empty; final logs contain no Godot runtime errors.
- Every canonical screenshot above 700 KB has a same-frame `_REVIEW.jpg` under 500 KB. Lossless PNGs remain the canonical captures.
- Physical-device acceptance remains for owner F5 review.

## Machine-readable companion

`BUILDER_SELF_VISUAL_AUDIT_V07_R02.json` contains each criterion, status, evidence path, iteration, and semantic position.
