# Codex Execution Log — BCM-M34-R18 Level Qualification Studio V01

## Scope and authority

- Work item: `BCM-M33-004`, executed under `CHATGPT_M34_R18_MANUAL_LEVEL_QUALIFICATION_STUDIO_MASTER_PROMPT.md`.
- Start HEAD: `a433468b407477bf7f673261d1b6755186c0277c`; branch/ref: detached in the reused non-Desktop checkout `C:\Users\sekip\.codex\worktrees\bcm-m34-r09-deferred-20261015`; remote `origin` is canonical GitHub `main`.
- R17 independent audit accepts evidence-integrity work only; physical level qualification remains open. Root `TASKS.md` is protected and will not be modified.

## Sync and owner-state preservation

- Canonical Desktop preflight began at `643b8f3115d858503e1a00a8e9a2432e69adaf80`, `main`, 0 ahead / 5 behind, with 8 tracked edits and 15 untracked owner paths. All 50 incoming paths were disjoint from the full dirty-path inventory.
- Created tracked-only stash `owner-local-safe-sync-643b8f3`, fast-forwarded Desktop to `a433468b407477bf7f673261d1b6755186c0277c`, and reapplied the new stash without dropping it. Verified all 8 tracked edits restored, all 15 untracked paths retained with fingerprint `f471c99b6dc3168d26cb5849160b6335e18e7fff06744140ade58c1c7f0b5569`, no conflicts, and Desktop 0/0 at synchronized HEAD.
- Reused the existing R17 non-Desktop checkout; fast-forwarded from `507f7c2220abd468c9477be8cff85e6182d4f004` to start HEAD. Its task-local R17 isolated userdata and untracked `r15_parse_probe.json` remain untouched.

## Implementation and validation

### Changed paths

- `scripts/debug/level_qualification_studio.gd` and `scenes/debug/LevelQualificationStudio.tscn`: standalone development-only Studio around the actual campaign navigation and production gameplay scene; ten-island/100-level selection; canonical normal/VIP objectives, T, exact normal 4T cap, content cap mismatch, and star thresholds; R17 Tiki L10 and R16 Tiki L30 presets; isolated in-memory session; manual production input; pause/resume/one-physics-frame stepping, seed reset, objective/action/contact/merge/timeline/FPS/board diagnostics, JSON export and Studio-only on-demand capture.
- `scripts/game_manager.gd` and `scripts/merge_queue.gd`: opt-in diagnostic signals and deterministic Studio seed injection, gated by the R18 launcher environment plus Studio Engine metadata. Normal runs do not enable those hooks.
- `tools/BCM-M34-R18-Level-Qualification-Studio.ps1`: Godot 4.7.2 validation, isolated profile launch, and focused headless probe entry.
- `tests/m34_r18_level_qualification_studio_probe.gd` and `tests/m34_r18_regression_suite.ps1`: focused Studio contract probe and bounded watchdog regression runner that writes a separate R18 evidence directory and does not append to the immutable R17 manifest.
- `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R18/regressions_20261016T000227919Z_779fc036e4bd434f996c9604458ee0a5/`: fresh import, ten regression watchdog records, and summary. `regression_summary.json` SHA-256: `7d55e58929536b3e8629df14c2112d0c894bdc9de7d1511f0b6b27dd12901c2d`.

### Commands and results

- `& .\tools\BCM-M34-R18-Level-Qualification-Studio.ps1 -ValidateOnly` — PASS, Godot `4.7.2.stable.official.ed1daf0bf`.
- `& .\tools\BCM-M34-R18-Level-Qualification-Studio.ps1 -HeadlessCheck` — PASS, focused Studio contract probe; all checks passed, including 10x100 canonical selection, Tiki L10 `T=24`/cap `96`, Tiki L30 `T=32`/cap `128`, persistence/economy detachment, actual production scene/controller and ShotController action capture, injected diagnostic seed, exactly one stepped physics frame, resume, append-only unique exports with stable prior report hash, R17 references, seeded reset, and no campaign save/backup/legacy save creation.
- `& .\tests\m34_r18_regression_suite.ps1` — PASS; fresh editor import exited `0` and all ten requested regression cases exited `0`: Economy 35, Daily 38, Navigation 17, M14 bridge 66, M15 VIP/economy 63, production routes, scene UID, slim content, VIP optional, and startup smoke. Summary reports `ALL_REQUESTED_REGRESSIONS_PASS`, `10/10`, and `tasks_unchanged=true`.
- PowerShell parser checks for both new `.ps1` files — PASS.
- `git diff --check` — PASS.
- Root `TASKS.md` blob SHA-1 before and after regressions: `9eecd67f57b76d5f8a4d97e2d62f35f1e1ab1d6d`; unchanged.
- A Godot import rewrote `GameFeelFlow` in `project.godot` to an equivalent generated UID. That import-only normalization is reverted to the original resource path and is not an R18 change. `project.godot` is excluded from the intended change set.
- No disk cleanup was attempted; generated Godot/test caches and the separate pre-existing R17 untracked userdata were left alone.

### Manual Windows GUI acceptance — owner pending

Launch from the repository root with:

```powershell
& .\tools\BCM-M34-R18-Level-Qualification-Studio.ps1
```

The launcher checks Godot 4.7.2 and uses `%LOCALAPPDATA%\BeachCocktailsMerge\M34-R18-LevelQualificationStudio` as its isolated user profile. In the Studio, the owner should verify:

1. The panel opens over the real gameplay board; hide/show the panel and confirm the board remains available for pointer aim/fire.
2. Switch islands, start a low level and a late level, and check canonical objectives, normal/VIP distinction, T, exact 4T cap, score thresholds, next drink, and physics status.
3. Fire manually and verify shot/action ID, seed, moves, board count, collision/merge/contact diagnostics, normal/VIP progress and per-shot objective deltas update from play.
4. Observe an actual win and an actual loss where practical; confirm labels are `OBSERVED_WIN`/`OBSERVED_LOSS`. Stop an inconclusive attempt with `BUDGET_UNKNOWN`; unknown must never be called impossible.
5. Pause, single-step one physics frame, resume, then reset/replay the same seed and confirm a new attempt ID.
6. Export JSON and use on-demand capture; confirm a new export package is created and prior exports remain unchanged.
7. Recheck the normal campaign save/economy after closing the isolated Studio if the owner wants an additional native confirmation.

No native Windows GUI session, visual screenshot, manual mouse/touch run, actual win/loss, or owner visual acceptance was performed by Codex. The headless checks do not validate visual layout, pointer usability, actual collision/merge quality, observed terminal outcomes, or native screenshot output. The 1,000 campaign levels remain unqualified; R18 adds diagnostic tooling only.

## Publication

- Product, focused test, and R18 regression evidence commit: `147a950c31f8b7d123a4c680c52feb76541a0f38`, pushed normally to `origin/main` from the reused detached checkout. At that publication point, `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` all resolved to that SHA.
- This builder log is published in a separate follow-up commit; final `HEAD`/`origin/main`/remote-main parity is verified after that push in the handoff. Root `TASKS.md` remains unchanged.
- Required stop marker: `AWAITING_GPT_M34_R18_INDEPENDENT_AUDIT_AND_OWNER_GUI_ACCEPTANCE`; BCM-M33-004 remains OPEN; Codex assigns no acceptance verdict.
