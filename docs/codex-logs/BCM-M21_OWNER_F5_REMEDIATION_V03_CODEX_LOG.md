# BCM-M21 Owner F5 Remediation V03 — Codex Execution Log

Status: `AWAITING_OWNER_F5_ACCEPTANCE_V03` (owner F5 checklist and independent audit remain pending; known legacy geometry-probe failures are disclosed below)

## Scope and authority

- Work items: BCM-M21-001, BCM-M21-004, BCM-M21-006.
- Prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V03.md`.
- Locked criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V03.md`.
- Owner ruling: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V03.md`.
- Branch/remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Start HEAD after sync recovery: `33681340e934f79c144e235bd886748a2c91e9cc`.
- Implementation/evidence commit: `8aa1e993e9bdfc1644db33515673984db61a2e47`.
- Root TASKS.md SHA-1 before and after: `9b44d0d78be4ab3c8a6d2c83d5d84b9cd5544c78`; it was not modified.

## Sync recovery and preservation

- Preflight ran in the canonical Desktop checkout: `git status --short --branch`, `git remote -v`, `git fetch origin main`, and `git rev-list --left-right --count HEAD...origin/main`.
- Local `main` began at `f892e7c`; fetched `origin/main` was six commits ahead at `3368134`.
- The exact 14 untracked Godot `.translation` files were listed and compared to `git diff --name-only HEAD..origin/main`. None collided with incoming tracked paths, and there were no other local owner modifications. A safe `git merge --ff-only origin/main` succeeded.
- Those 14 generated translations remain untracked, unstaged, and untouched.
- Before implementation commit publication, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `8aa1e993e9bdfc1644db33515673984db61a2e47`.

## Implementation summary

- `project.godot`: debug window override changed to 800x1422; canonical viewport remains 720x1280 and viewport stretch mode remains `viewport`.
- `scripts/campaign/world_map_controller.gd`: removed runtime `IslandRoute` Line2D and all hard-coded baked island centers; hotspot centers now derive from each `islands.json.map_position`. Added a report accessor for the ten computed centers. Sunny Cove resolves from `[0.16, 0.83]` in the lower-left. Duplicate thumbnails remain hidden.
- `scripts/campaign/island_map_controller.gd`: selected island `theme.island_map_background` now fills the map behind the path and nodes; generic flat color is only used when the path is missing/invalid.
- `scripts/game_manager.gd`: the verified Sunny Cove occluder was the full-viewport `LaunchZone` Sprite2D at z=-5, above the wooden `CampaignTable` at z=-10. Its z was moved to -15, behind the table, without changing the approved theme asset or R11 geometry. Added visible texture/z/layer inventory and terminal drink/effect counters. Terminal handling now freezes, hides, and disables collision on every active/held Drink; clears transient world effects and completion flash; kills pending transition tweens; blocks post-terminal score/collection callbacks; and blocks ShotController input.
- `scripts/campaign/gameplay_session_bridge.gd`: `set_current_score` now ignores calls unless a session is active, preventing score changes after terminal resolution.
- `scripts/campaign/campaign_navigation_controller.gd`: campaign result UI now renders in a dedicated root-viewport CanvasLayer (layer 2, above gameplay HUD layer 1) with full-viewport Control container; the CanvasLayer is disposed with its navigation owner. Retry, Next Level, and Island Map action routing remain covered.
- No `decor_left.png`, `decor_right.png`, or `decor_back.png` is instantiated by production code; the V03 visible texture inventory confirms none are visible.
- R11 rail source arrays, contact/footprint solver, collider radii, and `scripts/drink.gd` were not modified. No physics retuning was performed.

## Runtime evidence

- Godot: `4.7.2.stable.official.ed1daf0bf`; GL Compatibility, Intel Iris Xe.
- Command: `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m21_owner_f5_remediation_v03_probe.gd`.
- Result: `M21_OWNER_F5_REMEDIATION_V03_RESULT=PASS mouse=10/10 touch=10/10 drinks=0 effects=0 captures=7`.
- The probe uses real `InputEvent` objects through `Viewport.push_input()` and records zero direct launch-method calls. It verified all ten data-driven centers/no runtime IslandRoute, Sunny Cove theme background, gameplay texture inventory and table z-order, 800x1422 debug override with canonical 720x1280 viewport, no timer/one-hour survival, pause input blocking, terminal visual cleanup, post-terminal score/delivery immutability, and Next Level action transition.
- Seven 720x1280 captures: World Map; Sunny Cove Island Map; pre-shot gameplay; after ten mouse shots; after simulated hour; pause; clean WIN card. The World Map, Island Map, gameplay table, and WIN captures were visually inspected during builder verification. These are builder inspections, not owner F5 acceptance or independent audit.
- Machine-readable reports: `V03_HOTSPOT_CENTERS.json`, `V03_GAMEPLAY_VISIBLE_TEXTURE_INVENTORY.json`, `V03_TERMINAL_VISIBLE_COUNTS.json`, `M21_OWNER_F5_REMEDIATION_V03_REPORT.json`.
- Terminal report: visible Drink count 0; visible transient world effect count 0; result CanvasLayer layer 2.
- The owner checklist is `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_ACCEPTANCE_CHECKLIST_V03.md`; all PASS/FAIL selections are blank.

## Regression commands and results

- `godot_console.exe --headless --editor --path . --quit`: exit 0; expected warning that `res://original_reference` contains another `project.godot` and is ignored.
- `tests/m02_physics_regression.gd`: `M02_PROBE_RESULT=PASS`.
- `tests/m03_economy_regression.gd`: `M03_PROBE_RESULT=PASS`.
- `tests/m07_r06_owner_layout_probe.gd`: `M07_R06_PROBE_RESULT=PASS`; headless dummy renderer emitted null-texture `save_png` diagnostics for its visual captures. V03 GL gameplay captures independently cover the V03 visuals.
- `tests/m08_to_go_delivery_probe.gd`: `M08_TO_GO_DELIVERY_RESULT=PASS`; headless dummy renderer emitted null-texture `save_png` diagnostics.
- `tests/m09_audio_haptics_probe.gd`: `M09_AUDIO_HAPTICS_RESULT=PASS`.
- `tests/m14_gameplay_session_bridge_probe.gd`: `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`.
- `tests/m15_vip_boosters_economy_probe.gd`: `M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS`.
- `tests/m16_sunny_cove_content_probe.gd`: `M16_SUNNY_COVE_CONTENT_RESULT=PASS`.
- M18 completion progression, cumulative star rewards, cumulative reward remediation, integration, island-map replay, replay persistence, star contract, and untimed cumulative rewards: all respective `*_RESULT=PASS` markers.
- `tests/m19_multi_island_scalability_probe.gd`: `M19_SCALABILITY_RESULT=PASS` (all six child markers PASS).
- M20 app shell, onboarding, settings, pause lifecycle, campaign UX/result actions, and migration probes: all respective child PASS markers. Expected corrupt-fixture JSON parse diagnostics appeared in settings/migration negative cases; probes passed.
- `tests/m21_owner_f5_remediation_v03_progression_probe.gd`: `M21_CHILD_03_RESULT=PASS completed=100 checkpoints=5`; output/save locations were isolated under V03 paths.
- `tests/m21_release_persistence_probe.gd`: `M21_RELEASE_PERSISTENCE_RESULT=PASS`, with Godot user data redirected to ignored `.godot` storage.
- `git diff --cached --check`: clean before implementation commit. `TASKS.md` hash remained unchanged.

