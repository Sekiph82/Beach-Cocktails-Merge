# BCM-M12-001 — Codex Remediation Log V02

Status: AWAITING_AUDIT  
Work item: BCM-M12-001 — World Map remediation V02  
Prompt: \`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_EXECUTION_PROMPT_V02.md\`  
Criteria: \`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_V02.md\`  
Repository: \`https://github.com/Sekiph82/Beach-Cocktails-Merge\`  
Target branch: \`main\`  
Godot: 4.7.2  

## Scope

Remediated only M12 after the owner runtime rejection:

- replaced the card/list-primary screen with a full-screen visual ocean map;
- added spatial route geometry and island destination markers;
- kept state and unlock decisions in LevelDatabase/CampaignManager;
- made Sunny Cove the only initially selectable destination;
- showed nine future destinations as visibly locked placeholder islands;
- fixed refresh cleanup with deferred rebuild and \`queue_free()\`;
- verified repeated Sunny Cove selection/refresh leaves no duplicate markers;
- isolated normal M12 startup verification from historical R10 probe execution;
- kept the portrait 720x1280 layout and added focused tests/evidence.

No Island Map, level buttons, gameplay timer, VIP runtime, full content, M13+ work, gameplay physics, R11/M08/M09 behavior, scoring/rewards, gameplay HUD, canonical gameplay assets, or M11 persistence semantics were changed.

## Synchronization and preservation

The requested owner checkout was inspected at:

\`C:\Users\sekip\Desktop\Beach Cocktails - Merge MAIN\`

It was a detached local checkout at \`a875beaabc8b385bca3fc354a7c139650592de7d\`, four commits behind \`origin/main\`, with owner changes:

\`\`\`text
 M project.godot
 M scripts/campaign/world_map_controller.gd
?? assets/ui_assets/ASSET_DIMENSIONS.alpha.translation
?? assets/ui_assets/ASSET_DIMENSIONS.height.translation
?? assets/ui_assets/ASSET_DIMENSIONS.mode.translation
?? assets/ui_assets/ASSET_DIMENSIONS.width.translation
\`\`\`

The required preflight was run there:

\`\`\`text
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
=> 0 4
origin/main => 8694660b1e30a2bc8b1ee31fdd975acdd224052b
\`\`\`

Implementation used a clean managed worktree created from \`origin/main\` at \`8694660b1e30a2bc8b1ee31fdd975acdd224052b\`. The owner checkout was not reconciled, reset, rebased, stashed, or otherwise modified.

Start HEAD: \`8694660b1e30a2bc8b1ee31fdd975acdd224052b\`  
Implementation commit: \`5e87a654818b720c22280b98939ff06f73e6b2cf\`  

## Files changed

- \`data/campaign/islands.json\`
- \`scripts/campaign/island_entry.gd\`
- \`scripts/campaign/world_map_controller.gd\`
- \`tests/m12_world_map_probe.gd\`
- \`tests/m12_world_map_gui_capture.gd\`
- \`docs/CAMPAIGN_WORLD_MAP_M12.md\`
- \`docs/evidence/m12/world_map_fresh_720x1280.png\`
- \`docs/evidence/m12/world_map_locked_feedback_720x1280.png\`
- \`docs/evidence/m12/world_map_complete_fixture_720x1280.png\`
- this immutable log

No canonical asset bytes were changed. Existing \`assets/ui_assets/campaign/world_map/\` art is consumed as-is.

## Remediation implementation

\`data/campaign/islands.json\` now carries presentation coordinates and existing world-map art paths for the planned ten-island route:

- Sunny Cove;
- Tiki Island;
- Azure Bay;
- Coconut Beach;
- Sunset Island;
- Party Beach;
- Frozen Paradise;
- Volcano Bay;
- Billionaire Island;
- Final Island.

Only Sunny Cove has production level content and a \`default_open\` rule. The nine other records are zero-content placeholders with sequential completion rules. CampaignManager evaluates those rules, so the UI does not hardcode unlock state.

\`WorldMapController\` now:

- renders the existing ocean map background;
- draws a spatial route from data-defined marker positions;
- creates one reusable \`IslandEntry\` marker per LevelDatabase definition;
- obtains unlock feedback and semantic state from CampaignManager;
- emits the future Island Map boundary only for an unlocked destination;
- leaves locked markers tappable for feedback but never navigates;
- rebuilds through \`call_deferred()\`;
- detaches old markers and calls \`queue_free()\`, never immediate \`free()\`;
- exposes marker/node counts and deterministic 720x1280 geometry reporting.

\`IslandEntry\` now renders island art, lock overlay, state label, current/open halo, and spatial marker treatment rather than a rectangular list card.

## Historical R10 startup noise

Historical R10 probe sources were not rewritten, deleted, or falsified. The clean production project configuration still uses only:

\`\`\`text
run/main_scene="res://scenes/main.tscn"
\`\`\`

and contains no historical test startup path. The M12 controller and scene do not preload or invoke R10 probes. A clean editor/import scan was run with:

\`\`\`powershell
godot_console.exe --headless --path . --editor --quit
\`\`\`

The scan completed without \`R10\`, \`SCRIPT ERROR\`, or \`Parse Error\` output. The focused M12 probe also asserts that normal startup does not reference \`tests/\`. Historical probes remain directly runnable under their original paths; the known historical M06 environment probe still reports its existing Godot 4.7.2 type-inference parse failure when explicitly invoked.

## Focused M12 test

Command:

\`\`\`powershell
godot_console.exe --headless --path . --script res://tests/m12_world_map_probe.gd --quit-after 120
\`\`\`

Result:

\`\`\`text
M12_WORLD_MAP_RESULT=PASS
exit 0
\`\`\`

The focused probe verifies:

- normal startup excludes historical probe scripts;
- WorldMapScene loads;
- visual markers are generated from LevelDatabase definitions;
- canonical data exposes ten planned destinations;
- Sunny Cove is the only fresh selectable destination;
- all other displayed destinations are locked;
- locked selection emits no navigation and shows reason/progress;
- Sunny Cove emits the future Island Map boundary;
- repeated Sunny Cove selection/refresh remains accepted;
- deferred cleanup leaves no duplicate marker nodes;
- 720x1280 marker geometry has no clipping/overlap;
- COMPLETE/OPEN/CURRENT states derive from CampaignManager;
- isolated SaveManager round-trip reconstructs campaign state.

The test writes only under \`user://m12_world_map_probe/\` and never opens production campaign or legacy save paths.

## GUI evidence

Normal-window command:

\`\`\`powershell
godot.exe --path . --resolution 720x1280 --script res://tests/m12_world_map_gui_capture.gd --quit-after 300
\`\`\`

The run completed and regenerated these 720x1280 PNGs:

- \`docs/evidence/m12/world_map_fresh_720x1280.png\`
- \`docs/evidence/m12/world_map_locked_feedback_720x1280.png\`
- \`docs/evidence/m12/world_map_complete_fixture_720x1280.png\`

The committed images were inspected for:

- full-screen map/ocean composition;
- spatially placed destinations and route relationship;
- Sunny Cove current/open emphasis;
- visibly locked future destinations;
- locked reason/progress readability;
- portrait clipping and marker overlap;
- status/navigation boundary separation.

This is builder visual evidence only. Owner-native acceptance and independent ChatGPT audit were not performed.

## Regression evidence

Existing regression probes were run serially after the V02 implementation:

| Probe | Result |
| --- | --- |
| M01 | PASS |
| M02 | PASS |
| M03 | PASS |
| M04 | PASS |
| M05 | PASS |
| M06 \`m06_environment_geometry_probe.gd\` | PRE-EXISTING PARSE FAILURE |
| M07 | PASS |
| M08 | PASS |
| M09 | PASS |
| M10 | PASS |
| M11 | PASS |
| M12 focused | PASS |

The M06 failure is unchanged and occurs before execution because Godot 4.7.2 cannot infer \`launch_bounds\` and \`launch_ok\` in the historical probe. M05/M07/M08 headless runs emit their existing null-texture/save-capture diagnostics while returning PASS. M11 emits its expected malformed-save JSON diagnostics while returning PASS. No M12 source change was made to those historical harnesses.

## Known limitations and deferred work

- The nine future destinations are presentation-only zero-content placeholders; Island Map and gameplay content remain deferred.
- The clean editor scan confirms normal M12 startup/import isolation, but owner-native editor cache/pop-up state was not controlled or accepted by Codex.
- The historical M06 parse-invalid probe remains outside M12 remediation scope.
- Independent ChatGPT re-audit, owner runtime acceptance, and tracker transition remain pending.

## Publication proof

The implementation commit is \`5e87a654818b720c22280b98939ff06f73e6b2cf\`. This log is committed and pushed separately. Final verification after the log push must show the same final log commit for:

\`\`\`powershell
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
\`\`\`

\`TASKS.md\` and all ChatGPT-owned prompt/criteria/audit files were read but not modified. Codex did not self-audit or mark tasks complete.

Awaiting independent audit.

