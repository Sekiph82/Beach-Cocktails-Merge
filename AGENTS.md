# Beach Cocktails Merge — Codex Governance

## Canonical repository

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local workspace currently expected by the owner: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: Godot 4.7.x.

## Mandatory sync-first preflight

Every Codex session must begin from the repository root and run:

```powershell
git status --short --branch
git remote -v
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
```

Never use `reset --hard`, force-push, destructive checkout, automatic rebase, or silent stash to make synchronization succeed.

If local tracked/untracked work exists, preserve it. Reconcile local and remote history without discarding owner work. If safe automatic reconciliation is not possible, stop and document the exact blocker in the Codex log.

Before implementation work, local `HEAD` must be reconciled with `origin/main`. At completion, all intended repository changes must be committed and pushed, and these three values must match:

```powershell
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
```

Unsynchronized local changes are incomplete work.

## Project truth and H!veAI parser contract

The root `TASKS.md` is the only authoritative current project-status tracker for this repository.

H!veAI parser-compatible requirements:

- Keep the `## Project Status` section at the top.
- Keep these exact field labels:
  - `Current Milestone`
  - `Current Sprint`
  - `Current Task`
  - `Current Task Status`
  - `Next Task/Action`
  - `Required Actor`
  - `Tracking Repository`
  - `Tracking Branch`
- Task rows use exactly one of:
  - `- [x] TASK-ID — Title.` validated complete
  - `- [~] TASK-ID — Title.` active/in progress
  - `- [ ] TASK-ID — Title.` planned/pending
  - `- [!] TASK-ID — Title.` blocked
- Do not create a competing `.hiveai/TASKS.md`, STATE, HANDOFF, PROJECT, RULES, or EVENTS tracker.
- Codex must not independently mark root tracker tasks complete. Tracker transitions and milestone closure are owned by the independent ChatGPT audit cycle unless the active prompt explicitly authorizes a bounded tracker edit.

## Session start

At the start of every milestone or remediation:

1. Complete the sync-first preflight.
2. Read `AGENTS.md` and root `TASKS.md` from the synchronized checkout.
3. Read the authoritative prompt under `docs/prompts/`.
4. Inspect current implementation and asset paths before editing.
5. Create a new immutable Codex execution log under `docs/codex-logs/`.
6. Work only on the active task/milestone.
7. Commit and push all intended changes before claiming completion.

## Builder log rule

Codex logs are execution claims and evidence indexes, not acceptance proof.

Each log must include:

- prompt/work item identifier and version
- start HEAD and end HEAD
- branch and remote
- sync-preflight results
- files changed
- implementation summary
- commands/tests run and exact results
- Godot parse/run evidence when applicable
- manual checks performed and any checks not performed
- known limitations
- final commit SHA
- proof that local HEAD, `origin/main`, and remote main match

Historical logs are immutable. Corrections go into a new versioned log.

## Strict independent audit standard

Milestone closure requires an independent audit. A Codex statement such as COMPLETE, tests passing, or successful compilation is never sufficient by itself.

Every audit must contain:

1. `VERDICT` — `PASS`, `CONDITIONAL`, or `FAIL`.
2. `CONTRACT RECOVERY` — actual requirements from prompt, TASKS, codebase and acceptance criteria.
3. `BRANCH / HEAD / DIFF SCOPE`.
4. `ACCEPTANCE CRITERIA MATRIX` — each criterion as `PASS`, `PARTIAL`, `FAIL`, or `UNVERIFIED`.
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
17. `REGRESSION RISK` — `LOW`, `MEDIUM`, or `HIGH` with rationale.
18. `AUDIT CONFIDENCE` — `LOW`, `MEDIUM`, or `HIGH` with rationale.
19. `FINAL VERDICT`.
20. `REQUIRED REMEDIATION` when not unconditional PASS.

Audit rules:

- Treat Codex logs as claims to verify.
- Prefer source, config, committed assets, Git history and runtime evidence.
- Passing tests do not override a direct specification violation.
- Missing evidence remains `UNVERIFIED`; never fabricate PASS.
- Manual acceptance not actually performed remains pending/unverified.
- Previously closed behavior must be regression-checked when touched.
- Do not progress to the next milestone after FAIL or blocking CONDITIONAL findings until bounded remediation is audited closed.

## Godot and gameplay preservation

The owner has accepted the v6.7 gameplay feel as the baseline to preserve during the v7 visual integration unless an explicit later prompt changes it. In particular, do not casually retune physics while doing visual work.

Known accepted gameplay baseline from owner direction includes:

- initial shot speed: `700 px/s`
- deceleration: `180 px/s²`
- no artificial cruise/minimum-speed assist
- a newly launched drink is immediately replaced by the next launchable drink; moving drinks do not block subsequent launches
- stopped drinks remain physically movable when hit later
- merge result preserves meaningful forward/lateral momentum
- no backward rebound toward the player after collisions
- To-Go target levels span L6-L12
- existing matching L6-L12 drinks already on the table are eligible for later To-Go orders
- only the To-Go bonus is awarded when a previously scored stored drink is later delivered
- Level 12 remains on the table when not currently ordered and can be delivered by a later L12 order

## Visual master and asset policy

The owner-approved v7 direction is a bright, polished tropical beach-bar casual mobile merge game with a slightly perspective-tilted long wooden table.

Expected asset structure:

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

Do not regenerate or redesign owner-approved assets during integration unless the active prompt explicitly requests it. Use Godot nodes and dynamic labels/sprites over blank UI panel areas rather than baking changing score/order data into static images.

## Safety

- Preserve owner-created assets and project files.
- Never commit secrets, local caches, `.godot/`, build output, editor state, save files, or machine-specific temporary files.
- Do not replace functional gameplay logic merely to simplify integration.
- Keep implementation changes bounded to the active milestone.
