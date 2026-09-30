# BCM-M17-008 - V07-R03-R01 Evidence-Handoff Remediation Master Prompt

This package remediates only the incomplete V07-R03 handoff identified in `CHATGPT_AUDIT_V07_R03.md`. The R03 runner and report already passed their direct integrity gates and must remain immutable evidence.

## Required reading

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03_R01_CHILD_01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R01_CHILD_01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R03_R01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R03_R01_CHILD_01.md`

## Exact ordered package

This remediation has exactly one ordered child:

1. `CHATGPT_REMEDIATION_PROMPT_V07_R03_R01_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R01_CHILD_01.md` / `CODEX_LOG_V07_R03_R01_CHILD_01.md` — regression-evidence recapture and exact final synchronization proof.

There is no later child. A missing marker, non-zero exit, or incomplete synchronization proof blocks the batch.

## Synchronization and preservation rules

- Work only in `C:\Users\sekip\Desktop\Beach Cocktails - Merge` on `main`.
- Run the repository status/remote/fetch/divergence preflight and require a clean synchronized checkout before acting.
- Do not reset, clean, stash, rebase, force-push, overwrite owner work, or edit root `TASKS.md`.
- Preserve the R03 runner, R03 JSON/Markdown, V07-R02/V07-R01 evidence, V06-R02/V05 evidence, and canonical Sunny Cove data byte-for-byte.
- Do not rerun the R03 confirmation runner, repair its report, or change any production/canonical data.

## Evidence-only scope

The existing R03 direct run is accepted as the prerequisite PASS for this evidence recapture. Run the locked regression sequence from the R03 criteria, including the two `tests/m17_difficulty_validation_probe.gd` invocations, using a capture method that preserves the complete stdout tail and process exit code. Record the exact command, exit code, and required PASS marker for every regression. The sequence is:

1. R03 report/hash/integrity inspection without rewriting the report;
2. `tests/m17_canonical_screening_v06_analytical_probe.gd`;
3. `tests/m17_vip_optionality_probe.gd`;
4. `tests/m17_difficulty_validation_probe.gd` run 1;
5. the same M17 difficulty validation probe run 2;
6. `tests/m16_sunny_cove_content_probe.gd`;
7. `tests/m15_vip_boosters_economy_probe.gd`;
8. `tests/m14_gameplay_session_bridge_probe.gd`;
9. `tests/m02_physics_regression.gd`;
10. `git diff --check`, TASKS freeze proof, protected-file hash proof, and final local/origin/remote equality.

If any command fails or any required marker is absent, stop immediately, record the truthful failure, and do not rerun a failed evidence command in the same child.

## Handoff

Populate the child and master logs with exact commands, stdout markers, exit codes, protected hashes, unchanged R03 runner/report hashes, final `git rev-parse HEAD`, `git rev-parse origin/main`, `git ls-remote origin refs/heads/main`, clean-tree proof, limitations, and the final marker:

`AWAITING_M17_AUDIT_V07_R03_R01`

Stop. Do not tune M17 canonical data and do not start M18.
