# BCM-M00-002 — Repository Hygiene and Godot Import Baseline V01

## Scope

Execute **BCM-M00-002 only** for Beach Cocktails Merge.

This work item establishes a clean canonical Godot 4.7.x repository/import baseline before gameplay-contract verification or V7 visual integration.

Do not start BCM-M01-001 or any V7 visual integration work.

## Canonical repository and workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: `4.7.x`

## Mandatory governance

Read and obey before making changes:

- `AGENTS.md`
- `TASKS.md`
- `docs/audits/BCM-M00-001_REPOSITORY_SYNC_AND_BASELINE_V02_AUDIT.md`
- this prompt

Codex must never edit `TASKS.md`.

Codex must not self-approve the task or assign the authoritative audit verdict.

## Sync-first preflight

From the canonical local root, run and record exact outputs in the Codex log:

```powershell
git status --short --branch
git remote -v
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
git rev-list --left-right --count HEAD...origin/main
```

If local owner work exists, preserve it. Never use `reset --hard`, force-push, destructive checkout, automatic rebase, or silent stash.

If synchronization cannot be reconciled safely, stop and log the blocker.

## Required work

1. Confirm the canonical project structure exists and is the production source:
   - `project.godot`
   - `scenes/`
   - `scripts/`
   - `data/`
   - `assets/`

2. Confirm repository hygiene:
   - `.godot/` is ignored/untracked;
   - editor caches are ignored/untracked;
   - PNG `.import` sidecars are not tracked unless Godot 4.7.x specifically requires a tracked source artifact;
   - local script `.uid` sidecars remain excluded according to current repository policy;
   - export/build output, local logs, temp files, save files, and machine-specific files are excluded;
   - no secrets or credentials are present.

3. Inspect for duplicate/conflicting/stale production assets or prototype copies that could accidentally be referenced by the production scene. Do not delete owner reference material unless clearly safe and required. Prefer documenting non-production references over destructive cleanup.

4. Validate all approved canonical visual assets are versioned at the intended paths, including:
   - `assets/cocktails/L01.png` through `L12.png`
   - `assets/environment/game_board_background.png`
   - canonical UI assets
   - canonical effects assets

5. Validate `project.godot` and production scene/resource paths for obvious broken references.

6. Run Godot 4.7.x validation from the local machine. Prefer deterministic command-line/headless checks where supported. At minimum attempt:
   - project import/parse validation;
   - loading the configured main scene;
   - reporting all parser/import/resource errors exactly.

   If the installed Godot executable must be located, discover it non-destructively. Do not install unrelated software.

7. If parse/import/resource errors exist, fix only issues within BCM-M00-002 scope. Do not retune gameplay, physics, scoring, To-Go logic, layout, or V7 visual composition.

8. Update README/documentation only as needed to identify the synchronized baseline and reliable Godot 4.7.x open/run instructions.

9. Keep the accepted v6.7 gameplay baseline untouched except for a strictly necessary parse/import compatibility repair.

## Evidence-first logging rule

The owner must not be asked to manually copy terminal outputs between Codex and ChatGPT.

Create one immutable Codex execution log:

`docs/codex-logs/BCM-M00-002_REPOSITORY_HYGIENE_AND_GODOT_BASELINE_V01_CODEX_LOG.md`

The log must contain the **exact command outputs**, not summaries only, for all material checks that can be recorded before the log commit, including:

- sync-first Git outputs;
- relevant `git status` and divergence outputs;
- ignore/tracked-file checks;
- canonical asset/file inventory results;
- Godot version output;
- Godot headless/import/parse/main-scene command output;
- any errors/warnings and their exit codes;
- tests/checks performed;
- files changed;
- known limitations;
- explicit confirmation that `TASKS.md` was not modified;
- explicit confirmation that BCM-M01-001 / V7 integration was not started.

Do not rely on the owner to relay evidence later.

Because a Git commit cannot contain its own final SHA, do not create a self-referential requirement. Commit the implementation and log, push them, and stop. ChatGPT will independently verify the final GitHub `main` commit/state through GitHub during audit.

## Completion procedure

Before completion:

1. inspect `git diff` and `git status`;
2. ensure only intended BCM-M00-002 changes are included;
3. commit implementation/documentation/log changes;
4. push to `origin/main`;
5. fetch `origin/main` once more and confirm no local implementation work remains uncommitted;
6. do not edit `TASKS.md`;
7. stop for independent ChatGPT audit.

## Completion response

Return only:

- Codex log GitHub URL;
- pushed commit SHA;
- short statement that the Godot validation command completed or the exact blocker;
- short statement that `TASKS.md` was not edited;
- short statement that BCM-M01-001 / V7 integration was not started.

All detailed command/test evidence must already be inside the committed Codex log.
