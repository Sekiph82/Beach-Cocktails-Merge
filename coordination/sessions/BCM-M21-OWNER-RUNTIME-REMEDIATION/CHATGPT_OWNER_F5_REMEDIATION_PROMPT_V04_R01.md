# BCM-M21-001 + BCM-M21-004 + BCM-M21-006 — Owner F5 Remediation V04-R01

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

This is one combined instruction: **preserve local changes → sync → classify → execute full V04**.

## 0. Preserve the two tracked local changes

Current local modifications:
- `scripts/campaign/campaign_feedback_overlay.gd`
- `scripts/game_manager.gd`

Current generated untracked files:
- 14 Godot `.translation` sidecars.

Do not delete/reset/restore any of them.

Create a tracked-only stash:

`git stash push -m "pre-v04-owner-local-preserve" -- scripts/campaign/campaign_feedback_overlay.gd scripts/game_manager.gd`

Do not use `-u`.

Verify only the 14 known translation files remain untracked.

## 1. Safe fast-forward

Run:
- `git fetch origin main`
- verify incoming diff does not touch the two stashed scripts;
- `git merge --ff-only origin/main`;
- verify local HEAD = origin/main = remote main.

If the two paths unexpectedly appear in incoming tracked diff, STOP.

## 2. Reapply but keep rollback point

Run:
`git stash apply stash@{0}`

Do not `pop` or `drop` yet.

If conflict occurs, STOP.

## 3. Classify local hunks

Before reading/implementing V04 changes, inspect exact diffs in the two scripts.

Classify every hunk:
- V04_RELEVANT_AND_SAFE
- V04_RELEVANT_BUT_SUPERSEDED_BY_LOCKED_PROMPT
- UNRELATED_OWNER_CHANGE
- AMBIGUOUS

If any hunk is unrelated/ambiguous, STOP and report it without overwriting.

If all hunks are V04-related, preserve useful work and continue.

## 4. Execute full V04

Now read:
- `AGENTS.md`
- root `TASKS.md`
- `coordination/AUDIT_POLICY.md`
- `OWNER_F5_RULING_V04.md`
- `OWNER_F5_AUDIT_V04.md`
- `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V04.md`
- `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V04_R01.md`
- `CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V04.md`

Then execute the complete V04 scope exactly.

Do not edit root `TASKS.md`.

## 5. Handoff

Record the stash/classification decision in:
`CODEX_LOG_OWNER_F5_REMEDIATION_V04.md`

Do not drop the preservation stash until final commit/push/equality proves no intended local work was lost.

Finish exactly:
`AWAITING_OWNER_F5_ACCEPTANCE_V04`
