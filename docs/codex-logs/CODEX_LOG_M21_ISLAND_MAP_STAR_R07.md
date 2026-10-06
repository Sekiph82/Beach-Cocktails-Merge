# Codex Execution Log — BCM-M21-001-R07 Island Map + Star Mastery

## Start and synchronization

- Work item: BCM-M21-001-R07 — Home Label + Island Map UX + Star Mastery.
- Start HEAD after sync: `5800039af5a0670e446262e6fe5fc4a8ec1bdc98`; branch `main`; remote `origin`.
- Pre-sync HEAD `ee2c6d0598d0a7ee01b8b6c4be1d60f651db90f2`; origin/main and remote main were `5800039af5a0670e446262e6fe5fc4a8ec1bdc98`; `0 ahead / 6 behind`.
- Initial tracked local difference was only the Godot-generated `GameFeelFlow` UID normalization (`res://addons/game_feel_flow/core/game_feel_flow.gd` to `uid://ckhnfaf1odnpl`). Two owner critique screenshots remained untracked.
- Safe sync used the exact tracked-only stash `owner-local-safe-sync-ee2c6d0` (no `-u`), fast-forwarded to origin/main, and applied only that stash without dropping it. Incoming changes were disjoint from both owner screenshots and the local project file. After confirming the sole project difference was generated UID spelling, restored canonical `project.godot`; no owner semantic change was discarded.
- Active authority read: synchronized `AGENTS.md`, root `TASKS.md` (read-only), owner R07 ruling, R07 criteria and prompt, current M18 star/replay tests, and M18 V02-R01 independent audit.

## Execution

- Implemented a single `CampaignManager.get_frontier_level_id()` resolver and used it for the Home PLAY plaque and campaign navigation label. The plaque now shows `LEVEL N`; the top Level bar and selected-level launch behavior remain independent.
- Island Map restoration now records its frontier. A strictly advanced frontier supersedes stale saved scroll/focus and focuses the newly unlocked frontier page. Same-page manual browse/scroll restoration and old-level replay remain available.
- Repositioned the existing Sunny Cove title label using the existing plaque's rendered scale and measured inner aperture. No plaque art or Home layout changed.
- Enlarged level overlays to `LVn`, three visible star positions, strong outlines/shadows, and removed node BEST/SCORE display and tooltip content. Best score remains internal; current art, milestone and VIP indicators remain.
- Updated `GameplaySessionBridge.calculate_stars()` to the R07 score/VIP truth table. VIP only gates the third star on VIP-enabled levels; completion still unlocks progression.
- Added `tools/campaign/generate_sunny_cove_star_thresholds.py`. It reads canonical drinks and Sunny Cove orders, writes threshold values for all 100 levels, and emits the locked machine-readable report. First generation changed only the Sunny Cove threshold fields and report; the subsequent generator run reported `changed=none`, and `--check` reported `levels=100 deterministic=PASS`.
- Added focused R07 Home, page-focus, and node visual probes. Captures show production Home, Sunny Cove page, title plaque, all nine page boundary behavior, node states, and a VIP-complete 3-star node.
- Updated only current M18/M21 regression assertions whose old BEST/CONTINUE expectations conflict with R07. No gameplay physics, save schema, cumulative reward values, unlock rules, Home art, World Map composition, R04 gameplay surface, economy draft, or `TASKS.md` were changed.

### Verification commands and results

All output is retained under `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/evidence/`.

