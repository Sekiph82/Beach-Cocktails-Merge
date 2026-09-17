# BCM-M07-R04 Codex Execution Log V01

Status: `IMPLEMENTATION_COMPLETE / AWAITING_AUDIT`

This is builder evidence only. It is not the independent acceptance audit and does not update `TASKS.md`.

## Authority and scope

- Work item: BCM-M07-R04.
- Authoritative remediation prompt: `coordination/sessions/BCM-M07-R04/CHATGPT_REMEDIATION_PROMPT_V02.md`.
- Read before editing: `AGENTS.md`, `coordination/AUDIT_POLICY.md`, `TASKS.md`, `coordination/sessions/BCM-M07-R03/CHATGPT_AUDIT_V02.md`, and `coordination/sessions/BCM-M07-R04/CHATGPT_AUDIT_CRITERIA_V02.md`.
- Start HEAD after the mandatory fast-forward: `9f547f43b02f87447cd710c2b5c20da4948fd04d`.
- Branch: `main`.
- Remote: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

## Sync-first preflight

Executed from `C:\Users\sekip\Desktop\Beach Cocktails - Merge`:

```text
git status --short --branch
## main...origin/main
git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
git fetch origin main
FETCH_EXIT_CODE=0
git rev-list --left-right --count HEAD...origin/main
0 13
git merge --ff-only origin/main
FF_MERGE_EXIT_CODE=0
```

The checkout was clean before the safe fast-forward. No reset, rebase, force-push, checkout restore, or stash was used.

## Implementation

### Fixed score typography

- `BEST_SCORE_FIXED_FONT_SIZE = 20` and `SCORE_FIXED_FONT_SIZE = 20` are fixed production constants.
- `_score_display_text()` clamps the visible contract to `0..9999999`; it never changes font size based on digit count.
- Runtime checks exercised `0`, `321`, `24380`, `999999`, and `9999999` for both panels.
- At 20 px, the seven-digit visible bound was `[62.00,68.50,83.00,30.00]` inside the measured `[45.00,55.00,116.00,52.00]` value box.

### To-Go content and ropes

- Removed the runtime To-Go level/name label entirely.
- `_refresh_merge_target_visual()` now supplies only the target cocktail texture and reward digits; reward text is `%d` with no leading plus.
- Focused runtime checks passed targets L06-L12 with rewards `1000`, `1800`, `3000`, `5000`, `8000`, `12000`, `18000`.
- Target alpha bounds after the production placement adjustment remained inside `[30.00,78.00,150.00,100.00]` with no reward overlap.
- Two non-interactive `Line2D` continuation segments are siblings of the HUD, behind artwork (`z_index=-2`), and run from viewport `y=0` to the baked panel join at `y=19`.
- Canonical rope measurements: left x `302.460`, right x `418.380`; wider portrait left x `342.460`, right x `458.380`; all have top y `0.000`.

### Held cocktail body-foot alignment

- Added visual-only held-body foot anchors in `scripts/drink.gd` using the existing M05 visible-glass measurement basis; no collider radius, mass, launch speed, deceleration, collision, merge, or economy constant was changed.
- Held previews use the accepted launch y even when a high-level collision footprint would exceed near-rail clearance while held; settled/physics bodies retain the normal board clamp.
- `HELD_BODY_FOOT_SOURCE_PX` is `[476.0,495.5,431.5,477.5,428.0,478.0,410.5,443.0,470.5,453.0,443.0,498.0]` and visual baseline offset is `42.0` px.
- Focused runtime probe measured L01-L12 baseline spread `0.000` px at all three required viewports.

## Focused M07-R04 probe

Command:

```text
godot_v4.7.2-stable_win64_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tests/m07_r04_focused_probe.gd
```

Exact retained result markers:

