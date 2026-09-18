# BCM-R10 V07 Codex Execution Log

## Work item

- Work item: R10 V07 — independent 2D edge-contact dataset recovery.
- Authoritative execution prompt: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V07.md`.
- Read before implementation: `AGENTS.md`, `TASKS.md`, `coordination/AUDIT_POLICY.md`, `CHATGPT_AUDIT_V04.md`, and `CHATGPT_AUDIT_CRITERIA_V07.md`.
- Scope completed: replace the V06 algebraic edge-contact helper with an explicit independent L01-L12 dataset, preserve the frozen V05 three-sided envelope and gameplay contracts, add deterministic V07 evidence, and retain a normal-display GUI edge-contact capture.
- Status: `AWAITING_AUDIT`.

## Repository and synchronization

- Workspace: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Branch: `main`.
- Remote: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Initial preflight before synchronization:
  - `git status --short --branch` — `main...origin/main`; owner-dirty paths were present and preserved.
  - `git remote -v` — `origin` matched the canonical repository.
  - `git fetch origin main` — completed successfully.
  - `git rev-list --left-right --count HEAD...origin/main` — `0 5` before reconciliation.
  - `git merge --ff-only origin/main` — completed successfully; synchronized start HEAD was `277c95c5859abd4c072065a1313e27f4db39ab45`.
- The pre-existing owner-dirty paths were not staged or modified by this work:
  - `project.godot`
  - `docs/evidence/m06_r07/canonical_720x1280.png`
  - `docs/evidence/m06_r07/canonical_720x1280_runtime_overlay.png`
  - `docs/evidence/m06_r07/shorter_wider_800x1280.png`
  - `docs/evidence/m06_r07/shorter_wider_800x1280_runtime_overlay.png`
  - `docs/evidence/m06_r07/taller_720x1440.png`
  - `docs/evidence/m06_r07/taller_720x1440_runtime_overlay.png`
- `TASKS.md` was read and remained byte-for-byte untouched.
- No canonical PNG was modified. No ChatGPT-owned prompt, audit, criteria, or policy file was modified. No M08+ work was started. No `guide_line` was added.

## Implementation commit

- Implementation commit: `faf2b2b34c997cd0e8495a13330f0ec1ad25078e`.
- Implementation commit was pushed to `origin/main` before this log was created.
- Changed implementation/evidence files:
  - `scripts/drink.gd`
  - `docs/evidence/r10/v07_independent_edge_contact_measurements.json`
  - `tests/r10_v07_independent_edge_dataset_probe.gd`
  - `tests/r10_v07_gui_edge_capture.gd`
  - `docs/evidence/r10/v07_gui_edge_contacts_720x1280.png`

## V07 implementation summary

- Added explicit `Drink.TABLE_EDGE_CONTACT_HALF_WIDTHS` values for all twelve cocktail levels:
  - `L01..L12 = [14.3, 15.6, 20.6, 17.1, 23.7, 24.0, 29.7, 36.3, 36.1, 50.9, 51.3, 55.4]` runtime screen pixels.
- Removed the V06 production derivation that reduced the table-edge footprint from `VISIBLE_BODY_WIDTH_PX * visual_scale_for_level(...)` and therefore tracked the visual/collider scale algebraically.
- The new production helper returns the explicit per-level value and does not reference collider radii, `visual_scale_for_level`, `VISIBLE_BODY_WIDTH_PX`, or an equivalent runtime formula.
- Drink-to-drink collision radii remain unchanged. `RigidBody2D.CCD_MODE_CAST_SHAPE` remains enabled.
- Side limits and V05 post-merge containment continue to use the table-edge contact helper, while the full drink collider remains the drink-to-drink collision primitive.
- The rear rule remains exact: `rear_target_y == rear_table_y`; no radius, sprite extent, garnish, or per-level rear-Y offset was added.
- The frozen V05 left, right, and rear playable-envelope coordinates were not changed.

## Independent measurement evidence

File: `docs/evidence/r10/v07_independent_edge_contact_measurements.json`.

- Measurement basis: direct alpha-span measurements of the lower visible glass/container contact band in each canonical cocktail PNG.
- Alpha threshold: `32`.
- Body band: lower `95%` of the recorded visible body bounding box, with the maximum center contact span measured around the body centerline.
- Excluded from the contact footprint: garnish, straw, fruit, flowers, leaves, umbrellas, and transparent sprite margins.
- The JSON records all twelve texture paths, dimensions, SHA-256 values, visible-body bboxes, source contact widths, direct runtime half-width values, and unchanged collider radii.
- Source contact widths recorded in the evidence dataset are:
  - `L01 492`, `L02 490`, `L03 478`, `L04 422`, `L05 359`, `L06 400`, `L07 348`, `L08 398`, `L09 364`, `L10 442`, `L11 391`, `L12 437` pixels.
- The runtime dataset values are explicit screen-space measurements and are materially narrower than the unchanged collider radii. They are not generated from the collider radii, visual scale, or a production formula.

## Focused V07 probe

Command shape: Godot 4.7.x headless parse/check-only followed by runtime execution of `tests/r10_v07_independent_edge_dataset_probe.gd`.

Exact representative output:

```text
R10_V07_BODY level=L01 measured_source_contact_width_px=492.0 edge_contact_half_width=14.3 collider_radius=20.0 reduction=5.7 ccd=2
R10_V07_BODY level=L06 measured_source_contact_width_px=402.0 edge_contact_half_width=24.0 collider_radius=42.0 reduction=18.0 ccd=2
R10_V07_BODY level=L12 measured_source_contact_width_px=437.0 edge_contact_half_width=55.4 collider_radius=90.0 reduction=34.6 ccd=2
R10_V07_WALL_MERGE side=left raw_merge_x=15.810 edge_half_width=15.6 valid_range=(17.110,703.900) corrected_x=17.110 contained=true corrected=true
R10_V07_WALL_MERGE side=right raw_merge_x=705.200 edge_half_width=15.6 valid_range=(17.110,703.900) corrected_x=703.900 contained=true corrected=true
R10_V07_CENTER_NOOP raw_merge_x=360.505 corrected_x=360.505 delta=0.000
R10_V07_INDEPENDENT_EDGE_DATASET_RESULT=PASS
V07_EXIT_CODE=0
```

The probe also verifies, for every L01-L12, texture dimensions, alpha-band measurement, exact dataset equality, unchanged collider radius, material footprint reduction, exact rear targeting, and representative cast-shape CCD. L01, L06, and L12 are exercised at both side contacts. Left-wall, right-wall, and center no-op merge cases are covered.

## Full regression and focused runtime evidence

The active M01-M07 regression suite completed with the following results; each listed probe exited `0`:

```text
M01 PASS exit=0
M02 PASS exit=0
M03 PASS exit=0
M04 PASS exit=0
M05 PASS exit=0
M06_R07 PASS exit=0
M07 PASS exit=0
M07_R06 PASS exit=0
```

Additional focused checks completed successfully:

```text
R09_NO_INPUT_FINAL score=0 held=1 nonheld=0 total=1 merge_observed=false delivery_observed=false target_transition=false
R09_NO_INPUT_REGRESSION_RESULT=PASS
R09_NO_INPUT_EXIT_CODE=0

