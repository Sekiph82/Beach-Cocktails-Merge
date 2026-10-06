# Codex Execution Log — BCM-M21-001-R08 Home Frontier Authority Fix

## Start and synchronization

- Work item: BCM-M21-001-R08 — align Home LEVEL, PLAY plaque, and Home PLAY action to the canonical campaign frontier while preserving explicit Island Map replay.
- Start HEAD after safe sync: `cda89c59706051ba6f3bfde1dccdd7845f268836`; branch `main`; remote `origin`.
- Pre-sync HEAD was `0d99991ba3e1d653a8b843622662da0d06c0286a`; checkout was behind-only `0 ahead / 5 behind`.
- Dirty inventory before sync: two pre-existing untracked owner critique PNGs under `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence/`; no tracked modifications.
- Incoming changed paths were `AGENTS.md`, `TASKS.md`, and three R08 prompt/criteria/audit files. No overlap with either owner PNG. `git merge --ff-only origin/main` succeeded. Owner PNGs remain untouched.
- After sync, `HEAD == origin/main == cda89c59706051ba6f3bfde1dccdd7845f268836`; `TASKS.md` names R08 as active, `Required Actor: CODEX`, and is read-only.

## Execution

- Implementation:
  - `ApplicationShell._refresh_home_values()` now resolves one frontier value and uses it for both the Home top LEVEL field and the `LEVEL N` PLAY plaque. Removed the Home selected-replay display resolver.
  - `CampaignNavigationController.continue_campaign()` now launches `CampaignManager.get_frontier_level_id(current_island_id)`. Explicit level selection from Island Map still routes through `_on_level_selected()` and can launch unlocked replay level 4.
  - Updated the stale R07 Home label probe and R04 Home probe so old replay selection must preserve both Home frontier displays and Home PLAY must launch the frontier.
  - Added `tests/m21_home_frontier_authority_r08_probe.gd`: boots production ApplicationShell, sets frontier 11 / replay selection 4, sends real viewport mouse and touch input, opens World Map and Sunny Cove Island Map, clicks LV4, returns Home, completes frontier 11, and verifies Home/PLAY now use 12.
- Required test results:
  - `godot_console.exe --headless --path . --script res://tests/m21_home_frontier_authority_r08_probe.gd` — exit 0; `M21_HOME_FRONTIER_R08_RESULT=PASS frontier=11 replay=4 advanced_frontier=12`.
  - `godot_console.exe --headless --path . --script res://tests/m21_home_label_r07_probe.gd` — exit 0; `M21_HOME_LABEL_R07_RESULT=PASS`.
  - `godot_console.exe --path . --script res://tests/m21_home_exact_target_r04_probe.gd` — exit 0; `M21_HOME_R04_RESULT=PASS`.
  - `godot_console.exe --headless --path . --script res://tests/m21_island_map_page_focus_r07_probe.gd` — exit 0; `M21_ISLAND_MAP_PAGE_R07_RESULT=PASS boundaries=9`.
  - `godot_console.exe --path . --script res://tests/m21_island_map_node_visual_r07_probe.gd` — exit 0; `M21_ISLAND_MAP_NODE_R07_RESULT=PASS`.
  - `godot_console.exe --headless --path . --script res://tests/m18_star_contract_probe.gd` — exit 0; `M18_STAR_CONTRACT_RESULT=PASS`.
  - `godot_console.exe --headless --path . --script res://tests/m18_replay_persistence_probe.gd` — exit 0; `M18_REPLAY_PERSISTENCE_RESULT=PASS`.
  - `godot_console.exe --headless --path . --script res://tests/m20_app_shell_probe.gd` — exit 0; `M20_CHILD_01_RESULT=PASS`.
  - `godot_console.exe --path . --script res://tests/m21_island_map_full_background_followup_r01_probe.gd` — exit 0; `M21_FULL_BACKGROUND_R01_RESULT=PASS pages=10 levels_per_page=10 background=720x1280`.
  - `python tools/ui_assets/validate_assets.py` — exit 0; checksums 373/373, R04 surface families 10/10, retired art absent, semantic duplicates valid.
  - `godot_console.exe --headless --editor --path . --quit` — exit 0; editor parse/import completed.
  - `godot_console.exe --headless --path . --quit` — exit 0; project boot completed.
  - `git diff --check` — exit 0. `git diff --exit-code -- TASKS.md` — exit 0.
- Inherited regression blocker:
  - `godot_console.exe --path . --script res://tests/m21_world_map_production_v05_probe.gd` — exit 1 at the three existing return/touch checks: Island Map Back to World Map, touch opening Sunny Cove, and World Map Back to Home. Its visual/layout checks and first real mouse entry pass.
  - Reproduced the same three failures at clean pre-R08 baseline commit `cda89c59706051ba6f3bfde1dccdd7845f268836` in a temporary worktree; therefore this is not caused by the R08 Home changes. The temporary worktree was removed. World Map is frozen by R08, so no out-of-scope World Map changes were made. Exact outputs are retained in `world_map_v05.log` and `world_map_v05_baseline.log`.
- Restored all probe-regenerated pre-existing R04/R07/World Map evidence and Godot's incidental `project.godot` normalization byte-for-byte from current `HEAD`. No R07 map/star/background source or evidence changes are included.
- Manual owner F5/runtime acceptance was not performed. Desktop production-path test evidence is builder evidence only.

## Final repository state

- Publication pending. `TASKS.md` is unchanged. The two owner-local critique PNGs remain untouched and unstaged. R07 Island Map assets, layout, stars, and behavior remain unchanged.
- The R08 behavior and its focused/regression checks pass, but the locked V05 regression command remains red on both current and pre-R08 baseline. This inherited World Map issue remains unmodified due to the R08 scope freeze and must be considered in independent audit.
- Required final marker: `AWAITING_GPT_M21_HOME_FRONTIER_AUDIT_R08`.
