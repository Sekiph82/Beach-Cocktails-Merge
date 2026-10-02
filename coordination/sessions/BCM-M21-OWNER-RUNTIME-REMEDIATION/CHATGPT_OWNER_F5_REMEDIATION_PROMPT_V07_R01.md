# BCM-M21-001 + BCM-M21-006 — V07-R01 Sync Preserve + Full V07

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

This is one combined task:

**preserve godot_ai owner-local integration → synchronize local/GitHub → restore integration → execute complete V07 visual redesign/self-audit.**

## 0. Mandatory synchronization preflight

Current known state:
- local main: `82166db6bed433535707623131936daad9820133`
- remote main: `88d08db22c5ca453c1725e19b608a9aae1cea8cd`
- local is 6 commits behind.

Owner-local integration:
- modified `project.godot`
- untracked `addons/godot_ai/`
- 14 untracked `.translation` sidecars.

GitHub verification already proved the incoming six commits do not touch any of those paths.

### Preserve tracked project.godot only

Run:

`git stash push -m "pre-v07-owner-godot-ai-project-settings" -- project.godot`

Do NOT use `-u`.

Do not remove or stash:
- `addons/godot_ai/`
- the 14 translation sidecars.

Verify the only remaining local exceptions are those known untracked paths.

### Synchronize

Run:
- `git fetch origin main`
- verify incoming changed paths again
- `git merge --ff-only origin/main`

Verify:
- local HEAD = origin/main = remote main.

### Restore owner-local project settings

Apply the named stash without dropping it.

Do not assume stash index if there are multiple stashes; locate it by message.

After apply, verify:
- `project.godot` contains only the intended godot_ai local integration change;
- no conflict;
- plugin folder and sidecars remain untouched.

## 1. Read V07

Now read:
1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `OWNER_F5_RULING_V07.md`
5. `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07.md`
6. `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R01.md`
7. `CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07.md`

Then execute the entire V07 scope.

## 2. godot_ai policy during V07

The plugin is available locally and may remain active for the owner workflow.

But V07 must NOT commit:
- `project.godot` owner-local plugin/autoload changes;
- any `addons/godot_ai/**` file;
- any generated `.translation` file.

Do not delete or disable the integration.

## 3. V07 product task remains unchanged

You must still:
- redesign Sunny Cove gameplay surface from a blank 720×1280 canvas;
- do NOT tweak/shift V06 as the design method;
- freeze the final art first;
- derive geometry from that final image;
- open Godot GUI;
- run production navigation with real input;
- capture the required SC-01..SC-08 and WM-01..WM-10 screenshots;
- visually self-evaluate every item;
- fix and recapture anything FAIL/UNCERTAIN;
- hand off only when the builder self-visual audit contains PASS for every item.

## 4. Commit guard

Before each commit, stage explicit V07 paths only.

Assert `git diff --cached --name-only` does not contain:
- `project.godot`
- `addons/godot_ai/`
- `.translation` sidecars.

Never use a blanket stage such as `git add -A` or `git add .` in this task.

## 5. Final state

Final product commits must be pushed to `main`.

Verify product HEAD = origin/main = remote main.

The local checkout is allowed to remain intentionally dirty only with:
- owner-local modified `project.godot`;
- untracked `addons/godot_ai/`;
- 14 known untracked translation sidecars.

Preservation stash remains retained.

Do not edit root `TASKS.md`.

Finish exactly:
`AWAITING_OWNER_F5_ACCEPTANCE_V07`
