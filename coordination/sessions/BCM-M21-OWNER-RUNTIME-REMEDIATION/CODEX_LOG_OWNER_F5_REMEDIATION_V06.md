# CODEX Execution Log — BCM-M21 Owner F5 Remediation V06

Status: **TECHNICAL WORK COMPLETE — OWNER F5 ACCEPTANCE PENDING**

Active tasks: BCM-M21-001 + BCM-M21-006. BCM-M21-004 remains closed; no change to its gameplay behavior was required.
Prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V06.md`
Locked criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V06.md`
Owner ruling: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V06.md`
Branch: `main`
Remote: `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`)
Godot runtime: `4.7.2.stable.official.ed1daf0bf`, Compatibility renderer.

## Start and sync preflight

- Canonical checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Initial status: `main...origin/main`, no tracked modifications; 14 pre-existing untracked `.translation` sidecars were preserved.
- Remotes: origin fetch/push `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- After `git fetch origin main`, initial divergence was `0 6` (ahead, behind). Incoming paths were inspected and had no collisions with the sidecars.
- Fast-forwarded safely to V06 base `ccecf1d6d61577b0bbadcad9611975c364663822`; no reset, rebase, force-push, stash, or destructive checkout was used.
- Existing `stash@{0}` `pre-v04-owner-local-preserve` remains retained.
- `TASKS.md` was read only. Start blob SHA-1: `5a9b56e3e61a995b3de938b2e7cb4ddc371c822b`.

## Implementation

- Added `tools/build_sunny_cove_gameplay_surface.py`, which deterministically composites the accepted Sunny Cove gameplay background, table shadow, table, and edge overlay at the existing accepted +150px source-art transform. It records source SHA-256 values, source dimensions, exact layer order/transforms, output dimensions, and output SHA-256. Source images were not edited or removed.
- Added the 720×1280 `assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface.png`. Final SHA-256: `b8c4fdbeb43e34f823eb56e3d35fb6b769090efcb5749ec2bc020cace9891af0`.
- Added Sunny Cove `playable_geometry` in canonical image pixels. GameManager now derives the Sunny Cove polygon rails, bounds queries, footprint projection, held spawn position, launch line, and death line from that profile. The old table offset and separate static theme layers are not active for Sunny Cove. Other islands retain the legacy fallback.
- Corrected the initialization order for the initial held drink: when Sunny Cove geometry activates, the preview is reprojected onto the active profile's `spawn_y`.
- Added `tools/build_world_map_marker_calibration_v06.py` and a report for all ten islands. Centers use documented manual anchors on the canonical baked image, identified with each per-island visual asset; those assets are portraits rather than pixel-identical crops, so RGB template matching is not applicable. The report records pixel/normalized centers, asset hashes, estimated anchor uncertainty (<=12px), and zero marker-to-selected-anchor residual. Production ring/button centers share the same `map_position`; duplicate art/lock thumbnails and route lines remain hidden/absent.
- Sunny Cove Island Map level positions, pagination, and connector-line setting were not changed.
- V05 menu/result, input, no-timer, pause, and persistence behavior was retained.

## Evidence and commands

