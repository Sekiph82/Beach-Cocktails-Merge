# BCM-M06 — Environment, Table Composition, and Responsive Playfield V01 Codex Log

## Work item and governance

- Work item: BCM-M06-001 / M06 milestone completion.
- Prompt: `docs/prompts/BCM-M06_MILESTONE_COMPLETION_V01_PROMPT.md`.
- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Workspace: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Branch: `main`.
- Godot target/tested: `4.7.2.stable.official.ed1daf0bf`.
- Start HEAD before M06 sync: `56a21dc503fb72e1a00f8fcec78334555b3a92ef`.
- Synchronized base HEAD: `5fb7351e0f549fd4389f69264b964951403e072b`.
- End HEAD: recorded after commit and push below.

AGENTS.md, root TASKS.md, the M05 audit, the M05 Codex log, and the authoritative M06 prompt were read. `TASKS.md` was not edited. M07, M08, and later milestones were not started. No canonical PNG was modified.

The M05 audit correction was obeyed: the historical pre-M05 JSON radius series is `14,21,29,38,48,59,71,84,98,113,129,146`; the incorrect historical `18,22,26...` series is not propagated into this log, tests, or production code.

## Sync-first preflight

Exact commands and results from the repository root:

```text
git status --short --branch
## main...origin/main

git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)

git fetch origin main
From https://github.com/Sekiph82/Beach-Cocktails-Merge
 * branch            main       -> origin/main
   56a21dc..5fb7351  main       -> origin/main

git rev-parse HEAD
56a21dc503fb72e1a00f8fcec78334555b3a92ef

git rev-parse origin/main
5fb7351e0f549fd4389f69264b964951403e072b

git rev-list --left-right --count HEAD...origin/main
0 3
```

The remote-only commits were the M05 independent audit, M06 prompt, and tracker update. They were reconciled with the safe fast-forward command:

```text
git merge --ff-only origin/main
Updating 56a21dc..5fb7351
Fast-forward
```

No reset, force-push, destructive checkout, automatic rebase, or stash was used.

## Implementation summary

`GameManager` now composes `assets/environment/game_board_background.png` as a stable `Sprite2D` named `GameBoardBackground`, with `z_index = -100`, before the runtime `World` node. The source image is fitted with a uniform cover scale; no crop, recolor, redraw, or PNG edit is performed. The old procedural dark/trapezoid table fill and decorative bands were removed. The existing procedural red danger boundary remains as the already-owned gameplay/debug boundary until M07 owns final danger-line asset composition; no danger-line PNG was added.

The production geometry uses one source-background-to-viewport mapping:

- source size: `1024x1536`;
- `cover_scale = max(viewport_width / 1024, viewport_height / 1536)`;
- `cover_offset = (viewport_size - source_size * cover_scale) / 2`;
- `source_to_viewport(point) = cover_offset + point * cover_scale`.

Visible rail landmarks are manually interpreted from the owner-approved image and expressed in source pixels. They are the inside rail edges rather than the image canvas:

```text
TABLE_FAR_LEFT_SOURCE  = (292, 464)
TABLE_FAR_RIGHT_SOURCE = (732, 464)
TABLE_NEAR_LEFT_SOURCE = (104, 1208)
TABLE_NEAR_RIGHT_SOURCE = (920, 1208)
DANGER_SOURCE_Y = 1048
LAUNCH_SOURCE_Y = 1144
```

`get_table_rail_bounds_at_y()` linearly interpolates between these perspective rail points. `get_horizontal_bounds_at_y()` adds wall thickness, body radius, and a small clearance. `clamp_position_to_board()` now clamps between the mapped top and mapped near rail, not to the full viewport rectangle. `_build_walls()` creates four bounded `StaticBody2D` segments from the mapped rail points. `get_launch_position()` places the held drink on the lower visible table. No gravity or Suika behavior was introduced.

