# BCM-M21-001 — Owner-Approved World Map Production Integration V05

## Work item and authority
- Work item: `BCM-M21-001`.
- Prompt/criteria: `CHATGPT_WORLD_MAP_PRODUCTION_PROMPT_V05.md` / `CHATGPT_WORLD_MAP_PRODUCTION_CRITERIA_V05.md`.
- Frozen visual target: owner-approved V04 preview `WORLD_MAP_OWNER_PREVIEW_V02.png`, SHA-256 `d2c9693f5040a5a67b9292a07a0b19873840b23f842d3e6d5e44954760d8895f`.
- Background: `world_map_ocean_background_owner_v02.png`, source 941×1672, SHA-256 `dca5feb7283588d59158388bca87ea7d8f5796ccfa37559daecec11e4606a4e2`.

## Start state and sync preflight
- Repository: `C:/Users/sekip/Desktop/Beach Cocktails - Merge`.
- Branch/remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Initial HEAD: `d48d500cb4b71493b8ca08b50dbc7d18203214f2`.
- `git status --short --branch`: clean `main`.
- `git fetch origin main`: passed.
- `git rev-list --left-right --count HEAD...origin/main`: `0 7`; fast-forward only to synchronized HEAD `d48d500cb4b71493b8ca08b50dbc7d18203214f2`.
- After sync, local `HEAD = origin/main`; no local or owner changes were present.

## Implementation
- Rebuilt the runtime composition in `scripts/campaign/world_map_controller.gd`, used by the existing production `WorldMapScene.tscn`: owner V02 ocean background, route segments, existing clouds and boat, title frame/text in the sky, compass and back button, and ten independently rendered island entries.
- Updated `scripts/campaign/island_entry.gd`: island art is visible and its button rect is the hit target; art, hit center, label offset, state treatment, and size use the same island record. Decorative controls ignore pointer input. Existing locked-island feedback remains functional.
- Updated only World Map presentation fields in `data/campaign/islands.json`. Island IDs, ordering, unlock rules, level/reward data, and campaign semantics were preserved. The approved centers/sizes are used within V04 tolerance. Azure Bay is 2 px higher and Sunset Island 2 px lower than the preview center to remove their 3.5 px rectangular hitbox overlap while remaining within the ±2 px center tolerance.
- Added the real-input production/layout probe `tests/m21_world_map_production_v05_probe.gd` and updated stale M12 World Map expectations in `tests/m12_world_map_probe.gd`.
- Refreshed the UI asset manifest/dimensions/semantic count with the repository catalog tool so owner V01/V02 ocean sources are inventoried (358 assets). No source art was modified.
- Added the measured runtime layout report `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/WORLD_MAP_PRODUCTION_LAYOUT_V05.json` and seven renderer captures under `evidence/production-v05/`.
- No gameplay, R04 surface/profile, campaign progression, navigation-controller, Island Map controller, or root `TASKS.md` changes.

## Verification and exact results
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m21_world_map_production_v05_probe.gd` — exit 0; `M21_WORLD_MAP_PRODUCTION_V05_RESULT=PASS captures=7 mouse=PASS touch=PASS`. Real viewport Main Menu PLAY, Sunny Cove mouse input and `InputEventScreenTouch` each opened the visible Sunny Cove Island Map with 100 level buttons. Island Map and World Map Back controls were also exercised with viewport input.
- `godot_console.exe --headless --path . --script res://tests/m12_world_map_probe.gd` — run twice consecutively; exit 0 both; `M12_WORLD_MAP_RESULT=PASS` both runs.
- `godot_console.exe --headless --path . --script res://tests/m13_island_map_probe.gd` — exit 0; `M13_ISLAND_MAP_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m20_app_shell_probe.gd` — exit 0; `M20_CHILD_01_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m20_campaign_ux_probe.gd` — exit 0; `M20_CHILD_05_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m10_campaign_architecture_probe.gd` — exit 0; `M10_CAMPAIGN_ARCHITECTURE_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m11_save_migration_progression_probe.gd` — exit 0; `M11_SAVE_MIGRATION_PROGRESSION_RESULT=PASS`. The malformed-save recovery fixture emits its expected JSON parse diagnostics.
- `godot_console.exe --headless --path . --script res://tests/m14_gameplay_session_bridge_probe.gd` — exit 0; `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m21_r04_gameplay_surface_authority_probe.gd` — exit 0; `M21_R04_SURFACE_PROBE_RESULT=PASS islands=10 checks=71`.
- `python tools/ui_assets/rebuild_asset_catalog_r04.py` — exit 0; `R04_ASSET_CATALOG=PASS current_pngs=358 dimensions=358`.
- `python tools/ui_assets/validate_assets.py` — exit 0; manifest 358/358, R04 10/10, retired art absent, invalid semantic duplicates 0.
- `godot_console.exe --headless --editor --path . --quit` — exit 0; clean import/class scan completed.
- `godot_console.exe --headless --path . --quit-after 3` — exit 0; regular project boot.
- `git diff --check` and `git diff --cached --check` — exit 0.
- The renderer report records 10 islands, no hitbox overlaps, no viewport clipping, and no header collisions. Every island center and size meets the V04 locked tolerance; every art center matches its hit center.

## Incidental editor normalization
- The headless Godot editor rewrote the existing `GameFeelFlow` autoload reference in `project.godot` from its path form to Godot's equivalent UID form. This was the only incidental tracked editor change. The exact original path line was restored; final `git diff -- project.godot` is empty and `project.godot` is not part of the implementation commit.

## Manual review and remaining gates
- Reviewed the full-resolution production render and the Sunny Cove Island Map capture; checked title-in-sky placement, visible separate islands, varied sizes, labels, decoration, clipping, and route order.
- The renderer-driven mouse/touch input checks are builder evidence. Owner-native F5 acceptance and the independent GPT production audit were not performed and remain pending.
- Root `TASKS.md` is byte-for-byte unchanged; `git diff --exit-code -- TASKS.md` returned exit 0.

## Commits and publication
- Implementation/evidence commit: `14762ae58c4e12e374a8b5fdba305b80e56d427f` (`Integrate owner-approved World Map composition V05`).
- The implementation/evidence commit was pushed to `origin/main`; immediately afterward, local `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` all equaled `14762ae58c4e12e374a8b5fdba305b80e56d427f`; ahead/behind was `0/0`.
- This log is published in its own following commit. Final local/origin/live-main equality after that log-only publication is verified and reported in the handoff.
- Required stop marker: `AWAITING_GPT_M21_WORLD_MAP_PRODUCTION_AUDIT_V05`.
- BCM-M21-001 remains open; BCM-M21-006 was not started.
