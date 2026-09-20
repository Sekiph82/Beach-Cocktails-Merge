# BCM-M10-CAMPAIGN-ARCHITECTURE — ChatGPT Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

Introduce the campaign architecture and canonical data model without changing the accepted core gameplay scene, physics, scoring, R11 table-edge behavior, M08/M09 feedback, HUD layout, or canonical gameplay assets.

M10 is architecture/data-foundation work only. It must not yet implement the full World Map, Island Map, timer gameplay loop, save migration, or Sunny Cove 100-level content.

## Authoritative design references

Read and follow:
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- `docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md`

## Frozen gameplay baseline

Do not change:
- launch/deceleration;
- collider radii;
- merge/no-backward behavior;
- R11 table-edge footprint behavior;
- V05 rail coordinates;
- merge scoring/combo math;
- current To-Go reward table;
- accepted L5 -> L6 -> L7 main-scene startup test sequence;
- M08 merge/completion visuals;
- current yellow delivery trail;
- M09 feedback hooks;
- HUD placement;
- persistence/Game Over/restart;
- canonical cocktail/environment/UI/effect PNGs.

## Required module boundaries

Create clean initial runtime modules/interfaces for:

### CampaignManager
Owns runtime campaign selection/state API only.
Must expose at least:
- current island id;
- selected level id;
- level/island unlock query API;
- completion/update API placeholders that are idempotent by contract.

Do not yet own static definitions.

### LevelDatabase
Read-only canonical data loader/validator.
Must:
- load island definitions;
- load level definitions;
- validate duplicate/missing ids and unresolved references;
- expose `get_island()`, `get_level()`, `get_levels_for_island()`;
- fail deterministically on malformed data.

### SaveManager
M10 only establishes schema/API boundaries.
Do not migrate live save yet.
Must define:
- schema version;
- read/write API contract;
- atomic-write/backup intent in code/docs;
- backward-migration entry point placeholder.

### GameEconomy
M10 only establishes bounded economy API:
- booster inventory;
- coins/reward ledger;
- idempotent reward grant interface.

Do not add purchases/ads.

### GameplaySessionBridge
Boundary between campaign and existing gameplay.
Must:
- accept island_id + level_id;
- resolve immutable level definition through LevelDatabase;
- expose configuration/result interfaces;
- not yet rewrite the existing gameplay scene or physics.

## Canonical data schema

Add canonical campaign data paths:
- `data/campaign/islands.json`
- `data/campaign/levels/sunny_cove.json`

M10 data need only contain a minimal valid seed sufficient to prove schema/loader behavior, not all 100 Sunny Cove levels yet.

Island schema must support:
- id;
- display_name;
- order/index;
- level_count;
- unlock_rule;
- next_island_id;
- map/background references;
- reward-track metadata.

Level schema must support:
- island_id;
- level_id;
- time_limit_sec;
- normal orders array;
- optional VIP definition;
- rewards;
- score/star threshold placeholders;
- feature flags.

## Seed data requirements

At minimum:
- Sunny Cove island exists and is default-open;
- Tiki Island relation may be represented as next-island reference or placeholder data;
- at least 2 valid Sunny Cove levels exist so lookup/list validation is meaningful;
- seed levels must obey Sunny Cove target rules from the design docs;
- do not populate the full 100-level table yet.

## Validation requirements

LevelDatabase must reject:
- duplicate island ids;
- duplicate level ids within an island;
- missing required keys;
- unknown island references;
- non-positive time limits;
- invalid order quantities;
- cocktail targets outside allowed logical bounds;
- inconsistent declared island level count if the validator is running in strict/full-data mode.

Because M10 uses seed data, support an explicit seed/development validation mode if needed. Do not weaken production validation silently.

## Scene/project integration

Do not require a project.godot autoload mutation if it would conflict with existing dirty owner state.

Prefer modules that can be instantiated/tested directly in M10.

Any future autoload registration can be deferred to the milestone that actually launches campaign scenes.

## Tests

Add focused M10 coverage proving:
1. valid islands/levels load deterministically;
2. Sunny Cove seed is default-open;
3. get_island/get_level/get_levels_for_island work;
4. duplicate island id is rejected;
5. duplicate level id is rejected;
6. malformed level is rejected;
7. unresolved island reference is rejected;
8. module boundaries instantiate without touching gameplay scene;
9. GameplaySessionBridge resolves an immutable level definition;
10. GameEconomy duplicate reward grant is idempotent;
11. SaveManager schema/version API exists without mutating current user save;
12. M01-M09 active regressions remain green.

## Documentation

Document:
- module ownership;
- canonical data paths;
- schema fields;
- validation modes;
- what is intentionally deferred to M11+.

## Scope exclusions

Do not implement:
- World Map UI;
- Island Map UI;
- 100 level buttons;
- gameplay timer;
- campaign win/lose flow;
- live save migration;
- VIP runtime UI;
- booster gameplay;
- Sunny Cove full 100-level dataset;
- Tiki unlock runtime;
- M11+ work.

Codex must not edit `TASKS.md` or ChatGPT-owned audit/criteria files.
