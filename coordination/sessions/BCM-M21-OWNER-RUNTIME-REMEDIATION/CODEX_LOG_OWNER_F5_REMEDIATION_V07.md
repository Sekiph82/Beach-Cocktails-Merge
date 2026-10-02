# Codex Execution Log — BCM-M21-001 + BCM-M21-006 V07

Status: **Builder implementation and evidence committed; awaiting owner F5 acceptance and independent ChatGPT audit.**

## Work identity

- Prompt: `CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07_R01.md`
- Criteria: `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R01.md` plus V07 product and visual criteria.
- Branch / remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Synchronized V07 base SHA: `e9975dfbe23f0d2a31b9606a1144bb8baf368632`.
- Product and evidence commit SHA: `91b738a7c196ef9872303e464f75081d4549da04`.

## Sync and owner-local preservation

- The V07-R01 prompt’s stored preflight snapshot named local `82166db6bed433535707623131936daad9820133`, remote `88d08db22c5ca453c1725e19b608a9aae1cea8cd`, and six commits behind. A live fetch had advanced `origin/main` to `e9975dfbe23f0d2a31b9606a1144bb8baf368632`; live divergence was 0 ahead / 9 behind.
- Compared incoming paths before sync. No incoming commit touched `project.godot`, `addons/godot_ai/**`, or any of the 14 known `.translation` sidecars.
- Retained tracked-only stash: `2036e54ca81e88a9dc96317ed860af64c3e7379d`, `pre-v07-owner-godot-ai-project-settings`. Applied by SHA without dropping it. Older `pre-v04-owner-local-preserve` stash also remains retained.
- Fast-forwarded local `main` to synchronized base `e9975dfbe23f0d2a31b9606a1144bb8baf368632`; the sync-time local, `origin/main`, and remote `main` SHAs matched.
- Restored `project.godot` contains only the intended owner-local integration: `_mcp_game_helper` autoload and enabled `res://addons/godot_ai/plugin.cfg`. The plugin directory and all 14 sidecars were preserved. They were not staged or committed.
- Final working tree may remain intentionally dirty only for the owner-local `project.godot`, untracked `addons/godot_ai/**`, and those 14 known `.translation` sidecars.

## Implementation and evidence

- Authored the Sunny Cove V07 720×1280 surface from a fresh composition using new scenic and teak source plates. V06 transforms were not used as placement authority.
- Frozen surface SHA-256: `d68bd5456802ee04c15a66559780652a1d18ab1a3d0e8c9e21da68da3620b8bd`.
- Derived the playable geometry after freezing the surface; the provenance/calibration identifies the canonical V2 playable mask and reports an 11-vertex profile, `spawn_y=968`, `launch_y=947`, and `death_y=900`. The geometry debug and twelve-glass stress overlays use the frozen image and V2 authority. The deterministic shadow matches the V2 shadow master byte-for-byte; the edge overlay is derived from the final table.
- Updated Sunny Cove to use the single `gameplay_surface_v07.png` runtime texture and calibrated island-map anchors from the actual runtime map. No Sunny Cove runtime table, shadow, or edge layer is active.
- Added production-path GUI and gameplay probes, 720×1280 runtime screenshots, per-island World Map crops, probe reports/logs, builder audit, and owner checklist. The checklist owner result fields are blank.

## Commands and exact results

- `python tools/build_sunny_cove_gameplay_surface_v07.py` — exit 0; `SUNNY_COVE_V07_SURFACE_RESULT=PASS`, 720×1280; final image SHA above; shadow equals V2 master.
- `python tools/calibrate_sunny_cove_geometry_v07.py` — exit 0; `SUNNY_COVE_V07_GEOMETRY_RESULT=PASS`; 11 vertices, 12 stress placements inside V2 mask.
- `godot_console.exe --headless --editor --path . --quit` — exit 0 on Godot `4.7.2.stable.official.ed1daf0bf`. One warning reports that `res://original_reference/project.godot` is ignored because it is a second project file.
- `godot_console.exe --path . --script res://tests/m21_owner_f5_remediation_v07_gui_probe.gd` — exit 0; `M21_OWNER_F5_REMEDIATION_V07_GUI_RESULT=PASS clicks=15 captures=6`.
- `godot_console.exe --path . --script res://tests/m21_owner_f5_remediation_v07_gameplay_probe.gd` — exit 0; `M21_OWNER_F5_REMEDIATION_V07_RESULT=PASS mouse=10/10 touch=10/10 drinks=0 effects=0 captures=15`. Side and rear contacts passed. Final contact samples: left `(26.4809, 627.9224)`, right `(629.8873, 438.6142)`, rear `(323.5044, 406.2305)`.
- `godot_console.exe --headless --path . --script res://tests/m21_release_persistence_probe.gd` — exit 0; `M21_RELEASE_PERSISTENCE_RESULT=PASS`. `APPDATA` was isolated under `C:\Users\sekip\.codex\worktrees\m21-v07-persistence-evidence\AppData`; the owner’s usual user-data directory was not used.
- Visual review: inspected SC-01..SC-08 runtime images, three SC-06 boundary views, the clean full World Map, and each WM-01..WM-10 crop. All required builder entries are PASS in `BUILDER_SELF_VISUAL_AUDIT_V07.md/.json`.
- `git diff --check` and staged `git diff --cached --check` — PASS.
- Scanned gameplay, GUI, persistence, and editor-import logs for `ERROR:` and `SCRIPT ERROR:` — zero matches.

## Changed paths

- `data/campaign/islands.json` — Sunny Cove composite path, image-locked playable geometry, and runtime-calibrated map anchors.
- `assets/ui_assets/campaign/islands/sunny_cove/**` — V07 surface, derived table/edge/shadow, source plates, provenance, and calibration evidence.
- `tools/build_sunny_cove_gameplay_surface_v07.py`, `tools/calibrate_sunny_cove_geometry_v07.py`.
- `tests/m21_owner_f5_remediation_v07_gameplay_probe.gd`, `tests/m21_owner_f5_remediation_v07_gui_probe.gd`.
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/BUILDER_SELF_VISUAL_AUDIT_V07.md`, `BUILDER_SELF_VISUAL_AUDIT_V07.json`, `OWNER_F5_ACCEPTANCE_CHECKLIST_V07.md`, and `evidence/runtime/v07/**`.
- Root `TASKS.md` was not modified. Its pre-change SHA-256 was `bd6c1c9fc3ea9c1b2fb0267edf6d0bfb10c3e0a5967d538288dd45db1e02ef24`.

## Final repository state and handoff

- Product/evidence commit: `91b738a7c196ef9872303e464f75081d4549da04` on `main`.
- Before final handoff, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` were run after push; all three must match. The resulting main SHA is recorded in the handoff response and Git history.
- Explicit stage guard passed. No `project.godot`, `addons/godot_ai/**`, `.translation` sidecar, or `TASKS.md` path was staged.
- Native owner-device F5 acceptance is not performed by this builder. The owner checklist remains blank. No release-ready or independent-audit claim is made.
- `TASKS.md` remains byte-for-byte unchanged; only ChatGPT may update it after independent audit.

`AWAITING_OWNER_F5_ACCEPTANCE_V07`
