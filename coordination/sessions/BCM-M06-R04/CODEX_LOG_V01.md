# BCM-M06-R04 — Codex Execution Log V01

Status: AWAITING_AUDIT. Builder evidence only; no independent acceptance verdict is assigned.

## Authority and scope

- Master: `coordination/sessions/BCM-M04-M06-M07-R04/CHATGPT_EXECUTION_PROMPT_V02.md`.
- Locked criteria read before editing: `coordination/sessions/BCM-M06-R04/CHATGPT_AUDIT_CRITERIA_V01.md`.
- Start HEAD: `6f763e5` (the separately pushed M04-R03 retry).
- Phase scope: rebuild M06 geometry for the corrected owner background and regenerate M06 evidence.
- M07-R03 was not started in this phase.
- `TASKS.md`, prompts, criteria, policy files, cocktail PNGs, effects PNGs and canonical background bytes were not edited in this phase.
- No `guide_line` was added.

## Corrected background and independent measurements

The corrected V02 background is `assets/environment/game_board_background.png`, SHA-256 `bf9ef25bfe27b78805c487410601a9fef16b36f83c97b9bc6f3bf70670dfd17a`, dimensions `1024x1536`. The prior R03 source points `(292,464)/(732,464)/(104,1208)/(920,1208)` were not reused.

Independent visible-wood measurements from the new artwork:

| Landmark | New source pixel |
|---|---:|
| far inner rail left/right | `(154,472)` / `(870,472)` |
| near tabletop-to-apron transition left/right | `(16,1186)` / `(1008,1186)` |
| danger threshold | `y=1080` |
| launch center | `y=1136` |

Production constants in `scripts/game_manager.gd` now use these values. Cover scaling remains aspect-preserving (`max(viewport/source)`), with no stretching or black bars. The lower rail is clamped to the visible viewport edge when source-cover cropping places its outer edge off-screen.

## Responsive geometry evidence

The independent reference dataset is `docs/evidence/m06/expected_landmarks.json`; the independent clean-render dataset is `docs/evidence/m06/render_space_landmarks.json`. Production values and clean-render observations were:

| Viewport | scale/offset | table top/bottom | danger / launch | far rails | middle rails | near rails |
|---|---|---:|---:|---:|---:|---:|
| 720x1280 | 0.833333 / (-66.667,0) | 393.333 / 988.333 | 900.000 / 946.667 | 62 / 658 | 41 / 679 | 20 / 700 |
| 720x1440 | 0.937500 / (-120,0) | 442.500 / 1111.875 | 1012.500 / 1065.000 | 24 / 696 | 22 / 698 | 20 / 700 |
| 800x1280 | 0.833333 / (-26.667,0) | 393.333 / 988.333 | 900.000 / 946.667 | 102 / 698 | 61 / 739 | 20 / 780 |

Render-space rail tolerance: `8 px`. Every render-space comparison was below `0.54 px`; every independent source-to-production comparison was within `3 px` (exact in the probe’s generated values). The held L01 launch cocktail was on `y=946.667` in the canonical viewport, below danger and above the visible tabletop/apron transition.

## Commands and exact result markers

```text
godot_console.exe --path . --display-driver windows --rendering-driver opengl3 --rendering-method gl_compatibility --script res://tests/m06_environment_geometry_probe.gd
M06_PROBE_RESULT=PASS
M06_R04_GODOT_EXIT_CODE=0
python tools/m06_render_landmark_evidence.py
M06_RENDER_EVIDENCE_RESULT=PASS
M06_R04_EVIDENCE_EXIT_CODE=0
git diff --check
M06_R04_DIFF_CHECK_EXIT_CODE=0
```

The Godot probe reported `main scene loads as PackedScene`, exact canonical background path and `1024x1536`, four bounded perspective rail segments, responsive viewport checks for all three required sizes, collider containment for L01/mid/L12, held launch placement, no guide line, and aspect-preserving cover mapping. It saved clean and runtime-overlay captures for all three sizes. The Python evidence tool regenerated visible-wood references and master/runtime table sheets from those corrected-background renders.

## Files changed in this bounded phase

- `scripts/game_manager.gd`
- `docs/evidence/m06/expected_landmarks.json`
- `docs/evidence/m06/render_space_landmarks.json`
- `docs/evidence/m06/canonical_720x1280.png`
- `docs/evidence/m06/canonical_720x1280_runtime_overlay.png`
- `docs/evidence/m06/canonical_720x1280_visible_wood_reference.png`
- `docs/evidence/m06/canonical_720x1280_master_runtime_table_sheet.png`
- `docs/evidence/m06/taller_720x1440.png`
- `docs/evidence/m06/taller_720x1440_runtime_overlay.png`
- `docs/evidence/m06/taller_720x1440_visible_wood_reference.png`
- `docs/evidence/m06/taller_720x1440_master_runtime_table_sheet.png`
- `docs/evidence/m06/shorter_wider_800x1280.png`
- `docs/evidence/m06/shorter_wider_800x1280_runtime_overlay.png`
- `docs/evidence/m06/shorter_wider_800x1280_visible_wood_reference.png`
- `docs/evidence/m06/shorter_wider_800x1280_master_runtime_table_sheet.png`
- `coordination/sessions/BCM-M06-R04/CODEX_LOG_V01.md`

M01-M05 behavior/physics/economy was not retuned. Those regressions are rerun in the final M01-M07 suite after M07-R03.

## Handoff

This log does not self-audit, rewrite historical logs, edit tracker state, or assign `AUDITED_PASS`. Final commit/push and local/origin/remote equality are recorded at handoff after this bounded phase.
