# Codex Execution Log — BCM-M26-001 V01

Status: `AWAITING_GPT_M26_001_AUDIT_V01`

- Work item: `BCM-M26-001`, new Island Map level unlock and milestone presentation.
- Prompt version: `BCM-M26_MASTER_V01` / child prompt `BCM-M26-001_PROMPT_V01`.
- Start HEAD: `459d7013676be4ad9b7291e33df2867779017520`.
- Implementation/evidence end HEAD: `909a080a9fd293fa40bdbda851d6a85bf67d6767`.
- Branch: `main`.
- Remote: `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Initial sync preflight: from `4a68179`, `HEAD...origin/main` was `0 7`; inventoried seven modified tracked paths and five untracked owner/evidence paths. Incoming changes touched `TASKS.md` and M25/M26 coordination files only, disjoint from the dirty paths. Created tracked-only stash `owner-local-safe-sync-4a68179`, fast-forwarded to `459d701`, and restored the stash without dropping it. Post-sync `HEAD...origin/main` was `0 0`.
- Pre-publication fetch: `git fetch origin main`; `HEAD...origin/main` was `1 0` before push. After pushing implementation/evidence commit `909a080`, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `909a080a9fd293fa40bdbda851d6a85bf67d6767`.
- Owner work: local `project.godot`, M21/M22 evidence changes, and untracked M21/M23 paths were not staged or committed. Root `TASKS.md` was not modified.
- Files changed in the implementation/evidence commit: Island Map controller and level-button target tagging; presentation bridge and policy; campaign settings propagation; M22 cap regression expectations; M26 focused probe; five real GL captures; probe and user-data isolation reports.
- Implementation summary: Island Map listens to authoritative CampaignManager pre/post progression snapshots. New locked-to-open, milestone-reached, and milestone-claimed transitions queue stable, deduplicated requests and target the affected level art or milestone marker. Hidden-map events flush once when the map returns. Refresh, re-entry, replay, and restart do not replay consumed transitions. Reduced Motion settings reach the Island Map bridge through campaign navigation and the application shell. Layout, hitboxes, progression state, and gameplay rules remain unchanged.
- Commands/tests and exact results:
  - `godot_console.exe --path <sandbox> --script res://tests/m26_001_island_map_presentation_probe.gd` — `M26_001_ISLAND_MAP_RESULT=PASS captures=5 failures=0 dispatches=23` using Godot `4.7.2.stable.official.ed1daf0bf` and OpenGL Compatibility.
  - `godot_console.exe --headless --path <sandbox> --script res://tests/m22_003_effect_policy_probe.gd` — `M22_003_EFFECT_POLICY_RESULT=PASS checks=97 failures=0 authority_hash=2961871060`.
  - `godot_console.exe --headless --path <sandbox> --script res://tests/closeout-001/m22_003_effect_policy_probe_closeout.gd` — `M22_003_EFFECT_POLICY_RESULT=PASS checks=97 failures=0 authority_hash=2961871060`.
  - `godot_console.exe --path <sandbox> --quit-after 120` — exit code `0`; 120-frame GL boot completed. Godot emitted two invalid UID warnings and fell back to their text paths.
  - `git diff --cached --check` — no whitespace errors before the implementation/evidence commit.
  - A clean editor import was attempted with `godot_console.exe --headless --editor --path <sandbox> --quit`; it exited `1` because the existing Godot AI plugin references missing `res://addons/godot_ai/export/mcp_export_plugin.gd`. This file is absent from synchronized `origin/main`; no substitute was added.
- Godot parse/run evidence: focused production navigation probe passed. Standalone 120-frame project boot passed. Clean editor import remains blocked by the missing plugin source above.
- Manual checks performed: reviewed the five captured production Island Map GL frames at 720×1280 and 720×1440. Owner visual acceptance remains pending.
- Checks not performed: full M02–M25 regression suite, two separate mobile QA runs, owner visual acceptance, and independent ChatGPT audit.
- User-data isolation: all Godot runs used the uniquely named sandbox project `BCM-M26-001-459d701-Sandbox`, whose separate `user://` directory was created. The post-run hash report records 229/229 real `CocktailMerge` user-data files unchanged, zero added files, and 31/31 inventoried owner files unchanged. See `coordination/sessions/BCM-M26-MASTER-V01/evidence/M26-001/user_data_isolation_hashes.json`.
- Known limitations: editor import cannot complete until the pre-existing missing Godot AI plugin source is restored. The plugin import warning does not block the focused M26-001 GL run or 120-frame boot.
- Final implementation/evidence commit SHA: `909a080a9fd293fa40bdbda851d6a85bf67d6767`. This execution log is published in a following documentation-only commit; the final pushed `main` parity is recorded in the task handoff.
- `TASKS.md` was read and left byte-for-byte unchanged.
- Required stop marker: `AWAITING_GPT_M26_001_AUDIT_V01`. No M26-002 work started.
