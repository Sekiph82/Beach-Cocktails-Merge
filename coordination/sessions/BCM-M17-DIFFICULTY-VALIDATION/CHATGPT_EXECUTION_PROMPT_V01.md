# BCM-M17 Difficulty Model + Seeded Validation Harness — Execution Prompt V01

Execute against:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V01.md`
- root `TASKS.md`
- `docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md`
- current audited M16 Sunny Cove canonical data
- current audited physics/gameplay contracts

Before implementation:
- obey `AGENTS.md`;
- synchronize `C:\Users\sekip\Desktop\Beach Cocktails - Merge`;
- confirm canonical checkout is on clean `main`.

## Goal

Build the first trustworthy M17 difficulty-validation toolchain.

This V01 pass is **tooling + evidence only**.

Do not tune or rewrite any canonical Sunny Cove objective/timer yet.

## 1. One authoritative difficulty-model implementation

Create a reusable model used by both tools and tests.

It must expose:

`cost(Ln) = 2^(n-1)`

`objective_cost = SUM(quantity * cost(cocktail_level))`

For each canonical level report:
- level ID;
- normal orders;
- normal objective cost;
- VIP cost separately if present;
- canonical timer.

Do not add VIP cost to normal objective cost.

Verify:
- L1 = 16;
- L100 = 240.

## 2. Expected L1-L3 spawn production

Runtime spawn source is uniform L1-L3 via `randi_range(1,3)`.

Expose:
- L1 value = 1;
- L2 value = 2;
- L3 value = 4;
- expected L1-equivalent value per spawn = `7/3`;
- expected spawn count = `objective_cost / (7/3)`.

Label this clearly as a planning expectation only.

Do not pretend random spawn production or physical merging is deterministic.

## 3. Timer calculator

Build a transparent timer-planning tool.

Inputs must include:
- level definition;
- explicit seconds-per-launch or equivalent production-rate calibration.

Outputs:
- objective cost;
- expected spawn value;
- expected spawn count;
- calibration value used;
- raw calculated production time;
- raw ×2 planning target time;
- canonical configured timer;
- delta.

Do not hide a magic timing constant.

If you provide a default calibration:
- give it a named constant/config field;
- document where it came from;
- make it overrideable from CLI/test invocation.

Do not change canonical timers.

## 4. Spatial-complexity telemetry

Define a deterministic trial telemetry record with at least:

- island_id
- level_id
- seed
- outcome
- elapsed_sec
- remaining_sec
- shot_count
- merge_count
- failed_merge_approach_count or a documented bounded proxy
- peak_live_drinks
- mean_live_drinks
- peak_board_occupancy
- large_piece_coexistence_peak
- contact_count
- rail_contact_count where observable
- danger_line_exposure_sec
- normal_objective_complete
- vip_complete if available, but VIP must remain analytically separate from mandatory completion

Document every metric definition.

Prefer test/harness instrumentation over invasive production mutations.

## 5. Seeded gameplay-validation harness

Create a reusable command/test harness accepting:

- island_id
- level_id
- seed
- number of trials

Requirements:
- load canonical level data;
- isolate user/save state;
- seed randomness deterministically;
- exercise actual Godot gameplay/physics where practical;
- implement a deterministic baseline bot or replayable action interface;
- record every action needed to replay one exact trial;
- replaying the same seed/action log must reproduce the same logical result/telemetry within documented deterministic tolerance.

The bot need not represent optimal human play.

Document its policy so its limitations are obvious.

Do not silently "cheat" objectives by calling completion APIs directly if the purpose of the trial is physical difficulty validation.

If a pure-physics trial must use bounded helper hooks, document exactly what is simulated and what is not.

## 6. Baseline cohort

Run the harness on:

`1,10,11,20,21,30,31,40,41,50,51,60,61,70,71,80,81,90,91,100`

These are peak/relief pairs plus island anchors.

Target:
- 10 deterministic trials per level.

If that is impractical because real Godot physics makes execution too slow:
- run at least 3 per level;
- measure and report why 10 was infeasible;
- do not silently reduce trial count.

Use a deterministic seed schedule so the same report can be regenerated.

## 7. Report

Create a committed baseline report under:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/`

Suggested name:
`M17_BASELINE_REPORT_V01.md`

Also commit machine-readable data if useful:
`M17_BASELINE_REPORT_V01.json`

For every tested level include:
- trials;
- completion rate;
- median completion time;
- p75;
- p90;
- timeout count;
- danger/game-over count;
- harness-abort count;
- median/peak occupancy;
- median peak live drinks;
- median large-piece coexistence peak;
- contact/rail-contact summary;
- objective cost;
- planning target;
- canonical timer;
- notes.

Clearly distinguish:
- analytical planning metrics;
- actual seeded runtime evidence.

Do not label a level impossible solely because the baseline bot is weak.

## 8. V01 boundaries

Do not modify:
- `data/campaign/levels/sunny_cove.json`;
- normal objectives;
- timers;
- VIP content;
- reward/scoring;
- M15 HUD;
- R11 physics/table/colliders.

BCM-M17-007 and BCM-M17-008 are not to be implemented as canonical tuning in V01.

You may add **candidate flags in the report**, but they must be phrased as:
- "needs further validation",
- "baseline outlier",
- or equivalent,

not as a final gameplay judgment.

## 9. Tests

Add focused M17 tests covering:
- cost model;
- expected 7/3 spawn value;
- timer calculator;
- calibration override;
- same-seed reproducibility;
- action-log replay;
- telemetry schema;
- percentile method;
- no canonical-data mutation.

Run:
- M17 focused probe twice;
- M16 regression;
- M15 regression;
- authoritative physics regression/closure probe;
- `git diff --check`.

## 10. Completion

Write:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V01.md`

Include:
- implementation SHA;
- exact new files;
- model formulas;
- calibration interface;
- bot/replay policy;
- trial-count achieved per level;
- total harness runtime;
- report paths;
- test results;
- proof canonical Sunny Cove JSON was not modified;
- final sync proof.

Push to `main`, sync canonical Desktop, then return:

- implementation SHA;
- final main/canonical SHA;
- cost model PASS/FAIL;
- timer tooling PASS/FAIL;
- telemetry PASS/FAIL;
- deterministic harness PASS/FAIL;
- replayability PASS/FAIL;
- baseline cohort/trial count;
- report paths;
- canonical-data frozen PASS/FAIL;
- regressions;
- log URL;
- `AWAITING_M17_AUDIT_V01`.

Then STOP. Do not start M17 tuning or M18.
