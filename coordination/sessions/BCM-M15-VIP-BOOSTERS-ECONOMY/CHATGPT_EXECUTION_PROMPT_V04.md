# BCM-M15 VIP Visual Remediation — Execution Prompt V04

Execute only this visual remediation against:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V04.md`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V04.md`

Before work, obey `AGENTS.md` and synchronize the canonical Desktop checkout:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

## Scope

This task changes **only the VIP presentation**.

All V03 gameplay, score, target-policy, quantity, reward-ledger, WIN/LOSE, and progression behavior is frozen.

## 1. Preserve the existing To-Go Orders panel

Do not redesign or move the accepted To-Go Orders panel.

Remove the current inline VIP status string from inside that panel.

The normal To-Go cocktail image and normal reward value remain exactly in their accepted positions and behavior.

## 2. Add a separate attached VIP card

When VIP is active, create/show a compact secondary VIP card directly below and visually attached to the To-Go Orders panel.

Requirements:
- separate visual container from To-Go Orders;
- centered/aligned with the To-Go panel;
- compact enough to stay secondary;
- HUD-only;
- no table/playable-boundary changes;
- no overlap with normal To-Go cocktail/reward content.

When VIP is inactive, hide the entire card with no empty placeholder.

## 3. VIP target artwork

Inside the VIP card, show the actual VIP target cocktail image.

Use the same canonical cocktail texture source used by To-Go Orders, preferably the same `Drink.texture_for_level(vip_level)` path and equivalent HUD scaling behavior.

Do not regenerate, recolor, restyle, or replace cocktail art.

Do not rely on `L8` or another raw level label to identify the target.

## 4. VIP progress

Show a compact progress counter:
- initial: `0/N`;
- partial: `1/N`, `2/N`, etc.;
- complete: replace the fraction with `✓`.

Do not display:
- `PENDING`;
- `COMPLETED`;
- debug/state strings.

## 5. Reward presentation

Show the actual VIP per-unit delivery payout:
`2 * Drink.order_reward(vip_level)`

Place a compact `2X` badge immediately next to that points value.

This is display only. Do not change the V03 scoring calculation.

## 6. Visual hierarchy

The card should read immediately as:
`VIP` → target cocktail → progress → points + `2X`.

Keep typography legible at the 720x1280 reference viewport.

No text may cross the cocktail image.

Do not use one long status sentence.

Do not enlarge the card enough to compete visually with the mandatory To-Go panel.

Use existing game UI language/resources where practical. Do not generate a new cocktail asset.

## 7. Evidence

Capture Windows/OpenGL runtime evidence to:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v04/`

Required files:
- `vip_pending.png` with `0/N`;
- `vip_partial.png` with partial progress;
- `vip_completed.png` with `✓`;
- `non_vip.png` with VIP card absent.

Use full-screen 720x1280 evidence so placement relative to To-Go Orders and gameplay is visible.

## 8. Tests

Run:
- M15 focused probe twice;
- M14 gameplay-session probe;
- M08 To-Go delivery probe;
- M03 scoring/To-Go regression;
- `git diff --check`.

Update the focused M15 assertions only as needed for the new presentation. Do not weaken gameplay/economy assertions.

## Hard boundaries

Do not:
- edit root `TASKS.md`;
- change VIP target policy;
- change VIP 2x payout logic;
- change normal To-Go rewards;
- change quantity accounting;
- change same-level precedence;
- change WIN/LOSE/stars/economy reward timing;
- touch R11 physics/table/colliders;
- start M16;
- create a GitHub branch;
- create any extra Desktop project/worktree.

## Completion

Write:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V04.md`

Push to `main`, then perform mandatory post-task canonical Desktop sync.

Return:
- implementation SHA;
- final main/canonical SHA;
- separate attached VIP card PASS/FAIL;
- cocktail image parity PASS/FAIL;
- progress `0/N → partial → ✓` PASS/FAIL;
- reward + `2X` badge PASS/FAIL;
- required test results;
- V04 screenshot paths;
- log URL;
- `AWAITING_M15_AUDIT_V04`.

Then STOP. Do not start another task.