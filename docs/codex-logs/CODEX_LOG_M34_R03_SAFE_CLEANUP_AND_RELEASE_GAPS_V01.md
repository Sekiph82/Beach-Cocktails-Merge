# BCM-M34-R03 | Safe Cleanup and Release Gaps — Codex Execution Log V01

## Scope and repository state

- Governing prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R03_SAFE_CLEANUP_AND_RELEASE_GAPS_MASTER_PROMPT.md`.
- Work item: M34-R03-001 through M34-R03-005. Branch `codex/m34-isolated-20261014-a1`, remote `origin`, publication target `main`.
- Worktree: `C:\Users\sekip\AppData\Local\Packages\OpenAI.Codex_2p2nqsd0c76g0\LocalCache\Local\BCM-M34-safe-worktree\m34-20261014-a1`.
- Start HEAD after sync: `741e251ecd6870dbf22b5f2b883c65a1d2532068`.
- Start sync preflight: status showed only pre-existing untracked `godot-user-data/`; remote URL was `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`; fetch and ahead/behind check found 0 ahead / 2 behind; incoming diff touched the R02 audit and this R03 prompt only; fast-forwarded to the start HEAD above. The untracked profile was left untouched. No stash was created.
- `TASKS.md` was not modified. Its SHA-256 at handoff: `DEDE18079607C48B9E3CD3366E50D763BD56460F3CBD501D4E3C0981CA8EF58D`.
- `project.godot` was not modified. Its SHA-256 before and after the Godot probes: `16AEFDC52E70FFEC68CF7BA5726806A607A7BE0B1D0884906CF0E224419EE66A`.
- Existing untracked `godot-user-data/` and all canonical Desktop owner files/saves were preserved. No canonical Desktop synchronization was attempted in this task; see separate sync gate below.

## R03-001 — cleanup review

- Reviewed all 23 paths marked `REVIEW` in `evidence/M34-005/cleanup_inventory_r02.csv`. Machine-readable decisions, per-file byte sizes, SHA-256 digests, reference findings, future/source provenance, and rollback disposition are in `evidence/M34-R03/cleanup_review_r03.csv`.
- Result: **23 KEEP, 0 DELETE**; 64,001,602 source bytes reviewed (61.04 MiB). No source bytes were removed. No deletion was justified by absence of a literal runtime path alone.
- Provenance evidence: `assets/ui_assets/README.md` identifies contact sheets as historical audit evidence, V05 atlases as extraction sources, and the style boards as visual direction references. `assets/ui_assets/v04_masters/README.md` identifies each master’s future mapping and names the style boards used to ground generation. `assets/ui_assets/ASSET_MANIFEST.json` and `ASSET_DIMENSIONS.csv` catalog the candidate assets. The v01 World Map background is also named by the owner-directed composition record. Logo concepts and the World Map contact sheet have no explicit owner deletion/supersession ruling; ambiguity defaults to KEEP.
- The asset search covered `AGENTS.md`, `TASKS.md`, asset catalogs, `data/`, `docs/`, current M34 prompts, `scenes/`, `scripts/`, `tests/`, `tools/`, `addons/`, and `project.godot`, including literal/dynamic load APIs and export references. No candidate is loaded by a current runtime scene or data path found in that scan. Generic `load`, `preload`, `ResourceLoader`, and directory-based loading sites remain a false-positive risk if inferred from absence alone.
- Expanded source scan: the project `scripts/` tree has 32 GDScript files; static resource-path references were recorded in `evidence/M34-R03/script_module_scan_r03.csv`. Addons contain 226 source modules. No script/module was deleted: a static path scan does not close class-name, UID-based, plugin, or dynamic-dispatch references, and no module met the required safe-deletion proof.
- There is no `export_presets.cfg`, reproducible Android export, or measured shipping bundle. Shipping export size is therefore **not measured**; the 64,001,602-byte figure is source size only.
- Rollback commit: not applicable because this review produced no deletion.

## R03-002 — scene UID fallback warnings

- Two scene references contain IDs that disagree with the current script UID sidecars:
  - `scenes/campaign/WorldMapScene.tscn:3` uses `uid://b41edy8ohkeyn`; `scripts/campaign/world_map_controller.gd.uid` contains `uid://kf3xtrckwhbr`.
  - `scenes/main.tscn:3` uses `uid://66csd0hftvb2`; `scripts/game_manager.gd.uid` contains `uid://h8h4qcnoqcm4`.
- Exact Godot warning text: `WARNING: res://scenes/campaign/WorldMapScene.tscn:3 - ext_resource, invalid UID: uid://b41edy8ohkeyn - using text path instead: res://scripts/campaign/world_map_controller.gd`; and `WARNING: res://scenes/main.tscn:3 - ext_resource, invalid UID: uid://66csd0hftvb2 - using text path instead: res://scripts/game_manager.gd`.
- Both scenes load their scripts through the text paths and the R03 gameplay/navigation probes pass, but correcting the stale IDs requires changing those accepted scene files or changing authoritative script UID metadata. That exceeds this prompt’s safe edit boundary. The issue is **deferred**, not silently fixed. No clean editor import was run because it could rewrite project/scene metadata; no accepted scene, art, or `project.godot` was edited.

