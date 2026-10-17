# BCM-M34-006 Codex Execution Log V01

## Scope and authority
- Work item: BCM-M34-006, comprehensive rewarded ads preparation and safe integration.
- Prompt: `coordination/sessions/BCM-M34-006-CODEX-V01/CODEX_M34_006_COMPREHENSIVE_MASTER_PROMPT.md` (master prompt, V01).
- Start HEAD: `faefd362a8ef46f63964f23379ac0a6ae089a831`.
- Branch/remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Root `TASKS.md` is protected and will not be edited.

## Sync-first preflight and preservation
- `git status --short --branch`: `main...origin/main`; 10 untracked path groups/items present; no modified tracked files.
- `git remote -v`: origin fetch/push points to the canonical GitHub repository above.
- `git fetch origin main`: completed; remote advanced local from `d0a688d` to `faefd36`.
- `git rev-list --left-right --count HEAD...origin/main`: `0 4` before sync.
- Incoming changed paths were `AGENTS.md`, `CLAUDE.md`, `TASKS.md`, and the active M34-006 prompt; none intersected any untracked path. `git merge --ff-only origin/main` completed without conflict.
- After sync: local HEAD and `origin/main` both `faefd362a8ef46f63964f23379ac0a6ae089a831`; `git ls-remote origin refs/heads/main` returned the same SHA.
- All 7,648 tracked and untracked file hashes were inventoried; SHA-256 of sorted `path<TAB>file_sha256` manifest: `F6A8EE2BF5411E147DC67605D4543550D42D9CD325DCD1FA7B169A593BF37642`.
- All 100 stash entries were counted and preserved without apply/drop/change.
- No process command line referenced this repository or BCM-M34 work. No project lock files were found. Generic Godot MCP/Python background processes were not targeted.
- Existing owner untracked paths remain untouched, including `_m32_validation/`, campaign shop catalog, prior evidence/screenshots, `tools/capture_godot_window.ps1`, and the PNG.

## Initial repository findings
- `scripts/campaign/ads_service.gd` has basic states and explicit consent checks but uses synchronous provider calls; it has no timeout/retry/backoff, lifecycle invalidation, or provider authenticity boundary.
- `data/campaign/ads_provider_policy.json` keeps all placements disabled by default and notes owner setup requirements, but lacks the full Android/iOS ID, privacy, consent, ATT, SSV, and device-authorization fields from the task contract.
- Reward fulfillment routes through the existing verified callback and idempotent economy/daily-claim ledgers. These paths and M34-007 billing/catalog behavior are out of scope for changes.
- No AdMob plugin/source is installed under `addons/`; the current Android export preset is nonshipping and contains no ad SDK configuration. Native SDK integration is therefore not available for this pass.

## Execution record
- Baseline command: `python tests/run_regressions.py` — **12/12 PASS** (10 core probes, editor import, startup smoke).
- Implemented credential-free policy/configuration gates for Android/iOS IDs, privacy URL, age/families, UMP, iOS ATT, SSV endpoint, and device authorization. All placement toggles remain disabled; production adapter activation remains blocked.
- Extended `AdsService` with debug-test-only provider injection, guarded session IDs, asynchronous load callback entry points, three-attempt exponential retry, load/show timeouts, cancellation/shutdown handling, sanitized diagnostics, and rejection of unsigned rewards. Existing economy and daily-reward ledgers remain the settlement/idempotency boundary.
- Added a deterministic test-only provider fixture and focused M34 lifecycle probe covering unavailable/offline, consent/config gates, show-before-load, load retry/exhaustion, async load success, failure, stale/duplicate callback, unsigned callback, verified callback, duplicate transaction/receipt, show failure, load/show timeout, close/cancel, shutdown, and restart.
- Campaign navigation loads the new configuration, which cannot enable production ads. No billing/catalog, gameplay, art, physics, task tracker, or save contract was changed.
- Focused command: `python tests/run_regressions.py tests/m34_rewarded_ads_lifecycle_probe.gd tests/m34_economy_closure_probe.gd tests/m34_daily_rewards_probe.gd` — **5/5 PASS** (three probes, editor import, startup smoke).
- Final command: `python tests/run_regressions.py` — **13/13 PASS** (11 core probes, editor import, startup smoke). The increased count is the new focused lifecycle probe.
- `git diff --check`: PASS. `python -m json.tool data/campaign/ads_provider_policy.json`: PASS. Godot editor import/parse and startup smoke: PASS on Godot 4.7.2.
- World Map UID inspection: `WorldMapScene.tscn` scene UID `uid://clmfxxr13bwu2`; it references `world_map_controller.gd` UID `uid://b41edy8ohkeyn`, matching the tracked sidecar. No World Map files were changed.
- Initial focused test iterations exposed and corrected fixture-only issues (typed test-result array initialization and a test callback passing placement instead of transaction ID); the final focused and full regression runs above are green.
- Native SDK/API status: no AdMob plugin/source is installed under canonical `addons/`, and no production adapter is integrated. Historical repository evidence for plugin v7.0 reports that its client earned callback lacks a server-verifiable transaction ID; prior offline test export evidence does not establish runtime/device delivery. No Android/iOS export, install, consent display, ad playback, SSV callback, or device test was performed.
- Owner inputs still required: Android/iOS AdMob app IDs and rewarded unit IDs (Google test IDs are acceptable for first integration); privacy-policy URL; age-directed/families decision; UMP consent approach and iOS ATT decision; SSV backend hosting/verification decision; explicit permission for Android and iOS device or emulator tests. Billing remains a separate M34-007 task requiring an approved product catalog, store accounts/testers, and receipt-validation backend.
- Manual checks performed: sync-safe path comparison, all-file SHA-256 inventory, stash-count preservation, relevant process/lock inventory, scope and UID inspection. Manual checks not performed: native/mobile, production ads, store, or owner visual acceptance.
- Known limitations: ads remain unavailable and production-disabled; no native provider or trusted SSV backend exists in this checkout. Debug-only fixture rewards do not constitute native or production acceptance. Existing display-only probes were not run or claimed.
- Files changed: `data/campaign/ads_provider_policy.json`; `scripts/campaign/ads_service.gd`; `scripts/campaign/ads_provider_config.gd` and generated `.uid`; `scripts/campaign/campaign_navigation_controller.gd`; `tests/fixtures/m34_rewarded_ads_test_provider.gd` and generated `.uid`; `tests/m34_rewarded_ads_lifecycle_probe.gd` and generated `.uid`; `tests/m34_daily_rewards_probe.gd`; `tests/m34_economy_closure_probe.gd`; `tests/run_regressions.py`; this log.
- `TASKS.md` was not modified. The pre-existing owner-local untracked files and all 100 stash entries remain untouched.
- Final marker: `AWAITING_GPT_BCM_M34_006_INDEPENDENT_REVIEW`.
- Final commit SHA, end HEAD, and local/remote main equality proof: pending publication.
