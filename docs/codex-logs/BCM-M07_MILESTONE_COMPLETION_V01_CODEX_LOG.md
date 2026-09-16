# BCM-M07 — Dynamic Gameplay HUD Composition — Codex Execution Log V01

## Work item and authority

- Work item: BCM-M07
- Prompt: BCM-M07_MILESTONE_COMPLETION_V01_PROMPT.md
- Repository: https://github.com/Sekiph82/Beach-Cocktails-Merge.git
- Branch: main
- Local source of truth: C:\Users\sekip\Desktop\Beach Cocktails - Merge
- Godot observed: 4.7.2.stable.official.ed1daf0bf
- This is builder evidence only. Independent ChatGPT audit and tracker transition remain pending.
- Read before implementation: AGENTS.md, TASKS.md, the M07 entry prompt, coordination/sessions/BCM-M07-001/CHATGPT_PROMPT_V01.md, coordination/sessions/BCM-M07-001/CHATGPT_AUDIT_CRITERIA_V01.md, and the accepted M06 audit.
- TASKS.md and the ChatGPT-owned coordination files were not edited.

## Sync-first preflight

The session started from the requested repository root.

    git status --short --branch
    ## main...origin/main [behind 3]

    git remote -v
    origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
    origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)

    git fetch origin main
    From https://github.com/Sekiph82/Beach-Cocktails-Merge
     * branch main -> origin/main
       e445f77..a286525 main -> origin/main

    git rev-parse HEAD
    1d79b49ce770f955c69b07593af520f35b79bbdb

    git rev-parse origin/main
    a286525b2759c624005a1d1aad3073e85fe5b0fa

    git rev-list --left-right --count HEAD...origin/main
    0 10

    git merge --ff-only origin/main
    Updating 1d79b49..a286525
    Fast-forward

The checkout synchronized by fast-forward to a286525b2759c624005a1d1aad3073e85fe5b0fa. No reset, force-push, automatic rebase, or stash was used. origin already pointed to the canonical repository.

## Implementation summary

Production changes are bounded to scripts/game_manager.gd and the deterministic non-production probe tests/m07_hud_composition_probe.gd.

The production HUD creates one UI/HUD root containing:

    UI/CanvasLayer
    └── HUD
        ├── Logo/Artwork
        ├── BestScorePanel/Artwork + BestValue
        ├── ScorePanel/Artwork + ScoreValue
        ├── ToGoOrdersPanel/Artwork + TargetCocktail + live level/reward labels
        ├── NextPanel/Artwork + NextCocktail
        └── ProgressionStrip/Artwork + ProgressionIconL01 ... ProgressionIconL12

World-space overlays are separate production nodes:

    LaunchZone -> res://assets/ui/launch_zone.png
    DangerLine -> res://assets/ui/danger_line.png

Fixed-size Control wrappers with child Sprite2D artwork preserve authored panel aspect ratios. This also prevents Godot TextureRect intrinsic dimensions from expanding the layout. The first render probe exposed that intrinsic-size issue; the wrapper implementation was then verified by the successful probe.

The shared M05 mapping remains the only cocktail mapping source: production and HUD consumers use Drink.texture_for_level(level) and _hud_icon_scale(). No L01-L12 texture paths were duplicated. To-Go, Next, and all progression icons use the same canonical level mapping.

Old prototype score/best/next labels, procedural merge-target artwork/caption, permanent bottom instruction hint, and procedural danger-line draw were removed/suppressed. Accepted gameplay values and APIs remain unchanged: 700 px/s launch speed, 180 px/s² deceleration, simultaneous moving drinks, L6-L12 orders, L6=1000/L7=1800 rewards, L12 cap, restart, and Game Over behavior. No canonical PNG, guide_line, or M06 geometry was changed.

## Layout and M06 geometry evidence

Final wrapper sizes reported by the M07 probe:

    canonical_720x1280 logo=(220.0, 148.0) best=(230.0, 130.0) score=(230.0, 130.0) to_go=(310.0, 206.6667) next=(150.0, 150.0) strip=(696.0, 232.5345)
    taller_720x1440 logo=(220.0, 148.0) best=(230.0, 130.0) score=(230.0, 130.0) to_go=(310.0, 206.6667) next=(150.0, 150.0) strip=(696.0, 232.5345)
    shorter_wider_800x1280 logo=(242.0, 162.8) best=(253.0, 143.0) score=(253.0, 143.0) to_go=(341.0, 227.3333) next=(165.0, 165.0) strip=(773.6, 258.4608)

