# BCM-M08-TO-GO-DELIVERY-POLISH — ChatGPT Independent Audit V01

Verdict: **SOURCE_AUDITED_PASS / OWNER_RUNTIME_VERIFICATION_REQUIRED**

Audited implementation:
`5b0f52e2dfe4fa7f78e3dc8d58dde37b586d05a7`

Builder log:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CODEX_LOG_V01.md`

Locked criteria:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_CRITERIA_V01.md`

## 1. VERDICT

Source, diff scope, focused test design and reported regressions satisfy the locked M08 contract.

Final M08 closure is still blocked on owner runtime visual verification because this milestone is materially visual and the committed PNG evidence could not be independently inspected as image pixels through the available repository connector in this audit.

## 2. CONTRACT RECOVERY

M08 was required to add bounded visual polish only:
- restrained To-Go delivery feedback;
- short order-completion feedback;
- short merge feedback;
- cleanup-safe lightweight effects;

while freezing accepted gameplay, R11 table-edge behavior, physics, scoring, HUD placement and canonical assets.

## 3. BRANCH / HEAD / DIFF SCOPE

Implementation commit changes only:
- `scripts/game_manager.gd`;
- focused M08 test;
- three M08 evidence screenshots;
- M08 evidence README.

No gameplay-physics file, cocktail asset, UI asset, table geometry file, score table or R11 footprint implementation is changed by the M08 implementation commit.

## 4. ACCEPTANCE CRITERIA MATRIX

- Existing To-Go collection destination preserved: **PASS**
- Existing delivery tween semantics preserved: **PASS**
- Delivery trail added: **PASS**
- Delivered drink removed once: **PASS**
- Reward paid once: **PASS**
- Stored delivery does not re-award merge/combo points: **PASS**
- Target transition returns to idle and selects next target: **PASS**
- Completion feedback added without panel relocation: **PASS**
- Merge feedback added without changing merge logic: **PASS**
- Effects self-clean: **PASS**
- Duplicate collection callback protection: **PASS**
- Canonical assets not modified: **PASS**
- No M09 audio/haptics started: **PASS**
- Runtime visual quality / restraint: **UNVERIFIED pending owner**
- HUD/table visual preservation: **UNVERIFIED pending owner**

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH

The diff confirms that M08 does not rewrite reward, target eligibility, stock-delivery or scoring rules.

The existing `_collect_merge_target()` flow remains authoritative. M08 adds:
- `_spawn_to_go_trail(...)` immediately after target capture begins;
- constantized 0.34 s delivery duration;
- `_order_completion_feedback()` after collection finishes;
- a `MergeFeedback` root containing the existing procedural flash plus canonical merge glow.

The existing `_target_transition` guard remains the exactly-once gate for duplicate collection requests.

## 6. FILE / SYMBOL EVIDENCE

### To-Go delivery

`_spawn_to_go_trail()`:
- uses existing `assets/effects/to_go_trail.png`;
- aligns from drink to To-Go destination;
- uses alpha/scale tween only;
- queues itself free after the effect;
- does not alter drink physics, collision or reward logic.

### Order completion

`_order_completion_feedback()`:
- creates a temporary `ColorRect` inside the existing To-Go panel;
- does not move or resize the accepted panel;
- removes any prior temporary flash before creating another;
- self-cleans after the tween.

### Merge feedback

`_juice_effect()`:
- preserves the prior procedural flash;
- adds existing `merge_glow.png`;
- groups both under `MergeFeedback`;
- self-cleans the effect root;
- does not touch merge position, merge level or merge momentum code.

## 7. FOCUSED TEST EVIDENCE

`tests/m08_to_go_delivery_probe.gd` directly exercises production entry points and asserts:
- merge feedback creation and cleanup;
- merge result level/position/momentum contract;
- target capture once;
- delivery trail creation;
- drink removal once;
- reward addition once;
- target transition completion;
- no merge/combo re-award for stored delivery;
- completion feedback creation and cleanup;
- duplicate collection request paying once.

The builder reports `M08_TO_GO_DELIVERY_RESULT=PASS`.

The test does not replace visual acceptance; it correctly verifies state/economy/cleanup behavior.

## 8. REGRESSION EVIDENCE

Builder evidence reports PASS for:
- M01;
- M02;
- M03;
- M04;
- M05;
- M07 HUD composition;
- M07 owner-layout probe;
- R09 no-input runtime;
- R10 desktop idle;
- production parse/check;
- Godot import/startup;
- `git diff --check`.

The old R10 V10 negative reproduction still exits nonzero. It is historical/superseded and is reported truthfully rather than relabeled.

## 9. SECURITY / SAFETY REVIEW

No secrets, external downloads, machine-specific configuration, project settings or destructive changes are introduced.

## 10. ARCHITECTURE CONSISTENCY

The effect implementation is appropriately lightweight:
- Sprite2D / ColorRect / Polygon2D;
- Tween-based;
- short-lived;
- no new gameplay state machine;
- no collision changes;
- no persistent effect manager required.

This fits the mobile-polish scope.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS

Codex did not edit `TASKS.md` or ChatGPT-owned criteria/audit files.

The log correctly distinguishes builder visual inspection from independent acceptance.

## 12. DEFECTS BY SEVERITY

- BLOCKER: none in source.
- MAJOR: none in source.
- MINOR: none currently blocking owner test.
- NOTE: final visual restraint and composition cannot be concluded from source/test assertions alone.

## 13. UNVERIFIED ITEMS

Material visual acceptance remains pending:
- whether the delivery trail looks restrained rather than oversized/bright;
- whether merge glow reads cleanly and does not obscure nearby drinks;
- whether order-completion flash fits the accepted To-Go board;
- whether HUD/table composition remains visually unchanged during effects.

These require owner runtime inspection in normal Godot GUI.

## 14. REGRESSION RISK

**LOW to MEDIUM.**

Source changes are bounded and visual-only, but final visual quality is inherently runtime-dependent.

## 15. AUDIT CONFIDENCE

**HIGH** for source/state behavior.
**PENDING OWNER** for visual acceptance.

## 16. FINAL VERDICT

**SOURCE_AUDITED_PASS / OWNER_RUNTIME_VERIFICATION_REQUIRED**

Run the normal Godot game and visually verify:
1. merge feedback;
2. To-Go delivery trail;
3. order completion flash;
4. HUD/table unchanged;
5. no distracting effect stacking during normal play.

If owner accepts the runtime result, M08 can close without another code change.


## Owner runtime visual verification — 2026-09-20

Owner tested M08 in the normal fast-paced game runtime.

Observed:
- To-Go order-completion panel flash is clearly visible and accepted.
- Merge feedback is not perceptible during normal gameplay.
- To-Go yellow delivery trail is not perceptible during normal gameplay.
- No HUD, table, desktop/layout shift or other visual displacement was observed.

### Consequence

M08 is **not yet visually complete**.

The two core transient effects technically exist and self-clean, but their current presentation does not survive the actual gameplay tempo. A visual effect that is effectively invisible during normal play does not satisfy the communication goal of the locked criteria.

The completion flash may be preserved as-is.

Required remediation:
- make merge feedback perceptible without becoming large, noisy, or screen-blocking;
- make To-Go delivery trail perceptible without slowing or changing gameplay;
- preserve all accepted gameplay timing and physics;
- do not lengthen the actual merge/delivery mechanics solely to expose the effects;
- prefer effect persistence, alpha/scale/easing, layering, or brief afterglow over changing gameplay speed.

Revised final state: **CHANGES_REQUIRED — VISUAL REMEDIATION ONLY**.
