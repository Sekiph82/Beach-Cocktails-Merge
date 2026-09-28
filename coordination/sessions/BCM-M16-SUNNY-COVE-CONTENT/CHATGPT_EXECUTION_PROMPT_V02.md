# BCM-M16 Sunny Cove VIP Content — Execution Prompt V02

Execute against:

- `coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/OWNER_RULING_V02.md`
- `coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_CRITERIA_V02.md`
- M16 V01 audited Sunny Cove dataset
- current `main`

Before implementation:
- obey `AGENTS.md`;
- synchronize `C:\Users\sekip\Desktop\Beach Cocktails - Merge`;
- confirm root `TASKS.md` authorizes Codex.

## Goal

Implement BCM-M16-009 exactly as owner-approved:
- 25 VIP levels;
- every 4th level;
- visible Island Map VIP/crown marker;
- exact workload table;
- qty 1/2 mix;
- 2× VIP delivery score preserved;
- every 5th VIP grants Upgrade, all others +Time;
- VIP optional;
- missed VIP can be completed later by replay;
- no duplicate reward.

## 1. Exact VIP levels

Enable VIP on exactly:

`4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96, 100`

No other Sunny Cove level may have enabled VIP content.

## 2. Exact target / quantity / reward table

Apply exactly:

| Level | VIP target | Reward |
|---:|---|---|
| 4 | 1×L5 | +Time |
| 8 | 1×L5 | +Time |
| 12 | 1×L5 | +Time |
| 16 | 1×L5 | +Time |
| 20 | 2×L5 | Upgrade |
| 24 | 1×L6 | +Time |
| 28 | 2×L5 | +Time |
| 32 | 1×L6 | +Time |
| 36 | 2×L5 | +Time |
| 40 | 1×L6 | Upgrade |
| 44 | 1×L6 | +Time |
| 48 | 2×L5 | +Time |
| 52 | 1×L6 | +Time |
| 56 | 2×L6 | +Time |
| 60 | 1×L7 | Upgrade |
| 64 | 2×L5 | +Time |
| 68 | 1×L7 | +Time |
| 72 | 2×L6 | +Time |
| 76 | 1×L7 | +Time |
| 80 | 2×L6 | Upgrade |
| 84 | 1×L7 | +Time |
| 88 | 2×L6 | +Time |
| 92 | 1×L7 | +Time |
| 96 | 2×L6 | +Time |
| 100 | 1×L7 | Upgrade |

Reward JSON:

+Time:
```json
{"type":"booster","id":"time","quantity":1}
```

Upgrade:
```json
{"type":"booster","id":"upgrade","quantity":1}
```

VIP object must use:
- `enabled: true`
- exact `cocktail_level`
- exact `quantity`
- exact `reward`

VIP level:
- `feature_flags.vip = true`

Non-VIP level:
- `vip = null`
- `feature_flags.vip = false`

## 3. Do not change normal campaign content

All 100 previously audited:
- `orders`;
- `time_limit_sec`;
- normal rewards;
- Level 1/100 anchors;
- L5-L8 normal target policy

are frozen.

Generate a before/after canonical signature proving zero normal-content drift.

## 4. Workload verification

Use:
`cost(Ln) = 2^(n-1)`

and:
`vip_cost = quantity * 2^(cocktail_level - 1)`

Validate every VIP row against the owner table.

Only accepted ratio exceptions:
- Level 4 = 50.00%;
- Level 64 = 22.22%.

Every other VIP row must be 25%-40% inclusive.

## 5. Island Map VIP/crown marker

Update the reusable Island Map / LevelButton system so VIP levels visibly advertise the opportunity.

Requirements:
- marker comes from the level definition's VIP config;
- no hard-coded second list in the UI;
- visible for locked, open, current and completed VIP levels;
- absent on non-VIP levels;
- must not hide level number, stars, milestone marker or state;
- reuse an existing approved asset, preferably:
  `res://assets/ui_assets/screens/prelevel/vip_badge.png`
- do not generate new art.

Extend LevelButton API minimally to receive/display VIP status.

## 6. Replay behavior

Prove this exact flow:

A. First play:
- complete normal objective;
- do not complete VIP;
- WIN succeeds;
- no VIP reward granted;
- persisted `vip_completed = false`.

B. Replay:
- same completed level remains selectable/replayable;
- complete VIP and normal objective;
- persisted `vip_completed` becomes true;
- configured VIP booster reward grants once.

C. Replay again:
- no duplicate VIP booster grant;
- `vip_completed` remains true.

Do not weaken existing reward-ledger idempotency.

## 7. Existing M15 gameplay contract is frozen

Do not alter:
- VIP 2× delivery score;
- normal-first same-level precedence;
- VIP optionality;
- normal timer;
- tall To-Go/VIP HUD;
- economy persistence;
- stars/WIN/LOSE semantics.

## 8. Focused test coverage

Extend `tests/m16_sunny_cove_content_probe.gd` or add a bounded companion probe.

Must verify:
- exact 25 VIP levels;
- all 25 target/quantity rows;
- 15 qty1 / 10 qty2;
- exact reward cadence;
- 20/40/60/80/100 Upgrade only;
- all other VIP levels +Time;
- 75 non-VIP levels;
- workload ratios and two accepted exceptions;
- no normal-content drift;
- marker data plumbing;
- replay-later VIP completion;
- reward once only.

## 9. Regressions

Run:
- M16 focused probe twice;
- M15;
- M14;
- M13;
- M11;
- M10;
- `git diff --check`.

If a visual Island Map probe already exists, run it too.

## Hard boundaries

Do not:
- edit root `TASKS.md`;
- modify M15 HUD art/layout;
- modify normal Sunny Cove objectives/timers;
- retune physics/table/colliders;
- start M17;
- create a GitHub branch;
- create Desktop clones/worktrees.

## Completion

Write:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CODEX_LOG_V02.md`

Include:
- exact 25-level VIP table verification;
- qty distribution;
- reward cadence;
- workload ratio proof;
- normal-data immutability proof;
- marker implementation/evidence;
- replay-later reward proof;
- regression results;
- final sync proof.

Push to `main`, sync canonical Desktop, then return:

- implementation SHA;
- final main/canonical SHA;
- exact VIP cadence PASS/FAIL;
- exact VIP table PASS/FAIL;
- qty mix PASS/FAIL;
- reward cadence PASS/FAIL;
- crown marker PASS/FAIL;
- replay-later VIP PASS/FAIL;
- reward idempotency PASS/FAIL;
- normal-content immutability PASS/FAIL;
- regressions;
- log URL;
- `AWAITING_M16_AUDIT_V02`.

Then STOP. Do not start M17.
