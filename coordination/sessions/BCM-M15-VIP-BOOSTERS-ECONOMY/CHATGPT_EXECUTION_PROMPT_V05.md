# BCM-M15 Combined To-Go + VIP HUD Integration — Execution Prompt V05

Execute against:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V05.md`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V05.md`

Before implementation, obey `AGENTS.md` and synchronize the canonical Desktop checkout:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

## Canonical owner-approved HUD master

Use:
`res://assets/ui/panel_to_go_vip_orders.png`

Important facts:
- owner-approved;
- transparent PNG;
- source size `1132×755`;
- source width intentionally equals existing `panel_to_go_orders.png` width (`1132 px`);
- contains static `TO-GO ORDERS`, `VIP`, cocktail-coin art, `2X`, tropical decoration, and blank dynamic-content recesses.

Do not regenerate or redesign this asset.

## 1. Replace the active frame

Replace the current runtime composition of:
- `panel_to_go_orders.png`; plus
- procedural V04 dark VIP card

with one combined frame using `panel_to_go_vip_orders.png`.

At the 720×1280 reference viewport, keep the same external display width as current To-Go:
`to_go_vip_width = 210.0 * ui_scale`

Derive height from the new asset aspect ratio. Keep it centered at the same top HUD anchor.

Do not move BEST / SCORE / NEXT / logo unless a tiny bounded alignment correction is strictly necessary to prevent overlap; if any such adjustment is made, document it and prove M07 layout regression.

## 2. Dynamic upper To-Go content

Create runtime nodes aligned to the blank upper recesses:
- normal target cocktail sprite;
- normal progress label;
- normal reward-number label.

Use existing canonical cocktail art:
`Drink.texture_for_level(level)`.

Do not bake any changing values into the asset.

Reward remains exactly:
`Drink.order_reward(level)`.

### Normal progress

In campaign mode, derive progress from `GameplaySessionBridge.get_objective_state()` for the currently required normal level.

Display `completed / required` for that specific target level.

Do not infer from score or UI callbacks.

For legacy/free-play without campaign objective quantities, use a deterministic single-order representation such as `0/1` while pending and `1/1` only during a bounded completion transition if already supported. Do not invent persistent campaign quantity state.

## 3. Dynamic lower VIP content

The VIP panel is **always visible** because it is part of the combined master.

When VIP exists:
- show actual VIP cocktail sprite;
- show `0/N`, then partial progress, then `✓` when complete;
- show doubled reward digits:
  `2 * Drink.order_reward(vip_level)`.

Do not create runtime `VIP` or `2X` text. Those are already baked as static artwork.

Do not create another coin icon. The cocktail coin is already baked into the asset.

## 4. Non-VIP behavior

When no VIP target exists:
- keep the lower VIP board fully visible;
- hide/clear VIP cocktail sprite;
- set progress text exactly to `0/0`;
- clear VIP reward digits to empty string;
- leave static VIP / coin / 2X artwork visible;
- do not collapse or resize the combined panel.

This supersedes V04's `VipCard.visible = false` non-VIP behavior.

## 5. Equal cocktail sizing

The owner explicitly requires the normal and VIP cocktail images to be the same visual size policy.

Implement a shared helper/constant for both target slots.

Requirements:
- identical target-box dimensions;
- identical `_hud_icon_scale` max footprint or equivalent scaling rule;
- no VIP-specific reduced max such as the V04 `46px` path;
- natural cocktail silhouettes may differ, but scaling math is identical.

Use the owner-approved master recess geometry to determine the safe shared maximum.

## 6. Remove obsolete V04 presentation code

Remove/retire only presentation code that is now obsolete:
- procedural dark `StyleBoxFlat` VIP card;
- runtime VIP title label;
- runtime 2X label;
- any `PENDING` / `COMPLETED` state text;
- V04 logic that hides the whole VIP card on non-VIP levels.

Keep V03/V04 gameplay state and scoring code intact.

## 7. Preserve gameplay/economy

Do not change:
- normal To-Go eligibility;
- VIP target-policy parity;
- normal reward values;
- VIP 2× delivery bonus calculation;
- VIP quantity accumulation;
- same-level normal-first precedence;
- booster/economy reward dispatch;
- WIN/LOSE/stars;
- campaign progression;
- table/rails/colliders/physics/merge.

## 8. Runtime evidence

Capture full 720×1280 Windows/OpenGL screenshots to:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v05/`

Required:
- `normal_vip_pending.png`
- `normal_vip_partial.png`
- `normal_vip_completed.png`
- `non_vip_0_of_0.png`

The screenshots must prove:
- combined asset is centered;
- normal and VIP cocktails use equal scaling policy;
- texts fit their recesses;
- no overlap with BEST/SCORE/NEXT/logo;
- lower panel stays visible in non-VIP state with `0/0`.

## 9. Tests

Update/extend M15 probe without weakening prior technical assertions.

Run:
- M15 focused probe twice;
- M14;
- M08;
- M07 HUD composition and owner-layout probes;
- M03;
- `git diff --check`.

## Hard boundaries

Do not:
- edit root `TASKS.md`;
- modify the approved combined PNG;
- start M16;
- create a GitHub branch;
- create Desktop clones/worktrees;
- retune physics/table/colliders;
- change reward/economy semantics.

## Completion

Write:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V05.md`

Push to `main`, then perform mandatory post-task canonical Desktop sync.

Return:
- implementation SHA;
- final main/canonical SHA;
- combined asset active PASS/FAIL;
- external width parity PASS/FAIL;
- equal To-Go/VIP cocktail scaling PASS/FAIL;
- non-VIP persistent `0/0` state PASS/FAIL;
- normal progress/reward PASS/FAIL;
- VIP progress/reward PASS/FAIL;
- required test results;
- V05 screenshot paths;
- log URL;
- `AWAITING_M15_AUDIT_V05`.

Then STOP. Do not start M16.