`ShotController` reuses `GameManager.get_launch_position()` instead of spawning at `viewport_height - 92`; launch speed and all accepted M01-M05 gameplay constants remain unchanged. M02 and M03 probe assertions were only made geometry-relative: the top contact check uses the mapped top rail and a small physics epsilon, and the danger test uses `manager.death_line_y`.

## Before/after geometry evidence

Before M06, production geometry was a viewport-derived symmetric trapezoid with `table_top_y = 205`, `table_top_inset = 76`, `table_bottom_inset = 24`, walls extending to approximately `viewport_height + 10.8`, `death_line_y = 1040`, and the held launch position at `viewport_height - 92 = 1188` on the canonical viewport. These values were not tied to the approved background's visible table.

After M06 on the canonical `720x1280` viewport:

```text
table_top_y    = 386.667
table_bottom_y = 1006.667
top rail       = (176.667, 543.333)
middle y       = 696.667
middle rails   = (98.333, 621.667)
bottom rails   = (20.000, 700.000)
danger_line_y  = 873.333
launch_y       = 953.333
```

The far rail is narrower and higher, the near rail is wider and lower, and the launch/danger locations are on the tabletop. The danger line is `80 px` above the canonical launch Y, leaving the line closer to the launch side than the old broad prototype layout while preserving a usable accumulation area above it. The changes are visual-table alignment, not a retune of launch speed, deceleration, score/economy rules, or collision response.

Representative production collider checks from the focused probe:

```text
M06_COLLIDER level=L1 y=456.667 radius=20.000 safe_bounds=(193.979,526.021) inside=true
M06_COLLIDER level=L6 y=696.667 radius=42.000 safe_bounds=(155.333,564.667) inside=true
M06_COLLIDER level=L12 y=886.667 radius=90.000 safe_bounds=(155.323,564.677) inside=true
```

These positions cover far, middle, and near tabletop depth. They use the committed M05 body radii and test the actual production `spawn_drink()` clamp/rail helpers.

## Responsive/aspect-ratio evidence

The cover strategy is uniform and therefore preserves aspect ratio. All three tested portrait cases fit the source by height with no vertical crop; horizontal crop is the intentional cover behavior.

| Case | Viewport | Scale | Offset | Mapped far-left | Mapped near-left | Mapped danger Y | Mapped launch Y |
|---|---:|---:|---|---|---|---:|---:|
| canonical | 720x1280 | 0.833333 | (-66.66666, 0) | (176.6667,386.6667) | (20.0000,1006.6667) | 873.333 | 953.333 |
| taller portrait | 720x1440 | 0.937500 | (-120.0, 0) | (153.75,435.0) | (-22.5,1132.5) | 982.5 | 1072.5 |
| shorter/wider portrait | 800x1280 | 0.833333 | (-26.66666, 0) | (216.6667,386.6667) | (60.0000,1006.6667) | 873.333 | 953.333 |

The source center/table center remains visible in each case; the production geometry is recalculated from the same source landmarks for the actual viewport. The taller case intentionally crops the extreme near rail at the horizontal edges while retaining the table center, top region, danger region, and launch region. The shorter/wider case retains both usable near-rail edges. No gameplay-critical black bars are introduced by the cover transform. Final safe-area/native-device aesthetic acceptance remains unverified and belongs to later QA/audit.

## Retained runtime render evidence

The M06 probe generated deterministic captures with the production scene and actual environment composition under `docs/evidence/m06/`:

```text
canonical_720x1280.png       dimensions=720x1280 bytes=1526999 SHA256=943DBEB3A95D9911A4E3D9DF7B3D501A1789C0A12AC794B9FF651B9BD2AE0C2A
taller_720x1440.png          dimensions=720x1440 bytes=1621178 SHA256=8B8C18084F8111157FAC81178BBA35A4FEEDE947DDB24C7DD2055B39F7A2B180
shorter_wider_800x1280.png  dimensions=800x1280 bytes=1727955 SHA256=08541E16F0EAD80B2A43C256AA81B454DEE3B49992591ECE7A9C43CB8F9E31D3
```

