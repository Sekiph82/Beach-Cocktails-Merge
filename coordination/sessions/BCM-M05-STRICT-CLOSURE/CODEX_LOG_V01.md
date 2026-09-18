# BCM-M05-STRICT-CLOSURE — Codex Log V01

## Scope

- Work item: `BCM-M05-STRICT-CLOSURE`
- Prompt: `coordination/sessions/BCM-M05-STRICT-CLOSURE/CHATGPT_EXECUTION_PROMPT_V01.md`
- Criteria: `coordination/sessions/BCM-M05-STRICT-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01.md`
- Mode: evidence-only remediation
- Production gameplay, R11 table-edge behavior, collider radii, canonical PNGs, HUD, merge/economy behavior and `TASKS.md` were not modified.

## Synchronization

Workspace: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
Branch: `main`
Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`

Preflight before synchronization:

```text
git status --short --branch
## main...origin/main
 M docs/evidence/m06_r07/canonical_720x1280.png
 M docs/evidence/m06_r07/canonical_720x1280_runtime_overlay.png
 M docs/evidence/m06_r07/shorter_wider_800x1280.png
 M docs/evidence/m06_r07/shorter_wider_800x1280_runtime_overlay.png
 M docs/evidence/m06_r07/taller_720x1440.png
 M docs/evidence/m06_r07/taller_720x1440_runtime_overlay.png
 M project.godot
?? docs/BCM-R11_MASA_KENARI_DUZELTMESI_RAPORU.md
?? docs/MASA_DEGISIRSE_YAPILACAKLAR.md

git rev-parse HEAD
9d6d8950da5f62f6c22d495f58414d70d034d893

git rev-parse origin/main
571c6a99d4c01462d0ce3222a133348044325905

