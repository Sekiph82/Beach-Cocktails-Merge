# BCM-M13 Island Map — Remediation Audit Criteria V02

Status: **LOCKED BEFORE EXECUTION**  
Auditor: ChatGPT  
Builder: Codex  
Branch: `main`

Remediate only the blockers in:
`coordination/sessions/BCM-M13-ISLAND-MAP/CHATGPT_AUDIT_V01.md`

## Frozen accepted M13 work

Preserve:
- generic IslandMapScene;
- reusable LevelButton;
- 100-node deterministic path;
- state/stars/milestone/summary behavior;
- locked selection rejection;
- no gameplay launch;
- accepted M10/M11/M12 architecture;
- R11 physics/HUD/assets;
- M16 content boundary.

## Gate A — Real M12 -> M13 navigation

PASS requires a real runtime integration path that:
- consumes `WorldMapController.island_map_requested(island_id)`;
- opens/activates the single generic IslandMapScene;
- calls/configures it with the exact selected `island_id`;
- uses the same authoritative LevelDatabase/CampaignManager instance or equivalent canonical campaign authority;
- does not duplicate campaign state;
- does not launch gameplay.

A test-only direct `IslandMapScene.instantiate()` is not sufficient.

## Gate B — M13 -> M12 back navigation

PASS requires:
- IslandMap back action returns to the World Map runtime boundary/view;
- World Map/campaign selection remains coherent;
- no duplicate map scenes/nodes after repeated WorldMap -> IslandMap -> WorldMap cycles.

## Gate C — First-entry focus

With **no restoration state**, IslandMap must explicitly focus the highest unlocked unfinished level.

The test must make CampaignManager's current selected level different from that expected focus before entering IslandMap. PASS only if IslandMap still focuses the highest unlocked unfinished level.

If all configured levels are complete, focus the final configured level.

## Gate D — Exact re-entry restoration

Restoration state must preserve and restore:
- `selected_level_id`;
- `scroll_focus_level_id`;
- actual `scroll_vertical`.

The test must:
1. enter IslandMap;
2. set/produce a non-default scroll position that differs from automatic focus position;
3. capture restoration state;
4. leave/recreate/re-enter;
5. verify selected and focus IDs;
6. verify actual restored scroll position, allowing only deterministic clamping to valid scroll bounds.

Simply recomputing scroll from focus does not satisfy this gate.

## Gate E — Bounded level-selection boundary

`level_selected(island_id, level_id)` remains a boundary only.
M14 GameplaySessionBridge/gameplay launch must not be implemented.

## Gate F — Regression

After normal Godot 4.7 import/bootstrap:
- M13 remediation probe PASS twice with no intervening file changes;
- M10 PASS;
- M11 PASS;
- M12 PASS.

No R11 physics/gameplay/HUD/accepted-asset changes.

## Gate G — Governance

- no root `TASKS.md` edit by Codex;
- no M14 implementation;
- no M16 production content;
- no 100 bespoke scenes;
- builder log committed/pushed;
- worktree clean;
- local HEAD / origin/main / remote main synchronized.

## Required test

Update `tests/m13_island_map_probe.gd` or add one bounded integration probe.

Evidence must explicitly print/assert:
- actual M12 signal opens M13 with the selected island id;
- back navigation returns to World Map;
- repeated navigation creates no duplicate map nodes;
- first-entry focus remains highest unlocked unfinished even when campaign selection is lower;
- non-default exact/clamped scroll restoration works;
- existing 100-node/state/star/milestone/summary tests still pass.

## Builder log

Write:
`coordination/sessions/BCM-M13-ISLAND-MAP/CODEX_LOG_V02.md`

Include:
- start HEAD;
- implementation SHA;
- final main HEAD;
- exact changed files;
- runtime navigation architecture;
- exact scroll restoration behavior;
- M13 run 1/run 2 results;
- M10/M11/M12 results;
- confirmation TASKS.md untouched;
- sync/clean proof.

Any material FAIL/UNVERIFIED = `CHANGES_REQUIRED`.
