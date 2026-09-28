# BCM-M17 Full Canonical Challenge Screening — Independent Audit V04

Verdict: **AUDITED_PASS / BCM-M17-007 COMPLETE**

Auditor: ChatGPT  
Builder: CODEX  
Branch: `main`  
Implementation SHA: `3d360d2025830f51ae1f9b41cdc0d1e5ebcf76c8`  
Final audited HEAD: `d10d4765eba88d3de660ab2328993f4736755663`

## 1. Summary

M17 V04 passes independent audit.

The full 100-level Sunny Cove canonical challenge space is mapped and screened.

Independent results:
- 100 canonical levels;
- 45 exact physical challenge-signature classes;
- 0 class-map mismatches;
- no mathematically unreachable normal objective;
- timer/cost median = 1.25;
- no analytical timer-ratio outlier;
- 10 solver-feasible classes;
- 3 high-risk 0/5 solver-failure classes;
- 32 single-trial failures requiring confirmation;
- 21 spatial-mix candidate pairs affecting 27 classes;
- 25 VIP-interception-risk levels;
- canonical Sunny Cove data byte-for-byte unchanged.

BCM-M17-007 is therefore complete as a **screening/flagging** task.

BCM-M17-008 remains open. V04 does not authorize blind timer extensions or canonical tuning.

## 2. Independent 100-level / 45-class reconstruction

ChatGPT independently rebuilt challenge signatures from final canonical Sunny Cove data using exactly:

- ordered normal objectives + quantities;
- timer;
- VIP enabled state;
- VIP cocktail level;
- VIP quantity.

Result:
- levels mapped: **100**
- distinct signatures: **45**
- report classes: **45**
- representative/member mismatches: **0**
- every representative is the lowest level ID in its class.

This independently confirms the V04 class map.

## 3. Mathematical reachability

PASS.

The V04 model constructs the legal merge closure from:
- spawn L1/L2/L3;
- equal-level merge to next level;
- current max cocktail level.

Closure reaches L1-L12.

All Sunny Cove mandatory normal targets are within that closure and use positive quantity/timer values.

Independent report inspection confirms:

`MATHEMATICALLY_UNREACHABLE = NONE`

The model correctly does not manufacture a time-based mathematical impossibility from the provisional seconds-per-launch planning calibration.

## 4. Timer/cost analytical scan

PASS.

ChatGPT independently recomputed for all 100 levels:

`timer / normal_objective_cost`

Cohort median:
**1.25**

Independent >5% deviation list:
**NONE**

Report outlier list:
**NONE**

The canonical table is therefore analytically uniform under this metric.

This does not imply equal spatial difficulty.

## 5. VIP interception analysis

PASS, with a major design finding.

ChatGPT independently recomputed the minimum VIP-level intermediate production required by each VIP-enabled level and matched the V04 report exactly.

VIP interception risk levels:

`4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100`

Count:
**25 / 25 configured VIP levels**

Independent anchors:

### Level 4
- normal: 1×L6
- VIP: 1×L5
- normal cost: 32
- minimum forced VIP capture: 1×L5
- forced cost: 16
- effective lower bound: 48
- forced overhead: 50%

### Level 60
- normal: L8 + L6 + L5
- VIP: 1×L7
- normal cost: 176
- minimum forced capture: 1×L7
- forced cost: 64
- effective lower bound: 240
- forced overhead: 36.36%

### Level 100
- normal: L8 + L7 + L6 + L5
- VIP: 1×L7
- normal cost: 240
- minimum forced capture: 1×L7
- forced cost: 64
- effective lower bound: 304
- forced overhead: 26.67%

Production source confirms why:

`GameManager.on_merged()` routes:
1. current mandatory target first;
2. otherwise a matching active VIP target immediately.

`_try_collect_stocked_target()` also captures a distinct matching VIP stock drink while normal work remains.

Because each configured VIP level sits below a higher mandatory target somewhere in its level's ordered normal objectives, the mandatory production path necessarily creates the VIP-level intermediate.

The current implementation can therefore consume mandatory production intermediates into VIP progress.

This means the M16 owner contract "VIP is optional and excluded from the normal timer" is not fully realized mechanically even though VIP is not a logical WIN requirement.

This is the most important V04 finding.

## 6. Production precedence fixtures

PASS.

V04 tests do not rely only on a pure helper.

