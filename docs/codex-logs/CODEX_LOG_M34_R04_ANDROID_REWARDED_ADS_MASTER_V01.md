# Codex Log — BCM-M34 R04 Android Toolchain and Rewarded Ads

## Scope and disposition

Prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R04_ANDROID_REWARDED_ADS_MASTER_PROMPT.md` (SHA-256 `CE8DAB78A895B0DA9C8EF6F173ACA6F30E1BC194257A8E13D027168A70A10E67`). Work item BCM-M34-006; R04-001 through R04-005.

R04-001: inventory complete; Android toolchain absent; no large SDK/NDK/template download or install initiated. R04-002: official AdMob Android v7.0 archive pin/hash verified and package inspected; issue #124 reviewed; integration compatibility not established. R04-003: no adapter integrated because no native build and the plugin's client reward callback does not supply the unique server-verifiable receipt required by the existing economy seam. The provider path remains fail-closed. R04-004: no APK/export/device test; `NOT_DEVICE_VERIFIED`. R04-005: Daily, economy, and M33 navigation regressions pass. Desktop comparison is read-only; no Desktop files/stashes/saves/untracked paths were touched. The prompt mentions two overlapping owner-dirty JSONs, while live refs show zero incoming path overlaps and six dirty JSON files; see proposal.

No production gameplay/economy/plugin configuration was changed. No cleanup candidates were deleted; all 23 R03 cleanup candidates remain KEEP. No production ad IDs, banners, interstitials, IAP product prices/SKUs, signing materials, or purchase fulfillment were enabled. Root `TASKS.md` was not modified.

## Repository and synchronization

- Start HEAD: `2d0d84b91e75459d5ca0c7a3166f4eafb46424b3`.
- Branch: `codex/m34-isolated-20261014-a1`; remote `origin` is the canonical Beach Cocktails repository.
- Sync preflight in the isolated worktree: `git status --short --branch`; `git remote -v`; `git fetch origin main`; `git rev-list --left-right --count HEAD...origin/main` returned `0 5`. The five incoming commits touched `TASKS.md` and current R03/R04 coordination records, not tracked dirty paths in this worktree. `git merge --ff-only origin/main` succeeded to start HEAD `2d0d84b91e75459d5ca0c7a3166f4eafb46424b3`.
- Pre-existing untracked R03 probe outputs and `godot-user-data/` were preserved. All Godot regressions ran with a unique profile under `%LOCALAPPDATA%\\BCM-M34-R04-Godot-Isolated`.
- Desktop canonical checkout was read only: HEAD `5cff38a7b360b917739616aaebf79c13987b8d8c`, current `origin/main` `2d0d84b91e75459d5ca0c7a3166f4eafb46424b3`, `0 ahead / 44 behind`; seven modified tracked paths and its untracked content were left untouched.

## Evidence and checks

- Godot console: `4.7.2.stable.official.ed1daf0bf`.
- `m34_daily_rewards_probe.gd`: exit 0, `M34_DAILY_RESULT=PASS`.
- `m34_economy_closure_probe.gd`: exit 0, `M34_ECONOMY_RESULT=PASS`.
- `m33_campaign_navigation_probe.gd`: exit 0, `M33_NAV_RESULT=PASS`, all ten islands and representative levels after ordered 1,000-level campaign progression.
- The two pre-existing warnings reproduced: `scenes/campaign/WorldMapScene.tscn:3` invalid `uid://b41edy8ohkeyn` with text-path fallback to `world_map_controller.gd` (sidecar `uid://kf3xtrckwhbr`); `scenes/main.tscn:3` invalid `uid://66csd0hftvb2` with text-path fallback to `game_manager.gd` (sidecar `uid://h8h4qcnoqcm4`). They remain unfixed to avoid unrelated accepted scene changes.
- Hashes before/after probes: owner `godot-user-data` tree unchanged; `project.godot` unchanged (`16AEFDC52E70FFEC68CF7BA5726806A607A7BE0B1D0884906CF0E224419EE66A`); `TASKS.md` unchanged (`B66C2E9F97AB6898F36BEA70DBD18B2930AEAB57C961AFB8F9845FB443808507`).
- `rg` product scan found only retired Focus inventory/migration compatibility and unrelated UI focus uses; no active Focus currency reward/purchase path. Existing R04 policy keeps all rewarded claims unavailable without verified provider callback.
- No Android export, clean Android build, native initialization, ADB/device test, or physical-device review occurred.

## Manual checks and limitations

- Performed: read-only Windows path/command inventory; inspected the downloaded archive's files, AAR entry lists, plugin API callback shape, and source-tag license; checked the official issue status; read-only canonical Desktop path/blob comparison; inspected reproduced Godot UID warnings and sidecar UIDs; confirmed existing M34 cleanup candidate disposition remains KEEP.
- Not performed: Android export/build, Android provider initialization, device install/startup, physical ad presentation, owner visual/device acceptance, store submission, IAP/receipt validation, or desktop JSON reconciliation writes. No SDK installation was attempted.
- Remaining owner setup: install/configure the official Android prerequisites into a bounded non-Desktop location, provide device and permission for `adb` validation, and resolve the R04 prompt's two-overlap count discrepancy against the actual Desktop/local refs. Native rewarded claims remain gated on a trusted receipt/verifier design.

## Files added

- This master log.
- `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R04/android_toolchain_inventory.json`
- `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R04/admob_plugin_review.json`
- `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R04/desktop_readonly_merge_proposal.md`
- Five R04-001..005 child logs and three Godot stdout files plus regression summary in the same evidence folder.

## Final repository state

- Files changed are limited to R04 evidence and this execution log; implementation files, `TASKS.md`, Desktop files, R03 cleanup candidate assets, MOVES/tutorial assets, `project.godot`, and owner save data were not changed.
- `git diff --check` passed after writing the evidence. JSON parse checks passed for `android_toolchain_inventory.json`, `admob_plugin_review.json`, and `regression_summary.json`. Stage-path inspection, commit SHA, push result, final `HEAD`/`origin/main`/remote SHA parity, and `0/0` divergence are recorded after publication below.
- The builder stop marker after publication is `AWAITING_GPT_M34_R04_INDEPENDENT_AUDIT_AND_NATIVE_DEVICE_GATE`.
