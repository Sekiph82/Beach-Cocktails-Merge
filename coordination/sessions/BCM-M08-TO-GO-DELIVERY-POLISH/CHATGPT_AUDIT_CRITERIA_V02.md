# BCM-M08-TO-GO-DELIVERY-POLISH — ChatGPT Audit Criteria V02

Status: LOCKED BEFORE IMPLEMENTATION

## Purpose
Make the already-implemented M08 transient effects perceptible during normal fast-paced gameplay without changing gameplay speed, physics, scoring, table-edge behavior, HUD layout, or canonical assets.

## Preserve as-is
- To-Go order-completion panel flash, which owner can clearly see and accepts.
- R11 table-edge behavior.
- V05 rails.
- launch/deceleration.
- collider radii.
- merge momentum.
- scoring/combo/To-Go logic.
- target collection timing and reward logic.
- HUD/table layout.
- canonical assets.
- no audio/haptics yet.

## Owner runtime problem to solve
Current merge feedback and To-Go yellow trail technically exist but are effectively invisible during normal gameplay because the game is fast.

Do not slow the game or extend gameplay mechanics just to expose effects.

## Required visual remediation
### Merge feedback
Make merge confirmation visible at normal play speed by tuning only visual presentation, such as:
- slightly longer afterglow persistence;
- stronger initial alpha;
- slightly larger but still restrained glow;
- brief secondary fade ring/spark;
- better z-order if needed.

It must remain lightweight and must not obscure nearby drinks.

### To-Go delivery trail
Make the trail visible during normal play by tuning only the effect, such as:
- brighter initial alpha;
- thicker trail;
- short afterglow that outlives the moving drink;
- better layering;
- easing/fade adjustment.

Do not lengthen the actual 0.34 s delivery mechanic solely for visibility.

## Acceptance
Owner must be able to notice:
1. merge feedback in normal play without deliberately watching for it;
2. delivery trail in normal play without slowing gameplay;
3. existing completion flash still looks correct;
4. HUD/table stays unchanged;
5. no effect stacking becomes noisy.

## Tests
Preserve existing M08 state/economy/cleanup assertions.
Add focused timing/cleanup checks for any longer-lived visual nodes.
Run active regressions.

Codex must not edit TASKS.md or ChatGPT-owned criteria/audit files.
