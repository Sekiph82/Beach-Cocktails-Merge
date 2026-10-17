# Historical Claude Handoff (Superseded)

**2026-10-17 owner update:** Claude's final legacy probe triage was published at commit `d0a688d`. The owner transferred ongoing Beach Cocktails Merge coordination back to ChatGPT with Codex implementing. This document preserves Claude's historical instructions and work context only. For live authority follow root `TASKS.md` and `AGENTS.md`.

# Former Claude operating instructions (historical, no longer live)

**Owner authority, effective 2026-10-17:** Claude is the primary project coordinator, implementer/delegator, independent evidence reviewer, and sole authorized editor of repository-root `TASKS.md`. The former mandatory ChatGPT audit and prompt handoff is revoked. Codex can still implement work delegated by Claude, but must not write `TASKS.md`.

**Repository truth:** Read `AGENTS.md` and root `TASKS.md` first on each session. `TASKS.md` is the only live task-status tracker (H!veAI input). This file is an agent instruction and source-navigation document, **not** another task tracker, dashboard or competing status mirror. Do not create one. Owner decisions supersede historical instructions.

## Current state (Claude, 2026-10-17)

- M33-004 closed: frozen 100-level sample 100/100 winnable via `tools/campaign/m33_004_run_sample.py` (headless `--fixed-fps 60`, no wall-clock cutoff). Owner ruling: **no difficulty grading** — report winnability only.
- M34-005 closed: see `coordination/sessions/BCM-M34-005-CLAUDE-V01/cleanup_inventory.json`.
- M34-006 / M34-007 blocked on owner inputs listed in `TASKS.md` Blockers/Waits.
- Regressions: `python tests/run_regressions.py` (core) or `--all`. Probes run in isolated AppData with the first-play tutorial pre-completed.
- `.uid` sidecars are versioned; `coordination/` and `docs/` carry `.gdignore`.

## Original owner handoff (2026-10-17, historical)

1. Independently inventory the four noncomplete canonical task rows in current root `TASKS.md`, associated source/tests/evidence, and open release caveats. Do not trust historic [x] status as proof of native device tests. Do not invent additional task IDs without owner authorization.
2. For campaign physical qualification, owner specifically chose **10 randomly drawn unique levels per island, 10 islands, 100 sampled levels total**. The remaining 900 are **not** to be automatically played. The frozen selection SHA and seed are recorded under `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R23/qualification/r23_random_selection_seed_20261016_v01.json`. Resume from committed evidence; never redraw selection or replay already completed levels just to fill a report. Read `docs/codex-logs/CODEX_LOG_M34_R23_V02.md` and `evidence/M34-R23/sessions/random_sample_v01_session_01/qualification/r23_manifest_resume_integrity_v02.json` (under the session directory above) to recover the exact completed queue. Preserve hard watchdogs, honest outcome classes and bounded session resources. Earlier ChatGPT R24 prompt is historical optional material, not a required gate.
3. Remaining project-wide gaps include safe dead-code/asset/temporary-file inventory, native Android/iOS rewarded ads, and native billing/receipt verification; use their canonical M34 task rows and owner-approved SDK/catalog decisions. Device tests are deferred until the owner permits them. Do not change game scope as part of handoff.
4. When source, tests and immutable evidence prove a task result, Claude may update `TASKS.md` directly. Builder self-reports are never equivalent to tested acceptance. Clearly label anything still unverified.
5. Share one consolidated plan/remediation package per task or milestone where practical, with all discovered defects and regression coverage; avoid serial one-defect/one-prompt churn. User explicitly requested Claude take over and ChatGPT step aside.

## Owner data safeguards

Canonical Windows checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`. Expect pre-existing dirty tracked files, owner untracked paths and preserved stashes; their counts may change. Before Git sync or edits, inventory paths and hashes. Never force reset, clean, overwrite owner paths, drop preservation stashes, or use unsafe destructive workarounds. No new persistent worktrees, huge caches or GB-scale evidence dumps unless explicitly authorized. Owner wants proof-based disposal of actually unused artifacts only. Respect denied filesystem deletion without bypass. Test output must stay isolated from normal game saves.

Keep owner gameplay rulings: production ShotController and actual Godot physics, normal objective shot cap exactly 4T, optional VIP separate, no gameplay timer, no Focus booster, WIN energy cost 0, LOSE/QUIT energy cost 20 once per attempt. Preserve owner-approved island geometry, assets and game UI. No claim that BUDGET_UNKNOWN means an impossible level.

## Evidence reference

Session folder: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/`. Builder logs: `docs/codex-logs/`. Historical R17-R23 prompts/audits are evidence and do not grant authority to issue further ChatGPT approvals. Root `AGENTS.md` governs agent safety and repository synchronization.

**Handoff intent:** Take ownership now. Do not wait for ChatGPT to review, publish prompts or edit the tracker.
