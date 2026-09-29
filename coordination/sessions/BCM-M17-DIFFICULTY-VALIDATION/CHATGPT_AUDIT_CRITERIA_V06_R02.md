# BCM-M17 V06-R02 - Locked Remediation Audit Criteria

Status: **LOCKED BEFORE REMEDIATION**

## Gate A - governance and freeze

The checkout is clean synchronized `main`; root `TASKS.md` is unchanged by CODEX; canonical Sunny Cove, V04, V05, V06, and V06-R01 paths retain their baseline hashes and bytes. The only implementation change is the bounded V06-R02 runner integrity check.

## Gate B - corrected direct execution

The fresh V06-R02 runner returns PASS directly with exit code 0. A repair or post-failure bookkeeping conversion is not acceptable evidence.

## Gate C - complete fresh screen

The new report contains 100 levels, 45 exact challenge classes, and 45 fresh one-trial records at `MERGE_AWARE_V01` and `Engine.time_scale = 1.0`. Each trial contains the established flat telemetry fields and action log; each class contains policy and time-scale metadata, representative, members, outcome counters, and interpretation flags.

## Gate D - preserved semantics and scope

The report preserves `0/25` forced captures and `25/25` surplus paths, adds no VIP cost to timers, changes no production or canonical data, and does not overwrite V04, V05, V06, or V06-R01 evidence. Single-trial failures remain confirmation candidates; no `HIGH_RISK_SOLVER_FAILURE` is assigned without exact-class 0/5 evidence.

## Gate E - downstream regression

Only after the corrected runner passes, V05 optionality, M17 difficulty validation twice, M16, M15, M14, M02, tooling parse checks, report inspection, and `git diff --check` pass.

## Gate F - handoff

Child 03 and Child 04 logs include exact commands/results, SHAs/URLs, frozen hashes, scope limits, synchronization proof, and the final marker `AWAITING_M17_AUDIT_V06_R02`. Any failed or unverified material criterion is `CHANGES_REQUIRED`; M17-008 tuning and M18 remain blocked.
