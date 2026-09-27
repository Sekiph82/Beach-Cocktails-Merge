# M15 Owner Visual Ruling V04 — Separate Attached VIP Card

Status: **OWNER-APPROVED / CANONICAL FOR V04**

Owner ruling date: 2026-09-27

## Visual contract

VIP presentation must no longer be rendered as a text line inside the existing To-Go Orders panel.

When VIP is active:
- keep the existing To-Go Orders panel visually unchanged;
- open a **separate compact VIP card directly below and visually attached to the To-Go Orders panel**;
- keep the VIP card HUD-only; it must not alter gameplay/table geometry.

## VIP card contents

The VIP card contains only the following gameplay information:

1. `VIP` label.
2. The **actual VIP target cocktail image**, using the same cocktail artwork/texture source and unchanged cocktail appearance used by To-Go Orders.
3. VIP progress counter:
   - before any completion: `0/N`;
   - partial: `1/N`, `2/N`, etc.;
   - once all VIP tasks for that level are complete: replace the numeric progress with `✓`.
4. VIP reward points.
5. A compact `2X` badge immediately adjacent to the VIP reward points.

## Explicit removals

Do not show:
- `PENDING`;
- `COMPLETED`;
- debug-style state strings;
- raw cocktail level text such as `L8` as the primary way to identify the VIP target;
- VIP text over the normal To-Go cocktail image.

## Reward display

The displayed VIP points must represent the actual VIP delivery payout for the target cocktail under the accepted V03 rule:

`2 * Drink.order_reward(vip_level)`

The `2X` badge sits beside that points value and visually communicates the premium.

## Non-VIP state

When the level has no active VIP objective:
- the VIP card is completely hidden;
- the existing non-VIP To-Go Orders panel remains exactly as before.

## Frozen behavior

V04 is a visual remediation only.

Do not change:
- V03 target-policy parity;
- VIP 2x scoring mechanics;
- normal To-Go reward logic;
- VIP quantity accounting;
- WIN/LOSE/stars;
- economy reward dispatch;
- physics, colliders, table geometry, launch, merge, or campaign progression.