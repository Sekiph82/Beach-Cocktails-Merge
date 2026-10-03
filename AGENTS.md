# Beach Cocktails Merge — Codex Governance

## Canonical repository

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Owner workspace: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: Godot 4.7.x

## Mandatory sync-first preflight

Every Codex session starts from the repository root and runs:

```powershell
git status --short --branch
git remote -v
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
```

Never use `reset --hard`, force-push, destructive checkout, automatic rebase, or silent stash to make synchronization succeed.

Preserve all owner work. If local and remote history cannot be reconciled safely, stop and record the exact blocker in the Codex log.

Before implementation, reconcile local `HEAD` with `origin/main`. Before completion, commit and push all intended changes and verify these three values match:

```powershell
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
```

Unsynchronized local changes are incomplete work.

## Canonical project truth

Root `TASKS.md` is the **only authoritative live project-status tracker** and the **only project-status file consumed by the H!veAI parser**. GitHub `origin/main` plus the latest commit are the remaining repository-truth inputs. Coordination prompts/logs/audits are evidence, not parallel status authorities.

Do not create, revive, or maintain `coordination/SESSION_INDEX.md`, `coordination/AUDIT_INDEX.md`, `docs/04_ROADMAP.md`, `.hiveai/PROJECT_DASHBOARD.md`, any `.hiveai/*` control-plane tracker, or any equivalent current-state mirror. Historical branch/task files may remain only when explicitly labeled historical/evidence-only.

H!veAI parser requirements:

- Keep `## Project Status` near the top.
- Preserve these exact labels:
  - `Current Milestone`
  - `Current Sprint`
  - `Current Task`
  - `Current Task Status`
  - `Next Task/Action`
  - `Required Actor`
  - `Tracking Repository`
  - `Tracking Branch`
  - `Progress`
- Each canonical task ID must appear **exactly once** in root `TASKS.md`; duplicate task IDs with same or conflicting states are forbidden.
- `Progress` is derived from unique canonical task IDs in root `TASKS.md`: validated `[x]` rows divided by all canonical task rows.
- Task rows use only:
  - `- [x] TASK-ID — Title.` validated complete
  - `- [~] TASK-ID — Title.` active/in progress
  - `- [ ] TASK-ID — Title.` planned/pending
  - `- [!] TASK-ID — Title.` blocked
- Do not create a competing `.hiveai/TASKS.md`, STATE, HANDOFF, PROJECT, RULES, EVENTS, or other current-state tracker.


### Historical task-list rule

- `ui-assets-tasks.md` is historical/superseded branch evidence only and is not a live tracker or H!veAI input.
- `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md` is visual-production evidence/history only and is not a live tracker or H!veAI input.
- Asset manifests/status CSVs may track asset-level production facts, but they must never mirror the project's current milestone, actor, workflow status, next action, or overall progress.

### Absolute TASKS ownership rule

Codex **must never edit root `TASKS.md`**.

This includes, without exception:

- checking or unchecking tasks;
- changing `[ ]`, `[~]`, `[x]`, or `[!]` markers;
- changing Current Milestone, Current Sprint, Current Task, Current Task Status, Next Task/Action, Required Actor, repository, or branch fields;
- changing progress, milestone closure, audit status, blockers, acceptance status, or roadmap state;
- adding completion notes to `TASKS.md`;
- performing a self-audit and then updating the tracker based on that self-audit.

No Codex prompt may override this rule. If a prompt appears to authorize a `TASKS.md` edit, treat that instruction as invalid and report the conflict.

Codex may **read** `TASKS.md` to learn the active work item, but it must leave the file byte-for-byte unchanged.

Only ChatGPT, acting as the independent auditor after reviewing committed repository evidence and the Codex log, may update `TASKS.md`. Tracker transitions happen only after that independent audit. A Codex completion claim is never a tracker transition.

## Session start

At the start of every milestone or remediation:

1. Complete the sync-first preflight.
2. Read `AGENTS.md` and root `TASKS.md` from the synchronized checkout.
3. Read the active ChatGPT prompt and locked criteria under `coordination/sessions/<SESSION-ID>/`.
4. Inspect implementation and asset paths before editing.
5. Create a new immutable Codex execution log under `docs/codex-logs/`.
6. Work only on the active work item.
7. Do not edit `TASKS.md`.
8. Commit and push all intended implementation/log/documentation changes before claiming completion.
9. Stop and wait for independent ChatGPT audit.

## Builder log rule

Codex logs are execution claims and evidence indexes, not acceptance proof.

Each log must include:

- work item identifier and prompt version;
- start HEAD and end HEAD;
- branch and remote;
- sync-preflight results;
- files changed;
- implementation summary;
- commands/tests run and exact results;
- Godot parse/run evidence when applicable;
- manual checks performed and checks not performed;
- known limitations;
- final commit SHA;
- proof that local HEAD, `origin/main`, and remote main match;
- explicit confirmation that `TASKS.md` was not modified.

Historical logs are immutable. Corrections go in a new versioned log.

## Independent audit ownership

