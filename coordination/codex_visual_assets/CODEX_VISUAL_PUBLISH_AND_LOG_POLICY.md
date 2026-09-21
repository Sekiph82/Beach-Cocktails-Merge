# BEACH COCKTAILS MERGE — CODEX VISUAL PUBLISH & LOG POLICY

Status: MANDATORY  
Branch: `codex/visual-assets-production`

This policy applies to all current and future Codex visual-asset work.

## 1. Canonical repository

Repository:
`Sekiph82/Beach-Cocktails-Merge`

Dedicated visual branch:
`codex/visual-assets-production`

Codex MUST NOT modify, merge, rebase, reset, force-update, or push to `main`.

## 2. Local worktree is NOT the final destination

Codex may work from an isolated local visual worktree.

Local files are temporary working state.

A task is NOT complete merely because:
- the PNG exists locally;
- the log exists locally;
- a local commit exists.

A visual task is complete only after the correct files are present on:
`origin/codex/visual-assets-production`

## 3. Canonical image destinations

Every generated/derived visual MUST be copied or moved into the exact canonical target path defined by:
`coordination/codex_visual_assets/CODEX_VISUAL_ASSET_MASTER_LIST.md`

Final production targets live under:
`assets/ui_assets/**`

Raw/working selected outputs may additionally be stored under:
`assets/ui/generated/codex_visual_assets/**`

Never leave a required project asset only in generated-images, Desktop, temp, Downloads, or arbitrary output folders.

## 4. Canonical log destinations

Official GitHub logs:
- `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_LOG.md`
- `coordination/codex_visual_assets/CODEX_VISUAL_PRODUCTION_MASTER_LOG.md`

Before declaring completion:
1. merge/append missing factual local log entries into repository logs;
2. append concise batch summary to master log;
3. commit those repository log updates;
4. push them to the dedicated visual branch.

Never present a local Windows path as authoritative completion evidence.

## 5. Mandatory publish sequence

At the end of EVERY meaningful visual batch:

1. Confirm current branch/worktree:
   `git status --short`
   `git branch --show-current`

2. Fetch:
   `git fetch origin codex/visual-assets-production`

3. Safely fast-forward only the dedicated visual branch when possible. Never touch main.

4. Verify completed outputs exist at exact canonical paths.

5. Update official Codex visual log.

6. Append a summary to:
   `coordination/codex_visual_assets/CODEX_VISUAL_PRODUCTION_MASTER_LOG.md`

7. Stage ONLY exact authorized visual files and Codex visual coordination files.

8. Never use:
   `git add .`
   `git add -A`

9. Commit with visual-only message.

10. Push ONLY:
    `git push origin codex/visual-assets-production`

11. Verify remote publication:
    `git fetch origin codex/visual-assets-production`
    `git log origin/codex/visual-assets-production --oneline -n 12`

12. Verify required paths remotely:
    `git ls-tree -r --name-only origin/codex/visual-assets-production -- assets/ui_assets coordination/codex_visual_assets`

13. Only after verification may the batch be reported complete.

## 6. Push rejection handling

If push is rejected because the visual branch moved:
- do NOT push to main;
- do NOT force-push;
- do NOT reset;
- preserve all remote visual commits;
- fetch and safely integrate only visual-branch history.

If a conflict involves a forbidden non-visual project file, preserve the remote version and introduce no Codex change there.

## 7. Forbidden writes

Do not modify:
- root `TASKS.md`;
- ChatGPT prompts/audits/sessions outside this folder;
- gameplay code;
- Godot scenes/scripts;
- tests;
- manifests;
- configs;
- workflows;
- project settings;
- docs;
- `main`.

## 8. Required final report

Every Codex visual completion response must include:
- remote branch name;
- remote branch HEAD SHA;
- commit SHA(s);
- canonical targets present / expected;
- exact missing targets, if any;
- official GitHub log confirmation;
- confirmation that `main` was untouched.

Never present a local filesystem path as authoritative completion evidence.
