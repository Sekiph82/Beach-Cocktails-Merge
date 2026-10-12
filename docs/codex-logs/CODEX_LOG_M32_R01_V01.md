# BCM-M32-R01 Remediation Execution Log — V01

Status: `AWAITING_GPT_M32_R01_AUDIT`.

## Authority and scope

- Prompt: `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/CHATGPT_M32_R01_REMEDIATION_PROMPT_V01.md`.
- Audit: `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/CHATGPT_M32_INDEPENDENT_AUDIT_V01.md`.
- Branch/remote: `main`, `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Start HEAD after safe sync: `89a2a27157356f9a7669ec1f553f65c032319d59`.
- Final implementation/evidence commit: `add55f01bb48111d6c87a7295ef72dae30677ee1`.
- Only the new M17 semantic regression probe and M32-R01 evidence were added. No gameplay, campaign data, canonical timer, economy, tutorial, asset, or tracker source was changed.
- Root `TASKS.md` was not modified; `git diff --exit-code HEAD -- TASKS.md` returned 0 before publication.

## Sync and owner-work preservation

- Initial mandatory preflight was run in the canonical Desktop checkout. Starting local HEAD was `de922cd7e43a3bc546c79d318cfbfd24f995e748`, branch `main`, with 0 commits ahead and 4 behind `origin/main` at `89a2a27157356f9a7669ec1f553f65c032319d59`.
- All dirty paths were inventoried. Incoming changes touched only `TASKS.md` and active M32/M33 coordination documents, disjoint from the dirty owner paths. The authorized tracked-only stash `owner-local-safe-sync-de922cd` was created without `-u`; local `main` was fast-forwarded; the exact new stash was applied and retained. Tracked path hashes were restored and untracked owner paths remained present.
- Owner-local files remain unstaged and outside both commits: M21/M22 evidence JSON, `project.godot`, M21 home PNGs, M23 evidence, and `CODEX_LOG_M23_R01_V01.md`. The retained safe-sync stash was not dropped.
- Whole-worktree `git diff --check` reports CR-at-EOL whitespace in pre-existing owner-local modifications. The scoped staged check `git diff --cached --check` passed for all R01 files; no owner file was changed to silence the unrelated warnings.

## Runtime isolation

- Godot: `4.7.2.stable.official.ed1daf0bf`.
- Sandbox: `C:\Users\sekip\.codex\worktrees\bcm-m32-r01-canonical-screening`, detached at the synchronized start HEAD and outside Desktop.
- Project identity: `BCM-M32-R01-Isolated-20261012`; custom `user://` path: `C:\Users\sekip\AppData\Roaming\BCM-M32-R01-Isolated-20261012`.
- That unique user-data path did not exist before the first run, so there were no prior saves/logs there to back up. Owner saves and rotating logs were not accessed.
- Clean editor import exited 0. It emitted two invalid scene UID warnings and fell back to each scene's explicit text path; no parse/import error remained.
- Git's Windows `autocrlf` setting converted campaign JSON in the newly created sandbox to CRLF, which invalidated raw-byte manifest hashes. I restored only the private sandbox copies to exact checked-in LF bytes before final M32/M33 tests; all ten manifest hashes then matched. Canonical project data and manifest were untouched.
- Godot console/window PID and command lines were verified against the sandbox path. One headless mobile-capture probe stopped after its renderer returned a null screenshot texture; only the exact task-owned process pair for that probe was terminated. Final process query found no Godot process for this sandbox.

## Findings and expected-versus-actual evidence

### V03A exact-signature assertion

- The original `tests/m17_canonical_screening_probe.gd` still expects V04's historical signatures to match current Sunny Cove data exactly. Its comparator includes `time_limit_sec`.
- V03 and V04 each retain five trial rows for levels 1, 10, 11, 50, 51, and 100. The new semantic probe confirms that each V04 trial array exactly equals its V03 source array and that V03 timer metadata equals the historical V04 signature timer.
- The six historical timers are 20, 80, 60, 180, 140, and 300 seconds. The current six level records have `time_limit_sec=0`; their normal orders and other challenge-signature fields still match. The no-timer rule is current owner authority. The old exact-current comparator is therefore stale after the authorized data change, not evidence of a production defect.
- Provenance limit: V04 declares Sunny Cove SHA-256 `9feabee63be44cfbb2b9db7527a06b1b0e3f072c6859f4e7b8c6b3d7d9f25495`, while the raw Sunny Cove file at V04's publication commit is `23d3948d31289a67e38ae3f7e1b3a595467531a2e704ea0ab8d616eebfb220d9`; current raw source is `573b5ca14ca75bec04f40a5b7d00aa441534a266569b200e36e78b28d3591128`. The historical report's full canonical-data binding remains unverified. No physical-screening claim is made for the current untimed signatures.
- The original assertion and report were preserved unchanged. Current semantic coverage was added in `tests/m32_r01_m17_semantic_coverage_probe.gd`.

