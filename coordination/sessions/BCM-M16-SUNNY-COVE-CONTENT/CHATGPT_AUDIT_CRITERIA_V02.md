# BCM-M16 Sunny Cove VIP Content — Audit Criteria V02

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/OWNER_RULING_V02.md`
- M16 V01 audited canonical normal-content dataset
- M15 audited VIP runtime/economy contracts
- root `TASKS.md`

## Objective

Implement only BCM-M16-009 using the exact owner-approved 25-level Sunny Cove VIP table and marker/replay policy.

## Gate A — Exact VIP cadence

PASS requires exactly 25 VIP levels, at exactly:

`4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96, 100`

No other Sunny Cove level may contain enabled VIP content.

## Gate B — Exact target/quantity table

For every VIP level, cocktail_level and quantity must exactly match `OWNER_RULING_V02.md`.

Required quantity distribution:
- qty 1 = 15 levels;
- qty 2 = 10 levels.

Automated assertions must validate all 25 rows, not spot-checks only.

## Gate C — Workload policy

For each VIP level:
- calculate `vip_cost = quantity * 2^(cocktail_level-1)`;
- compare against canonical normal objective cost.

All entries must match the exact owner table.

Accepted out-of-band ratios are only:
- L4 = 50.00%;
- L64 = 22.22%.

Every other VIP must remain between 25%-40%.

## Gate D — Reward cadence

VIP indices 5,10,15,20,25, corresponding exactly to levels:
`20, 40, 60, 80, 100`

must grant exactly:
`{"type":"booster","id":"upgrade","quantity":1}`

All other VIP levels must grant exactly:
`{"type":"booster","id":"time","quantity":1}`

No coins or alternate reward types may be introduced.

## Gate E — Feature flags / non-VIP rows

VIP levels:
- `vip.enabled = true`;
- `feature_flags.vip = true`.

Non-VIP Sunny Cove levels:
- `vip = null`;
- `feature_flags.vip = false`.

Total non-VIP levels = 75.

## Gate F — Normal-content immutability

The previously audited M16 V01 normal dataset is frozen.

For all 100 levels:
- `orders` unchanged;
- `time_limit_sec` unchanged;
- normal rewards unchanged;
- score-star thresholds unchanged except only where proven necessary for existing runtime compatibility, and any such change requires explicit audit justification.

Preferred implementation changes only VIP payload + feature flag on the 25 VIP rows.

Any normal objective/timer drift = FAIL.

## Gate G — Island Map marker

Every configured VIP level must expose a visible VIP/crown marker derived directly from level data.

PASS requires:
- visible for LOCKED / OPEN / CURRENT / COMPLETE VIP levels;
- absent on non-VIP levels;
- does not replace level number, stars, milestone marker or level-state semantics;
- derives from canonical VIP config, not a second hard-coded list;
- reuses existing approved asset where practical;
- no generated/new art required.

## Gate H — Replay / persistence

Automated tests must prove:

1. Win normal objectives while VIP incomplete:
   - level completion succeeds;
   - VIP reward not granted;
   - stored vip_completed remains false.

2. Replay that completed level and complete VIP:
   - replay is allowed;
   - VIP completion is persisted monotonically false → true;
   - configured reward grants exactly once.

3. Replay again after VIP already earned:
   - persisted vip_completed remains true;
   - reward ledger prevents duplicate reward.

## Gate I — Existing M15 scoring semantics

For accepted VIP deliveries:
- existing delivery payout remains exactly 2× normal To-Go payout;
- optional VIP does not block normal win;
- VIP cost does not alter normal timer;
- same-level normal-first precedence remains unchanged.

## Gate J — Tests

Extend/add focused M16 VIP assertions validating all 25 VIP rows.

Required PASS:
- M16 focused probe twice;
- M15;
- M14;
- M13;
- M11;
- M10;
- `git diff --check`.

## Governance

Codex must:
- sync canonical Desktop before and after;
- not edit root `TASKS.md`;
- not create GitHub branches;
- not create Desktop copies/worktrees;
- not start M17;
- not change M15 HUD visuals;
- not alter R11 physics/table/colliders.

## Builder log

Write:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CODEX_LOG_V02.md`

Final M16 closure requires independent ChatGPT audit.
