# R09 Verification Summary

Godot 4.7.2.stable.official.ed1daf0bf.

## Focused real-input test

`godot_console.exe --path . --script res://tests/m21_world_map_production_v05_probe.gd`

- Unchanged pre-edit reproduction: exit 1, preserved in `initial_v05_unchanged.log`.
- Final run 1: exit 0, `M21_WORLD_MAP_PRODUCTION_V05_RESULT=PASS captures=7 mouse=PASS touch=PASS`.
- Final run 2, immediately after run 1: exit 0, same PASS marker.
- Per-run details: `final_v05_run_1.log` and `final_v05_run_2.log`.

## Locked regressions

| Check | Command | Result |
|---|---|---|
| R08 Home frontier | `godot_console.exe --headless --path . --script res://tests/m21_home_frontier_authority_r08_probe.gd` | exit 0; frontier 11 advances Home and PLAY to level 12 |
| R07 Island Map page focus | `godot_console.exe --headless --path . --script res://tests/m21_island_map_page_focus_r07_probe.gd` | exit 0; `M21_ISLAND_MAP_PAGE_R07_RESULT=PASS boundaries=9` |
| R07 node visuals and selection | `godot_console.exe --path . --script res://tests/m21_island_map_node_visual_r07_probe.gd` | exit 0; `M21_ISLAND_MAP_NODE_R07_RESULT=PASS` |
| M20 ApplicationShell | `godot_console.exe --headless --path . --script res://tests/m20_app_shell_probe.gd` | exit 0; `M20_CHILD_01_RESULT=PASS` |
| Full Sunny Cove background | `godot_console.exe --path . --script res://tests/m21_island_map_full_background_followup_r01_probe.gd` | exit 0; `M21_FULL_BACKGROUND_R01_RESULT=PASS pages=10 levels_per_page=10 background=720x1280` |
| M18 star contract | `godot_console.exe --headless --path . --script res://tests/m18_star_contract_probe.gd` | exit 0; `M18_STAR_CONTRACT_RESULT=PASS` |
| Asset validator | `python tools/ui_assets/validate_assets.py` | exit 0; 373/373 manifest checksums, 10/10 R04 families, no invalid duplicate groups |
| Godot editor parse/import | `godot_console.exe --headless --editor --path . --quit` | exit 0 |
| Godot headless boot | `godot_console.exe --headless --path . --quit` | exit 0 |
| Whitespace check | `git diff --check` | exit 0 |
| Tracker unchanged | `git diff --exit-code -- TASKS.md` | exit 0 |

The exact per-run console output is retained in the correspondingly named `.log` files in this evidence directory. Test-generated tracked R07/V05 screenshots were restored byte-for-byte after the probes.
