# BCM Canonical Desktop Reconciliation — Audit Criteria V02

Status: **LOCKED BEFORE EXECUTION**

Owner decisions are now explicit:

- Delete/discard the local `project.godot` working-tree change and use GitHub `main` version.
- `beach cocktails merge logo.png` has already been deleted by the owner.
- `Beach Cocktails - Merge.owner-backup-20260923-table-assets` has already been deleted by the owner.
- Canonical local project folder is permanently:
  `C:\Users\sekip\Desktop\Beach Cocktails - Merge`

## Gate A — Canonical Desktop becomes current main

PASS requires:
- canonical Desktop checkout attached to local branch `main`;
- canonical HEAD == origin/main == remote main;
- local `project.godot` exactly matches current `origin/main`;
- the two tracked atlases are restored exactly from main;
- generated untracked translation artifacts are removed if still present;
- no owner-approved unique content remains pending;
- final working tree clean except ignored editor state.

No branch creation.

## Gate B — No owner data loss

The owner explicitly authorized:
- discard local `project.godot` divergence;
- logo already deleted;
- owner backup already deleted.

No other non-generated/non-main file may be deleted without evidence or owner approval.

## Gate C — Main worktree ownership

If local branch `main` is currently checked out by an outside-Desktop publication worktree:
- safely detach/release that clean worktree's `main` association;
- do not delete dirty worktrees;
- do not touch `C:\Users\sekip\.codex\worktrees\bcm-visual-production`;
- attach canonical Desktop checkout to `main`.

## Gate D — Permanent task-start synchronization rule

Update `AGENTS.md` so every future Codex task must, BEFORE reading/implementing the task:

1. Treat `C:\Users\sekip\Desktop\Beach Cocktails - Merge` as canonical owner checkout.
2. Run canonical sync preflight there:
   - `git status --short --branch`
   - `git remote -v`
   - `git fetch origin main`
   - `git rev-list --left-right --count HEAD...origin/main`
3. If canonical checkout is clean and behind-only, fast-forward it to `origin/main`.
4. If canonical contains only proven generated/reproducible clutter, remove only those generated items as permitted, then fast-forward.
5. If canonical contains any unique/ambiguous owner change, STOP and report. Never overwrite/stash/reset it silently.
6. After ChatGPT updates `TASKS.md` or other coordination artifacts on GitHub, the NEXT Codex task must synchronize the canonical Desktop checkout before implementation begins.
7. After Codex completes and pushes a task, if the canonical Desktop checkout is clean, fast-forward it to the just-pushed remote `main` before handoff so the owner's Desktop stays current.
8. If post-task sync is blocked by unique owner changes, report the blocker instead of creating another Desktop copy/worktree.
9. Temporary implementation worktrees may exist only outside Desktop.
10. No new GitHub branch without explicit owner approval.

These rules are mandatory even when Codex performs implementation in an outside-Desktop worktree.

## Gate E — No Desktop proliferation

PASS requires:
- no new `Beach Cocktails - Merge-*` Desktop folder;
- no new Desktop Git worktree;
- no backup clone under Desktop;
- only the canonical Desktop project folder remains under owner control.

## Gate F — Final verification

Record:
- canonical branch;
- canonical HEAD;
- origin/main SHA;
- remote main SHA;
- `git status --short --branch`;
- exact `project.godot` SHA or blob match;
- worktree list relevant to branch `main`;
- confirmation no new branch/worktree/folder was created.

Write:
`coordination/sessions/BCM-CANONICAL-DESKTOP-RECONCILIATION/CODEX_LOG_V02.md`

Return:
`CANONICAL_DESKTOP_SYNCED_AWAITING_AUDIT_V02`