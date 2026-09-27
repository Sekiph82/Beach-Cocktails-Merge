# BCM Repository Hygiene / Desktop Sync — Audit Criteria V01

Status: **LOCKED BEFORE EXECUTION**  
Auditor: ChatGPT  
Builder: Codex  
Branch: `main`

## Owner intent

Canonical local project folder:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

The owner's Desktop must NOT contain additional Beach Cocktails Merge clones, worktrees, copies, temp folders, or suffixed project folders created by ChatGPT/Codex.

Known unexpected Desktop folders to inspect only:

- `C:\Users\sekip\Desktop\Beach Cocktails - Merge-M13`
- `C:\Users\sekip\Desktop\Beach Cocktails - Merge-M13V02`

The owner wants:
1. one canonical Desktop project folder only;
2. GitHub `main` as the canonical remote branch;
3. all other GitHub branches classified so the owner can decide whether to merge/delete them;
4. local canonical folder and GitHub `main` eventually synchronized without losing owner work;
5. no branch creation, branch merge, branch deletion, destructive local sync, or deletion of the two unexpected Desktop folders without an explicit owner decision after the inventory.

## Gate A — Desktop folder identity

For each of these three paths, report:
- exists / missing;
- normal folder vs Git repo vs linked Git worktree;
- `.git` form: directory or gitfile/worktree pointer;
- current HEAD SHA;
- current branch or detached HEAD;
- remote URL(s);
- `git status --short --branch`;
- ahead/behind vs `origin/main`;
- staged/unstaged/untracked files;
- commits reachable from that folder but not from `origin/main`;
- files/content unique to that folder and not present in canonical Desktop repo or `origin/main`.

Do NOT modify or delete either `-M13` or `-M13V02` folder.

A folder may be classified `SAFE_TO_DELETE_BY_OWNER` only if:
- it has no unique commit not already reachable from `origin/main`;
- it has no staged/unstaged/untracked user file that is not safely present elsewhere;
- it is not an active required worktree for an unmerged branch;
- deleting it would not remove the only copy of any user work.

Otherwise classify `DO_NOT_DELETE_YET` and explain exactly why.

## Gate B — Canonical Desktop repo safety

For:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

determine:
- current HEAD/branch/detached state;
- exact dirty changes;
- exact divergence from `origin/main`;
- whether local-only work exists.

Do not reset, clean, stash, checkout-overwrite, rebase, discard, or auto-commit owner changes.

If the canonical repo is clean and has no unique local work, it may be fast-forwarded to `origin/main`.

If any local-only or dirty owner work exists, STOP before changing it and report the exact reconciliation choices.

## Gate C — Git worktree inventory

Run and record:
- `git worktree list --porcelain`;
- all linked worktree paths;
- branch/HEAD tied to each worktree;
- whether each worktree is still needed.

Future temporary worktrees for this repository must never be created anywhere under Desktop.

Allowed temporary/worktree roots are outside Desktop, preferably:
- `C:\Users\sekip\.codex\worktrees\...`
- another non-Desktop temp/worktree directory explicitly approved by the owner.

## Gate D — GitHub branch inventory

Fetch remote truth and report every remote branch other than `main`.

For each branch:
- branch name;
- current tip SHA;
- ahead/behind vs `origin/main`;
- unique commits not in main;
- commits on main not in branch;
- changed file summary of unique branch work;
- whether the branch is fully merged into main;
- classification:
  - `FULLY_MERGED_SAFE_TO_DELETE`
  - `UNIQUE_COMMITS_REVIEW_REQUIRED`
  - `UNKNOWN/NEEDS_MORE_EVIDENCE`.

Do not merge or delete any branch in this V01 execution.

## Gate E — branch origin / reason evidence

The owner asked when and why branches were created.

Git itself does not reliably store remote branch creation timestamps or intent.

Therefore:
- never invent a branch creation date or purpose;
- use local reflog only if available and label it as local evidence;
- use earliest unique commit timestamp, PR/session logs, commit messages, Codex logs, or coordination artifacts as supporting evidence;
- clearly label any inferred date/purpose as `INFERRED`, not exact;
- if no evidence exists, state `UNKNOWN`.

## Gate F — main completeness

Determine whether any remote branch contains unique work that should potentially enter `main`.

Do not blindly merge "everything".

Report:
- branches already fully represented in main;
- branches with unique commits;
- whether unique commits are obsolete/superseded, conflicting, or potentially valuable;
- exact recommended owner decision per branch.

Any actual merge/cherry-pick requires a new explicit owner approval after this report.

## Gate G — permanent anti-clutter governance

Prepare a bounded governance patch that permanently states:

1. Canonical Desktop repository:
   `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
2. Never create another Beach Cocktails Merge clone/worktree/copy/temp directory on Desktop.
3. Temporary worktrees must live outside Desktop, preferably under `C:\Users\sekip\.codex\worktrees\...`.
4. Before creating any branch or worktree, inspect existing branch/worktree state first.
5. Do not create a new GitHub branch unless the owner explicitly authorizes it.
6. Do not merge/delete remote branches without owner approval.
7. If canonical Desktop repo differs from `origin/main`, preserve owner work and report the divergence before attempting reconciliation.
8. Never treat a dirty/detached canonical Desktop repo as disposable.
9. Codex/ChatGPT must not create suffixed Desktop folders such as `-M13`, `-M13V02`, sprint names, remediation names, or backup clones.

Because the owner explicitly asked to prevent recurrence, this governance patch may be committed directly to `main` in the same V01 task ONLY if it changes governance/documentation files and no product/runtime code.

## Gate H — no destructive cleanup

V01 must NOT:
- delete either unexpected Desktop folder;
- delete any Git worktree;
- delete any GitHub branch;
- merge/cherry-pick any branch;
- force-push;
- hard reset;
- clean untracked files;
- stash owner changes;
- rewrite history;
- move owner files;
- overwrite the canonical Desktop repo.

## Gate I — required handoff

Write:
`coordination/sessions/BCM-REPO-HYGIENE-DESKTOP-SYNC/CODEX_LOG_V01.md`

The log must include:
- canonical Desktop repo status;
- full `-M13` folder verdict;
- full `-M13V02` folder verdict;
- worktree inventory;
- branch inventory table;
- branch creation/purpose evidence or UNKNOWN;
- main completeness analysis;
- governance patch files/commit if applied;
- exact owner decisions still required;
- explicit statement that no folder/branch/worktree was deleted;
- explicit statement that no branch was merged/cherry-picked;
- final `main` SHA;
- sync proof.

## Acceptance

This task is an inventory/safety gate.

PASS requires complete evidence and no destructive action.

Any ambiguous unique work must remain preserved and be escalated to the owner.
