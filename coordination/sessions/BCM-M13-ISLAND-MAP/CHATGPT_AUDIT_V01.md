# BCM-M13 Island Map — Independent Audit V01

Verdict: **CHANGES_REQUIRED**

Auditor: ChatGPT  
Builder: Codex  
Branch: `main`  
Audited start HEAD: `b2264dfda91678b37acd1155231fa43c53726de2`  
Implementation SHA: `ca0e347e191beb4dc0a3b5ec0c097c769102eb18`  
Audited builder final HEAD: `14a696dc41628b88d79e6c41a8bb67bea5716552`

Locked criteria:
`coordination/sessions/BCM-M13-ISLAND-MAP/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-M13-ISLAND-MAP/CHATGPT_EXECUTION_PROMPT_V01.md`

Builder log:
`coordination/sessions/BCM-M13-ISLAND-MAP/CODEX_LOG_V01.md`

## 1. Verdict

**CHANGES_REQUIRED.**

Most M13 architecture is implemented correctly and the focused/regression probes pass, but two locked contract requirements are not actually satisfied:

1. the M12 World Map selection boundary is not wired into a real Island Map runtime navigation path;
2. exact scroll restoration is recorded but not restored, and the focused probe does not test it.

M14 must not begin.

## 2. Diff / scope audit

Independent compare from `b2264df...` to `14a696d...` contains exactly two commits and only:
- `scenes/campaign/IslandMapScene.tscn`
- `scenes/campaign/LevelButton.tscn`
- `scripts/campaign/island_map_controller.gd`
- `scripts/campaign/level_button.gd`
- `tests/m13_island_map_probe.gd`
- builder log

No R11 physics, gameplay/HUD, M14, M16, production level data, accepted visual assets, or root `TASKS.md` were modified by Codex.

Scope discipline: **PASS**.

## 3. Acceptance matrix

| Gate | Result | Independent finding |
| --- | --- | --- |
| A. Reusable scene architecture | **PASS** | One generic IslandMapScene and one LevelButton scene; no per-level/per-island duplication. |
| B. 100-level scalability | **PASS** | Fixture renders 100 reusable nodes using deterministic two-column vertical layout. |
| C. LevelButton contract | **PASS** | LOCKED/OPEN/CURRENT/COMPLETE, 0-3 stars, milestones, locked rejection and bounded selection are implemented. |
| D. Milestones | **PASS** | 10/20/.../100 supported via reward_track or default tenth-level milestones. |
| E. Entry focus / scroll behavior | **PARTIAL / FAIL** | Focus behavior passes current fixture, but restoration does not restore actual saved scroll position. |
| F. Island summary | **PASS** | Display name, completed/total, stars, next milestone and completion state derive from campaign/database state. |
| G. Selection/navigation boundaries | **FAIL** | IslandMap emits safe boundaries, but no runtime consumer connects M12 `island_map_requested(island_id)` to IslandMapScene. |
| H. Persistence/state preservation | **PARTIAL** | Progress/stars reload correctly. Selected/focus IDs restore, but saved `scroll_vertical` is ignored. |
| I. Visual/mobile safety | **PASS at source/probe level** | 720x1280 no horizontal clipping; 116x112 touch targets; readable state styling; no visual assets replaced. |
| J. Regression preservation | **PASS** | Builder evidence: M13 twice PASS; M10/M11/M12 PASS after normal import bootstrap. |
| K. Governance/write scope | **PASS** | TASKS untouched by Codex; no M14/M16/physics scope expansion. |

## 4. Blocking finding A — M12 -> M13 runtime navigation is not integrated

M12 established:
`WorldMapController.island_map_requested(island_id)`

The M13 execution prompt explicitly required:
- honor that existing boundary;
- add the smallest navigation integration required so the selected island id configures the generic Island Map.

Current repository truth:
- `world_map_controller.gd` still emits `island_map_requested(island_id)`;
- M13 implementation added only the new IslandMap scene/controller/button/test;
- no existing runtime scene/controller was modified to consume the M12 signal;
- `scenes/main.tscn` and `scripts/game_manager.gd` contain no WorldMap/IslandMap campaign navigation integration;
- the M13 probe calls `IslandMapScene.instantiate()` and `configure_island(...)` directly.

Therefore the generic Island Map exists, but the actual M12 selection boundary does not navigate to it.

This fails locked Gate G.

## 5. Blocking finding B — saved scroll position is not restored

`IslandMapController.get_restoration_state()` returns:
- `selected_level_id`
- `scroll_focus_level_id`
- `scroll_vertical`

But:
- `configure_island()` reads selected and focus IDs only;
- `restore_state()` reads selected and focus IDs only;
- `_apply_focus()` recalculates scroll position from focus;
- saved `scroll_vertical` is never reapplied.

The focused probe checks:
- selected level restored;
- focus level restored.

It does **not** modify scroll position, persist it, remount, and assert restored `scroll_vertical`.

Thus the test does not satisfy the locked requirement:
`re-entry selection/scroll restoration`.

This fails/under-verifies Gates E and H.

## 6. Additional test-quality finding — auto-focus proof is fixture-coupled

Locked behavior says first Island Map entry focuses the highest currently unlocked unfinished level.

Current CampaignManager configuration automatically sets `selected_level_id` to the highest unlocked level. `configure_island()` then copies that selection into `_focus_level_id`.

The probe expects Level 6 and receives Level 6, but does not prove that IslandMap independently computes highest-unlocked-unfinished focus when the campaign's current selection points somewhere else.

The remediation test must deliberately select a lower unlocked level before first Island Map entry and still prove initial focus chooses the highest unlocked unfinished level when no restoration state exists.

This prevents a false-green test.

## 7. What passed and must be preserved

Preserve unchanged unless necessary for the bounded fix:
- generic IslandMapScene architecture;
- reusable LevelButton;
- 100-node fixture scalability;
- deterministic mobile-safe path;
- level state rendering;
- 0-3 stars;
- milestone presentation;
- summary;
- locked selection rejection;
- level selection remains a signal boundary and does not launch gameplay;
- M10/M11/M12 regression behavior;
- no M14/M16 implementation;
- no R11 physics/HUD/asset changes.

## 8. Required remediation

1. Add the smallest real runtime navigation integration that consumes M12 `island_map_requested(island_id)` and opens/configures the generic IslandMapScene with that exact island id and the same campaign/database authority.
2. Wire IslandMap back navigation to return to the World Map boundary/state without launching gameplay.
3. Preserve the bounded `level_selected(island_id, level_id)` signal only; M14 remains deferred.
4. Make restoration distinguish first entry from re-entry:
   - first entry with no restoration must explicitly choose highest unlocked unfinished;
   - re-entry must restore selected level, focus level and saved/clamped `scroll_vertical`.
5. Extend M13 probe to prove actual M12->M13->M12 navigation integration.
6. Extend M13 probe to set a non-default manual scroll position, persist restoration state, recreate/re-enter the map and verify actual scroll restoration.
7. Strengthen first-entry focus proof by making campaign selection differ from the expected highest-unlocked-unfinished level.
8. Run M13 twice after clean import plus M10/M11/M12 regressions.
9. Do not edit root `TASKS.md`; stop for independent audit.

## 9. Final verdict

**CHANGES_REQUIRED**

M13 remains open.