git rev-list --left-right --count HEAD...origin/main
0 5
```

`git fetch origin main` completed successfully. `git merge --ff-only origin/main` reconciled the checkout to `571c6a99d4c01462d0ce3222a133348044325905` without overwriting the dirty owner files. Remote `TASKS.md`, M05 locked criteria/prompt/audit and the R11 audit update were preserved.

## Independent measurement method

The independent phase ran first:

```text
python tools/m05_strict_closure_evidence.py
M05_STRICT_INDEPENDENT levels=12 output=docs/evidence/m05/strict_closure_independent_measurements.json
M05_STRICT_INDEPENDENT production_constants_read_before_output=false
M05_STRICT_INDEPENDENT_RESULT=PASS
```

The generator reads only canonical `assets/cocktails/L01.png`–`L12.png` pixels. It does not import or parse `scripts/drink.gd`, production constants, production hulls, or production helpers before writing the independent dataset. Independently selected visual review windows exclude the visible garnish/straw regions; alpha-positive pixels at threshold `32` inside those windows produce deterministic inclusive body bounds, widths, heights and center offsets. Each record contains the source path, SHA-256, dimensions, body bounds, pixel count, exclusion method, ambiguity note, shape category and visual rationale.

Shape review in the independent records:

- L04/L06: martini/coupe;
- L03/L07/L11: highball/tall;
- L05/L08/L10: goblet/rounded;
- L09: coconut/special container;
- L12: pineapple/special container;
- L01/L02: short tumblers/rocks glasses.

After the independent file was written and frozen, the comparison phase ran:

```text
python tools/m05_strict_closure_compare.py
M05_STRICT_COMPARISON levels=12 output=docs/evidence/m05/strict_closure_production_comparison.json
M05_STRICT_OVERLAY representatives=L04,L03,L08,L09,L12 output=docs/evidence/m05/strict_closure_contact_overlays.png
M05_STRICT_PROTECTED_R11_SYMBOLS=PASS
M05_STRICT_COMPARISON_RESULT=PASS
```

The comparison reports per level: independent width versus production width, center-offset differences, unchanged collider radius/diameter, current visual scale, independently estimated runtime body width and collider-to-body ratio. It reads production values only after the independent dataset exists. The protected symbol blocks match the R11 baseline commit `9d6d8950da5f62f6c22d495f58414d70d034d893` byte-for-byte:

`COCKTAIL_TEXTURE_PATHS`, `VISIBLE_BODY_WIDTH_PX`, `BOUNDARY_CONTACT_HULL_SOURCE_PX`, `VISIBLE_BODY_CENTER_OFFSET_PX`, `HELD_BODY_FOOT_SOURCE_PX`, `COLLIDER_RADII`.

Evidence hashes:

```text
docs/evidence/m05/strict_closure_independent_measurements.json
D501E9A0BEEC70725855A0FF5E190A8761DFEB4B48BA7658106E59F8F3D953D0
docs/evidence/m05/strict_closure_production_comparison.json
6B821C48A95F18B30016472A2E68A13CD255DC3AA631738D7823A30D5746E81B
docs/evidence/m05/strict_closure_contact_overlays.png
2F0CE9EA779DDB7A54394858659B8E9EFA4868608B16F1874F9F34EDE0697C92
```

The representative overlay contains L04 martini/coupe, L03 highball, L08 goblet, L09 coconut and L12 pineapple. Red rectangles are the independently measured body bounds after the current visual transform, blue circles are the unchanged current colliders, and yellow crosses mark independent body centers. The overlay was opened and visually checked as builder evidence; independent acceptance remains the auditor's responsibility.

## Focused strict-closure probe

```text
python tests/m05_strict_closure_probe.py
M05_STRICT_PROBE PASS: independent dataset exists
M05_STRICT_PROBE PASS: comparison dataset exists
M05_STRICT_PROBE PASS: exactly 12 independent records exist
M05_STRICT_PROBE PASS: no L13 texture exists
M05_STRICT_PROBE PASS: generator has no production import
M05_STRICT_PROBE PASS: generator has no production measurement symbols
M05_STRICT_PROBE PASS: independent phase is before production comparison
M05_STRICT_PROBE PASS: generator records production-free provenance
M05_STRICT_PROBE PASS: all shape classifications have rationale
M05_STRICT_PROBE PASS: all canonical hashes match current PNGs
M05_STRICT_PROBE PASS: all source dimensions are present
M05_STRICT_PROBE PASS: comparison has 12 records
M05_STRICT_PROBE PASS: comparison is post-freeze
M05_STRICT_PROBE PASS: comparison contains non-circular differences
M05_STRICT_PROBE PASS: representative overlay covers five required families
M05_STRICT_PROBE PASS: protected R11 symbols match
M05_STRICT_PROBE PASS: texture mapping remains 12 levels
M05_STRICT_PROBE_RESULT=PASS
exit code: 0
```

## Active regression and Godot evidence

All active non-superseded M01–M07/R09/R11 checks requested by the prompt passed:

| Command | Result |
|---|---:|
| `godot_console.exe --headless --path . --script tests/m01_contract_probe.gd --quit` | 0 |
| `godot_console.exe --headless --path . --script tests/m02_physics_regression.gd --quit` | 0 |
| `godot_console.exe --headless --path . --script tests/m03_economy_regression.gd --quit` | 0 |
| `godot_console.exe --headless --path . --script tests/m04_asset_import_probe.gd --quit` | 0 |
| `godot_console.exe --headless --path . --script tests/m05_sprite_integration_probe.gd --quit` | 0 |
| `godot_console.exe --headless --path . --script tests/m07_hud_composition_probe.gd --quit` | 0 |
| `godot_console.exe --headless --path . --script tests/m07_r06_owner_layout_probe.gd --quit` | 0 |
| `godot_console.exe --headless --path . --script tests/r09_no_input_runtime_regression.gd --quit` | 0 |
| `godot_console.exe --headless --path . --script tests/r10_desktop_idle_smoke.gd --quit` | 0 |
| `godot_console.exe --headless --path . --script tests/r10_v10_v09_failure_repro.gd --quit` | 0 |
| `--check-only --script scripts/drink.gd` | 0 |
| `--check-only --script scripts/game_manager.gd` | 0 |
| `--check-only --script scripts/merge_queue.gd` | 0 |
| `--check-only --script scripts/shot_controller.gd` | 0 |
| `godot_console.exe --headless --editor --path . --quit` | 0 |
| `godot_console.exe --headless --path . --quit-after 5` | 0 |
| `git diff --check` | 0 |

Godot version: `4.7.2.stable.official.ed1daf0bf`.

The R11 audit marks historical R10 full-silhouette probes as superseded by the owner-accepted table-plane footprint solution. No superseded probe was rewritten or used as a current acceptance gate.

## Files added by this bounded closure

- `docs/evidence/m05/strict_closure_contact_overlays.png`
- `docs/evidence/m05/strict_closure_independent_measurements.json`
- `docs/evidence/m05/strict_closure_method.md`
- `docs/evidence/m05/strict_closure_production_comparison.json`
- `tests/m05_strict_closure_probe.py`
- `tools/m05_strict_closure_compare.py`
- `tools/m05_strict_closure_evidence.py`
- `coordination/sessions/BCM-M05-STRICT-CLOSURE/CODEX_LOG_V01.md`

No production implementation file, canonical PNG, `TASKS.md`, `AGENTS.md`, coordination prompt/criteria/audit file, old evidence file, R11 file, `project.godot`, or Turkish document was changed or staged.

## Git publication

Evidence/test implementation commit before this log: `4bc5c2c245974b0d9249be8db8e333280d1f7398`.

The log is committed as a separate immutable documentation commit so the evidence commit SHA can be recorded without modifying the evidence after measurement. The final log-commit SHA and the final local/origin/live-remote equality are returned in the completion handoff after push.

`TASKS.md` was not modified by Codex.

Status: `AWAITING_AUDIT`.
