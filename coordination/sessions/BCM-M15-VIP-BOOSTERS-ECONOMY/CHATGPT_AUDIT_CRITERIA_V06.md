# BCM-M15 Tall To-Go + VIP HUD — Audit Criteria V06

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V06.md`
- V05 technical audit PASS
- owner rejection of V05 runtime scale

## Objective

Replace only the V05 combined HUD asset/geometry with the owner-approved tall V06 master while preserving all accepted gameplay/economy behavior.

## Gate A — Exact canonical asset

PASS requires:
- Codex downloads the V06 PNG from the owner ruling;
- SHA-256 exactly equals:
  `acd600d05b316a01b5d39006cf845afa9674cfaaf0385c4f3aecda539d53539b`;
- PNG dimensions exactly `1132×1698`;
- destination is exactly `assets/ui/panel_to_go_vip_orders.png`;
- final repository asset hash is logged;
- V05 1132×755 master is replaced, not retained as the active runtime master.

Any hash/dimension mismatch = FAIL.

## Gate B — Width unchanged, height expanded

At 720×1280:
- combined HUD width remains `210.0 * ui_scale`;
- aspect ratio is preserved;
- runtime height derives from 1132×1698;
- runtime code must not squash/stretch the V06 master into V05 proportions;
- the vertical footprint is materially larger than V05, approximately 2×+ V05 height;
- top rope artwork begins at/near viewport top and is visibly long.

## Gate C — HUD composition

PASS requires:
- combined HUD remains horizontally centered;
- BEST SCORE, SCORE, NEXT and logo remain readable;
- no overlap/collision that makes those HUD elements unusable;
- To-Go/VIP board scale is visually comparable to the surrounding SCORE/BEST boards rather than miniature;
- table/playable geometry is unchanged.

## Gate D — Dynamic upper To-Go content

Upper board:
- canonical To-Go cocktail;
- authoritative normal progress;
- normal reward digits;
- all content fits the new V06 recesses;
- no runtime replacement of static title/coin/decorations.

Normal reward remains `Drink.order_reward(level)`.

## Gate E — Dynamic lower VIP content

VIP board:
- canonical VIP cocktail when active;
- `0/N`, partial values, then `✓`;
- reward display = `2 * Drink.order_reward(vip_level)`;
- static VIP/2X/coin art comes only from the master;
- no PENDING/COMPLETED/raw L# telemetry.

## Gate F — Non-VIP persistent state

No-VIP level:
- VIP board stays visible;
- no VIP cocktail;
- progress exactly `0/0`;
- VIP reward digits blank;
- no layout jump/collapse.

## Gate G — Equal cocktail scale policy

PASS requires:
- normal and VIP cocktail slots use the same scale helper/maximum footprint;
- no VIP-specific smaller scale;
- both are visually large enough to use the increased V06 board space;
- natural silhouette variation is allowed, scaling math is not.

## Gate H — Frozen technical behavior

No changes to:
- target eligibility;
- reward values/formulas;
- VIP 2× scoring;
- quantity ledger;
- same-level precedence;
- economy reward timing/idempotency;
- WIN/LOSE/stars/progression;
- R11 table/rails/colliders/physics/launch/merge.

## Gate I — Runtime evidence

Commit 720×1280 Windows/OpenGL evidence under:

`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v06/`

Required:
- `normal_vip_pending.png`
- `normal_vip_partial.png`
- `normal_vip_completed.png`
- `non_vip_0_of_0.png`

Evidence must show the entire top HUD and enough gameplay area to judge the new taller vertical footprint.

## Gate J — Regression

Required PASS:
- M15 focused probe twice;
- M14;
- M08;
- M07 HUD/layout probes;
- M03;
- `git diff --check`.

Codex must not:
- edit root `TASKS.md`;
- create branches;
- create Desktop clones/worktrees;
- start M16;
- modify physics/table/collider gameplay.

## Builder log

Write:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V06.md`

Final closure still requires independent audit and owner visual acceptance.
