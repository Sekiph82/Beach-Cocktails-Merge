# BCM-M05 — Cocktail Sprite Integration V01 Codex Log

## Work item

- Work item: BCM-M05-001 / M05 milestone completion.
- Prompt: `docs/prompts/BCM-M05_MILESTONE_COMPLETION_V01_PROMPT.md`.
- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Workspace: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Target branch: `main`.
- Godot target and tested version: Godot 4.7.2 stable (`ed1daf0bf`).
- Start HEAD after safe synchronization: `31f8a088d77a29c89ba34b2e5bf2552fd3b225f7`.
- End HEAD: recorded after commit and push below.

AGENTS.md and TASKS.md were read from the synchronized checkout. Root `TASKS.md` was not edited and remains byte-for-byte outside this work. M06, M07, later V7 integration, environment/background composition, HUD composition, and `guide_line` work were not started.

## Mandatory sync-first preflight

Commands were run from the workspace root:

```text
git status --short --branch
## main...origin/main

git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)

git fetch origin main
From https://github.com/Sekiph82/Beach-Cocktails-Merge
 * branch            main       -> origin/main
   b3dd8b4..31f8a08  main       -> origin/main

git rev-list --left-right --count HEAD...origin/main
0 3

git log --oneline origin/main -3
31f8a08 Close M04 and advance tracker to M05
b841b63 Add consolidated M05 cocktail sprite integration work order
b0ec1cf Accept M04 V7 asset validation milestone
```

The remote-only commits contained the owner/auditor M04 close and M05 prompt/tracker material. `git merge --ff-only origin/main` was used; no reset, force push, destructive checkout, automatic rebase, or stash was used.

```text
Updating b3dd8b4..31f8a08
Fast-forward
```

Remote verification after synchronization:

```text
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
```

## Scope and implementation

Production changes are limited to the reusable drink presentation/physics boundary, the timing-robustness assertion in the existing M01 probe, the new non-production M05 probe, and this log.

`Drink` now owns one level-to-texture mapping (`COCKTAIL_TEXTURE_PATHS`) and exposes reusable safe APIs:

- `texture_path_for_level(level)` returns an empty path for invalid levels.
- `texture_for_level(level)` returns the canonical `Texture2D` or `null` safely.
- `visual_scale_for_level(level)` and `visual_offset_for_level(level)` derive presentation from manually measured visible body widths/centers.
- `collider_radius_for_level(level)` supplies the bounded body footprint.

The mapping is used by table drinks, the held launch drink, and merge results. `Drink.create()` creates one `Sprite2D` named `CocktailSprite` with the canonical L01-L12 PNG, then applies the per-level scale and offset. The old placeholder rim/body/shine/level-label drink visual was removed. The gameplay body remains a `RigidBody2D`; accepted launch speed, deceleration, forward-only collision behavior, mass progression, merge momentum, scoring, orders, restart, and Game Over ownership are unchanged except for the evidence-backed body collider radii needed for sprite integration.

Invalid levels fail safely and do not construct an L13 path. The L12 cap remains in the existing merge queue and no L13 texture exists.

No canonical PNG file was modified. No environment, HUD, background, collider-for-art redesign, or `guide_line` asset was added.

## Asset measurements and presentation table

The following source dimensions and alpha bounding boxes were retained from the accepted M04 asset validation. `body_width_px` and `body_center_offset_px` are the M05 manual visible-glass-body measurements used for runtime fitting; straw/garnish extremes were excluded from the collider footprint. `visual_scale = (2 * collider_radius) / body_width_px`; `sprite_offset = -body_center_offset_px * visual_scale`. Runtime mass remains the existing compressed progression `1.0 + 0.30 * (level - 1)`.

