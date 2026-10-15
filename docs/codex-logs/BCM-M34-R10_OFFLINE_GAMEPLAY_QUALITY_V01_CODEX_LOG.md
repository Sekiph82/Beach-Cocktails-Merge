# BCM-M34-R10 Offline Gameplay Quality and Release Hygiene — Codex Log V01

## Work item and repository state

- Prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R10_OFFLINE_GAMEPLAY_QUALITY_MASTER_PROMPT.md` (R10-001 through R10-005).
- Start HEAD: `698284eb6d8286867abfd76e86a82f4964ab2061`.
- Branch: existing detached worktree `C:\Users\sekip\.codex\worktrees\bcm-m34-r09-deferred-20261015`; no branch or worktree was created.
- Remote: `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- At task start, the canonical Desktop checkout was `0a40b07fb9d9434538cd3ea7cd0a68fd3eab0c8d`, behind 3/ahead 0. The seven modified tracked paths were inventoried; all untracked owner paths were preserved. The incoming diff touched `TASKS.md` and the active M34 R09 audit/R10 prompt and was path-disjoint from owner paths. Applied the authorized tracked-only stash `owner-local-safe-sync-0a40b07`, fast-forwarded to `698284eb6d8286867abfd76e86a82f4964ab2061`, then reapplied that stash without dropping it. The older overlapping M34 worktree and its untracked data were left untouched.
- The implementation worktree began clean at `698284e`. `TASKS.md` was read-only throughout and was not modified.

## Implementation and evidence

### R10-001 — Bounded mechanical gameplay sample

- Added `tools/campaign/m34_r10_offline_gameplay_quality.gd`, using the existing M17 `MERGE_AWARE_V01` deterministic lane policy with production GameManager/Drink physics and ShotController move commits. Godot was 4.7.2.stable.official.ed1daf0bf, decision scale 1.0, timer disabled, fixed documented seed formula, 20-second per-trial and 360-second aggregate wall budgets.
- Static full-campaign census loaded all 1,000 records across 10 islands (100 each): 2,156 normal order rows, 167 VIP-enabled records, normal objective T minimum 4 / median 40 / maximum 80, zero nonzero time limits, zero timed-feature flags, and each island's L100 was its highest normal-objective T. Census reported `ok=true`, no errors.
- Selected L1 and L100 on each island (20 trials), interleaved round-robin by stratum. Seventeen trials executed: two one-policy/one-seed normal wins, zero terminal failures, 15 budget-limited trials, and three not run after the overall wall budget; 18/20 remain unverified. Total observed wall time was 373 sec because the final running trial crossed the 360-sec check by 13 sec. The first grouped-order exploratory run was stopped after 11 trials with poor island coverage and retained as `offline_gameplay_quality_grouped_partial.json`; the interleaved report is the final sample.
- VIP optional completion was separately probed through `GameplaySessionBridge` on canonical Sunny Cove L4 (normal objective T=8): normal orders completed with one VIP order pending and outcome `WIN`.
- Conclusion remains `M33-004 OPEN_HUMAN_FAIRNESS_AND_UNSAMPLED_LEVELS_REMAIN_UNVERIFIED`. This policy is neither an optimal solver nor a human-playability model. A win proves only that one tested policy/seed found one production-physics path; bounded runs and failures do not establish unsolvability or difficulty. No human fairness acceptance is claimed.
- Evidence: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R10/offline_gameplay_quality.json`, corresponding stdout/stderr, and `vip_optional_rule.stdout.txt`.

### R10-002 — Scene UID and import-warning cleanup

- Fixed only stale script UIDs where the referenced script path and current `.gd.uid` sidecar agreed:
  - `scenes/main.tscn`: `scripts/game_manager.gd` → `uid://bb85np3c1r3it`.
  - `scenes/campaign/WorldMapScene.tscn`: `scripts/campaign/world_map_controller.gd` → `uid://kf3xtrckwhbr`.
- Added `.gdignore` markers to the two evidence-only folders containing CSV header labels that Godot had been treating as translation-source candidates: `coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R03/` and `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-005/`. The flagged fields were `two_star...`, `three_star...`, and `active_contract_prompt_refs`. CSVs and generated translation sidecars were preserved. Fresh editor import v04 exited 0 with empty stderr; prior 14 and 23 sidecars remain in place respectively.
- Added and passed `tests/m34_r10_scene_uid_probe.gd`, which instantiates both scenes and verifies their attached script resource paths.

### R10-003 — Existing Android icon and export filters

- Inspected the existing approved `assets/ui_assets/brand/app_icon.png`; did not generate or modify artwork. Asset catalog identifies it as VA-001, 256×256 with alpha, SHA-256 `1B4199B47EE7A92A22FC7133FF0831171EBE1525FBD202173F8A3F7FF6D6AF83`.
- Added the main 192×192 launcher-icon source to the sole Android preset in `export_presets.cfg`. Preset remains `Android Production-Targeted Slim Debug (Nonshipping)`, features `nonproduction,r09_slim_android`, package `org.example.bcm.r09slimdebug`, name `Beach Cocktails Merge R09 Debug`, version `0.0.0-r09-nonshipping`; filters exclude `coordination/**`, `assets/ui_assets/source/**`, and contact-sheet content. No export was run. No separately approved adaptive-icon foreground/background layer pair was found or invented.

