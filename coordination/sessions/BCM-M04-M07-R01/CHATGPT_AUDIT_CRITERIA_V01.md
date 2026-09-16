# BCM-M04-M07-R01 — ChatGPT Orchestration Audit Criteria V01

This file audits the **execution discipline** of the combined remediation session. Each milestone still has its own locked audit criteria and receives its own independent verdict.

`ORCHESTRATION_PASS` requires:

1. Codex read all four re-audits, remediation prompts and locked criteria before implementation.
2. Work executed in order M04-R01 -> M05-R01 -> M06-R02 -> M07-R01.
3. M04 has its own bounded commit and `coordination/sessions/BCM-M04-R01/CODEX_LOG_V01.md`.
4. M05 has its own bounded commit and `coordination/sessions/BCM-M05-R01/CODEX_LOG_V01.md`.
5. M06 has its own bounded commit and `coordination/sessions/BCM-M06-R02/CODEX_LOG_V01.md`.
6. M07 has its own bounded commit and `coordination/sessions/BCM-M07-R01/CODEX_LOG_V01.md`.
7. M04 does not contain M05-M07 production changes.
8. M05 does not contain M06/M07 composition changes.
9. M06 does not contain M07 HUD remediation beyond evidence needed to evaluate M06.
10. M07 is performed on top of completed M04-M06 remediation state.
11. Existing M07 owner/Codex work is preserved, not destructively discarded.
12. No historical immutable Codex log is rewritten.
13. `TASKS.md` is untouched by Codex.
14. ChatGPT-owned re-audit/prompt/criteria/policy files are untouched by Codex.
15. No M08+ implementation leakage.
16. No guide line is introduced.
17. Canonical owner source PNGs are not destructively edited merely to satisfy validation.
18. Each phase records exact changed files, tests, evidence, commit/push facts and limitations.
19. Final M01-M07 regression sequence is run after final M07 remediation as required by the phase criteria.
20. `git diff --check` is clean.
21. Final local HEAD, origin/main and remote main match.
22. Codex never assigns itself `AUDITED_PASS`.
23. Completion response returns all four log URLs/commit SHAs as `AWAITING_AUDIT`.

Failure of orchestration discipline may require a new bounded remediation even if an individual milestone implementation looks correct.
