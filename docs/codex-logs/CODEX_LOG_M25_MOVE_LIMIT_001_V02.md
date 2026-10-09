# BCM-M25-MOVE-LIMIT-001 execution log V02 — implementation and builder evidence

- Work item / prompt: `BCM-M25-MOVE-LIMIT-001`, master prompt and locked audit criteria, 2026-10-09.
- Start HEAD after required sync: `d71cd676aad4986b8acd522c1f94a76ce2380327`.
- Branch / remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Sync preflight: see immutable V01 baseline log. Before publication, `git fetch origin main` and `git rev-list --left-right --count HEAD...origin/main` returned `0 0`.
- Implementation commit: `debae81` (`Add Sunny Cove move limit`). This commit contains implementation, focused probe, immutable V01 baseline log, and all M25 task evidence. The present V02 log is a separate evidence commit.
- Files changed by implementation: `data/campaign/levels/sunny_cove.json`; `scripts/campaign/gameplay_session_bridge.gd`; `scripts/game_manager.gd`; `scripts/merge_queue.gd`; `scripts/shot_controller.gd`; `tests/m25_move_limit_probe.gd`; and `coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-MOVE-LIMIT-001/**`.
- Behavior: Sunny Cove L6 alone has candidate `move_limit: 35`. Count is tied to successful `shot_fired` launch commits with per-drink dedupe. The bridge exposes budget state, retry resets the counter, launch is denied after 35, move exhaustion waits for settled drinks/merge queue and resolves once as `MOVES_EXHAUSTED`, and objective completion wins even when it resolves on shot 35. The HUD displays remaining moves and changes to warning color at five or fewer. Other levels retain unlimited fallback. Existing score-star thresholds and time rules remain unchanged.
- Calibration: `calibration_report.md` describes legitimate natural trials and limitations; `level_budget_recommendations.csv` has 100 structural estimates, all except L6 explicitly marked not activated and for owner review. Move-based stars are a separate, non-applied option. Candidate 35 has a natural 22-shot 3-star completion with 13 moves of headroom, an independent natural completion on move 35, and natural exhaustion routes. This is a small policy-stratified sample, not a population fairness estimate; owner playtesting and independent review remain appropriate before enabling other levels.

## Commands and results

Godot runtime version: `4.7.2.stable.official.ed1daf0bf`.
All Godot sessions used isolated `APPDATA` and `LOCALAPPDATA` under `C:\Users\sekip\AppData\Local\Temp\BCM-M25-MOVE-LIMIT-001-20261009\`; task-specific evidence outputs stayed under this session's evidence directory. The owner AppData save tree and pre-existing owner-local artifacts were hashed before the first probe. `protected_hashes_after.json` contains the comparison and disposition.

- `godot_console.exe --headless --editor --path . --quit`: exit 0; final clean-import/parse run, no script errors, parse errors, errors, or warnings in captured output (`runs/final_editor_import*`).
- `godot_console.exe --headless --path . --quit-after 120`: exit 0; no script errors, parse errors, errors, or warnings (`runs/final_boot_120_frames*`).
- `godot_console.exe --headless --path . --script res://tests/m25_move_limit_probe.gd`: PASS, exit 0 (`runs/session_contract_final*`). Covers configured/unlimited fallback, pause, dedupe, 35th/36th shot boundary, retry reset, current score-star parity, and objective-completion precedence.
- Real GL production route, FULL, 720×1280: PASS, natural `LOSE/MOVES_EXHAUSTED` at 35; real touch Retry reset to 35; second natural loss; real mouse Island Map routed once (`runtime_final_full_720_v02/`, `runs/runtime_final_full_720_v02_gl.txt`).
- Real GL production route, REDUCED, 720×1280: PASS, natural loss at 35; real touch Retry reset; second natural loss; real mouse Island Map routed once (`runtime_final_reduced_720/`, `runs/runtime_final_reduced_720_gl.txt`).
- Real GL objective route, FULL, 720×1280: PASS, natural WIN after 22 shots, score 3,591, 3 score stars (`runtime_objective_full/`, `runs/runtime_objective_full_gl.txt`).
- Real GL objective route, REDUCED, 720×1280, latest source: PASS, natural WIN on exactly shot 35, score 4,394; 35 real mouse shots and normal objective completion prove last-move WIN precedence (`runtime_final_reduced_objective_720/`, `runs/runtime_final_reduced_objective_720_gl.txt`).
- Additional 720×1440 real routes: objective policy naturally won in 25 moves; max-spread policy naturally exhausted at 35. FULL and REDUCED HUD captures at both 720×1280 and 720×1440 show clear placement above the playable table; metadata verifies no visible To-Go artwork overlap (`layout_final_720/`, `layout_final_1440/`).
- M21 GL mobile QA twice, 16 captures per run: both PASS, exit 0 (`regression/m21_mobile_qa_run1/`, `regression/m21_mobile_qa_run2/`).
- Regression results: M02 physics PASS; M09 audio/haptics PASS; M15 VIP/economy PASS; M21 full progression PASS; M22-001 PASS; M22-002 PASS (27 checks); M22-003 PASS (97 checks); M23-001/002/003 PASS; M24-001/002/003 PASS; M25 result presentation PASS (22 checks, 0 failures). Raw outputs and exit codes are under `runs/regressions/`.
- `git diff --check` and `git diff --cached --check`: pass.
- Root `TASKS.md`: byte-identical to `HEAD:TASKS.md`; not staged or modified by Codex.

Some initial regression invocations had harness-output directory setup errors or a wrong output path; those exact initial logs are retained. Each affected probe was rerun with its evidence parent directory created and passed. They were output setup issues, not product test failures.

## Owner-work protection and scope

- Original modified owner files and user save files were inventoried before probes; isolated app data was used throughout. There are 259 unchanged inventory entries and no new files in the protected M23-R01 directory. `project.godot` was restored byte-for-byte from the retained owner-local safe-sync stash (`7174030E8BC658C7E0346DD328917905EB36AAFEB7C70D02C6D5B2A00F92D1BD`) after Godot rewrote its autoload reference during editor import. It remains unstaged and is not part of the implementation commit. The pre-probe inventory captured the temporary path-form variant, so its later comparison records that known difference.
- No changes were staged outside the six implementation/test files, this task's evidence folder, and its V01 baseline log. Pre-existing M21/M22/M23 owner-local modifications and untracked files remain unstaged and untouched.
- Root `TASKS.md` was not modified; no M26 work started.

## Limitations and handoff

- These are builder tests and natural automated strategy trials, not the independent acceptance audit or broad human fairness study. Level budget recommendations are estimates only; only L6 is activated. No move-star policy is applied.
- Full completion requires the independent ChatGPT audit, not this builder log. Awaiting `AWAITING_GPT_M25_MOVE_LIMIT_001_AUDIT`.
- Publication verification (`HEAD = origin/main = remote main`) is recorded in the post-push audit addendum by the caller; no tracker transition is claimed here.
