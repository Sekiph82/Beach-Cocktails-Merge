# M15 Owner Ruling V03 — VIP Level Range and 2x Delivery Payout

Status: **OWNER-APPROVED / CANONICAL FOR M15+**

Owner ruling date: 2026-09-27

## Ruling

1. VIP cocktail targets may use any existing cocktail level from **L1 through L12 inclusive**.
2. Each successfully delivered VIP cocktail pays **exactly 2x the normal To-Go delivery reward for the same cocktail level**.

## Canonical interpretation

- Normal To-Go reward authority remains `Drink.order_reward(level)`.
- VIP per-unit delivery payout is:
  `VIP_DELIVERY_REWARD(level) = 2 * Drink.order_reward(level)`.
- The 2x payout applies per accepted/consumed VIP drink.
- Merge/combo score remains unchanged and is awarded once by normal merge logic.
- VIP payout is an additional delivery bonus analogous to the normal To-Go delivery bonus.
- A mismatched, rejected, paused, invalid, or post-completion duplicate VIP attempt pays zero.
- Existing configured VIP economy reward payloads (for example booster rewards) remain separate one-time rewards dispatched only after normal WIN + completed VIP.
- VIP remains optional and never gates normal level completion.
- Normal campaign target constraints and VIP target constraints are separate. In particular, the M16 normal-target minimum L5 rule does not prevent VIP targets from using L1-L4.

## Data validity

- `vip.cocktail_level` must be integer L1-L12.
- `vip.quantity` must be a positive integer when VIP is enabled.
- Invalid VIP target data must fail deterministic LevelDatabase validation.

## Same-level normal/VIP precedence

If the normal mandatory objective and VIP objective request the same cocktail level, mandatory normal delivery retains first claim while that normal objective remains pending. Additional qualifying drinks may satisfy VIP afterward.

This ruling supersedes any earlier implication that VIP capture provides no To-Go-style score payout.