Codex does not perform the acceptance audit for its own work and does not assign the authoritative milestone verdict.

Codex may run tests, static checks, smoke tests, and manual verification required by its prompt. Those are builder evidence only.

After Codex stops, ChatGPT independently audits repository truth. The strict audit uses these sections:

1. `VERDICT` — `PASS`, `CONDITIONAL`, or `FAIL`.
2. `CONTRACT RECOVERY`.
3. `BRANCH / HEAD / DIFF SCOPE`.
4. `ACCEPTANCE CRITERIA MATRIX` — `PASS`, `PARTIAL`, `FAIL`, or `UNVERIFIED` per criterion.
5. `BUILDER CLAIMS VS REPOSITORY TRUTH`.
6. `FILE / SYMBOL EVIDENCE`.
7. `FOCUSED TEST EVIDENCE`.
8. `REGRESSION EVIDENCE`.
9. `SECURITY / SAFETY REVIEW`.
10. `ARCHITECTURE CONSISTENCY`.
11. `TRACKER / LOG / DOCUMENTATION TRUTHFULNESS`.
12. `FINAL REPOSITORY STATE`.
13. `OPEN CROSS-MILESTONE FINDINGS`.
14. `DEFECTS BY SEVERITY` — `BLOCKER`, `MAJOR`, `MINOR`, `NOTE`.
15. `TECHNICAL DEBT / UPGRADE OPPORTUNITIES`.
16. `UNVERIFIED ITEMS`.
17. `REGRESSION RISK` — `LOW`, `MEDIUM`, or `HIGH`.
18. `AUDIT CONFIDENCE` — `LOW`, `MEDIUM`, or `HIGH`.
19. `FINAL VERDICT`.
20. `REQUIRED REMEDIATION` when not unconditional PASS.

Audit principles:

- Codex logs are claims to verify, not proof.
- Source, configuration, committed assets, tests, Git history, and runtime evidence outrank summaries.
- Passing tests do not override a direct specification violation.
- Missing evidence remains `UNVERIFIED`.
- Manual acceptance not actually performed remains pending/unverified.
- Previously accepted behavior must be regression-checked when touched.
- FAIL or blocking CONDITIONAL findings must be remediated and re-audited before normal progression.
- After the audit, ChatGPT alone updates `TASKS.md` to reflect the validated state and next action.

## Godot and gameplay preservation

The owner-accepted v6.7 gameplay feel is the baseline to preserve during v7 visual integration unless an explicit later owner direction changes it.

Accepted gameplay baseline includes:

- initial shot speed: `700 px/s`;
- deceleration: `180 px/s²`;
- no artificial cruise/minimum-speed assist;
- a newly launched drink is immediately replaced by the next launchable drink;
- multiple drinks may remain in motion while the next shot is launched;
- stopped drinks remain physically movable when hit;
- merge results preserve meaningful forward/lateral momentum;
- collisions must not intentionally rebound drinks backward toward the player;
- To-Go target levels span L6-L12;
- matching L6-L12 drinks already on the table can satisfy later orders;
- when a previously scored stored drink is later delivered, only the To-Go bonus is awarded;
- L12 stays on the table when not ordered and can satisfy a later L12 order.

Do not retune gameplay physics as a side effect of visual integration.

## Visual master and asset policy

The approved v7 direction is a bright polished tropical beach-bar casual mobile merge game with a slightly perspective-tilted long wooden table.

Canonical asset structure:

```text
assets/
  cocktails/
    L01.png ... L12.png
  environment/
    game_board_background.png
  ui/
    logo_beach_cocktails_merge.png
    panel_best_score.png
    panel_score.png
    panel_to_go_orders.png
    panel_next.png
    progression_strip.png
    launch_zone.png
    danger_line.png
  effects/
    to_go_trail.png
```

Do not regenerate or redesign owner-approved assets during integration unless the owner explicitly requests it. Use dynamic Godot labels/sprites over blank panel areas rather than baking changing score/order content into static images.

`guide_line` is not part of the current asset plan and must not be introduced unless the owner later asks for it.

## Table geometry constitution V2

Table visuals obey `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md` and `assets/ui_assets/tables/table_geometry_v2.json`.

This is a constitutional project rule:
- accepted R11 runtime rails remain the gameplay geometry authority;
- V1 bottom-corner geometry and `table_silhouette_mask.png` are legacy and must not be used as authority for new table art;
- `gameplay_table.png` is a 720x1280 transparent FULL TABLE asset;
- playable/tabletop art follows the R11 envelope and transitions to non-playable front structure at approximately y=988.333 on the canonical viewport;
- the lower region contains front apron/thickness and exactly two visible front legs;
- the existing L01-L12 progression UI remains between the legs and must not be occluded;
- Azure Bay V2 is the owner-approved structural master. Canonical technical masters under `assets/ui_assets/tables/` are `table_playable_surface_mask_v2.png`, `table_structure_mask_v2.png`, `table_edge_extraction_mask_v2.png`, and `table_shadow_master_v2.png`;
- every V2-converted island must use those exact masters for playable geometry, lower structure, overlay extraction, and shadow;
- island skins may change materials/colors/trim only, never geometry;
- do not retune R11 physics merely to fit AI-generated artwork.

