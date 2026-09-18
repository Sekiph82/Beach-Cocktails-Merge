# BCM-M08-TO-GO-DELIVERY-POLISH — ChatGPT Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

Add restrained To-Go delivery and merge/order feedback polish without changing accepted gameplay, physics, scoring, table-edge behavior, HUD layout, or canonical assets.

## Frozen baseline

Do not change:
- owner-accepted R11 table-edge footprint behavior;
- V05 playable rail coordinates;
- launch speed 700 px/s;
- deceleration 180 px/s²;
- drink-to-drink collider radii;
- merge momentum rules;
- no-backward rule;
- scoring/combo/To-Go reward values;
- To-Go target logic;
- stored-drink fulfillment rules;
- BEST SCORE / SCORE / NEXT / To-Go HUD placement;
- held drink alignment;
- canonical cocktail/environment/UI PNGs;
- save/Game Over/restart behavior.

No guide line.

## Required M08 behavior

### To-Go delivery

When an eligible drink satisfies the active To-Go order:
- clearly communicate that the drink is being delivered;
- preserve the existing collection destination and reward logic;
- use restrained movement/scale/fade/trail feedback;
- delivery animation must not block or corrupt normal gameplay state;
- the delivered drink must be removed exactly once;
- the To-Go reward must be awarded exactly once;
- previously scored stored drinks must not receive merge/combo points again;
- target transition must complete and choose the next target normally.

### Merge feedback

When a merge occurs:
- provide a short restrained visual confirmation at the merge position;
- do not obscure the board;
- do not add long screen-blocking particles;
- do not alter merge position, momentum, level result, scoring or combo math;
- keep effects lightweight enough for mobile.

### Order completion feedback

The To-Go panel/target may receive a short pulse/flash/scale response when an order completes.

Do not redesign or move the accepted panel.

## Asset policy

Prefer existing canonical assets and lightweight procedural/tween effects.

If `assets/effects/to_go_trail.png` exists and is appropriate, it may be used.

Do not regenerate or replace owner-approved assets.

## Runtime safety

Effects must:
- clean themselves up;
- not leak nodes/tweens;
- not keep stale references to deleted drinks;
- not create duplicate delivery callbacks;
- not interfere with rapid-launch;
- not affect collision layers/masks;
- not modify gameplay physics.

## Tests

Add focused M08 coverage verifying:
1. matching To-Go drink is collected once;
2. reward is added once;
3. stored eligible drink delivery does not re-award merge/combo score;
4. target transition returns to idle and selects next target;
5. visual effect nodes self-clean;
6. merge feedback does not change merge result position/level/momentum contract;
7. rapid-launch/no-input regressions remain intact;
8. R11 table-edge regression remains intact;
9. M01-M07 active regressions remain green.

## Visual evidence

Provide a normal GUI 720x1280 capture sequence or screenshots showing:
- To-Go delivery in progress;
- order completion feedback;
- merge feedback;
- HUD/table layout unchanged.

Builder screenshots are evidence only. Final visual acceptance remains owner/ChatGPT audit.

## Scope

Do not start M09 audio/haptics.

Codex must not edit TASKS.md or ChatGPT-owned criteria/audit files.
