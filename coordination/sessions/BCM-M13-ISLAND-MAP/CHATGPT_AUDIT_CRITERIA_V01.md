# BCM-M13 Island Map — Audit Criteria V01

Status: **LOCKED BEFORE EXECUTION**  
Auditor: ChatGPT  
Builder: Codex  
Branch: `main`

## Milestone objective

Implement the reusable, data-driven Island Map engine defined by M13 without implementing M14 gameplay launch/timer systems or M16 canonical Sunny Cove Level 1-100 content.

## Locked authorities

- `TASKS.md`
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- M10 accepted campaign architecture
- M11 accepted save/progression architecture
- M12 accepted World Map and `island_map_requested(island_id)` navigation boundary
- accepted R11 gameplay physics/runtime behavior
- accepted V02 brand/visual library
- accepted ten-family V2 table library

## Scope boundaries

Allowed:
- generic `IslandMapScene.tscn`;
- reusable `LevelButton.tscn`;
- Island Map controller/scripts;
- data-driven path/layout engine;
- island summary UI;
- milestone markers;
- selection/navigation signals;
- scroll/focus restoration state;
- focused M13 tests/fixtures;
- minimal navigation wiring needed to connect the existing M12 island selection boundary to Island Map.

Not allowed:
- actual gameplay session launch implementation;
- countdown timer gameplay;
- VIP runtime logic;
- booster/economy gameplay integration;
- production Sunny Cove L1-L100 content authoring;
- physics/merge/table-edge/HUD retuning;
- 100 bespoke level scenes;
- duplicated per-island IslandMap scenes/controllers.

Canonical Sunny Cove L1-L100 gameplay data remains M16.

## Gate A — Reusable scene architecture

PASS requires:
- one generic `scenes/campaign/IslandMapScene.tscn`;
- one reusable `scenes/campaign/LevelButton.tscn`;
- no per-level scene files;
- no per-island duplicated IslandMap scene/controller;
- IslandMap receives an `island_id` and uses LevelDatabase/CampaignManager state rather than hardcoded Sunny Cove progression.

## Gate B — 100-level scalability

PASS requires the same IslandMap architecture to render a fixture/configured island with **100 level nodes**.

The 100-node proof must:
- not create 100 bespoke scenes;
- use reusable LevelButton instances;
- remain mobile-scrollable at 720x1280;
- avoid horizontal clipping;
- avoid destructive node duplication after refresh/re-entry;
- expose a deterministic path/layout.

Production Sunny Cove content does not need to contain 100 authored gameplay records in M13. A deterministic test fixture may prove 100-level scalability.

## Gate C — LevelButton contract

Each reusable LevelButton must expose:
- level number;
- LOCKED / OPEN / CURRENT / COMPLETE state;
- 0-3 earned stars;
- optional milestone state/marker;
- locked selection rejection;
- level-selection event only when selectable.

State must be derived from CampaignManager/save progression rather than local button-owned progression truth.

## Gate D — Milestones

PASS requires milestone presentation support for:
- 10
- 20
- 30
- 40
- 50
- 60
- 70
- 80
- 90
- 100

Milestones are presentation/navigation metadata only in M13.
Reward-claim/economy behavior remains deferred.

## Gate E — Entry focus / scroll behavior

On Island Map entry:
- focus/scroll toward the highest currently unlocked unfinished level;
- if all configured levels are complete, focus the highest/final configured level;
- repeated refresh must not create duplicate LevelButton nodes;
- 100-node map remains usable at 720x1280.

## Gate F — Island summary

PASS requires a concise summary interface exposing at minimum:
- island display name;
- levels completed / configured level count;
- stars earned;
- next milestone;
- island completion state.

Summary values must derive from campaign/database state.

## Gate G — Selection and navigation boundaries

PASS requires:
- Island Map accepts the island id selected from M12;
- locked level selection is rejected;
- unlocked/current/completed level selection emits a bounded `level_selected(island_id, level_id)` or equivalent signal;
- M13 must not directly launch gameplay;
- back navigation emits/returns to World Map boundary;
- selected level and scroll/focus state can be restored safely after leaving and re-entering the Island Map.

## Gate H — Persistence/state preservation

PASS requires Island Map state to reflect reloaded CampaignManager/SaveManager state:
- completion;
- stars;
- highest unlocked level/current progression;
- selected/focused level where applicable.

M13 must not invent a second save authority.

## Gate I — Visual/mobile safety

PASS requires:
- 720x1280 portrait-safe layout;
- no horizontal clipping;
- touch-sized LevelButton targets;
- readable state differences;
- accepted V02/M12 visual language preserved;
- no owner-accepted asset replacement/regeneration unless explicitly necessary.

## Gate J — Regression preservation

Required focused regressions:
- M10 campaign architecture PASS;
- M11 save/migration/progression PASS;
- M12 World Map PASS;
- M13 Island Map probe PASS twice after normal clean/import bootstrap.

No R11 physics/runtime source changes.

## Gate K — Governance/write scope

PASS requires:
- Codex does not edit root `TASKS.md`;
- no M14/M16 implementation;
- no physics retuning;
- builder log committed;
- local HEAD, `origin/main`, and remote main synchronized;
- worktree clean.

## Required M13 focused test

Create:
`tests/m13_island_map_probe.gd`

It must prove at minimum:
- reusable scene loads;
- 100-level fixture renders 100 reusable nodes;
- state rendering LOCKED/OPEN/CURRENT/COMPLETE;
- stars 0-3;
- milestones at every tenth level;
- locked selection rejection;
- selectable level event boundary;
- highest-unlocked-unfinished focus;
- all-complete final focus;
- no duplicate nodes after repeated refresh;
- 720x1280 no horizontal clipping;
- summary values;
- back-navigation boundary;
- save/progression reload reflection;
- re-entry selection/scroll restoration.

Run it twice after a clean Godot 4.7 import/bootstrap with no intervening file changes. Both must PASS with exit code 0.

## Required builder log

Write:
`coordination/sessions/BCM-M13-ISLAND-MAP/CODEX_LOG_V01.md`

Include:
- start HEAD;
- implementation SHA;
- final main HEAD;
- exact changed files;
- architecture summary;
- 100-level scalability evidence;
- M13 probe run 1/run 2 exact commands and exit codes;
- M10/M11/M12 regression results;
- any warnings;
- confirmation that `TASKS.md` was untouched;
- clean/synchronized remote proof.

## Acceptance

Any material FAIL or UNVERIFIED = `CHANGES_REQUIRED`.

PASS does not authorize M14 or M16. It closes M13 only after independent ChatGPT audit.
