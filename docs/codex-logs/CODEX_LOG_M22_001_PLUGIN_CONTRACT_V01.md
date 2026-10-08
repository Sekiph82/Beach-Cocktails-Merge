# CODEX_LOG_M22_001_PLUGIN_CONTRACT_V01

## Work item
- Work item: BCM-M22-001 — Installed Plugin Contract + Graceful Fallback
- Prompt/criteria: `coordination/sessions/BCM-M22-MASTER-V01/BCM-M22-001_PROMPT_V01.md`, `BCM-M22-001_AUDIT_CRITERIA_V01.md`
- Branch/remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`)
- Start HEAD after sync: `45086e032cb91553f264c825abefcc2618b5cb06`
- Implementation/evidence commit: `3ea59622f1f024469d7eae78fb0463e9f37d3717`
- Required child stop marker: `M22_001_READY_FOR_MASTER_CONTINUATION`

## Sync preflight
- Initial tracked worktree: clean. Two unrelated owner-local untracked PNG evidence files under `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence/` were inventoried and left untouched.
- Fetch advanced `origin/main` from `4dff38f` to `45086e0`; divergence was `0 ahead / 13 behind`.
- Incoming changed paths were disjoint from the untracked owner evidence; no tracked owner edits existed, so no stash was created/applied. Historical stashes were listed and left untouched.
- Fast-forward only: `git merge --ff-only origin/main` succeeded.
- Post-sync: local `HEAD = origin/main = live refs/heads/main = 45086e032cb91553f264c825abefcc2618b5cb06`, `0/0`.

## Implementation and evidence
- Added `scripts/presentation_plugin_contract.gd`: generic Node-based capability discovery for `/root/GameFeelFlow` and `/root/Spark`; explicit refresh/cache; API, effect/combo/preset query; no plugin preloads, effect execution, per-frame polling, or gameplay/campaign mutation.
- Added `tests/m22_001_plugin_contract_probe.gd` and M22-001 evidence under `coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-001/`.
- Installed plugin source/config SHA-256 values, autoload/editor-plugin state, runtime effect/combo/preset names and defaults are recorded in `plugin_source_hashes.json` and `plugin_runtime_inventory.json`.
- Current package contains both tracked addon folders and enables their autoloads. Deleting addon files while retaining autoload declarations is not claimed as boot-safe.
- Forbidden effects remain `impulse`, `velocity`, `freeze_frame`, `time_scale`, and full-screen `camera_flash`; camera/screen shake is excluded. Stock GFF combos are not whitelisted.
- No visible production effect was executed or enabled. The plugin-call failure simulation is assigned to the M22-002 bridge boundary, where such calls can be safely exercised on isolated fixtures.

## Commands and exact results
- `godot_console.exe --headless --path . --script res://tests/m22_001_plugin_contract_probe.gd` — exit 0; `M22_001_PLUGIN_CONTRACT_RESULT=PASS checks=21 failures=0 authority_hash=891736178`.
- `godot_console.exe --headless --path . --editor --quit` — exit 0; editor scan, class registration, addon initialization, and asset import completed.
- `godot_console.exe --headless --path . --quit-after 2` — exit 0; main scene booted; both presentation autoloads initialized.
- `godot_console.exe --headless --path . --script res://tests/m21_full_progression_probe.gd` — exit 0; `M21_CHILD_03_RESULT=PASS completed=100 checkpoints=5`.
- `godot_console.exe --headless --path . --script res://tests/m21_world_map_production_v05_probe.gd` — exit 0; `M21_WORLD_MAP_PRODUCTION_V05_RESULT=PASS captures=0 mouse=PASS touch=PASS`.
- Historical `m21_owner_f5_remediation_v07_gameplay_probe.gd` — exit 1 at parse because it references removed `IslandEntry.MARKER_CENTER`; no M21 source/test correction was made in this M22 scope. Current V05 mouse/touch and 100-level save/progression probes passed.
- `git diff --check` and `git diff --cached --check` — exit 0.
- Optional-plugin source scan — no hard addon preload/reference in the new contract or test.

## Manual checks / unverified
- Manually inspected installed `plugin.cfg`, `game_feel_flow.gd`, `gff_combo.gd`, `gff_combo_entry.gd`, and `spark.gd`; hashes are in evidence.
- No owner visual acceptance, physical-device check, or production visual-effect run was performed; these are outside M22-001 and remain unverified.
- Godot editor rewrote the GFF autoload to a UID during import. The exact generated drift was inspected and restored; `project.godot` has its pre-run working-tree SHA-256 and is clean relative to HEAD. M21 tests rewrote two tracked historical evidence JSONs; their outputs were saved under M22-001 evidence and their pre-run bytes restored. No M21 evidence change is part of the commit.

## Repository and governance
- `TASKS.md` was read and not modified; staged diff for `TASKS.md` was empty.
- The two owner-local untracked PNG files remain present and unstaged.
- After pushing the implementation/evidence commit, verified:
  - `git rev-parse HEAD`: `3ea59622f1f024469d7eae78fb0463e9f37d3717`
  - `git rev-parse origin/main`: `3ea59622f1f024469d7eae78fb0463e9f37d3717`
  - `git ls-remote origin refs/heads/main`: `3ea59622f1f024469d7eae78fb0463e9f37d3717`
  - ahead/behind: `0/0`
- The builder log is published separately; the M22 master log records the post-log publication final SHA and parity.

## Execution chronology note
The initial implementation/test harness edits preceded creation of this child log. This sequencing deviation is recorded explicitly; no task scope, tracker, or owner evidence was altered to conceal it.

M22_001_READY_FOR_MASTER_CONTINUATION
