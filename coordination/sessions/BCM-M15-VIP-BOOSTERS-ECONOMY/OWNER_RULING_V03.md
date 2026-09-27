# M15 Owner Ruling V03 — VIP Target Parity + 2x Delivery Payout

Status: **OWNER-APPROVED / CANONICAL FOR M15+**

Owner ruling date: 2026-09-27
Revision: owner clarified the target-range rule before V03 execution.

## Ruling

1. VIP cocktails do **not** have a separate L1-L12 eligibility rule.
2. VIP cocktail target eligibility must be **the same as the normal campaign To-Go target rule** for that island/content set.
3. Each successfully delivered VIP cocktail pays **exactly 2x the normal To-Go delivery reward for the same cocktail level**.

## Canonical interpretation

- Normal To-Go target policy is the single source of truth for which cocktail levels are eligible.
- VIP must reuse/inherit that policy; no independent VIP target range may drift from normal To-Go rules.
- Current canonical campaign direction:
  - no normal campaign target below L5;
  - Sunny Cove normal targets are L5-L8;
  - therefore Sunny Cove VIP targets are also L5-L8;
  - future islands may expand/change their eligible range, and VIP follows that same island rule automatically.
- The legacy/free-play verification sequence (L5 -> L6 -> L7, then legacy L6-L12) is not the campaign content eligibility contract.

## Reward rule

Normal To-Go reward authority remains:

`Drink.order_reward(level)`

VIP per-unit delivery payout is:

`VIP_DELIVERY_REWARD(level) = 2 * Drink.order_reward(level)`

The 2x payout:
- applies per accepted/consumed VIP drink;
- is an additional To-Go-style delivery bonus;
- does not duplicate merge/combo score;
- pays zero on invalid, rejected, mismatched, paused, or post-completion duplicate attempts.

## Economy reward remains separate

Existing configured VIP economy rewards (for example booster/coin payloads) remain separate one-time rewards dispatched only after:
- normal WIN; and
- completed VIP.

VIP remains optional and never gates normal level completion.

## Validation rule

- VIP data must satisfy the same target-eligibility policy used by normal campaign To-Go data.
- Do not create a VIP-only L1-L12 validator.
- `vip.quantity` must remain a positive integer when VIP is enabled.
- Invalid VIP target data must fail deterministically whenever the corresponding normal target would also be invalid.
- M15 V03 must not author Sunny Cove L1-100 content; M16 remains the canonical content-population milestone.

## Same-level normal/VIP precedence

If normal mandatory To-Go and VIP request the same cocktail level:
- mandatory normal delivery retains first claim while normal quantity remains pending;
- that drink receives the normal 1x To-Go reward only;
- it does not simultaneously count as VIP;
- later qualifying drinks may satisfy VIP and receive the 2x VIP payout.

This ruling supersedes the earlier V03 wording that gave VIP an independent L1-L12 range.