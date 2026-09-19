# Beach Cocktails Merge — Campaign Module Technical Design

## Purpose

This document defines the low-asset campaign layer that turns the existing endless merge prototype into a structured level game without replacing the accepted core table physics.

The campaign layer has three player-facing states:

1. **World Map** — choose an unlocked island.
2. **Island Map** — progress through that island's level path.
3. **Gameplay** — run the existing merge table with level-specific objectives, timer, VIP option, and rewards.

The core merge gameplay remains the same table-driven 2D physics game. Campaign systems sit above it.

## Non-goals

The campaign layer must not require:
- customer-character scenes;
- bar renovation/decorating meta gameplay;
- animation-heavy world simulation;
- different gameplay tables per level;
- bespoke scenes for every level;
- physics retuning as a side effect of progression work.

## Runtime modules

### CampaignManager

Godot autoload/singleton responsible for:
- current island and selected level;
- island/level unlock state;
- completion state;
- stars and best level score;
- claimed milestone rewards;
- next-level / next-island resolution;
- idempotent progression updates.

CampaignManager does not own static level definitions. It reads them from LevelDatabase.

### LevelDatabase

Read-only runtime service responsible for:
- loading island definitions;
- loading level definitions;
- validating ids and references;
- exposing get_island(), get_level(), get_levels_for_island();
- rejecting malformed, duplicate, or unresolved data.

Recommended canonical data paths:

```
data/campaign/islands.json
data/campaign/levels/sunny_cove.json
data/campaign/levels/tiki_island.json
...
```

### SaveManager

Responsible for:
- schema-versioned player save;
- atomic persistence under `user://`;
- migration from existing persisted score/state;
- backup/recovery behavior;
- no silent deletion of valid progress.

### GameEconomy

Responsible for:
- booster inventory;
- coins/reward ledger;
- milestone and VIP reward grants;
- duplicate-claim protection.

Campaign completion must not depend on purchases or ads.

### GameplaySessionBridge

Boundary between campaign data and the accepted gameplay scene.

Responsibilities:
- receive island_id and level_id;
- fetch immutable level definition;
- configure timer;
- configure normal To-Go objectives;
- configure optional VIP objective;
- collect win/lose result;
- return result to CampaignManager;
- preserve accepted physics/scoring/table-edge contracts.

## Scene architecture

Recommended reusable scenes:

```
scenes/campaign/WorldMapScene.tscn
scenes/campaign/IslandMapScene.tscn
scenes/campaign/LevelButton.tscn
scenes/campaign/LevelResultPopup.tscn
```

The existing gameplay scene remains the gameplay implementation and is launched through GameplaySessionBridge.

## World Map contract

WorldMapScene is data-driven.

Each island entry supports:
- id;
- display name;
- order/index;
- level count;
- unlock rule;
- next island id;
- map/background asset references;
- OPEN / LOCKED / CURRENT / COMPLETE state.

Initial planned island sequence:

1. Sunny Cove
2. Tiki Island
3. Azure Bay
4. Coconut Beach
5. Sunset Island
6. Party Beach
7. Frozen Paradise
8. Volcano Bay
9. Billionaire Island
10. Final island, name TBD

Sunny Cove is open on a fresh save.
Tiki Island unlocks only after Sunny Cove Level 100 completion.

## Island Map contract

IslandMapScene receives an `island_id`.

It must:
- render the configured number of levels, initially 100 for Sunny Cove;
- use reusable LevelButton instances;
- show lock/current/completed state;
- show 0-3 earned stars;
- show milestone markers;
- scroll/focus to the highest unlocked unfinished level;
- preserve scroll/selection state when returning from gameplay;
- avoid 100 bespoke scenes.

A vertical mobile-friendly path is preferred. A repeated authored anchor pattern or deterministic path generator is acceptable.

Milestone levels for Sunny Cove:
10, 20, 30, 40, 50, 60, 70, 80, 90, 100.

## LevelButton contract

Each LevelButton displays:
- level number;
- locked/unlocked/current/completed state;
- 0-3 stars;
- optional milestone marker.

It emits a level-selection event only when the level is unlocked.

## Level definition schema

Minimum logical shape:

```json
{
  "level_id": 100,
  "island_id": "sunny_cove",
  "time_limit_sec": 300,
  "orders": [
    {"cocktail_level": 8, "quantity": 1},
    {"cocktail_level": 7, "quantity": 1},
    {"cocktail_level": 6, "quantity": 1},
    {"cocktail_level": 5, "quantity": 1}
  ],
  "vip": {
    "enabled": true,
    "cocktail_level": 5,
    "quantity": 1,
    "reward": {"type": "booster", "id": "upgrade", "quantity": 1}
  },
  "rewards": {
    "coins": 0
  }
}
```

VIP is optional and never part of the normal win requirement.

## Island definition schema

Minimum logical shape:

```json
{
  "id": "sunny_cove",
  "display_name": "Sunny Cove",
  "level_count": 100,
  "unlock_rule": {"type": "default_open"},
  "next_island_id": "tiki_island",
  "map_background": "res://assets/campaign/sunny_cove_map.png"
}
```

## Save schema

Minimum logical state:

```json
{
  "schema_version": 1,
  "unlocked_islands": ["sunny_cove"],
  "islands": {
    "sunny_cove": {
      "highest_unlocked_level": 1,
      "completed_levels": {},
      "claimed_milestones": []
    }
  },
  "boosters": {},
  "coins": 0
}
```

Each completed level record should be able to persist:
- stars;
- best score;
- first completion;
- VIP completion history if needed.

Replay must never lower stored best score or stars.

## Timed gameplay contract

Normal level win condition:

> Complete every normal To-Go objective before the timer reaches zero.

VIP:
- optional;
- gives a reward;
- does not prevent a normal win when incomplete.

Timer must:
- start only after gameplay is ready;
- pause with legitimate game pause;
- not drain while the app is legitimately backgrounded;
- stop immediately on win/lose resolution;
- be authoritative from one clock source.

## Result flow

Win:
- compute result;
- persist completion;
- update stars/best score;
- grant eligible rewards once;
- unlock next level;
- if Level 100, unlock next island;
- offer Next Level / Island Map.

Lose:
- do not advance progression;
- offer Retry / Island Map;
- later +Time continuation can be integrated as a booster/rewarded-ad hook.

## Stars

Stars are mastery, not a progression gate.

Initial contract:
- 1 star: normal level completed;
- 2 stars: completion plus VIP or configured mastery condition;
- 3 stars: completion plus VIP and configured score mastery.

Exact score thresholds may remain data-driven.

A player must not be forced to replay old levels perfectly to unlock the next island.

## Testing boundaries

Campaign tests must cover:
- first boot;
- unlock chain;
- locked-level selection rejection;
- normal win;
- timeout loss;
- optional VIP;
- reward idempotency;
- better/worse replay handling;
- save reload;
- corrupted/old save migration;
- Sunny Cove 100 -> Tiki Island unlock;
- preservation of accepted gameplay physics and scoring.

## Architectural rule

Adding Island N must primarily require:
- island data;
- level data;
- optional island map/background skin assets.

It must not require a duplicated campaign manager, duplicated island-map scene, or forked gameplay engine.
