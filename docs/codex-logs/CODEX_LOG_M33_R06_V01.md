# BCM-M33-R06 Owner Playability Test Kit — Codex Execution Log V01

Status: IMPLEMENTED; awaiting owner real play and independent GPT audit.
Work item: BCM-M33-R06, children R06-001 through R06-005.
Prompt: `coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/CHATGPT_M33_R06_OWNER_PLAYABILITY_TEST_MASTER_PROMPT.md`
Start HEAD: `04846783127008bd9989a8679e9a63ca57bc472f`.
Branch: `main`.
Remote: `origin` → `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

## Sync preflight and owner-work preservation

- At session start, local HEAD `2f58c21806f1df7692f3901e4922c4865f499434` was behind `origin/main` by 6, with no local commits ahead.
- Inventoried all dirty paths and compared them to incoming changed paths. Incoming changes were path-disjoint from all seven tracked owner-local edits and existing untracked owner files.
- Applied the prescribed tracked-only named safe-sync stash `owner-local-safe-sync-2f58c21`, fast-forwarded to `04846783127008bd9989a8679e9a63ca57bc472f`, reapplied the new stash without dropping it, and verified restored owner diffs and untouched untracked paths.
- At implementation start `HEAD = origin/main = 04846783127008bd9989a8679e9a63ca57bc472f`. Final pre-commit `git fetch origin main` and `git rev-list --left-right --count HEAD...origin/main` returned `0 0`.
- Seven owner-local tracked changes remain outside the staged task scope: six M21/M22 evidence JSON files and `project.godot`. Existing owner-local untracked evidence, images, and M23 log remain outside the staged task scope. No stash was dropped. No owner Godot process was stopped; graphical probes ran as separately owned, short-lived Godot processes.

## Files changed for R06

- `scripts/campaign/application_shell.gd` — opens the test-only chooser only when the explicit launcher environment flag is present.
- `scripts/campaign/campaign_navigation_controller.gd` — builds an in-memory all-samples progression state with persistence disabled and exposes an opt-in sample launch method.
- `scripts/campaign/owner_playtest_console.gd` — sample preview, explicit isolated-profile check, production session/Retry/leave telemetry, CSV/JSONL append, and owner-readable report.
- `tools/BCM-M33-R06-Owner-Playtest.ps1` and `tools/START-BCM-M33-R06-OWNER-PLAYTEST.cmd` — in-project Godot 4.7.2 launcher and double-click entrypoint; no shortcut or auto-run installation.
- `tests/m33_r06_owner_playtest_probe.gd` — bounded production-shell integration probe and graphical captures.
- `coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R06/README.md`, `R06_GRAPHICAL_PROBE.txt`, `M14_GAMEPLAY_SESSION_BRIDGE_PROBE.txt`, and two 720×1280 PNG captures.
- This execution log.

Root `TASKS.md`, campaign data, Sunny Cove, the 12-level Tiki seed, physics, art, and normal save code were not changed.

## Implementation

Launcher path inside the existing project: `tools/START-BCM-M33-R06-OWNER-PLAYTEST.cmd` (invokes `tools/BCM-M33-R06-Owner-Playtest.ps1`). It resolves the same project root, requires Godot 4.7.2, and temporarily redirects child-process `APPDATA` to `%LOCALAPPDATA%\BeachCocktailsMerge\M33-R06-OwnerPlaytest`. The running app verifies that actual `user://` resolves beneath that isolated profile and differs from the normal `CocktailMerge` user-data path before enabling Start.

In test mode, CampaignNavigationController configures temporary in-memory island/level unlock state and never reads the campaign save or enables campaign persistence. Selector launches go through the real bridge and existing gameplay scene. It does not force or write production unlocks, stars, score, rewards, or economy.

Thirteen selectable rows map to actual global IDs: nine generated-island level-1 entries (101, 201, 301, 401, 501, 601, 701, 801, 901), empty/one/two starter contrasts (201, 208, 127), and optional final prestige capstone L9 at 1000. The preview shows actual objectives, VIP, stock, T and 4×T move limit. Gameplay uses the existing player input and ShotController. The test-only SAMPLES button returns to the chooser.

The isolated report records privacy-safe run ID; sample/global ID; content revision; monotonic start/end ticks and elapsed seconds; shots; To-Go/VIP counts; wins/losses; retries; stars; starter inventory; and leave reason. Runtime output is `user://m33_r06/attempts.jsonl`, `attempts.csv`, and `OWNER_PLAYTEST_REPORT.md`, under the redirected profile.