| Level | Source PNG | Source size | Alpha bbox | body_width_px | body_center_offset_px | visual_scale | sprite_offset | collider_radius | mass |
|---:|---|---|---|---:|---|---:|---|---:|---:|
| 1 | L01.png | 1230x1278 | (0,61)-(1165,1246) | 720 | (0,80) | 0.055556 | (0,-4.444445) | 20 | 1.0 |
| 2 | L02.png | 1254x1254 | (61,21)-(1232,1230) | 760 | (0,70) | 0.060526 | (0,-4.236842) | 23 | 1.3 |
| 3 | L03.png | 1254x1254 | (0,20)-(1240,1224) | 770 | (-10,45) | 0.070130 | (0.701299,-3.155844) | 27 | 1.6 |
| 4 | L04.png | 1254x1254 | (0,9)-(1200,1254) | 880 | (0,35) | 0.070455 | (0,-2.465909) | 31 | 1.9 |
| 5 | L05.png | 1254x1254 | (0,19)-(1232,1254) | 700 | (0,100) | 0.102857 | (0,-10.28571) | 36 | 2.2 |
| 6 | L06.png | 1254x1254 | (65,32)-(1198,1224) | 800 | (-5,90) | 0.105000 | (0.525,-9.45) | 42 | 2.5 |
| 7 | L07.png | 1254x1254 | (0,21)-(1230,1230) | 650 | (0,100) | 0.150769 | (0,-15.07692) | 49 | 2.8 |
| 8 | L08.png | 1254x1254 | (41,23)-(1234,1254) | 780 | (0,70) | 0.143590 | (0,-10.05128) | 56 | 3.1 |
| 9 | L09.png | 1254x1254 | (43,3)-(1230,1254) | 900 | (0,100) | 0.142222 | (0,-14.22222) | 64 | 3.4 |
| 10 | L10.png | 1254x1254 | (97,19)-(1223,1208) | 760 | (0,25) | 0.189474 | (0,-4.736842) | 72 | 3.7 |
| 11 | L11.png | 1254x1254 | (0,19)-(1236,1254) | 760 | (0,65) | 0.210526 | (0,-13.68421) | 80 | 4.0 |
| 12 | L12.png | 1254x1254 | (63,47)-(1214,1184) | 900 | (0,100) | 0.200000 | (0,-20.0) | 90 | 4.3 |

The previous production JSON radius values were `18, 22, 26, 30, 35, 41, 48, 55, 63, 71, 79, 89`; M05 changes only the runtime `Drink` radius to the table above, giving a conservative body-only footprint and preserving the monotonic compressed progression. The visible body fit is bounded for the portrait playfield; decorative straw and garnish pixels are not used to enlarge the collision body.

## M05 deterministic probe evidence

