# BCM-M04-M06-R01 — ChatGPT Orchestration Audit Criteria V01

This file governs the **single-session execution discipline**. It does not replace the detailed M04-R01, M05-R01, or M06-R02 criteria.

Overall orchestration completion requires:

1. Codex reads all three strict re-audits before implementation.
2. Codex reads all three remediation prompts before implementation.
3. Codex reads all three locked milestone criteria before implementation.
4. M04-R01 is executed first.
5. M04-R01 has its own `CODEX_LOG_V01.md`.
6. M04-R01 is committed as a distinct bounded commit.
7. M05-R01 is executed second against the remediated M04 state.
8. M05-R01 has its own `CODEX_LOG_V01.md`.
9. M05-R01 is committed as a distinct bounded commit.
10. M06-R02 is executed third against the remediated M04/M05 state.
11. M06-R02 has its own `CODEX_LOG_V01.md`.
12. M06-R02 is committed as a distinct bounded commit.
13. M04 evidence is not mixed into the M05 or M06 log as a substitute for their own evidence.
14. M05 production changes are not hidden in the M04 commit.
15. M06 production changes are not hidden in the M04/M05 commits.
16. Any pre-existing local M07 work is preserved non-destructively and not merged into remediation commits.
17. M07 is not resumed during or after this sequence.
18. M08+ is not started.
19. `TASKS.md` is untouched by Codex.
20. ChatGPT-owned re-audit/prompt/criteria/policy files are untouched by Codex.
21. No destructive reset, force push, automatic rebase, destructive checkout, or silent stash is used.
22. Final `main` local HEAD, `origin/main`, and remote main are synchronized.
23. Final `git diff --check` is clean.
24. Codex does not self-audit any of the three remediations.
25. Final response reports three separate log URLs/SHAs with `AWAITING_AUDIT`, then stops.

The master sequence does **not** receive overall `AUDITED_PASS` until the three detailed independent audits each return `AUDITED_PASS`.
