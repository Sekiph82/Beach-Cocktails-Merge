# BCM-M15 VIP Visual Remediation — Audit Criteria V04

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V04.md`
- M15 V03 technical audit PASS
- owner rejection of V03 VIP visuals

## Objective

Remediate only the VIP presentation. Preserve all V03 gameplay/economy behavior.

## Gate A — Separate attached VIP card

PASS requires:
- existing To-Go Orders panel remains visually unchanged;
- VIP information is removed from inside the To-Go Orders content area;
- when VIP is active, a separate compact VIP card appears directly below and visually attached to To-Go Orders;
- the VIP card is HUD-only and does not alter gameplay/table geometry;
- no overlap with the normal To-Go cocktail image or reward value.

## Gate B — VIP target cocktail image

PASS requires:
- VIP card shows the actual VIP target cocktail sprite/image;
- it uses the same cocktail texture/art source used by To-Go Orders (`Drink.texture_for_level()` or the canonical equivalent);
- cocktail artwork itself is not regenerated, recolored, restyled, or replaced;
- the VIP target must be identifiable visually without relying on raw `L#` text.

## Gate C — Progress presentation

PASS requires:
- active VIP with required quantity N begins at `0/N`;
- each accepted VIP delivery increments the visible count;
- partial state shows `1/N`, `2/N`, etc.;
- fully completed VIP replaces the numeric counter with `✓`;
- no `PENDING` or `COMPLETED` words are displayed.

## Gate D — Reward + 2X badge

PASS requires:
- VIP card shows the actual doubled VIP delivery payout for the target cocktail;
- displayed value equals `2 * Drink.order_reward(vip_level)`;
- a compact `2X` badge is positioned immediately adjacent to that value;
- reward and 2X are visually legible at 720x1280;
- no reward change is made to underlying scoring mechanics.

## Gate E — Non-VIP state

PASS requires:
- VIP card is completely hidden when no VIP objective is active;
- non-VIP To-Go Orders panel matches the accepted baseline with no dead space, placeholder, or residual VIP text.

## Gate F — Visual hierarchy

PASS requires:
- VIP card reads as a secondary attached card, not as debug telemetry;
- hierarchy is visually clear: VIP label, cocktail image, progress, reward + 2X;
- no text crosses the cocktail sprite;
- no raw `L8`, `PENDING`, `COMPLETED`, or similar state/debug strings;
- the card remains compact and does not visually compete with the mandatory To-Go panel.

## Gate G — Frozen behavior

Source diff must not change:
- V03 shared normal/VIP target policy;
- VIP 2x payout calculation;
- normal To-Go payout;
- VIP quantity ledger;
- same-level precedence;
- terminal economy reward behavior;
- WIN/LOSE/stars/progression;
- R11 physics/table/collider behavior.

## Gate H — Evidence

Capture Windows/OpenGL evidence under:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v04/`

Required:
- `vip_pending.png` showing `0/N`;
- `vip_partial.png` showing partial progress;
- `vip_completed.png` showing `✓`;
- `non_vip.png` showing the VIP card fully absent.

Evidence must show the full top HUD context, not only isolated crops.

## Gate I — Regression

Required PASS:
- M15 focused probe twice;
- M14 gameplay-session regression;
- M08 To-Go delivery regression;
- M03 scoring/To-Go regression;
- `git diff --check`.

Codex must not edit root `TASKS.md`.

Mandatory canonical Desktop sync applies before and after the task.

No new GitHub branch or Desktop project/worktree.

## Builder log

Write:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V04.md`

Final technical verdict remains pending owner visual acceptance.