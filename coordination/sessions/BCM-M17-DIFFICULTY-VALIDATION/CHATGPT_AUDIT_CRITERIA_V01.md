# BCM-M17 Difficulty Model + Validation Harness — Audit Criteria V01

Status: **LOCKED BEFORE EXECUTION**

Authority:
- root `TASKS.md` M17 section
- `docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md`
- current audited M02/R11 physics contracts
- current audited M16 canonical Sunny Cove Level 1-100 content

## V01 scope

This pass covers the tooling foundation for:
- BCM-M17-001
- BCM-M17-002
- BCM-M17-003
- BCM-M17-004
- BCM-M17-005
- BCM-M17-006

BCM-M17-007 and BCM-M17-008 remain pending until the harness has produced auditable evidence.

No canonical level objective or timer tuning is authorized in V01.

## Gate A — deterministic objective-cost model

Provide one reusable M17 difficulty-model implementation that calculates, for every campaign level:

`cost(Ln) = 2^(n-1)`

and:

`objective_cost = SUM(quantity * cost(cocktail_level))`

Required:
- deterministic;
- no duplicated divergent formulas across tools/tests;
- validates all 100 Sunny Cove rows;
- Level 1 cost = 16;
- Level 100 cost = 240;
- VIP cost reported separately and never added to normal objective cost/timer.

## Gate B — expected L1-L3 spawn-production model

Expose the random spawn baseline explicitly:

- possible spawn levels = L1, L2, L3;
- default probability assumption = uniform only because runtime uses `randi_range(1,3)`;
- expected L1-equivalent value per spawn = `(1 + 2 + 4) / 3 = 7/3`;
- expected spawn count for an objective = `objective_cost / (7/3)`.

The tool must label this as an expectation/planning metric, not a physical guarantee.

## Gate C — timer-calculation tooling

Provide tooling that exposes, per level:

- normal objective cost;
- expected L1-equivalent value per spawn;
- expected spawn count;
- explicit configurable seconds-per-launch / production-rate assumption;
- raw calculated production time;
- `×2` planning target time;
- canonical configured timer;
- delta between planning target and canonical timer.

Important:
- do not invent a hidden seconds-per-launch constant;
- any default calibration must be named, documented, and overrideable;
- V01 must not modify canonical timers;
- the output must distinguish "planning estimate" from "runtime evidence."

## Gate D — spatial difficulty treated separately

The M17 model must not equate theoretical merge cost with real difficulty.

The report/schema must explicitly separate:
- theoretical production cost;
- physical/spatial complexity;
- timer result.

No formula may claim that same-level cocktails merge for free merely because their L1-equivalent cost matches.

## Gate E — telemetry schema

Define and collect, at minimum, per seeded trial:

- level_id;
- seed;
- outcome: completed / timeout / danger / harness abort;
- elapsed_sec;
- remaining_sec;
- shot_count;
- merge_count;
- failed/unsuccessful merge-approach count if observable;
- peak live drink count;
- mean live drink count;
- peak board occupancy estimate;
- large-piece coexistence peak;
- contact/collision count;
- rail-contact count where observable;
- danger-line exposure duration;
- objective completion state.

Definitions must be documented and deterministic.

If a metric cannot be observed without invasive production changes, it may be marked unavailable only with explicit justification and a bounded proxy.

## Gate F — seeded validation harness / replayable bot interface

Implement a reusable test/tool harness that:
- loads canonical campaign data;
- accepts island_id, level_id, seed, and trial count;
- seeds the relevant RNG deterministically;
- runs against actual Godot gameplay/physics contracts where practical;
- can replay one exact trial from its seed/action log;
- records the telemetry schema;
- does not modify player save data;
- does not mutate canonical campaign data.

The harness may use a deterministic baseline bot/policy. The policy must be documented and reproducible.

This is a validation tool, not a claim of optimal human play.

## Gate G — baseline report

Produce a committed M17 V01 baseline report for a bounded representative Sunny Cove cohort:

Required levels:
`1, 10, 11, 20, 21, 30, 31, 40, 41, 50, 51, 60, 61, 70, 71, 80, 81, 90, 91, 100`

This deliberately samples milestone peaks and immediate relief levels.

Minimum trials:
- at least 10 deterministic seeded trials per required level if the harness can complete within a bounded runtime;
- if actual physics runtime makes that infeasible, use at least 3 per level and record the measured runtime limitation. Do not silently reduce coverage.

Report per tested level:
- completion rate;
- median completion time;
- p75 completion time;
- p90 completion time;
- timeout/danger/harness-abort counts;
- median and peak occupancy;
- median peak live-drink count;
- median large-piece coexistence peak;
- contact/rail-contact summary;
- planning-cost/timer comparison.

Percentiles must use a documented deterministic method.

## Gate H — no acceptance/tuning from weak evidence

V01 must not alter:
- `data/campaign/levels/sunny_cove.json`;
- any canonical timer;
- any objective;
- VIP content;
- scoring/reward/economy;
- M15 HUD;
- R11 physics.

The baseline report may flag observations, but M17-007/008 remain pending until independent audit confirms the harness is trustworthy enough for outlier/tuning decisions.

## Gate I — focused tests

Add M17 focused probe(s) covering:
- objective cost anchors;
- 7/3 expected spawn value;
- timer calculator transparency/overrideability;
- deterministic same-seed reproducibility;
- different-seed differentiation where expected;
- telemetry schema completeness;
- percentile calculation;
- replay of one exact trial;
- no canonical data mutation.

Required regression PASS:
- M17 focused probe twice;
- M16;
- M15;
- M02 physics regression or the current authoritative R11/R10 physics closure probe;
- `git diff --check`.

## Governance

Codex must:
- sync canonical Desktop before/after;
- not edit root `TASKS.md`;
- not create branches;
- not create Desktop copies/worktrees;
- not start M18;
- not tune canonical levels in V01.

## Deliverables

Preferred bounded locations:
- difficulty model/tool under `scripts/campaign/` or `tools/`;
- test harness under `tests/` or `tools/`;
- report under `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/`;
- builder log `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V01.md`.

Final acceptance requires independent ChatGPT audit.
