# BCM-M11-SAVE-MIGRATION-PROGRESSION — ChatGPT Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

Implement persistent campaign save/migration and core progression behavior on top of the audited M10 architecture without changing accepted gameplay, physics, R11 table-edge behavior, M08/M09 feedback, HUD, scoring, or canonical assets.

## Frozen baseline

Do not change:
- core merge gameplay;
- launch/deceleration;
- collider radii;
- merge/no-backward behavior;
- R11 footprint containment;
- rail geometry;
- scoring/combo/To-Go reward tables;
- accepted L5 -> L6 -> L7 main-scene startup sequence;
- M08/M09 visual/feedback behavior;
- HUD placement;
- canonical cocktail/environment/UI/effect PNGs;
- project.godot unless strictly required and explicitly justified.

Do not start World Map/Island Map/timer/VIP runtime/full Sunny Cove 100-level work.

## SaveManager persistence

Implement real persistence under:
`user://campaign_save.json`

Requirements:
- explicit schema version;
- valid-state serialization;
- temp-file write first;
- atomic/replace-style finalization appropriate for Godot/FileAccess;
- backup of last known good save;
- failed writes must not silently destroy the last valid save;
- read path must distinguish missing, valid, malformed and unsupported-version saves;
- return structured status/reason information.

## Recovery behavior

### Missing save
Return a fresh default campaign state.

### Malformed/partial primary save
Attempt recovery from last known good backup.

If backup is valid:
- recover from backup;
- surface that recovery occurred;
- do not silently discard valid backup progress.

If no valid backup exists:
- return a safe default;
- surface recovery/fallback reason.

### Unsupported/older schema
Use migration entry point rather than silently accepting incompatible data.

## Legacy best-score migration

The existing gameplay persists best score in:
`user://save.cfg`

M11 must preserve that legacy best-score data.

Requirements:
- read legacy best score without modifying/deleting the old save;
- migrate/copy the value into campaign-aware state in a clearly named legacy/global field or documented migration slot;
- migration must be idempotent;
- repeated loads must not duplicate or inflate values;
- if campaign state already contains a higher migrated/global best, preserve the higher value.

Do not rewrite the existing gameplay best-score save behavior in this milestone.

## CampaignManager progression

Implement/complete APIs for:
- island unlock query;
- level unlock query;
- mark level completed;
- replay with best score/stars preserved;
- next-level resolution;
- sequential unlock of next level;
- island completion detection;
- next-island unlock according to canonical unlock_rule;
- milestone/reward-claim state hooks;
- idempotent one-time progression updates.

State updates must be deterministic and derived from LevelDatabase definitions.

## Idempotency

Replaying an already-completed level must not:
- duplicate island unlocks;
- duplicate level unlocks;
- duplicate one-time reward/milestone claims;
- lower best score;
- lower stars.

Signals/events should preferably fire only when state materially changes.

## Save/progression integration

Provide a clean orchestration path so campaign state can:
1. load through SaveManager;
2. configure CampaignManager;
3. update progression;
4. serialize/write back;
5. reload and reproduce the same state.

Do not require campaign UI scenes yet.

## Tests

Add focused M11 coverage for:
1. first boot with no save;
2. valid write/read round-trip;
3. backup creation;
4. malformed primary with valid backup recovery;
5. malformed primary + malformed/missing backup safe fallback;
6. unsupported version path;
7. legacy save.cfg best-score migration;
8. migration idempotency;
9. completion unlocks next level;
10. replay preserves higher stars/best score;
11. replay does not duplicate one-time state;
12. completing final level unlocks next island according to rule;
13. persisted progression reloads identically;
14. failed/invalid write does not destroy previous valid state;
15. M01-M10 active regressions remain green.

Use isolated user:// test paths / temporary directories so tests never mutate the owner's actual save files.

## Documentation

Document:
- save files and backup names;
- write/recovery algorithm;
- schema/migration behavior;
- legacy best-score handling;
- idempotency rules;
- what remains deferred to M12+.

## Scope exclusions

Do not implement:
- World Map;
- Island Map;
- level buttons;
- campaign gameplay timer;
- result popups;
- VIP runtime;
- boosters in gameplay;
- full 100-level Sunny Cove data;
- M12+ UI work.

Codex must not edit `TASKS.md` or ChatGPT-owned audit/criteria files.
