# BCM-M17 Full Canonical Challenge Screening — Execution Prompt V04

Execute against:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V03A.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V04.md`
- current `main`

Before work:
- obey `AGENTS.md`;
- synchronize `C:\Users\sekip\Desktop\Beach Cocktails - Merge`;
- confirm clean `main`.

## Goal

Perform the actual BCM-M17-007 screening pass over all 100 Sunny Cove levels using the independently qualified canonical-scale `MERGE_AWARE_V01` solver.

This task must **flag**, not tune.

Do not modify any canonical campaign data.

## 1. Preserve the qualified solver

Use:

`MERGE_AWARE_V01`

for every new physical screening trial.

All V04 decision evidence must run at:

`Engine.time_scale = 1.0`

Do not use historical 4× results for classification.

Preserve:
- V02 danger/timeout semantics;
- V02 rail-proximity metric;
- V03A anti-fixed-lane behavior;
- action-log evidence.

## 2. Build the 100-level challenge-signature map

For each canonical Sunny Cove level define its physical challenge signature from:

- ordered normal objectives with quantities;
- timer;
- VIP enabled/disabled;
- VIP cocktail level;
- VIP quantity.

Do not include:
- score thresholds;
- score rewards;
- booster reward type

because these do not change pre-terminal board physics.

Expected canonical result:

- 100 levels
- **45 challenge classes**

If the current data does not produce exactly 45 classes:
- STOP;
- do not silently continue;
- report the discrepancy.

Representative rule:

`representative = lowest level_id in the class`

## 3. Mathematical reachability

Build reachable cocktail closure from:

- spawn L1/L2/L3;
- merge L(n)+L(n) -> L(n+1);
- current `Drink.max_level()`.

For all 100 normal objectives:
- verify target level reachable;
- quantity >0;
- timer >0.

Only use:

`MATHEMATICALLY_UNREACHABLE`

for a real structural reachability failure.

Do not derive mathematical impossibility from:
- a failed bot seed;
- the provisional 1.5 sec/launch calibration;
- the V01 planning target.

The production ShotController has no fixed mandatory firing cooldown, so do not invent one.

## 4. Timer/cost analytical scan

For all 100 levels report:

- normal objective cost;
- canonical timer;
- timer/cost ratio;
- V01 planning target;
- canonical minus planning delta;
- percentage deviation of timer/cost ratio from cohort median.

Flag:

`ANALYTICAL_TIMER_RATIO_OUTLIER`

only if absolute deviation from median >5%.

Do not tune.

## 5. Detect forced VIP interception workload

This is a critical V04 requirement.

Production behavior:
- current mandatory normal target has first claim if the merged drink matches it;
- otherwise a distinct active VIP target can auto-capture a matching merged/stocked drink.

Therefore an active VIP cocktail can mechanically consume an intermediate piece needed to build a higher mandatory normal cocktail.

Create a deterministic analytical model of this production precedence.

For every VIP level calculate:

- VIP quantity remaining;
- mandatory normal order sequence;
- whether a higher mandatory target necessarily generates intermediate VIP-level pieces;
- minimum forced VIP captures before normal completion;
- forced VIP L1-equivalent cost;
- normal cost;
- effective lower-bound production cost:
  `normal_cost + forced_vip_cost`;
- overhead percentage.

Set:

`VIP_INTERCEPTION_RISK = true`

when forced captures >0.

Do not change the VIP system in this task.

### Required production-precedence fixtures

Explicitly validate:
- L4
- L60
- L100

against GameManager's normal-first / VIP-second behavior.

The fixtures must prove the analytical forced-capture result is consistent with production routing.

## 6. Canonical-scale class screening

Every one of the 45 challenge classes must receive physical evidence.

### Reuse V03A deep evidence

If the representative is exactly one of:

`1,10,11,50,51,100`

reuse the already-audited V03A 5-trial canonical-scale cohort for that class.

Evidence source:

`V03A_5_TRIAL`

Do not rerun these merely to obtain different outcomes.

### Run all remaining representatives once

For each other challenge-class representative run exactly one canonical-scale trial.

Policy:
`MERGE_AWARE_V01`

Seed:
`17400000 + representative_level_id * 1000`

Evidence source:

`V04_SINGLE_TRIAL_SCREEN`

Record full telemetry/action log as normal.

## 7. Apply screening flags exactly

### SOLVER_FEASIBLE

Use when at least one canonical-scale qualified-solver trial for the class completes.

### HIGH_RISK_SOLVER_FAILURE

Use only when the exact class has at least 5 canonical-scale audited trials and completion count is 0.

Do not promote a one-trial failure into this category.

### SCREENING_FAILURE_NEEDS_CONFIRMATION

Use when:
- the V04 single broad-screen trial fails;
- exact class has fewer than 5 audited canonical-scale trials.

### SPATIAL_MIX_OUTLIER_CANDIDATE

Compare classes with:
- same normal objective cost;
- same timer;
- different ordered target composition.

Flag when solver evidence shows materially different feasibility/danger behavior.

State explicitly that sample sizes are small.

Orthogonal flags:
- MATHEMATICALLY_UNREACHABLE
- ANALYTICAL_TIMER_RATIO_OUTLIER
- VIP_INTERCEPTION_RISK

Every class and every level must receive a classification record.

## 8. Produce immutable V04 outputs

Create:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V04.json`

and:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V04.md`

### JSON global fields

Include at minimum:
- canonical data SHA-256;
- policy;
- physics scale;
- 100-level count;
- 45-class count;
- class signature definition;
- classification definitions;
- number of reused V03A trials;
- number of new V04 trials.

### Per-class

Include:
- class ID;
- full signature;
- representative;
- member levels;
- evidence source;
- trial count;
- completion/danger/timeout/abort counts;
- telemetry summary;
- physical screening flags.

### Per-level

Include:
- level ID;
- class ID;
- normal objective cost;
- timer;
- timer/cost ratio;
- planning target/delta;
- reachability result;
- VIP forced-capture count;
- forced cost;
- forced overhead percentage;
- all flags.

### Markdown summary tables

Required:
- mathematical unreachable list;
- timer-ratio outlier list;
- VIP-interception-risk list;
- solver-feasible classes;
- high-risk 0/5 classes;
- one-trial failures needing confirmation;
- spatial-mix candidates.

Empty sections are allowed, but write `NONE` explicitly.

## 9. Interpretation rules

The report must state:

- one qualified-solver completion proves at least one solver-feasible path;
- one failed seed does not prove impossibility;
- 0/5 is high-risk solver evidence, not proof no human can win;
- 4× historical cohorts are excluded from classification;
- V04 itself authorizes no data change.

## 10. Tests

Extend M17 tests to verify:

- exactly 45 challenge classes;
- all 100 levels map once;
- lowest-ID representative rule;
- reachability closure;
- no fabricated timer-impossibility rule;
- L4/L60/L100 forced VIP-interception fixtures;
- V03A evidence reuse for the exact six representatives;
- all newly executed V04 trials use 1×;
- all classes and levels receive classifications;
- canonical Sunny Cove JSON byte-for-byte unchanged.

Run:

- M17 focused probe twice;
- M16;
- M15;
- M02;
- `git diff --check`.

## Hard boundaries

Do not modify:
- `data/campaign/levels/sunny_cove.json`;
- any normal order;
- any timer;
- any VIP target/quantity/reward;
- M15 HUD;
- scoring/economy;
- production table/physics/colliders.

Do not implement M17-008 tuning.

Do not start M18.

Do not edit root `TASKS.md`.

Do not create a GitHub branch or Desktop clone/worktree.

## Completion

Write:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V04.md`

Include:
- challenge-class count;
- representative map;
- number of reused/new trials;
- mathematical reachability results;
- timer-ratio outliers;
- VIP forced-interception results;
- physical classification counts;
- V04 report links;
- canonical data frozen proof;
- regressions;
- final sync proof.

Push to `main`, sync canonical Desktop, then return:

- implementation SHA;
- final main/canonical SHA;
- challenge classes PASS/FAIL;
- mathematical reachability PASS/FAIL;
- timer scan PASS/FAIL;
- VIP interception analysis PASS/FAIL;
- physical screening PASS/FAIL;
- classification summary;
- canonical data frozen PASS/FAIL;
- regressions;
- report links;
- log URL;
- `AWAITING_M17_AUDIT_V04`.

Then STOP. Do not tune canonical data.