```text
M07_R04_PROBE PASS: M07-R04 independent layout dataset loads
M07_R04_PROBE PASS: M07-R04 main scene loads
M07_R04_PROBE PASS: canonical_720x1280 fixed score font fits 0/321/24380/999999/9999999
M07_R04_PROBE PASS: canonical_720x1280 score display enforces seven-digit maximum
M07_R04_PROBE PASS: canonical_720x1280 To-Go contains target and digits-only reward for L06-L12
M07_R04_PROBE PASS: canonical_720x1280 To-Go ropes attach viewport top to baked anchors
M07_R04_PROBE PASS: canonical_720x1280 NEXT L01-L12 alpha bounds fit measured cream window
M07_R04_PROBE PASS: canonical_720x1280 held L01-L12 body bottoms share launch baseline
M07_R04_PROBE PASS: canonical_720x1280 preserves M06 danger/launch coordinates
M07_R04_PROBE PASS: taller_720x1440 fixed score font fits 0/321/24380/999999/9999999
M07_R04_PROBE PASS: taller_720x1440 To-Go contains target and digits-only reward for L06-L12
M07_R04_PROBE PASS: taller_720x1440 To-Go ropes attach viewport top to baked anchors
M07_R04_PROBE PASS: taller_720x1440 NEXT L01-L12 alpha bounds fit measured cream window
M07_R04_PROBE PASS: taller_720x1440 held L01-L12 body bottoms share launch baseline
M07_R04_PROBE PASS: taller_720x1440 preserves M06 danger/launch coordinates
M07_R04_PROBE PASS: shorter_wider_800x1280 fixed score font fits 0/321/24380/999999/9999999
M07_R04_PROBE PASS: shorter_wider_800x1280 To-Go contains target and digits-only reward for L06-L12
M07_R04_PROBE PASS: shorter_wider_800x1280 To-Go ropes attach viewport top to baked anchors
M07_R04_PROBE PASS: shorter_wider_800x1280 NEXT L01-L12 alpha bounds fit measured cream window
M07_R04_PROBE PASS: shorter_wider_800x1280 held L01-L12 body bottoms share launch baseline
M07_R04_PROBE PASS: shorter_wider_800x1280 preserves M06 danger/launch coordinates
M07_R04_PROBE_RESULT=PASS
M07_R04_FOCUSED_EXIT_CODE=0
```

## Retained render evidence

The focused probe retained clean and visible-bounds runtime screenshots at:

- `docs/evidence/m07_r04/canonical_720x1280.png` and `_visible_bounds.png` (`720x1280`).
- `docs/evidence/m07_r04/taller_720x1440.png` and `_visible_bounds.png` (`720x1440`).
- `docs/evidence/m07_r04/shorter_wider_800x1280.png` and `_visible_bounds.png` (`800x1280`).

The focused evidence sheet command was:

```text
python tools/m07_r04_evidence_sheets.py
M07_R04_SHEETS_PASS cases=3 fixed_score=PASS to_go_l06_l12=PASS next_l01_l12=PASS held_l01_l12=PASS
M07_R04_SHEETS_EXIT_CODE=0
```

Retained sheets:

- `docs/evidence/m07_r04/fixed_score_fit_sheet.png`
- `docs/evidence/m07_r04/to_go_l06_l12_fit_sheet.png`
- `docs/evidence/m07_r04/next_l01_l12_fit_sheet.png`
- `docs/evidence/m07_r04/held_l01_l12_body_anchor_sheet.png`

These sheets are evidence composites. Canonical PNG files were read only; they were not modified.

## M07 production probe

Command:

```text
godot_v4.7.2-stable_win64_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tests/m07_hud_composition_probe.gd
```

Exact result markers:

```text
M07_PROBE PASS: canonical progression has no runtime Panel/StyleBox cell frames
M07_PROBE PASS: canonical exactly one active To-Go panel/target/reward
M07_PROBE PASS: canonical exactly one Next panel shows true next texture
M07_PROBE PASS: canonical progression is intentional 2x6 order top L07-L12 / bottom L01-L06 with no L13
M07_PROBE PASS: canonical danger/launch remain at independent M06 coordinates
M07_PROBE PASS: canonical no guide-line or permanent prototype hint
M07_PROBE PASS: canonical cocktail HUD consumers use shared M05 level mapping
M07_PROBE PASS: canonical rapid launch keeps current held sprite and Next synchronized
M07_PROBE PASS: taller_720x1440 rapid launch keeps current held sprite and Next synchronized
M07_PROBE PASS: shorter_wider_800x1280 rapid launch keeps current held sprite and Next synchronized
M07_PROBE_RESULT=PASS
M07_HUD_PROBE_EXIT_CODE=0
```

