# BCM-M21-007 R04 Cleanup Deletion Manifest V01

Status: builder evidence; independent audit pending. Root `TASKS.md` remains unchanged.

## Deletion totals

- Removed files: **335** (136 tracked and 199 generated/untracked `.import` sidecars).
- Original bytes removed: **167,405,266**.
- Orphan `.import` sidecars after clean Godot editor import: **0**.
- The tracked total includes four owner-confirmed deletions: the obsolete generic background and three top-level contact sheets. Owner `project.godot`, `scenes/main.tscn`, add-ons, and translation sidecars are excluded.

| Category | Files |
|---|---:|
| generated_import_sidecar | 199 |
| obsolete_visual_or_evidence | 115 |
| retired_split_table_contract_data | 2 |
| retired_test_or_probe | 13 |
| retired_visual_helper | 6 |

| Extension | Files |
|---|---:|
| .gd | 13 |
| .import | 199 |
| .json | 16 |
| .png | 97 |
| .py | 10 |

## Protected authority and remaining review

All ten R04 source/runtime/profile families and map/completion assets remain protected and passed the current asset validator and Godot authority probe. **94** candidates remain REVIEW; none were deleted while REVIEW. Uncertain historical contact sheets and unrelated evidence were retained.

The generic background consumer was traced: gameplay uses each island's `gameplay_surface.png`; Island Map uses `theme.island_map_background`. Root campaign schema/data no longer require the obsolete top-level `map_background` field.

## Validation results

- Asset/R04 validator: PASS, 356/356 current PNG checksums; all 10 R04 families; 0 invalid.
- R04 authority probe: PASS, 10 islands / 71 checks.
- Godot asset import: PASS, 25/25 assets (12 cocktails, 0 environment, 9 UI, 4 effects).
- R10 V10 visual-hull containment: PASS; side rails, rear accumulation, merge containment.
- M10, M13, M14, M15, M17, M18, M19, M20 campaign/gameplay probes: PASS; M21 V07-R02 gameplay probe PASS (10/10 mouse and touch).
- M12 World Map probe: one 720x1280 overlap/clipping assertion fails. Its layout is based on map positions and is unrelated to the removed top-level background field; disclosed for independent review.
- Clean Godot 4.7.2 editor import/parse: PASS; the engine noted the existing nested `original_reference` project is ignored.
- `git diff --check`: PASS (line-ending conversion warnings only).
- Headless visual captures were skipped; no owner-native visual acceptance is claimed.

## Commit groups

Generated `.import` cleanup is recorded as local cleanup evidence. Tracked obsolete files, rules/tests/catalog reconciliation, and inventory/log will be committed in bounded groups. Owner-local files listed above are excluded from staging.
