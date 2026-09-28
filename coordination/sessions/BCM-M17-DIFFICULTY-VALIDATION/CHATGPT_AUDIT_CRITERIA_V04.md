# BCM-M17 Full Canonical Challenge Screening — Audit Criteria V04

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V03A.md`
- accepted V01 analytical model
- accepted V02 telemetry
- accepted V03A `MERGE_AWARE_V01` solver qualification
- current audited M16 Sunny Cove canonical data
- current production GameManager objective/VIP capture precedence

## Purpose

Use the now-qualified canonical-scale solver to perform the actual BCM-M17-007 screening pass.

V04 must flag the full 100-level Sunny Cove challenge space for:
- mathematical reachability failures;
- solver-feasibility evidence;
- high-risk solver failures;
- spatial/objective-mix outlier candidates;
- VIP-interception workload risk.

V04 is **screening/evidence only**.

No canonical timer/objective/VIP tuning is authorized.

## Gate A — preserve the qualified solver and telemetry

Do not regress:
- `MERGE_AWARE_V01` board-state-responsive policy;
- anti-fixed-lane action evidence;
- canonical 1× qualification requirement;
- danger/timeout classification;
- rail-proximity transition proxy;
- telemetry schema;
- action-log replay;
- cost/timer analytical model.

V04 screening trials must use:
- `MERGE_AWARE_V01`
- `Engine.time_scale = 1.0`

Historical 4× data remains telemetry-only and may not drive V04 classifications.

## Gate B — canonical challenge-signature map

Build one deterministic challenge signature for every Sunny Cove level from gameplay-affecting campaign fields:

1. ordered mandatory normal `orders` list, including quantity;
2. `time_limit_sec`;
3. VIP enabled/disabled;
4. if enabled: VIP cocktail level and quantity.

Do not include score-star thresholds, normal rewards, or VIP booster reward type in the physical challenge signature because they do not change mandatory board physics before terminal completion.

On the currently audited 100-level data, the expected result is:

- **100 mapped levels**
- **45 distinct challenge-signature classes**

If the count is not 45, STOP and explain the canonical-data discrepancy rather than silently adapting.

For every class record:
- signature ID;
- exact signature;
- member level IDs;
- deterministic representative = lowest level ID in the class.

## Gate C — mathematical reachability audit for all 100 levels

Implement a strict reachability model based on actual merge rules:

- spawn levels available: L1, L2, L3;
- merge rule: two equal L(n) -> one L(n+1);
- maximum cocktail level from current Drink data.

For each mandatory normal target:
- prove the target level belongs to the reachable closure;
- validate positive quantity;
- validate positive timer.

Classification:

`MATHEMATICALLY_UNREACHABLE`

may be used only when a mandatory target cannot be constructed from the legal spawn/merge closure or the canonical record is structurally invalid.

Do **not** call a level mathematically impossible merely because:
- the provisional timer-planning estimate exceeds its timer;
- the solver fails;
- a random seed is unfavorable.

The current production ShotController has no fixed fire cooldown, so V04 must not invent a strict time-impossibility bound from the provisional seconds-per-launch calibration.

## Gate D — analytical timer/cost outlier scan

For all 100 levels calculate:
- normal objective L1-equivalent cost;
- canonical timer;
- timer / normal-cost ratio;
- V01 planning target;
- canonical-vs-planning delta.

Report:
- cohort median timer/cost ratio;
- per-level percentage deviation from median.

Flag:
`ANALYTICAL_TIMER_RATIO_OUTLIER`

only when absolute deviation from the cohort median exceeds **5%**.

This is an analytical outlier flag, not a tuning instruction.

## Gate E — VIP interception workload analysis

The production GameManager automatically captures a distinct active VIP cocktail when a matching merged/stocked drink exists, while same-level mandatory normal delivery has first claim.

V04 must model the consequence for mandatory production.

For every VIP-enabled level:
- preserve ordered normal objectives;
- preserve VIP quantity remaining;
- determine whether construction of a higher mandatory target necessarily produces intermediate cocktails equal to the active VIP level before normal completion;
- calculate the minimum number of VIP pieces that production would auto-capture before all mandatory normal objectives can be completed;
- calculate forced-interception L1-equivalent cost;
- calculate:
  `effective_mandatory_production_lower_bound = normal_cost + forced_vip_interception_cost`
- calculate forced overhead percentage vs normal cost.

Orthogonal flag:

`VIP_INTERCEPTION_RISK`

must be true when forced captures > 0.

Important:
- this does not change the logical WIN requirement;
- it identifies mechanically unavoidable extra production caused by auto-capture while the timer still excludes VIP cost;
- do not alter VIP behavior in V04.

Focused proof fixtures must include at least:
- L4
- L60
- L100

and demonstrate the analytical interception model matches production normal-first/VIP-second precedence.

## Gate F — class-representative canonical-scale screening

Screen every one of the 45 challenge classes.

### Existing deep evidence reuse

If a class representative is one of the V03A levels:
`1, 10, 11, 50, 51, 100`

reuse the exact audited V03A 5-trial canonical-scale evidence for that class.

Do not rerun merely to create different results.

### New class evidence

For each remaining class representative:
- run exactly **1** canonical-scale trial;
- policy = `MERGE_AWARE_V01`;
- seed:
  `17400000 + representative_level_id * 1000`

No trial index offset is needed because this is the broad-screen seed.

The report must clearly distinguish:
- `V03A_5_TRIAL`
- `V04_SINGLE_TRIAL_SCREEN`

evidence strength.

## Gate G — class/level screening classifications

Every challenge class, and therefore all 100 levels, must receive screening classifications.

Allowed physical-evidence flags:

### `SOLVER_FEASIBLE`
At least one canonical-scale qualified-solver trial for the class completed.

### `HIGH_RISK_SOLVER_FAILURE`
Use only when audited evidence contains at least **5 canonical-scale trials** for that exact challenge class with **0 completions**.

V03A currently provides this evidence strength for the L50, L51, and L100 challenge classes if the canonical signature still matches.

### `SCREENING_FAILURE_NEEDS_CONFIRMATION`
The single V04 broad-screen trial failed, but fewer than 5 audited canonical-scale trials exist.

This is not an effective-impossibility verdict.

### `SPATIAL_MIX_OUTLIER_CANDIDATE`
May be added when two classes share the same normal objective cost and timer but materially different ordered target composition and their qualified-solver evidence shows different feasibility/danger patterns.

The report must state that one/few-seed differences are candidate signals, not statistical proof.

Orthogonal analytical flags:
- `MATHEMATICALLY_UNREACHABLE`
- `ANALYTICAL_TIMER_RATIO_OUTLIER`
- `VIP_INTERCEPTION_RISK`

No class may be silently left unclassified.

## Gate H — 100-level mapped screening report

Create immutable outputs:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V04.json`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V04.md`

JSON must contain:

### Global
- canonical data SHA-256;
- policy name;
- physics scale;
- 100 level count;
- 45 class count;
- classification definitions;
- challenge-class map;
- number of newly executed V04 trials;
- number of reused V03A trials.

### Per class
- signature;
- member levels;
- representative;
- evidence source;
- trial outcomes;
- completion count / trial count;
- median merge/live/occupancy/rail metrics when sample size permits;
- physical screening flags.

### Per level
- class ID;
- normal cost;
- timer;
- timer/cost ratio;
- planning delta;
- mathematical reachability result;
- VIP forced-capture count/cost/overhead;
- all applicable flags.

Markdown must provide concise tables for:
- mathematically unreachable levels;
- analytical timer-ratio outliers;
- VIP interception risk levels;
- solver-feasible classes;
- high-risk 0/5 classes;
- single-trial failures requiring confirmation;
- spatial-mix outlier candidates.

## Gate I — interpretation boundaries

V04 must explicitly state:

- one successful qualified-solver completion proves at least one solver-feasible path, not human difficulty;
- one failed screening seed does not prove impossibility;
- 0/5 qualified-solver evidence is a **high-risk candidate**, not proof no human can complete;
- historical 4× results are excluded from decision classifications;
- no timer/objective change is authorized by V04 itself.

## Gate J — tests

Add/extend focused M17 tests for:
- exactly 45 challenge classes from current canonical data;
- all 100 levels map to exactly one class;
- deterministic representative selection;
- reachability closure;
- no fabricated strict timer-impossibility rule;
- VIP interception fixtures L4/L60/L100;
- correct reuse of V03A class evidence;
- V04 new trials forced to time scale 1.0;
- every class/level receives classifications;
- canonical JSON unchanged.

Required regression PASS:
- M17 focused probe twice;
- M16;
- M15;
- M02;
- `git diff --check`.

## Gate K — canonical/product freeze

No changes to:
- `data/campaign/levels/sunny_cove.json`;
- normal objectives/timers;
- VIP targets/quantities/rewards;
- M15 HUD;
- scoring/economy;
- production table/physics/colliders.

No M17-008 tuning in V04.

## Governance

Codex must:
- sync canonical Desktop before/after;
- not edit root `TASKS.md`;
- not create branches;
- not create Desktop clones/worktrees;
- not start M18.

## Builder log

Write:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V04.md`

Final BCM-M17-007 closure requires independent ChatGPT audit of the V04 screening report.
