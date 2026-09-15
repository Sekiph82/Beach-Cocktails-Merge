# BCM-M00 — Milestone Completion V01

## Purpose

Complete all remaining work required to make **M00 — Repository synchronization, governance, and trustworthy baseline** ready for independent closure audit.

BCM-M00-001 is already independently accepted and must **not** be reimplemented or rewritten. Treat its synchronized baseline and evidence as immutable accepted history. The only active implementation task is BCM-M00-002, but this consolidated prompt requires Codex to verify that M00-001 remains intact while completing every still-open M00 acceptance item.

## Canonical repository and workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: `4.7.x`

## Mandatory governance

Before making changes, read and obey:

- `AGENTS.md`
- `TASKS.md`
- `docs/audits/BCM-M00-001_REPOSITORY_SYNC_AND_BASELINE_V02_AUDIT.md`
- `docs/prompts/BCM-M00-002_REPOSITORY_HYGIENE_AND_GODOT_BASELINE_V01_PROMPT.md`
- this prompt

Codex must never edit `TASKS.md`.
Codex must not self-approve M00, close the milestone, or start M01/V7 visual integration.

## Scope

Execute all **remaining incomplete M00 work** in one Codex session.

### Preserve accepted BCM-M00-001

Do not redo BCM-M00-001. Verify only that its accepted repository baseline remains present and unbroken:

- canonical local workspace is the expected repository root;
- branch is `main`;
- remote points to the canonical GitHub repository;
- owner gameplay baseline and V7 assets remain present;
- accepted governance files remain present;
- no destructive reconciliation is performed;
- no accepted owner work is discarded.

If any contradiction with the accepted M00-001 state is discovered, stop and document it as a blocker instead of silently changing history.

### Complete BCM-M00-002 and every remaining M00 acceptance item

1. Run the full sync-first preflight required by `AGENTS.md` and record exact outputs.
2. Safely reconcile any new owner local work with GitHub `main`, preserving all owner work.
3. Confirm canonical production structure:
   - `project.godot`
   - `scenes/`
   - `scripts/`
   - `data/`
   - `assets/`
4. Confirm repository hygiene:
   - `.godot/` ignored and untracked;
   - editor/cache/import artifacts excluded per repository policy;
   - `.uid`, temporary files, build/export outputs, local logs, saves, machine-specific artifacts excluded as appropriate;
   - no secrets or credentials committed.
5. Inspect for duplicate/conflicting/stale production resources. Preserve owner reference material unless clearly safe to remove. Do not destructively clean reference art merely because it is not production content.
6. Verify all canonical approved visual assets exist at intended paths, including L01-L12 cocktails, environment, UI, and effects assets.
7. Inspect `project.godot`, production scenes, scripts, resources, and paths for obvious broken references.
8. Locate the installed Godot 4.7.x executable non-destructively.
9. Run deterministic Godot validation where technically possible, including:
   - Godot version;
   - project import/parse validation;
   - configured main-scene load/headless startup validation;
   - exact parser/import/resource errors and exit codes.
10. Fix only M00 baseline/hygiene/import problems. Do not retune gameplay, physics, scoring, To-Go logic, layout, art composition, or V7 presentation.
11. Update README/documentation only if needed for accurate Godot 4.7.x open/run instructions and synchronized baseline identification.
12. Run final repository hygiene checks and verify no required production source remains only untracked locally.
13. Preserve the accepted v6.7 gameplay baseline unless a strictly necessary parse/import compatibility repair is required.

## Evidence-first logging

The owner must not be asked to copy terminal output from Codex to ChatGPT.

Create one immutable consolidated Codex log:

`docs/codex-logs/BCM-M00_MILESTONE_COMPLETION_V01_CODEX_LOG.md`

The log must contain exact outputs, not summary-only claims, for all material evidence available before the log commit, including:

- repository root;
- branch/remotes;
- initial status;
- fetch result;
- local HEAD and `origin/main` before implementation;
- divergence;
- reconciliation details if any;
- tracked/untracked/ignored hygiene checks;
- relevant file inventories;
- canonical asset inventory;
- duplicate/stale-resource inspection results;
- Godot executable path;
- Godot version output;
- Godot parse/import/main-scene validation commands;
- exact stdout/stderr and exit codes for Godot validation;
- fixes made;
- files changed;
- final pre-commit `git diff --check` result;
- final pre-commit status;
- known limitations/unverified items;
- explicit statement that `TASKS.md` was not modified;
- explicit statement that BCM-M01-001 and V7 integration were not started.

For any post-push equality check whose final SHA cannot be written self-referentially into the same commit, do not ask the owner to relay it. Perform the check, keep the completion response minimal, and allow ChatGPT to independently verify GitHub `main` during audit.

## Completion procedure

1. Inspect the full diff and scope.
2. Ensure only legitimate M00 baseline/hygiene/import changes plus the Codex log are included.
3. Commit all intended changes.
4. Push to `origin/main`.
5. Fetch `origin/main` again.
6. Confirm no implementation work remains uncommitted.
7. Do not edit `TASKS.md`.
8. Do not start BCM-M01-001.
9. Do not start any V7 visual integration.
10. Stop for independent ChatGPT audit.

## Completion response

Return only:

- consolidated M00 Codex log GitHub URL;
- pushed commit SHA;
- one-line Godot validation result or exact blocker;
- confirmation that `TASKS.md` was not edited;
- confirmation that M01/V7 work was not started.

All detailed evidence must already be committed inside the consolidated M00 log.