Accepted M06 gameplay coordinates remained unchanged:

    canonical_720x1280 table_top_y=386.667 table_bottom_y=1006.667 danger_y=873.333 launch_y=953.333
    taller_720x1440 danger_y=982.500 launch_y=1072.500
    shorter_wider_800x1280 danger_y=873.333 launch_y=953.333

The danger PNG is positioned at death_line_y. The launch oval follows the held drink position and is below the held drink in z-order. No gameplay rail, launch, stop, danger, collider, physics, scoring, or economy value was retuned for M07.

## Dynamic-state evidence

The probe prepared a real production scene with score 12650, best score 24380, To-Go target L6, reward +1000, next L2, and five settled table drinks for representative captures. It then changed production state to score 777, best 888, To-Go L7, reward +1800, and Next L3; all consumers updated without duplicate nodes or duplicate mapping. It restored the representative state and performed three rapid launches, verifying the held drink and true Next texture remained synchronized.

Reported state lines:

    M07_HUD_STATE label=canonical score=12650 best=24380 target=L6 reward=1000 next=L1 progression_slots=12 death_y=873.333 launch_y=953.333
    M07_HUD_STATE label=taller_720x1440 score=12650 best=24380 target=L6 reward=1000 next=L3 progression_slots=12 death_y=982.500 launch_y=1072.500
    M07_HUD_STATE label=shorter_wider_800x1280 score=12650 best=24380 target=L6 reward=1000 next=L3 progression_slots=12 death_y=873.333 launch_y=953.333

The Next level varies after the intentional rapid-launch sequence; the probe checks it against the controller's actual _next_level rather than a hard-coded visual.

## Retained production screenshots

The M07 probe saved actual Godot render captures:

    docs/evidence/m07/canonical_720x1280.png
    docs/evidence/m07/taller_720x1440.png
    docs/evidence/m07/shorter_wider_800x1280.png

    canonical_720x1280.png dimensions=720x1280 SHA256=2779A2C61C3110043DDA21D33AFED803E66F9BFAC42C0FD0FBC25E30810A9E3D bytes=1720793
    taller_720x1440.png dimensions=720x1440 SHA256=FAF905B5CEC476E5CBAB8A4DFF4ACB5EF31C90D9601FFD82350AC0C9B0892C96 bytes=1830347
    shorter_wider_800x1280.png dimensions=800x1280 SHA256=66661D97486DA072A8BBD2F392C4DDD83E79EB67CBF02B6A5D762668BCE99B85 bytes=1933697

Builder visual inspection found the required logo, score panels, centered To-Go panel, one Next panel, table area, danger PNG, launch oval, and 12-slot strip in all three captures, with no permanent bottom hint or aiming guide. This is builder inspection, not independent owner/auditor acceptance.

## Godot version, import, and startup

    godot_console --version
    4.7.2.stable.official.ed1daf0bf
    VERSION_PROCESS_EXIT_CODE=0

    godot_console --headless --quiet --path . --editor --import --quit
    WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
    IMPORT_PROCESS_EXIT_CODE=0

    godot_console --headless --quiet --path . --quit-after 3
    STARTUP_PROCESS_EXIT_CODE=0

The import warning concerns the pre-existing original_reference directory and did not prevent import or startup.

## M01 regression

Command: godot_console --headless --path . --script res://tests/m01_contract_probe.gd

    M01_PROBE PASS: main scene loads as PackedScene
    M01_PROBE PASS: runtime world is created
    M01_PROBE PASS: runtime ShotController is created
    M01_PROBE PASS: runtime MergeQueue is created
    M01_PROBE PASS: mouse release launches current drink
    M01_PROBE PASS: launched drink uses 700 px/s initial velocity
    M01_PROBE PASS: next held drink appears immediately after mouse launch
    M01_PROBE PASS: multiple drinks can move simultaneously
    M01_PROBE PASS: sliding deceleration is 180 px/s^2
    M01_PROBE PASS: forward-only motion removes +Y rebound
    M01_PROBE PASS: settled drink wakes and is physically movable on impact
    M01_PROBE PASS: merge creates capped next level
    M01_PROBE PASS: merge result preserves forward/lateral momentum
    M01_PROBE PASS: L12 is the cap and L13 is unavailable
    M01_PROBE PASS: Game Over freezes the run and shows overlay
    M01_PROBE PASS: best score is persisted through user://
    M01_PROBE PASS: restart reloads a playable scene
    M01_PROBE PASS: best score survives restart
    M01_PROBE_RESULT=PASS
    PROCESS_EXIT_CODE=0

