# M15 Owner Visual Ruling V05 — Canonical Combined To-Go + VIP HUD Master

Status: **OWNER-APPROVED / CANONICAL FOR V05+**

Owner acceptance date: 2026-09-28

## Canonical production asset

- Path: `assets/ui/panel_to_go_vip_orders.png`
- Source canvas after repository normalization: `1132×755` PNG with transparency.
- Git blob: `6ff5bd6551fa2cfa5de569fca43c380626a9e038`.
- Width intentionally matches the existing canonical To-Go panel source width: `1132 px`.
- The owner explicitly selected this visual direction for the in-game To-Go + VIP HUD.

## Supersession

This ruling supersedes the V04 visual composition only.

V03/V04 gameplay behavior remains frozen unless explicitly stated below:
- VIP target-policy parity with normal campaign To-Go;
- VIP delivery payout = 2× normal To-Go reward for the same cocktail;
- VIP quantity accounting;
- same-level normal-first precedence;
- separate one-time VIP economy reward at WIN;
- WIN/LOSE/stars/progression;
- R11 physics/table/colliders.

## Combined HUD contract

1. Replace the old standalone `panel_to_go_orders.png` + procedural V04 VIP card composition with the single canonical combined HUD master `panel_to_go_vip_orders.png`.
2. Runtime display width remains the same as the current To-Go panel display width (`210 * ui_scale` at the 720×1280 reference viewport).
3. The asset itself supplies all static framing/decorative art:
   - `TO-GO ORDERS` title;
   - `VIP` crown badge;
   - cocktail-themed coin icons;
   - `2X` badge;
   - wood/cream/tropical frame;
   - empty dynamic-content recesses.
4. Dynamic runtime content must never be baked into or regenerated inside this asset.

## Normal To-Go dynamic content

The upper panel receives at runtime:
- current normal To-Go cocktail sprite;
- normal To-Go progress text in the upper progress recess;
- normal To-Go reward number in the upper reward recess.

The cocktail sprite uses the existing canonical cocktail artwork and is not regenerated/recolored/restyled.

## VIP dynamic content

The lower panel receives at runtime:
- VIP cocktail sprite when a VIP target exists;
- VIP progress:
  - `0/N` initially;
  - `1/N`, `2/N`, etc. during progress;
  - `✓` when complete;
- doubled VIP reward number in the lower reward recess.

The static cocktail-coin icon and static `2X` badge are already part of the canonical HUD asset.

## VIP card is always visible

The lower VIP panel must remain visible on **every level**, including levels with no VIP target.

When no VIP objective exists:
- keep the VIP panel visible;
- show **no VIP cocktail sprite**;
- show progress exactly `0/0`;
- show no misleading active VIP reward number; the reward-number recess may remain blank/neutral;
- keep the static VIP framing and static `2X` badge because they are part of the fixed HUD master.

This fixed-height HUD rule prevents level-to-level layout jumping.

## Equal cocktail sizing

The upper To-Go cocktail slot and lower VIP cocktail slot are intentionally designed as the same visual target class.

PASS requires:
- both runtime cocktail sprites use the same target-box dimensions;
- both use the same scaling function / max visible footprint;
- VIP cocktail may not be arbitrarily smaller than To-Go;
- natural artwork silhouettes may differ, but the scaling policy must be identical.

## Visual placement

- Preserve the current centered top-HUD anchor.
- The combined HUD must not cover the BEST / SCORE / NEXT / logo panels.
- It must remain HUD-only and must not alter the playable table, rails, launch zone, danger line, colliders, or physics.
- The new combined HUD may change To-Go/VIP internal sizing and positions as needed to fit the owner-approved master.

## Coin icon

The coin art embedded in the master uses a cocktail-glass symbol rather than the earlier palm-tree coin symbol. This is intentional and owner-approved for this HUD.

## Owner gate

The static master asset itself is owner-approved.

After runtime integration, owner acceptance is still required for:
- final 720×1280 placement;
- cocktail sizes;
- progress/reward typography;
- overlap/legibility;
- non-VIP `0/0` state;
- pending/partial/completed VIP states.