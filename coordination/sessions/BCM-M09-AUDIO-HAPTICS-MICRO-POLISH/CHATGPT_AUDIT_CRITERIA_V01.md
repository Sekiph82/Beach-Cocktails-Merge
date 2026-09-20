# BCM-M09-AUDIO-HAPTICS-MICRO-POLISH — ChatGPT Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

Add bounded audio, optional haptics and micro-polish while preserving all accepted gameplay, physics, R11 table-edge behavior, M08 visual effects and HUD layout.

This round also carries one explicit owner-requested runtime sequencing change:
the first three live To-Go targets in the main game must be deterministic **L5 -> L6 -> L7** so M08 delivery-trail visibility can be verified quickly in normal play.

## Frozen baseline

Do not change:
- launch speed 700 px/s;
- deceleration 180 px/s²;
- drink-to-drink collider radii;
- merge momentum/no-backward rules;
- R11 table-edge footprint solution;
- V05 rail coordinates;
- merge scoring/combo math;
- existing To-Go reward table;
- stored-drink fulfillment semantics;
- BEST SCORE / SCORE / NEXT / To-Go / held layout;
- canonical cocktail/environment/UI/effect PNGs;
- persistence, Game Over, restart;
- accepted M08 merge feedback;
- accepted M08 completion-panel flash.

No guide line.

## Owner-requested To-Go startup sequence

Implement a deterministic first-three order sequence in the normal main gameplay flow:

1. first target = L5;
2. second target = L6;
3. third target = L7.

After those three targets are completed, resume the existing normal target-selection behavior unless a later campaign system overrides it.

Important:
- do not invent a new L5 reward in this task;
- preserve the existing `order_reward` data exactly;
- L5 currently has reward 0 and may therefore display/pay 0;
- do not alter stored-drink scoring semantics;
- this sequencing change is intentionally owner-directed and supersedes the old "first target L6" startup rule.

Add a focused test proving the first three targets are exactly 5, 6, 7 and that normal selection resumes afterward.

## M08 carry-forward verification

Do not retune the already accepted merge feedback or completion flash.

Preserve the current yellow To-Go trail implementation unless a source-level bug is found.

The L5/L6/L7 startup sequence exists partly so the owner can observe the trail quickly in a real normal game.

## Audio

Add lightweight hooks for:
- merge;
- To-Go/order complete;
- level/game success/fail hooks only where an existing event already exists and no campaign system is required;
- basic UI tap/confirm only if a safe existing interaction point exists.

Requirements:
- no audio may change game timing or state;
- no duplicate sound on duplicate callbacks;
- missing audio asset/device must fail safely;
- do not redesign gameplay around sound.

If no appropriate canonical audio assets exist, implement clean hooks/interfaces/placeholders without adding low-quality/generated sounds.

## Haptics

Add optional haptic hooks for:
- merge;
- To-Go completion;
- fail/success where appropriate.

Requirements:
- default-safe behavior on desktop/unsupported platforms;
- haptics may be enabled/disabled through one runtime setting or placeholder setting API;
- no crash/error if unsupported;
- no vibration spam during rapid merges;
- haptics must never alter gameplay state.

## Micro-polish

Keep micro-polish restrained and non-blocking.
Do not add large animations, camera shake, physics impulses or screen-obscuring effects.

## Tests

Add focused coverage for:
1. first three To-Go targets are L5, L6, L7;
2. fourth+ target returns to normal selection behavior;
3. L5 reward table remains unchanged;
4. merge audio/haptic hook fires at most once per merge;
5. To-Go completion audio/haptic hook fires at most once per completion;
6. disabling haptics prevents haptic calls;
7. unsupported platform path is a safe no-op;
8. no-input/rapid-launch regressions remain intact;
9. M08 visual effect cleanup remains intact;
10. R11 boundary behavior remains intact;
11. M01-M08 active regressions remain green.

## Visual/runtime acceptance

Owner must verify:
- M08 yellow delivery trail can now be observed using the early L5/L6/L7 targets;
- merge/completion visuals remain as previously accepted;
- no new HUD/table/layout shift;
- audio/haptics feel restrained if runtime hardware supports them.

## Scope

Do not start campaign architecture or M10 work.

Codex must not edit TASKS.md or ChatGPT-owned criteria/audit files.
