# BCM Canonical Desktop Reconciliation — Audit Criteria V01

Status: **LOCKED BEFORE EXECUTION**

Canonical local repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Goal: make the canonical Desktop checkout current with GitHub `main` without losing any owner-created local file.

## Gate A — exact local dirty-item classification

Before mutation, capture the full canonical status and exact content/diff for every dirty/untracked item.

Known classes from prior inventory include:
- tracked deleted source atlases;
- modified `project.godot`;
- owner backup directory;
- generated `*.translation` files;
- untracked logo PNG;
- any additional current status item.

For every item classify:
- `IDENTICAL_OR_ALREADY_PRESERVED_IN_MAIN`
- `GENERATED_REPRODUCIBLE`
- `OBSOLETE_SUPERSEDED`
- `UNIQUE_OWNER_CONTENT`
- `UNKNOWN_REQUIRES_OWNER`

Use byte hashes/path/content comparison where possible.

No ambiguous item may be discarded.

## Gate B — no-loss rule

If ANY item is `UNIQUE_OWNER_CONTENT` or `UNKNOWN_REQUIRES_OWNER`:
- do not clean/reset/overwrite/switch away destructively;
- do not auto-move it;
- stop and report exactly what needs owner decision.

Only if every dirty item is proven safe/reproducible/preserved may synchronization proceed.

## Gate C — canonical main ownership

If Gate B is clear:
- ensure no other clean worktree keeps branch `main` checked out;
- safely detach/remove only the clean outside-Desktop publication worktree association as required;
- do not delete dirty outside-Desktop worktrees;
- attach the canonical Desktop repo to local `main`;
- update with `git pull --ff-only` / equivalent non-destructive fast-forward;
- final canonical HEAD, origin/main and remote main must match.

No new branch may be created.

## Gate D — generated/local clutter

Generated editor/import files may be removed only when proven reproducible and not owner-authored.

Do not delete owner backup/logo files unless proven byte-identical/already preserved or owner explicitly authorizes.

## Gate E — M13/M13V02 worktree metadata

The physical M13/M13V02 folders are owner-approved safe-to-delete, but Codex must not delete them unless the owner explicitly says they have been deleted or authorizes Codex to remove them.

If the owner deletes them manually, Codex may prune stale Git worktree metadata in a later authorized cleanup.

## Gate F — preserve dirty visual-production worktree

Do not modify/delete:
`C:\Users\sekip\.codex\worktrees\bcm-visual-production`

until its eight modified badge assets are separately audited/owner-decided.

## Gate G — final state

PASS requires:
- canonical Desktop repo on branch `main`;
- canonical HEAD == origin/main == remote main;
- no lost owner file;
- no extra new Desktop project folder/worktree;
- no new GitHub branch;
- no force/reset-hard/rebase;
- exact final status reported.

## Builder log

Write:
`coordination/sessions/BCM-CANONICAL-DESKTOP-RECONCILIATION/CODEX_LOG_V01.md`

If reconciliation cannot safely proceed, log `OWNER_DECISION_REQUIRED` and STOP without modifying ambiguous files.