The focused probe creates actual GameManager + GameplaySessionBridge fixtures for L4/L60/L100 and calls the real production `on_merged()` route.

Observed:
- mandatory current target routes to normal capture;
- distinct active VIP target routes to VIP capture.

The analytical forced-interception model is therefore grounded in the actual production precedence.

## 7. Physical screening classification

Independent report inspection confirms:

### Solver-feasible
**10 classes**

C01, C02, C04, C06, C07, C08, C09, C12, C20, C36.

### High-risk qualified-solver failure
**3 classes**

- C17, representative L29, members L29/L34/L37/L39/L42/L51
- C26, representative L47, members L47/L50/L53/L55/L62/L71
- C45, representative L100

Each has exact-class canonical-scale 0/5 evidence.

These are high-risk candidates, not proof of human impossibility.

### Single-trial screening failure
**32 classes**

These correctly remain:
`SCREENING_FAILURE_NEEDS_CONFIRMATION`

No one-trial failure was promoted to effective impossibility.

## 8. Spatial-mix candidates

PASS as screening evidence.

Report contains:
- 21 candidate class-pairs;
- 27 affected classes.

They are restricted to classes with equal normal cost/timer and different objective composition, with differing solver feasibility/danger signals.

The report explicitly marks them as small-sample candidate signals rather than statistical proof.

## 9. V03A evidence reuse note

The locked wording said to reuse V03A evidence when the *representative* itself was one of:
L1/L10/L11/L50/L51/L100.

The implementation instead reused all six V03A sources at the **exact challenge-signature class** level.

This means:
- L11 evidence is reused for C04 whose representative is L6;
- L51 evidence is reused for C17 whose representative is L29;
- L50 evidence is reused for C26 whose representative is L47.

ChatGPT independently verified that each reused source is an exact member of the corresponding challenge-signature class.

Because the class signature is the defined physical challenge identity, this substitution is evidence-equivalent and strictly stronger than replacing five audited same-class trials with one new representative trial.

It does not weaken screening coverage and is accepted as a bounded methodological deviation.

Result:
- reused V03A trials: 30
- new V04 trials: 39
- all 45 challenge classes have canonical-scale evidence.

## 10. Canonical/product freeze

PASS.

Compared V04 start HEAD with final audited HEAD.

Changes are limited to:
- V04 analytical model;
- V04 screening runner;
- V04 focused probe;
- V04 JSON/Markdown/log evidence.

`data/campaign/levels/sunny_cove.json` is byte-for-byte unchanged.

No change to:
- normal objectives;
- timers;
- VIP content;
- M15 HUD;
- scoring/economy;
- production table/physics/colliders.

## 11. Regression evidence

Builder reports PASS:
- V04 focused probe;
- M17 focused probe ×2;
- M16;
- M15;
- M02;
- `git diff --check`.

ChatGPT did not execute Godot locally, but independently verified:
- final GitHub HEAD;
- canonical data;
- V04 model/tool/test source;
- full JSON/Markdown evidence;
- class mapping;
- timer ratios;
- VIP interception calculations;
- production routing fixtures.

No repository evidence contradicts the reported PASS results.

## 12. Gate matrix

| Gate | Result |
| --- | --- |
| A qualified solver / telemetry preserved | PASS |
| B 45 challenge classes | PASS |
| C mathematical reachability | PASS |
| D timer/cost scan | PASS |
| E VIP interception analysis | PASS |
| F canonical-scale class screening | PASS |
| G class/level classifications | PASS |
| H 100-level report | PASS |
| I interpretation boundaries | PASS |
| J tests | PASS |
| K canonical/product freeze | PASS |

## 13. M17 task state

**BCM-M17-007: AUDITED_PASS / COMPLETE**

Still open:

**BCM-M17-008 — evidence-driven tuning/remediation.**

### Required M17-008 order of operations

V04 does **not** support adding timer padding first.

Before any canonical level-data tuning:

1. restore true VIP optionality so VIP cannot automatically consume the mandatory production reserve;
2. preserve the owner-approved VIP cadence/targets/rewards and normal timers;
3. revalidate mandatory completion difficulty after that structural fix;
4. only then decide whether C17/C26/C45 or any confirmed outlier needs objective/timer data tuning.

This follows the M17 rule:

> never hide structural/impossible design behind arbitrary timer extensions.

**M17 V04: AUDITED_PASS.**
