# BCM-M32-R02 Current-Campaign Integration Regression — V01

Status: `AWAITING_GPT_M32_R02_AUDIT`.

## Authority and scope

- Prompt: `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/CHATGPT_M32_R02_INTEGRATION_REGRESSION_PROMPT_V01.md`.
- Read with the M32 R01 independent audit, original M32 independent audit, M32 audit criteria, M33 master prompt, and M33 Tiki continuity follow-up.
- Branch/remote: `main`, `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Synchronized start HEAD: `0e133268cb2bafbe246e3d1b1f6cd00f66ba34a0`.
- Implementation and test-evidence commit: `d539da33ad1e1ba28c070acc3b19a8e77ae83585`.
- Scope was limited to the two stale M32 staged-content probes and new R02 evidence. Production gameplay, campaign content, economy, tutorial implementation, saves, owner assets, and root `TASKS.md` were not changed.
- Root `TASKS.md` remained byte-for-byte unchanged (`git diff --exit-code HEAD -- TASKS.md` exited 0 before publication).
- This execution log was authored after the two probe edits and their validation had begun; the implementation/evidence commit therefore precedes the log publication commit. The task chronology and evidence are recorded below.

## Sync and owner-work preservation

- Initial canonical Desktop preflight: branch `main`, local HEAD `95d13ff8458d4888ebca6e4b18da35ae21feb820`, behind-only by three commits. `origin` was `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Incoming paths were only `TASKS.md`, the M32 R01 independent audit, and the R02 prompt. They did not overlap the seven modified tracked owner paths or five untracked owner paths.
- Applied the authorized tracked-only sync procedure with retained stash `owner-local-safe-sync-95d13ff`; fast-forwarded to `0e133268cb2bafbe246e3d1b1f6cd00f66ba34a0`; applied the exact new stash without dropping it. Untracked owner paths were not stashed or changed.
- Owner-local M21/M22 evidence, `project.godot`, M21 PNGs, M23 evidence, and `CODEX_LOG_M23_R01_V01.md` remained unstaged and outside the R02 commits.
- Before publishing the implementation/evidence commit, fetched `origin/main`; local main was exactly one commit ahead and zero behind. Pushed normally, then verified `HEAD = origin/main = remote main = d539da33ad1e1ba28c070acc3b19a8e77ae83585`; divergence was `0/0`.

## Changes

- `tests/m32_campaign_contract_probe.gd`: now loads an explicit M32 staged fixture from Sunny Cove and the original `tiki_island.json` seed. The fixture keeps Sunny Cove at 100 levels and Tiki at 12, marks later staged counts empty, preserves the campaign's 10-island/100-level contract, and retains the FULL-mode fail-closed assertion for that fixture. Separately loads canonical M33 content in FULL mode and asserts 100 rows for each of the ten canonical islands and exactly 1,000 authored levels.
- `tests/m32_tiki_vertical_slice_probe.gd`: uses the same explicit M32 staged fixture so the original 12-level Tiki slice and production L1 integration semantics remain tested after M33 content delivery.
- Added probe outputs, successful clean-import output, graphical tutorial capture report, and two new PNG captures under `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/evidence/M32-R02/`.
- Existing M32 R01 tutorial evidence and historical M17 test/report files were not overwritten.

## Isolated Godot validation

- Godot: `4.7.2.stable.official.ed1daf0bf`.
- Sandbox worktree: `C:\Users\sekip\.codex\worktrees\bcm-m32-r02-current-campaign`, detached at synchronized start HEAD and outside Desktop.
- Project identity and custom `user://` path: `BCM-M32-R02-Current-Campaign-20261012`; `C:\Users\sekip\AppData\Roaming\BCM-M32-R02-Current-Campaign-20261012` did not exist before the first launch. Test-created saves/logs remain isolated there. Owner saves and rotating logs were not opened.
- A first ordinary headless-editor attempt stalled during startup; the exact sandbox-bound process pair was verified and task-cleaned. A subsequent `--headless --recovery-mode --import` completed successfully with exit 0 after importing 1,515 asset steps; output is in `evidence/M32-R02/clean_import_recovery.txt`.
- Runtime logs warn that two scene UIDs are unavailable and fall back to their explicit text paths. The M32/M33 probes below still completed with exit 0.
- Headless script probes, each exit 0:
  - `tests/m32_campaign_contract_probe.gd` — `M32_CONTRACT_PROBE_RESULT=PASS`.
  - `tests/m32_tiki_vertical_slice_probe.gd` — `M32_TIKI_VERTICAL_SLICE_RESULT=PASS`, including real production physics trial, World Map/Island Map navigation, results, retry, save/reload, and the twelve Tiki level nodes.
  - `tests/m32_economy_shop_probe.gd` — `M32_ECONOMY_SHOP_RESULT=PASS`.
  - `tests/m32_focus_booster_probe.gd` — `M32_FOCUS_BOOSTER_RESULT=PASS`.
  - `tests/m32_economy_tutorial_probe.gd` — `M32_ECONOMY_TUTORIAL_RESULT=PASS`.
  - `tests/m32_r01_m17_semantic_coverage_probe.gd` — `M32_R01_M17_SEMANTIC_RESULT=PASS`.
  - `tests/m33_campaign_content_probe.gd` — `M33_CONTENT_RESULT=PASS`.
  - `tests/m33_campaign_navigation_probe.gd` — `M33_NAV_RESULT=PASS`.
  - `tests/m33_content_unavailable_probe.gd` — `M33_UNAVAILABLE_RESULT=PASS`.
  - `tests/m33_tiki_compatibility_probe.gd` — `M33_TIKI_COMPAT_RESULT=PASS`.
- The original `tests/m17_canonical_screening_probe.gd` remains historical evidence and was not rewritten or rerun in R02. R01 recorded its exit 1 with the historic V03A exact-signature and L4/L60/L100 candidate-only VIP assertions. That historic status is separate from the passing R01 present-semantics probe and is not presented as current M32 validation.

## Graphical tutorial capture

- Ran `tests/m32_tutorial_mobile_capture_probe.gd` without `--headless`, using the Windows display driver and GL Compatibility renderer. The actual renderer reported OpenGL 3.3.0 Compatibility on Intel Iris Xe Graphics.
- With Reduced Motion and High Contrast enabled, the tutorial was visible and the prompt remained inside both requested viewports. Exit 0; `M32_TUTORIAL_MOBILE_RESULT=PASS`.
- Captures were verified as 390×844 and 432×960 PNGs and visually inspected. New evidence is stored as `tutorial_portrait_390x844.png`, `tutorial_portrait_432x960.png`, and `tutorial_mobile_capture.json` under the R02 evidence directory. Prior tutorial evidence files were not replaced.
- This is a Windows GL capture, not owner-native device approval or physical device QA.

## Checks, limitations, and handoff

- `git diff --check` passed for the two changed probes. `git diff --cached --check` passed for all 18 implementation/evidence paths.
- Manual checks: visually inspected both generated captures; checked exact PNG dimensions, Reduced Motion/High Contrast report fields, isolated user-data identity, sandbox-bound process cleanup, and staged path scope.
- Not performed: owner-native/mobile device acceptance, physical reachability or human playtesting for the 899 M33 levels outside preserved Tiki L1's bounded trial, release/signing/store work, or tracker transition.
- The 12 M32 Tiki seed levels remain unchanged and preserved as the documented M33 continuity exception. M33 static uniqueness/integration results do not establish physical solvability of the other 899 new levels.
- Final stop marker: `AWAITING_GPT_M32_R02_AUDIT`. Independent audit and any later `TASKS.md` transition remain with ChatGPT.
