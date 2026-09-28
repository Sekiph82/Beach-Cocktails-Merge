# BCM-M17 Difficulty Model + Validation Harness — Independent Audit V01

Verdict: **CHANGES_REQUIRED**

Auditor: ChatGPT  
Builder: CODEX  
Branch: `main`  
Implementation SHA: `21386b2bbf3a364c8860f5cb7b4e26bce03bc83f`  
Final audited HEAD: `2969d966d021d64a10fdcfc85a799fb9a9505b15`

## 1. Summary

M17 V01 succeeds on the analytical model, timer tooling, deterministic seed/action-log mechanics, telemetry schema shape, report generation, and canonical-data immutability.

However, two telemetry-integrity defects make the runtime baseline report unreliable for M17-006 and therefore unsuitable as the evidence base for M17-007/008:

1. danger/game-over sessions are classified as `timeout`;
2. rail-contact telemetry is reported as zero even though the production collision model cannot generate the callback being counted and the implemented proximity proxy is never persisted.

Therefore:
- M17-001: technically PASS;
- M17-002: technically PASS;
- M17-003: technically PASS;
- M17-004: **CHANGES_REQUIRED** for rail-contact telemetry integrity;
- M17-005: technically PASS with remediation required in outcome classification;
- M17-006: **CHANGES_REQUIRED** because the published cohort summary contains incorrect timeout/danger and rail-contact statistics.

M17-007/008 remain blocked.

## 2. Gate A — objective-cost model

PASS.

Independent source inspection confirms one reusable model implements:

`cost(Ln) = 2^(n-1)`

and normal objective cost as the sum of quantity × cocktail cost.

Verified anchors:
- Level 1 normal cost = 16;
- Level 100 normal cost = 240;
- VIP cost is exposed separately.

No second divergent production formula was introduced.

## 3. Gate B — expected L1-L3 spawn-production model

PASS.

The model explicitly exposes:
- L1/L2/L3 values = 1/2/4;
- uniform spawn assumption tied to runtime `randi_range(1,3)`;
- expected L1-equivalent value = `7/3`;
- expected spawn count = objective_cost / (7/3).

The source correctly labels this as a planning expectation rather than a physical guarantee.

## 4. Gate C — timer tooling

PASS.

The tool exposes:
- objective cost;
- expected spawn value/count;
- named `DEFAULT_SECONDS_PER_LAUNCH = 1.5`;
- overrideable calibration;
- raw production time;
- ×2 planning target;
- canonical timer;
- delta;
- VIP cost separately.

No canonical timer was modified.

## 5. Gate D — theoretical vs spatial difficulty

PASS.

Source/docs explicitly separate analytical production cost from physical/spatial difficulty and warn that separated equal-level cocktails do not merge for free.

## 6. Gate E — telemetry integrity

**CHANGES_REQUIRED.**

### E1. Danger misclassified as timeout

Current order in `run_trial()`:

1. `if bridge.is_terminal()`
2. classify WIN as completed, every other terminal as timeout
3. only `elif manager.game_over` classify danger

But production GameManager resolves table danger into the campaign bridge as terminal LOSE before this classification runs.

Result: trials with:

`terminal_reason = TABLE_DANGER`

are stored as:

`outcome = timeout`

Independent inspection of the committed JSON confirms this repeatedly. Example cohort rows contain TABLE_DANGER reasons while:
- `timeout_count = 3`;
- `danger_count = 0`.

This violates the required outcome semantics and makes timeout-cause statistics incorrect.

Required fix:
- classify `TABLE_DANGER` / game-over terminal losses as `danger`;
- reserve `timeout` for actual time-limit terminal conditions;
- add focused assertions covering both cases.

### E2. Rail-contact metric is false-zero

Production wall bodies are diagnostics/reference geometry on collision layer 2 / mask 2 while drinks are layer 1 / mask 1. Therefore the harness's `Drink.body_entered` callback is not a valid source of rail contacts.

The harness already computes a read-only rail-proximity proxy in `_sample()`, but when proximity is detected it only `break`s. It never increments or records a proxy metric.

Consequently:
- every reported `rail_contact_count` is zero;
- zero currently means "not measured", not "no rail interaction".

This fails the telemetry contract, which allowed an unavailable metric only when explicitly justified and replaced by a bounded proxy.

Required fix:
- implement a deterministic rail-proximity/contact-event proxy;
- count transitions/events rather than every frame if appropriate;
- document exact semantics;
- expose it honestly in telemetry/report naming or define `rail_contact_count` as the documented proxy;
- ensure the report no longer presents false zeros as measured physical contacts.

## 7. Gate F — seeded/replayable harness

PASS with bounded remediation.

Strengths independently verified:
- canonical data load;
- island/level/seed inputs;
- deterministic `RandomNumberGenerator`;
- recorded spawn/lane/x action log;
- same-seed action-log reproduction;
- explicit action-log replay;
- production GameManager / Drink / MergeQueue physics hook;
- no completion API shortcut;
- no save/canonical data mutation.

The danger-classification fix must be applied inside this harness before it can be considered final.

## 8. Gate G — baseline report

**CHANGES_REQUIRED.**

Structural requirements are present:
- exactly 20 required levels;
- 3 trials each;
- 60 total;
- deterministic seed schedule;
- completion rate / percentiles / occupancy / live-drink / contacts / planning comparison fields;
- runtime limitation for reducing from 10 to 3 trials is documented.

However, the report currently has semantically incorrect outcome counts and false-zero rail metrics.

Independent JSON inspection found many trials with:
- `terminal_reason = TABLE_DANGER`
- `outcome = timeout`

while per-level summaries show `danger_count = 0`.

The baseline must be regenerated after telemetry fixes. Existing V01 report must not be used for M17-007/008.

The fact that the deterministic baseline bot completed 0/60 trials is not itself a failure because the prompt explicitly forbids treating a weak bot as a final gameplay judgment. It does, however, reinforce that M17-007/008 must remain blocked.

## 9. Gate H — no canonical tuning

PASS.

Compare from V01 start HEAD to final HEAD shows no canonical Sunny Cove level-data modification and no M15 HUD / reward / physics retuning.

M17-007/008 were not executed.

## 10. Gate I — tests / R10 note

Builder reports:
- M17 focused probe ×2 PASS;
- M16 PASS;
- M15 PASS;
- M02 PASS;
- `git diff --check` PASS.

The noted R10 failures are not introduced by V01 product changes. V01 did not modify R10 probe/source geometry. M02 remains the passing authoritative physics regression used for this tooling-only diff.

However, current focused tests do not catch:
- TABLE_DANGER outcome misclassification;
- false-zero rail telemetry.

V02 must add tests for both.

## 11. Verdict matrix

| Gate | Result |
| --- | --- |
| A cost model | PASS |
| B spawn-production model | PASS |
| C timer tooling | PASS |
| D theory vs spatial separation | PASS |
| E telemetry | **CHANGES_REQUIRED** |
| F seeded/replay harness | PASS with remediation |
| G baseline report | **CHANGES_REQUIRED** |
| H no tuning/canonical freeze | PASS |
| I tests/governance | PASS but insufficient assertions |

## 12. Required remediation

V02 must be narrowly limited to telemetry/report correctness:

- correctly classify danger vs timeout;
- implement/document a real rail-proximity/contact proxy;
- add focused assertions;
- regenerate the exact same 20-level × 3-trial baseline cohort using the same deterministic seed schedule;
- prove canonical data remains frozen;
- do not tune any level.

**M17-004 / M17-006 remain open.**
**M17-007 / M17-008 remain blocked.**
