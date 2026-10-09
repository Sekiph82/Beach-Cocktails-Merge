# BCM-M25-PERCENT400 Child 03 execution log

- Prompt: `coordination/sessions/BCM-M25-MASTER-V01/children/BCM-M25-PERCENT400-CHILD-03_PROMPT.md` (under master prompt `BCM-M25-PERCENT400_MASTER_PROMPT.md`).
- Start HEAD: `c507c5c0cab5c19088c43dce5a4136d933235456`; branch/remote: `main` / `origin`.
- Sync: no new incoming commits at child start; owner-local dirty evidence and `project.godot` stayed untouched and unstaged.
- Files: `tests/m14_gameplay_session_bridge_probe.gd`, `tests/m18_completion_progression_probe.gd`, `tests/m18_star_contract_probe.gd`, `tests/m23_003_combo_milestone_probe.gd`, closeout clone of the M23 probe, Child 03 prompt, and focused regression stdout/summary.
- Implementation: migrated score-derived star assertions to move thresholds; added exact 200%, 300%, and 400% edges, score independence, optional VIP/inclusive denominator assertions, a 300%-move completion fixture, replay best-score/best-star monotonicity, and no score-derived star-progress feedback.
- Exact results: M14 gameplay-session bridge probe exit 0; M18 star-contract, replay persistence, cumulative rewards, and completion progression exit 0; M23 combo milestone and closeout clone exit 0; M17 VIP optionality exit 0. Captured output is under `evidence/M25-PERCENT400/regressions/`.
- Fixture correction: an early M14 probe revision assumed the fixture's L12 VIP represented 32 shots; the actual formula is 512. The assertion and 2T boundary were corrected to inclusive T=544 and the final M14 run passed. An initial M18 progression run used the retired score-star fixture and failed; after migrating it to 12 moves against T=4 (300%), rerun passed. Both facts remain visible in raw evidence and the master log.
- Limitations: independent audit remains pending; no gameplay/economy tuning was done.
- Child commit: `99e746e310b6584ef30ccef36723bec4b9b10410`, pushed to `origin/main`.
- End implementation/evidence SHA at completion snapshot: `7eb35fc02a4c41b9012d00cd1b45d25fd294c750`; `HEAD`, `origin/main`, and live `refs/heads/main` matched at verification. Owner-local diffs remained unstaged and untouched.
- Root `TASKS.md` was not modified by Codex.