### L4/L60/L100 VIP-second assertions

- The old fixture expects capture for any distinct VIP level, but each fixture provides only the VIP cocktail and no reserve inventory. Under the locked V05 reserve rule, those candidates are still useful to unfinished normal orders: L4 VIP L5 contributes toward L6; L60 VIP L7 contributes toward L8; L100 VIP L7 contributes toward L8/L7.
- Actual original fixture result: VIP delivered remains 0 at all three levels. Production `GameManager` correctly protects each reserve-contributing drink.
- The new probe confirms both sides of the rule through the production `on_merged` route: candidate alone is not captured and normal objectives are unchanged; after supplying reserve inventory plus one extra VIP candidate, the surplus candidate is captured once and normal objectives remain unchanged.
- Exact reserve boards for surplus cases: L4 `[5,5]`; L60 `[7,7,6,5]`; L100 `[7,7,7,6,5]`.

## Commands and validation results

All Godot runs used the isolated identity above. Console outputs and the classification record are in `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/evidence/M32-R01/`.

- `godot_console.exe --headless --path <sandbox> --editor --quit`: exit 0; two UID fallback warnings described above.
- `tests/m17_canonical_screening_probe.gd`: exit 1, preserving the original four assertions red: V03A current exact signature; L4, L60, L100 VIP capture with candidate-only boards.
- `tests/m32_r01_m17_semantic_coverage_probe.gd`: exit 0. Historical payload/timer checks and all reserve/surplus production cases passed.
- `tests/m32_campaign_contract_probe.gd`: exit 1 on three obsolete staged-content expectations (future content pending, Tiki has only 12 rows, FULL mode lacks 900 levels). Current checkout contains the later M33 full content batch.
- `tests/m32_tiki_vertical_slice_probe.gd`: exit 1 on two obsolete 12-level count assertions. Its production L1 play, world/island navigation, result, retry, save/reload, and progression assertions passed.
- `tests/m32_economy_shop_probe.gd`: exit 0; `M32_ECONOMY_SHOP_RESULT=PASS`.
- `tests/m32_focus_booster_probe.gd`: exit 0; `M32_FOCUS_BOOSTER_RESULT=PASS`.
- `tests/m32_economy_tutorial_probe.gd`: exit 0; `M32_ECONOMY_TUTORIAL_RESULT=PASS`.
- `tests/m32_tutorial_mobile_capture_probe.gd`: incomplete under headless dummy rendering. Shell/tutorial availability and the 390x844 prompt fit passed; capture then returned a null texture and the probe raised an error. This is not reported as product acceptance.
- `tests/m33_tiki_compatibility_probe.gd`: exit 0; `M33_TIKI_COMPAT_RESULT=PASS`, including a real production physics trial for preserved Tiki L1/global 101.
- `tests/m33_campaign_content_probe.gd`: exit 0; `M33_CONTENT_RESULT=PASS` after sandbox bytes matched the manifest.
- `tests/m33_campaign_navigation_probe.gd`: exit 0; `M33_NAV_RESULT=PASS`.
- `tests/m33_content_unavailable_probe.gd`: exit 0; `M33_UNAVAILABLE_RESULT=PASS`.
- `git diff --cached --check`: passed for R01 files. No source asset/data changes were made.

M33 content/navigation probes do not establish physical reachability or human playtesting for the 899 levels outside Sunny Cove. No such claim is made.

## Files changed

- Added `tests/m32_r01_m17_semantic_coverage_probe.gd`.
- Added 15 immutable run-evidence files under `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/evidence/M32-R01/`, including expected/actual classification, runtime isolation record, clean-import log, and captured outputs for M17, M32, and M33 probes.
- Added this new execution log. Historical M17 reports, original probe, M32/M33 data, and root `TASKS.md` were not edited.

## Publication and handoff

- Implementation/evidence commit: `add55f01bb48111d6c87a7295ef72dae30677ee1` (`BCM-M32-R01 classify M17 screening fixtures`), pushed to `origin/main`.
- Immediately after that push, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `add55f01bb48111d6c87a7295ef72dae30677ee1`; divergence was `0/0`.
- This execution log is published separately so it can name the implementation/evidence commit. Final parity is rechecked after publishing this log.
- No tracker transition or independent audit was performed. Required stop marker: `AWAITING_GPT_M32_R01_AUDIT`.
