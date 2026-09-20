# BCM-M12-WORLD-MAP — ChatGPT Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

Create the reusable campaign World Map UI on top of the audited M10/M11 data, save, and progression architecture without changing accepted core gameplay.

M12 is the first campaign-facing UI milestone.

## Authoritative references

Read and follow:
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- `coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_V02.md`
- `coordination/sessions/BCM-M11-SAVE-MIGRATION-PROGRESSION/CHATGPT_AUDIT_V01.md`

## Frozen gameplay baseline

Do not change:
- core gameplay scene physics;
- launch/deceleration;
- collider radii;
- merge/no-backward behavior;
- R11 table-edge containment;
- rail geometry;
- scoring/combo/To-Go reward table;
- accepted L5 -> L6 -> L7 main-game startup sequence;
- M08/M09 feedback behavior;
- existing HUD placement;
- canonical cocktail/environment/UI/effect assets;
- current save/progression semantics.

Do not start Island Map/100-level path/timed campaign gameplay.

## Required World Map architecture

Create a reusable data-driven World Map scene and script.

Recommended paths:
- `scenes/campaign/WorldMapScene.tscn`
- `scripts/campaign/world_map_controller.gd`

Equivalent clean paths are acceptable.

The scene must consume LevelDatabase + CampaignManager state rather than hardcoding progression logic.

## Island representation

Render campaign islands from canonical island definitions.

At minimum the current canonical data must visibly represent:
- Sunny Cove;
- Tiki Island placeholder.

Each island entry must support these semantic states:
- OPEN;
- LOCKED;
- CURRENT;
- COMPLETE.

The visual treatment may use restrained temporary/procedural UI if dedicated map assets do not yet exist.

Do not invent polished permanent island art if canonical assets are absent.

## Unlock behavior

Fresh/default state:
- Sunny Cove selectable/open;
- Tiki Island locked.

Tiki Island must remain unselectable until CampaignManager says its unlock rule is satisfied.

The World Map must never duplicate unlock-rule logic independently.

## Navigation contract

World Map must expose:
- island-selected signal/callback;
- selected island id;
- navigation boundary for opening the future Island Map;
- back/return action boundary if applicable.

Because M13 owns the Island Map, M12 may route selection into a placeholder transition/callback rather than implement IslandMapScene.

Do not silently launch gameplay directly from World Map.

## Locked island feedback

Selecting/tapping a locked island must:
- not navigate;
- expose a concise locked reason/progress state;
- remain input-safe;
- avoid fake completion/progression changes.

## Scalability

Architecture/layout must be data-driven for the planned island list and must not require one bespoke scene per island.

Demonstrate that the same entry component/layout can handle at least 10 island definitions structurally, even though only current canonical seed islands need production data now.

## Mobile layout

Target portrait mobile layout.

Requirements:
- no horizontal clipping at 720x1280 reference;
- tappable island entries;
- text readable;
- scroll/pan/container behavior appropriate if content exceeds viewport;
- no overlap with navigation controls.

## Save reload integration

World Map state must be reconstructible from:
- LevelDatabase;
- reloaded CampaignManager progression state.

A reload must reproduce OPEN/LOCKED/CURRENT/COMPLETE states without scene-specific persistence.

## Tests

Add focused M12 coverage proving:
1. WorldMapScene loads;
2. island entries are generated from LevelDatabase, not hardcoded count;
3. Sunny Cove renders/selects as open on fresh state;
4. Tiki renders locked on fresh state;
5. locked Tiki selection does not emit navigation;
6. locked reason/progress feedback appears;
7. unlocked island selection emits the correct island id;
8. COMPLETE state is derived from CampaignManager completion;
9. CURRENT state is derived from campaign selection/progression;
10. state reconstructs after SaveManager round-trip/reload;
11. generated layout can structurally handle 10 island definitions;
12. 720x1280 reference layout has no clipping/overlap according to deterministic geometry probe;
13. M01-M11 active regressions remain green.

## Visual evidence

Provide normal GUI 720x1280 screenshots for:
- fresh World Map with Sunny Cove open / Tiki locked;
- locked-island feedback;
- an unlocked/complete-state test fixture if practical.

Builder screenshots are evidence only. Final visual acceptance remains owner/ChatGPT audit.

## Scope exclusions

Do not implement:
- IslandMapScene;
- 100 level buttons;
- gameplay timer;
- campaign win/lose flow;
- VIP runtime;
- full Sunny Cove 100-level data;
- Tiki gameplay;
- M13+ work.

Codex must not edit `TASKS.md` or ChatGPT-owned criteria/audit files.