### R10-004 — ZIP metadata and APK rebuild boundary

- Added `tools/campaign/m34_r10_zip_metadata_probe.py` and two 154-byte unsigned ZIP controls containing the same 34-byte payload, same filename/order/compression/permissions, with only the DOS timestamp changed. Payload SHA-256 is identical (`203B4EBB8CCFA16858AF93AA8472552C396C06C733DBCBB6E7D4086763C51E4B`); archive SHA-256 changes from `4E69454ABEF024552EA8E856755D9F5F223F98727B23F05E07B96E77794C8D5C` (2020 timestamp) to `BE5FA762FAA37DC4E6D93CD4034697A150548B32B9683A11BA80783B60CFAB37` (2026 timestamp). This isolates one metadata source of byte nondeterminism, not all APK causes.
- No APK was rebuilt. No R09 APK binary was present in this worktree, so APK central-directory metadata and signing were not independently re-read. The prior R09 V02 log records a 301,983,466-byte APK with SHA-256 `4E00378E3E47843A1B1E8585EBFE6F5B44B50996AF9F6BD0F7D60A9800FCCCC2` and reports a differing V01 SHA despite equal size/semantic inventory and the same debug certificate. Those remain prior builder claims, not reverified R10 evidence. No APK binary is included here.
- Evidence: `evidence/M34-R10/zip_metadata_comparison.json`, `repro_probe_2020.zip`, and `repro_probe_2026.zip`.

## Commands and results

- Fresh editor import: `godot_console.exe --headless --editor --path <worktree> --quit`; exit 0, latest v04 stderr empty. Godot rewrote an unrelated `project.godot` plugin resource reference during import; it was restored to its exact starting text, and final `git diff -- project.godot` is empty. Existing `.godot` cache was left intact. User-data paths were isolated under `C:\Users\sekip\AppData\Local\BeachCocktailsM34R10-20261015\appdata`.
- Captured Godot stdout text was normalized from CRLF to LF after `git diff --cached --check` correctly flagged the carriage returns as trailing whitespace. The recorded output text is unchanged; the final staged whitespace check passed.
- Focused probe scripts were run serially with Godot headless; all exited 0 and stderr was empty:
  - `tests/m34_daily_rewards_probe.gd` — `M34_DAILY_RESULT=PASS`, 38/38 checks.
  - `tests/m34_economy_closure_probe.gd` — `M34_ECONOMY_RESULT=PASS`, 24/24 checks.
  - `tests/m33_campaign_navigation_probe.gd` — `M33_NAV_RESULT=PASS`, 17/17 checks.
  - `tests/m34_r09_slim_export_content_probe.gd` — PASS; content manifest checks cover 10 islands/1,000 records and required gameplay/UI content without a coordination runtime dependency.
  - `tests/m34_r10_scene_uid_probe.gd` — PASS; both scene scripts load from the expected paths.
  - `tests/m34_r10_vip_optional_rule_probe.gd` — PASS; optional VIP remains pending when normal completion wins.
  - Main-scene headless startup smoke, `--quit-after 3` — exit 0.
- Machine-readable exit/result index: `evidence/M34-R10/probe_results.json`. Full stdout/stderr are retained next to it.
- `git diff --check` — passed before commit. No phone, ADB, APK install/export, signing, native ad/IAP, or physical-device action was performed.

## Files changed

- `export_presets.cfg`
- `scenes/main.tscn`
- `scenes/campaign/WorldMapScene.tscn`
- `coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R03/.gdignore`
- `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-005/.gdignore`
- `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R10/*`
- `tests/m34_r10_scene_uid_probe.gd`
- `tests/m34_r10_vip_optional_rule_probe.gd`
- `tools/campaign/m34_r10_offline_gameplay_quality.gd`
- `tools/campaign/m34_r10_zip_metadata_probe.py`
- This immutable builder log. No project save data, owner image, APK, build output, `.godot` cache, or root `TASKS.md` change is included.

## Final state and limits

- Root `TASKS.md` was not modified.
- Manual owner playability/fairness, full 1,000-level mechanical solvability, physical-device behavior, adaptive icon rendering, APK metadata/reproducibility, and release readiness remain unverified.
- Stop marker: `AWAITING_GPT_M34_R10_INDEPENDENT_AUDIT`.
- Implementation commit SHA: `6bd4b55` (`Complete bounded M34 R10 gameplay quality evidence`).
- Evidence line-ending normalization commit SHA: `2474fbc479acea8890e6c1f869ff205b9c23c95e` (`Normalize M34 R10 captured log line endings`).
- This builder log is committed separately after those implementation/evidence commits. Final `HEAD`, `origin/main`, and remote `main` parity will be verified after publication and reported in the handoff.
