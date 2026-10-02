# BCM-M21 V07-R01 — godot_ai Local Integration Preserve + Sync Criteria

Status: **LOCKED BEFORE EXECUTION**

This package only changes V07 preflight handling. All V07 product, visual-self-audit, and owner-gate criteria remain authoritative.

## Starting state

Canonical local checkout:
- branch: main
- local HEAD: `82166db6bed433535707623131936daad9820133`
- remote main: `88d08db22c5ca453c1725e19b608a9aae1cea8cd`
- divergence: local 0 ahead / 6 behind

Owner-local changes:
- tracked modified `project.godot`
  - adds `_mcp_game_helper` autoload
  - enables `res://addons/godot_ai/plugin.cfg`
- untracked `addons/godot_ai/`
- 14 known generated untracked `.translation` sidecars

GitHub compare proves the six incoming commits do NOT touch:
- `project.godot`
- `addons/godot_ai/**`
- any known translation sidecar path

## A — owner-local integration policy

The `godot_ai` integration is an **authorized owner-local development integration**.

It is NOT part of the V07 product commit.

Never:
- delete it;
- reset/restore it;
- commit it;
- add it to repo history;
- include it in a stash with untracked files;
- stage any `addons/godot_ai/**` file;
- stage any generated `.translation` sidecar.

The owner-local `project.godot` modification must also not be committed by V07.

## B — preserve tracked project.godot only

Create a named tracked-only stash containing exactly `project.godot`:

`git stash push -m "pre-v07-owner-godot-ai-project-settings" -- project.godot`

Do NOT use `-u`.

Then verify:
- `project.godot` is clean relative to local HEAD;
- `addons/godot_ai/` remains present and untracked;
- the 14 translation sidecars remain present and untracked;
- no other unexpected local path exists.

If stash creation fails, STOP.

## C — safe sync

1. `git fetch origin main`
2. verify incoming diff still excludes `project.godot`, `addons/godot_ai/**`, and the known translation sidecars;
3. run `git merge --ff-only origin/main`;
4. verify local HEAD = origin/main = remote main.

No branch creation.
No reset.
No rebase.

## D — restore owner-local project settings

Apply, do not pop:

`git stash apply stash@{0}`

If stash ordering differs, resolve the named stash by message instead of assuming index.

Verify:
- only the intended owner-local `project.godot` diff returns;
- `addons/godot_ai/` remains untracked;
- 14 sidecars remain untracked;
- no conflict occurred.

Do not drop the stash during V07.

## E — execute full V07

After successful sync/restore:
- read and execute `CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07.md`;
- preserve all owner-local integration files while using Godot GUI as required;
- the plugin may be active locally, but no plugin-generated repo mutation may be included unless explicitly part of V07 and independently justified.

## F — staging/commit guard

Before every V07 commit:

1. stage only explicit V07 product/evidence paths;
2. run `git diff --cached --name-only`;
3. assert staged set excludes:
   - `project.godot`
   - `addons/godot_ai/**`
   - all `.translation` sidecars
4. if any excluded path is staged, unstage it and STOP to recheck.

The final local working tree is allowed to contain:
- modified `project.godot` owner-local integration;
- untracked `addons/godot_ai/`;
- 14 known generated translation sidecars.

This is an authorized known-local exception and must not be falsely reported as a fully clean working tree.

## G — final handoff

All V07 visual self-audit requirements still apply.

The final log must record:
- synchronized V07 base SHA;
- named stash identity;
- exact restored `project.godot` owner-local diff classification;
- proof excluded paths were never committed;
- final HEAD/origin/remote equality;
- known owner-local exception list.

Successful marker remains:
`AWAITING_OWNER_F5_ACCEPTANCE_V07`
