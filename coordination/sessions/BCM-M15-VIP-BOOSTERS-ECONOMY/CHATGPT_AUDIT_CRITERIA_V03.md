# BCM-M15 VIP, Boosters, Rewards & Economy — Audit Criteria V03

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `OWNER_RULING_V03.md`
- M15 V02 technical implementation/audit
- accepted M14 and R11 gameplay contracts

## Objective

Implement the owner's new VIP payout rule without disturbing the V02 real-delivery solution or accepted gameplay.

## Gate A — VIP data range validation

LevelDatabase must deterministically validate enabled VIP data.

PASS requires:
- `vip.cocktail_level` integer in L1-L12 inclusive;
- L1 accepted;
- L12 accepted;
- L0 rejected;
- L13 rejected;
- positive integer `vip.quantity` required;
- zero/negative/fractional quantity rejected;
- null/disabled VIP remains valid as appropriate.

This VIP range is independent of M16's normal-target minimum-L5 rule.

## Gate B — 2x VIP delivery payout

For every successfully accepted and physically consumed VIP cocktail unit:
`vip_bonus = 2 * Drink.order_reward(vip_level)`.

PASS requires:
- bonus added exactly once to gameplay score for each accepted VIP unit;
- merge/combo score remains unchanged and is not duplicated;
- quantity-2 VIP pays two separate 2x unit bonuses, one per actual delivery;
- stored VIP drink delivery pays the same 2x unit bonus;
- rejected/mismatched/paused/nonpositive delivery pays zero;
- extra VIP drink after objective completion pays zero and remains unconsumed under current V02 idempotent behavior;
- normal To-Go delivery still pays its existing 1x `Drink.order_reward(level)`.

## Gate C — score authority / stars

After VIP bonus is added, GameplaySessionBridge's current score must receive the updated total.

Terminal result score and data-driven star mastery must therefore see the real score including accepted VIP delivery bonuses.

No star-rule rewrite is permitted.

## Gate D — economy reward remains separate

The existing configured VIP economy reward (booster/coin reward payload) remains a separate one-time terminal reward.

PASS requires:
- delivery-time 2x score bonus does not mark economy reward ledger;
- economy VIP reward still grants only on normal WIN + VIP complete;
- LOSE or incomplete VIP does not grant economy VIP reward;
- replay/reload does not duplicate economy reward.

## Gate E — same-level precedence

If normal and VIP target the same L-level:
- mandatory normal objective gets first claim while pending;
- its delivery receives normal 1x To-Go reward only;
- it must not simultaneously count/pay as VIP;
- after the mandatory normal quantity for that level is satisfied, subsequent qualifying drinks may satisfy VIP and receive the VIP 2x payout.

## Gate F — UI evidence

Keep V02 compact VIP badge geometry.

The UI should make the VIP premium understandable with a bounded indication such as `2X` or the exact VIP reward amount, without moving accepted HUD/table geometry.

Capture committed Windows/OpenGL evidence under:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v03/`

Required states:
- VIP pending with premium indication;
- VIP partial if quantity >1;
- VIP completed;
- non-VIP hidden.

Owner visual acceptance remains required after technical audit.

## Gate G — focused V03 tests

Extend M15 probe to prove:
- VIP validation boundaries L1/L12 accepted and L0/L13 rejected;
- positive integer quantity validation;
- actual merged VIP unit adds exactly 2x normal order reward;
- stored VIP unit adds exactly 2x normal order reward;
- quantity 2 total payout equals two unit bonuses;
- extra delivery after completion adds zero;
- normal L6 delivery still pays 1x normal order reward;
- same-level normal/VIP precedence and payout separation;
- terminal result score reflects accepted VIP bonuses;
- existing booster/economy reward idempotency remains intact.

## Gate H — regression / governance

Required PASS:
- M15 twice;
- M14;
- M13;
- M12;
- M11;
- M10;
- M08;
- M03;
- M02.

Mandatory canonical Desktop sync at task start and after publication.

Codex must not edit `TASKS.md`, start M16, create a GitHub branch, create Desktop project copies, or retune physics/table/colliders.

## Builder log

Write:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V03.md`

Any material technical FAIL/UNVERIFIED => CHANGES_REQUIRED.