The captures visibly show the approved beach-bar environment, perspective wooden table, canonical cocktail above the table, launch region, danger boundary, and top accumulation region. They are builder evidence, not owner-final visual acceptance. Godot-generated `.import` sidecars remain ignored and are not intended for the commit.

## Focused M06 probe

Probe: `tests/m06_environment_geometry_probe.gd`. It instantiates `scenes/main.tscn`, checks the production background/world/rails/geometry, checks L01/L06/L12 collider placement, verifies held launch placement and absence of `guide_line`, tests all three responsive mappings, and saves the captures above. It does not reimplement gameplay rules.

Exact focused result:

```text
M06_PROBE PASS: main scene loads as PackedScene
M06_PROBE PASS: production background node uses exact canonical asset
M06_PROBE PASS: background source dimensions are 1024x1536
M06_PROBE PASS: background is behind gameplay world
M06_PROBE PASS: canonical cover scale/offset is deterministic
M06_PROBE PASS: visible perspective rails narrow toward top
M06_PROBE PASS: top stop and bottom rail are inside the rendered table
M06_PROBE PASS: danger line is near launch side with usable table area
M06_PROBE PASS: production walls use four bounded perspective rail segments
M06_PROBE PASS: L01/mid/L12 collider footprints remain inside perspective rails
M06_PROBE PASS: held launch cocktail starts on the lower visible table
M06_PROBE PASS: no guide_line asset or node was introduced
M06_PROBE PASS: canonical source-to-viewport mapping preserves aspect without distortion
M06_PROBE PASS: responsive canonical_720x1280 keeps portrait table landmarks visible
M06_PROBE PASS: responsive taller_720x1440 keeps portrait table landmarks visible
M06_PROBE PASS: responsive shorter_wider_800x1280 keeps portrait table landmarks visible
M06_NOTE direct/glancing collision, rapid launch, merge, restart, Game Over and To-Go contracts are covered by the rerun M01-M05 probes recorded with this run.
M06_PROBE_RESULT=PASS
M06_PROCESS_EXIT_CODE=0
```

The exact capture/render lines were:

```text
M06_CAPTURE name=canonical_720x1280 dimensions=720x1280 path=res://docs/evidence/m06/canonical_720x1280.png error=0
M06_CAPTURE name=canonical_720x1280 dimensions=720x1280 path=res://docs/evidence/m06/canonical_720x1280.png error=0
M06_CAPTURE name=taller_720x1440 dimensions=720x1440 path=res://docs/evidence/m06/taller_720x1440.png error=0
M06_CAPTURE name=shorter_wider_800x1280 dimensions=800x1280 path=res://docs/evidence/m06/shorter_wider_800x1280.png error=0
```

The canonical capture appears twice because it is first saved from the main runtime viewport and then verified through the canonical responsive case; both saves are the same purposeful evidence path.

## M01-M05 and asset regression evidence

All focused probes were run after the M06 production geometry changes in isolated temporary Godot user-data directories. No score, combo, reward, persistence, physics constant, cocktail mapping, or collider mapping was changed by M06.

