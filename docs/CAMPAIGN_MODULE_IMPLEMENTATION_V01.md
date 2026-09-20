# Campaign module foundation — M10 V01

M10 adds data and API boundaries above the accepted merge-table gameplay. The
existing gameplay scene, physics, scoring, rewards, HUD, persistence behavior,
R11 table-edge implementation, M08 feedback, M09 hooks, and canonical assets
remain outside this change.

## Ownership

- `LevelDatabase` is the read-only owner of canonical island and level JSON
  loading, deterministic validation, and lookup.
- `CampaignManager` owns runtime selection and progression-state API shape. It
  does not own static definitions and does not persist state.
- `CampaignSaveManager` defines schema version 1, serialization, validation,
  and migration/persistence entry points. M10 intentionally returns a safe
  default and does not read or write the live `user://` save.
- `GameEconomy` defines the bounded coin, booster-inventory, and idempotent
  reward-ledger API. Purchases, ads, and booster gameplay are deferred.
- `GameplaySessionBridge` resolves a detached level-definition snapshot for a
  future gameplay launch. It does not configure a timer, VIP runtime, or scene.

## Canonical data

- `data/campaign/islands.json`
- `data/campaign/levels/sunny_cove.json`

Island records use `id`, `display_name`, `order_index`, `level_count`,
`unlock_rule`, `next_island_id`, `map_background`, and `reward_track`.
Level records use `island_id`, `level_id`, `time_limit_sec`, `orders`, `vip`,
`rewards`, `score_star_thresholds`, and `feature_flags`.

The seed includes Sunny Cove with two valid levels and a Tiki Island placeholder
so references are resolvable without claiming the full 100-level dataset.
Sunny Cove seed objectives remain within L5-L8 and Level 1 uses 1xL5 at 20
seconds. The declared Sunny Cove count remains 100; seed validation permits a
partial development dataset. Full validation is available through
`LevelDatabase.ValidationMode.FULL` and is intended for the complete data pass.

## Validation

The loader rejects malformed JSON/records, duplicate island IDs, duplicate
island-local level IDs, missing required fields, unresolved island references,
non-positive timers, invalid order quantities, and cocktail levels outside
L1-L12. Full mode additionally rejects a declared island count that does not
match the loaded level records.

## Deliberate M11+ boundary

World Map, Island Map, level-button UI, timer gameplay, campaign win/lose flow,
live save migration and atomic file writes, VIP runtime/UI, booster gameplay,
full Sunny Cove 100-level content, Tiki unlock runtime, autoload registration,
and later milestone work remain deferred. Future islands should be added by
data plus optional map/background assets; they should not duplicate these
services or fork the gameplay engine.