## R03-003 — MOVES HUD owner-review package

- Added a deterministic capture probe at `tests/m34_r03_owner_review_capture.gd`. It runs the production `scenes/main.tscn` with Godot 4.7.2 on the Windows renderer at the requested output dimensions. It exercises real viewport touch-drag input for before/after frames; the one-move-left state is constructed through the production move-budget bridge for a deterministic frame. The tutorial is started through the production tutorial entry point.
- Capture result: **PASS, 8 frames**, no probe failures. `capture_manifest.json` records each pixel size, state, remaining-move label, renderer, and that these are not physical-device captures. Owner visual review remains `PENDING`.
- Captures (all under `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review/`):
  - [390×844 before touch](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review/390x844_before_touch.png)
  - [390×844 after touch](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review/390x844_after_touch.png)
  - [390×844 low moves](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review/390x844_low_moves.png)
  - [390×844 tutorial](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review/390x844_tutorial.png)
  - [432×960 before touch](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review/432x960_before_touch.png)
  - [432×960 after touch](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review/432x960_after_touch.png)
  - [432×960 low moves](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review/432x960_low_moves.png)
  - [432×960 tutorial](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review/432x960_tutorial.png)
  - [Capture manifest](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review/capture_manifest.json)
- Manual frame review checked the tabletop, launch drink, To-Go/VIP panels, NEXT, score panels, progression strip, and red deadline line in both sizes and all four states. Gameplay frames keep the HUD off the playable board. In tutorial frames, the tutorial UI replaces the progression shelf area; owner review should decide whether that tutorial-state presentation is acceptable. This is visual evidence only, not owner acceptance or device verification.
- In-project reproduction: open the repository with Godot 4.7.2 and run Project; use the Home campaign entry to reach Tiki Island level 27. To reproduce all eight deterministic review captures, run `godot --path <repository-root> --script res://tests/m34_r03_owner_review_capture.gd`. No Desktop-root launcher was added.

## R03-004 — Ads/IAP release gap assessment

