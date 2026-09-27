# BCM Canonical Desktop Reconciliation — Codex Execution Log V01

Status: `OWNER_DECISION_REQUIRED`

## Scope and authority

- Work item: BCM Canonical Desktop Reconciliation V01.
- Prompt: `coordination/sessions/BCM-CANONICAL-DESKTOP-RECONCILIATION/CHATGPT_EXECUTION_PROMPT_V01.md`.
- Locked criteria: `coordination/sessions/BCM-CANONICAL-DESKTOP-RECONCILIATION/CHATGPT_AUDIT_CRITERIA_V01.md`.
- Canonical Desktop repository: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- GitHub canonical branch: `main`.
- This run performed forensic inspection only. The canonical Desktop checkout was not changed, switched, cleaned, reset, stashed, rebased, or overwritten.

## Sync-first preflight

The required preflight ran from the canonical Desktop folder:

```text
git status --short --branch
## HEAD (no branch)
 D assets/ui_assets/v05_sources/effects_atlas.png
 D assets/ui_assets/v05_sources/ui_atlas.png
 M project.godot
?? Beach Cocktails - Merge.owner-backup-20260923-table-assets/
?? assets/ui_assets/ASSET_DIMENSIONS.{alpha,height,mode,width}.translation
?? assets/ui_assets/V05_ASSET_REGEN_STATUS.{alpha,category,dimensions,final,generation,path,source,status,validation,visual}.translation
?? beach cocktails merge logo.png

git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)

git fetch origin main
832dbe4..d692a2f  main -> origin/main

git rev-list --left-right --count HEAD...origin/main
0 92
```

Canonical start HEAD: `48072280694c7fcece9a4b63dc37c211585d2083`.
Canonical start branch state: detached HEAD. No commit was ahead of
`origin/main`; the blocker is the dirty working tree.

Canonical `TASKS.md` SHA-256: `248218B0197BEF84A6B4E4E9736FE8E34EC354612F2114E14F7A29165D39726E`.
This file was not modified.

## Exact dirty-item classification

| Item | Evidence | Classification | Safe for canonical sync? |
|---|---|---|---|
| `assets/ui_assets/v05_sources/effects_atlas.png` deleted | `HEAD` Git blob `5cc7805909e8d54fee717fd257729c3f4cb44a28`; `origin/main` has the exact same blob. No working-tree bytes remain. | `IDENTICAL_OR_ALREADY_PRESERVED_IN_MAIN` | Yes; a non-destructive fast-forward would restore the tracked file. |
| `assets/ui_assets/v05_sources/ui_atlas.png` deleted | `HEAD` Git blob `250c63c7866b53ec90f4970abaf6773177b6fc45`; `origin/main` has the exact same blob. No working-tree bytes remain. | `IDENTICAL_OR_ALREADY_PRESERVED_IN_MAIN` | Yes; a non-destructive fast-forward would restore the tracked file. |
| `project.godot` modified | Working SHA-256 `5AE398165F3AE5108ABC8296797507567DA3D8A7BB092980C7AAA95BD0A4632C`; `HEAD` Git blob `2caf030d55a28d04f19738ebca3a2852898b59a3`; `origin/main` Git blob `dcc5ae8a318aad08f6c97311b0c315acb2a26469`. The working file changes the header comments, changes `run/main_scene` from `res://scenes/campaign/CampaignNavigationScene.tscn` to `res://scenes/main.tscn`, and removes `window/stretch/aspect="keep"`. | `UNIQUE_OWNER_CONTENT` | No. Owner must decide whether to preserve or discard this configuration. |
| `Beach Cocktails - Merge.owner-backup-20260923-table-assets/` | 952 files, 538,595,062 bytes. It includes source, tests, governance/task files, UI assets, a 103,028,736-byte `assets/ui_assets/campaign.zip` with SHA-256 `91EC4938E199CB002793071394B775417B182FF6CD83D9871E8A489B27A58880`, and 33 same-path content differences from the canonical checkout. The zip path is absent from `origin/main`; the backup snapshot contains three files absent from the current canonical tree, including the two deleted source atlases. | `UNKNOWN_REQUIRES_OWNER` | No. Do not delete, move, or overwrite this snapshot. |
| Generated translation artifacts | Four exact `assets/ui_assets/ASSET_DIMENSIONS.*.translation` files and ten exact `assets/ui_assets/V05_ASSET_REGEN_STATUS.*.translation` files. All 14 are binary Godot `RSRC`/`OptimizedTranslation` resources, byte-identical to the same files in `Beach Cocktails - Merge-M13V02`, and absent from the `origin/main` tree. | `GENERATED_REPRODUCIBLE` | Not a blocker by itself; left untouched because other owner content blocks sync. |
| `beach cocktails merge logo.png` | Untracked root PNG, 88,215 bytes, SHA-256 `7071EDB222A83F5CF2C8D139230F2D1ADB1CBB1056E614FFF73A4756E892929D`. It is not byte-identical to tracked `assets/ui/logo_beach_cocktails_merge.png` (2,401,659 bytes, SHA-256 `E65D7EEDCC60AEDD7522D6415411E39B3ED2798EEDF06318D321BD43DE63B3C9`) or tracked brand logo candidates. | `UNIQUE_OWNER_CONTENT` | No. Owner must decide whether to preserve or discard this root asset. |