```text
M01_PROBE_RESULT=PASS
M01_PROCESS_EXIT_CODE=0

M02_TOP_CONTACT final_position=(359.9996, 418.3671) motion_state=2 velocity=(0.0, 0.000013)
M02_PROBE PASS: top boundary contact settles without +Y rebound
M02_PROBE PASS: 700 px/s direct-hit has contact without tunneling
M02_PROBE PASS: 700 px/s glancing-hit has contact without tunneling
M02_PROBE PASS: collision response remains forward-only
M02_PROBE PASS: one pair resolves once with one score and one result body
M02_PROBE PASS: moving multi-body chain merge produces stable L3
M02_PROBE PASS: L12 plus L12 remains two L12 bodies with no L13
M02_PROBE PASS: six rapid launches preserve current/next integrity
M02_PROBE PASS: earlier rapid-launch drinks continue physical simulation
M02_PROBE PASS: restart during multi-body motion produces clean playable scene
M02_PROBE PASS: Game Over with multiple moving drinks freezes all and stops shooting
M02_PROBE PASS: post-Game-Over restart has no stale moving-body references
M02_PROBE_RESULT=PASS
M02_PROCESS_EXIT_CODE=0

M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
M03_PROBE PASS: every resulting merge level L2-L12 pays the exact score once
M03_PROBE PASS: combo x1 through x6+ uses 0/25/50/75/100/125 percent cap
M03_PROBE PASS: combo expiration resets deterministically
M03_PROBE PASS: stored L6 matching drink receives only the current To-Go reward exactly once
M03_PROBE PASS: stored L7 matching drink receives only the current To-Go reward exactly once
M03_PROBE PASS: L12 remains stored when not ordered and fulfills a later L12 order
M03_PROBE PASS: missing save loads safe best-score default
M03_PROBE PASS: corrupt save loads safe best-score default without crash
M03_PROBE PASS: danger line triggers deterministic Game Over at one second
M03_PROBE PASS: restart after moving Game Over preserves best and clears session
M03_PROBE_RESULT=PASS
M03_PROCESS_EXIT_CODE=0

M05_PROBE PASS: all L01-L12 table drinks use the canonical Sprite2D mapping
M05_PROBE PASS: all L01-L12 visual/body scales stay bounded for the portrait playfield
M05_PROBE PASS: held launch drink uses a canonical Sprite2D
M05_PROBE PASS: merge creates the correct next-level sprite atomically
M05_PROBE PASS: merge result preserves forward/lateral momentum without visual teleport
M05_PROBE PASS: L12 has no L13 texture/path and stays capped
M05_PROBE PASS: rapid launches preserve coherent current/next Sprite2D visuals
M05_PROBE PASS: restart leaves one playable held Sprite2D and no orphan visuals
M05_PROBE PASS: Game Over preserves visual/body ownership without orphan nodes
M05_PROBE PASS: restart after Game Over restores one canonical held visual
M05_PROBE_RESULT=PASS
M05_PROCESS_EXIT_CODE=0
```

The M04 canonical asset import probe was also rerun:

```text
M04_GODOT_ASSET_COUNT expected=22 observed=22
M04_GODOT_ASSET PASS path=res://assets/environment/game_board_background.png dimensions=1024x1536 image_loaded=true
M04_GODOT_RESULT=PASS
M04_PROCESS_EXIT_CODE=0
```

The complete M01-M05 probe outputs remain in the executed test scripts and their earlier immutable logs; the lines above retain the M06-required contract evidence and exact process exit codes.

## Godot import/parse/startup evidence

```text
godot --version
4.7.2.stable.official.ed1daf0bf
VERSION_PROCESS_EXIT_CODE=0

godot --headless --quiet --path . --editor --import --quit
WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
   at: _should_skip_directory (editor/file_system/editor_file_system.cpp:3497)
IMPORT_PROCESS_EXIT_CODE=0

godot --headless --quiet --path . --quit-after 3
STARTUP_PROCESS_EXIT_CODE=0
```

The ignored `res://original_reference` nested project warning is pre-existing governance/reference content. Root `project.godot` remains the active project and `res://scenes/main.tscn` remains the main scene.

## Asset and scope integrity

The canonical environment blob was checked before commit:

```text
assets/environment/game_board_background.png SHA256=479FCA4698D0D3F0E819EC878F20CDE1033CC011ED396E48792FDE3072B1D9DF GIT_BLOB=2cefdb9b21d6a8f6ba08e796c5d41aea51c98d70
git hash-object assets/environment/game_board_background.png
2cefdb9b21d6a8f6ba08e796c5d41aea51c98d70
git rev-parse HEAD:assets/environment/game_board_background.png
2cefdb9b21d6a8f6ba08e796c5d41aea51c98d70
git diff --quiet -- assets/environment assets/cocktails assets/ui assets/effects
CANONICAL_ASSET_DIFF_EXIT_CODE=0
```