- `python tools/build_sunny_cove_gameplay_surface.py` — `SUNNY_COVE_COMPOSITE_RESULT=PASS size=720x1280`; output hash recorded above.
- `python tools/build_world_map_marker_calibration_v06.py` — `WORLD_MAP_CALIBRATION_RESULT=PASS markers=10`; map SHA-256 `09e26c73359615892a126be872164e2c07c34a2b0b0f6093011a9fde08438306`.
- `godot_console.exe --headless --editor --path . --quit` — exit 0; project scripts/classes and imported assets loaded. Godot emitted only the pre-existing warning that `res://original_reference` contains another ignored `project.godot`.
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m21_owner_f5_remediation_v06_gui_probe.gd` — final exit 0; `M21_OWNER_F5_REMEDIATION_V06_GUI_RESULT=PASS clicks=15 captures=6`. Real viewport mouse input covered Main Menu PLAY, SETTINGS, Back, World Map Sunny Cove selection, Island Map Level 1, result Next Level, result Island Map, and menu re-entry after a result. A preliminary run exposed that the synthetic cursor needed a motion event before clicking the World Map hotspot; the final probe dispatches motion, press, and release. No `ERROR:` or `SCRIPT ERROR:` lines.
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m21_owner_f5_remediation_v06_gameplay_probe.gd` — final exit 0; `M21_OWNER_F5_REMEDIATION_V06_RESULT=PASS mouse=10/10 touch=10/10 drinks=0 effects=0 captures=9`. Checks include the ten World Map centers, duplicate/route-line absence, unchanged Island Map layout and pagination, single Sunny Cove composite node, no active `table_y_offset_canonical`, profile-backed rails/bounds/spawn/launch/death, untimed 3600-second bridge survival, pause/resume, real mouse/touch launches, crowded 12-drink capture, WIN cleanup, and result input blocking. No `ERROR:` or `SCRIPT ERROR:` lines.
- One earlier gameplay-probe run exposed the initial held-drink ordering issue; the fix is described above. A subsequent final run passed all criteria. Five frames are allowed after result teardown before counting queued transient effects, producing zero visible effects.
- `godot_console.exe --headless --path . --script res://tests/m20_settings_probe.gd` — exit 0; `M20_CHILD_03_RESULT=PASS`. The deliberately malformed-settings fixture emitted its expected JSON parser diagnostic and recovered to defaults.
- `godot_console.exe --headless --path . --script res://tests/m21_release_persistence_probe.gd` — exit 0; `M21_RELEASE_PERSISTENCE_RESULT=PASS`. `campaign_save.json`, its backup, and `save.cfg` were copied outside Desktop and restored byte-for-byte afterward; restored hashes match those preserved copies.
- `git diff --check` — exit 0.
- Runtime captures, Godot logs, geometry runtime report, World Map calibration report, and builder outputs are under `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v06/` and the Sunny Cove asset directory.

## Manual review and limitations

- Inspected the committed-source composite, geometry outline/stress overlay, production gameplay capture, crowded 12-drink capture, and World Map capture. The polygon follows the visible tabletop boundary; the debug overlay shows the canonical profile and measured cocktail-footprint radii. Runtime captures show the cocktail sprites and HUD above the one static composite.
- World Map anchors are documented manual visual selections, not automatic template-match results. The per-island images are distinct portrait renders; owner F5 review remains the required visual acceptance gate.
- Physical-device behavior, owner-native F5 acceptance, and owner visual acceptance have not been performed. No release-ready, acceptance, or independent-audit verdict is claimed.
- The 14 existing untracked `.translation` sidecars remain untouched. No new branch was created. Root `TASKS.md` was not modified.

## Files changed

- `data/campaign/islands.json`
- `scripts/campaign/gameplay_session_bridge.gd`
- `scripts/campaign/level_database.gd`
- `scripts/game_manager.gd`
- `scripts/shot_controller.gd`
- `tools/build_sunny_cove_gameplay_surface.py`
- `tools/build_world_map_marker_calibration_v06.py`
- `tests/m21_owner_f5_remediation_v06_gameplay_probe.gd`
- `tests/m21_owner_f5_remediation_v06_gui_probe.gd`
- `assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface.png`
- `assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface.provenance.json`
- `assets/ui_assets/campaign/islands/sunny_cove/playable_geometry_calibration.json`
- `assets/ui_assets/campaign/islands/sunny_cove/playable_geometry_debug.png`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_ACCEPTANCE_CHECKLIST_V06.md`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v06/`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CODEX_LOG_OWNER_F5_REMEDIATION_V06.md`
- `docs/codex-logs/BCM-M21-OWNER-F5-REMEDIATION-V06.md`

## Publication and final repository state

- Start HEAD: `ccecf1d6d61577b0bbadcad9611975c364663822`.
- Implementation/evidence commit: `1315ed60b332a8115562f53412dec082fe2265d5` (`BCM-M21 V06 composite surface and map calibration`), pushed to `origin/main`.
- After `git fetch origin main`, exact pre-log-closeout equality was verified:
  - `git rev-parse HEAD`: `1315ed60b332a8115562f53412dec082fe2265d5`
  - `git rev-parse origin/main`: `1315ed60b332a8115562f53412dec082fe2265d5`
  - `git ls-remote origin refs/heads/main`: `1315ed60b332a8115562f53412dec082fe2265d5`
- End `TASKS.md` blob remained `5a9b56e3e61a995b3de938b2e7cb4ddc371c822b`, equal to the start blob. `TASKS.md` was not modified.
- A follow-up log-only closeout commit will publish these final verification details in both V06 Codex log copies; post-closeout branch equality will be verified again.
- Handoff marker: `AWAITING_OWNER_F5_ACCEPTANCE_V06`.
