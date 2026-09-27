# BCM-M15 Combined To-Go + VIP HUD Integration — Audit Criteria V05

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V05.md`
- owner-approved asset `assets/ui/panel_to_go_vip_orders.png`
- M15 V03 technical behavior
- V04 technical audit PASS, superseded only in visual composition

## Objective

Integrate the owner-approved combined To-Go + VIP HUD master without changing accepted gameplay/economy behavior.

## Gate A — Canonical asset usage

PASS requires:
- runtime uses `assets/ui/panel_to_go_vip_orders.png` as the visible To-Go/VIP frame;
- existing standalone `panel_to_go_orders.png` is no longer the active gameplay frame;
- procedural dark V04 VIP card styling is removed from the active composition;
- no regeneration/redesign of the approved combined master;
- asset source/display width remains tied to the existing To-Go width contract.

## Gate B — Same external HUD width / safe placement

At the 720×1280 reference viewport:
- combined frame width remains `210 * ui_scale`, matching current To-Go display width;
- panel remains centered at the current top-HUD anchor;
- BEST / SCORE / NEXT / logo remain readable and not overlapped;
- gameplay/table/launch/danger geometry is unchanged.

Responsive scaling must continue to use existing HUD scaling conventions.

## Gate C — Normal To-Go content

Upper panel must show:
- actual current To-Go cocktail via canonical cocktail texture source;
- dynamic normal-order progress in the upper progress recess;
- dynamic normal-order reward number in the upper reward recess;
- embedded static cocktail-coin icon remains visible.

Do not bake cocktail/progress/reward digits into the PNG.

Normal reward remains existing `Drink.order_reward(level)`.

## Gate D — VIP content / equal cocktail scaling

When VIP exists, lower panel must show:
- actual VIP target cocktail via the same canonical cocktail texture source;
- progress `0/N`, partial `1/N` etc., and `✓` on completion;
- doubled VIP reward number;
- static embedded cocktail-coin and static `2X` badge.

Upper and lower cocktail sprites must use:
- the same content-box class/dimensions;
- the same scale policy/max visible footprint;
- no separate smaller VIP icon scale.

## Gate E — Always-visible non-VIP state

When no VIP objective exists:
- lower VIP panel remains visible;
- VIP cocktail sprite is absent/hidden;
- progress is exactly `0/0`;
- VIP reward digits are blank/neutral so no payout is falsely advertised;
- fixed HUD height/placement does not jump.

The static `VIP` and `2X` artwork remains because it is part of the approved master.

## Gate F — Normal-order progress truth

Campaign normal-order progress displayed in the upper recess must derive from authoritative session objective state.

For the current required normal target level:
- initial display reflects completed/required accurately;
- accepted normal deliveries increment the display;
- switching to the next required target updates level/progress/reward consistently.

For non-campaign/free-play where campaign quantity state is unavailable, preserve existing gameplay semantics and use a deterministic, non-misleading single-order display rather than inventing campaign progress.

## Gate G — Frozen behavior

No changes to:
- normal target eligibility;
- VIP target-policy parity;
- normal To-Go reward values;
- VIP 2× delivery scoring;
- VIP quantity ledger;
- same-level precedence;
- terminal economy reward timing/idempotency;
- WIN/LOSE/stars/progression;
- R11 physics/table/colliders/launch/merge.

## Gate H — Evidence

Capture full 720×1280 Windows/OpenGL evidence under:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v05/`

Required:
- `normal_vip_pending.png`
- `normal_vip_partial.png`
- `normal_vip_completed.png`
- `non_vip_0_of_0.png`

Evidence must show entire top HUD plus enough gameplay area to judge overlap and scale.

## Gate I — Focused tests

Update/extend M15 focused probe to verify:
- combined asset path is active;
- legacy procedural VIP card style is no longer active;
- To-Go/VIP target sprites use identical scaling policy;
- campaign normal progress is authoritative;
- VIP pending/partial/checkmark;
- non-VIP remains visible with `0/0`, no cocktail, blank reward;
- normal reward unchanged;
- VIP reward display equals 2× while scoring behavior stays V03;
- same-level normal-first behavior preserved.

## Gate J — Regression/governance

Required PASS:
- M15 focused probe twice;
- M14;
- M08;
- M07 HUD composition/owner layout;
- M03;
- `git diff --check`.

Codex must obey canonical Desktop sync before/after task.

Codex must not edit root `TASKS.md`, create branches, create Desktop project copies/worktrees, or start M16.

## Builder log

Write:
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V05.md`

Final closure still requires independent audit and owner runtime visual acceptance.