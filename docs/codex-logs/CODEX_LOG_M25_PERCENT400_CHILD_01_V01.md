# BCM-M25-PERCENT400 Child 01 execution log

- Prompt: `coordination/sessions/BCM-M25-MASTER-V01/children/BCM-M25-PERCENT400-CHILD-01_PROMPT.md` (under master prompt `BCM-M25-PERCENT400_MASTER_PROMPT.md`).
- Start HEAD: `80ebf4cacbf13d75b08973c25bdd88137c0e76a0`; branch/remote: `main` / `origin`.
- Preflight: began 0 ahead / 6 behind; incoming task prompt paths were disjoint from inventoried owner-local tracked and untracked files. Applied only the new tracked-only safe-sync stash, fast-forwarded to the then-current main, and left owner work unstaged. The full handling and later remote update are recorded in `CODEX_LOG_M25_PERCENT400_V01.md`.
- Files: `scripts/campaign/level_database.gd`, `data/campaign/levels/sunny_cove.json`, `tests/m25_move_limit_probe.gd`, `evidence/M25-PERCENT400/level_formula_audit.json`, formula-probe stdout/exit, and Child 01 prompt.
- Implementation: derive To-Go and enabled VIP ideal-L3 shots independently, sum for inclusive T, and derive `move_limit=4*T` on all validated level definitions. Removed only the stale explicit L6 limit 35; order targets unchanged. The probe independently audits each canonical level and 2T/3T/4T boundaries.
- Exact result: Godot 4.7.2 headless M25 formula probe exit 0: `M25_PERCENT400_RESULT PASS levels=100 vip_levels=25 overlap_levels=[8, 24, 32, 36, 56, 64, 72, 76, 80, 92, 96, 100]`. Formula output verifies L6 T=12/cap48, L8 T=16/cap64, L100 T=76/cap304 and records To-Go/VIP separately.
- Manual checks: inspected all 100 JSON definitions and overlap-level set. Runtime delivery remains normal-first; the inclusive denominator includes optional VIP even where that WIN ends before VIP completion. The formula audit explicitly records this and avoids double credit.
- Limitations: this is builder evidence, not balance approval or independent acceptance. Physical-device QA is not part of this child.
- Child implementation commit: `a06e2e817fbf3b54ed6fa06dd45bbfd7a01cf635`; pushed to `origin/main` and preserved in the merge commit after GitHub advanced concurrently.
- End implementation/evidence SHA at completion snapshot: `7eb35fc02a4c41b9012d00cd1b45d25fd294c750`; `HEAD`, `origin/main`, and live `refs/heads/main` matched at verification. Owner-local diffs remained unstaged and untouched.
- Root `TASKS.md` was not modified by Codex; its remote audit update was merged verbatim.
