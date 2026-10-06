# Codex Execution Log — BCM-M21-006-R03 Final Release Closure

## Work item and scope

- Work item: BCM-M21-006-R03
- Prompt: `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/CHATGPT_FINAL_RELEASE_PROMPT_R03.md`
- Locked criteria: `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/CHATGPT_FINAL_RELEASE_CRITERIA_R03.md`
- Start HEAD: `8801136b18a502d08e5f03b1995f470ad5b1ecad`
- End HEAD for implementation/evidence: `c2ef88d772c8a5ae38a99f9c1b24e92eb09af2fe` (the Codex log is published in the following log-only commit).
- Branch / remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`)
- Release scope remained limited to stale regression-probe expectations, R03 evidence, and this log. No production visual or gameplay code was changed. M22 was not started.

## Sync preflight and owner-work preservation

- Initial local HEAD: `b213fbd`; initial branch: `main`; configured `origin` matched the canonical repository.
- `git fetch origin main` reported local main was behind-only, 0 ahead / 8 behind.
- All dirty paths were inventoried before sync: tracked `project.godot`; untracked owner critique PNGs at `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence/02_home_reference_941x1672 kritik.png` and `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence/owner-critique-v02/02_home_owner_critique_v02_941x1672 kritik.png`.
- Incoming `origin/main` paths were disjoint from those local paths. The exact tracked-only stash `owner-local-safe-sync-b213fbd` was applied without dropping it; untracked critique files were left untouched. Fast-forward completed to `8801136b18a502d08e5f03b1995f470ad5b1ecad`.
- Older owner-local safe-sync stashes were left untouched. No local owner work was staged or committed.
- Active task and locked R03 prompt/criteria were read only after synchronization. Root `TASKS.md` was not modified.

## project.godot reconciliation

The only tracked drift was the GameFeelFlow autoload path spelling: canonical `res://addons/game_feel_flow/core/game_feel_flow.gd` versus the local Godot UID `uid://ckhnfaf1odnpl`. The adjacent `.gd.uid` sidecar contains that same UID. No semantic configuration difference was present. Canonical bytes were restored; SHA-256 is `DE79FF257F4F4BE0DBE01BECB574A3E502F9BF36F07CF662B293A4B6242D0267`. Editor import later re-emitted the same UID path form, which was checked against the sidecar and restored again. Final `project.godot` has no diff.

## Changes made

- Updated M07 probes to current accepted HUD art paths, one-row L01–L12 progression, held-drink indicator, To-Go geometry, and live score recess dimensions. Created a new independent inner-content layout fixture v03; historical v02 remains unchanged.
- R06 initially exposed that its old score-recess rectangles used source-panel pixels without scaling. The measured center error was about 9.3 px. Assertions now scale those reference rectangles by actual panel dimensions while retaining the original 1.5 px center bound and 4 px containment bound.
- Updated the M21 performance probe’s Home PLAY assertion to match the accepted R08 frontier behavior (PLAY opens current frontier gameplay), then explicitly returned through the production router to World Map for map-cycle profiling.
- No production runtime, accepted art, gameplay physics, campaign definitions, or export configuration was changed.

## Commands and results

All detailed stdout/stderr logs are retained in `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/evidence/`.

