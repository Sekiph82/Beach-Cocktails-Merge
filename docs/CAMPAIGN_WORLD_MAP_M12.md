# Campaign World Map — M12

## Scope

M12 adds a reusable portrait World Map above the audited M10/M11 campaign
services. It presents a full-screen ocean map, a spatial route, and island
destination markers from `LevelDatabase`, with current progression from
`CampaignManager`. It does not launch gameplay and it does not implement the
future Island Map.

## Runtime pieces

- `scenes/campaign/WorldMapScene.tscn` is the reusable scene boundary.
- `scripts/campaign/world_map_controller.gd` builds the portrait map shell,
  route, and one spatial marker for every loaded island definition.
- `scenes/campaign/IslandEntry.tscn` and
  `scripts/campaign/island_entry.gd` are the reusable island-destination
  marker component.

The canonical seed data contains Sunny Cove plus nine zero-content placeholder
destinations. Their `map_asset` and `map_position` fields are presentation data;
their sequential `unlock_rule` fields are consumed by CampaignManager. Fresh
state therefore shows Sunny Cove as the only selectable destination while the
remaining route is visibly locked.

The controller asks `CampaignManager` for unlock state and locked-island
feedback. It does not copy or hardcode unlock rules. The manager also exposes
`select_island()`, progress feedback, and completion counts for campaign UI
consumers.

## Entry states and navigation boundary

Each entry renders one of `OPEN`, `LOCKED`, `CURRENT`, or `COMPLETE`.

- Fresh campaign state selects Sunny Cove as `CURRENT • OPEN`.
- Tiki Island is `LOCKED` until the canonical campaign rule is satisfied.
- Locked entries remain tappable only to show their reason/progress; they never
  emit island navigation.
- Unlocked selection emits `island_selected(island_id)` and
  `island_map_requested(island_id)`. M13 owns the receiving Island Map.
- The back control emits `return_requested` and has no gameplay side effect.

## Layout, lifecycle, and testing

The scene fills the portrait viewport with the map background, route, markers,
header, status panel, and future Island Map boundary. Marker positions come
from the loaded definitions and are checked for clipping/overlap at 720x1280.
Refresh is deferred and detaches old markers before `queue_free()`; no UI node
is immediately freed from a signal callback. The focused probe exercises
repeated Sunny Cove selection/refresh and checks for duplicate markers.

The probe uses in-memory campaign fixtures and writes only to
`user://m12_world_map_probe/reload.json` for its reload assertion; it never
opens production campaign or legacy save paths. Historical R10 probes remain
unchanged and are not referenced by the production scene or startup config;
normal M12 verification invokes only the World Map scene/probes.

GUI evidence is under `docs/evidence/m12/`:

- `world_map_fresh_720x1280.png`
- `world_map_locked_feedback_720x1280.png`
- `world_map_complete_fixture_720x1280.png`

The evidence harness uses in-memory state and does not change project
persistence semantics.

## Deferred work

Island Map, level buttons, full Sunny Cove content, campaign timer, result
flow, VIP runtime, boosters in gameplay, and all M13+ UI remain deferred.