- No Android/AdMob plugin exists in `addons/`; no Android export preset exists. The inspected host has no `adb`, `java`, or `gradle` command available and no configured `ANDROID_HOME`/`ANDROID_SDK_ROOT`. The common Android SDK path is absent. The Godot 4.7.2 template directory contains web templates only and no Android export template. No plugin or SDK artifact was downloaded or integrated.
- Current official candidate: `godot-sdk-integrations/godot-admob` v7.0, pinned to signed tag commit `4b4ddceab0be81f0dcb12a6313038dba6cf9eacf`. The release says it targets Godot 4.7 and is tested against 4.7. The Android archive is published as `AdmobPlugin-Android-v7.0.zip`, 260 KB, SHA-256 `ce38b75aeb4bb870fda8b74e1513d807696d8485d237c263b7b7a9613493aee8`; this is provenance metadata only and the artifact was not fetched. The plugin LICENSE is MIT. Official release, asset checksum, license, setup, and issue sources are linked in the independent task response.
- Primary references: [v7.0 release](https://github.com/godot-sdk-integrations/godot-admob/releases/tag/v7.0); [published release asset checksums](https://github.com/godot-sdk-integrations/godot-admob/releases/expanded_assets/v7.0); [MIT license at v7.0](https://github.com/godot-sdk-integrations/godot-admob/blob/v7.0/LICENSE); [issue #124](https://github.com/godot-sdk-integrations/godot-admob/issues/124); [Godot 4.7 Android export setup](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html).
- Open issue #124 reports a Godot 4.7 Android initialization failure. Its original issue remains labeled reported/not investigated; the reporter later says an AAR was not found by the editor and copying it into `android/build/bin` allowed the editor to see it. This is one user report, not a confirmed general root cause or verified resolution.
- The exact v7.0 Google Mobile Ads SDK/Gradle transitive dependency versions remain **unverified** because the plugin archive/source was intentionally not fetched. Do not substitute a guessed dependency version. Verify the official archive checksum, inspect its license and Gradle/AAR dependency declarations, and resolve the AAR/editor discovery report before choosing an integration.
- Safe next phase: configure the Godot Android export environment (Godot 4.7.2 matching export templates; official Godot 4.7 docs recommend JDK 17 and list SDK platform-tools 35+, Build Tools 35.0.1, Platform 35, command-line tools latest, NDK 28.1.13356709, and CMake 3.10.2.4988404); set Android paths in the local editor; create a nonproduction Android export preset; validate the exact plugin archive/checksum/dependency tree; integrate it in a separate bounded change; then run plugin initialization, load/show/fail/close callbacks, and earned-reward-only settlement on an Android test device using test ad unit IDs. Owner-only setup data needed: registered AdMob app ID and rewarded ad unit IDs, account/app consent and privacy configuration, test-device availability, and store/legal decisions. Do not place credentials in chat or source.
- IAP remains disabled and no real store products, purchases, receipt verification, or deployment were introduced. R03 Economy probe confirms placeholders cannot fulfill purchases, even with a mock verifier.

## R03-005 — preserved behavior and probe results

- No economy/config/gameplay production source or R02 Daily Rewards JSON was changed. The existing R02 authority remains UTC-midnight reset with the five values: free 40 Coins; rewarded +20 Energy; +40 Coins; +2 Gems; +80 Coins. No Focus currency was added. Accepted 4T/VIP/stars/no-timer behavior was not changed.
- Godot runtime: `4.7.2.stable.official.ed1daf0bf`, Windows renderer for the capture probe.
- `godot --headless --path <root> --script res://tests/m34_daily_rewards_probe.gd` — **PASS**, exit 0; `M34_DAILY_RESULT=PASS`. Evidence: `evidence/M34-R03/m34_daily_rewards_probe.run.log`.
- `godot --headless --path <root> --script res://tests/m34_economy_closure_probe.gd` — **PASS**, exit 0; `M34_ECONOMY_RESULT=PASS`. Evidence: `evidence/M34-R03/m34_economy_closure_probe.run.log`.
- `godot --headless --path <root> --script res://tests/m33_campaign_navigation_probe.gd` — **PASS**, exit 0; all ten production World Map → Island Map routes exposed representative levels 1, 50, and 100, with the 1,000-level completion/unlock chain. Evidence: `evidence/M34-R03/m33_campaign_navigation_probe.run.log`.
- `godot --path <root> --script res://tests/m34_r03_owner_review_capture.gd` — **PASS**, exit 0; 8 captures and real viewport touch-drag committed one move at both target sizes. Evidence: `evidence/M34-R03/owner_review_capture.run.log` and `owner-review/capture_manifest.json`.
- The first capture-probe run reported three GDScript type-inference parse errors; the new probe was corrected with explicit `Dictionary` types and then passed. No production source was changed to address that probe-only issue.
- All gameplay probe logs continue to show the two pre-existing invalid scene UID fallback warnings described in R03-002. No clean import, Android export, physical-device test, store test, or owner visual acceptance was performed.

## Commands, changed files, and final proof

- Focused commands: `git status --short --branch`; `git remote -v`; `git fetch origin main`; `git rev-list --left-right --count HEAD...origin/main`; `git diff --check`; the four Godot commands above; read-only `rg` scans over runtime/config/data/tests/tools and source-provenance files; `git hash-object`/`Get-FileHash` for preservation and candidate evidence.
- Intended task-owned changes: this log; `tests/m34_r03_owner_review_capture.gd`; `evidence/M34-R03/cleanup_review_r03.csv`; `evidence/M34-R03/script_module_scan_r03.csv`; the four probe/capture run logs; `evidence/M34-R03/owner-review/` manifest and eight PNGs. No `TASKS.md`, production scenes, accepted art, `project.godot`, economy, Daily Rewards JSON, save data, cache, or owner-local work was modified.
- Child commits: `bdb1190f` — owner-review probe and eight captures; `7bd237820dce62a879ccd31d22d8e61a9adcd36f` — cleanup/script review inventory and focused probe logs.
- Start HEAD: `741e251ecd6870dbf22b5f2b883c65a1d2532068`.
- Task-content publication SHA: `831be253a1f99aba56e7a1fab203a013940202bd`.
- After pushing that changeset, verified `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `831be253a1f99aba56e7a1fab203a013940202bd`; ahead/behind was `0/0`; `git diff --check` and `git diff --cached --check` passed. A final log-only amendment is being published after this verification snapshot; its resulting HEAD is reported in the task handoff.
- Canonical Desktop read-only snapshot (no fetch or mutation): branch `main`, local HEAD `5cff38a7b360b917739616aaebf79c13987b8d8c`, local `origin/main` ref `831be253a1f99aba56e7a1fab203a013940202bd`, status `behind 37`. It has tracked owner modifications in six M21/M22 evidence JSONs and `project.godot`, plus untracked M21 screenshots, M23 evidence/logs, and `f647e4ff-b906-40e7-93f8-3c4b59d95b23.png`. None were touched. This owner-dirty, behind checkout remains a separate reconciliation gate and was not synchronized. Current release readiness remains blocked on owner review of the captures, the accepted-scene UID decision, Android environment/artifact validation, and native-device ad/store acceptance.

## Builder stop marker

`AWAITING_GPT_M34_R03_INDEPENDENT_AUDIT_AND_OWNER_MOVES_REVIEW`
