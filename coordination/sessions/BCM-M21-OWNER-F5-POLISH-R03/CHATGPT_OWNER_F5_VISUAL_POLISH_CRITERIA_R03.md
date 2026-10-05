# BCM-M21-001-R03 — Regression and Clean-State Closure Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `CHATGPT_OWNER_F5_VISUAL_POLISH_AUDIT_R02.md`
- R02 owner ruling / criteria
- R02 product implementation at `cd4f5604a73eadc1702f92f0fe38402494a0eece`

## A. Scope

R03 is a bounded technical closure.

Do not redesign:
- Island Map node art mapping;
- Island Map plaque/header visual;
- Home composition;
- World Map;
- To-Go +25% visual;
- R04 gameplay surface/geometry.

Only change production code if a reproduced regression proves a real current defect.

## B. Sync and tracked local diff reconciliation

Start in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Record exact:
- HEAD;
- origin/main;
- ahead/behind;
- `git status --short`;
- `git diff -- project.godot`.

For the current `project.godot` modification:
1. compare local bytes/semantics with canonical GitHub main;
2. prove whether the only difference is the GameFeelFlow autoload's machine-local UID representation;
3. if and only if it is semantically equivalent generated/local representation, restore canonical portable repo state;
4. if any other intentional owner change exists, STOP with `OWNER_PROJECT_GODOT_RECONCILIATION_REQUIRED`.

Final worktree MUST be clean.

## C. M07 R06 score-center diagnosis

Run `tests/m07_r06_owner_layout_probe.gd` unchanged first and capture complete stdout/exit.

For each viewport, report:
- viewport;
- ui_scale;
- actual BEST/SCORE panel size;
- actual local recess center;
- expected local recess center;
- actual visible glyph center;
- delta.

Prove whether the current failure is:
1. real production mis-centering; or
2. stale/unscaled probe expectation.

If real production defect:
- fix centering minimally;
- preserve accepted HUD positions.

If probe defect:
- fix the probe so expected boxes scale from the canonical 720 reference using the same production scale basis;
- retain strict center tolerance;
- do not loosen tolerance just to pass.

Required final result:
`M07_R06_PROBE_RESULT=PASS`
with exit code 0 at all three viewports.

## D. Other M07 stale probe reconciliation

Independently inspect:
- `tests/m07_hud_composition_probe.gd`
- `tests/m07_r04_focused_probe.gd`
- `tests/m07_r05_hud_adaptation_probe.gd`

For every failing assertion:
- identify the exact historical contract;
- identify the current canonical replacement contract/API;
- prove from git history/current code that the old expectation was superseded;
- update only stale probe assumptions to current production truth;
- preserve equivalent or stronger assertions for current behavior.

Forbidden:
- deleting probes merely because they fail;
- commenting out assertions;
- widening tolerances without evidence;
- accepting missing current functionality;
- reintroducing retired production APIs solely to satisfy stale tests.

Required final result:
all retained current M07 probes exit 0.

If a probe is truly historical and cannot represent current architecture without becoming misleading, move its status to an explicit historical/non-gating test classification in a committed evidence note, and provide a current replacement probe with equal or stronger coverage. Do not silently skip it.

## E. M08 non-zero crash closure

Run `tests/m08_to_go_delivery_probe.gd` and capture:
- complete stdout/stderr;
- exact process exit code;
- crash/backtrace/dump path if available.

A printed PASS marker is insufficient.

Diagnose teardown after the PASS marker:
- queued nodes/tweens;
- viewport lifetime;
- physics objects;
- signals/callbacks firing after quit;
- process shutdown;
- engine crash.

Fix the smallest actual cause.

Required:
- `M08_TO_GO_DELIVERY_RESULT=PASS`;
- process exit code exactly 0;
- no SCRIPT ERROR / ERROR / access violation;
- run twice consecutively with exit 0.

Do not wrap or post-process the command to convert a crash into success.

## F. Preserve R02 product contract

Re-run focused R02 probe and prove:
- exact level-node PNG mapping;
- 2-star asset;
- compact island plaque/header;
- 100 level nodes;
- +25% To-Go/VIP panel and local content;
- Home asset composition;
- distinct WORLD MAP and PLAY/CONTINUE actions;
- dynamic continue level.

No visual redesign is authorized.

## G. Regression matrix

All must exit 0:
- R02 focused owner-F5 visual polish probe;
- M07 R06 owner layout;
- reconciled current M07 HUD composition;
- reconciled/current M07 R04/R05 coverage or explicitly superseding current replacements;
- M08 To-Go delivery twice consecutively;
- M13;
- M14;
- M15 twice;
- M18 Island Map replay;
- M20 app shell;
- M21 V05 real mouse/touch Sunny Cove;
- R04 surface authority;
- asset rebuild/validator;
- Godot editor import/parse;
- application boot;
- `git diff --check`.

## H. Evidence

Create:
`coordination/sessions/BCM-M21-OWNER-F5-POLISH-R03/evidence/`

Required:
- pre/post `project.godot` reconciliation record;
- M07 diagnosis JSON/MD;
- complete M07 command outputs + exits;
- complete M08 run-1/run-2 outputs + exits;
- focused R02 result;
- final synchronization record.

## I. Log and publication

Create:
`docs/codex-logs/CODEX_LOG_M21_OWNER_F5_POLISH_R03.md`

Root `TASKS.md` remains read-only.

Final mandatory proof:
- `git status --short` EMPTY;
- local HEAD = origin/main = remote main;
- ahead/behind 0/0;
- no preservation stash needed for current canonical project state;
- all mandatory current regressions exit 0.

Final marker exactly:

`AWAITING_GPT_M21_OWNER_F5_POLISH_AUDIT_R03`
