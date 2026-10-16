# Codex Execution Log — BCM-M34-R18-FIX01 Visual Studio Layout V01

## Scope and authority

- Work item: `BCM-M33-004`, executed under `CHATGPT_M34_R18_FIX01_VISUAL_STUDIO_LAYOUT_MASTER_PROMPT.md`.
- Start HEAD: `ad746bf53bfc37712d748acebb1cb94f3cae5953`; branch/ref: detached in existing non-Desktop worktree `C:\Users\sekip\.codex\worktrees\bcm-m34-r09-deferred-20261015`; remote `origin` is canonical GitHub `main`.
- Desktop safe sync fast-forwarded from `27a70a6e6814ac552985c41c7c00b3c660ac9a9c` to `ad746bf53bfc37712d748acebb1cb94f3cae5953`. Eight tracked owner edits were preserved with new tracked-only stash `owner-local-safe-sync-27a70a6`, reapplied without dropping; 15 untracked files remained byte-identical with saved fingerprint `f471c99b6dc3168d26cb5849160b6335e18e7fff06744140ade58c1c7f0b5569`. Desktop was `0/0` after sync.
- Incoming `main` paths were disjoint from owner-local changes. Root `TASKS.md` is read-only and will not be modified.
- Independent owner visual audit V02 is `FAIL`; this remediation addresses only R18 Studio layout, draw order, responsive controls, and associated diagnostics. No gameplay/economy/content changes are in scope.

## Implementation and validation

- Reworked `scripts/debug/level_qualification_studio.gd` into a fixed 720×1280 production campaign preview inside a `SubViewportContainer`, with the Studio UI on CanvasLayer 100 above it. Desktop-sized windows show the portrait board beside a full-height inspector; narrower viewports use a centered portrait preview and a vertically scrollable panel with HFlow-wrapped selectors/actions. Added high-contrast panel styling, explicit field captions, visible development-only labeling, and a hide/show control. The desktop window request is bounded to 1440×960 and the available display size. Production navigation and gameplay source were not changed.
- Extended `tests/m34_r18_level_qualification_studio_probe.gd` with desktop/portrait bounds and wrapping checks, explicit Studio-vs-production tree separation, all 1,000 canonical island/level selections, and routed pointer input through the preview container for Sunny Cove selection and gameplay shot firing. Existing T/4T, pause/step, attempt isolation, immutable export, and save-isolation assertions remain.
- Focused probe command: `godot_console.exe --headless --path . --script tests/m34_r18_level_qualification_studio_probe.gd`, with the isolated R18 environment variables set by the launcher contract. Result: `M34_R18_STUDIO_RESULT=PASS`; all focused checks passed, including 10×100 selection, map click routing, gameplay shot routing, T/4T caps, attempt isolation, exports, pause/frame step, and no campaign save writes.
- Fresh editor import and ten requested regressions: `tests/m34_r18_regression_suite.ps1`, with `LOCALAPPDATA` rooted under this worktree. Result: `ALL_REQUESTED_REGRESSIONS_PASS`, 10/10, import exited 0, `TASKS.md` blob unchanged at `ee96361503b2f0a071cbcb32f5e5d9c2feb2f5a6`. Summary SHA-256: `2243da4005dca1d2acdb325404a6fde52f0881b51ef79d8158f81719e997215e`. Evidence is under `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R18/regressions_20261016T050538390Z_5d1a610dafb74d81b25111e4aa1e57b4/`.
- Final focused probe command: `godot_console.exe --headless --path . --script tests/m34_r18_level_qualification_studio_probe.gd` with isolated profile variables; `M34_R18_STUDIO_RESULT=PASS` (22 focused assertions passed). Final `git diff --check`: PASS. Manual GUI checks performed: none; owner visual confirmation remains required.
- Godot editor import rewrote the unrelated `GameFeelFlow` autoload path in `project.godot` to a UID form. Restored that exact generated-only line; `project.godot` is excluded from the task diff.
- Builder/runtime limits retained: energy/economy, gameplay physics, timer/focus, release UI, canonical content, and production visuals were not changed. R18 isolated-userdata/export files are not staged.

## GUI / owner handoff

Actual Windows GUI visual inspection and desktop/portrait screenshots were not available from the connected tooling in this run; no visual PASS is claimed. Owner must launch the Studio, inspect desktop and portrait layouts, verify map visibility plus gameplay aim/fire/pause/frame-step access, and provide a screenshot/recheck. Stop marker: `AWAITING_OWNER_R18_FIX01_VISUAL_RECHECK`; M33-004 remains open.

## Publication

Implementation commit SHA: `1ebb679fdd62c882eebde396d6cf4d585a12d27d`. Builder-log commit SHA: recorded in Git history after this file is committed. Normal non-force publication to canonical `main` and final local/origin/remote parity verification: pending. Root `TASKS.md` has not been modified.