### Owner-backup forensic summary

The backup directory is a full project snapshot, not a disposable import cache.
Its top level contains `.gitignore`, `AGENTS.md`, `README.txt`, `TASKS.md`,
`project.godot`, `ui-assets-tasks.md`, `b75ee426-9568-4ed6-b35e-140600a7c995.png`,
and the project directories `assets`, `coordination`, `data`, `docs`,
`original_reference`, `scenes`, `scripts`, `tests`, and `tools`.

Hash/path comparison against the current canonical tree found:

- 916 files with the same relative path and identical SHA-256;
- 33 files with the same relative path but different SHA-256;
- 3 backup files with no same-path canonical file: `assets/ui_assets/campaign.zip`, `assets/ui_assets/v05_sources/effects_atlas.png`, and `assets/ui_assets/v05_sources/ui_atlas.png`;
- 951 of 952 backup relative paths exist in the current `origin/main` tree by path; `assets/ui_assets/campaign.zip` does not.

The 33 differing files include the backup `project.godot`, 30 island table/shadow/edge assets, and two visual-production logs. The existence of a unique archive and differing owner snapshot means the directory cannot be classified as safe to discard during this run.

## Safety decision

Gate B fails. `project.godot`, the root logo PNG, and the owner-backup
directory contain content not proven identical to current `origin/main`.
Accordingly:

- canonical Desktop `main` was not attached or fast-forwarded;
- the outside-Desktop publication worktree was not detached or deleted;
- no canonical file was restored, removed, moved, or overwritten;
- no dirty outside-Desktop worktree was touched.

The exact owner decisions required are:

1. Preserve or explicitly discard the current `project.godot` configuration change.
2. Preserve or explicitly discard `beach cocktails merge logo.png`.
3. Preserve, archive, or explicitly discard the 952-file owner-backup directory, including its unique `campaign.zip`.
4. After those decisions, authorize a new reconciliation run. Only then may the two deleted source atlases and generated translation artifacts be handled during a safe fast-forward.

## Worktree safety

`git worktree list --porcelain` was inspected. The clean outside-Desktop
publication worktree remains the `main` branch worktree at
`C:\Users\sekip\.codex\worktrees\bcm-main-targeted-production`, originally at
`832dbe495f1be5038c5beadbc5d846bec4540bdf` and fast-forwarded non-destructively
to `d692a2f` only to publish this log. The canonical Desktop worktree remains
detached at `48072280694c7fcece9a4b63dc37c211585d2083`.

The dirty visual-production worktree
`C:\Users\sekip\.codex\worktrees\bcm-visual-production` was not touched, in
accordance with the locked criteria.

No new Desktop folder, Git worktree, or branch was created. No branch was
merged, cherry-picked, deleted, reset, rebased, or force-pushed.

## Checks performed

- Required sync-first preflight: completed.
- `git fetch origin main`: completed.
- Full canonical status and untracked-file inventory: completed.
- Tracked diff against `HEAD` and `origin/main`: completed.
- SHA-256 hashes for binary/untracked files: completed.
- Recursive owner-backup inventory and hash comparison: completed.
- Generated translation comparison against M13V02: 14/14 exact byte matches.
- Runtime/Godot tests: not run; this was a forensic synchronization gate.
- `TASKS.md`: not modified.

## Handoff

- Result: `OWNER_DECISION_REQUIRED_BEFORE_CANONICAL_SYNC`.
- Canonical remains detached and dirty, `0 ahead / 92 behind` relative to `origin/main` at preflight.
- No owner file was lost.
- No canonical fast-forward was performed.
- Log publication base: `d692a2f` before this log commit.
- Independent audit should verify this evidence and wait for owner decisions before any cleanup or synchronization.