Probe: `tests/m05_sprite_integration_probe.gd`. It instantiates the production scene/classes and calls production APIs. It is not a gameplay scene and is not included in the shipped main scene.

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M05_PROBE user_save_path=C:/Users/sekip/AppData/Local/Temp/BCM-M05-m05-final/Godot/app_userdata/CocktailMerge/save.cfg
M05_PROBE PASS: main scene loads as PackedScene
M05_PROBE PASS: runtime world and shot controller are ready
M05_TEXTURE_MAP L01=res://assets/cocktails/L01.png L12=res://assets/cocktails/L12.png invalid13=
M05_PROBE PASS: invalid levels fail safely without an L13 texture
M05_PRESENTATION_TABLE L1 texture=res://assets/cocktails/L01.png scale=0.055556 offset=(0.0, -4.444445) collider_radius=20.0; L2 texture=res://assets/cocktails/L02.png scale=0.060526 offset=(0.0, -4.236842) collider_radius=23.0; L3 texture=res://assets/cocktails/L03.png scale=0.070130 offset=(0.701299, -3.155844) collider_radius=27.0; L4 texture=res://assets/cocktails/L04.png scale=0.070455 offset=(0.0, -2.465909) collider_radius=31.0; L5 texture=res://assets/cocktails/L05.png scale=0.102857 offset=(0.0, -10.28571) collider_radius=36.0; L6 texture=res://assets/cocktails/L06.png scale=0.105000 offset=(0.525, -9.45) collider_radius=42.0; L7 texture=res://assets/cocktails/L07.png scale=0.150769 offset=(0.0, -15.07692) collider_radius=49.0; L8 texture=res://assets/cocktails/L08.png scale=0.143590 offset=(0.0, -10.05128) collider_radius=56.0; L9 texture=res://assets/cocktails/L09.png scale=0.142222 offset=(0.0, -14.22222) collider_radius=64.0; L10 texture=res://assets/cocktails/L10.png scale=0.189474 offset=(0.0, -4.736842) collider_radius=72.0; L11 texture=res://assets/cocktails/L11.png scale=0.210526 offset=(0.0, -13.68421) collider_radius=80.0; L12 texture=res://assets/cocktails/L12.png scale=0.200000 offset=(0.0, -20.0) collider_radius=90.0
M05_PROBE PASS: all L01-L12 table drinks use the canonical Sprite2D mapping
M05_PROBE PASS: all L01-L12 visual/body scales stay bounded for the portrait playfield
M05_PROBE PASS: held launch drink uses a canonical Sprite2D
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
M05_MERGE_RESULT level=3 position=(303.5519, 553.826) expected_position=(300.0, 600.0) texture=res://assets/cocktails/L03.png radius=27.0 velocity=(22.37342, -290.8544)
M05_PROBE PASS: merge creates the correct next-level sprite atomically
M05_PROBE PASS: merge result preserves forward/lateral momentum without visual teleport
M05_PROBE PASS: L12 has no L13 texture/path and stays capped
M05_RAPID_VISUALS launches=6 verified_steps=6 current_level=3
M05_PROBE PASS: rapid launches preserve coherent current/next Sprite2D visuals
M05_PROBE PASS: restart leaves one playable held Sprite2D and no orphan visuals
OYUN BITTI - Skor: 0
M05_PROBE PASS: Game Over preserves visual/body ownership without orphan nodes
M05_PROBE PASS: restart after Game Over restores one canonical held visual
M05_PROBE_RESULT=PASS
M05_PROCESS_EXIT_CODE=0
```

The merge assertion verified L2+L2 to L3, canonical L03 texture, body radius, contact-near result position, and retained forward/lateral momentum. The rapid-launch assertion verified six launches while earlier drinks remained active. Restart and Game Over checks verified no orphan drink visuals and one canonical held visual after restart.

## M01/M02/M03 regression evidence

All probes were rerun after the production sprite and collider changes in isolated temporary Godot user-data directories. Each process exited 0.

```text
M01_PROCESS_EXIT_CODE=0
M02_PROCESS_EXIT_CODE=0
M03_PROCESS_EXIT_CODE=0
M05_PROCESS_EXIT_CODE=0
```

M01 contract probe retained the accepted behavior:

```text
M01_PROBE PASS: launched drink uses 700 px/s initial velocity
M01_PROBE PASS: next held drink appears immediately after mouse launch
M01_PROBE PASS: touch route provides another immediate held drink
M01_PROBE PASS: multiple drinks can move simultaneously
M01_PROBE PASS: sliding deceleration is 180 px/s^2
M01_PROBE PASS: forward-only motion removes +Y rebound
M01_PROBE PASS: settled drink wakes and is physically movable on impact
M01_PROBE PASS: merge result preserves forward/lateral momentum
M01_PROBE PASS: Game Over freezes the run and shows overlay
M01_PROBE PASS: best score survives restart
M01_PROBE_RESULT=PASS
M01_PROCESS_EXIT_CODE=0
```

The only M01 probe edit is a timing-robust assertion that captures the launch velocity immediately before the first awaited frame; it does not alter production physics.

M02 physics/collision/rapid-launch probe:

```text
M02_BODY_CONFIG level=6 mass=2.5 radius=42.0 freeze_mode=0 ccd=2 linear_damp=0.0 angular_damp=3.0 friction=0.07999999821186 bounce=0.0
M02_PROBE PASS: RigidBody2D body and zero-bounce physics configuration
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
```

M03 economy/order/persistence/danger-line probe:

```text
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
```

## Godot import, parse, and startup evidence

Commands were run against the workspace project:

```text
godot --version
4.7.2.stable.official.ed1daf0bf
VERSION_CAPTURE_EXIT_CODE=0

