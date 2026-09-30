# BCM-M17-R03-R02-V05 Child 01 - Immutable Evidence-Log Correction

## Scope

Close only the V04 log-embedded equality omission. This child is documentation-only and must not rerun commands.

## Required work

1. Complete and record clean synchronized preflight.
2. Read-only inspect the V04 child/master logs, V04 terminal record, protected hashes, and preserved V07-R03 PASS evidence.
3. Create `CODEX_LOG_V07_R03_R02_CHILD_01_V05.md` and complete the supplied master template `CODEX_LOG_V07_R03_R02_V05.md` by preserving the V04 evidence content. Do not alter captured output, commands, markers, exits, hashes, or prior-attempt claims.
4. Publish the two V05 logs in a first commit. Verify its local/origin/remote equality, clean status, and `git diff --check`.
5. Add that exact first-publication equality block to both V05 logs, commit and push, then verify the second/final equality.
6. Publish a terminal record in `docs/codex-logs/` for the second publication. It must repeat final equality, clean status, `git diff --check`, and `TASKS.md` immutability.

## Forbidden work

Do not invoke any smoke, V07-R03, V04, M17, M16, M15, M14, or M02 command. Do not edit `TASKS.md`, production code, canonical data, reports, historical logs, timer/objective data, or M18 files. Do not reset, clean, stash, rebase, force-push, overwrite owner work, or create a later child.

## Handoff

Both V05 logs must end with `AWAITING_M17_AUDIT_V07_R03_R02`. Stop there.