## Legacy geometry probe findings

- The locked M02 physics regression passed, and static diff review confirms R11 geometry functions/constants were not changed.
- Additional `tests/r10_v08_exact_edge_contact_probe.gd` could not parse: it references removed `Drink.TABLE_EDGE_CONTACT_HALF_WIDTHS` and then reports dependent type-inference errors. This stale probe was not repaired because it targets a retired scalar contact model outside V03 scope.
- Additional `tests/r10_v10_visual_hull_containment_probe.gd` ran under GL and failed its old crowd/rear-stress assertions: left crowd minimum edge distance -14.989, right crowd -33.253, rear stress -169.974, and left merge result containment false. Its frozen rail arrays, 13 boundary segments, collider radii, retired scalar-model checks, transform equivalence, and right merge containment all passed. The probe's failure concerns the existing physics solver at crowded stress cases; changing R11 rails/contact geometry is explicitly forbidden by this V03 task. These findings are disclosed for independent audit and are not represented as PASS.
- Therefore this handoff does not claim release-ready status or unconditional regression closure. Owner F5 acceptance and independent audit remain pending.

## Files changed in implementation/evidence commit

- `project.godot`
- `scripts/campaign/campaign_navigation_controller.gd`
- `scripts/campaign/gameplay_session_bridge.gd`
- `scripts/campaign/island_map_controller.gd`
- `scripts/campaign/world_map_controller.gd`
- `scripts/game_manager.gd`
- `tests/m21_owner_f5_remediation_v03_probe.gd`
- `tests/m21_owner_f5_remediation_v03_progression_probe.gd`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_ACCEPTANCE_CHECKLIST_V03.md`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v03/` (seven captures and four JSON reports)

## Final handoff

- Implementation/evidence commit: `8aa1e993e9bdfc1644db33515673984db61a2e47`.
- After push/fetch, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` matched at that SHA.
- This detailed log and its session pointer are being published as a separate documentation commit after the implementation/evidence commit; final repository parity will be reverified after that log push.
- `TASKS.md` was not modified. The 14 generated `.translation` files remain preserved and untracked.
- Required stop marker: `AWAITING_OWNER_F5_ACCEPTANCE_V03`.
