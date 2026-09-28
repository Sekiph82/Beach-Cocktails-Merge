# BCM-M17 Decision-Grade Solver Qualification — Execution Prompt V03

Execute against:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V02.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V03.md`
- current `main`

Before work:
- obey `AGENTS.md`;
- synchronize `C:\Users\sekip\Desktop\Beach Cocktails - Merge`;
- confirm clean `main`.

## Goal

V02 telemetry is now accepted, but the old deterministic lane bot completed 0/60 trials.

Build and qualify a stronger deterministic merge-aware validation policy at canonical physics time scale so later M17-007/008 decisions have a meaningful evidence base.

Do not tune any canonical level in V03.

## 1. Add a stronger deterministic policy

Add a named policy, preferably:

`MERGE_AWARE_V01`

Keep the old V02 policy available for historical comparison.

The stronger policy may observe:
- current spawned level;
- current board drink levels/positions/states;
- current mandatory normal objective state;
- timer/danger state;
- canonical table geometry.

Allowed behavior:
- aim at a matching same-level cocktail;
- choose a legal x launch position;
- prefer lanes with lower congestion;
- prioritize merge chains that contribute toward the mandatory normal objective;
- avoid obviously dangerous lower-board congestion.

Forbidden:
- future RNG peeking;
- spawn-level rewriting;
- post-launch teleportation;
- direct merge calls;
- direct completion/objective mutation;
- deleting board pieces;
- physics/timer/collider changes.

Document the exact deterministic decision order and tie-breakers.

## 2. Canonical-scale runner

Add a V03 qualification runner that forces:

`Engine.time_scale = 1.0`

for all qualification trials.

Do not use 4× for the qualification verdict.

## 3. Qualification cohort

Run exactly 5 trials each for:

`1, 10, 11, 50, 51, 100`

Total:
`30 trials`

Seed base:
`17300000`

Seed formula:
`base + level_id * 1000 + trial_index`

Generate:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_SOLVER_QUALIFICATION_V03.json`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_SOLVER_QUALIFICATION_V03.md`

Per level report:
- completed / timeout / danger / abort counts;
- completion rate;
- median completion time;
- median merge count;
- median peak live drinks;
- median occupancy;
- median rail-proxy events;
- median contact count;
- median failed-merge proxy;
- canonical timer;
- normal objective cost.

## 4. Qualification threshold

Compute a machine-readable verdict.

`SOLVER_QUALIFIED_FOR_M17_007` only if:

- 30/30 trials finish without harness abort;
- L1 completion >= 3/5;
- at least one of L10/L11 has >= 1 completion;
- focused same-seed action log reproduces;
- focused replay reproduces logical outcome;
- telemetry validates.

Otherwise:

`SOLVER_NOT_QUALIFIED`

If not qualified:
- do not tune anything;
- do not invent final impossible/outlier conclusions;
- publish evidence and stop.

## 5. Compare with V02 weak baseline

For overlapping levels:

`1,10,11,50,51,100`

compare V02 weak policy vs V03 merge-aware policy:

- completion count;
- danger count;
- timeout count;
- median merges;
- peak live drinks;
- occupancy;
- rail events.

The report must clearly say this is a small diagnostic comparison, not statistical significance.

## 6. Time-scale fidelity spot check

Choose one fixed seed/action log for:
- L1;
- L50.

Replay the identical action log at:
- 1×;
- 4×.

Record:
- outcome;
- merge count;
- terminal reason;
- elapsed gameplay time;
- peak live drinks.

If 1× and 4× differ in outcome or merge count, explicitly mark historical 4× cohorts:

`TELEMETRY_ONLY_NOT_DECISION_GRADE`

Do not attempt to force them to match by altering physics.

## 7. Preserve V02 telemetry

Do not regress:
- danger vs timeout classification;
- rail hysteresis/proxy;
- schema metadata;
- action logging;
- canonical-data hashing;
- report consistency validation.

## 8. Focused tests

Add/extend M17 tests for:

- policy is deterministic;
- same board state + same spawn level => same chosen action;
- selected x is legal;
- no future RNG input is consumed by policy;
- qualification runner uses exactly time scale 1.0;
- same-seed repeat;
- action-log replay;
- V02 danger classification;
- V02 rail proxy;
- canonical Sunny Cove JSON unchanged.

Run:
- M17 focused probe twice;
- M16;
- M15;
- M02;
- `git diff --check`.

## 9. Frozen boundaries

Do not modify:
- `data/campaign/levels/sunny_cove.json`;
- objectives;
- timers;
- VIP content;
- rewards/scoring/economy;
- M15 HUD;
- R11 physics/table/colliders.

Do not implement M17-008 tuning.

Do not start M18.

## Completion

Write:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V03.md`

Include:
- exact policy algorithm;
- implementation SHA;
- final main/canonical SHA;
- 30-trial qualification results;
- L1 completion count;
- L10/L11 completion counts;
- qualification verdict;
- 1× vs 4× spot-check results;
- V02 comparison;
- canonical-data frozen proof;
- regressions;
- report links;
- final sync proof.

Push to `main`, sync canonical Desktop, then return:

- implementation SHA;
- final main/canonical SHA;
- merge-aware policy PASS/FAIL;
- canonical-scale cohort PASS/FAIL;
- solver qualification verdict;
- L1 / L10 / L11 completion counts;
- time-scale fidelity result;
- canonical data frozen PASS/FAIL;
- regressions;
- report links;
- log URL;
- `AWAITING_M17_AUDIT_V03`.

Then STOP.
