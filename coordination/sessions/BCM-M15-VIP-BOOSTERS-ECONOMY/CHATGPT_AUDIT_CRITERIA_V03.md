# BCM-M15 VIP, Boosters, Rewards & Economy — Audit Criteria V03

Status: **RELOCKED BEFORE EXECUTION AFTER OWNER CLARIFICATION**

Authority:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V03.md`
- M15 V02 technical implementation/audit
- accepted M14 and R11 gameplay contracts

No `CODEX_LOG_V03.md` existed when this clarification was locked.

## Objective

Implement the owner's VIP reward rule while preserving V02 real-delivery behavior:

- VIP target eligibility = normal campaign To-Go target eligibility;
- VIP per-delivery payout = 2x normal To-Go reward for that same level.

## Gate A — No independent VIP target range

PASS requires:
- no VIP-only L1-L12 eligibility rule;
- VIP target validation/policy mirrors the normal campaign To-Go eligibility policy;
- when a target is legal for normal campaign To-Go in a given island/content context, it is legal for VIP;
- when a target is illegal for normal campaign To-Go in that same context, it is illegal for VIP;
- `vip.quantity` remains a positive integer;
- no M16 Sunny Cove L1-100 content is authored in this task.

Current roadmap authority:
- no normal campaign target below L5;
- Sunny Cove normal targets L5-L8;
- therefore Sunny Cove VIP targets L5-L8;
- future islands inherit whatever normal target range is defined for that island.

Do not use the legacy/free-play L6-L12 selector as campaign target policy.

If validation plumbing is touched in V03, it must be shared/reusable rather than a separate VIP hardcode.

## Gate B — 2x VIP delivery payout

For every successfully accepted and physically consumed VIP cocktail unit:

`vip_bonus = 2 * Drink.order_reward(vip_level)`

PASS requires:
- bonus added exactly once per accepted VIP unit;
- merge/combo score unchanged and not duplicated;
- quantity-2 VIP pays two separate 2x bonuses;
- stored VIP delivery pays the same 2x bonus;
- rejected/mismatched/paused/nonpositive delivery pays zero;
- post-completion extra VIP drink pays zero;
- normal To-Go remains 1x `Drink.order_reward(level)`.

## Gate C — Score authority / stars

After VIP bonus is added:
- GameManager score is authoritative;
- GameplaySessionBridge receives the updated score;
- terminal result score includes accepted VIP bonuses;
- existing data-driven star rules remain unchanged.

## Gate D — Economy reward remains separate

Configured VIP booster/coin reward remains a separate one-time terminal economy reward.

PASS requires:
- delivery-time 2x score bonus does not mark economy reward ledger;
- economy VIP reward grants only on normal WIN + VIP complete;
- LOSE/incomplete VIP gives no VIP economy reward;
- replay/reload cannot duplicate it.

## Gate E — Same-level precedence

If normal and VIP target the same cocktail level:
- mandatory normal pending objective gets first claim;
- that drink gets normal 1x reward only;
- it does not increment/pay VIP;
- after normal requirement is satisfied, later qualifying drinks can satisfy VIP and receive 2x.

## Gate F — UI evidence

Keep V02 compact VIP badge geometry.

Add a bounded premium indication such as `2X` or exact VIP reward amount without moving accepted HUD/table geometry.

Capture committed Windows/OpenGL evidence under:

- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v03/`

Required:
- VIP pending with premium indication;
- VIP partial for quantity >1 if used;
- VIP completed;
- non-VIP hidden.

Owner visual acceptance remains required after technical audit.

## Gate G — Focused V03 tests

Extend M15 tests to prove:
- VIP uses the same target-eligibility rule as normal campaign To-Go;
- no independent VIP L1-L12 policy exists;
- positive integer VIP quantity validation;
- actual merged VIP unit adds exact 2x normal order reward;
- stored VIP unit adds exact 2x normal order reward;
- quantity-2 total payout equals two unit bonuses;
- extra delivery after completion adds zero;
- normal delivery remains 1x;
- same-level normal/VIP precedence and payout separation;
- terminal result score reflects VIP bonuses;
- existing economy reward idempotency remains intact.

Do not add L1/L12 boundary assertions merely because of the superseded ruling.

## Gate H — Regression / governance

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

Codex must not:
- edit `TASKS.md`;
- start M16 content population;
- create a GitHub branch;
- create Desktop project copies/worktrees;
- retune physics/table/colliders.

## Builder log

Write:

- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V03.md`

Any material technical FAIL/UNVERIFIED => `CHANGES_REQUIRED`.