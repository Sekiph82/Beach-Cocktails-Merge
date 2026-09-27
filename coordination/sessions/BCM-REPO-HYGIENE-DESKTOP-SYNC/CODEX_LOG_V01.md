# BCM Repository Hygiene / Desktop Sync — Codex Execution Log V01

Status: `AWAITING_REPO_HYGIENE_AUDIT_V01`

## Scope and authority

- Work item: BCM Repository Hygiene / Desktop Sync V01.
- Prompt: `coordination/sessions/BCM-REPO-HYGIENE-DESKTOP-SYNC/CHATGPT_EXECUTION_PROMPT_V01.md`.
- Locked criteria: `coordination/sessions/BCM-REPO-HYGIENE-DESKTOP-SYNC/CHATGPT_AUDIT_CRITERIA_V01.md`.
- Canonical repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`.
- Canonical Desktop folder: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Scope was repository inventory and governance documentation only. No runtime or product code was changed.

## Sync-first preflight

The required preflight ran from the canonical Desktop folder before any mutation:

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
From https://github.com/Sekiph82/Beach-Cocktails-Merge
   b01a063..a306548  main -> origin/main

git rev-list --left-right --count HEAD...origin/main
0 86
```

Start canonical HEAD: `48072280694c7fcece9a4b63dc37c211585d2083`.
The canonical checkout is detached, dirty, and behind-only. It has no commit
reachable from `HEAD` that is absent from `origin/main`, but it has owner/local
file changes and therefore was not synchronized, checked out, reset, stashed,
cleaned, rebased, or overwritten.

Canonical `TASKS.md` SHA-256 at preflight:
`248218B0197BEF84A6B4E4E9736FE8E34EC354612F2114E14F7A29165D39726E`.

## Desktop folder inventory

| Folder | Identity and state | Evidence | Verdict |
|---|---|---|---|
| `C:\Users\sekip\Desktop\Beach Cocktails - Merge` | Canonical linked worktree; `.git` is a directory; detached at `4807228`; `0 ahead / 86 behind`; 19 status lines including owner/local changes listed above. | Remote is `origin` at the canonical GitHub URL. No local-only commit was found. | `DO_NOT_SYNC_AUTOMATICALLY`; owner reconciliation required. |
| `C:\Users\sekip\Desktop\Beach Cocktails - Merge-M13` | Registered linked worktree; `.git` is a gitfile pointing to `.git/worktrees/Beach-Cocktails---Merge-M13`; branch `codex/m13-island-map`; HEAD `14a696dc41628b88d79e6c41a8bb67bea5716552`; clean; `0 ahead / 27 behind`. | HEAD is an ancestor of `origin/main`; tip subject is `docs: record M13 island map builder evidence` dated `2026-09-26T00:19:37+03:00`. No status-visible untracked or modified file. | `SAFE_TO_DELETE_BY_OWNER` after independent audit, because no unique commit or visible user file is present. Not deleted here. |
| `C:\Users\sekip\Desktop\Beach Cocktails - Merge-M13V02` | Registered linked worktree; `.git` is a gitfile pointing to `.git/worktrees/Beach-Cocktails---Merge-M13V02`; branch `codex/m13-v02-navigation`; HEAD `318829c1623e4cbeea2c08171ebbbbe6f954117f`; `0 ahead / 21 behind`. | HEAD is an ancestor of `origin/main`; tip subject is `docs: record M13 V02 remediation evidence` dated `2026-09-27T00:08:46+03:00`. The 14 visible generated `*.translation` files are byte-identical to the same canonical files by SHA-256. No unique visible user file was found. | `SAFE_TO_DELETE_BY_OWNER` after independent audit, because no unique commit or visible user file is present. Not deleted here. |

The ignored `.godot` directories were left untouched as generated editor/import
state. Neither unexpected folder was modified, moved, cleaned, or deleted.

### M13/M13V02 investigation

Both M13 branch tips are fully represented in current `origin/main`; neither
has a commit or tracked file that needs to be moved into `main`. M13V02’s
status-visible generated files are the same files already present in the
canonical folder, with matching SHA-256 values. The M13V02 implementation and
evidence are therefore preserved by `main` and do not depend on either Desktop
folder remaining present.

## Git worktree inventory

Inventory command: `git worktree list --porcelain`. Existing Desktop paths
were inspected only; no new Desktop worktree was created.