## M02 regression

Command: godot_console --headless --path . --script res://tests/m02_physics_regression.gd

    M02_PROBE PASS: main scene loads as PackedScene
    M02_PROBE PASS: runtime GameManager/World is ready
    M02_BODY_CONFIG level=6 mass=2.5 radius=42.0 freeze_mode=0 ccd=2 linear_damp=0.0 angular_damp=3.0 friction=0.07999999821186 bounce=0.0
    M02_PROBE PASS: RigidBody2D body and zero-bounce physics configuration
    M02_PROBE PASS: all 12 collider radii are positive and runtime mass is monotonic
    M02_PROBE PASS: held-to-sliding transition enables dynamic collision
    M02_PROBE PASS: top boundary contact settles without +Y rebound
    M02_PROBE PASS: 700 px/s direct-hit has contact without tunneling
    M02_PROBE PASS: 700 px/s glancing-hit has contact without tunneling
    M02_PROBE PASS: collision response remains forward-only
    M02_PROBE PASS: one pair resolves once with one score and one result body
    M02_PROBE PASS: moving multi-body chain merge produces stable L3
    M02_PROBE PASS: chain merge consumes only the intended chain inputs
    M02_PROBE PASS: L12 plus L12 remains two L12 bodies with no L13
    M02_PROBE PASS: L12 remains a hard cap
    M02_RAPID_LAUNCH launches=6 world_drinks=7 simulated_previous=6 current_valid=true current_state=0
    M02_PROBE PASS: six rapid launches preserve current/next integrity
    M02_PROBE PASS: earlier rapid-launch drinks continue physical simulation
    M02_PROBE PASS: restart during multi-body motion produces clean playable scene
    M02_PROBE PASS: Game Over with multiple moving drinks freezes all and stops shooting
    M02_PROBE PASS: post-Game-Over restart has no stale moving-body references
    M02_PROBE_RESULT=PASS
    PROCESS_EXIT_CODE=0

## M03 regression

Command: godot_console --headless --path . --script res://tests/m03_economy_regression.gd

    M03_PROBE PASS: main scene loads as PackedScene
    M03_PROBE PASS: runtime economy objects are ready
    M03_PROBE PASS: every resulting merge level L2-L12 pays the exact score once
    M03_SCORE_TABLE L2=20 L3=50 L4=100 L5=200 L6=350 L7=600 L8=1000 L9=1600 L10=2500 L11=4000 L12=6500
    M03_PROBE PASS: combo x1 through x6+ uses 0/25/50/75/100/125 percent cap
    M03_PROBE PASS: combo expiration resets deterministically
    M03_PROBE PASS: initial active To-Go target starts at L6
    M03_PROBE PASS: To-Go target stays in L6-L12 and avoids immediate repeat
    M03_REWARD_TABLE L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
    M03_PROBE PASS: owner-approved To-Go reward table L6-L12 is exact
    M03_PROBE PASS: newly created L6-L12 matching drinks fulfill active order exactly once
    M03_PROBE PASS: stored L6-L12 matching drinks receive only the current reward exactly once
    M03_PROBE PASS: only one matching stored drink is consumed
    M03_PROBE PASS: L12 remains stored when not ordered and fulfills a later L12 order
    M03_PROBE PASS: duplicate merge request cannot double-pay
    M03_PROBE PASS: missing/corrupt save loads safe best-score default
    M03_PROBE PASS: danger line waits below one-second tolerance
    M03_PROBE PASS: danger line triggers deterministic Game Over at one second
    M03_PROBE PASS: restart clears session score/state and restores playable scene
    M03_PROBE PASS: Game Over with moving drinks freezes run, stops shooting, clears pending work, and shows overlay
    M03_PROBE PASS: Game Over persists best score without corrupting save
    M03_PROBE PASS: restart after moving Game Over preserves best and clears session
    M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
    OWNER-APPROVED REWARD TABLE APPLIED: L6=1000 L7=1800; L8-L12 unchanged
    M03_PROBE_RESULT=PASS
    PROCESS_EXIT_CODE=0