| Command / probe | Result |
| --- | --- |
| `godot_console.exe --path . --script res://tests/m21_home_label_r07_probe.gd` | Exit 0; `M21_HOME_LABEL_R07_RESULT=PASS` |
| `godot_console.exe --path . --script res://tests/m21_island_map_page_focus_r07_probe.gd` | Exit 0; `M21_ISLAND_MAP_PAGE_R07_RESULT=PASS boundaries=9` |
| `godot_console.exe --path . --script res://tests/m21_island_map_node_visual_r07_probe.gd` | Exit 0; `M21_ISLAND_MAP_NODE_R07_RESULT=PASS`; title center error <=2 px; all required state crops saved |
| `godot_console.exe --headless --path . --script res://tests/m18_star_contract_probe.gd` | Exit 0; `M18_STAR_CONTRACT_RESULT=PASS` |
| `godot_console.exe --headless --path . --script res://tests/m18_replay_persistence_probe.gd` | Exit 0; `M18_REPLAY_PERSISTENCE_RESULT=PASS` |
| `godot_console.exe --headless --path . --script res://tests/m18_cumulative_star_rewards_probe.gd` | Exit 0; `M18_CUMULATIVE_STAR_REWARDS_RESULT=PASS` |
| `godot_console.exe --headless --path . --script res://tests/m18_cumulative_reward_claim_remediation_probe.gd` | Exit 0; `M18_CUMULATIVE_REWARD_REMEDIATION_RESULT=PASS` |
| `godot_console.exe --headless --path . --script res://tests/m18_integration_probe.gd` | Exit 0; `M18_INTEGRATION_RESULT=PASS` |
| `godot_console.exe --headless --path . --script res://tests/m18_island_map_replay_probe.gd` | Exit 0; `M18_ISLAND_MAP_REPLAY_RESULT=PASS` |
| `godot_console.exe --path . --script res://tests/m18_v02_r01_replay_capture_probe.gd` | Exit 0; `M18_REPLAY_CAPTURE_RESULT=PASS`; actual viewport captures valid at 720x1280 |
| `godot_console.exe --headless --path . --script res://tests/m13_island_map_probe.gd` | Exit 0; `M13_ISLAND_MAP_RESULT=PASS` |
| `godot_console.exe --headless --path . --script res://tests/m14_gameplay_session_bridge_probe.gd` | Exit 0; `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS` |
| `godot_console.exe --headless --path . --script res://tests/m20_app_shell_probe.gd` | Exit 0; `M20_CHILD_01_RESULT=PASS` |
| `godot_console.exe --path . --script res://tests/m21_home_exact_target_r04_probe.gd` | Exit 0; `M21_HOME_R04_RESULT=PASS`; accepted Home layout geometry and real PLAY/World Map navigation retained |
| `godot_console.exe --path . --script res://tests/m21_world_map_production_v05_probe.gd` | Exit 0; `M21_WORLD_MAP_PRODUCTION_V05_RESULT=PASS captures=7 mouse=PASS touch=PASS` |
| `godot_console.exe --headless --path . --script res://tests/m21_r04_gameplay_surface_authority_probe.gd` | Exit 0; 71 checks, 10 island surface/profile families pass |
| `python tools/ui_assets/validate_assets.py` | Exit 0; 373/373 current PNGs and 10/10 R04 families pass |
| `python tools/campaign/generate_sunny_cove_star_thresholds.py --check` | Exit 0; all 100 levels deterministic |
| second `python tools/campaign/generate_sunny_cove_star_thresholds.py` | Exit 0; `changed=none` |
| `godot_console.exe --headless --editor --path . --quit` | Exit 0; editor scan, class registration, asset reimport completed |
| `godot_console.exe --headless --path . --quit-after 5` | Exit 0; headless project boot |
| `git diff --check` | Exit 0 |
| `git diff --exit-code -- TASKS.md` | Exit 0; tracker unchanged |

Two preliminary verification invocations were corrected: the M18 V02 capture probe was first run headless (capture unavailable under the dummy renderer), then passed in the normal renderer; the M20 probe was first called under a guessed non-existent filename, then passed using the actual `m20_app_shell_probe.gd` path. These were invocation corrections, not product failures.

### Evidence files

- `evidence/home_level_10.png`
- `evidence/island_map_levels_1_10.png`
- `evidence/frontier_10_to_11.png`, `frontier_20_to_21.png`, `frontier_90_to_91.png`
- `evidence/node_completed_1_star.png`, `node_completed_2_star.png`, `node_completed_3_star.png`, `node_open.png`, `node_current_open.png`, `node_locked.png`, `node_milestone.png`, `node_vip_complete_3_star.png`
- Individual `.log` files for all verification commands and probes.
- Threshold report: `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/SUNNY_COVE_STAR_THRESHOLDS_R07.json`.

- Manual checks performed: visually inspected Home, Island Map, the 10→11/20→21/90→91 production captures, and the VIP-complete node crop at 720×1280.
- Manual checks not performed: owner-native F5 acceptance/review; this is the requested handoff.
- Preserved unrelated owner-local untracked Home critique screenshots without staging them. Godot-generated `project.godot` UID normalization and prior M18/V05/Home-R04 tracked screenshot rewrites caused by regression probes were restored byte-for-byte to `HEAD` after verification.

## Final repository state

- Product/evidence commit: `d0df2040b357a8850e9aaa5235ec64add38d9700` on `main` / `origin`.
- Immediately after that push and fetch, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `d0df2040b357a8850e9aaa5235ec64add38d9700`; divergence was `0 0`.
- This required log publication receipt is a follow-up log-only commit. Its resulting local/origin/live SHA equality is verified again in the final handoff; the product state is unchanged.
- `TASKS.md` remains byte-identical and is not staged. The two owner critique screenshots remain untouched and unstaged.
- Builder stop marker: `AWAITING_OWNER_ISLAND_MAP_STAR_REVIEW_R07`.
