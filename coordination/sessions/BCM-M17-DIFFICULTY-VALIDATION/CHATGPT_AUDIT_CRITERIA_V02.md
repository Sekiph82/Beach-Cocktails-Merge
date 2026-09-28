# BCM-M17 Telemetry Integrity Remediation — Audit Criteria V02

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V01.md`
- V01 analytical model/timer tooling
- current audited M16 canonical Sunny Cove data
- current authoritative gameplay/physics contracts

## Scope

V02 is a narrow remediation of M17 runtime telemetry/report correctness.

Authorized work:
- fix danger vs timeout outcome classification;
- implement/document an honest deterministic rail-contact/proximity proxy;
- extend focused assertions;
- regenerate the exact same 20-level × 3-trial seeded cohort into V02 report files.

Not authorized:
- canonical level tuning;
- objective/timer/VIP changes;
- bot-policy redesign beyond what is strictly required for telemetry correctness;
- M17-007/008 final outlier/impossibility/tuning decisions.

## Gate A — danger vs timeout classification

PASS requires trial outcomes to distinguish:

### danger
Use `outcome = "danger"` when the production session terminates due to table danger / game-over.

At minimum:
- terminal reason `TABLE_DANGER` => danger;
- manager game-over caused by the danger line => danger.

### timeout
Use `outcome = "timeout"` only for actual time-limit exhaustion.

At minimum:
- terminal reason `TIMEOUT` / explicit time-limit exhaustion => timeout.

Do not map every non-WIN terminal to timeout.

The final V02 JSON must have internally consistent:
- trial `outcome`;
- trial `terminal_reason`;
- per-level `timeout_count`;
- per-level `danger_count`.

## Gate B — focused outcome tests

Add deterministic focused coverage that proves both branches:

1. a table-danger fixture yields:
   - `outcome == danger`;
   - `terminal_reason == TABLE_DANGER` or the canonical equivalent.

2. a pure time-limit fixture yields:
   - `outcome == timeout`;
   - not danger.

Tests must fail if TABLE_DANGER is again counted as timeout.

## Gate C — honest rail telemetry

The existing `body_entered` path is not a valid rail-contact source because production drinks and diagnostic rail bodies are on non-interacting collision layers.

V02 must not present zero callbacks as proof of zero rail interaction.

Implement a deterministic bounded proxy using the production playable-boundary geometry.

Required semantics:
- calculate each live drink footprint's minimum signed distance to the authoritative playable boundary edges;
- define a named enter threshold, default **<= 1.0 px**;
- define a release threshold, default **> 3.0 px**, to provide hysteresis;
- count one rail-contact/proximity **event** on transition from "not near rail" to "near rail";
- do not increment every physics frame while the drink remains near the same rail;
- track per drink instance and per edge so distinct edge interactions can be counted;
- clean stale state when drinks disappear/merge.

The metric may remain named `rail_contact_count` only if docs clearly state it is a deterministic **footprint-to-authoritative-rail proximity-event proxy**, not a PhysicsServer collision callback.

Prefer also adding a telemetry field such as:
- `rail_contact_metric = "footprint_proximity_transition_proxy"`

to make the semantics machine-readable.

## Gate D — rail proxy validation

Focused tests must prove:
- a controlled drink placed/projected at a rail creates at least one rail-proximity event;
- a centered drink with no rail approach does not create a false event;
- remaining near the same rail across multiple samples does not repeatedly inflate the count;
- leaving beyond the release threshold and re-entering can create a new event.

## Gate E — telemetry schema/docs

Update:
- telemetry schema documentation;
- harness telemetry validation;
- report interpretation text

so rail-contact semantics and outcome semantics are explicit.

Required telemetry remains:
- outcome;
- terminal_reason;
- contact_count;
- rail_contact_count;
- all prior V01 spatial metrics.

Do not silently change the meaning of unrelated metrics.

## Gate F — regenerate exact V02 cohort

Create new immutable outputs:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_BASELINE_REPORT_V02.json`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_BASELINE_REPORT_V02.md`

Do not overwrite/delete V01 historical evidence.

Use the exact same required level cohort:

`1,10,11,20,21,30,31,40,41,50,51,60,61,70,71,80,81,90,91,100`

Use:
- exactly 3 trials per level;
- same seed base `17000000`;
- same formula `base + level_id * 1000 + trial_index`;
- same baseline bot policy;
- same explicitly documented physics time scale used by V01 unless a correctness defect requires otherwise.

This isolates the telemetry fix from bot-policy drift.

## Gate G — V02 report integrity

For every level:
- `trial_count = 3`;
- timeout + danger + abort + completed = 3;
- counts must equal the underlying trial outcomes;
- TABLE_DANGER trials must contribute to danger_count, never timeout_count;
- rail_contact_count summary must reflect the documented proxy and may not be a hard-coded/structural all-zero artifact.

The Markdown report must include:
- completion rate;
- median/P75/P90 completion times;
- timeout/danger/abort counts;
- occupancy/live-drink/large-piece/contact metrics;
- rail-proxy summary;
- planning cost/timer comparison;
- explicit weak-bot interpretation boundary.

## Gate H — preserve V01 analytical model

Do not change the accepted meaning of:
- `cost(Ln)=2^(n-1)`;
- normal objective cost;
- separate VIP cost;
- expected L1-L3 value `7/3`;
- named/overrideable timer calibration;
- ×2 planning target;
- R7 percentile method.

Any model change requires explicit justification and independent audit.

## Gate I — canonical/product freeze

No changes to:
- `data/campaign/levels/sunny_cove.json`;
- any objective/timer/VIP content;
- M15 HUD;
- economy/rewards/scoring;
- production R11 table/physics/colliders.

Instrumentation must remain test/tooling-side or strictly non-invasive.

## Gate J — tests/regressions

Required PASS:
- M17 V02 focused probe twice;
- M16 regression;
- M15 regression;
- M02 authoritative physics regression;
- `git diff --check`.

The old R10 known failures are not part of V02 acceptance unless V02 modifies those files/contracts.

## Governance

Codex must:
- sync canonical Desktop before/after;
- not edit root `TASKS.md`;
- not create branches;
- not create Desktop clones/worktrees;
- not start M17-007/008 tuning;
- not start M18.

## Builder log

Write:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V02.md`

Final V02 acceptance requires independent ChatGPT audit.