## M04 regression

Command: godot_console --headless --path . --script res://tests/m04_asset_import_probe.gd

    M04_GODOT_ASSET_COUNT expected=22 observed=22
    M04_GODOT_ASSET PASS: all canonical cocktail, environment, UI, and effects PNGs load with image_loaded=true
    M04_GODOT_RESULT=PASS
    PROCESS_EXIT_CODE=0

The exact run listed all 22 canonical paths and dimensions, including L01=1230x1278, L02-L12=1254x1254, background=1024x1536, logo=1536x1024, Best=1672x941, Score=1670x941, To-Go=1536x1024, Next=1254x1254, progression=2170x725, launch=1254x1254, danger=2172x724, and trail=1774x887.

## M05 regression

Command: godot_console --headless --path . --script res://tests/m05_sprite_integration_probe.gd

    M05_PROBE PASS: main scene loads as PackedScene
    M05_TEXTURE_MAP L01=res://assets/cocktails/L01.png L12=res://assets/cocktails/L12.png invalid13=
    M05_PROBE PASS: invalid levels fail safely without an L13 texture
    M05_PROBE PASS: all L01-L12 table drinks use the canonical Sprite2D mapping
    M05_PROBE PASS: all L01-L12 visual/body scales stay bounded for the portrait playfield
    M05_PROBE PASS: held launch drink uses a canonical Sprite2D
    M05_PROBE PASS: merge creates the correct next-level sprite atomically
    M05_PROBE PASS: merge result preserves forward/lateral momentum without visual teleport
    M05_PROBE PASS: L12 has no L13 texture/path and stays capped
    M05_RAPID_VISUALS launches=6 verified_steps=6 current_level=1
    M05_PROBE PASS: rapid launches preserve coherent current/next Sprite2D visuals
    M05_PROBE PASS: restart leaves one playable held Sprite2D and no orphan visuals
    M05_PROBE PASS: Game Over preserves visual/body ownership without orphan nodes
    M05_PROBE PASS: restart after Game Over restores one canonical held visual
    M05_PROBE_RESULT=PASS
    PROCESS_EXIT_CODE=0

## M06 regression

Command: godot_console --path . --script res://tests/m06_environment_geometry_probe.gd --rendering-method gl_compatibility --display-driver windows

    M06_PROBE PASS: main scene loads as PackedScene
    M06_PROBE PASS: production background node uses exact canonical asset
    M06_PROBE PASS: background source dimensions are 1024x1536
    M06_PROBE PASS: background is behind gameplay world
    M06_PROBE PASS: canonical cover scale/offset is deterministic
    M06_CANONICAL_RENDER viewport=(720.0, 1280.0) source=1024x1536 scale=0.833333 offset=(-66.66666, 0.0) table_top_y=386.667 table_bottom_y=1006.667 danger_y=873.333 launch_y=953.333
    M06_PROBE PASS: visible perspective rails narrow toward top
    M06_RAILS top=(176.667,543.333) middle_y=696.667 middle=(98.333,621.667) bottom=(20.000,700.000)
    M06_PROBE PASS: production walls use four bounded perspective rail segments
    M06_PROBE PASS: L01/mid/L12 collider footprints remain inside perspective rails
    M06_PROBE PASS: held launch cocktail starts on the lower visible table
    M06_PROBE PASS: no guide_line asset or node was introduced
    M06_PROBE PASS: canonical source-to-viewport mapping preserves aspect without distortion
    M06_PROBE PASS: responsive canonical/taller/shorter-wider cases keep portrait table landmarks visible
    M06_NOTE direct/glancing collision, rapid launch, merge, restart, Game Over and To-Go contracts are covered by rerun M01-M05 probes.
    M06_PROBE_RESULT=PASS
    PROCESS_EXIT_CODE=0

M06 was rerun as regression after M07 code changes. Its existing committed M06 evidence remains outside the M07 diff; only M07 captures are added.

## M07 focused probe

