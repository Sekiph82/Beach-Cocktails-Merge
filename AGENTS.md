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
  ui_assets/campaign/islands/<island>/
    gameplay_surface_v07_r04.png  # island-specific frozen source
    gameplay_surface.png          # byte-identical runtime authority
    playable_geometry_r04.json    # profile bound to the surface SHA-256
```

Do not regenerate or redesign owner-approved assets during integration unless the owner explicitly requests it. Use dynamic Godot labels/sprites over blank panel areas rather than baking changing score/order content into static images.

`guide_line` is not part of the current asset plan and must not be introduced unless the owner later asks for it.

## Active M21 V07-R04 owner visual override

For the active Sunny Cove V07-R04 remediation, the latest owner ruling under
`coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V07_R04.md`
supersedes older table **visual-composition** rules that require a complete freestanding table, exactly two visible legs, or an L01-L12 progression panel between those legs.

Current visual authority for V07-R04:
- preserve the CURRENT-design Beach Cocktails Merge logo, To-Go Orders, Best Score, Score, and Next; the master reference does not control those five HUD designs;
- for the rest of the gameplay scene, follow the owner master composition: close player-facing board, deep tabletop, strong perspective, near edge close to the player, no mandatory visible legs, and a wide L01-L12 progression strip directly below the front edge;
- keep one horizontal deadline on the tabletop;
- do not introduce the master's vertical dotted/arrow aiming guide or any substitute trajectory/guide line.

This override changes visual composition only. Accepted gameplay physics, collision behavior, scoring, To-Go/VIP behavior, progression, persistence, input behavior, and the owner's no-timer ruling remain frozen.

## R04 gameplay-surface technical authority — owner-directed 2026-10-04

The owner explicitly authorizes the island-specific `gameplay_surface_v07_r04.png` files as the new gameplay-screen art authority and replaces the former split `gameplay_background` + `gameplay_table` + `table_edge_overlay` + `gameplay_table_shadow` production model for this screen.

Read and obey `docs/ui-assets/GAMEPLAY_SURFACE_CONTRACT_V07_R04.md`.

- Each island's `gameplay_surface_v07_r04.png` is its frozen source image.
- Each island's runtime `gameplay_surface.png` must be byte-identical to that same island's R04 source; never substitute Sunny Cove art for another island.
- Each island has a `playable_geometry_r04.json` record bound to the canonical surface SHA-256. Runtime geometry and asset validation must reject a missing/mismatched surface/profile pair.
- Calibration and measurements use that exact canonical surface. Geometry-debug and crowded-drink proofs are derived overlays of it and belong under remediation evidence, not under runtime assets.
- The former independent table-fit and table-shadow proof chain is retired for R04; the surface/profile overlay proof replaces it.
- The five island-map/completion files `complete_badge.png`, `map_background.png`, `map_title.png`, `theme_badge.png`, and `world_icon.png` remain separate island assets.
- Do not retune accepted gameplay physics to fit artwork. Keep the shared gameplay boundary consistent across islands and validate visible drink footprints against each island's R04 surface.

`TABLE_GEOMETRY_CONTRACT_V2.md` and `TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md` are historical evidence only for the retired split-table visual pipeline. They do not authorize new R04 split table layers or masks.

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

### Standing owner-local plugin sync exception

The following exact dirty-state combination is an authorized, recurring owner-local development setup and MUST NOT block synchronization by itself:

- modified tracked `project.godot` containing owner-local plugin/autoload integration;
- untracked `addons/godot_ai/`;
- untracked `addons/game_feel_flow/`;
- untracked `addons/saltmire_spark/`;
- exactly 14 known generated untracked `.translation` sidecars.

The three addon directories above are deliberate owner-installed local integrations. During M21 they are protected owner-local content: do not delete, clean, reset, stash with `-u`, stage, commit, or rewrite them.

When ALL of the following are true:

1. local `main` is behind-only relative to `origin/main`;
2. the only local dirty paths are the authorized categories above;
3. the incoming diff from local `HEAD` to `origin/main` does not touch `project.godot`, `addons/godot_ai/**`, `addons/game_feel_flow/**`, `addons/saltmire_spark/**`, or any of the 14 translation sidecars;

Codex is explicitly owner-authorized to reconcile the checkout **before reading the active task prompt**.

Use this procedure:

1. record the current pre-sync HEAD short SHA:
   `$preSync = git rev-parse --short=12 HEAD`
2. create a NEW tracked-only stash containing exactly `project.godot`, with a message unique to that pre-sync HEAD:
   `git stash push -m "owner-local-plugin-sync-preserve-$preSync" -- project.godot`
3. do **not** use `-u`; leave all three untracked addon directories and the 14 sidecars untouched;
4. `git fetch origin main`;
5. re-verify that the incoming diff excludes every protected owner-local path;
6. `git merge --ff-only origin/main`;
7. locate and apply only the NEW stash whose exact message contains the recorded `$preSync`; do not apply an older similarly named stash and do not drop any preservation stash;
8. verify the restored dirty state consists only of the intended `project.godot` diff plus the three untouched addon directories and 14 sidecars;
9. continue with the synchronized `AGENTS.md`, `TASKS.md`, and active prompt.

Existing older preservation stashes may remain. Their mere existence is not a blocker and they must not be applied blindly.

This is a standing owner authorization. **Do not stop merely because this exact known owner-local plugin state exists.** Stop only if the dirty set contains anything else, the branch is not behind-only, the incoming diff touches a protected owner-local path, the newly created stash cannot be applied cleanly, or another genuine ambiguity appears.

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
