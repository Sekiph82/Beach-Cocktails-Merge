# Codex Execution Log — BCM-M26-001-R01 V01

Status: `AWAITING_GPT_M26_001_R01_AUDIT_V01`

- Work item: `BCM-M26-001-R01`, Godot AI editor-import dependency and process-cleanup remediation.
- Prompt: `BCM-M26-001-R01_PROMPT.md`; independent audit: `CHATGPT_M26_001_AUDIT_V01.md`.
- Start HEAD: `c26ca6bd2447fbe1bdfd40f127031aa8dd2ee060`.
- End HEAD after the evidence commit and before the documentation-only commit: `f5c224529e9aad6784878235b585d1cf46066265`.
- Branch: `main`; remote: `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Sync preflight: initial `HEAD...origin/main` was `0 4`. Inventoried seven modified tracked paths and fourteen untracked owner/evidence paths. Incoming paths (`TASKS.md`, R01 prompt, R01 audit) were disjoint. Created tracked-only stash `owner-local-safe-sync-b5a61cf`, fast-forwarded to `c26ca6b`, and applied that exact stash without dropping it. Untracked owner paths were left in place. Post-sync `HEAD...origin/main` was `0 0`.
- `TASKS.md` was read and not modified. No new GitHub branch is authorized or planned.
- Process cleanup: before the new Godot runs, the prior exact sandbox had two matching Godot processes, PIDs `38888` and `33332`, both with the exact sandbox path and probe command line. Both had empty window titles and reported responsive. Graceful close failed for `38888`, which was force-terminated only after revalidating its PID and command line; `33332` exited before escalation. The post-cleanup exact sandbox process count was zero. Seven unrelated Godot processes were left untouched. The owner screenshot reported three gray windows; process inventory found two exact task PIDs, both with headless command lines and no window titles. See `process_cleanup.json`.
- Source provenance: existing local `addons/godot_ai/export/mcp_export_plugin.gd` was ignored by `.gitignore:16` and absent from Git index. The local bytes and separately downloaded official Godot AI `v4.3.0` source both hash to `E32FD58F473C4D9C974D866ADA447058E1F71B933AADCF4B1EF6C6C4AD2A470A`; the official tag resolves to `b82b5c519b1b17228f70d8effce1626f391bd1dd`. Tracked the exact existing file without replacing or editing its bytes. See `source_provenance.json`.
- Disposable test sandbox: detached worktree at `C:\Users\sekip\.codex\worktrees\m26-001-r01-verified-source`; only its `project.godot` name was changed to `BCM-M26-001-R01-VERIFIED-SANDBOX`. Godot user data used the distinct `app_userdata\BCM-M26-001-R01-VERIFIED-SANDBOX` directory. The sandbox was fresh before test launch.
- Process harness: added `tests/m26_001_r01_godot_runner.ps1`. It refuses launch if the exact sandbox already has Godot processes, records the launched PID tree, applies a timeout, and performs graceful/targeted cleanup in `finally`. All seven invocations completed with exit code 0 and `cleanup_verified=true`; every result recorded zero matching project processes after cleanup.
- Commands and exact results (Godot `4.7.2.stable.official.ed1daf0bf`):
  - `godot_console.exe --headless --editor --path <sandbox> --quit` — exit `0`; fresh editor scan/import completed with all three project plugins enabled. Godot AI reports its editor UI disabled in headless mode; the preload now resolves.
  - `godot_console.exe --path <sandbox> --quit-after 120` — exit `0`; 120-frame boot completed. Startup emitted invalid UID fallback warnings for `WorldMapScene.tscn` and `scenes/main.tscn`.
  - `godot_console.exe --path <sandbox> --script res://tests/m26_001_island_map_presentation_probe.gd` — `M26_001_ISLAND_MAP_RESULT=PASS captures=5 failures=0 dispatches=23`; actual OpenGL Compatibility viewport captures at 720×1280 and 720×1440 are under `captures/`.
  - `godot_console.exe --headless --path <sandbox> --script res://tests/m22_001_plugin_contract_probe.gd` — `PASS checks=21 failures=0`.
  - `godot_console.exe --headless --path <sandbox> --script res://tests/m22_002_semantic_bridge_probe.gd` — `PASS checks=27 failures=0`.
  - `godot_console.exe --headless --path <sandbox> --script res://tests/m22_003_effect_policy_probe.gd` — `PASS checks=97 failures=0`.
  - `godot_console.exe --headless --path <sandbox> --script res://tests/closeout-001/m22_003_effect_policy_probe_closeout.gd` — `PASS checks=97 failures=0`.
- User-data/source integrity: before and after manifests hash all 229 files under the real `CocktailMerge` app userdata. Result: 229/229 unchanged, zero added and zero removed. The dirty owner checkout `project.godot` hash and existing local plugin file hash also match their pre-run values. The sandbox created 12 files only in its distinct user-data folder. See `user_data_before.json`, `user_data_after.json`, and `test_summary.json`.
- Files changed for this R01: tracked verified export source and process runner in commit `a11b0f0771edc11f1ec67918241020e4c8ec8e4e`; new R01 evidence package (41 files); this execution log. Existing owner-local edits/untracked files, prior M26 evidence paths, and root `TASKS.md` were not staged.
- Source/harness commit SHA: `a11b0f0771edc11f1ec67918241020e4c8ec8e4e`.
- Final implementation/evidence commit SHA: `f5c224529e9aad6784878235b585d1cf46066265`. A following documentation-only commit publishes this log. `TASKS.md` was read and not modified. No M26-002 or M27 work started.
- Checks not performed: full M02–M25 regression matrix, two separate M21 mobile QA runs, and owner visual acceptance. M26 GL probe uses CampaignManager test fixtures; it does not represent natural player-operated completion, consistent with the prior independent audit limitation.
- Required stop: `AWAITING_GPT_M26_001_R01_AUDIT_V01`; wait for independent ChatGPT audit.
- Required stop: `AWAITING_GPT_M26_001_R01_AUDIT_V01`; do not start M26-002 or M27.
