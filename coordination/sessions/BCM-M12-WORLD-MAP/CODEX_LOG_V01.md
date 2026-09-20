# BCM-M12-001 — Codex Execution Log V01

Status: AWAITING_AUDIT  
Work item: BCM-M12-001 — World Map  
Prompt: \`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_EXECUTION_PROMPT_V01.md\`  
Criteria: \`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_LOCKED_ACCEPTANCE_CRITERIA_V01.md\`  
Repository: \`https://github.com/Sekiph82/Beach-Cocktails-Merge\`  
Target branch: \`main\`  
Godot: 4.7.2  

## Scope

Implemented only the reusable, data-driven World Map boundary requested by M12:

- \`WorldMapScene\` and \`WorldMapController\`.
- Reusable \`IslandEntry\` card component.
- Data-driven \`OPEN\`, \`LOCKED\`, \`CURRENT\`, and \`COMPLETE\` presentation states.
- Sunny Cove and Tiki canonical seed-island behavior from campaign state.
- Locked-island reason/progress feedback.
- Island-selection signal boundary for a future Island Map; no gameplay launch.
- Portrait/mobile-safe 720x1280 layout.
- Focused in-memory tests, isolated save round-trip coverage, and GUI evidence.

No Island Map, level buttons, gameplay timer, VIP runtime, full 100-level data, M13+ work, accepted gameplay/physics, R11/M08/M09 behavior, scoring/rewards, HUD, canonical gameplay assets, or persistence semantics were changed.

## Synchronization and preservation

The owner checkout was inspected first and preserved. It was on \`ui-assets\` with unrelated owner changes:

\`\`\`text
 M docs/evidence/m06_r07/canonical_720x1280.png
 M docs/evidence/m06_r07/canonical_720x1280_runtime_overlay.png
 M docs/evidence/m06_r07/shorter_wider_800x1280.png
 M docs/evidence/m06_r07/shorter_wider_800x1280_runtime_overlay.png
 M docs/evidence/m06_r07/taller_720x1440.png
 M docs/evidence/m06_r07/taller_720x1440_runtime_overlay.png
 M project.godot
?? assets/beach cocktails merge logo.png
?? docs/BCM-R11_MASA_KENARI_DUZELTMESI_RAPORU.md
?? docs/MASA_DEGISIRSE_YAPILACAKLAR.md
\`\`\`

The required sync-first checks were run in that checkout:

\`\`\`text
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
=> origin/main advanced from d755b2e to 5df469d
=> 0 7
\`\`\`

Because the owner checkout was dirty and on the visual-assets branch, implementation was performed in a clean managed worktree created from \`origin/main\` at \`5df469dbb618c5aa9b59625ed383ffaa58794130\`. No reset, rebase, stash, force-push, or destructive checkout was used.

Start HEAD: \`5df469dbb618c5aa9b59625ed383ffaa58794130\`  
Implementation commit: \`40d40c9\`  

## Files published

- \`scripts/campaign/campaign_manager.gd\`
- \`scripts/campaign/island_entry.gd\`
- \`scripts/campaign/world_map_controller.gd\`
- \`scenes/campaign/IslandEntry.tscn\`
- \`scenes/campaign/WorldMapScene.tscn\`
- \`tests/m12_world_map_probe.gd\`
- \`tests/m12_world_map_gui_capture.gd\`
- \`docs/CAMPAIGN_WORLD_MAP_M12.md\`
- \`docs/evidence/m12/world_map_fresh_720x1280.png\`
- \`docs/evidence/m12/world_map_locked_feedback_720x1280.png\`
- \`docs/evidence/m12/world_map_complete_fixture_720x1280.png\`
- this immutable log

## Implementation evidence

\`WorldMapController\` obtains island definitions from \`LevelDatabase\`, obtains unlock/progress feedback from \`CampaignManager\`, and derives card presentation from the returned campaign state. The UI does not own unlock rules. Locked selection emits feedback without selection/navigation; unlocked selection emits \`island_selected\` and \`island_map_requested\` with the island id as the future Island Map boundary, without launching gameplay.

The controller creates a portrait shell with a bounded scrollable island list, navigation boundary footer, and layout reporting. \`IslandEntry\` is reusable and renders semantic state, progress, and action text. Campaign manager additions provide island selection, progression feedback, and progress reporting while preserving existing persistence and progression semantics.

The test fixture uses an in-memory \`LevelDatabase\` and \`CampaignManager\`. Its reload check writes only to \`user://m12_world_map_probe/reload.json\` and \`.bak\`; it never reads or writes the owner save paths \`user://campaign_save.json\` or \`user://save.cfg\`.

## Focused tests and GUI evidence

Focused command:

\`\`\`powershell
godot_console.exe --headless --path . --script res://tests/m12_world_map_probe.gd
\`\`\`

Result:

\`\`\`text
M12_WORLD_MAP_RESULT=PASS
exit 0
\`\`\`

The probe covers scene loading, database-driven entries, fresh Sunny Cove selection, locked Tiki feedback, selection/navigation signals, 720x1280 clipping and overlap checks, ten-island structural handling, complete/open/current state derivation, and isolated persistence reload reconstruction.

GUI evidence command:

\`\`\`powershell
godot.exe --path . --resolution 720x1280 --script res://tests/m12_world_map_gui_capture.gd
\`\`\`

Result: \`M12_GUI_CAPTURE_RESULT=PASS\`. The normal-window capture produced these committed 720x1280 PNGs:

- \`docs/evidence/m12/world_map_fresh_720x1280.png\`
- \`docs/evidence/m12/world_map_locked_feedback_720x1280.png\`
- \`docs/evidence/m12/world_map_complete_fixture_720x1280.png\`

The captures were inspected for portrait clipping, card overlap, state readability, locked feedback, and the future Island Map boundary. No owner-native acceptance or independent audit was performed.

## Regression evidence

After Godot import/reimport completed, the existing probes were run without modifying their source:

| Probe | Result |
| --- | --- |
| M01 | PASS |
| M02 | PASS |
| M03 | PASS |
| M04 | PASS |
| M05 | PASS |
| M06 | PRE-EXISTING PARSE FAILURE |
| M07 | PASS |
| M08 | PASS |
| M09 | PASS |
| M10 | PASS |
| M11 | PASS |
| M12 | PASS |

M06 fails before execution in the existing \`tests/m06_environment_geometry_probe.gd\` because Godot 4.7.2 cannot infer the types of \`launch_bounds\` and \`launch_ok\`. This M12 implementation did not modify that harness. M07/M08 emit expected headless \`save_png\`/null-texture diagnostics while returning their existing PASS results.

Godot editor import/reimport was completed before the focused and regression probes so the clean worktree had current class and resource imports. Generated \`.godot\` data and four untracked import translation artifacts were removed from the worktree and were not published.

## Known limitations and deferred work

- The canonical seed database currently exposes Sunny Cove and a Tiki placeholder; the placeholder remains locked until campaign progression supplies the required completion.
- Full content and future island-level selection remain deferred to their authorized milestones.
- The existing M06 probe parse issue remains outside M12 scope.
- Independent ChatGPT audit, owner-native acceptance, and tracker transition were not performed.

## Publication proof

The implementation was committed as \`40d40c9\` and pushed fast-forward to \`origin/main\`. The log is published in a subsequent commit. Final verification after the log push must show the same final log commit for all three values:

\`\`\`powershell
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
\`\`\`

\`TASKS.md\` was read but not modified. Codex did not mark any task complete and did not self-audit.

Awaiting independent audit.

