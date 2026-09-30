# BCM-M17-008 - V07-R03-R02-V03 Complete-Stdout Evidence-Handoff Retry

This is a new, bounded retry of the single-child V07-R03-R02 evidence handoff after `CHATGPT_AUDIT_V07_R03_R02.md` found Attempt 02 stopped at an incomplete M17 run-1 transcript. Attempts 01 and 02 remain immutable historical evidence.

## Required reading

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03_R02.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02_V03.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01_V03.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01_V03.md`

## Exact ordered package

This retry has exactly one ordered child:

1. `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01_V03.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01_V03.md` / `CODEX_LOG_V07_R03_R02_CHILD_01_V03.md` - complete regression stdout/stderr recapture and equality proof.

There is no later child. Any failed or incomplete command stops Child 01 and prevents the batch from being accepted.

## Synchronization and preservation rules

- Work only in `C:\Users\sekip\Desktop\Beach Cocktails - Merge` on `main`.
- Run and record the required status/remote/fetch/divergence preflight. Require a clean synchronized checkout before acting.
- Do not reset, clean, stash, rebase, force-push, overwrite owner work, or edit root `TASKS.md`.
- Preserve the V07-R03 runner/report, canonical Sunny Cove data, all prior V06/V07 evidence, and Attempts 01/02 byte-for-byte.
- Do not rerun the V07-R03 confirmation runner, repair its report, change canonical data, tune timers/objectives, or start M18.

## Evidence-only scope and capture protocol

1. Inspect the existing V07-R03 report and hashes read-only. The report must remain PASS and the locked runner/JSON/Markdown hashes must match.
2. Run the locked sequence exactly once in this order: report/hash inspection; V06 analytical; V05 optionality; M17 difficulty validation twice; M16; M15; M14; M02; then diff/freeze/equality proofs.
3. Capture each command through a deterministic wrapper that waits for process completion, captures complete stdout and stderr without truncation or ellipses, records the exact command line and exact process exit code, and emits the required PASS marker. Preserve the raw capture until the transcript is copied verbatim into both logs.
4. Do not treat a partial console stream or tool timeout as a successful command. If the wrapper cannot establish a complete transcript and exit code, stop the child immediately and do not rerun that command in this child.
5. Both M17 runs must contain `M17_DIFFICULTY_VALIDATION_RESULT=PASS` and exit `0`.
6. Record the actual 64-character SHA-256 for `data/campaign/levels/sunny_cove.json`: `9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495`.
7. Record exact execution-time and post-publication `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` values, all equal, plus clean status and `git diff --check`.

## Handoff

Write the immutable child and master logs as `CODEX_LOG_V07_R03_R02_CHILD_01_V03.md` and `CODEX_LOG_V07_R03_R02_V03.md`. After pushing, publish the terminal equality record. Both logs must end with:

`AWAITING_M17_AUDIT_V07_R03_R02`

Stop. Do not tune M17 canonical data and do not start M18.
