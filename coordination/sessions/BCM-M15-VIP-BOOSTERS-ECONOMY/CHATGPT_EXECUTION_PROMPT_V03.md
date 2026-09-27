# BCM-M15 VIP, Boosters, Rewards & Economy — Execution Prompt V03

Implement the new owner ruling against:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V03.md`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V03.md`

Before any work, obey the mandatory canonical Desktop sync rule in `AGENTS.md` for:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`.

## Owner rule

VIP cocktails may be any existing cocktail level **L1-L12**.

Every successfully delivered VIP cocktail pays **2x the normal To-Go reward of that same level**.

Use the existing single source of truth:
`Drink.order_reward(level)`.

Therefore:
`VIP unit payout = 2 * Drink.order_reward(vip_level)`.

## 1. Validate VIP target data

Extend LevelDatabase validation so enabled VIP definitions enforce:
- cocktail_level integer 1..12;
- positive integer quantity;
- deterministic rejection outside range.

Do not apply the normal M16 minimum-L5 rule to VIP. L1-L4 are legal VIP targets.

## 2. Add delivery-time VIP premium

On successful real V02 VIP capture completion:
- compute `2 * Drink.order_reward(delivered_level)`;
- add that bonus once to GameManager score;
- refresh HUD;
- then update GameplaySessionBridge current score with the post-bonus total;
- record the accepted VIP delivery.

Do not duplicate merge/combo score.

Do not pay VIP premium for rejected/invalid/mismatched/post-completion no-op deliveries.

For a quantity-2 VIP order, each of the two actual delivered cocktails receives its own 2x unit payout.

## 3. Preserve separate economy reward

Keep configured VIP booster/coin reward behavior separate:
- no economy grant at delivery time;
- economy grant only at normal WIN + VIP complete;
- deterministic reward ledger remains idempotent.

## 4. Same-level normal/VIP rule

Preserve V02 mandatory-normal-first precedence.

If both normal and VIP request L6:
- while normal L6 is pending, that drink goes to normal To-Go and receives normal 1x order reward only;
- it does not also increment VIP;
- after normal L6 requirement is satisfied, later L6 drinks may satisfy VIP and receive 2x VIP payout.

## 5. VIP UI

Keep the existing compact badge footprint.

Add a bounded premium indication so the player can understand VIP pays more. Prefer exact amount or a compact `2X` indicator without changing accepted HUD/table geometry.

Capture V03 Windows/OpenGL evidence under:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v03/`.

## 6. Tests

Extend the M15 probe for:
- L1/L12 valid VIP targets;
- L0/L13 invalid VIP targets;
- invalid quantity;
- merged VIP exact 2x payout;
- stored VIP exact 2x payout;
- quantity-2 cumulative payout;
- no payout after completion;
- normal order remains 1x;
- same-level precedence;
- terminal score includes VIP bonuses;
- existing economy reward idempotency.

Then run:
- M15 twice;
- M14, M13, M12, M11, M10;
- M08, M03, M02.

## Hard boundaries

Do not:
- edit root `TASKS.md`;
- start M16 canonical content;
- change normal target reward values;
- alter merge/combo scoring;
- retune R11 physics/table/colliders;
- add purchases/ads/backend;
- create GitHub branches;
- create Desktop project copies/worktrees.

## Completion

Write:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V03.md`

Push to `main`, then perform mandatory post-task canonical Desktop sync.

Return:
- implementation SHA;
- final main/canonical SHA;
- VIP L1-L12 validation PASS/FAIL;
- 2x VIP payout PASS/FAIL;
- same-level precedence PASS/FAIL;
- M15x2 and regression results;
- V03 evidence paths;
- log URL;
- `AWAITING_M15_AUDIT_V03`.

Then STOP.