| Path | HEAD | Branch | State / disposition |
|---|---|---|---|
| `C:\Users\sekip\Desktop\Beach Cocktails - Merge` | `48072280694c7fcece9a4b63dc37c211585d2083` | detached | dirty; preserve owner work |
| `C:\Users\sekip\.codex\worktrees\bcm-m10-campaign-architecture\Beach Cocktails - Merge` | `8aba901000d8c4a8de77b76f90933f8e1b55524b` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-m10-v02-remediation\Beach Cocktails - Merge` | `b9bc7163ad3f96fea3ab4a3e21c40df21784c868` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-m11-save-migration\Beach Cocktails - Merge` | `3927ffd3f92f30b0fbd7516cc8d67645a227390c` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-m12-v02-world-map\Beach Cocktails - Merge` | `7c139915c039fea37a458c99513c89496f2a326e` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-m12-v03-visual-regeneration\Beach Cocktails - Merge` | `5d503bfe6eaea2c293f721a88e0743093ec79d16` | `codex/m12-v03-visual-blocker` | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-m12-v04-staged-masters\Beach Cocktails - Merge` | `f2d6da2f849015f8a0869d93282ce65e738be82e` | `codex/m12-v04-publish` | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-m12-v06-work` | `f6d60c246ebffa8b31c6340d7065572a31fc2a49` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-m12-world-map\Beach Cocktails - Merge` | `5aff64900d41649c282e64de009118853ca2f059` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-m14-gameplay-session-bridge\Beach Cocktails - Merge` | `dc6cf46fcd966429d8cfa9862fff65426ab44c29` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-main-merge` | `00f1278cffcec5ec8d8239d89386881270dd56ea` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-main-targeted-production` | `5a54b7b8dc106a2eebd1af7029cc692043f7655a` | `main` | clean after fast-forward and governance commit; publication worktree |
| `C:\Users\sekip\.codex\worktrees\bcm-owner-audit-remediation\Beach Cocktails - Merge` | `1dc4020708293cecb75fabecc5200a7fa1ba9137` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-remaining-table-assets` | `48072280694c7fcece9a4b63dc37c211585d2083` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\.codex\worktrees\bcm-visual-production` | `a07fc88524dfca6f1d8881dd1af18148c5529469` | `codex/visual-assets-production` | dirty: eight modified badge assets; preserve and obtain owner decision before cleanup |
| `C:\Users\sekip\.codex\worktrees\beach-visual-production\Beach Cocktails - Merge` | `0fada6337edb0197d9cef35fcb8b2ed78ce306c5` | detached | clean; existing outside-Desktop worktree, untouched |
| `C:\Users\sekip\Desktop\Beach Cocktails - Merge M12V02` | `45963ef0f10f5722ba96e09bef323bf151ea8dd2` | detached | missing; prunable gitdir pointer, not deleted here |
| `C:\Users\sekip\Desktop\Beach Cocktails - Merge MAIN` | `a875beaabc8b385bca3fc354a7c139650592de7d` | detached | missing; prunable gitdir pointer, not deleted here |
| `C:\Users\sekip\Desktop\Beach Cocktails - Merge-M13` | `14a696dc41628b88d79e6c41a8bb67bea5716552` | `codex/m13-island-map` | clean; owner deletion verdict above |
| `C:\Users\sekip\Desktop\Beach Cocktails - Merge-M13V02` | `318829c1623e4cbeea2c08171ebbbbe6f954117f` | `codex/m13-v02-navigation` | generated translation files only; owner deletion verdict above |

The two missing `M12V02`/`MAIN` paths were observed as already absent and
prunable. Their Git worktree metadata was not pruned in this task.

## GitHub branch inventory and main completeness

After `git fetch --all --prune`, `git ls-remote --heads origin` returned only:

```text
a306548f5921b1b78cc582ad4894f9d4c2158b9c refs/heads/main
```

Therefore there are no remote GitHub branches other than `main` to classify or
delete. No GitHub branch was merged, cherry-picked, deleted, or force-pushed.

The following local historical branch refs remain. Each is an ancestor of
`origin/main` and has zero unique commits/files relative to it. Dates and
purposes are supported by the tip commit timestamp and subject; they are not
claimed as remote branch creation timestamps.

