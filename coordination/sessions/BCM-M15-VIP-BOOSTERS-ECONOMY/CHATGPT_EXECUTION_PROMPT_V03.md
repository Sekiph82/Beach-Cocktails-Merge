# BCM-M15 VIP, Boosters, Rewards & Economy — Execution Prompt V03

Implement the clarified owner ruling against:

- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V03.md`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V03.md`

Before any work, obey the mandatory canonical Desktop sync rule in `AGENTS.md` for:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

## Owner rule

VIP does **not** have its own L1-L12 target range.

VIP must follow the **same campaign To-Go target eligibility rule as normal To-Go orders** for the same island/content set.

Current roadmap example:
- normal campaign target minimum = L5;
- Sunny Cove normal targets = L5-L8;
- therefore Sunny Cove VIP targets = L5-L8;
- future-island VIP ranges follow that island's normal To-Go rule.

Do not use the legacy/free-play `L6-L12` random selector as campaign content policy.

The only VIP-specific difference is reward:

`VIP unit payout = 2 * Drink.order_reward(vip_level)`

## 1. Target-policy parity

Remove/avoid the superseded V03 idea of a VIP-only L1-L12 eligibility validator.

Where validation/policy needs adjustment:
- VIP must reuse the same target eligibility source/helper/policy as normal campaign To-Go;
- do not create duplicated range constants that can drift;
- keep positive-integer VIP quantity validation;
- do not populate M16 Sunny Cove L1-L100 content in this task.

If the current normal campaign eligibility rule is not yet encoded as a reusable validator because M16 owns content population, add only the minimum shared policy plumbing needed for parity, without authoring M16 level records.

## 2. Add delivery-time VIP premium

On successful real V02 VIP capture completion:
- compute `2 * Drink.order_reward(delivered_level)`;
- add the bonus exactly once to GameManager score;
- refresh HUD;
- update GameplaySessionBridge with the post-bonus score;
- record the accepted VIP delivery.

Do not duplicate merge/combo score.

No VIP bonus for rejected, mismatched, paused, invalid, or post-completion no-op deliveries.

For quantity 2, each accepted physical VIP drink gets its own 2x unit payout.

## 3. Preserve separate economy reward

Configured VIP booster/coin reward remains separate:
- no economy grant at delivery time;
- grant only at normal WIN + completed VIP;
- preserve deterministic reward-ledger idempotency.

## 4. Same-level normal/VIP rule

Preserve V02 mandatory-normal-first precedence.

If normal and VIP both request the same level:
- while normal is pending, the drink satisfies normal To-Go and receives 1x normal order reward only;
- it does not increment VIP;
- after normal requirement is complete, later same-level drinks may satisfy VIP and receive 2x VIP payout.

## 5. VIP UI

Keep the compact V02 badge footprint.

Add a bounded premium indicator such as `2X` or exact reward amount without moving accepted HUD/table geometry.

Capture V03 Windows/OpenGL evidence under:

- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v03/`

## 6. Tests

Extend M15 probe to prove:
- VIP target eligibility mirrors normal campaign To-Go policy;
- no independent L1-L12 VIP rule;
- positive integer quantity validation;
- merged VIP exact 2x payout;
- stored VIP exact 2x payout;
- quantity-2 cumulative payout;
- no payout after completion;
- normal delivery remains 1x;
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
- start M16 canonical content population;
- change normal To-Go reward values;
- alter merge/combo scoring;
- retune R11 physics/table/colliders;
- add purchases/ads/backend;
- create GitHub branches;
- create Desktop project copies/worktrees.

## Completion

Write:

- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V03.md`

Push to `main`, then perform mandatory post-task canonical Desktop sync.

Return:
- implementation SHA;
- final main/canonical SHA;
- normal/VIP target-policy parity PASS/FAIL;
- 2x VIP payout PASS/FAIL;
- same-level precedence PASS/FAIL;
- M15x2 and regression results;
- V03 evidence paths;
- log URL;
- `AWAITING_M15_AUDIT_V03`.

Then STOP.