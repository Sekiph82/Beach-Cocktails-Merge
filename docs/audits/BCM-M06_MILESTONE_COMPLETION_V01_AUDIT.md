# BCM-M06 — Environment, Table Composition, and Responsive Playfield V01 Audit

## 1. VERDICT

**PASS**

BCM-M06-001 is accepted. The canonical beach-bar background is integrated into production, gameplay geometry is mapped to the visible perspective table, launch/danger/top-stop geometry is source-landmark driven, representative portrait aspect mappings are deterministic, and the accepted M01-M05 contracts remain green.

## 2. CONTRACT RECOVERY

Audited against `AGENTS.md`, root `TASKS.md`, the M06 work order, the committed M06 Codex log, production source, Git history, and the retained runtime evidence paths.

Required M06 contract:

- integrate `assets/environment/game_board_background.png` without modifying it;
- align gameplay rails/playfield to the visible table;
- align launch position, danger boundary, and top stop to the environment;
- preserve portrait aspect without distortion or gameplay-critical black bars;
- keep the danger line near the launch side while preserving usable table area;
- retain runtime evidence for canonical/taller/shorter-wider portrait cases;
- preserve M01-M05 gameplay, economy, physics, sprite and collider behavior;
- do not start M07 HUD composition or add `guide_line`.

## 3. BRANCH / HEAD / DIFF SCOPE

Audited M06 range:

- base: `5fb7351e0f549fd4389f69264b964951403e072b`
- implementation: `0e23998a8676831106761778b35474b0985170bc`
- evidence-log finalization: `1d79b49ce770f955c69b07593af520f35b79bbdb`

M06 changes are bounded to:

- `scripts/game_manager.gd`
- `scripts/shot_controller.gd`
- geometry-relative adjustments in `tests/m02_physics_regression.gd` and `tests/m03_economy_regression.gd`
- `tests/m06_environment_geometry_probe.gd`
- `docs/evidence/m06/*.png`
- the immutable M06 Codex log.

No canonical PNG was modified and `TASKS.md` was not edited by Codex.

## 4. ACCEPTANCE CRITERIA MATRIX

| Criterion | Result | Audit basis |
|---|---|---|
| Canonical background integrated | PASS | `GameBoardBackground` uses the exact production asset at z=-100 |
| Uniform, non-distorting cover mapping | PASS | source-to-viewport transform uses one uniform scale |
| Playfield follows visible perspective table | PASS | source rail landmarks drive four bounded perspective wall segments |
| Launch position aligned to lower table | PASS | `get_launch_position()` is source-landmark based and used by `ShotController` |
| Danger line near launch side | PASS | canonical mapped danger Y 873.333 vs launch Y 953.333 |
| Top stop aligned to far rail | PASS | top rail uses mapped far table edge; M02 top-contact regression passes |
| L01/L06/L12 footprints remain within rails | PASS | focused production probe passes at far/mid/near depths |
| Canonical 720x1280 mapping | PASS | deterministic focused probe and committed render evidence |
| Taller 720x1440 mapping | PASS | deterministic focused probe and committed render evidence |
| Shorter/wider 800x1280 mapping | PASS | deterministic focused probe and committed render evidence |
| No `guide_line` | PASS | focused probe and source scope |
| M01-M05 regression preservation | PASS | all focused processes exit 0 |
| Godot import/parse/startup | PASS | Godot 4.7.2, import and startup exit 0 |
| Owner/native final aesthetic acceptance | UNVERIFIED | intentionally deferred; M07/M12 owner visual acceptance remains later |

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH

The central builder claims match repository truth. `GameManager` owns a canonical `BACKGROUND_PATH`, source image size, source-space perspective table landmarks, a uniform cover transform, four mapped wall segments, and mapped danger/launch coordinates. `ShotController` now queries the production launch position instead of using a raw viewport-bottom offset.

The committed M06 range also contains exactly three render-evidence PNG files corresponding to the logged canonical, taller and shorter/wider cases.

## 6. FILE / SYMBOL EVIDENCE

Key production symbols verified:

