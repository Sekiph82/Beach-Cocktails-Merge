# Owner F5 Acceptance Checklist — BCM-M21 V05

Status: **PENDING OWNER F5 REVIEW**

Builder runtime evidence and screenshots are not owner acceptance. Leave all owner result fields blank until the owner performs the F5 review.

## Required owner review

| # | Surface / action | Evidence | Owner result |
|---|---|---|---|
| 1 | Main Menu opens and PLAY / CONTINUE responds to a real mouse click. | `evidence/runtime/v05/01_main_menu_before_play.png`, `02_world_map_after_play.png` | [ ] PASS  [ ] FAIL |
| 2 | World Map Back returns to Main Menu; SETTINGS responds to a real mouse click. | `evidence/runtime/v05/03_settings_after_click.png` | [ ] PASS  [ ] FAIL |
| 3 | BACK TO MENU responds; PLAY / CONTINUE works again. | `evidence/runtime/v05/04_main_menu_after_settings.png` | [ ] PASS  [ ] FAIL |
| 4 | Sunny Cove Level 1 reaches a visible WIN result with the result canvas active. | `evidence/runtime/v05/05_win_result_visible.png` | [ ] PASS  [ ] FAIL |
| 5 | Next Level responds to a real GUI click and deactivates the result canvas. | `evidence/runtime/v05/M21_OWNER_F5_REMEDIATION_V05_PROBE_LOG.txt` | [ ] PASS  [ ] FAIL |
| 6 | Returning to Main Menu after a result leaves PLAY and SETTINGS clickable. | `evidence/runtime/v05/06_main_menu_after_result.png` | [ ] PASS  [ ] FAIL |
| 7 | Combined menu/result flow has zero red Godot runtime errors. | `evidence/runtime/v05/M21_OWNER_F5_REMEDIATION_V05_PROBE_LOG.txt` | [ ] PASS  [ ] FAIL |
| 8 | Preserved V04 map, gameplay input, no-timer, table geometry, result lifecycle, and persistence behavior remain acceptable. | V04 runtime probe and V05 regression evidence | [ ] PASS  [ ] FAIL |

## Owner record

- Device / Godot build:
- Review date:
- Owner notes:
- Final owner decision: [ ] ACCEPT  [ ] CHANGES REQUIRED

Technical handoff remains `AWAITING_OWNER_F5_ACCEPTANCE_V05` until this owner-native review is recorded.
