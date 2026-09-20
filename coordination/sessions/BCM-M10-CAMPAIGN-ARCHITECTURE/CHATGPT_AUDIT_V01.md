# BCM-M10-CAMPAIGN-ARCHITECTURE — ChatGPT Independent Audit V01

Verdict: **CHANGES_REQUIRED**

Audited implementation:
`1e6c6e8604634e2e644b0679b727c088c74f6218`

Builder log:
`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CODEX_LOG_V01.md`

Locked criteria:
`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_CRITERIA_V01.md`

## 1. Summary

The M10 architecture is well-bounded and most of the requested foundation is present without touching accepted gameplay.

However, three source-level validation/immutability gaps remain against the locked criteria. These are architecture defects, not visual/runtime issues, so owner F5 verification is not the next step.

## 2. What passes

### Scope containment

PASS:
- no World Map UI;
- no Island Map UI;
- no gameplay timer;
- no live save migration;
- no VIP runtime;
- no booster gameplay;
- no full Sunny Cove 100-level data;
- no project.godot autoload mutation;
- no accepted gameplay/physics/R11/M08/M09/HUD/reward/canonical-asset changes.

### Module boundaries

PASS:
- CampaignManager exists and does not own static definitions;
- LevelDatabase exists and owns JSON loading/lookup;
- SaveManager exposes schema/version/read/write/migration boundaries while deferring live persistence;
- GameEconomy exposes bounded coins/boosters/idempotent reward grants;
- GameplaySessionBridge resolves campaign data without rewriting gameplay.

### Seed data

PASS:
- Sunny Cove exists and is default-open;
- Tiki placeholder exists;
- Sunny Cove has two seed levels only;
- seed levels obey L5 Sunny Cove target rule and 20-second anchor;
- full 100-level data is correctly deferred.

### Baseline validations

PASS:
- duplicate island ids rejected;
- duplicate level ids rejected;
- missing required level keys rejected;
- unknown level-root island rejected;
- non-positive timer rejected;
- invalid order quantity rejected;
- L1-L12 target bound enforced.

### Regression evidence

Builder reports M01-M09 active regressions green after Godot import, plus M10 focused probe and git diff check.

No gameplay regression is visible in the audited diff.

## 3. BLOCKER 1 — unlock_rule references are not validated

The locked criteria require unresolved references to fail deterministically.

`data/campaign/islands.json` includes:

`tiki_island.unlock_rule = {"type":"requires_island_completion","island_id":"sunny_cove","level_id":100}`

But `LevelDatabase._validate_island_root()` only validates:
- required top-level island fields;
- basic type checks;
- `next_island_id` references.

It does **not** validate the nested `unlock_rule` reference.

Therefore malformed data such as:

`{"type":"requires_island_completion","island_id":"missing_island","level_id":100}`

would currently pass island validation.

That violates the required deterministic unresolved-reference validation.

### Required correction

Validate supported unlock-rule types and their required fields.

At minimum:
- `default_open` requires no foreign reference;
- `requires_island_completion` must contain a non-empty referenced `island_id` that exists;
- its `level_id` must be positive and logically compatible with the referenced island declaration.

Add a focused regression that fails the current implementation by supplying an unresolved unlock-rule island reference.

## 4. BLOCKER 2 — FULL level-count validation skips islands with zero loaded rows

Current code checks declared `level_count` only while iterating:

`for island_id in _levels_by_island`

That means an island declared with `level_count > 0` but having **zero** loaded level records never enters the loop and therefore can incorrectly pass FULL validation.

The locked criteria require inconsistent declared island level counts to be rejected in strict/full-data mode.

### Required correction

In FULL mode, iterate over every declared island, not only islands appearing in `_levels_by_island`.

Conceptually:

- expected = declared `level_count`;
- actual = loaded levels for that island, or 0 if absent;
- require actual == expected.

Add a focused test where a declared island has a positive level count but zero loaded level rows. It must fail FULL validation.

## 5. BLOCKER 3 — GameplaySessionBridge snapshot is not deeply immutable

The criteria require GameplaySessionBridge to resolve an **immutable** level definition.

Current implementation does:

`var snapshot := _active_level.duplicate(true)`
`snapshot.make_read_only()`

This makes the top-level Dictionary read-only, but nested Arrays/Dictionaries such as:
- `orders`;
- order entries;
- `rewards`;
- `score_star_thresholds`;
- `feature_flags`

remain mutable containers.

The focused probe only checks:

`session["level_definition"].is_read_only()`

which proves top-level read-only state only. It does not prove nested immutability.

The snapshot is detached from canonical data, which protects LevelDatabase state, but that is not the same as an immutable session definition.

### Required correction

Either:
1. recursively freeze nested Arrays/Dictionaries before returning the level definition, or
2. expose a truly immutable value/interface that cannot be mutated by session consumers.

Add a focused test attempting to mutate a nested order/reward structure and prove the returned session definition remains immutable.

Do not weaken the criterion to “detached copy.”

## 6. Non-blocking notes

### CampaignManager replay signal

`mark_level_completed()` emits `progression_changed` even when replay state does not improve. State remains idempotent, so this is not a closure blocker, but later UI work may prefer signaling only on actual change.

### Seed/full architecture

A single `levels_path` is sufficient for the current M10 Sunny Cove seed. Multi-island file loading can remain deferred, provided the validator itself correctly enforces declared counts/references when FULL mode is used.

## 7. Final verdict

**CHANGES_REQUIRED**

The implementation is close and the remediation should be narrow.

Do not touch gameplay.

Required V02 scope:
1. validate unlock-rule foreign references;
2. make FULL level-count validation cover all declared islands;
3. make GameplaySessionBridge level definitions deeply immutable;
4. add focused failing-before/fixed-after tests for all three;
5. rerun M01-M10 active regressions.

No owner visual/runtime verification is required for these architecture-only corrections.
