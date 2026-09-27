# BCM Canonical Desktop Reconciliation — Execution Prompt V01

Execute against:
`coordination/sessions/BCM-CANONICAL-DESKTOP-RECONCILIATION/CHATGPT_AUDIT_CRITERIA_V01.md`

Canonical folder:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Current GitHub canonical branch: `main`.

## Objective

Safely make the canonical Desktop repo current with GitHub main.

Do NOT create another Desktop clone/worktree/folder.
Do NOT create a branch.
Do NOT use reset --hard, clean -fd, silent stash, rebase, or destructive checkout.

## Step 1 — exact forensic classification

Re-fetch current main and inspect the canonical folder.

For EVERY modified/deleted/untracked item:
- show exact path;
- for tracked files show working-tree diff against HEAD and against current origin/main;
- for binary/untracked files compute SHA-256 and compare against likely canonical/current-main files;
- for directories recursively inventory relevant files/hashes;
- determine whether the content is already preserved elsewhere in current main.

Pay special attention to:
- `assets/ui_assets/v05_sources/effects_atlas.png`
- `assets/ui_assets/v05_sources/ui_atlas.png`
- `project.godot`
- `Beach Cocktails - Merge.owner-backup-20260923-table-assets/`
- generated `*.translation` files
- `beach cocktails merge logo.png`

Classify each item:
- IDENTICAL_OR_ALREADY_PRESERVED_IN_MAIN
- GENERATED_REPRODUCIBLE
- OBSOLETE_SUPERSEDED
- UNIQUE_OWNER_CONTENT
- UNKNOWN_REQUIRES_OWNER

## Step 2 — safety decision

If ANY item is UNIQUE_OWNER_CONTENT or UNKNOWN_REQUIRES_OWNER:

STOP.

Do not change the canonical repo.

Write the log with exact evidence and tell the owner what decision is needed.

If every item is proven safe because it is generated, obsolete, or already preserved in main, continue.

## Step 3 — make canonical repo the real main checkout

Only after Step 2 is completely safe:

1. inspect `git worktree list --porcelain`;
2. branch `main` is currently associated with an outside-Desktop publication worktree if still present;
3. safely release/detach branch `main` from that CLEAN outside-Desktop worktree without deleting any dirty worktree;
4. attach the canonical Desktop repository to `main`;
5. fast-forward to `origin/main`;
6. verify:
   - `git rev-parse HEAD`
   - `git rev-parse origin/main`
   - `git ls-remote origin refs/heads/main`
   are identical.

Do not touch `C:\Users\sekip\.codex\worktrees\bcm-visual-production` because it contains unresolved modified badge assets.

## Step 4 — final verification

Report:
- final canonical branch;
- final HEAD;
- final status;
- whether canonical == origin/main == remote main;
- every local file removed/restored and why it was safe;
- every preserved owner file;
- worktrees touched and exact action;
- confirmation no new Desktop folder and no new branch were created.

Write:
`coordination/sessions/BCM-CANONICAL-DESKTOP-RECONCILIATION/CODEX_LOG_V01.md`

Return one of:

`CANONICAL_DESKTOP_SYNCED_AWAITING_AUDIT`

or

`OWNER_DECISION_REQUIRED_BEFORE_CANONICAL_SYNC`

Then STOP.