| Local branch | Tip | Ahead/behind vs origin/main | Evidence-based purpose | Classification |
|---|---|---:|---|---|
| `codex/m12-v03-visual-blocker` | `5d503bfe6eaea2c293f721a88e0743093ec79d16` | `0 / 188` | M12 V03 visual regeneration blocker log, `2026-09-21` | `FULLY_MERGED_SAFE_TO_DELETE` as a branch ref; no remote ref remains |
| `codex/m12-v04-publish` | `f2d6da2f849015f8a0869d93282ce65e738be82e` | `0 / 179` | M12 V05 regeneration evidence, `2026-09-21` | `FULLY_MERGED_SAFE_TO_DELETE` as a branch ref; no remote ref remains |
| `codex/m13-island-map` | `14a696dc41628b88d79e6c41a8bb67bea5716552` | `0 / 27` | M13 Island Map builder evidence, `2026-09-26` | `FULLY_MERGED_SAFE_TO_DELETE` as a branch ref after owner review |
| `codex/m13-v02-navigation` | `318829c1623e4cbeea2c08171ebbbbe6f954117f` | `0 / 21` | M13 V02 navigation remediation evidence, `2026-09-27` | `FULLY_MERGED_SAFE_TO_DELETE` as a branch ref after owner review |
| `codex/visual-assets-production` | `a07fc88524dfca6f1d8881dd1af18148c5529469` | `0 / 105` | visual publication evidence, `2026-09-22` | branch tip merged, but its linked worktree has eight modified files; preserve pending owner decision |
| `ui-assets` | `97dd1fdc452c6f7fffcb8466eec2ad5d67e268e6` | `0 / 214` | final UI asset remediation handoff V02, `2026-09-20` | `FULLY_MERGED_SAFE_TO_DELETE` as a branch ref; tracked remote ref is gone |

No branch contains unique work that needs merging into `main`. The only
remaining local work requiring preservation is the dirty visual-production
worktree noted above, not a unique commit.

## Governance patch

The existing clean outside-Desktop `main` worktree was fast-forwarded from
`1194bcbce611fc974393014000c586f5f481afce` to `a306548f5921b1b78cc582ad4894f9d4c2158b9c`.
The authorized governance-only patch changed:

- `AGENTS.md`: added the canonical Desktop path, no-Desktop-clone/worktree
  rule, outside-Desktop temporary worktree location, branch/worktree
  inspection requirement, explicit owner approval for branch creation and
  merge/delete, and dirty/detached canonical preservation rule.

Governance commit: `5a54b7b8dc106a2eebd1af7029cc692043f7655a` (`docs: codify canonical Desktop repository hygiene`).
No runtime/product files were changed. `TASKS.md` was not edited by Codex.

## Commands and checks

- Required sync-first preflight: completed.
- `git fetch --all --prune`: completed.
- `git worktree list --porcelain`: completed; all linked paths recorded above.
- `git branch -vv` and `git branch -r -vv`: completed.
- `git ls-remote --heads origin`: only `main` returned.
- `git diff --check`: passed for the governance patch.
- Folder/branch/worktree deletion: not performed.
- Branch merge/cherry-pick: not performed.
- Destructive sync (`reset`, clean, stash, overwrite checkout, rebase): not performed.
- Godot/runtime tests: not applicable; no runtime/product code changed.
- Manual owner/native acceptance: not performed and remains the independent audit’s responsibility.

## Owner decisions required

1. Confirm whether to delete the physical `Beach Cocktails - Merge-M13` folder: evidence supports `SAFE_TO_DELETE_BY_OWNER`.
2. Confirm whether to delete the physical `Beach Cocktails - Merge-M13V02` folder: evidence supports `SAFE_TO_DELETE_BY_OWNER`; its visible generated files are duplicated in canonical.
3. Decide how to reconcile the canonical Desktop checkout’s dirty owner changes and 86-commit behind-only state. Safe options are owner backup/commit/move followed by a reviewed fast-forward, or continued preservation while the owner resolves the files. Codex did not choose or execute either option.
4. Decide when to preserve/archive the dirty outside-Desktop visual-production worktree before any local branch cleanup.
5. Approve any future local branch/worktree cleanup separately. No remote branch operation is currently required because no non-main remote branch exists.

## Final handoff state

- Governance patch commit: `5a54b7b8dc106a2eebd1af7029cc692043f7655a`.
- Final main SHA at governance commit boundary: `5a54b7b8dc106a2eebd1af7029cc692043f7655a`.
- Canonical Desktop repo: not current with `main`; exact blocker is its detached state plus the 19 visible owner/local changes, despite being ancestor-only and 86 commits behind.
- `TASKS.md`: explicitly not modified; canonical preflight SHA-256 recorded above.
- No Desktop folder, Git worktree, or GitHub branch was deleted.
- No branch was merged or cherry-picked.
- Independent audit required next: `AWAITING_REPO_HYGIENE_AUDIT_V01`.
