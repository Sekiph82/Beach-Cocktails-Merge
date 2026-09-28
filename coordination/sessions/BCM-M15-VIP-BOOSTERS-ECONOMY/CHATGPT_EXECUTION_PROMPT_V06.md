# BCM-M15 Tall To-Go + VIP HUD Integration — Execution Prompt V06

Execute only this V06 visual remediation against:

- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V06.md`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V06.md`

Before any work, obey `AGENTS.md` and synchronize the canonical Desktop checkout:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

## 1. Replace the active combined HUD asset

Download the owner-approved PNG from:

`https://d2ol7oe51mr4n9.cloudfront.net/user_3FxbKbb9noNuzsWT2Zc6dqfIuy6/a98d64bb-5bdd-438b-9346-665f8125530d.png`

Before using it, verify:

- SHA-256:
  `acd600d05b316a01b5d39006cf845afa9674cfaaf0385c4f3aecda539d53539b`
- dimensions:
  `1132 × 1698`

If either check fails, STOP and report failure.

Replace:

`assets/ui/panel_to_go_vip_orders.png`

with this exact verified PNG.

Do not regenerate, redraw, crop, stretch, recolor, or edit the owner-approved asset.

## 2. Keep width, expand height

At the 720×1280 reference viewport:

`to_go_vip_width = 210.0 * ui_scale`

must stay unchanged.

Derive runtime height from the new `1132×1698` asset aspect ratio.

Do not constrain it back to the old V05 height.

Keep aspect ratio intact.

The new visual must be substantially taller than V05. This is intentional.

## 3. Long top ropes

Keep the combined HUD centered horizontally.

Place the asset so the top of the long rope artwork begins at/near the top edge of the viewport.

The long ropes must remain visibly present. Do not crop them away or compensate by pushing the board upward.

The owner wants the hanging sign to visually occupy much more of the vertical top-HUD space.

## 4. Re-map dynamic content to the new tall recesses

Recalculate the runtime content rectangles for the new source geometry.

Upper To-Go board:
- normal target cocktail;
- authoritative normal progress;
- normal reward digits.

Lower VIP board:
- VIP target cocktail when enabled;
- `0/N`, partial values, then `✓`;
- doubled VIP reward digits.

Use source-space or normalized coordinates derived from the new V06 PNG. Do not reuse V05 pixel coordinates blindly.

## 5. Cocktail sizing

Use one shared scaling helper/constant for both normal and VIP cocktail sprites.

Requirements:
- identical max footprint policy;
- same target-box class;
- no separate smaller VIP scale;
- use the extra vertical room provided by the new asset;
- do not make the cocktails tiny inside the larger boards.

## 6. Non-VIP behavior remains fixed

When the level has no VIP target:
- VIP board remains visible;
- VIP cocktail hidden/cleared;
- progress exactly `0/0`;
- VIP reward digits empty;
- static VIP / coin / 2X artwork remains visible;
- no layout jump.

## 7. Preserve all accepted M15 behavior

Do not change:
- normal To-Go target logic;
- normal reward values;
- VIP target-policy parity;
- VIP 2× scoring;
- VIP quantity accumulation;
- same-level normal-first precedence;
- VIP economy reward grant/idempotency;
- WIN/LOSE/stars;
- campaign progression;
- table/rails/colliders/physics/merge/launch.

V06 is visual geometry + asset integration only.

## 8. Surrounding HUD protection

BEST SCORE, SCORE, NEXT and logo must remain readable and usable.

Do not move them unless a very small bounded correction is necessary after the taller asset is integrated.

If any correction is made:
- document exact old/new coordinates;
- keep it minimal;
- prove M07 HUD/layout regression PASS.

## 9. Runtime evidence

Capture full 720×1280 Windows/OpenGL screenshots to:

`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v06/`

Required:

- `normal_vip_pending.png`
- `normal_vip_partial.png`
- `normal_vip_completed.png`
- `non_vip_0_of_0.png`

Evidence must clearly show:
- long top ropes;
- much taller To-Go/VIP combined HUD;
- relative size against BEST SCORE / SCORE / NEXT;
- equal normal/VIP cocktail scaling;
- text/reward fit;
- no blocking overlap;
- persistent non-VIP `0/0`.

## 10. Tests

Update focused layout assertions only as needed for the new owner-approved V06 geometry. Do not weaken gameplay/economy assertions.

Run:
- M15 focused probe twice;
- M14;
- M08;
- M07 HUD/layout probes;
- M03;
- `git diff --check`.

## Hard boundaries

Do not:
- edit root `TASKS.md`;
- modify the verified V06 PNG after download;
- start M16;
- create a GitHub branch;
- create Desktop project copies/worktrees;
- retune gameplay physics/table/colliders;
- change scoring/economy semantics.

## Completion

Write:

`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V06.md`

The log must include:
- downloaded source URL;
- verified SHA-256;
- verified PNG dimensions;
- final repository asset SHA-256;
- implementation commit SHA;
- final main/canonical SHA;
- old V05 runtime HUD size;
- new V06 runtime HUD size at 720×1280;
- any surrounding HUD coordinate changes;
- test results;
- V06 screenshot paths.

Push to `main`, then perform mandatory post-task canonical Desktop sync.

Return:

- implementation SHA;
- final main/canonical SHA;
- asset SHA/dimension verification PASS/FAIL;
- same-width/taller-height PASS/FAIL;
- long-rope visibility PASS/FAIL;
- equal cocktail scaling PASS/FAIL;
- non-VIP persistent `0/0` PASS/FAIL;
- regression results;
- V06 evidence paths;
- log URL;
- `AWAITING_M15_AUDIT_V06`.

Then STOP. Do not start M16.
