# M15 Owner Visual Ruling V06 — Tall To-Go + VIP HUD Master

Status: **OWNER-APPROVED / CANONICAL FOR V06**

Owner decision date: 2026-09-28

## Owner rejection of V05 runtime scale

The V05 runtime integration is technically valid but visually rejected.

Reason:
- the combined To-Go/VIP HUD is too short/small relative to the BEST SCORE and SCORE boards;
- width is correct and must remain unchanged;
- total visual height must increase substantially, approximately 2× versus the V05 master/runtime result;
- the hanging ropes above the To-Go board must be much longer.

V05 gameplay/economy behavior remains accepted. This ruling supersedes V05 **visual asset geometry and placement only**.

## Canonical V06 source asset

Download source:
https://d2ol7oe51mr4n9.cloudfront.net/user_3FxbKbb9noNuzsWT2Zc6dqfIuy6/a98d64bb-5bdd-438b-9346-665f8125530d.png

Required SHA-256:
`acd600d05b316a01b5d39006cf845afa9674cfaaf0385c4f3aecda539d53539b`

Required PNG dimensions:
`1132 × 1698`

Required repository destination:
`assets/ui/panel_to_go_vip_orders.png`

The asset is the owner-approved design with:
- same overall source width as the old To-Go master: 1132 px;
- much taller overall composition;
- substantially longer top ropes;
- taller upper To-Go board;
- taller lower VIP board;
- small VIP badge;
- small 2X badge;
- cocktail-themed coin medallions;
- transparent exterior/background;
- empty dynamic cocktail/progress/reward content areas.

Codex must verify SHA-256 before replacing the repository asset.

## Runtime geometry

At the canonical 720×1280 reference viewport:

- external HUD width remains exactly the existing To-Go width:
  `210.0 * ui_scale`;
- runtime height is derived from the new 1132×1698 asset aspect ratio;
- do **not** artificially squash the new asset back to V05 height;
- preserve aspect ratio;
- keep the combined HUD centered on the same horizontal anchor;
- place the top of the rope artwork at the viewport top so the long ropes are visible;
- the larger vertical footprint is intentional.

The owner specifically wants the sign to read at a visual scale comparable to the BEST SCORE and SCORE boards rather than as a tiny central widget.

## Dynamic content

Upper To-Go:
- canonical normal cocktail artwork;
- normal progress;
- normal reward digits.

Lower VIP:
- canonical VIP cocktail artwork when VIP exists;
- `0/N`, partial progress, then `✓`;
- doubled VIP reward digits.

Non-VIP:
- lower VIP panel stays visible;
- cocktail absent;
- progress exactly `0/0`;
- reward digits blank.

## Equal cocktail sizing

Normal and VIP cocktail slots must continue to use the same runtime scale policy and same maximum visual footprint.

The larger/taller asset is intended to give both cocktail sprites enough space. Do not shrink VIP separately.

## Static asset elements

Do not recreate these as runtime text/icons:
- TO-GO ORDERS;
- VIP;
- 2X;
- cocktail coin medallions;
- wood/rope/flowers/leaves.

## Frozen technical behavior

Do not change:
- normal To-Go target/reward logic;
- VIP target-policy parity;
- VIP 2× scoring;
- VIP quantity accumulation;
- same-level normal-first precedence;
- VIP economy reward idempotency;
- WIN/LOSE/stars/progression;
- R11 physics/table/colliders/launch/merge.

## Owner acceptance gate

After V06 integration, owner review is required for:
- overall visual size relative to BEST SCORE / SCORE / NEXT;
- rope length and top attachment;
- To-Go and VIP board vertical footprint;
- cocktail size;
- progress/reward typography and fit;
- overlap with other HUD;
- all VIP/non-VIP runtime states.
