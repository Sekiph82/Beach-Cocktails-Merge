# BCM-M17 Telemetry Integrity Remediation — Execution Prompt V02

Execute only this bounded remediation against:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V02.md`
- current `main`

Before implementation:
- obey `AGENTS.md`;
- synchronize `C:\Users\sekip\Desktop\Beach Cocktails - Merge`;
- confirm clean `main`.

## Goal

Fix the two telemetry defects found by independent audit:

1. TABLE_DANGER sessions are currently counted as `timeout`;
2. `rail_contact_count` is structurally false-zero because diagnostic rail bodies do not collide with drinks and the existing proximity calculation is never persisted.

Do not change canonical level data or tune difficulty.

## 1. Correct trial outcome classification

Refactor final outcome resolution in:

`scripts/campaign/m17_seeded_validation_harness.gd`

Required precedence:

- WIN terminal => `completed`
- table-danger/game-over terminal => `danger`
- actual time-limit exhaustion => `timeout`
- otherwise bounded harness failure => `harness_abort`

Do not classify every non-WIN terminal as timeout.

At minimum, `terminal_reason == "TABLE_DANGER"` must produce:
- `outcome = "danger"`

A real time-limit terminal must produce:
- `outcome = "timeout"`

Keep `terminal_reason` intact.

## 2. Add explicit danger/timeout focused fixtures

Extend M17 focused tests so they independently trigger and assert:

### Danger fixture
- production danger-line/game-over path;
- final trial outcome `danger`;
- reason TABLE_DANGER/canonical equivalent.

### Timeout fixture
- no danger-line failure;
- timer expires;
- final trial outcome `timeout`.

Tests must catch a future regression where danger gets counted as timeout.

If a dedicated bounded harness test hook is needed, keep it deterministic and test-only.

## 3. Implement rail proximity-event proxy

Do not rely on `body_entered` for rail contact.

Use authoritative playable-boundary edges from GameManager.

For every live non-held drink and each boundary edge:

- calculate minimum signed footprint distance;
- ENTER threshold: `<= 1.0 px`;
- RELEASE threshold: `> 3.0 px`.

Maintain state keyed by:
- drink instance ID;
- edge name.

Behavior:
- state false -> distance <= 1.0: increment `rail_contact_count` once and mark near;
- while still near: do not increment again;
- distance > 3.0: clear near state;
- later re-entry: increment a new event;
- delete stale keys when drink/edge no longer exists.

This count is a deterministic **rail proximity transition proxy**, not a collision callback count.

Add machine-readable metadata to telemetry, preferably:

`"rail_contact_metric": "footprint_proximity_transition_proxy"`

If you use a different exact key/value, document it and make tests assert it.

## 4. Rail proxy focused fixtures

Add deterministic tests proving:

- controlled near-rail footprint => count increases;
- centered drink => no false rail event;
- multiple samples while continuously near same edge => no repeated inflation;
- leave beyond 3px and re-enter <=1px => second event.

Do not modify production collision layers just to make tests green.

## 5. Documentation

Update:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_TELEMETRY_SCHEMA_V01.md`

or create a V02 schema document if cleaner.

It must explicitly state:
- `contact_count` = drink/body collision callbacks;
- `rail_contact_count` = authoritative-footprint rail-proximity transition proxy;
- enter/release thresholds;
- danger vs timeout semantics;
- V01 report contains known misclassification and must not be used for tuning.

## 6. Generate new V02 reports

Do not overwrite V01 reports.

Generate:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_BASELINE_REPORT_V02.json`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_BASELINE_REPORT_V02.md`

Use exactly:

Levels:
`1,10,11,20,21,30,31,40,41,50,51,60,61,70,71,80,81,90,91,100`

Trials:
- exactly 3 per level

Seeds:
- base = `17000000`
- formula = `base + level_id * 1000 + trial_index`

Keep:
- same baseline bot policy;
- same V01 physics time scale;
- same analytical model/calibration.

Only telemetry correctness should change.

## 7. V02 report validation

Programmatically verify:

For each level:

`completed_count + timeout_count + danger_count + harness_abort_count == 3`

And from underlying trials:
- every TABLE_DANGER trial has outcome danger;
- no TABLE_DANGER trial contributes to timeout_count;
- summary counts exactly match trial outcomes.

Across the report:
- all 20 required level IDs present exactly once;
- 60 total trials;
- rail-proxy values are derived from actual proximity transitions, not initialized constants.

Do not require rail count > 0 for every single level, but prove the metric is functional via focused fixtures and report nonzero events where the baseline actually reaches rails.

## 8. Preserve accepted V01 model/harness behavior

Do not redesign:
- cost model;
- 7/3 expectation;
- timer calibration;
- percentile algorithm;
- seed schedule;
- baseline bot lane policy;
- replay action-log contract.

Changes outside telemetry correctness require explicit justification.

## 9. Frozen boundaries

Do not modify:
- `data/campaign/levels/sunny_cove.json`;
- objectives/timers/VIP;
- rewards/scoring/economy;
- M15 HUD;
- production R11 table/physics/colliders.

Do not implement M17-007/008 tuning.

## 10. Tests

Run:
- M17 V02 focused probe twice;
- M16;
- M15;
- M02;
- `git diff --check`.

Known historical R10 probe failures may be logged but are not a V02 blocker unless V02 changes those contracts.

## Completion

Write:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V02.md`

Include:
- exact outcome-classification fix;
- rail-proxy algorithm;
- focused fixture results;
- V02 report paths;
- 20×3 / 60-trial proof;
- outcome consistency proof;
- report rail-proxy summary;
- canonical-data frozen proof;
- regression results;
- final sync proof.

Push to `main`, sync canonical Desktop, then return:

- implementation SHA;
- final main/canonical SHA;
- danger classification PASS/FAIL;
- timeout classification PASS/FAIL;
- rail proxy PASS/FAIL;
- telemetry docs PASS/FAIL;
- V02 60-trial report PASS/FAIL;
- canonical data frozen PASS/FAIL;
- regressions;
- report links;
- log URL;
- `AWAITING_M17_AUDIT_V02`.

Then STOP. Do not start M17-007/008 or M18.
