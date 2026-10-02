# Owner F5 Acceptance Checklist — BCM-M21 V04

Status: **PENDING OWNER F5 REVIEW**

This checklist records the owner-native acceptance gate. Builder probes and captures are evidence only. Leave every PASS/FAIL selection blank until the owner performs the F5 review.

## Required owner review

| # | Surface / action | Evidence | Owner result |
|---|---|---|---|
| 1 | World Map: all ten state rings and labels sit on their baked island bodies; no duplicate thumbnail art or route lines. | `evidence/runtime/v04/01_world_map_calibrated_720x1280.png` | [ ] PASS  [ ] FAIL |
| 2 | Sunny Cove page 1: L1-L10 occupy the ten marked landmarks and no connector lines appear. | `evidence/runtime/v04/02_sunny_cove_page01_landmarks_720x1280.png` | [ ] PASS  [ ] FAIL |
| 3 | Sunny Cove later page: L51-L60 reuse the same landmarks on a repeated background; scrolling reaches L100. | `evidence/runtime/v04/03_sunny_cove_page06_landmarks_720x1280.png` | [ ] PASS  [ ] FAIL |
| 4 | Gameplay: table, shadow, edge, launch/death coordinates and R11 boundary move down exactly 150 canonical pixels; background and HUD remain fixed. | `evidence/runtime/v04/04_sunny_cove_gameplay_shifted_720x1280.png` and `evidence/runtime/v04/V04_TABLE_TRANSLATION_INVARIANCE.json` | [ ] PASS  [ ] FAIL |
| 5 | Gameplay: full-screen `launch_zone.png` art is absent; the simple launch line remains; no separate `decor_left/right/back` nodes render. | `evidence/runtime/v04/04_sunny_cove_gameplay_shifted_720x1280.png` and `evidence/runtime/v04/V04_THEME_LAYER_ISOLATION_REPORT.md` | [ ] PASS  [ ] FAIL |
| 6 | WIN: result card appears once with Next Level and Island Map; Next Level starts the next level. | `evidence/runtime/v04/08_win_result_visible_720x1280.png` | [ ] PASS  [ ] FAIL |
| 7 | Second WIN: Island Map returns to the map; LOSE card has Retry and Island Map; Retry restarts the same level. | `evidence/runtime/v04/09_second_win_result_visible_720x1280.png`, `evidence/runtime/v04/10_lose_result_visible_720x1280.png` | [ ] PASS  [ ] FAIL |
| 8 | Full production result flow completes with zero red Godot runtime errors. | `evidence/runtime/v04/M21_OWNER_F5_REMEDIATION_V04_PROBE_LOG.txt` | [ ] PASS  [ ] FAIL |
| 9 | Input, no-timer, pause/resume and persistence behavior remain acceptable in the owner runtime. | `evidence/runtime/v04/05_sunny_cove_gameplay_after_10_mouse_shots_720x1280.png`, `06_sunny_cove_untimed_after_one_hour_720x1280.png`, `07_pause_untimed_720x1280.png` | [ ] PASS  [ ] FAIL |

## Owner record

- Device / Godot build:
- Review date:
- Owner notes:
- Final owner decision: [ ] ACCEPT  [ ] CHANGES REQUIRED

Technical handoff remains `AWAITING_OWNER_F5_ACCEPTANCE_V04` until this owner-native review is recorded.
