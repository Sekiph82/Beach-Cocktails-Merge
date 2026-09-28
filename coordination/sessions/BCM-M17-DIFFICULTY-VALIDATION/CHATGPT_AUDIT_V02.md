# BCM-M17 Telemetry Integrity Remediation — Independent Audit V02

Verdict: **AUDITED_PASS**

Auditor: ChatGPT  
Builder: CODEX  
Branch: `main`  
V02 implementation/evidence SHA: `8a0422c397f30894ab85f8f9f40f6dcb819ef3b5`  
Final audited HEAD: `d83aee906a10c8999007bc31982c0c3e40435171`

## 1. Summary

The V02 telemetry remediation passes independent audit.

The two V01 defects are corrected:

1. production TABLE_DANGER outcomes are now recorded as `danger`, not `timeout`;
2. rail telemetry now uses a documented deterministic footprint-to-authoritative-boundary proximity transition proxy with hysteresis rather than structurally false-zero body-collision callbacks.

The V02 20-level × 3-trial cohort is internally consistent and suitable as a corrected telemetry baseline.

However, the baseline bot completed **0/60 trials**. Therefore this report is valid telemetry evidence but is **not yet strong enough to support M17-007 effective-impossibility judgments or M17-008 tuning decisions**. A stronger decision-grade validation policy must be qualified before canonical level tuning.

## 2. Outcome-classification verification

Independent inspection of:
- production harness source;
- focused fixtures;
- final V02 JSON;
- per-level summary counts

confirms:

- total trials: **60**
- `danger`: **54**
- `timeout`: **6**
- `completed`: **0**
- `harness_abort`: **0**
- TABLE_DANGER trials misclassified: **0**
- TIMEOUT trials misclassified: **0**
- per-level outcome summary mismatches: **0**

All `TABLE_DANGER` underlying trials contribute to `danger_count`, never `timeout_count`.

The focused probe also uses the real production danger-line/GameManager path and the campaign timer path.

## 3. Rail-proximity telemetry verification

PASS.

Production harness constants:
- enter threshold: **<= 1.0 px**
- release threshold: **> 3.0 px**
- metric ID: `footprint_proximity_transition_proxy`

Implementation:
- computes minimum signed distance from each live drink footprint to each authoritative playable-boundary edge;
- state key = drink instance ID + edge name;
- false→near transition increments once;
- continued proximity does not inflate count;
- >3 px releases near state;
- later <=1 px re-entry creates a new event;
- stale drink/edge keys are removed after each sample.

The focused probe verifies:
- one controlled near-rail event;
- no repeated inflation while continuously near;
- centered control creates no false event;
- release then re-entry creates another event.

## 4. V02 report integrity

Independent parsing of `M17_BASELINE_REPORT_V02.json` confirms:

- report version: V02
- exactly 20 required level IDs in exact order:
  `1,10,11,20,21,30,31,40,41,50,51,60,61,70,71,80,81,90,91,100`
- exactly 3 trials per level
- exactly 60 total trials
- seed base: `17000000`
- seed formula preserved
- physics time scale: 4.0
- no summary/count mismatch
- 9 underlying trials have nonzero rail-proxy events
- median rail-proxy events are nonzero at L50, L70, and L100
- V01 report remains historical and was not overwritten.

The Markdown report correctly distinguishes:
- planning metrics;
- runtime telemetry;
- body-contact callbacks;
- rail-proximity proxy;
- weak-bot limitations.

## 5. Canonical/product freeze

PASS.

Compared V02 start HEAD to final audited HEAD.

V02 product/tooling changes are limited to:
- M17 seeded harness;
- M17 focused probe;
- M17 report generator;
- V02 schema/report/log evidence.

`data/campaign/levels/sunny_cove.json` is byte-for-byte unchanged from V02 start.

No changes were made to:
- canonical objectives;
- timers;
- VIP content;
- M15 HUD;
- scoring/economy;
- production R11 table/physics/colliders.

## 6. Accepted V01 analytical model remains intact

PASS.

No V02 change altered:
- `cost(Ln)=2^(n-1)`;
- normal objective cost;
- separate VIP cost;
- expected spawn value `7/3`;
- overrideable timer calibration;
- ×2 planning target;
- R7 percentile method;
- seed/action-log replay contract;
- baseline lane policy.

## 7. Tests

Builder reports PASS:
- M17 focused probe ×2;
- M16;
- M15;
- M02;
- `git diff --check`.

ChatGPT did not execute Godot locally, but independently verified:
- live final GitHub HEAD;
- exact implementation diff;
- focused test source;
- raw V02 JSON and Markdown reports;
- telemetry counts/consistency;
- canonical-data immutability.

No repository evidence contradicts the reported test results.

The known historical R10 failures remain unrelated to this tooling-only remediation and no R10 contract/source was modified.

## 8. Gate matrix

| Gate | Result |
| --- | --- |
| A danger vs timeout | PASS |
| B focused outcome tests | PASS |
| C honest rail telemetry | PASS |
| D rail proxy validation | PASS |
| E schema/docs | PASS |
| F exact V02 cohort | PASS |
| G report integrity | PASS |
| H preserve analytical model | PASS |
| I canonical/product freeze | PASS |
| J tests/governance | PASS |

## 9. M17 task closure

**BCM-M17-004: AUDITED_PASS**  
**BCM-M17-005: AUDITED_PASS**  
**BCM-M17-006: AUDITED_PASS**

Together with V01:
- BCM-M17-001: complete
- BCM-M17-002: complete
- BCM-M17-003: complete

Still open:
- BCM-M17-007
- BCM-M17-008

## 10. Decision boundary for M17-007/008

The corrected baseline is now trustworthy about what this specific weak deterministic bot experienced.

It is not decision-grade evidence of player feasibility because:
- completion rate is 0/60;
- the bot is explicitly non-optimal;
- the cohort ran at physics time scale 4.0;
- a bot that cannot complete even the simplest sampled level cannot distinguish a difficult level from a weak policy.

Therefore the next M17 pass must qualify a stronger deterministic merge-aware policy at canonical physics time scale before:
- declaring levels effectively impossible/outliers;
- tuning canonical objectives or timers.

No canonical tuning is authorized by this V02 audit.

**M17 V02: AUDITED_PASS.**
