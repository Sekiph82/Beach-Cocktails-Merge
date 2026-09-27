# BCM Repository Hygiene / Desktop Sync — Execution Prompt V01

Execute against:
`coordination/sessions/BCM-REPO-HYGIENE-DESKTOP-SYNC/CHATGPT_AUDIT_CRITERIA_V01.md`

This task interrupts product work only long enough to establish repository and Desktop truth safely.

## Owner's canonical local folder

The ONLY canonical Desktop project folder is:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

From now on, do NOT create additional Beach Cocktails Merge folders, clones, backups, or Git worktrees anywhere on the Desktop.

Temporary Codex worktrees must be outside Desktop, preferably under:

`C:\Users\sekip\.codex\worktrees\...`

## Unexpected folders to investigate

Inspect, but DO NOT delete or modify:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge-M13`

`C:\Users\sekip\Desktop\Beach Cocktails - Merge-M13V02`

The owner wants to know exactly:
- what each folder is;
- who/what likely created it from repository evidence;
- which branch/commit/worktree it belongs to;
- whether it contains any unique commit or uncommitted/untracked file;
- whether anything from it still needs to be preserved or moved into the canonical repo/main;
- whether the owner can safely delete it.

Return a clear verdict for each:

`SAFE_TO_DELETE_BY_OWNER`

or

`DO_NOT_DELETE_YET`

with evidence.

Do not delete them yourself.

## Phase 1 — READ-ONLY inventory first

Before ANY mutation:

1. Inspect the canonical Desktop repo:
   - HEAD
   - branch/detached state
   - remotes
   - status
   - ahead/behind vs origin/main
   - dirty/untracked/staged state
   - local commits not in origin/main

2. Inspect both unexpected Desktop folders with the same checks.

3. Run:
   - `git worktree list --porcelain`
   - `git branch -vv`
   - `git branch -r -vv`
   - `git fetch --all --prune`
   - remote/main sync checks

4. Inventory every remote GitHub branch other than main.

For every branch show:
- tip SHA;
- ahead/behind vs main;
- unique commits;
- unique changed files;
- whether fully merged;
- likely creation date/reason only where evidence exists.

IMPORTANT: Git does not reliably store branch creation time/purpose. Never invent this. Use reflog/session logs/commit history where available and label inference honestly.

## Phase 2 — protect owner work

The canonical Desktop folder may contain owner changes.

Never:
- reset;
- clean;
- auto-stash;
- discard;
- overwrite;
- rebase;
- force checkout;
- silently commit owner files.

If the canonical repo is clean and has no local-only work, you may fast-forward it to `origin/main`.

If it is dirty or contains unique local work:
- do NOT change it;
- report the exact files/commits;
- explain the safest reconciliation options;
- stop for owner approval.

## Phase 3 — GitHub branch classification

The owner ultimately wants GitHub main to contain all work that genuinely belongs there and old branches to become deletable.

BUT DO NOT blindly merge every branch.

Classify each remote branch as:

- `FULLY_MERGED_SAFE_TO_DELETE`
- `UNIQUE_COMMITS_REVIEW_REQUIRED`
- `UNKNOWN_NEEDS_EVIDENCE`

For branches with unique commits:
- summarize the exact commits/files;
- say whether work appears superseded, obsolete, conflicting, or potentially valuable;
- give a recommended merge/cherry-pick/no-merge decision.

Do NOT merge, cherry-pick, or delete a GitHub branch in this V01 task.

The owner explicitly wants to be asked before GitHub branch operations.

## Phase 4 — stop future Desktop clutter permanently

Update repository governance/documentation ONLY, not runtime/product code, to encode these permanent rules:

- canonical Desktop repo is exactly:
  `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- no additional Beach Cocktails Merge Desktop clone/worktree/copy;
- no `-M13`, `-M13V02`, sprint, remediation, backup, or suffixed Desktop work folders;
- temporary worktrees go outside Desktop, preferably `C:\Users\sekip\.codex\worktrees\...`;
- do not create a new GitHub branch without owner approval;
- do not merge/delete GitHub branches without owner approval;
- inspect existing worktrees/branches before creating anything new;
- if canonical local differs from main, preserve local owner work and report first.

Use the existing appropriate governance files such as `AGENTS.md` and/or `coordination/AUDIT_POLICY.md`.

This governance-only patch is explicitly authorized by the owner in this task.

Commit/push that governance patch directly to `main` without creating a branch.

## Phase 5 — handoff and STOP

Write:

`coordination/sessions/BCM-REPO-HYGIENE-DESKTOP-SYNC/CODEX_LOG_V01.md`

Include a compact table for:

### Desktop folders
- canonical
- M13
- M13V02

### Git worktrees

### Remote branches

### Owner decisions required

At the end, tell the owner:
1. whether `Beach Cocktails - Merge-M13` is safe to delete;
2. whether `Beach Cocktails - Merge-M13V02` is safe to delete;
3. whether canonical Desktop repo is current with main;
4. if not, exactly what blocks sync;
5. which branches are already safe to delete;
6. which branches contain unique work and need owner approval before merge/delete.

Return:
- governance commit SHA;
- final main SHA;
- log GitHub URL;
- `AWAITING_REPO_HYGIENE_AUDIT_V01`.

Then STOP.

Do not resume M15 implementation in this run.