- M07 R04, R05, composition, and R06 current owner-layout probes: each final run PASS, process exit 0; three viewport layouts were covered. Logs: `m07_r04_final_1.log`, `m07_r05_current.log`, `m07_hud_composition_final_3.log`, `m07_r06_normal_final.log`. The earlier stale/failing diagnostics are retained alongside the final runs. No tolerance was increased.
- M08 normal GL process/economy/session probe run twice consecutively: both `M08_TO_GO_DELIVERY_RESULT=PASS`, exit 0, all captures saved, no `SCRIPT ERROR`, `ERROR`, or access-violation output. Logs: `m08_normal_run_3.log`, `m08_normal_run_4.log`.
- R08 Home frontier probe: PASS, exit 0; replay level 4 left frontier 11 and completing it advanced to frontier 12. Log: `r08_home_frontier.log`.
- R09 V05 World Map real mouse/touch chain: two runs PASS, exit 0, each retained seven captures with mouse and touch paths passing. Logs: `r09_world_map_run_1.log`, `r09_world_map_run_2.log`.
- R07 page focus, R07 node visual/stars, and full Sunny Cove background: all PASS, exit 0. Logs: `r07_page_focus.log`, `r07_node_visual.log`, `r07_full_background.log`.
- M18 stars/replay/cumulative rewards/reward claim and M20 ApplicationShell: all PASS, exit 0. Logs: `m18_star_contract.log`, `m18_replay.log`, `m18_cumulative_rewards.log`, `m18_reward_claim.log`, `m20_app_shell.log`.
- Fresh-save full production progression: `M21_CHILD_03_RESULT=PASS completed=100 checkpoints=5`, exit 0. The isolated schema-2 save records L1–L100 complete, Tiki unlocked, and Tiki level count 0 / Level 1 not launchable. Machine-readable report: `M21-003_FULL_PROGRESSION.json`; full log: `m21_full_progression.log`.
- Performance/stability profile: final run `M21_CHILD_02_RESULT=PASS samples=21 frame_samples=60`, exit 0; 12 map cycles, 8 gameplay cycles, 20 save/settings I/O cycles, zero orphan nodes. It is a Windows desktop GL Compatibility host profile, not a physical-device benchmark. Report: `M21-002_PERFORMANCE_STABILITY_PROFILE.json`; final log: `m21_performance_profile_final.log`. An earlier run failed only the now-stale Home PLAY destination assertion; the updated probe passed.
- Save/restart persistence: `M21_RELEASE_PERSISTENCE_RESULT=PASS`, exit 0; production shell, onboarding, settings, campaign completion, and no debug progression bypass verified across restart. Log: `m21_release_persistence.log`.
- Accepted gameplay regressions M01, M02, M03, M09, M13, M14, M15 and the R04 gameplay-surface authority probe: all PASS, exit 0. R04 surface probe covers all ten islands and 71 checks. Logs: `m01_contract_probe.log`, `m02_physics_regression.log`, `m03_economy_regression.log`, `m09_audio_haptics_probe.log`, `m13_island_map_probe.log`, `m14_gameplay_session_bridge_probe.log`, `m15_vip_boosters_economy_probe.log`, `m21_r04_gameplay_surface_authority_probe.log`.
- `python tools/ui_assets/validate_assets.py`: exit 0; 373/373 current PNG checksums and 10/10 R04 source/runtime/profile families pass. Log: `asset_validation.log`.
- `godot_console.exe --headless --editor --path . --quit`: exit 0. `godot_console.exe --headless --path . --quit`: exit 0. Logs: `godot_import_parse.log`, `godot_boot.log`.
- `git diff --check`: exit 0 before publication. The final published tree has no tracked changes.

## Release/export manifest

Godot reports `4.7.2.stable.official.ed1daf0bf`; `project.godot` selects `res://scenes/campaign/ApplicationShellScene.tscn` and 720×1280. No `export_presets.cfg` is present, so no distributable or signed artifact was produced; the artifact list is empty. See `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/evidence/release_manifest.json`.

## Manual checks and limitations

- Performed automated real mouse/touch interaction through the production World Map route in two normal renderer runs.
- No new owner-native F5 review, physical-device run, clean-machine installation, or package signing was performed. M21-001 owner visual/runtime acceptance remains the supplied R09 acceptance; this closure did not alter those production bytes.
- The two listed owner critique PNGs remain untracked local evidence, were not staged, and are outside product/release inputs.
- The inactive Economy Draft V01 was not implemented. `TASKS.md` remains byte-for-byte unchanged and was never staged.

## Repository identity at implementation-evidence publication

- Implementation/evidence commit SHA: `c2ef88d772c8a5ae38a99f9c1b24e92eb09af2fe`.
- At publication of that commit, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned that SHA; ahead/behind was `0/0`.
- Subsequent log-only publication is recorded in Git history. The two owner critique PNGs are the only remaining untracked paths; tracked working tree is clean.

## Builder stop marker

`AWAITING_GPT_M21_FINAL_RELEASE_AUDIT_R03`
