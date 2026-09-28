# BCM-M16 Owner Ruling V02 — Sunny Cove VIP Placement / Reward Policy

Status: **OWNER-APPROVED / CANONICAL**

Owner approval date: 2026-09-28

## 1. Retention policy

Sunny Cove uses exactly **25 VIP levels** across its 100-level campaign.

VIP appears at every fourth level:

`4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96, 100`

This cadence is intentional. The Island Map must visibly preview upcoming VIP opportunities with a persistent VIP/crown marker.

VIP is always:
- optional;
- excluded from normal completion requirements;
- excluded from normal timer calculation;
- eligible for later replay completion if missed;
- rewarded at most once through the existing idempotent VIP reward ledger;
- worth the existing M15 **2× delivery score** per accepted VIP cocktail delivery.

## 2. Reward cadence

For VIP indices 1..25:

- every 5th VIP gives **1× Upgrade booster**;
- all other VIPs give **1× +Time booster**.

Therefore Upgrade VIP levels are exactly:

`20, 40, 60, 80, 100`

All other VIP levels grant:

`{"type":"booster","id":"time","quantity":1}`

Upgrade VIP levels grant:

`{"type":"booster","id":"upgrade","quantity":1}`

The existing M15 score multiplier remains independent from the booster reward:
- VIP delivery score = **2× normal To-Go delivery score**;
- VIP completion reward = configured booster above.

## 3. Workload contract

VIP workload is targeted at approximately **25%-40% of that level's normal objective merge cost**.

Merge cost remains:

`cost(Ln) = 2^(n-1)`

VIP cost:

`vip_cost = quantity * 2^(cocktail_level - 1)`

Because Sunny Cove's shared target policy starts at L5 and VIP quantity is restricted to 1 or 2, the workload is discrete rather than continuous.

Two explicitly accepted discrete exceptions exist:

- **Level 4:** 1×L5 = 16 versus normal cost 32 = **50.00%**. This is the smallest legal VIP objective and is accepted as the first-VIP tutorial exception.
- **Level 64:** 2×L5 = 32 versus normal cost 144 = **22.22%**. The lower option is deliberately chosen instead of 1×L7 / 2×L6 = 64 = 44.44%, preserving VIP's optional/non-punitive nature.

All other VIP entries fall within 25%-40%.

## 4. Exact canonical VIP table

| VIP # | Level | Normal cost | VIP target | VIP cost | Workload | Reward |
|---:|---:|---:|---|---:|---:|---|
| 1 | 4 | 32 | 1×L5 | 16 | 50.00% | +Time |
| 2 | 8 | 48 | 1×L5 | 16 | 33.33% | +Time |
| 3 | 12 | 64 | 1×L5 | 16 | 25.00% | +Time |
| 4 | 16 | 64 | 1×L5 | 16 | 25.00% | +Time |
| 5 | 20 | 96 | 2×L5 | 32 | 33.33% | Upgrade |
| 6 | 24 | 96 | 1×L6 | 32 | 33.33% | +Time |
| 7 | 28 | 96 | 2×L5 | 32 | 33.33% | +Time |
| 8 | 32 | 96 | 1×L6 | 32 | 33.33% | +Time |
| 9 | 36 | 112 | 2×L5 | 32 | 28.57% | +Time |
| 10 | 40 | 128 | 1×L6 | 32 | 25.00% | Upgrade |
| 11 | 44 | 112 | 1×L6 | 32 | 28.57% | +Time |
| 12 | 48 | 128 | 2×L5 | 32 | 25.00% | +Time |
| 13 | 52 | 128 | 1×L6 | 32 | 25.00% | +Time |
| 14 | 56 | 160 | 2×L6 | 64 | 40.00% | +Time |
| 15 | 60 | 176 | 1×L7 | 64 | 36.36% | Upgrade |
| 16 | 64 | 144 | 2×L5 | 32 | 22.22% | +Time |
| 17 | 68 | 176 | 1×L7 | 64 | 36.36% | +Time |
| 18 | 72 | 160 | 2×L6 | 64 | 40.00% | +Time |
| 19 | 76 | 192 | 1×L7 | 64 | 33.33% | +Time |
| 20 | 80 | 192 | 2×L6 | 64 | 33.33% | Upgrade |
| 21 | 84 | 176 | 1×L7 | 64 | 36.36% | +Time |
| 22 | 88 | 208 | 2×L6 | 64 | 30.77% | +Time |
| 23 | 92 | 192 | 1×L7 | 64 | 33.33% | +Time |
| 24 | 96 | 224 | 2×L6 | 64 | 28.57% | +Time |
| 25 | 100 | 240 | 1×L7 | 64 | 26.67% | Upgrade |

Quantity mix:
- quantity 1: **15 VIP levels**
- quantity 2: **10 VIP levels**

## 5. Canonical JSON shape

VIP level example using +Time:

```json
"vip": {
  "enabled": true,
  "cocktail_level": 6,
  "quantity": 1,
  "reward": {
    "type": "booster",
    "id": "time",
    "quantity": 1
  }
}
```

Upgrade VIP example:

```json
"vip": {
  "enabled": true,
  "cocktail_level": 7,
  "quantity": 1,
  "reward": {
    "type": "booster",
    "id": "upgrade",
    "quantity": 1
  }
}
```

For VIP levels:
- `feature_flags.vip = true`.

For all other Sunny Cove levels:
- `vip = null`;
- `feature_flags.vip = false`.

## 6. Island Map VIP marker

Every configured VIP level must show a visible VIP/crown marker on the Island Map.

Requirements:
- marker is visible on VIP levels even while locked, so the player can anticipate the upcoming opportunity;
- marker remains visible in OPEN, CURRENT, COMPLETE and LOCKED states;
- do not create a second progression authority;
- derive marker directly from the canonical level definition's VIP configuration;
- reuse an existing approved VIP/crown asset where practical, preferably `assets/ui_assets/screens/prelevel/vip_badge.png`;
- do not generate a new visual asset in this task;
- marker must not replace level number, stars, milestone marker, or lock/current/completed state.

## 7. Replay / persistence contract

If the player wins the normal level but misses VIP:
- normal campaign completion remains valid;
- VIP reward is not granted;
- the player may replay the already-completed level later;
- completing VIP on that replay must upgrade persisted `vip_completed` from false to true;
- the configured VIP booster reward is granted exactly once.

If VIP was already completed:
- replay may still run the level;
- no duplicate VIP booster reward may be granted;
- persisted `vip_completed` must remain true.

Existing CampaignManager monotonic VIP persistence and GameEconomy reward-ledger idempotency remain authoritative.

## 8. Frozen systems

Do not change:
- the 100 approved normal objectives;
- any normal timer;
- normal reward calculation;
- Sunny Cove L5-L8 target policy;
- M15 2× VIP delivery score;
- M15 tall To-Go/VIP HUD;
- WIN/LOSE/star semantics;
- R11 table/physics/collider behavior.

This ruling completes the owner policy required for BCM-M16-009.
