# BCM-M21 Owner F5 Remediation V04-R01 — Sync/Local-Change Preservation Criteria

Status: **LOCKED BEFORE EXECUTION**

This only supersedes V04 preflight handling. All V04 owner/runtime criteria remain authoritative.

## Starting condition

Canonical checkout:
- local HEAD: `a7339ab1d05dfb5034ee90d55a5b79439fe8b7d4`
- remote/main: `8d99d34d5132bf3ea8f376640df815411a4ddb99`
- local tracked modifications:
  - `scripts/campaign/campaign_feedback_overlay.gd`
  - `scripts/game_manager.gd`
- local untracked generated artifacts:
  - 14 Godot `.translation` sidecars.

GitHub compare proves the 8 incoming commits do **not** touch either locally modified script.

## A — preserve, do not discard

Never:
- reset --hard;
- checkout/restore either modified script from HEAD;
- delete the 14 translation files;
- include the translation files in a stash;
- commit the ambiguous local changes before classification.

## B — tracked-only stash

Create a named tracked-only stash containing exactly the two modified scripts:

`git stash push -m "pre-v04-owner-local-preserve" -- scripts/campaign/campaign_feedback_overlay.gd scripts/game_manager.gd`

Then prove:
- those two tracked paths are clean in worktree/index;
- 14 translation sidecars remain untracked and untouched;
- no other unexpected local file exists.

If stash creation fails, STOP.

## C — safe sync

1. `git fetch origin main`
2. verify incoming tracked paths still do not include the two stashed scripts;
3. `git merge --ff-only origin/main`
4. verify local HEAD = origin/main = remote main.

No branch creation.

## D — reapply without destroying fallback

Use:
`git stash apply stash@{0}`

Do **not** pop/drop yet.

Expected:
- no merge conflict, because incoming commits do not touch the two paths.

If conflict occurs, STOP and preserve both sides.

## E — classify the two local diffs before V04 implementation

Inspect exact diff against synced HEAD.

For each hunk classify as one of:
- `V04_RELEVANT_AND_SAFE`
- `V04_RELEVANT_BUT_SUPERSEDED_BY_LOCKED_PROMPT`
- `UNRELATED_OWNER_CHANGE`
- `AMBIGUOUS`

Rules:
- keep `V04_RELEVANT_AND_SAFE` as starting implementation;
- do not duplicate it;
- if superseded, preserve evidence of the hunk but implement the locked V04 contract instead;
- any `UNRELATED_OWNER_CHANGE` or `AMBIGUOUS` hunk blocks implementation until reported;
- do not silently overwrite owner-local code.

Record classification in V04 execution log.

Only after all hunks are classified and either retained or safely superseded may V04 work continue.

## F — V04 execution

After successful preflight, execute the complete:
`CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V04.md`
against synchronized main.

All V04 criteria remain required, including:
- World Map calibration;
- Sunny Cove landmark pages/no lines;
- +150 px rigid table/playable translation;
- foreground cleanup;
- result lifecycle repair with 0 red Godot runtime errors;
- regression/evidence/owner checklist.

## G — stash cleanup

Do not drop the preservation stash until:
- V04 work is committed/pushed;
- local/origin/remote equality is verified;
- the final commit contains every retained local hunk intended for production;
- owner-local unrelated content has not been lost.

Then the stash may be dropped only if its contents are fully represented or intentionally superseded and documented.

Success marker remains:
`AWAITING_OWNER_F5_ACCEPTANCE_V04`
