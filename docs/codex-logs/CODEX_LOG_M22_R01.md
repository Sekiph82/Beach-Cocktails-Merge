# CODEX_LOG_M22_R01

- Work item: BCM-M22-R01 REDUCED policy/matrix consistency remediation.
- Prompt: `coordination/sessions/BCM-M22-MASTER-V01/CHATGPT_M22_R01_REMEDIATION_PROMPT.md`.
- Start HEAD: `4aaf1e156aba6780435798517c4d8366ea0e2d32`.
- Branch/remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Sync preflight: behind-only by 3 before sync; incoming paths were `TASKS.md` and two M22 session documents. Both owner-local untracked PNG paths were inventoried and path-disjoint. Safe `git merge --ff-only origin/main` completed; post-sync local/origin/live-main SHA matched at `4aaf1e156aba6780435798517c4d8366ea0e2d32`, ahead/behind `0/0`.
- Owner-local evidence: both M21 Home PNGs preserved and untouched.
- Root `TASKS.md`: read only and must remain unchanged by this remediation.

## Execution record

### Sync and scope

- Before fetch, local HEAD and `origin/main` were `dfd5de70bfcae54a79a7f92d61199f9d29dc5909`; live GitHub main was `4aaf1e156aba6780435798517c4d8366ea0e2d32`.
- Local was behind-only `0/3`. Incoming paths were `TASKS.md`, the M22 audit, and this R01 prompt. They did not overlap the two untracked owner PNGs. `git merge --ff-only origin/main` completed; synchronized start HEAD is `4aaf1e156aba6780435798517c4d8366ea0e2d32`; ahead/behind `0/0`. Existing stashes were left untouched; no stash was created or applied.
- Scope stayed within the policy, policy probe, generated M22-003 evidence/matrix, R01 regression evidence, and this new log. No production effect mapping, gameplay authority, or owner visuals were changed.

### Remediation

- Set REDUCED Spark amount, lifetime, speed, and allowed presets to zero for `merge` BASE/SURGE/PEAK and `vip_delivery` / `vip_complete`, matching their existing categorical no-particles prose.
- Added a semantic regression that finds REDUCED styles that say no particles and verifies zero Spark amount for every applicable band, including all three merge bands. The fixture dispatch for REDUCED dust now uses `order_progress`, whose policy allows bounded dust.
- The probe regenerates the owner matrix from `PresentationEffectPolicy.render_markdown_matrix()`, rereads the saved bytes, checks exact equality, and writes source/matrix SHA-256 proof.
- Matrix/source parity: `rendered_matches_saved_bytes=true`; policy source SHA-256 `5bc45eee02e171fb6603b77409c69a5e0a78fa21ab27b2dfcc6af19185633de7`; matrix SHA-256 `3835af87f1a570026c3b440722da64859d0052138a4a89069669445ca2cd1519`.
- The modified M22-002 probe output and M21 progression/World Map reports were copied into `evidence/M22-R01/`; historical tracked report paths were restored.

### Commands and results

Exact commands/results are retained in `coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-R01/commands_and_results.txt`.

- M22-001 contract probe: exit 0; `M22_001_PLUGIN_CONTRACT_RESULT=PASS checks=21 failures=0 authority_hash=891736178`.
- M22-002 semantic bridge probe: exit 0; `M22_002_SEMANTIC_BRIDGE_RESULT=PASS checks=27 failures=0 authority_hash=891736178`.
- M22-003 policy probe: exit 0; `M22_003_EFFECT_POLICY_RESULT=PASS checks=97 failures=0 authority_hash=891736178`.
- M02 physics, M09 audio/haptics, M15 VIP/economy, M21 full progression, and M21 production World Map probes: each exited 0 and reported PASS. Progression completed 100 levels across five checkpoints. World Map mouse/touch navigation passed with `captures=0`.
- `godot_console --headless --editor --path . --quit`, `godot_console --headless --path . --quit-after 5`, and `godot_console --headless --path . --check-only --script res://scripts/game_manager.gd`: exit 0.
- `rg -n --glob '*.gd' 'callv|\\.call\\(' scripts`: exit 0. Effect invocations remain only in `PresentationFeedbackBridge`; `PresentationPluginContract` uses `call()` only for read-only registry queries. Bridge production dispatch remains false and no combo-dispatch path was added.
- `git diff --check`: exit 0. `git diff --exit-code -- TASKS.md`: exit 0; tracker unchanged.
- An early development run caught an `Array[int]` assignment error in the new test setup; changing the local chain list to an untyped `Array` fixed it. Final M22-003 run passes as recorded above.

### Limitations and publication

- M09/M15/M21 headless screenshot capture is unavailable. The World Map probe emits null-texture capture diagnostics but exits 0 with mouse/touch and navigation assertions passing; no screenshot acceptance is claimed.
- No production effects/particles were activated. Owner matrix approval remains pending; M23 was not started.
- Code/evidence commit SHA: `9171a9bb59e1ffd1abc05b024a99ca1113436033` (`fix(m22): align reduced particle policy`).
- After code/evidence push and fetch, local HEAD = `origin/main` = live `refs/heads/main` = `9171a9bb59e1ffd1abc05b024a99ca1113436033`; ahead/behind `0/0`.
- The log-record commit is the final publication step; final ref equality is reverified after that push.
- `TASKS.md` was not modified. Both owner-local PNG files remain untracked and untouched.

Required stop marker: `AWAITING_GPT_M22_R01_REAUDIT`.
