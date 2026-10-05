# BCM-M21-001-R03 — Regression and Clean-State Closure

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

GitHub:
`https://github.com/Sekiph82/Beach-Cocktails-Merge`

Branch:
`main`

## Mission

Close ONLY the technical defects found by the independent R02 audit.

The R02 visual/product changes are already implemented. Do not redesign them.

You must:
1. reconcile the local `project.godot` dirty state safely;
2. make the current M07 regression authority truthful and fully passing;
3. eliminate the M08 post-PASS Windows crash so the process exits 0;
4. rerun the required regression matrix;
5. finish genuinely clean and synchronized.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/CHATGPT_OWNER_F5_VISUAL_POLISH_AUDIT_R02.md`
4. `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R03/CHATGPT_OWNER_F5_VISUAL_POLISH_CRITERIA_R03.md`
5. R02 prompt/criteria/log
6. current M07/M08 probes.

Root `TASKS.md` is read-only.

## 1. Sync + project.godot reconciliation

Do not begin by stashing the dirty file and forgetting it again.

Record:
```
git status --short --branch
git diff -- project.godot
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
```

Determine exactly why `project.godot` differs.

The previous canonicalization intentionally stored portable repository-relative addon/autoload paths in GitHub.

If the only local difference is a Godot-generated UID representation of the same GameFeelFlow autoload:
- prove semantic equivalence;
- restore the canonical GitHub portable form;
- continue.

If the diff contains anything else that could be intentional owner work:
STOP:
`OWNER_PROJECT_GODOT_RECONCILIATION_REQUIRED`

Do not commit machine-local UID churn as canonical just to make status clean.

## 2. M07 R06 diagnosis first

Run current:
`tests/m07_r06_owner_layout_probe.gd`

Capture full output and exit.

Do not immediately move SCORE/BEST or loosen tolerance.

The reported ~9 px failure is suspicious because the probe uses fixed 720-reference local boxes while the runtime panel scales responsively.

For all three viewports prove:
- ui_scale;
- panel sizes;
- reference box scaled/unscaled values;
- runtime recess center;
- rendered glyph center.

If the production text is actually mis-centered, fix production minimally.

If the probe is comparing scaled runtime geometry to unscaled reference boxes, fix the probe mathematics instead.

The final probe must retain strict centering and exit 0.

## 3. Reconcile remaining M07 historical assumptions

Run:
- `tests/m07_hud_composition_probe.gd`
- `tests/m07_r04_focused_probe.gd`
- `tests/m07_r05_hud_adaptation_probe.gd`

For every failure, trace the expectation to current canonical code/history.

Known symptoms include:
- references to removed `_launch_zone`;
- old To-Go size assumptions;
- old logo/progression layout assumptions;
- removed `get_horizontal_bounds_at_y` APIs.

Do NOT re-add retired production architecture simply to satisfy old probes.

Update stale probe assertions to current canonical contracts while preserving equivalent/stronger coverage.

Do not delete assertions or just increase tolerances.

If an entire probe is historical-only, document why, classify it explicitly, and replace its current-gating role with a current probe that covers the same safety property.

Final current M07 regression set must exit 0.

## 4. M08 crash

Run:
`tests/m08_to_go_delivery_probe.gd`

The current result is invalid because it prints PASS and then exits with Windows `-1073741819`.

Capture stdout/stderr and exact exit.

Diagnose teardown.

Check especially:
- queued frees;
- active tweens;
- target capture callbacks;
- Viewport/SubViewport lifetime;
- physics object shutdown;
- signal callbacks after SceneTree quit.

Fix the smallest real cause.

Do NOT accept a PASS marker if process exit is non-zero.
Do NOT hide the crash with a wrapper.

Run M08 twice consecutively.

Both must:
- print `M08_TO_GO_DELIVERY_RESULT=PASS`;
- exit 0;
- produce no access violation.

## 5. R02 freeze

Do not redesign:
- Home;
- Island Map node art/header;
- To-Go panel;
- World Map;
- R04 gameplay surface.

Run the R02 focused probe after every necessary change.

## 6. Full regression

Run every command listed in the locked R03 criteria.

Every gating command must exit 0.

## 7. Evidence / log / publish

Create:
`coordination/sessions/BCM-M21-OWNER-F5-POLISH-R03/evidence/`

Create:
`docs/codex-logs/CODEX_LOG_M21_OWNER_F5_POLISH_R03.md`

Commit only justified remediation/test/evidence changes.

Do not edit root `TASKS.md`.

Push to main.

## FINAL HARD GATE

Before handoff:

```
git status --short
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
git rev-list --left-right --count HEAD...origin/main
```

Required:
- status EMPTY;
- local = origin = remote main;
- 0/0;
- all current mandatory regressions exit 0.

Finish exactly:

`AWAITING_GPT_M21_OWNER_F5_POLISH_AUDIT_R03`

STOP. Do not start BCM-M21-006.
