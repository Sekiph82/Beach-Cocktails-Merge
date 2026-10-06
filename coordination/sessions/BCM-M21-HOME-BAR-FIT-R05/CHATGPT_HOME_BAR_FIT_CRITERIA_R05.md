# BCM-M21-001-R05 — Home Energy/Coin Bar Fit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
`OWNER_HOME_BAR_FIT_RULING_R05.md`

## A. Scope

Only Energy/Coin horizontal bar geometry, their corresponding plus x-positions, and the Coin numeric text box may change.

Everything else is frozen.

## B. Exact geometry

At 941×1672 reference space:

Energy:
- rect = (229.0, 15.0, 136.125, 81.0)
- right edge = 365.125
- Energy plus center = (347.625, existing bar-center-y)

Coin:
- rect = (444.0, 14.0, 203.4375, 81.0)
- right edge = 647.4375
- Coin plus center = (629.6875, existing bar-center-y)

Diamond:
- unchanged from V03.

## C. Plus seating

PASS requires:
- Energy plus keeps the same current inset from Energy bar right edge: 17.5 px;
- Coin plus keeps the same current inset from Coin bar right edge: 17.75 px;
- plus icon width/height unchanged;
- plus icon vertical center exactly equals its bar vertical center;
- no visual gap or floating plus.

## D. Coin text fit

PASS requires:
- current coin value is fully inside Coin bar;
- `4.250` fixture does not clip;
- no overlap with Coin plus;
- no overlap with baked coin icon/left visual;
- text remains visually centered in the available numeric region;
- no unnecessary font-size reduction.

## E. Frozen layout proof

Focused probe must assert unchanged V03 values for:
- Level bar;
- Diamond bar/plus;
- Settings;
- PLAY;
- Continue;
- World Map;
- bottom row.

## F. Functional preservation

Real input still proves:
- PLAY opens current selected level;
- WORLD MAP opens production World Map;
- SETTINGS opens Settings.

## G. Evidence

Create:
`coordination/sessions/BCM-M21-HOME-BAR-FIT-R05/evidence/`

Required:
1. `01_home_bar_fit_941x1672.png`
2. `02_home_bar_fit_720x1280.png`
3. `03_home_bar_fit_800x1422.png`
4. `04_coin_bar_crop_941x1672.png`

Create:
`HOME_BAR_FIT_R05.json`

Record exact old/new bar widths, right edges, plus centers, and coin text bounds.

## H. Tests

Run:
- focused R05 Home bar-fit probe;
- existing R04 Home probe;
- M20 app shell;
- asset validator;
- Godot import/parse/boot;
- `git diff --check`.

Do not work on deferred M07/M08/project.godot closure in this task.

## I. Publication

Create:
`docs/codex-logs/CODEX_LOG_M21_HOME_BAR_FIT_R05.md`

Root `TASKS.md` remains read-only to Codex.

Push to main and stop at:

`AWAITING_OWNER_HOME_BAR_FIT_APPROVAL_R05`