R10_DESKTOP_IDLE_FINAL score=0 held=1 nonheld=0 total=1
R10_DESKTOP_IDLE_RESULT=PASS
R10_DESKTOP_EXIT_CODE=0

R10 runtime physics closure probe: PASS exit=0
R10 V05 three-sided envelope probe: PASS exit=0
R10 V07 independent edge dataset probe: PASS exit=0
```

The no-input checks prove no unintended auto-fire, delivery, merge, or synthetic test-drink leakage during the tested idle interval.

## Godot, GUI, and hygiene evidence

Godot/editor and check-only evidence:

```text
godot_console.exe --headless --path . --editor --quit: exit=0
res://scripts/drink.gd CHECK_ONLY_EXIT_CODE=0
res://scripts/game_manager.gd CHECK_ONLY_EXIT_CODE=0
res://scripts/merge_queue.gd CHECK_ONLY_EXIT_CODE=0
res://tests/r10_v07_independent_edge_dataset_probe.gd CHECK_ONLY_EXIT_CODE=0
res://tests/r10_v07_gui_edge_capture.gd CHECK_ONLY_EXIT_CODE=0
GIT_DIFF_CHECK_EXIT_CODE=0
```

Godot emitted only the known warning that another `project.godot` under `res://original_reference` was ignored; the editor/import command exited successfully.

Normal-display GUI capture:

```text
R10_V07_GUI_CAPTURE label=edge_contacts dimensions=720x1280 error=0 path=res://docs/evidence/r10/v07_gui_edge_contacts_720x1280.png
R10_V07_GUI_CAPTURE_RESULT=PASS
GUI_CAPTURE_CONSOLE_EXIT_CODE=0
```

The capture was produced by the normal production main scene in a non-headless OpenGL Godot run and retained as builder evidence. It places representative L01, L06, and L12 drinks at the independent left/right contact positions. Owner visual acceptance was not performed by Codex; the capture is evidence for the independent audit, not an acceptance verdict.

`git diff --check` exited `0`. Its only output was the expected LF-to-CRLF warning for the pre-existing owner-dirty `project.godot` and the changed `scripts/drink.gd`.

## Limitations and audit handoff

- The historical V06 algebraic-footprint probe and the historical R09 pixel-boundary probe were not rewritten; they are superseded by the V07 dataset/probe and frozen V05 envelope contract. Historical files remain unchanged.
- Codex did not self-audit or assign an acceptance verdict. Independent ChatGPT audit remains required.
- Manual owner acceptance of the GUI capture remains unperformed/unverified.
- The owner-dirty `project.godot` and six pre-existing M06-R07 evidence images remain in the worktree by design and are not part of the V07 commit.

## Publication and final equality

- This log is committed separately after the implementation commit and is pushed to `origin/main`.
- The final equality block below is filled from the post-push verification after the log commit.
- Required final values are `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main`; they must match exactly.
- `TASKS.md` was not modified.
- Final handoff: `AWAITING_AUDIT`.
