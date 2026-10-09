# BCM-M25-PERCENT400 Child 02 execution log

- Prompt: `coordination/sessions/BCM-M25-MASTER-V01/children/BCM-M25-PERCENT400-CHILD-02_PROMPT.md` (under master prompt `BCM-M25-PERCENT400_MASTER_PROMPT.md`).
- Start HEAD: `a06e2e817fbf3b54ed6fa06dd45bbfd7a01cf635`; branch/remote: `main` / `origin`.
- Sync: Child 01 had already been pushed. GitHub advanced with CAL02 audit/guardrail commits before the next push. The two-sided history and changed paths were inspected; only `TASKS.md` and the new audit document changed remotely, disjoint from owner-local dirty paths. A normal merge preserved both histories without conflicts; no rebase/reset/stash was used.
- Files: `scripts/campaign/gameplay_session_bridge.gd`, `scripts/game_manager.gd`, `evidence/M25-PERCENT400/runners/m25_percent400_runtime_probe.gd`, and Child 02 prompt.
- Implementation: expose To-Go/VIP/total T in session and move-budget state, count each committed shot once, enforce the derived cap, keep terminal settling behavior, remove score-based star preview cues, and render a dynamic MOVES label without a fixed stale cap.
- Exact runtime evidence: production GL FULL/MAX_SPREAD and REDUCED/MAX_SPREAD exhaust naturally at 48 moves for L6 with `MOVES_EXHAUSTED`, zero stars, and Retry resets the budget. FULL objective play wins at 43 moves; REDUCED objective play wins at 42 moves. Both are within the 48-move cap and show one star. The final shot precedence, duplicate protection, 49th-shot rejection, Retry, and Island Map routing are covered by the runner and focused probes.
- Commands/checks: isolated Godot 4.7.2 production GL sessions at 720x1280 and 720x1440; stdout, exit codes, result metadata, screenshots, and logs are in `evidence/M25-PERCENT400/`.
- Limitations: simulated GL evidence is not physical-device acceptance. Independent audit remains pending.
- Child commit: `c507c5c0cab5c19088c43dce5a4136d933235456`, pushed to `origin/main`.
- End implementation/evidence SHA at completion snapshot: `7eb35fc02a4c41b9012d00cd1b45d25fd294c750`; `HEAD`, `origin/main`, and live `refs/heads/main` matched at verification. Owner-local diffs remained unstaged and untouched.
- Root `TASKS.md` was not modified by Codex; the latest remote tracker change was merged verbatim.
