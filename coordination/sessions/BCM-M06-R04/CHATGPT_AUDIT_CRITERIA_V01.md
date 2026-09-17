# BCM-M06-R04 — Locked Audit Criteria V01

Status: LOCKED BEFORE IMPLEMENTATION

## Scope
Rebuild responsive table/playfield geometry around the newly owner-approved canonical background `assets/environment/game_board_background.png`, whose exact owner source is `game_board_background 2.png` SHA-256 `5d3d795935e2a69175e048c354ab4ce82ef13627cd27a8894f0605f78f0559b3`.

## PASS requirements
1. The canonical background hash equals the owner hash above and dimensions are 1024x1536.
2. Old M06 source landmarks are not blindly reused. Visible wooden playfield rails/top/bottom are independently remeasured from the new image/render.
3. Production table rail constants/helpers are updated only from evidence appropriate to the new background.
4. For 720x1280, 720x1440 and 800x1280, actual rendered left/right far, middle and near wood boundaries are recorded independently from the production helper values.
5. Collision rails materially follow the visible inner wooden rails within a documented tolerance.
6. The far stop is on the visible far-table boundary, not beach/scenery.
7. The near playfield remains on visible wood and does not extend into the dark wooden apron below the tabletop.
8. Launch position remains visibly on the lower tabletop.
9. Danger line remains below most usable table area and above launch, synchronized with actual `death_line_y`.
10. No guide line is introduced.
11. Background uses aspect-preserving scaling with no stretching and no black bars.
12. Controlled cropping is acceptable, but both playfield rails and launch region remain credible in all required aspect ratios.
13. M01-M05 gameplay contracts are not retuned: 700 px/s launch, 180 px/s² deceleration, momentum/merge/L12/economy remain unchanged.
14. Clean captures and rail/danger/launch overlays are regenerated for all three required viewports.
15. Evidence must come from the new background, not stale pre-replacement screenshots.
16. `TASKS.md` and ChatGPT-owned files remain untouched by Codex.
17. Godot import/startup and `git diff --check` pass.

Any material failure blocks AUDITED_PASS.