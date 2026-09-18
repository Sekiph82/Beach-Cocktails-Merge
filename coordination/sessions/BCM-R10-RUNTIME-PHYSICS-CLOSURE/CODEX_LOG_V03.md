# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Codex Log V03

Status: IMPLEMENTATION_COMPLETE / AWAITING_INDEPENDENT_AUDIT

## Authority and scope

- Work item: BCM-R10-RUNTIME-PHYSICS-CLOSURE.
- Prompt: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V05.md`.
- Criteria read before editing: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V05.md`.
- V05 superseded R10 V01-V04.
- `TASKS.md`, ChatGPT-owned prompt/audit/criteria/policy files, historical logs, canonical PNGs and M08+ work were not edited.

## Sync-first preflight

Workspace: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Remote:

```text
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
```

Before editing, the required preflight found local HEAD behind origin by six commits. No destructive sync command was used.

```text
git rev-list --left-right --count HEAD...origin/main
0 6
git merge --ff-only origin/main
Fast-forward to e8da4548f590260c6568c51797eb627b76bbc7f5
```

Synchronized start HEAD:

```text
e8da4548f590260c6568c51797eb627b76bbc7f5
```

The pre-existing owner-dirty paths were preserved and never staged:

```text
docs/evidence/m06_r07/canonical_720x1280.png
docs/evidence/m06_r07/canonical_720x1280_runtime_overlay.png
docs/evidence/m06_r07/shorter_wider_800x1280.png
docs/evidence/m06_r07/shorter_wider_800x1280_runtime_overlay.png
docs/evidence/m06_r07/taller_720x1440.png
docs/evidence/m06_r07/taller_720x1440_runtime_overlay.png
project.godot
```

## Owner screenshot measurement

The attached owner annotation was read-only evidence. It was not copied into the repository and was not modified.

```text
path=C:/Users/sekip/OneDrive/Resimler/Screenshots/Screenshot 2026-09-18 070858.png
sha256=417AACC6A3B0916799D41F77BBD985C2300E20F7E6E9DCE6C3DBE0CD6D711A41
bytes=2086281
dimensions=2560x1600
```

Measured screenshot game viewport: `x=896..1663`, `y=128..1493`, width `768`, height `1366`, screenshot/runtime scale approximately `1.066667`. Neutral-bright connected white annotation tracing mapped to these source-space samples through the canonical `1024x1536` background transform:

```text
rear_white_line y=478.0 left=199.0 right=833.0
rear_depth_1   y=587.0 left=149.0 right=880.0
rear_depth_2   y=644.0 left=124.0 right=905.0
rear_depth_3   y=734.0 left=85.0  right=942.0
```

The retained machine-readable measurement is `docs/evidence/r10/v05_owner_envelope_measurement.json`.

## Implementation

Changed files in the bounded implementation commit:

```text
scripts/game_manager.gd
scripts/merge_queue.gd
tests/m06_r06_full_tabletop_probe.gd
tests/r10_v05_three_sided_envelope_probe.gd
docs/evidence/r10/v05_owner_envelope_measurement.json
```

Implementation details:

1. Replaced the old rear source boundary `457.0` with the owner-defined inward rear boundary `478.0`. Production `rear_table_y`, `table_top_y`, TopRail and the existing clamp/solver path use this one common rear boundary.
2. Rebuilt the source-space rails from the owner samples and a conservative blend into the accepted lower table:

```text
left  = (199,478), (149,587), (124,644), (85,734), (60,800), (20,1000), (8,1186)
right = (833,478), (880,587), (905,644), (942,734), (964,800), (1002,1000), (1016,1186)
```

3. Kept rear contact exact: `get_rear_target_center_y()` returns `rear_table_y` without radius/body/sprite/per-level Y additions.
4. Added the V05 Solution 1 merge correction in `MergeQueue._do_merge()`: immediately after the final merged collider exists, the new drink X is clamped using `get_horizontal_bounds_at_y(new_drink.position.y, new_drink.radius)`. Y and inherited momentum are untouched.
5. Redirected the active M06 piecewise geometry probe to the V05 independent measurement dataset. No historical audit/log was rewritten.

Implementation commit:

```text
045705a311864b1ab7498e88990c46b116b80e71
```

## Focused V05 evidence

Command:

```text
godot_console.exe --headless --path . --script res://tests/r10_v05_three_sided_envelope_probe.gd
```

Exact result:

```text
R10_V05_ENVELOPE rear_table_y=398.333 rear_rails=(99.167,627.500) bottom_y=988.333
R10_V05_REAR level=L01 radius=20.000 rear_target_y=398.333
R10_V05_REAR level=L06 radius=42.000 rear_target_y=398.333
R10_V05_REAR level=L12 radius=90.000 rear_target_y=398.333
R10_V05_WALL_MERGE side=left input_x=60.909 result_x=63.909 result_radius=23.000 valid_bounds=(63.909,660.257) expected_tangent_x=63.909 contained=true tangent=true
R10_V05_WALL_MERGE side=right input_x=663.257 result_x=660.257 result_radius=23.000 valid_bounds=(63.909,660.257) expected_tangent_x=660.257 contained=true tangent=true
R10_V05_THREE_SIDED_ENVELOPE_RESULT=PASS
exit=0
```