## M01-M06 regression evidence at the M07-R04 boundary

Each probe was run with Godot 4.7.2 stable, Windows display driver, OpenGL compatibility renderer.

```text
M01_PROBE_RESULT=PASS
M01_CONTRACT_EXIT_CODE=0
M02_PROBE_RESULT=PASS
M02_PHYSICS_EXIT_CODE=0
M03_PROBE_RESULT=PASS
M03_ECONOMY_EXIT_CODE=0
M04_GODOT_RESULT=PASS
M04_ASSET_IMPORT_EXIT_CODE=0
M05_PROBE_RESULT=PASS
M05_SPRITE_EXIT_CODE=0
M06_PROBE_RESULT=PASS
M06_GEOMETRY_EXIT_CODE=0
```

Selected regression facts retained in the command output:

- M01: 700 px/s initial launch, 180 px/s² deceleration, simultaneous motion, forward-only response, merge momentum, L12 cap, Game Over, persistence and restart all passed.
- M02: direct and glancing 700 px/s contacts had `contacts=1` with no tunneling; single/chain merge, L12 cap, six rapid launches, moving restart and moving Game Over all passed.
- M03: exact merge score table L2-L12 passed; combo x1-x6+ passed; reward table passed as `L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000`; immediate/stored orders, duplicate protection, persistence, danger-line timing and moving Game Over/restart passed.
- M04: 25 canonical PNGs loaded with expected dimensions; `M04_GODOT_RESULT=PASS`.
- M05: all L01-L12 shared mapping, visible-body diameter/radius envelopes, merge visual continuity, rapid launch, restart and Game Over visual ownership passed.
- M06: source-to-viewport, perspective rails, launch/danger coordinates and all three required portrait layouts passed.

## Scope / safety checks

- Changed implementation/probe/evidence files are limited to M07-R04 work and regenerated runtime evidence.
- No canonical PNG under `assets/` was modified.
- `TASKS.md` was not edited; no diff exists for it.
- ChatGPT-owned prompts, audit criteria, audit policy, and historical logs were not edited.
- No `guide_line` was introduced.
- No M08+ work was started.
- The earlier M07-R03 log and other historical logs were not rewritten.

## Files changed in this phase

- `scripts/game_manager.gd`
- `scripts/drink.gd`
- `tests/m07_hud_composition_probe.gd`
- `tests/m07_hud_inner_boxes.gd`
- `tests/m07_hud_visible_bounds.gd`
- `tests/m07_r04_focused_probe.gd`
- `tools/m07_r04_evidence_sheets.py`
- `docs/evidence/m07_r04/` focused screenshots and sheets
- regenerated M07/M06 runtime evidence files used by the required regression run
- `coordination/sessions/BCM-M07-R04/CODEX_LOG_V01.md`

## Publication and final equality

The implementation commit is `c9ae038d02bc673725e20c883b6e41730a5126d7`. A remote-safe synchronization merge incorporated the newly published M06-R05/M07-R05 prompt and criteria files without overwriting M07-R04 work; the final pushed repository HEAD is `355b89dff79da70fffc33511dcefaa83f7b76c5f`.

Final pushed HEAD SHA: `355b89dff79da70fffc33511dcefaa83f7b76c5f`

```text
git rev-parse HEAD
355b89dff79da70fffc33511dcefaa83f7b76c5f
git rev-parse origin/main
355b89dff79da70fffc33511dcefaa83f7b76c5f
git ls-remote origin refs/heads/main
355b89dff79da70fffc33511dcefaa83f7b76c5f	refs/heads/main
git status --short --branch
## main...origin/main
```

This phase stops at `AWAITING_AUDIT` for independent ChatGPT review.
