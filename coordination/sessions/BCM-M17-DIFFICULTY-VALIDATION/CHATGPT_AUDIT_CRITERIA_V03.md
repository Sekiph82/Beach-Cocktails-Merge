# BCM-M17 Decision-Grade Solver Qualification — Audit Criteria V03

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V02.md`
- accepted V01 analytical model
- accepted V02 corrected telemetry
- current audited M16 Sunny Cove canonical content
- current authoritative gameplay/physics contracts

## Purpose

V02 proves the telemetry is now correct, but the baseline bot completed 0/60 trials and therefore cannot support M17-007/008 decisions.

V03 must qualify a stronger deterministic merge-aware validation policy at canonical physics time scale before any level is called effectively impossible or any canonical timer/objective is tuned.

This is still **validation tooling only**.

## Gate A — preserve accepted V01/V02 contracts

Do not regress:
- objective-cost model;
- separate VIP cost;
- 7/3 expected spawn value;
- timer calculator/calibration override;
- R7 percentiles;
- danger/timeout classification;
- rail-proximity transition proxy;
- V02 telemetry schema;
- action-log replay;
- canonical-data immutability.

## Gate B — stronger deterministic policy

Add a clearly named stronger policy, e.g. `MERGE_AWARE_V01`.

It may use only information a deterministic gameplay agent can legitimately observe:
- current spawned cocktail level;
- current board positions/levels/states;
- current mandatory normal objective state;
- current timer/danger state;
- canonical table geometry.

It may:
- aim at an existing same-level cocktail;
- choose among legal launch x positions;
- prefer less congested lanes when no immediate pair exists;
- prioritize merges that contribute toward the mandatory normal objective;
- avoid launching into a lane whose lower board region is already congested.

It must not:
- inspect future RNG values;
- alter spawn levels;
- teleport drinks after launch;
- call merge/completion/objective APIs directly;
- delete board pieces;
- change physics/colliders/timers;
- use privileged hidden future state.

Policy behavior must be documented and reproducible.

## Gate C — canonical physics time scale

All V03 qualification trials must run at:

`Engine.time_scale = 1.0`

No accelerated 4× physics may be used for the qualification verdict.

The harness may retain 4× support for historical telemetry, but V03 decision evidence must be canonical scale.

## Gate D — qualification cohort

Run exactly 5 deterministic trials each on:

`1, 10, 11, 50, 51, 100`

Total: **30 canonical-scale trials**.

Seed schedule:
- base = `17300000`
- formula = `base + level_id * 1000 + trial_index`

Use the stronger policy for all 30.

Required report:
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_SOLVER_QUALIFICATION_V03.json`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_SOLVER_QUALIFICATION_V03.md`

## Gate E — minimum solver qualification

The stronger policy is considered **decision-grade enough to continue M17 validation** only if all are true:

1. no harness aborts in the 30-trial cohort;
2. Level 1 completes at least **3/5** trials;
3. at least one of Level 10 or Level 11 records at least **1 completed trial**;
4. same-seed repeated run reproduces the exact action log and logical outcome for a focused canonical-scale fixture;
5. action-log replay reproduces the same logical outcome;
6. telemetry remains schema-valid.

These are solver-qualification thresholds only. They are not player difficulty ratings.

If any threshold fails:
- report `SOLVER_NOT_QUALIFIED`;
- do not implement M17-007 final classifications;
- do not tune canonical data;
- stop after evidence publication.

## Gate F — compare against V02 weak baseline

For the overlapping qualification levels, report:
- V02 weak-policy completion count;
- V03 merge-aware completion count;
- danger/timeout counts;
- median merges;
- median peak live drinks;
- median occupancy;
- rail-proxy events.

The purpose is to prove whether the stronger policy adds meaningful signal.

Do not claim statistical significance from 5 trials.

## Gate G — time-scale fidelity spot check

Use one fixed seed/action log for at least:
- Level 1;
- Level 50.

Replay the identical action log at:
- time scale 1.0;
- time scale 4.0.

Record:
- logical outcome;
- merge count;
- danger/timeout reason;
- elapsed gameplay time;
- peak live drinks.

If logical outcomes or merge counts diverge, explicitly mark accelerated 4× cohorts as **telemetry-only / not decision-grade for M17-007/008**.

No requirement exists that 1× and 4× match.

## Gate H — no M17-007/008 canonical decision unless qualified

V03 may produce candidate observations.

It must not:
- mark any canonical level mathematically/effectively impossible as a final project truth;
- modify timers/objectives;
- implement canonical tuning.

If qualification passes, hand back `SOLVER_QUALIFIED_FOR_M17_007`.

If it fails, hand back `SOLVER_NOT_QUALIFIED`.

M17-008 remains blocked in either case until a later independently audited evidence pass.

## Gate I — focused tests

Add/extend M17 focused tests for:
- policy determinism;
- no privileged future-RNG access;
- legal x-position selection;
- canonical time scale in qualification runner;
- same-seed reproducibility;
- replay reproducibility;
- unchanged V02 outcome/rail telemetry;
- unchanged canonical data.

Required regression PASS:
- M17 focused probe twice;
- M16;
- M15;
- M02;
- `git diff --check`.

## Governance

Codex must:
- sync canonical Desktop before/after;
- not edit root `TASKS.md`;
- not create GitHub branches;
- not create Desktop clones/worktrees;
- not modify canonical Sunny Cove data;
- not start M18.

## Builder log

Write:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V03.md`

Final qualification verdict requires independent ChatGPT audit.
