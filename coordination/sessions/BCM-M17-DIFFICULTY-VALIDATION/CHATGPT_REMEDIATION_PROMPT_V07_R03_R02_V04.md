# BCM-M17-008 - V07-R03-R02-V04 Capture-Compatible Evidence Retry

This is a new bounded retry after `CHATGPT_AUDIT_V07_R03_R02_V03.md` found that the V03 capture wrapper failed during setup before the first regression. V03 and all earlier attempts remain immutable historical evidence.

## Required reading

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03_R02_V03.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02_V04.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01_V04.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01_V04.md`

## Exact ordered package

This retry has exactly one ordered child:

1. `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01_V04.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01_V04.md` / `CODEX_LOG_V07_R03_R02_CHILD_01_V04.md` - capture-compatible regression evidence and equality proof.

There is no later child. Any failed or incomplete command stops Child 01 and prevents the batch from being accepted.

## Synchronization and preservation rules

- Work only in `C:\Users\sekip\Desktop\Beach Cocktails - Merge` on `main`.
- Run and record the required status/remote/fetch/divergence preflight. Require a clean synchronized checkout before acting.
- Do not reset, clean, stash, rebase, force-push, overwrite owner work, or edit root `TASKS.md`.
- Preserve the V07-R03 runner/report, canonical Sunny Cove data, all prior V06/V07 evidence, and Attempts 01/02/V03 byte-for-byte.
- Do not rerun the V07-R03 confirmation runner, repair its report, change canonical data, tune timers/objectives, or start M18.

## Capture-compatible evidence protocol

1. Inspect the existing V07-R03 report and hashes read-only. The report must remain PASS and the locked hashes must match.
2. Before consuming the locked regression sequence, run one bounded capture-wrapper compatibility smoke check that launches a harmless local command, waits for completion, captures stdout and stderr completely, and records its native exit code. This is a wrapper check, not a project regression, and it must pass without changing repository files.
3. Run the locked sequence exactly once and in order: V06 analytical; V05 optionality; M17 difficulty validation twice; M16; M15; M14; M02; then diff/freeze/equality proofs.
4. Use a runtime-compatible capture implementation. Do not use the unavailable `ProcessStartInfo.ArgumentList` API. The implementation must wait for process completion, preserve complete stdout and stderr without truncation or ellipses, record the exact command and native exit code, and emit the required PASS marker.
5. If the compatibility smoke check fails, stop before the locked sequence and record the failure. If any locked command cannot produce a complete transcript and exact exit code, stop immediately and do not rerun that command in this child.
6. Both M17 runs must contain `M17_DIFFICULTY_VALIDATION_RESULT=PASS` and exit `0`.
7. Record the actual SHA-256 for `data/campaign/levels/sunny_cove.json`: `9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495`.
8. Record exact execution-time and final post-publication `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` values, all equal, plus clean status and `git diff --check`.

## Handoff

Write the immutable child and master logs as `CODEX_LOG_V07_R03_R02_CHILD_01_V04.md` and `CODEX_LOG_V07_R03_R02_V04.md`. After pushing, publish the terminal equality record. Both logs must end with:

`AWAITING_M17_AUDIT_V07_R03_R02`

Stop. Do not tune M17 canonical data and do not start M18.