## Commands/tests and exact results

- `godot_console.exe --version` → `4.7.2.stable.official.ed1daf0bf`.
- `tools/BCM-M33-R06-Owner-Playtest.ps1 -ValidateOnly` → `LAUNCHER_VALIDATION=PASS`, resolved Godot executable and canonical project root reported.
- `godot_console.exe --headless --path . --editor --quit` → exit 0; project scan, global script registration and plugin startup/shutdown completed.
- `godot_console.exe --headless --path . --script res://scripts/campaign/owner_playtest_console.gd --check-only` → exit 0.
- `godot_console.exe --headless --path . --script res://scripts/campaign/campaign_navigation_controller.gd --check-only` → exit 0.
- `godot_console.exe --headless --path . --script res://scripts/campaign/application_shell.gd --check-only` → exit 0.
- `godot_console.exe --headless --path . --script res://tests/m33_r06_owner_playtest_probe.gd --check-only` → exit 0.
- Bounded R06 headless integration run with `APPDATA` and R06 test variables redirected beneath `%LOCALAPPDATA%\BeachCocktailsMerge\M33-R06-Probe`: `M33_R06_RESULT=PASS`, exit 0. Verified 13 sample/global mappings, nine distinct empty entry levels, three starter contrasts, capstone G1000, isolated `user://`, disabled normal persistence, production gameplay, real viewport mouse shot/move count, production merge queue through L5, To-Go capture, untimed session, production Retry, return-to-samples, and isolated telemetry/report output.
- Same R06 integration probe in graphical Godot 4.7.2 / OpenGL Compatibility on Intel Iris Xe: `M33_R06_RESULT=PASS`, exit 0. Captured actual selector and production one-L6-starter gameplay view at 720×1280. Evidence: `R06_SAMPLE_SELECTOR_720x1280.png` and `R06_GAMEPLAY_ONE_STARTER_INITIAL_720x1280.png`.
- `tests/m14_gameplay_session_bridge_probe.gd` under redirected test `APPDATA` → `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`, exit 0. This complements session, delivery, VIP, stars, retry and navigation coverage.
- `git diff --check` on the full checkout reports trailing whitespace in pre-existing owner-local M21/M22 evidence JSON changes. These six files were present before this task, remain unstaged, and were not edited. R06-only `git diff --cached --check` → exit 0, no output; `git diff --cached -- TASKS.md` → no output.
- No 900-level solver run, store publication, or owner-device/human play was performed.

Exact R06 graphical run output: `evidence/M33-R06/R06_GRAPHICAL_PROBE.txt`. M14 output: `evidence/M33-R06/M14_GAMEPLAY_SESSION_BRIDGE_PROBE.txt`. Screenshot links are in the same folder's `README.md` and target the committed PNGs.

## Manual checks / pending

- Owner must double-click the in-project CMD entrypoint, confirm `SAVE ISOLATION VERIFIED`, and play the selected samples with normal mouse/touch input.
- Owner real timing, playability, and subjective feedback remain pending. The automated probe is builder evidence only.
- Owner can share `OWNER_PLAYTEST_REPORT.md` and `attempts.csv` from the report's isolated-profile path; no source-log inspection is required.
- Normal-profile return procedure: close the test window, then open the same existing project path in Godot Project Manager and run the project normally. The R06 launcher is test-only.

## Limitations

- This is a small owner playability sample kit, not qualification of all 900 generated levels.
- The test probe uses controlled production merge-queue inputs to complete the L5 entry target; owner play still must establish real-world timing and playability.
- Screenshot and code checks do not establish owner acceptance or independent audit.

## Final repository state

- Implementation/evidence commit SHA: `20fea1f2c85ebc16f6b39496b521f3cd85857879`. The execution-log closeout is published in a following documentation-only commit.
- `git push origin main` published the implementation commit. Immediate verification returned `git rev-parse HEAD = git rev-parse origin/main = git ls-remote origin refs/heads/main = 20fea1f2c85ebc16f6b39496b521f3cd85857879`. The following log-only commit is separately verified after its push in the task handoff.
- `TASKS.md` was not modified.
- Required stop marker: `AWAITING_OWNER_M33_R06_REAL_GAMEPLAY_TEST_AND_GPT_AUDIT`.
