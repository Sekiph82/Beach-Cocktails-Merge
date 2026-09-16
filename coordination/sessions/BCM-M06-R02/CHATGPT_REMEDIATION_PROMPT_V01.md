# BCM-M06-R02 — Environment / Table Composition Remediation V01

Status: **ISSUED**

## Goal

Repair M06 so the actual production gameplay screen's environment/table/playfield composition is visibly derived from the owner-approved master, not merely from a technically valid but visually divergent cover transform.

## Canonical visual truth

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

For this remediation, ignore M07 HUD widgets while judging M06, but preserve the master's environment/table silhouette, perspective, occupancy, horizon relationship and launch/play-space proportions.

## Read first

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- completed M04-R01 outputs/log
- completed M05-R01 outputs/log
- `coordination/sessions/BCM-M06-R02/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M06-R02/CHATGPT_AUDIT_CRITERIA_V01.md`
- original M06 prompt/log
- owner master visual

## Required work

1. Safely sync and preserve owner work. Do not edit `TASKS.md` or ChatGPT-owned audit/criteria/prompt files.
2. STOP any M07 implementation work for this sequence. M06 must be corrected first.
3. Do not assume `720x1280` is automatically the correct canonical visual design space just because the prototype used it.
4. Compare the 1024x1536 owner master and `game_board_background.png` directly. Establish a documented adaptation strategy for target portrait ratios.
5. Prefer preserving the owner's table silhouette/composition over blind center-cover cropping. If necessary, use a canonical 2:3 internal design composition with controlled viewport adaptation, camera/canvas framing, or another non-distorting strategy.
6. Do not stretch the background/table.
7. If a target aspect must crop, explicitly preserve the gameplay-critical master features:
   - narrow far table under upper HUD region;
   - visible beach/horizon around the far table;
   - broad near table occupying most lower width;
   - coherent visible left/right wood rails;
   - large central playable wood surface;
   - lower launch region;
   - low danger threshold region.
8. Create retained reference overlays under `docs/evidence/m06/`:
   - `master_table_landmarks.png`: owner master with labelled far/near rail landmarks, top stop, danger reference region, launch reference region;
   - `background_table_landmarks.png`: canonical environment asset with corresponding landmarks;
   - `canonical_runtime_overlay.png`: production 720x1280 (or newly justified canonical runtime size) with visible collision rails/top/bottom/danger/launch overlays;
   - `taller_runtime_overlay.png`;
   - `shorter_wider_runtime_overlay.png`;
   - clean counterparts without debug overlays for owner/audit comparison.
9. Put independent expected landmark data in a dedicated evidence/config file, not only in the same production helper being tested. The focused M06 test must compare production geometry against that independent reference dataset within documented tolerances.
10. Strengthen responsive assertions. For each tested viewport verify at minimum:
   - both visible table rails remain materially within/credible to the frame;
   - table width at far/middle/near depths matches expected adapted reference within tolerance;
   - launch and danger lines land on visible wood and in the intended lower-table region;
   - top stop is on the far-table boundary;
   - table center/horizon relationship remains master-like;
   - no material black bars or stretch;
   - L01/L06/L12 representative bodies stay inside the independently expected visual rail envelope.
11. Do not validate a drink against bounds produced by the exact same production function and call that visual proof.
12. Keep danger threshold close to launch side and preserve most of the tabletop as usable area.
13. Preserve all M05 cocktail mapping/scale/collider choices unless M05-R01 itself changed them with evidence.
14. Preserve launch 700 px/s, deceleration 180 px/s², forward-only behavior, wake/momentum transfer, merge momentum, L12 cap, M03 economy/persistence/Game Over/restart.
15. Rerun M01-M05 regressions plus strengthened M06 probe after production changes.
16. Run Godot import/parse/main-scene startup and `git diff --check`.
17. Write all execution evidence to:

`coordination/sessions/BCM-M06-R02/CODEX_LOG_V01.md`

18. Commit the M06 remediation as its own bounded commit.
19. Do not start or resume M07 after the M06 commit. Stop the overall master sequence for independent ChatGPT audits.

## Important visual rule

A green geometry probe is not enough. If the clean runtime captures do not visibly resemble the table/environment composition of the owner master, report a blocker instead of claiming success.

## Out of scope

- no final M07 HUD composition;
- no guide line;
- no M08 effects;
- no economy/physics redesign;
- no destructive editing of canonical PNGs solely to satisfy tests.

## Completion state

Return `AWAITING_AUDIT` for M06-R02. Do not self-approve.