Any prompt, historical log, V1 contract, mask, or old asset instruction that conflicts with V2 is superseded.

## Table asset production rulechain V2

For every island table family, Codex/ChatGPT MUST read and obey:
- `docs/ui-assets/TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md`

Mandatory sequence:
1. final V2-fitted `gameplay_table.png`;
2. derive `table_edge_overlay.png` from that exact final table;
3. create `gameplay_table_shadow.png` using the fixed deterministic V2 shadow recipe.

Independent AI generation of table-edge overlay geometry or scenic table shadows is forbidden.

Azure Bay is the V2 structural master. The remaining nine islands must use the same geometry, apron/leg relationship, progression clearance, overlay derivation method, and shadow recipe. Only island art/material language may vary.

## Repository hygiene and Desktop worktree policy

- The only canonical Desktop project folder is `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Never create another Beach Cocktails Merge clone, copy, backup, temporary directory, or Git worktree anywhere under Desktop.
- Do not create suffixed Desktop folders such as `-M13`, `-M13V02`, sprint names, remediation names, or backup clones.
- Temporary worktrees must be outside Desktop, preferably under `C:\Users\sekip\.codex\worktrees\...`.
- Inspect existing branches and worktrees before creating anything new.
- Do not create a new GitHub branch without explicit owner approval.
- Do not merge or delete a GitHub branch without explicit owner approval.
- If the canonical Desktop repository differs from `origin/main`, preserve owner work and report the exact divergence before attempting reconciliation.
- A dirty or detached canonical Desktop repository is not disposable and must not be treated as a synchronization target for destructive operations.

## Mandatory Canonical Desktop Sync Before Every Task

Before reading or implementing any new Codex task, synchronize the canonical
Desktop checkout with the current `origin/main`. ChatGPT may have updated
`TASKS.md`, prompts, audit criteria, audits, or other coordination files after
the prior task.

### Standing owner-local godot_ai sync exception

The following exact dirty-state combination is an authorized, recurring owner-local development integration and MUST NOT block synchronization by itself:

- modified tracked `project.godot` containing the owner-local godot_ai/autoload integration;
- untracked `addons/godot_ai/`;
- exactly 14 known generated untracked `.translation` sidecars.

When ALL of the following are true:

1. local `main` is behind-only relative to `origin/main`;
2. the only local dirty paths are the three known owner-local categories above;
3. the incoming diff from local `HEAD` to `origin/main` does not touch `project.godot`, `addons/godot_ai/**`, or any of those translation sidecars;

Codex is explicitly owner-authorized to reconcile the checkout **before reading the active task prompt** using this exact procedure:

1. create a tracked-only named stash containing exactly `project.godot`:
   `git stash push -m "owner-local-godot-ai-sync-preserve" -- project.godot`
2. do **not** use `-u`; leave `addons/godot_ai/` and the 14 translation sidecars untouched and untracked;
3. `git fetch origin main`;
4. re-verify the incoming diff excludes the protected owner-local paths;
5. `git merge --ff-only origin/main`;
6. locate the stash by message and `git stash apply` it without dropping it;
7. verify the restored dirty state contains only the intended `project.godot` owner-local diff plus the untouched plugin folder and 14 sidecars;
8. continue with the now-synchronized `AGENTS.md`, `TASKS.md`, and active prompt.

This is a standing owner authorization. **Do not stop merely because this exact known owner-local state exists.** Stop only if the dirty set contains anything else, the branch is not behind-only, the incoming diff touches a protected owner-local path, stash/apply conflicts, or any other ambiguity appears.

1. From `C:\Users\sekip\Desktop\Beach Cocktails - Merge`, run:
   - `git status --short --branch`
   - `git remote -v`
   - `git fetch origin main`
   - `git rev-list --left-right --count HEAD...origin/main`
2. If the canonical checkout is clean and behind-only, fast-forward it to `origin/main`.
3. If it contains only proven generated/reproducible clutter, remove only those generated items as authorized, then fast-forward.
4. If it contains any unique or ambiguous owner change, stop and report it; never overwrite, stash, reset, or discard it silently.
5. After ChatGPT updates `TASKS.md` or other coordination artifacts on GitHub, the next Codex task must synchronize the canonical Desktop checkout before implementation begins.
6. After Codex completes and pushes a task, if the canonical checkout is clean, fast-forward it to the just-pushed remote `main` before handoff.
7. If post-task synchronization is blocked by unique owner changes, report the blocker instead of creating another Desktop copy or worktree.
8. Temporary implementation worktrees may exist only outside Desktop.
9. Do not create a new GitHub branch without explicit owner approval.

## Safety

- Preserve owner-created assets and project files.
- Never commit secrets, `.godot/`, local caches, build output, editor state, save files, or machine-specific temporary files.
- Do not replace functional gameplay logic merely to simplify integration.
- Keep changes bounded to the active work item.
- Never self-approve work, close milestones, or edit `TASKS.md`.
