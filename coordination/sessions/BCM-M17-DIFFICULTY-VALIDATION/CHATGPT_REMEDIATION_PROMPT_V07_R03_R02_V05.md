# BCM-M17-008 - V07-R03-R02-V05 Log-Embedded Equality Correction

This is a bounded no-rerun correction after `CHATGPT_AUDIT_V07_R03_R02_V04.md` found that the V04 child and master logs omitted the required post-publication equality block. V04, V03, Attempts 01/02, V07-R03, and all earlier evidence remain immutable historical evidence.

## Required reading

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03_R02_V04.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02_V05.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01_V05.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01_V05.md`

## Exact ordered package

This retry has exactly one ordered child:

1. `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01_V05.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01_V05.md` / `CODEX_LOG_V07_R03_R02_CHILD_01_V05.md` - immutable evidence-log correction.

There is no later child. Any deviation stops Child 01 and prevents acceptance.

## Scope and preservation

- Work only in `C:\Users\sekip\Desktop\Beach Cocktails - Merge` on `main`.
- Run and record clean synchronized preflight before acting.
- Do not reset, clean, stash, rebase, force-push, overwrite owner work, or edit root `TASKS.md`.
- Do not rerun any V07-R03, V04, M17, M16, M15, M14, M02, or smoke command. Do not repair reports, alter canonical data, alter production code, tune timers/objectives, or start M18.
- Preserve the V04 child/master logs, terminal record, all V03/earlier attempts, V07-R03 runner/report, canonical data, and protected hashes byte-for-byte.

## Required two-publication correction

1. Read-only inspect V04 logs and the V04 terminal equality record.
2. Create the new V05 child and master logs by preserving the V04 evidence and adding an explicit equality section. Do not change any captured command, stdout, stderr, marker, exit code, protected hash, or scope claim.
3. Publish the new V05 child/master logs in a first evidence commit. Verify and record that first commit's exact local `HEAD`, `origin/main`, and remote-main equality.
4. Add that verified first-publication equality block to both V05 logs, commit and push the correction, and verify the second publication's exact equality.
5. Publish a terminal record under `docs/codex-logs/` containing the second publication's final equality, clean status, `git diff --check`, `TASKS.md` immutability, and the final marker.

The first-publication equality is deliberately embedded in both logs after that first commit, avoiding a self-referential commit hash. The terminal record must describe the final second log-publication commit.

## Handoff

The new child and master logs must end with `AWAITING_M17_AUDIT_V07_R03_R02`. Stop. No rerun, canonical tuning, or M18 work is authorized.
