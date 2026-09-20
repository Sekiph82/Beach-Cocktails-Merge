# Campaign save and progression — M11

M11 adds persistence above the accepted merge-table gameplay. It does not
change gameplay physics, scoring, rewards, HUD, assets, or the legacy
`user://save.cfg` writer.

## Files and schema

The production campaign files are:

- `user://campaign_save.json` — current campaign state.
- `user://campaign_save.json.bak` — the last known-good primary state.
- `user://campaign_save.json.tmp` — short-lived temporary write file.
- `user://save.cfg` — legacy gameplay `ConfigFile`; M11 reads its
  `records/best` value but never rewrites or deletes it.

The campaign schema is version `2`. The root includes `schema_version`,
`unlocked_islands`, `islands`, `legacy_best_score`, `boosters`, and `coins`.
Each island state contains `highest_unlocked_level`, `completed_levels`, and
`claimed_milestones`. `legacy_best_score` is the clearly named migration slot
for the old global best score.

## Write and recovery algorithm

`SaveManager.write_state()` validates the complete state, serializes it, writes
the bytes to the `.tmp` path, flushes and closes that file, copies a valid
existing primary to `.bak`, and replaces the primary with the temporary file.
An invalid primary is never copied over a valid backup. If validation, backup,
or replacement fails, the old primary remains in place and the temporary file
is removed.

`SaveManager.load_state()` returns a structured result with `ok`, `status`,
`reason`, `source`, `legacy_migrated`, and `state` fields:

- missing primary and backup -> fresh default state with `status = missing`;
- valid primary -> current state with `status = valid`;
- malformed/partial primary plus valid backup -> backup state with
  `status = recovered`, then a safe primary repair is attempted;
- no valid candidate -> fresh default with `status = fallback`;
- a future schema without a valid backup -> fresh default with
  `status = unsupported`.

The caller can inspect the reason even when a safe default is returned; valid
progress is never silently discarded.

## Schema migration

The migration entry point converts schema `1` (the M10 campaign boundary) to
schema `2` by adding the legacy score slot and any newly required empty
collections. Older or unsupported versions that cannot be converted are
rejected and go through backup recovery/fallback. Successfully migrated state
is persisted through the same guarded write path.

## Legacy best-score migration

On campaign load, `SaveManager` reads `records/best` from `user://save.cfg`.
The value is copied to `legacy_best_score` only when it is greater than the
campaign value already stored. The legacy file is never modified. Repeated
loads therefore do not duplicate or inflate the score, and a higher campaign
value is preserved.

## Progression and idempotency

`CampaignManager` receives loaded state and a read-only `LevelDatabase`.
Completion updates the level record using the maximum of existing and replay
stars/score, unlocks only the next sequential level, evaluates the canonical
island `unlock_rule`, and exposes next-level/next-island resolution. Completion
of a final defined level unlocks the rule-approved next island. Milestones are
explicitly claimable and stored once; duplicate claims and worse replays leave
state unchanged and do not emit a progression change signal.

The orchestration boundary is:

1. load structured state through `SaveManager`;
2. configure `CampaignManager` with `result.state`;
3. apply completion/replay/claim operations;
4. write `get_progression_state()` through `SaveManager`;
5. reload and configure a new manager from the persisted state.

## Test isolation and deferred work

`tests/m11_save_migration_progression_probe.gd` passes explicit paths under
`user://m11_save_probe/` for every campaign and legacy file. It never opens
the production `user://campaign_save.json`, `user://campaign_save.json.bak`,
or `user://save.cfg` paths. The probe covers first boot, round-trip writes,
backup/recovery, malformed and unsupported saves, schema and legacy migration,
idempotent replay/progression/milestones, failed writes, and reload equality.

World Map, Island Map, level-button UI, timed gameplay, result popups, VIP
runtime, boosters in gameplay, and full Sunny Cove content remain deferred to
later milestones.
