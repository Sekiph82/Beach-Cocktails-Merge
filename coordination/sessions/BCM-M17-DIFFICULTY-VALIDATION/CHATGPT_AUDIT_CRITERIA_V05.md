# BCM-M17 VIP Optionality Structural Remediation — Audit Criteria V05

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V04.md`
- M16 owner ruling: VIP is optional, excluded from normal completion requirement and normal timer
- audited M15 VIP delivery/reward semantics
- current production GameManager normal-first / VIP-second routing

## Purpose

V04 proved that all 25 configured Sunny Cove VIP levels currently have unavoidable VIP interception risk: mandatory production necessarily creates the VIP-level intermediate and production immediately auto-captures it.

That behavior makes the VIP workload mechanically forced even though VIP is logically optional.

M17-008 must not hide this structural issue by adding timer padding.

V05 must restore **true VIP optionality** while preserving all canonical level data and the owner-approved VIP content.

## Gate A — canonical data and owner policy remain frozen

No changes to:
- Sunny Cove normal orders;
- timers;
- VIP cadence;
- VIP cocktail levels;
- VIP quantities;
- VIP +Time/Upgrade rewards;
- 2× VIP delivery score;
- M15 HUD asset/layout;
- WIN/LOSE/stars/progression.

The 25 VIP levels remain exactly the M16 owner-approved table.

## Gate B — exact definition of a surplus VIP candidate

A matching VIP cocktail may be auto-captured only when it is **surplus to all remaining mandatory normal objectives**.

Normative definition:

> A VIP candidate is surplus only if removing that candidate from current board inventory does **not increase** the minimum additional production cost required to satisfy every remaining mandatory normal objective under the legal equal-level merge rules.

The calculation must use:
- the bridge's authoritative `normal_remaining` state;
- current eligible board inventory;
- legal cocktail levels/merge rules.

It must account for cocktail non-splittability:
- a higher-level cocktail cannot be treated as freely divisible into lower-level cocktails;
- a simple total L1-equivalent sum is not sufficient by itself.

The planner/decision must be deterministic.

## Gate C — protected mandatory reserve

If a matching VIP candidate contributes to the minimum mandatory reserve:

- do not capture it as VIP;
- leave it in normal gameplay;
- allow it to merge toward or satisfy mandatory objectives.

This protection applies to both production paths:

1. direct merged-cocktail routing in `GameManager.on_merged()`;
2. stocked-cocktail VIP capture in `_try_collect_stocked_target()`.

No alternate path may bypass the reserve guard.

## Gate D — same-level normal-first remains authoritative

When current mandatory normal target and VIP target are the same level:

- normal delivery keeps first claim;
- VIP may not steal the mandatory normal delivery;
- existing M15 normal-first semantics remain unchanged.

## Gate E — optional VIP remains achievable through surplus production

The fix must not disable VIP.

When the player creates material beyond the remaining mandatory reserve:

- a matching surplus VIP candidate may still be auto-captured;
- VIP progress advances normally;
- 2× VIP delivery score remains;
- configured terminal booster reward remains once-only.

No new button, tap mode, toggle, or visual UI interaction is introduced in V05.

## Gate F — required pure reserve-planner fixtures

Focused deterministic tests must cover at minimum:

### F1 — L4 protected path
Remaining normal:
- 1×L6
VIP:
- 1×L5

Board/material cases:
- 1×L5 candidate => NOT surplus;
- 2×L5 including candidate => NOT surplus;
- 3×L5 including candidate => candidate surplus.

The first two L5-equivalent pieces must remain available to build the mandatory L6.

### F2 — non-splittability fixture

Construct a state where:
- a higher cocktail has enough total L1-equivalent value numerically;
- but cannot satisfy a lower remaining mandatory target because cocktails cannot split.

The planner must not treat that higher cocktail as valid lower-level reserve.

### F3 — L60
Use the real remaining normal/VIP definition and prove:
- mandatory production reserve is protected;
- an additional surplus L7 can be identified as VIP-eligible.

### F4 — L100
Use the real remaining normal/VIP definition and prove:
- mandatory L7/L8 production reserve is protected;
- an additional surplus L7 can be identified as VIP-eligible.

## Gate G — production integration: VIP can genuinely be missed

Use real GameManager + GameplaySessionBridge fixtures.

At minimum L4 must prove:

1. mandatory path is completed without intentionally producing surplus VIP material;
2. VIP delivered remains 0 / VIP completed remains false;
3. normal WIN succeeds;
4. no VIP completion reward is granted.

This is a critical acceptance gate.

A normal win where VIP is mechanically auto-completed fails V05.

## Gate H — production integration: VIP can deliberately be completed

At minimum L4 must also prove:

1. create/retain enough mandatory reserve;
2. create one additional surplus L5;
3. surplus L5 is captured as VIP;
4. protected reserve still completes normal L6;
5. normal WIN succeeds;
6. VIP completed = true;
7. reward is granted once.

## Gate I — replay-later contract remains real

Prove the full campaign flow:

First play:
- normal WIN;
- VIP missed;
- persisted `vip_completed = false`;
- no VIP booster reward.

Replay:
- create valid surplus VIP delivery;
- complete normal WIN;
- persisted `vip_completed` becomes true;
- configured reward grants once.

Second replay:
- no duplicate VIP booster reward;
- `vip_completed` remains true.

This must use the remediated production capture rule, not direct `set_vip_completed()`.

## Gate J — all 25 VIP levels structural analysis

Create immutable evidence:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_VIP_OPTIONALITY_V05.json`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_VIP_OPTIONALITY_V05.md`

For all 25 VIP levels record:
- normal objectives;
- VIP target/quantity;
- V04 historical forced-interception count/cost;
- post-V05 mandatory-reserve forced-capture count;
- whether VIP is still achievable with surplus production.

Required result:
- historical V04 risk: 25/25;
- post-V05 **forced** VIP captures on minimal mandatory production path: 0/25;
- surplus VIP eligibility remains possible: 25/25.

Do not overwrite V04 historical evidence.

## Gate K — V04 physical screening is historical after mechanics change

V05 must explicitly mark:

`M17_CANONICAL_SCREENING_V04`

as **PRE_OPTIONALITY_FIX / HISTORICAL FOR PHYSICAL CLASSIFICATION**.

Do not delete or rewrite it.

Because gameplay routing changes, M17-008 canonical tuning remains blocked until a fresh post-fix physical screening is independently audited.

## Gate L — regression tests

Required PASS:
- new V05 focused optionality probe;
- M17 focused probe ×2;
- M16 Sunny Cove content;
- M15 VIP/boosters/economy;
- M14 gameplay bridge;
- M02 physics;
- `git diff --check`.

The M15/M16 contracts must be strengthened where necessary so a future regression cannot make VIP mechanically mandatory again.

## Gate M — scope / governance

V05 may modify only the minimum production/runtime logic and test/tool evidence needed to enforce existing owner-approved optionality.

Do not:
- change canonical campaign data;
- extend timers;
- change objectives;
- change VIP targets/quantities/rewards;
- change M15 HUD visuals;
- retune table/physics/colliders;
- perform M17-008 data tuning;
- start M18;
- edit root `TASKS.md`;
- create branches;
- create Desktop clones/worktrees.

## Builder log

Write:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V05.md`

Final acceptance requires independent ChatGPT audit.
