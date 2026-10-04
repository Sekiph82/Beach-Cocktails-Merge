# Codex Execution Log — BCM-M21-001 World Map Layout Closure V01

## Work item and authority

- Work item: `BCM-M21-001` — World Map 720×1280 layout regression diagnosis and closure.
- Prompt / locked criteria: `CHATGPT_M21_WORLD_MAP_LAYOUT_PROMPT_V01.md` / `CHATGPT_M21_WORLD_MAP_LAYOUT_CRITERIA_V01.md`.
- Start HEAD: `fdd1e5349c07594dfa8be616e6dd9bd8f9f7bd21`.
- Synchronized implementation base: `70f92306688e496c7dd6b5a5b34ec61cf5fce711`.
- Branch / remote: `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge` (`origin`).
- Godot: `4.7.2.stable.official.ed1daf0bf`.

## Sync preflight and owner-work preservation

- Initial `git status --short --branch`: `main`, 0 ahead / 4 behind; dirty tracked paths were `project.godot` and `scenes/main.tscn`; untracked paths were `addons/`, 14 generated `.translation` sidecars, `tools/__pycache__/`, and `tools/ui_assets/__pycache__/`.
- `git remote -v` identified the canonical GitHub origin. `git fetch origin main` completed. Incoming changed paths were `TASKS.md` and the current World Map prompt, criteria, and hygiene audit; none intersected the dirty local paths.
- Followed the synchronized `AGENTS.md` standing safe-sync procedure: created a new tracked-only stash named `owner-local-safe-sync-fdd1e53` with the explicit tracked path list `project.godot scenes/main.tscn`; did not use `-u`; untracked owner paths were left in place.
- `git merge --ff-only origin/main` fast-forwarded to `70f9230`. Applied only the new stash without dropping it; no conflict. Both tracked diffs were restored. The stash remains in the stash list.
- Post-sync owner paths remained present and unstaged. None were included in the implementation commit.

## Reproduction and diagnosis

- Pre-fix `godot_console.exe --headless --path . --script tests/m12_world_map_probe.gd`: exit 1; all checks passed except the canonical 720×1280 geometry cleanliness assertion. The two-island fixture's clipping and overlap checks passed.
- Full pre-fix output, exit code, exact fixture/canonical report, and renderer screenshots are under `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/evidence/world-map-layout-v01/`.
- Renderer-capable pre-fix capture used OpenGL Compatibility on Intel Iris Xe at exactly 720×1280. It confirmed real presentation overlap: the Frozen Paradise / Volcano Bay selection rings crossed behind the header, and a MapBoat texture rendered at its 320×180 native size obscured Sunny Cove marker content.
- Cleanup causality was checked against `6febc285` and `fdd1e534`: `world_map_controller.gd` has the same blob `0fa46a41e2983ad9eebc64ed6bff12d0055bacb7`; the prior M12 probe diff only removed retired `map_background` fixture keys; all ten canonical `map_position` values are unchanged. The regression predates cleanup, while the rendered overlap itself was real.

## Implementation

- `scripts/campaign/world_map_controller.gd`: bounded the header to the safe top band; reapplied title, compass, and MapBoat sizes after adding texture controls to the tree; moved the small MapBoat into open water and behind markers; split horizontal and vertical viewport clipping and added marker/header/footer overlap and header-fit reporting.
- `tests/m12_world_map_probe.gd`: asserts independent viewport axes, header fit/clearance, and navigation clearance for fixture and canonical ten-island layouts.
- No canonical island `map_position`, campaign state/unlock behavior, gameplay asset/profile, physics, scoring, persistence, or root `TASKS.md` changes.
- Renderer screenshots, exact pre/post layout JSON, regression logs, and summary are in the required `evidence/world-map-layout-v01/` package.

## Validation and exact results

- `godot_console.exe --headless --path . --script tests/m12_world_map_probe.gd` — PASS, exit 0 twice consecutively after the final source change; logs `post-fix-m12-run-1.log` and `post-fix-m12-run-2.log`.
- `godot_console.exe --headless --editor --path . --quit` — PASS, exit 0; clean import/parse/boot log retained. Godot emitted a non-fatal warning that `res://original_reference` contains a second `project.godot` and was ignored.
- `godot.exe --path . --windowed --resolution 720x1280 --script res://coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/evidence/world-map-layout-v01/world_map_layout_diagnostic.gd` — PASS, exit 0; renderer output was native 720×1280.
- Godot AI connected editor runtime inspection — PASS; World Map ran with a live non-stale framebuffer at 720×1280. Header `720×76`, title panel `444×76`, compass `70×70`, MapBoat `86×62`, status and selection bounds matched the post-fix report. The final screenshot was visually inspected alongside fresh, locked, selected, top, and bottom captures.
- `godot_console.exe --headless --path . --script tests/m10_campaign_architecture_probe.gd` — `M10_CAMPAIGN_ARCHITECTURE_RESULT=PASS`, exit 0.
- `godot_console.exe --headless --path . --script tests/m11_save_migration_progression_probe.gd` — `M11_SAVE_MIGRATION_PROGRESSION_RESULT=PASS`, exit 0.
- `godot_console.exe --headless --path . --script tests/m13_island_map_probe.gd` — `M13_ISLAND_MAP_RESULT=PASS`, exit 0.
- `godot_console.exe --headless --path . --script tests/m14_gameplay_session_bridge_probe.gd` — `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`, exit 0.
- `godot_console.exe --headless --path . --script tests/m20_app_shell_probe.gd` — `M20_CHILD_01_RESULT=PASS`, exit 0.
- `godot_console.exe --headless --path . --script tests/m21_r04_gameplay_surface_authority_probe.gd` — `M21_R04_SURFACE_PROBE_RESULT=PASS islands=10 checks=71`, exit 0.
- `python tools/ui_assets/validate_assets.py` — PASS, exit 0; 356/356 manifest checksums, 10/10 R04 families, invalid semantic duplicates 0.
- `git diff --check` and `git diff --cached --check` — PASS.

## Manual checks and limitations

- Visually inspected the renderer-capable 720×1280 pre-fix and post-fix screenshots: full map, northern markers/header, southern markers/footer, locked modal, and selected/current state.
- Godot AI runtime UI tree and global rectangles were inspected after reloading `WorldMapScene.tscn` from disk. The framebuffer capture was live, not stale.
- No physical-device touch, export-template/mobile build, or independent acceptance audit was performed. M12 automated selection/navigation assertions passed; device-specific behavior remains outside this builder verification.

## Publication and tracker

- Implementation/evidence commit: `a0304d3` — `fix: close M21 world map portrait overlap`.
- An immutable execution-log publication commit follows this implementation/evidence commit. The final pushed branch is verified by `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` during handoff.
- Explicit confirmation: root `TASKS.md` was not modified; only independent ChatGPT audit may update it.
- Builder result: `AWAITING_GPT_M21_WORLD_MAP_LAYOUT_AUDIT_V01`.
