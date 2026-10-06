# Codex Execution Log — BCM-M21-001-R06 Full Runtime Review

## Start and synchronization

- Work item/prompt: BCM-M21-001-R06 — Freeze Approved Home and Prepare Full Godot Runtime Review; locked prompt `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/CHATGPT_FULL_RUNTIME_PROMPT_R06.md`.
- Initial HEAD: `d265865f67770be34e3c45f83ea07141feb3c5ca`; branch `main`; remote `origin`.
- After fetch, checkout was `0 ahead / 5 behind`, with `origin/main=8de111a23db71d075f70460d15505a2bc0c950c8`. Incoming paths were disjoint from local `project.godot` and two owner-created critique screenshots.
- Followed the standing safe-sync exception: stashed only tracked `project.godot` under `owner-local-safe-sync-d265865` without `-u`, fast-forwarded to `8de111a`, reapplied that exact stash without dropping it, and preserved both untracked owner screenshots.
- Project reconciliation diff was limited to `GameFeelFlow="*uid://ckhnfaf1odnpl"` versus canonical `GameFeelFlow="*res://addons/game_feel_flow/core/game_feel_flow.gd"`; all other autoload/plugin and main-scene settings matched. Restored canonical `project.godot`. Godot later regenerated the UID spelling; it was restored again. Final `project.godot` is byte-identical to HEAD.
- Sync detail: `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/evidence/sync_report.txt`.

## Home freeze

- Accepted Home baseline: `d265865f67770be34e3c45f83ea07141feb3c5ca`.
- `HOME_TARGET_LAYOUT_R04.json` SHA-256: `1a557b1057bcfd2ebf8daa79ed5493a28b7de2860a2275f729b4a6308dbd3222`.
- `scripts/campaign/application_shell.gd` SHA-256: `afee1e949606e0e1afc37389282b88ce429683fb063fed4e2d5e40a1cdbc18c6`.
- All Home PNG hashes and before/after equality are recorded in `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/evidence/home_freeze_hashes_before.txt` and `home_freeze_hashes_after.txt`; the manifests are identical.
- No production Home source, layout, or PNG changed. The focused Home probe exposed one stale test-only expected Energy x coordinate (`254.84375`); the accepted layout has x=`259`. Updated that single probe expectation, reran it, and all checks passed. Home runtime now verifies current campaign level/economy values and real PLAY, WORLD MAP, and SETTINGS pointer navigation.

## Commands and results

- `godot_console.exe --path . --script res://tests/m21_home_exact_target_r04_probe.gd` — PASS after updating the stale probe expectation; exact output in `evidence/home_probe.log`.
- `godot_console.exe --headless --path . --script res://tests/m20_app_shell_probe.gd` — PASS.
- `godot_console.exe --headless --path . --script res://tests/m21_world_map_production_v05_probe.gd` — PASS; real viewport mouse and touch World Map entry.
- `godot_console.exe --headless --path . --script res://tests/m13_island_map_probe.gd` — PASS.
- `godot_console.exe --headless --path . --script res://tests/m14_gameplay_session_bridge_probe.gd` — PASS; gameplay bridge, pause/resume, result/retry/return boundaries.
- `godot_console.exe --headless --path . --script res://tests/m21_r04_gameplay_surface_authority_probe.gd` — PASS, 10 islands / 71 checks.
- `python tools/ui_assets/rebuild_asset_catalog_r04.py` — PASS, 373 current PNG dimensions.
- `python tools/ui_assets/validate_assets.py` — PASS, 373/373 manifest checksums; 10/10 R04 families.
- `godot_console.exe --headless --path . --editor --quit` — PASS; editor import/parse and plugins initialized.
- `godot_console.exe --headless --path . --quit-after 120` — PASS; normal configured main-scene boot.
- `git diff --check` — PASS.
- Exact command output and exit codes: `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/evidence/automated_check_summary.txt` and sibling `.log` files.

## Real-game launch and limits

- Confirmed canonical `run/main_scene="res://scenes/campaign/ApplicationShellScene.tscn"`.
- Launched the actual editor using `godot_console.exe --path . --editor` and the actual configured production game using `godot_console.exe --path .`; both were left running for owner review. The game was not launched via a test harness. The launch did not automate an F5 keypress.
- Probe evidence captures Home, Home-to-World-Map, full World Map, and Sunny Cove Island Map after real pointer input under `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/evidence/`.
- Current gameplay screenshot capture from the live GUI was unavailable through the enabled tools. `gameplay_reference_prior_v06.png` is explicitly prior R04 evidence, not a new R06 capture. The full composite Home→World Map→Sunny Cove→Island Map→level→gameplay→pause/resume→return route was not manually driven end-to-end in the visible game; its boundaries are covered by the named production probes. See `evidence/runtime_smoke_report.md`.
- No owner save/progression/onboarding data was cleared or reset. Probe fixtures use named test-only `user://` paths.
- M07 historical-regression reconciliation and M08 post-PASS process-crash finding remain deferred carry-forward items; not claimed closed.

## Files and final handoff

- Changed: `tests/m21_home_exact_target_r04_probe.gd` (one stale frozen Home coordinate assertion corrected); new R06 evidence under `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/evidence/`; this log.
- `TASKS.md` was not modified.
- Two pre-existing owner critique screenshots remain untracked and untouched. Therefore the required clean `git status` cannot be claimed without publishing or removing those owner files; they are excluded from the task commit.
- Pre-publication repository proof: local HEAD=`8de111a23db71d075f70460d15505a2bc0c950c8`; `origin/main`=`8de111a23db71d075f70460d15505a2bc0c950c8`; remote `main`=`8de111a23db71d075f70460d15505a2bc0c950c8`; ahead/behind=`0/0`.
- R06 implementation/evidence commit: `3d07dab459a6133204c1a3d645d7af1f4560e9ea`.
- Post-push verification for that commit: local HEAD=`3d07dab459a6133204c1a3d645d7af1f4560e9ea`; `origin/main`=`3d07dab459a6133204c1a3d645d7af1f4560e9ea`; remote `main`=`3d07dab459a6133204c1a3d645d7af1f4560e9ea`; ahead/behind=`0/0`. Detailed proof is in `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/evidence/final_repository_proof.txt`.
- The final proof/log-only commit is reported separately in the task handoff; no product files are included in that follow-up.
- Builder handoff marker: `AWAITING_OWNER_FULL_GAME_RUNTIME_REVIEW_R06`.
