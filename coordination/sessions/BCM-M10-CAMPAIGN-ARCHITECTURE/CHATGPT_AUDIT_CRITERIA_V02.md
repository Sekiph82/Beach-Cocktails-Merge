# BCM-M10-CAMPAIGN-ARCHITECTURE — ChatGPT Audit Criteria V02

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

Remediate only the three M10 V01 audit blockers without changing accepted gameplay or expanding M10 scope.

Read:
- `coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_V01.md`
- V01 criteria/prompt
- current implementation/log

## Frozen baseline

Do not change:
- core gameplay scene;
- physics;
- R11 table-edge behavior;
- rails/colliders;
- scoring/reward data;
- M08/M09 feedback;
- HUD;
- canonical gameplay assets;
- project.godot;
- World Map/Island Map/timer/VIP/live-save/full-100-level scope.

## Required remediation 1 — unlock_rule validation

LevelDatabase must validate supported island unlock rules.

At minimum:

### default_open
- valid without a foreign island reference.

### requires_island_completion
Must require:
- non-empty `island_id`;
- referenced island exists;
- positive `level_id`;
- referenced `level_id` does not exceed the referenced island's declared `level_count` when that count is positive.

Reject:
- unknown unlock-rule type;
- missing referenced island;
- non-positive required level;
- required level beyond declared source-island range.

Add focused negative tests.

## Required remediation 2 — FULL count validation across all declared islands

In `ValidationMode.FULL`:
- iterate every declared island;
- actual loaded level count defaults to 0 when no rows exist;
- require actual == declared `level_count`.

Add a focused test proving that an island declaring a positive count but having zero loaded rows fails FULL validation.

Do not silently treat missing islands as valid full data.

## Required remediation 3 — deeply immutable session definitions

GameplaySessionBridge must return a level definition that cannot be mutated through nested containers.

Top-level `Dictionary.make_read_only()` alone is insufficient.

Use a recursive freeze/deep-read-only implementation or an equivalent immutable representation.

The returned immutable session definition must cover nested:
- orders array;
- order dictionaries;
- VIP dictionary if present;
- rewards;
- score/star thresholds;
- feature flags;
- any future nested container copied into the definition.

Add a focused test proving nested containers are read-only / mutation-resistant.

Also preserve detachment from LevelDatabase canonical state.

## Tests

Add/extend focused tests proving:
1. unresolved unlock-rule island reference fails;
2. unsupported unlock-rule type fails;
3. invalid required completion level fails;
4. FULL validation catches a declared positive-count island with zero loaded rows;
5. session top-level and nested Arrays/Dictionaries are immutable;
6. canonical LevelDatabase data remains unchanged after consumer access;
7. all prior M10 validations still pass;
8. M01-M09 active regressions remain green.

## Scope

This is a narrow architecture remediation only.

Codex must not edit `TASKS.md` or ChatGPT-owned audit/criteria files.
