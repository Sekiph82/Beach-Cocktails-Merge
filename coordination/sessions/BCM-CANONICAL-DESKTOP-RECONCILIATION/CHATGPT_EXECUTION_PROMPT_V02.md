# BCM Canonical Desktop Reconciliation — Execution Prompt V02

Execute against:
`coordination/sessions/BCM-CANONICAL-DESKTOP-RECONCILIATION/CHATGPT_AUDIT_CRITERIA_V02.md`

The owner has made the required decisions.

Canonical folder:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

## Owner-authorized cleanup

The owner has already deleted:
- `beach cocktails merge logo.png`
- `Beach Cocktails - Merge.owner-backup-20260923-table-assets`

The owner explicitly authorizes:
- DISCARD the local `project.godot` divergence;
- replace it with the current GitHub `main` version;
- restore the two deleted tracked atlas files from current main;
- remove the 14 previously identified generated `*.translation` artifacts if still present.

Do not infer authorization for any other unique file.

## Phase 1 — sync truth

From the canonical Desktop repo:
- run status/remotes/fetch/ahead-behind;
- verify the owner-deleted logo/backup are absent;
- verify no new unexpected unique file appeared since V01.

If any NEW ambiguous owner content exists, STOP and report it.

Otherwise continue.

## Phase 2 — make canonical Desktop the real main checkout

Current canonical checkout was detached.

Safely:
1. inspect `git worktree list --porcelain`;
2. if branch `main` is held by a CLEAN outside-Desktop publication worktree, detach/release its branch association without deleting dirty worktrees;
3. do not touch the dirty `bcm-visual-production` worktree;
4. restore/discard only the explicitly authorized canonical working-tree differences;
5. attach canonical Desktop checkout to local `main`;
6. fast-forward to `origin/main`;
7. do not create a new branch;
8. do not use rebase or force-push.

The resulting canonical Desktop project must exactly represent current remote `main`.

## Phase 3 — permanent synchronization discipline

Update `AGENTS.md` with a mandatory **Canonical Desktop Sync Before Every Task** rule:

- before every Codex task, synchronize `C:\Users\sekip\Desktop\Beach Cocktails - Merge` with current `origin/main`;
- this happens before task implementation, because ChatGPT may have updated `TASKS.md`, prompts, criteria, audits, or other coordination files after the prior task;
- if canonical is clean and behind, fast-forward;
- if it has only known generated artifacts, clean only those generated artifacts and fast-forward;
- if it has unique owner changes, STOP and ask/report;
- never solve divergence by creating another Desktop copy/worktree;
- temporary worktrees must remain outside Desktop;
- after Codex pushes task completion, if canonical checkout is clean, fast-forward the canonical Desktop checkout to the new remote main before handoff;
- no GitHub branch creation without explicit owner approval.

Commit/push this governance-only change to `main`.

## Phase 4 — final canonical sync after governance push

Because the governance commit itself advances main:
- fetch current `origin/main` again;
- fast-forward the canonical Desktop checkout again;
- verify all three are identical:
  - canonical HEAD
  - origin/main
  - remote main

Final canonical status must be clean except ignored editor state.

## Phase 5 — evidence

Write:
`coordination/sessions/BCM-CANONICAL-DESKTOP-RECONCILIATION/CODEX_LOG_V02.md`

Include:
- pre-sync canonical status;
- authorized items removed/restored;
- branch-main worktree transfer action;
- governance change;
- post-governance final sync;
- final canonical branch/HEAD/status;
- origin/main and remote-main SHA;
- confirmation no new Desktop project folder/worktree;
- confirmation no new branch;
- confirmation dirty visual-production worktree untouched;
- confirmation root `TASKS.md` not edited.

Return:
- governance implementation SHA;
- final main SHA;
- final canonical Desktop HEAD;
- log URL;
- `CANONICAL_DESKTOP_SYNCED_AWAITING_AUDIT_V02`.

Then STOP. Do not start M15 in this run.