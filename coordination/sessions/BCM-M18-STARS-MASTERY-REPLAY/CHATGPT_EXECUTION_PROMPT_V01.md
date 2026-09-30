# BCM-M18-BATCH-001 - Stars, Score Mastery, Milestones, and Replay

Status: AUTHORIZED CODEX MILESTONE-BATCH HANDOFF

This is the complete ordered M18 package. CODEX is authorized to execute all six children in order, with one child handoff at a time. The current task cursor in `TASKS.md` names this batch, not only Child 01.

## Required reading

- `AGENTS.md`
- `coordination/README.md`
- `coordination/AUDIT_POLICY.md`
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- `docs/CAMPAIGN_MODULE_IMPLEMENTATION_V01.md`
- `TASKS.md`
- this master prompt and `CHATGPT_AUDIT_CRITERIA_V01.md`
- every ordered child prompt and matching locked child criteria before that child begins

## Exact ordered package

1. `BCM-M18-001` - `CHATGPT_EXECUTION_PROMPT_V01_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V01_CHILD_01.md` / `CODEX_LOG_V01_CHILD_01.md`
2. `BCM-M18-002` - `CHATGPT_EXECUTION_PROMPT_V01_CHILD_02.md` / `CHATGPT_AUDIT_CRITERIA_V01_CHILD_02.md` / `CODEX_LOG_V01_CHILD_02.md`
3. `BCM-M18-003` - `CHATGPT_EXECUTION_PROMPT_V01_CHILD_03.md` / `CHATGPT_AUDIT_CRITERIA_V01_CHILD_03.md` / `CODEX_LOG_V01_CHILD_03.md`
4. `BCM-M18-004` - `CHATGPT_EXECUTION_PROMPT_V01_CHILD_04.md` / `CHATGPT_AUDIT_CRITERIA_V01_CHILD_04.md` / `CODEX_LOG_V01_CHILD_04.md`
5. `BCM-M18-005` - `CHATGPT_EXECUTION_PROMPT_V01_CHILD_05.md` / `CHATGPT_AUDIT_CRITERIA_V01_CHILD_05.md` / `CODEX_LOG_V01_CHILD_05.md`
6. `BCM-M18-006` - `CHATGPT_EXECUTION_PROMPT_V01_CHILD_06.md` / `CHATGPT_AUDIT_CRITERIA_V01_CHILD_06.md` / `CODEX_LOG_V01_CHILD_06.md`

The required master log is `CODEX_LOG_V01.md`. The required final marker is `AWAITING_M18_AUDIT_V01`.

## Scope and frozen boundaries

- Work only in `C:\Users\sekip\Desktop\Beach Cocktails - Merge` on `main`.
- Preserve the accepted v6.7 gameplay feel, R11 table/physics geometry, M15 economy/VIP behavior, M16 Sunny Cove content, and M17 difficulty evidence.
- Do not retune launch physics, merge physics, timers, canonical objectives, VIP targets/rewards, table geometry, HUD layout, or difficulty data as a side effect of M18.
- Do not start M19, M20, M21, or any unlisted feature. Do not create a second tracker or edit `AGENTS.md`.
- `TASKS.md` is ChatGPT-owned. CODEX must read it but must not edit it.
- Use existing campaign architecture: `CampaignManager`, `SaveManager`, `GameEconomy`, `GameplaySessionBridge`, `IslandMapController`, `LevelButton`, and the canonical `data/campaign` schemas. Prefer narrow data/API/UI additions over replacement of accepted systems.
- The M18 contract is mastery/progression only: stars are not an island-unlock gate; normal completion remains sufficient for next-level and island progression.

## Batch sequence and stop conditions

- Complete each child, publish its immutable `CODEX_LOG_V01_CHILD_0N.md`, and stop for the child boundary until its focused checks and clean remote equality are recorded.
- Do not skip, reorder, merge, or pre-accept children. If a child fails, is unverified, exposes a conflicting product specification, or requires owner-only/native acceptance, stop the entire batch and leave later children unstarted.
- Child 03 must not invent reward amounts or purchase/ads behavior when the repository lacks an owner-approved value. Record `OWNER_REQUIRED` and stop if exact reward configuration cannot be recovered from repository truth.
- The master log must record every child result, changed files, commands and exact exits, regression scope, limitations, and final synchronization equality. It must end with `AWAITING_M18_AUDIT_V01`.
- Do not claim `PASS`, close M18, or update `TASKS.md`. ChatGPT independently audits the pushed batch.

## Evidence requirements

For every child, record:

- synchronized preflight, branch/remote, start and end HEADs, and exact local/origin/remote equality;
- files changed and protected paths checked;
- exact focused test commands, complete relevant output, and exit codes;
- `git diff --check`, clean status, and proof `TASKS.md` was byte-for-byte unchanged;
- runtime captures where the child changes Island Map/result presentation, clearly labeled builder evidence;
- known limitations and any owner/native/device checks not performed.

Run regressions only after the child’s own focused checks pass. The final child must run the cumulative M18 suite plus the required legacy campaign/gameplay probes without modifying frozen behavior. Do not stage `.godot/`, caches, save files, exports, or machine-specific output.

## Final handoff

After Child 06 completes, publish the master log and stop at `AWAITING_M18_AUDIT_V01`. ChatGPT will audit all six child results, the master log, source/data/tests, runtime evidence, and the actual GitHub diff before deciding the M18 lifecycle state.
