# BCM-M34-006/007 | V08 Independent Audit Remediation: Bounded Legacy Triage + Native Gates

**Sole authoritative tracker:** root `TASKS.md`. **Codex MUST NOT edit TASKS.md**, create new task IDs, or reopen previously closed milestones. Read `AGENTS.md`, latest `TASKS.md`, `docs/codex-logs/CODEX_LOG_2026-10-19_M34_006_007_NATIVE_V08.md` and the independent audit `BCM_M34_006_007_NATIVE_V08_INDEPENDENT_AUDIT_V01.md` in this folder. Task scope stays M34-006/007 technical verification and cross-milestone regressions exposed by safe tests.

**OWNER rules:** GitHub Actions unavailable, DO NOT invoke/enable/alter/depend on Actions. No Expo, Orbit or substitute cloud CI. Computer Use for Chrome store accounts blocked on safety/origin, no bypass/JS/cookie workarounds. No production AdMob traffic, purchases, Cloudflare Worker/D1 deployment, Apple/Play account changes, device installation or hidden service activation. Never touch, read, hash, restore or delete real user `user://campaign_save.json`/backup unless separate explicit owner authorization; historical incident remains `OWNER_SAVE_STATE_UNKNOWN_NO_BASELINE`. XTool/BAT, historical IPA/APK, owner untracked/stashes, accepted game mechanics and visuals must stay intact; no disk or test-sandbox cleanup. `--all` runs only with isolated per-process `.godot/bcm_sandboxes` profile, verified before launching any save-aware controller.

## 0. Sync-first
At `C:\Users\sekip\Desktop\Beach Cocktails - Merge`, inspect `git status --short --branch`, `git remote -v`, `git fetch origin main`, `git rev-list --left-right --count HEAD...origin/main`, compare incoming changes against owner dirty/untracked inventory and fast-forward only if safe. No reset/rebase/stash/clean/forced push. GitHub remote is authoritative.

## 1. P0 source-confirmed: wrong GUI probe category
The prior V08 run `--all` had 118 headless, 17 GUI; source inspection now proves `tests/m26_002_campaign_unlock_presentation_probe.gd` is **not headless**:
`_set_viewport_size()` calls `DisplayServer.window_set_mode` and `_capture()` requires real GL framebuffer `get_viewport().get_texture().get_image()`, asserts saved nonempty 720×1280 / 720×1440 PNGs. Yet it sits in `ALL_HEADLESS_PROBES`. Reclassify it to `NEEDS_DISPLAY` and update `tests/test_run_regressions_discovery.py` counts/invariants. Add a source- or contract-level detector preventing this specific incorrect headless classification from recurring. Test **real** GUI path only under isolated profile, with a short bounded Godot timeout and report what could not render (do not fake screenshots or remove capture assertions). Do NOT change production gameplay or blindly relabel failing tests as GUI merely to increase PASS count.

`tests/m27_002_campaign_unlock_probe.gd` intentionally skips framebuffer capture if `DisplayServer.get_name()=="headless"`, but may still fail actual semantic cue/particle assertions. Look at V08 isolated `.godot/m34_v08_all.json` `error_lines` + retained `.godot/bcm_sandboxes` synthetic test paths if available, then one **targeted** retry with exact assertions. Determine whether it is stale expected presentation, missing headless renderer, actual gameplay regression, or runner limitation with line-level source evidence; do not retire or weaken tests. Only move it to display category if genuinely required for its non-capture acceptance, with explicit separate GUI proof.

## 2. P1 Slow five 100-level progression proofs: single bounded diagnosis, NOT endless reruns
V08 `--all` first 113/121 PASS at 60s: six timed out, two exit 1. M33 navigation later **PASS 69.3 s**; five long progression tests still exceeded 180 s:
`tests/closeout-001/m21_full_progression_probe_closeout.gd`,
`tests/m21_full_progression_probe.gd`,
`tests/m21_owner_f5_remediation_v03_progression_probe.gd`,
`tests/m21_owner_runtime_closure_v02_r01_progression_probe.gd`,
`tests/m27_003_full_progression_probe.gd`.
These loop through 100 actual levels with awaited frames, map/gameplay instantiation and checkpoint writes. A 180s deadline alone proves neither infinite hang nor product defect.

1. First inspect retained *synthetic-only* V08 result JSON, standard output tails, M21 probes' shared code patterns, and CPU/duration context; no owner save access. Instrument optional **test-only** per-10-level progress/timing messages if necessary, not production economy/physics.
2. Choose **one representative** of the five; perform ONE bounded isolated profiling run with maximum 240 seconds and collect actual last completed level, last awaited operation, memory pressure if available and duration projection. If it is making legitimate progress and a full run clearly needs more time, classify as `SLOW_UNVERIFIED` with evidence and an opt-in category for owner-approved long tests. **Do not claim a PASS or quietly drop any test**, and do not rerun all five repeatedly. If a real stall/exception is found, fix the narrow root cause and rerun targeted regression only.
3. Preserve previous M21 acceptance history; do not auto-reopen unrelated milestones or change owner-approved game rules merely to satisfy historical probes.

## 3. P2 Local technical work if safe and genuinely useful
- Local synthetic Node SQLite Worker→ECDSA-formatted SSV→Godot real HTTP→isolated SaveManager→ACK→separate process replay is already reported PASS. Avoid repeating it unnecessarily. It is not live Google/Cloudflare/AdMob proof.
- Bundled AdMob Godot `LoadAdRequest.set_user_id/set_custom_data` is visible, native AAR bridge forwarding to `RewardedAd` remains **UNVERIFIED_NATIVE_BRIDGE**. Inspect only safe metadata/upstream contract sources; do not claim proof from class names, binary inventory or a signed APK. Without owner-authorized Android device or inspectable upstream native source, state the hard gate honestly; do not substitute a fake ad result.
- Play Billing fake durable ledger is not store certification. Leave all `buyable=false`, Worker store routes 503, and iOS StoreKit as blocked until real compatible toolchain and owner account test context. Avoid speculative work or new milestones to hide gates.

## 4. Verification & publication
- Run Python discovery contract, isolation-only refusal and default core after safe classification edits. Run ONLY targeted M26/M27 checks and ONE bounded slow-probe diagnostic above as necessary; broad `--all` full suite **need not be repeated** until previously demonstrated failures have an evidence-backed fix. Use project-local isolated profiles for every Godot process.
- If actual source/worker files change, run affected Worker `npm test`, Node synthetic E2E, GDScript `--check-only` as appropriate. If only test classification changes, no need to rebuild unchanged 205 MB signed Android APK.
- Report exact environment, selected probed PASS/FAIL/timeout, last progress level, reason, and all unresolved cases. Do not count category exclusions or unresolved timeouts as PASS, or claim complete M34 readiness.
- Legacy scripts can refresh tracked report outputs: inventory a **pre-run clean tracked baseline**, and restore ONLY identified test-generated tracked outputs whose original bytes match pre-run HEAD, not owner-created changes. No blanket destructive restore or untracked deletion.
- Commit coherent source and one new immutable builder log `docs/codex-logs/CODEX_LOG_2026-10-19_M34_006_007_NATIVE_V09.md` (use actual execution date), push `main`, check local HEAD/origin/main/remote equality. Codex NEVER edits root `TASKS.md`; ChatGPT independently audits before acceptance. Handoff with GitHub log URL, not Windows-only links.