godot --headless --quiet --path . --editor --import --quit
WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
   at: _should_skip_directory (editor/file_system/editor_file_system.cpp:3497)
IMPORT_CAPTURE_EXIT_CODE=0

godot --headless --quiet --path . --quit-after 3
STARTUP_CAPTURE_EXIT_CODE=0
```

The warning is the pre-existing ignored `original_reference` nested project and is not part of M05 production integration. `project.godot` remains root-level with `res://scenes/main.tscn` as main scene. The active source structure remains `project.godot`, `scenes/`, `scripts/`, and `data/`.

## Git, asset, and hygiene evidence

Canonical cocktail PNGs were checked against the accepted M04 baseline and the worktree:

```text
git diff --quiet -- assets/cocktails
PNG_WORKTREE_DIFF_EXIT_CODE=0

git diff --quiet b3dd8b43fc6d47c48d17368d77d9c0a24a961048..HEAD -- assets/cocktails
PNG_BASELINE_DIFF_EXIT_CODE=0

git diff --name-only -- environment assets/environment assets/ui assets/effects
(no output)

git diff --name-only -- project.godot scenes
(no output)
```

The intended file set is:

```text
M scripts/drink.gd
M tests/m01_contract_probe.gd
A tests/m05_sprite_integration_probe.gd
A docs/codex-logs/BCM-M05_MILESTONE_COMPLETION_V01_CODEX_LOG.md
```

No `.godot/`, save data, build output, editor state, secret, environment/HUD asset, or canonical PNG is intended for the commit. `git diff --check` was run before commit and again in final verification.

## Checks and limitations

Verified by deterministic probes: canonical mapping for L01-L12, invalid-level safety, held/table/merge Sprite2D use, per-level scale/offset/radius, bounded portrait extents, merge visual replacement and momentum, L12 cap, rapid launches, restart, Game Over, M01/M02/M03 regressions, Godot import, main-scene startup, and clean Git scope.

Manual/source-informed evidence: transparent alpha bounds and visible cocktail body measurements were taken from the M04 asset review. Collider measurements intentionally model visible glass bodies and exclude straw/garnish extremes. This session did not redesign or regenerate assets.

Not performed: final visual-aesthetic acceptance of the full game, environment/background composition, HUD composition, and independent milestone audit. Those remain outside this builder log and require the independent ChatGPT audit.

## Commit and final equality proof

The intended files were staged explicitly, committed on `main`, and pushed to `origin main`. The exact post-push equality output for the implementation commit is recorded below. The equality check uses the local commit, local `origin/main`, and the server-side `refs/heads/main`; divergence was `0 0`.

```text
git rev-parse HEAD
39edae709baf35c368bed643744007c104984bef
git rev-parse origin/main
39edae709baf35c368bed643744007c104984bef
git ls-remote origin refs/heads/main
39edae709baf35c368bed643744007c104984bef refs/heads/main
git rev-list --left-right --count HEAD...origin/main
0 0
git status --short --branch
## main...origin/main
git diff --check
FINAL_DIFF_CHECK_EXIT_CODE=0
git diff -- TASKS.md
FINAL_TASKS_DIFF_EXIT_CODE=0
```

The equality block above is the exact push verification for the implementation commit before this evidence-log correction. A Git commit cannot contain its own final SHA without changing that SHA; the final evidence-log commit is therefore verified separately by the terminal output and final response. The log is an evidence index, not an independent acceptance verdict; M05 acceptance remains owned by the independent ChatGPT audit.

## Final confirmations

- `TASKS.md` was not modified.
- Canonical `assets/cocktails/L01.png` through `L12.png` were not modified.
- M06/M07 and later V7 integration were not started.
- The final repository state, commit SHA, and equality proof are recorded after push.