Command: godot_console --path . --script res://tests/m07_hud_composition_probe.gd --rendering-method gl_compatibility --display-driver windows

    M07_PROBE PASS: main scene loads as PackedScene
    M07_PROBE PASS: canonical/taller/shorter-wider cases each have one HUD root
    M07_PROBE PASS: canonical logo/panels exist
    M07_PROBE PASS: score panels share normalized display size
    M07_PROBE PASS: top-left logo then Best Score then Score hierarchy
    M07_PROBE PASS: upper-center To-Go panel and upper-right Next panel do not overlap
    M07_PROBE PASS: live score values are dynamic
    M07_PROBE PASS: exactly one active To-Go panel/target/reward
    M07_PROBE PASS: exactly one Next panel shows true next texture
    M07_PROBE PASS: progression is exactly L01-L12 with no L13
    M07_PROBE PASS: held cocktail is above canonical launch zone
    M07_PROBE PASS: canonical danger PNG tracks accepted M06 threshold
    M07_PROBE PASS: no guide-line or permanent prototype hint
    M07_PROBE PASS: no legacy duplicate labels
    M07_PROBE PASS: live score/To-Go/Next state updates without duplicate mapping
    M07_PROBE PASS: rapid launch keeps current held sprite and Next synchronized
    M07_CAPTURE name=canonical_720x1280 dimensions=720x1280 path=res://docs/evidence/m07/canonical_720x1280.png error=0
    M07_CAPTURE name=taller_720x1440 dimensions=720x1440 path=res://docs/evidence/m07/taller_720x1440.png error=0
    M07_CAPTURE name=shorter_wider_800x1280 dimensions=800x1280 path=res://docs/evidence/m07/shorter_wider_800x1280.png error=0
    M07_PROBE_RESULT=PASS
    PROCESS_EXIT_CODE=0

## Asset and scope hygiene

    git diff --quiet -- assets/cocktails assets/environment assets/ui assets/effects
    WORKTREE_CANONICAL_ASSET_DIFF_EXIT_CODE=0

    git diff --name-only -- TASKS.md
    WORKTREE_TASKS_DIFF_EXIT_CODE=0

    git diff --name-only -- coordination/sessions/BCM-M07-001
    WORKTREE_COORDINATION_DIFF_EXIT_CODE=0

Only these intended M07 files are to be committed:

    scripts/game_manager.gd
    tests/m07_hud_composition_probe.gd
    docs/evidence/m07/canonical_720x1280.png
    docs/evidence/m07/taller_720x1440.png
    docs/evidence/m07/shorter_wider_800x1280.png
    docs/codex-logs/BCM-M07_MILESTONE_COMPLETION_V01_CODEX_LOG.md

Godot .import sidecars are ignored and not staged. No TASKS.md, coordination prompt/audit, canonical PNG, guide_line, M08 file, or later V7 integration file is in M07 scope.

## Known limitations and audit boundary

- No independent ChatGPT acceptance audit has been performed by this builder session.
- Visual inspection was local; owner-master pixel/diff comparison and device safe-area QA remain auditor/owner checks.
- Godot reported the pre-existing res://original_reference import warning.
- The existing prototype Game Over overlay remains outside this M07 HUD composition scope; M08+ work was not started.
- Runtime capture verification used the local Intel OpenGL Compatibility renderer.

## Commit and final equality evidence

Start HEAD after mandatory synchronization: a286525b2759c624005a1d1aad3073e85fe5b0fa.

The implementation, probe, captures, and this log will be committed to main, pushed to origin/main, and final equality commands will be recorded below before completion.

    git rev-parse HEAD
    <FINAL_COMMIT_SHA>
    git rev-parse origin/main
    <FINAL_COMMIT_SHA>
    git ls-remote origin refs/heads/main
    <FINAL_COMMIT_SHA> refs/heads/main
    git rev-list --left-right --count HEAD...origin/main
    0 0
    git status --short --branch
    ## main...origin/main
    git diff --check
    FINAL_DIFF_CHECK_EXIT_CODE=0
    git diff -- TASKS.md
    FINAL_TASKS_DIFF_EXIT_CODE=0

The placeholder must be replaced by the actual final pushed SHA before completion.

Explicit governance confirmations:

- TASKS.md was not edited.
- BCM-M08 or later was not started.
- V7 environment/HUD-after-M07 work was not started.
- Canonical PNG files were not modified.