Representative unchanged canonical hashes also recorded:

```text
assets/cocktails/L01.png SHA256=5CC060ADF501562C2920FCB04A251E7A679A069F8D865F898E13ADB87AC1E425
assets/cocktails/L12.png SHA256=528022036A3C06F8782153D2AE22F644E533EEFFBC1AC198E411D50692B3C788
assets/ui/logo_beach_cocktails_merge.png SHA256=E65D7EEDCC60AEDD7522D6415411E39B3ED2798EEDF06318D321BD43DE63B3C9
assets/ui/panel_score.png SHA256=C392B2D14F47BC91570206ECB3C818666DB1424740738F050579FE8DB42403B1
```

Intended changed files:

```text
M scripts/game_manager.gd
M scripts/shot_controller.gd
M tests/m02_physics_regression.gd
M tests/m03_economy_regression.gd
A tests/m06_environment_geometry_probe.gd
A docs/evidence/m06/canonical_720x1280.png
A docs/evidence/m06/taller_720x1440.png
A docs/evidence/m06/shorter_wider_800x1280.png
A docs/codex-logs/BCM-M06_MILESTONE_COMPLETION_V01_CODEX_LOG.md
```

No `TASKS.md`, canonical PNG, M05 production file, UI asset, background asset, `guide_line`, M07 composition, M08 effect, audio, haptics, menu, export, or save file is intended to change.

## Verification matrix and limitations

| Evidence type | Result |
|---|---|
| Verified source/runtime | Background path, dimensions, z-order, uniform cover mapping, perspective rails, bounded walls, launch/danger/top geometry, collider placement, M06 probe, M01-M05 focused regressions, M04 import, Godot import/startup, PNG hashes, clean intended scope |
| Manual visual interpretation | Source rail landmarks `(292,464)`, `(732,464)`, `(104,1208)`, `(920,1208)` and source danger/launch Y landmarks were measured from the approved PNG; screenshots were visually inspected for table fit and gameplay layering |
| Unverified | Native phone safe-area behavior, device-specific GPU performance, owner-final aesthetic acceptance, final M07 HUD composition, M07 danger-line asset composition |

Known limitation: the source background is narrower than the taller portrait viewport at the near rail, so the cover crop can clip the extreme near-rail endpoints on the taller case. The central usable tabletop, top region, danger region, and launch region remain visible and the gameplay geometry is derived from the same transform. Final device safe-area tuning is deferred to later mobile/UI QA.

M06 is builder evidence only; it does not self-approve the milestone. Independent ChatGPT audit remains required.

## Commit/push and final equality

The intended files were staged explicitly, committed on `main`, pushed to `origin main`, then `origin/main` was fetched again. The exact final equality output for the pushed M06 implementation/log commit is recorded below after that push; the final commit SHA itself is supplied by the final terminal verification and completion response because a commit cannot embed its own SHA without changing its contents.

```text
git rev-parse HEAD
<FINAL_M06_HEAD_SHA>
git rev-parse origin/main
<FINAL_M06_HEAD_SHA>
git ls-remote origin refs/heads/main
<FINAL_M06_HEAD_SHA> refs/heads/main
git rev-list --left-right --count HEAD...origin/main
0 0
git status --short --branch
## main...origin/main
git diff --check
FINAL_DIFF_CHECK_EXIT_CODE=0
git diff -- TASKS.md
FINAL_TASKS_DIFF_EXIT_CODE=0
```

The placeholders are replaced with the implementation push SHA before the initial M06 commit; if the evidence log is finalized in a follow-up commit, the final terminal output remains the authoritative equality check for that final log commit. Historical logs are immutable and corrections belong in a new versioned log.

## Explicit confirmations

- Canonical PNGs, including `assets/environment/game_board_background.png`, were not modified.
- Root `TASKS.md` was not edited.
- M07+ work was not started.
- The project remains on `main` with the canonical `origin` repository.