- `GameManager.BACKGROUND_PATH`
- `TABLE_FAR_LEFT_SOURCE`, `TABLE_FAR_RIGHT_SOURCE`
- `TABLE_NEAR_LEFT_SOURCE`, `TABLE_NEAR_RIGHT_SOURCE`
- `DANGER_SOURCE_Y`, `LAUNCH_SOURCE_Y`
- `background_scale_for_viewport()`
- `background_offset_for_viewport()`
- `source_to_viewport()`
- `_configure_board_layout()`
- `_build_background()`
- `get_table_rail_bounds_at_y()`
- `get_horizontal_bounds_at_y()`
- `clamp_position_to_board()`
- `get_launch_position()`
- `_build_walls()`.

## 7. FOCUSED TEST EVIDENCE

`tests/m06_environment_geometry_probe.gd` reports PASS for background asset identity, z-order, deterministic cover transform, rail perspective, top/bottom placement, danger/launch placement, four wall segments, collider containment, held launch placement, absence of guide line and all three portrait mappings.

`M06_PROBE_RESULT=PASS`, process exit code 0.

## 8. REGRESSION EVIDENCE

Post-M06:

- M01 PASS, exit 0
- M02 PASS, exit 0
- M03 PASS, exit 0
- M04 asset load PASS, exit 0
- M05 PASS, exit 0
- Godot 4.7.2 import/parse PASS, exit 0
- configured main-scene startup PASS, exit 0.

No accepted launch speed, deceleration, forward-only behavior, merge momentum, L12 cap, scoring/combo/To-Go reward, persistence, cocktail mapping, visual scale or M05 collider contract was retuned in M06.

## 9. SECURITY / SAFETY REVIEW

No secrets, save data, `.godot/`, machine-local output, destructive Git operation, force push or generated import sidecar was introduced in the audited scope.

## 10. ARCHITECTURE CONSISTENCY

PASS. Environment mapping is centralized in `GameManager` and reused by world geometry and launch placement instead of duplicating unrelated screen-space constants. This is compatible with later M07 dynamic HUD composition.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS

PASS. Codex did not edit `TASKS.md`. The M06 log explicitly distinguishes deterministic/runtime evidence from final owner-native aesthetic acceptance. It also correctly carries forward the M05 historical-radius audit correction.

## 12. FINAL REPOSITORY STATE

M06 implementation and evidence are present on `main`. The M06 finalization commit is `1d79b49ce770f955c69b07593af520f35b79bbdb` before this independent audit commit.

## 13. OPEN CROSS-MILESTONE FINDINGS

- M07 must replace the temporary/procedural HUD and danger-boundary presentation with the canonical separate UI assets while retaining the M06 gameplay geometry.
- M07 must use the existing canonical `Drink` texture accessor for Next, To-Go and progression consumers.
- Final native-device safe-area/aesthetic acceptance remains later QA/final acceptance work.

## 14. DEFECTS BY SEVERITY

**BLOCKER:** none.

**MAJOR:** none.

**MINOR:** none blocking M06 closure.

**NOTE — N-M06-EVIDENCE-001:** the three committed PNG render-evidence files are present with dimensions/hashes recorded by the builder. This connector audit cannot independently decode the binary PNG pixels, so their detailed aesthetic contents were not re-asserted as independent pixel-level proof. Production geometry, source mapping, file presence and deterministic runtime checks independently support the M06 gate.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES

M07 should remove/supersede the remaining prototype HUD presentation rather than layering duplicate live values on top of it. The canonical danger-line PNG should visually replace the temporary procedural red boundary without changing the already accepted M06 `death_line_y` gameplay coordinate.

## 16. UNVERIFIED ITEMS

- native phone safe-area visual acceptance;
- owner visual approval of the final M07-composed screen;
- device/export behavior;
- pixel-level independent inspection of the retained M06 screenshots through this connector.

These are not M06 blockers.

## 17. REGRESSION RISK

**MEDIUM** because M06 legitimately changed production wall/board geometry. Risk is contained by geometry-focused tests and complete M01-M05 reruns.

## 18. AUDIT CONFIDENCE

**HIGH** for production geometry and regression preservation; **MEDIUM-HIGH** for rendered aesthetics due the binary-evidence limitation noted above.

## 19. FINAL VERDICT

**PASS**

BCM-M06-001 is accepted and M07 may begin.