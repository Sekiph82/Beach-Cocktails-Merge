# Move-limit calibration and budget recommendations

## Current implementation under audit

Sunny Cove level 6 is the only activated move-limited level. Its candidate budget is 35 successful committed launches. Levels 1–5 and 7–100 retain unlimited behavior unless separately approved. The runtime keeps the existing score-star thresholds unchanged.

## Calibration evidence

Natural production-flow trials used actual mouse launch events and did not inject terminal states:

- FULL presentation at 720×1280: objective-focused play completed the L5 and L6 orders in 22 moves with score 3,591, naturally winning and meeting the existing 3-star score threshold of 3,450.
- FULL presentation at 720×1280: dispersed/missed launches reached a natural `LOSE / MOVES_EXHAUSTED` after 35 moves while L6 remained incomplete. Real touch input retried; a second natural loss occurred at 35; real mouse input then routed to Island Map exactly once.
- REDUCED presentation at 720×1280, latest source: objective-focused play naturally completed both orders on exactly move 35, scored 4,394, and resolved to WIN (`NORMAL_OBJECTIVES_COMPLETE`). This is direct final-move WIN precedence evidence. The run used 35 actual mouse shots and then a real mouse Island Map action.
- REDUCED presentation at 720×1280, latest source: a separate route produced a natural 35-move loss, real touch Retry reset to 35, a second natural exhaustion, and real mouse Island Map route; all passed.
- An objective-oriented FULL trial at 720×1440 naturally won in 25 moves. A separate maximally dispersed trial at 720×1440 naturally exhausted at 35. The 720×1280 and 720×1440 HUD layout captures both place the counter in the clear ocean band above the playable table.

These are intentionally small, policy-stratified calibration trials, not a population success rate or proof that 35 is fair for every player. They show a 3-star completion in 22 moves with 13 moves of headroom, a separate natural completion on move 35, and unproductive routes that reach the cap. Wider owner playtesting remains necessary before assigning budgets to more levels.

## Structural recommendation method

The accompanying CSV lists all 100 Sunny Cove levels. Its planning estimate computes mandatory merge mass as `sum(quantity × 2^(cocktail_level - 1))`, estimates raw shots as `ceil(mass / (7/3))` using the L1–L3 spawn mix, and proposes `ceil(raw_shots × 1.35 + 6)`. This deliberately yields 35 for L6. It is a structural planning heuristic only: physics, opportunities to merge existing table drinks, spawn variance, strategy, and retry/player behavior affect actual moves. It does not activate any additional level limit.

## Separate move-star option for owner review

If a move-based star layer is later desired, a distinct, non-applied L6 proposal is: 3 stars at 24 moves or fewer, 2 stars at 30 or fewer, and 1 star at 35 or fewer. Keep the existing score-star thresholds and any VIP gate as-is; do not combine or substitute the measures without owner approval. No move-based star thresholds are active in this implementation.

## Recommendation

Keep 35 as the L6 candidate for independent audit and owner review. Do not activate budgets for levels 1–5 or 7–100 from the heuristic alone. The CSV marks those levels `NOT_ACTIVATED_OWNER_REVIEW`; their candidate numbers are estimates, not validated settings.