## Final active regression suite

All commands below ran against implementation commit `045705a` before this log commit. Each returned exit code `0` and the exact result shown:

```text
tests/m01_contract_probe.gd                 M01_PROBE_RESULT=PASS
tests/m02_physics_regression.gd             M02_PROBE_RESULT=PASS
tests/m03_economy_regression.gd             M03_PROBE_RESULT=PASS
tests/m04_asset_import_probe.gd             M04_GODOT_RESULT=PASS
tests/m05_sprite_integration_probe.gd       M05_PROBE_RESULT=PASS
tests/m06_r06_full_tabletop_probe.gd        M06_R07_PROBE_RESULT=PASS
tests/m07_hud_composition_probe.gd          M07_PROBE_RESULT=PASS
tests/m07_r06_owner_layout_probe.gd         M07_R06_PROBE_RESULT=PASS
tests/r10_v05_three_sided_envelope_probe.gd R10_V05_THREE_SIDED_ENVELOPE_RESULT=PASS
tests/r10_runtime_physics_closure_probe.gd  R10_RUNTIME_PHYSICS_CLOSURE_RESULT=PASS
```

Representative final R10 rear-motion lines:

```text
R10_REAR_MOTION label=rear-center-L01 level=L01 final=(360.0000,398.3333) rear_table_y=398.3333 target_error=0.0000 state=SETTLED
R10_REAR_MOTION label=rear-center-L06 level=L06 final=(360.0000,398.3333) rear_table_y=398.3333 target_error=0.0000 state=SETTLED
R10_REAR_MOTION label=rear-center-L12 level=L12 final=(360.0000,398.3333) rear_table_y=398.3333 target_error=0.0000 state=SETTLED
R10_RUNTIME_PHYSICS_CLOSURE_RESULT=PASS
```

Final no-input production runtime regression:

```text
command=godot_console.exe --headless --path . --script res://tests/r09_no_input_runtime_regression.gd
R09_NO_INPUT_OBSERVATION_SECONDS=30.5
R09_NO_INPUT_FINAL score=0 held=1 nonheld=0 total=1 merge_observed=false delivery_observed=false target_transition=false
R09_NO_INPUT_REGRESSION_RESULT=PASS
exit=0
```

Final desktop idle smoke:

```text
R10_DESKTOP_IDLE_OBSERVATION_SECONDS=10.0
R10_DESKTOP_IDLE_FINAL score=0 held=1 nonheld=0 total=1
R10_DESKTOP_IDLE_RESULT=PASS
exit=0
```

M01/M02/M03 preserved accepted 700 px/s launch, 180 px/s² deceleration, collision/momentum, merge chain/L12 cap, scoring/combo/To-Go economy, persistence, Game Over/restart and rapid-launch contracts. M07 probes preserved accepted BEST/SCORE centering, To-Go placement, NEXT, held-drink alignment, baked 2x6 progression and no guide line.

## Godot and hygiene checks

```text
godot_console.exe --headless --path . --editor --quit
GODOT_EDITOR_IMPORT_STARTUP_EXIT=0

--check-only res://scripts/game_manager.gd
exit=0
--check-only res://scripts/merge_queue.gd
exit=0
--check-only res://tests/r10_v05_three_sided_envelope_probe.gd
exit=0
--check-only res://tests/m06_r06_full_tabletop_probe.gd
exit=0

git diff --check
GIT_DIFF_CHECK_EXIT=0
```

Godot import emitted the existing warning that `res://original_reference` contains another `project.godot` and is ignored; import/startup still exited `0`.

The headless dummy renderer does not expose a viewport texture in this environment. Existing capture-oriented probes emitted `Parameter "t" is null` / `renderer_has_no_image` and could not save PNG captures, while their deterministic non-render assertions and process result lines remained PASS. No capture is claimed as retained visual proof from those headless runs. Interactive GUI/manual play was not performed in this bounded remediation; runtime behavior was checked through production-scene probes and idle smoke.

## Git state and ownership

Implementation commit was pushed separately before this log was created. The log is the second bounded commit.

```text
implementation start HEAD=e8da4548f590260c6568c51797eb627b76bbc7f5
implementation end HEAD=045705a311864b1ab7498e88990c46b116b80e71
branch=main
remote=origin
```

`TASKS.md` was not modified. The owner-dirty `project.godot` and six pre-existing M06-R07 PNG modifications remained unstaged and preserved. No canonical asset PNG was modified by this work.

The post-log remote-equality proof is returned with the completion handoff; independent ChatGPT audit remains pending.

AWAITING_AUDIT
