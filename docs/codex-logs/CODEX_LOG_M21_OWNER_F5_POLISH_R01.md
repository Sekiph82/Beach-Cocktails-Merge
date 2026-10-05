# Codex Execution Log — BCM-M21-001-R02 Owner F5 Visual Polish

## Start record

- Prompt: `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/CHATGPT_OWNER_F5_VISUAL_POLISH_PROMPT_R02.md`
- Locked criteria: `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/CHATGPT_OWNER_F5_VISUAL_POLISH_CRITERIA_R02.md`
- Start SHA after safe synchronization: `36c6b9bdde4ce7ba402f0453ba0a941f43d0b2f0`
- Branch/remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`)
- Initial divergence: `0 ahead / 11 behind`; synchronized with a fast-forward after confirming incoming paths were disjoint from the two pre-existing dirty paths.
- Owner-local preservation: tracked-only stash `owner-local-safe-sync-7783fb9` was applied without dropping. `project.godot` remains modified by the owner (`GameFeelFlow` autoload uses the local UID form); it is excluded from this task's changes. The preflight `WorldMapScene.tscn` marker had no content diff after synchronization.
- `TASKS.md` was read only; active task was `BCM-M21-001`, `IN_PROGRESS`. No tracker edits were made.

## Implementation

- Replaced flat Island Map level buttons with the canonical 320×180 PNG family. Exact state/star mapping:
  - LOCKED → `level_node_locked.png`
  - OPEN → `level_node_unlocked.png`
  - CURRENT → `level_node_finale.png`
  - COMPLETE 0 stars → `level_node_completed.png`
  - COMPLETE 1 star → `level_node_current.png`
  - COMPLETE 2 stars → `level_node_two_star.png`
  - COMPLETE 3 stars → `level_node_milestone.png`
- Added deterministic local generator `tools/ui_assets/create_two_star_level_node.py` and `assets/ui_assets/campaign/island_map/level_node_two_star.png`. Image is 320×180 RGBA, 64,094 bytes, SHA-256 `f7431f70810075d92e8ca7a2b4b80ffc5806f104d7974aff335f3e8ae38915da`.
- `IslandMapHeader` changed from a teal Panel with bottom 166 px to a transparent Control with a 112 px sky band and centered island plaque/name. Scroll top changed from y=178 to y=112; Back remains at upper left. Summary/progression APIs remain; their old visible text and subtitle are hidden/removed.
- To-Go/VIP panel changed from 170×255×`ui_scale` to 212.5×318.75×`ui_scale`; width and height ratios are both exactly 1.25. Normal/VIP cocktails use the shared 1.25 scale policy, all four progress/reward labels use 1.25 scale, and panel-bound flash remains attached to the enlarged panel. Centering and y=0 remain unchanged. No table or physics geometry changed.
- Rebuilt Home from the canonical main-menu background, logo, action buttons, and tropical decor. PLAY continues the valid current campaign level via existing navigation/session authority; WORLD MAP opens World Map directly. Continue label is derived from campaign state. Shop and Daily Rewards are visibly disabled as “Coming soon”; Settings remains wired.
- Updated M15/M18/M20 and V05 probes for the new authoritative visuals/actions. Updated M07-R06 To-Go expected box to the old calibrated box scaled 1.25 about its center; no score layout or gameplay behavior was altered.

## Files changed for this task

- `assets/ui_assets/ASSET_DIMENSIONS.csv`
- `assets/ui_assets/ASSET_MANIFEST.json`
- `assets/ui_assets/SEMANTIC_DUPLICATE_REPORT.json`
- `assets/ui_assets/campaign/island_map/level_node_two_star.png`
- `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/evidence/` (nine required renderer captures)
- `docs/codex-logs/CODEX_LOG_M21_OWNER_F5_POLISH_R01.md`
- `scripts/campaign/application_shell.gd`
- `scripts/campaign/campaign_navigation_controller.gd`
- `scripts/campaign/island_map_controller.gd`
- `scripts/campaign/level_button.gd`
- `scripts/game_manager.gd`
- `tests/m07_r06_owner_layout_probe.gd`
- `tests/m15_vip_boosters_economy_probe.gd`
- `tests/m18_island_map_replay_probe.gd`
- `tests/m20_app_shell_probe.gd`
- `tests/m21_owner_f5_visual_polish_probe.gd`
- `tests/m21_world_map_production_v05_probe.gd`
- `tools/ui_assets/create_two_star_level_node.py`

## Evidence captures

- `evidence/01_island_map_top.png`
- `evidence/02_island_map_state_matrix.png`
- `evidence/03_gameplay_to_go_plus25_nonvip.png`
- `evidence/04_gameplay_to_go_plus25_vip.png`
- `evidence/05_gameplay_to_go_plus25_nonvip.png` (persistent non-VIP 0/0)
- `evidence/06_home_720x1280.png`
- `evidence/07_home_800x1422.png`
- `evidence/08_home_world_map_navigation.png`
- `evidence/09_home_play_continue_navigation.png`

## Verification results

- `godot_console.exe --path . --script tests/m21_owner_f5_visual_polish_probe.gd` — PASS; all mapping, layout, 1.25 scaling, campaign Continue, distinct World Map navigation, and nine renderer captures passed.
- `tests/m13_island_map_probe.gd` — PASS.
- `tests/m18_island_map_replay_probe.gd` — PASS.
- `tests/m20_app_shell_probe.gd` — PASS.
- `tests/m21_world_map_production_v05_probe.gd` — PASS; real mouse and touch input reached Sunny Cove Island Map. Probe now clicks the distinct WORLD MAP action.
- `tests/m15_vip_boosters_economy_probe.gd` — PASS twice.
- `tests/m14_gameplay_session_bridge_probe.gd` — PASS.
- `tests/m08_to_go_delivery_probe.gd` — emitted `M08_TO_GO_DELIVERY_RESULT=PASS` and saved three captures; process exited with Windows code `-1073741819` during shutdown.
- `tests/m03_economy_regression.gd` — PASS.
- `tests/m21_r04_gameplay_surface_authority_probe.gd` — PASS, 10 islands / 71 checks.
- `tests/m07_r06_owner_layout_probe.gd` — To-Go L6–L12 bounds now PASS at all three viewports; overall FAIL remains on the score glyph center assertions (measured center deltas 9.347 px BEST and 9.240 px SCORE versus 1.5 px limit). Score layout is outside this visual scope and was left unchanged.
- `tests/m07_hud_composition_probe.gd` — FAIL on legacy expectations for existing logo/progression layout and then references unavailable `GameManager._launch_zone`; it does not reach a result line. No gameplay/score layout changes were made to accommodate the stale probe.
- `tests/m07_r04_focused_probe.gd` / `tests/m07_r05_hud_adaptation_probe.gd` — legacy probes fail on prior To-Go sizing/layout and missing `_launch_zone` / `get_horizontal_bounds_at_y` APIs; these contracts conflict with current production architecture and this task's required 1.25 panel.
- `python tools/ui_assets/rebuild_asset_catalog_r04.py` — PASS, 359 current PNGs/dimensions.
- `python tools/ui_assets/validate_assets.py` — PASS, 359/359 checksums; R04 10/10; duplicate groups invalid=0.
- `godot_console.exe --headless --editor --path . --quit` — PASS, clean import/class scan.
- `godot_console.exe --headless --path . --quit-after 3` — PASS, application boot.
- `git diff --check` — PASS (line-ending warnings only).
- Test-generated changes to historical M07/M08/M15/V05 evidence were restored byte-for-byte to `HEAD`; new R02 evidence remains under the task evidence directory.

## Manual review and limitations

- Reviewed the live renderer output for the 720×1280 Home, Island Map, and non-VIP To-Go panel. The Home presents the tropical hero, logo, PLAY/CONTINUE, separate WORLD MAP, and bottom utilities. The Island Map shows the plaque and varied state skins. The To-Go/VIP artwork and contents visibly enlarge together.
- Native owner F5 acceptance was not performed by Codex; owner review and independent GPT audit remain pending.
- The R02 required legacy M07 regression gate is not fully green for the recorded reasons above. Do not treat this builder log as acceptance.

## Publication and repository state

- Implementation commit SHA: `cd4f5604a73eadc1702f92f0fe38402494a0eece`, published to `origin/main`.
- Branch: `main`; no new branch created.
- `TASKS.md` was not modified.
- Owner-local `project.godot` work is preserved and remains unstaged/uncommitted. Therefore the prompt's clean-worktree condition cannot be claimed in this checkout; intended task changes will be committed separately.
- At implementation publication verification: local HEAD, `origin/main`, and remote `main` all equaled `cd4f560`; ahead/behind was `0/0`. A following log-only commit will contain this record. Final tip parity was rechecked after that publication and is reported in the handoff.
- Required handoff marker: `AWAITING_GPT_M21_OWNER_F5_POLISH_AUDIT_R02`.
