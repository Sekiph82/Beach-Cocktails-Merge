# BCM-M21-001 + BCM-M21-006 — V07-R03-R01 Sync-Preserve + Execute V07-R03

Work only in the canonical checkout:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`

This is a continuation of the V07-R03 owner visual candidate remediation.

## 0. Owner-authorized reconciliation of the reported blocker

Reported canonical state:

- local HEAD: `7ad8f0584db703235aba67cc3bb54db0a75a4df4`
- `origin/main`: `f2fcedced42d95a4a3aba27ccc49019466642b56`
- divergence: local 0 ahead / 4 behind
- modified tracked owner-local file: `project.godot`
- untracked owner-local integration: `addons/godot_ai/`
- 14 generated untracked translation sidecars

The four incoming commits are coordination-only:

- `df522db` — V07-R02 owner visual rejection
- `5974e91` — V07-R03 criteria
- `49fd2c7` — V07-R03 prompt
- `f2fcedc` — TASKS tracking update

GitHub compare from `7ad8f058...` to `f2fcedc...` shows only these incoming paths:

- `TASKS.md`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V07_R02.md`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R03.md`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07_R03.md`

The incoming commits do **not** touch:
- `project.godot`
- `addons/godot_ai/**`
- the known translation sidecars

You are authorized to reconcile this exact state using the preserve/sync/restore procedure below.

## 1. Preserve tracked project.godot only

Create a new named tracked-only stash containing exactly `project.godot`:

`git stash push -m "pre-v07-r03-owner-godot-ai-project-settings" -- project.godot`

Do **not** use `-u`.

Do not stash, remove, clean, reset, restore, or delete:
- `addons/godot_ai/`
- the 14 translation sidecars

After the stash:
- verify `project.godot` is clean relative to local HEAD;
- verify `addons/godot_ai/` remains present and untracked;
- verify the 14 translation sidecars remain present and untracked;
- verify there are no additional unexpected owner-local changes.

If anything beyond the known owner-local set appears, STOP and report it.

## 2. Fast-forward canonical main

Run:

- `git fetch origin main`
- `git rev-list --left-right --count HEAD...origin/main`
- inspect incoming changed paths once more
- `git merge --ff-only origin/main`

No reset.
No rebase.
No force operation.
No new branch.
No new Desktop clone/worktree.

Verify:

- local HEAD = `origin/main`
- local HEAD = remote `main`

## 3. Restore owner-local project.godot

Locate the stash by the exact message:

`pre-v07-r03-owner-godot-ai-project-settings`

Apply it without dropping it.

Do not assume a stash index if ordering differs.

Verify:
- `project.godot` contains only the intended owner-local godot_ai integration diff;
- no conflict occurred;
- `addons/godot_ai/` remains untracked and untouched;
- the 14 translation sidecars remain untracked and untouched.

Keep the preservation stash.

## 4. Read and execute V07-R03

Only after successful sync and restore, read:

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V07_R02.md`
4. `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R03.md`
5. `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07_R03.md`

Then execute the entire V07-R03 prompt exactly.

Important owner visual rules from V07-R03 remain unchanged:

- table must dominate the 720×1280 screen and feel close to the player;
- rear tabletop edge approximately y=300..360;
- player-facing edge approximately y=880..950;
- visible tabletop depth >=520 px;
- current cocktail appears naturally near the player-facing tabletop;
- deadline is a single line ON the tabletop, slightly farther into the table than the current cocktail;
- no special launch-zone region, box, shade, outline, label, arrow, target area, or extra gameplay marking;
- L1-L12 progression panel must sit visually BETWEEN the two table legs;
- current production upper UI must be shown in each review candidate;
- Sunny Cove scenery remains visible behind and on both sides of the table;
- create exactly three owner-review visual candidates;
- do not promote production geometry or production bindings before owner selection.

## 5. Commit guard

Before every commit, stage only explicit V07-R03 product/evidence/log paths.

Run:

`git diff --cached --name-only`

Assert the staged set excludes:
- `project.godot`
- `addons/godot_ai/**`
- every `.translation` sidecar
- root `TASKS.md`

Never use:
- `git add -A`
- `git add .`

Codex must leave root `TASKS.md` byte-for-byte unchanged.

## 6. Final state and handoff

Push intended V07-R03 candidate/evidence/log commits to `main`.

Verify:
- product HEAD = `origin/main` = remote `main`

The local checkout may remain intentionally dirty only with:
- owner-local modified `project.godot`;
- untracked `addons/godot_ai/`;
- 14 known generated translation sidecars.

The final Codex log must record:
- synchronized base SHA;
- preservation stash name;
- restored `project.godot` classification;
- proof excluded owner-local paths were never staged/committed;
- final HEAD/origin/remote equality;
- exact candidate evidence paths;
- confirmation that `TASKS.md` was not modified.

Do not continue into geometry/runtime integration.

Finish exactly:

`AWAITING_OWNER_VISUAL_SELECTION_V07_R03`
