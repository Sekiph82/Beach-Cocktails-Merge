# BCM-M12 World Map — Final Closure Independent Audit V01

Status: **PENDING_CODEX_EXECUTION**

Locked criteria:
`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_FINAL_CLOSURE_V01.md`

Execution prompt:
`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_EXECUTION_PROMPT_FINAL_CLOSURE_V01.md`

## Governance

This file is owned by ChatGPT independent audit.

Codex must not write the verdict and must not edit `TASKS.md`.

After Codex returns `AWAITING_M12_FINAL_AUDIT`, ChatGPT will:
1. audit the actual `main` diff, source, tests and evidence against the locked criteria;
2. replace this pending state with the final independent verdict;
3. update root `TASKS.md` itself after the audit;
4. if PASS, close M12 and advance the canonical next action to M13;
5. if CHANGES_REQUIRED, record the blocker in `TASKS.md` and create the next locked remediation prompt/criteria before further Codex execution.
