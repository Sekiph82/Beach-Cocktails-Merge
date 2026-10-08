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

Historical logs are immutable during ordinary implementation work. Corrections go in a new versioned log.

**Owner-authorized repository-hygiene exception:** when root `TASKS.md` explicitly activates a cleanup/hygiene task and the matching owner ruling + locked cleanup criteria authorize deletion, Codex may delete superseded historical logs/prompts/audits/evidence/derived assets that are explicitly classified as obsolete by that cleanup. This exception does not permit deletion of the active/current acceptance chain, canonical tracker, current contracts, current owner-approved assets, or any file still needed by runtime/tests/future planned work.

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

## Active M21 World Map owner-first visual gate — 2026-10-05

The owner requires the proposed World Map composition to be visually reviewed **before** any production implementation.

The owner-selected background is a specific 720×1280 PNG that must be placed at:

`assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v01.png`

Before owner approval:
- Codex may read production World Map code/data/assets;
- Codex may create preview-only evidence and layout metadata;
- Codex may commit the exact owner background asset if supplied locally;
- Codex MUST NOT modify production World Map scripts, scenes, data, map positions, hitboxes, navigation, or production tests;
- Codex MUST NOT start BCM-M21-006;
- root `TASKS.md` remains read-only.

The active preview package is:
- `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_OWNER_PREVIEW_CRITERIA_V02.md`
- `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_OWNER_PREVIEW_PROMPT_V02.md`

Required preview stop marker:
`AWAITING_OWNER_WORLD_MAP_VISUAL_APPROVAL_V02`

The owner has now explicitly issued `OWNER_WORLD_MAP_VISUAL_APPROVED_V02` for the V04 preview recorded in:
`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/OWNER_WORLD_MAP_VISUAL_ACCEPTANCE_V04.md`.

The approved V04 preview is the frozen visual target for production integration. Do not redesign it during implementation unless a newer owner ruling supersedes it.

The active locked production package is now:
- `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_PRODUCTION_CRITERIA_V05.md`
- `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_PRODUCTION_PROMPT_V05.md`

Required builder stop marker:
`AWAITING_GPT_M21_WORLD_MAP_PRODUCTION_AUDIT_V05`

The older direct-implementation R01 package remains superseded and must not be executed as-is.

## Active M21 World Map composition authority — 2026-10-05

The owner has rejected the baked ten-island World Map composition.

The previous architecture in which `world_map_background.png` visually baked the ten islands while `IslandEntry` supplied separate invisible/displaced interaction markers is **superseded** for the active M21 remediation.

The new World Map authority is a composited runtime map:

- a new clean 720×1280 ocean/background base with no baked island bodies;
- the ten existing per-island transparent PNGs under `assets/ui_assets/campaign/world_map/`:
  - `sunny_cove.png`
  - `tiki_island.png`
  - `azure_bay.png`
  - `coconut_beach.png`
  - `sunset_island.png`
  - `party_beach.png`
  - `frozen_paradise.png`
  - `volcano_bay.png`
  - `billionaire_island.png`
  - `final_island.png`;
- each island's visible art, state treatment, and pointer/touch target must share the same authoritative layout transform and center;
- no invisible hotspot may be spatially separated from its island art;
- map positions may be recalibrated during this explicit remediation;
- the current island ordering, unlock rules, ids, save/progression truth, and campaign semantics must remain unchanged.

The current header/back/compass treatment may be retained if it fits the new map cleanly. Decorative clouds/boat/routes may be reused only if they do not obscure islands, labels, hit targets, or navigation.

Do not delete the old `world_map_background.png` until the replacement map has passed owner visual/runtime acceptance. After acceptance it may be retired in a later explicit cleanup.

### Sunny Cove navigation blocker

The owner also reports that Sunny Cove does not open from the World Map in the current F5 build.

The active remediation must prove the complete real-input chain:

`visible Sunny Cove island art → IslandEntry/Button press → WorldMapController.select_island("sunny_cove") → island_map_requested("sunny_cove") → CampaignNavigationController.show_island_map("sunny_cove") → IslandMapController.configure_island(...) → visible Sunny Cove Island Map`.

A direct method call is insufficient. Mouse/touch interaction must be tested through the real production UI.

## Canonical addon/dependency authority — 2026-10-05

The owner has explicitly decided that the canonical GitHub repository must contain the complete project source needed to reproduce the local project.

The following addon directories are no longer intended to remain local-only after the one-time full-sync promotion task:
- `addons/godot_ai/`
- `addons/game_feel_flow/`
- `addons/saltmire_spark/`

During the one-time full-sync promotion:
- preserve these local directories through the preliminary safe sync;
- inspect them for secrets, machine-specific caches, demo/test clutter, generated binaries, and license files;
- commit the actual addon source/config/assets required by the project;
- preserve required license/attribution files;
- do not commit generated caches, editor state, logs, temp files, or secrets;
- commit the corresponding intentional `project.godot` plugin/autoload configuration needed for the tracked addons to work;
- after publication, these addon directories become normal tracked canonical repository dependencies and must no longer appear as untracked owner-local exceptions.

The owner's desired steady state is:
- local canonical checkout contains all intended project source;
- GitHub `main` contains the same intended project source;
- `git status --short` is empty after synchronization;
- local `HEAD = origin/main = remote main`;
- ahead/behind = `0/0`.

Generated/reproducible files are not "missing project source" and must remain ignored rather than committed. This includes:
- `.godot/`;
- `*.import`;
- generated `*.translation` sidecars;
- Python `__pycache__/` and `*.pyc`;
- logs, temp/build/export output, editor state, and machine-specific files.

### One-time tracked owner-file reconciliation

For the full-sync promotion, Codex is explicitly authorized to inspect and reconcile the current local diffs in:
- `project.godot`;
- `scenes/main.tscn`;
- `scenes/campaign/WorldMapScene.tscn`.

Do not discard these files merely to obtain a clean status.

For each:
1. inspect the exact local-vs-origin diff;
2. determine whether the local diff is intentional current project state or generated/stale residue;
3. validate parse/runtime implications;
4. commit intentional current state;
5. remove/revert only changes proven generated/stale and document why.

The goal is not to force-clean Git. The goal is to make GitHub accurately contain the current intended project.

## Owner-authorized R04 repository cleanup authority — 2026-10-04

The owner has explicitly approved the current R04 gameplay backgrounds/playable areas for all ten islands and explicitly authorizes a dedicated repository cleanup task to remove superseded, unused, orphaned, and no-longer-planned files.

This section removes any **repository-level** prohibition on deleting files during that cleanup task. It does not override external tool/runtime safety policy. If a shell deletion command is rejected by the execution environment, use another ordinary file-delete/edit mechanism exposed and permitted by that environment; do not attempt to bypass platform safeguards. If no allowed deletion mechanism exists, stop with the exact deletion manifest and blocker.

### Protected current authority — never delete in cleanup

For each of the ten island folders under `assets/ui_assets/campaign/islands/<island>/`, preserve:
- `gameplay_surface_v07_r04.png` — owner-approved frozen R04 source;
- `gameplay_surface.png` — byte-identical runtime authority;
- `playable_geometry_r04.json` — current gameplay geometry/profile;
- `complete_badge.png`;
- `map_background.png`;
- `map_title.png`;
- `theme_badge.png`;
- `world_icon.png`.

Also preserve unless a newer owner ruling explicitly replaces them:
- current L01-L12 cocktail assets;
- current logo, To-Go Orders, Best Score, Score, Next, progression, held-marker/danger-line assets actually used by current runtime;
- current World Map and Island Map assets actually referenced by data/runtime;
- `data/campaign/islands.json`, current level/campaign/economy/save data;
- `docs/ui-assets/GAMEPLAY_SURFACE_CONTRACT_V07_R04.md`;
- active R04 runtime/validation tests and the code that loads/validates the R04 surface/profile pair;
- during the preliminary safe sync for the one-time canonical promotion, preserve local `project.godot`, `addons/godot_ai/`, `addons/game_feel_flow/`, `addons/saltmire_spark/`, and generated translation sidecars; after promotion, the three addon directories and intentional project.godot configuration are canonical tracked repository state, while generated translation sidecars remain ignored.

### Explicitly deletable after proof

During the authorized cleanup, Codex may delete tracked or untracked files that are proven obsolete by repository-wide reference analysis and validation, including:
- orphaned or legacy Godot `*.import` sidecars; these are ignored/generated metadata and may be removed when current sources remain intact and Godot clean-import/boot validation passes;
- PNG/JPG/WebP/SVG assets belonging only to rejected/superseded gameplay-table/background/split-layer/candidate pipelines;
- derived review/contact-sheet/debug/calibration images for superseded visual iterations that are no longer part of the current R04 acceptance chain;
- obsolete provenance/calibration/measurement/manifests JSON files and stale asset-catalog entries;
- retired table masks, table layers, overlays, shadows, fit proofs, and V1/V2 visual-pipeline artifacts if no current runtime/test/future task still depends on them;
- stale test fixtures and tests whose only purpose is asserting deleted/superseded paths, provided they are replaced by current R04 tests where equivalent coverage is still required;
- obsolete helper scripts used only to generate deleted superseded assets/evidence;
- obsolete historical coordination/evidence files when they are not part of the retained current acceptance chain and their removal does not leave an active contract/test/TASKS reference broken;
- any other file with zero current runtime/config/test/current-contract/future-roadmap references and no owner-stated future use.

### Required cleanup method

1. Build a machine-readable inventory of candidate deletions with path, type, size, why obsolete, all references found, replacement/current authority, and disposition.
2. Classify each path as `KEEP`, `DELETE`, or `REVIEW`. Default ambiguity to `KEEP`.
3. Search **source, scenes, data, tests, tools, current contracts, current prompts/criteria, and root TASKS.md** before deleting a tracked path.
4. Historical text mentioning a retired filename does not by itself make the retired binary/derived evidence a current dependency, but active TASKS/contracts/tests must not be left with broken required references.
5. For old tests/rules that conflict with R04, update or retire them in the same cleanup commit set so current truth has one coherent contract.
6. Rebuild current asset manifests/dimension catalogs/reports after deletions so they list only retained current assets.
7. Run focused R04 surface/profile validation, clean Godot import/parse/boot, gameplay/campaign regressions, and `git diff --check` before handoff.
8. Verify all ten owner-approved R04 surface/profile families still hash/load correctly and all current planned-use images remain present.
9. Never edit root `TASKS.md`; ChatGPT remains its sole writer.

### Current owner-deleted legacy background

`assets/environment/game_board_background.png` is retired by the R04 gameplay-surface authority and current Island Map theme architecture. Gameplay renders each island's `gameplay_surface.png`; Island Map backgrounds resolve from `theme.island_map_background`. The old generic image and top-level `map_background` field are not runtime dependencies.

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

### Standing owner-local safe-sync exception

Owner-local work in the canonical Desktop checkout MUST be preserved and, by itself, MUST NOT block a safe behind-only synchronization when incoming remote changes are path-disjoint.

Known owner-local paths may include, but are not limited to:

- tracked `project.godot`;
- tracked `scenes/main.tscn`;
- tracked `scenes/campaign/WorldMapScene.tscn`;
- during the one-time addon promotion only, untracked `addons/godot_ai/`, `addons/game_feel_flow/`, and `addons/saltmire_spark/`;
- generated untracked `.translation` sidecars and Python cache files.

After the one-time addon promotion, the three addon directories are expected to be tracked and must not remain recurring untracked exceptions.

The rule is intentionally generic so future legitimate owner-local tracked edits do not require one-off authorization every time.

When ALL of the following are true:

1. local `main` is behind-only relative to `origin/main`;
2. there are no local commits ahead of `origin/main`;
3. every current dirty path is inventoried before sync;
4. the incoming diff from local `HEAD` to `origin/main` touches **none** of the dirty local paths;
5. no merge/rebase conflict is predicted;

Codex is explicitly owner-authorized to synchronize **before reading the active task prompt** while preserving all current local work.

Use this exact safe procedure:

1. record:
   - current HEAD;
   - `git status --short`;
   - the complete list of modified tracked paths;
   - the complete list of untracked paths.
2. create a NEW tracked-only stash containing **all currently modified tracked owner-local paths**:
   - use an explicit path list;
   - do not use `-u`;
   - do not stash untracked files;
   - name the stash `owner-local-safe-sync-<preSyncShortSha>`.
3. leave all untracked files/directories untouched.
4. `git fetch origin main`.
5. re-check behind-only status and compare incoming changed paths against the full dirty-path inventory.
6. if incoming changes remain path-disjoint, run:
   `git merge --ff-only origin/main`
7. locate only the NEW stash by its exact unique message and apply it without dropping it.
8. verify:
   - every tracked owner-local diff is restored;
   - every untracked owner-local path is still present and untouched;
   - no conflict occurred;
   - no owner-local path was staged or committed.
9. continue with synchronized `AGENTS.md`, `TASKS.md`, and the active prompt.

Do **not** stop merely because a new owner-local tracked file such as `scenes/main.tscn` appears, provided the incoming diff does not touch that path and all conditions above are satisfied.

Stop only when:
- local history is not behind-only;
- incoming remote changes touch any dirty local path;
- a stash/apply conflict occurs;
- an unexpected path cannot be safely classified as owner-local work;
- or another genuine ambiguity remains after the path-disjoint comparison.

Existing older preservation stashes may remain. Their existence is not a blocker and they must never be applied blindly.


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

## Active M21 owner-F5 polish regression closure — 2026-10-06

The R02 product visuals are implemented and frozen for remediation. Independent audit is:
`coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/CHATGPT_OWNER_F5_VISUAL_POLISH_AUDIT_R02.md`
with verdict:
`CHANGES_REQUIRED / REGRESSION_AND_CLEAN_STATE_CLOSURE`.

The active bounded remediation package is:
- `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R03/CHATGPT_OWNER_F5_VISUAL_POLISH_CRITERIA_R03.md`
- `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R03/CHATGPT_OWNER_F5_VISUAL_POLISH_PROMPT_R03.md`

R03 may reconcile stale regression assumptions, a real M08 teardown crash, and the local `project.godot` canonical-state drift. It must not redesign the accepted R02 Home, Island Map, World Map, To-Go presentation, or R04 gameplay geometry unless a reproduced regression proves a minimal production correction is necessary.

Required stop marker:
`AWAITING_GPT_M21_OWNER_F5_POLISH_AUDIT_R03`

BCM-M21-006 remains blocked.

## Active M21 exact Home target authority — 2026-10-06

The owner has supplied a complete Home PNG set locally under:
`assets/ui_assets/screens/home/`

and an exact reference:
`TARGET beach cocktails merge home.png`.

For the active R04 task, that TARGET is pixel-authoritative. Codex must compose the production Home from the supplied separate PNGs at the same relative positions/sizes. No redesign, creative adjustment, asset regeneration, renaming, recoloring, cropping, alternate layout, or substitute visual is authorized.

Active package:
- `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/OWNER_HOME_EXACT_TARGET_RULING_R04.md`
- `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/CHATGPT_HOME_EXACT_TARGET_CRITERIA_R04.md`
- `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/CHATGPT_HOME_EXACT_TARGET_PROMPT_R04.md`

The prior R03 regression/clean-state closure package is deferred before execution because its Home baseline is superseded. Its findings (M07 regression authority, M08 post-PASS crash, and project.godot clean-state drift) remain open and must be reissued after R04 owner visual acceptance.

Required stop marker:
`AWAITING_OWNER_HOME_EXACT_TARGET_APPROVAL_R04`

BCM-M21-006 remains blocked.

## Active M21 final Home bar-fit correction — 2026-10-06

The owner has identified one remaining Home visual issue after R04/V03: the coin value does not fit cleanly inside the current Coin bar.

Active bounded R05 authority:
- `coordination/sessions/BCM-M21-HOME-BAR-FIT-R05/OWNER_HOME_BAR_FIT_RULING_R05.md`
- `coordination/sessions/BCM-M21-HOME-BAR-FIT-R05/CHATGPT_HOME_BAR_FIT_CRITERIA_R05.md`
- `coordination/sessions/BCM-M21-HOME-BAR-FIT-R05/CHATGPT_HOME_BAR_FIT_PROMPT_R05.md`

R05 may change only:
- Energy horizontal width and its plus x-position;
- Coin horizontal width and its plus x-position;
- Coin value text bounds needed to fit the widened bar.

All other Home geometry/art and navigation behavior are frozen.

Reference-space values:
- Energy rect → `(229.0, 15.0, 136.125, 81.0)`;
- Energy plus center x → `347.625`;
- Coin rect → `(444.0, 14.0, 203.4375, 81.0)`;
- Coin plus center x → `629.6875`.

Required stop marker:
`AWAITING_OWNER_HOME_BAR_FIT_APPROVAL_R05`

Deferred M07/M08/project.godot technical closure remains open after Home approval.

## Active M21 full runtime integration authority — 2026-10-06

The owner has explicitly accepted the current Home at:
`d265865f67770be34e3c45f83ea07141feb3c5ca`.

The Home visual/layout is frozen. No further Home movement, resizing, asset replacement, text-geometry change, or stylistic reinterpretation is authorized in R06.

Active R06 package:
- `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/OWNER_HOME_ACCEPTANCE_R06.md`
- `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/CHATGPT_FULL_RUNTIME_CRITERIA_R06.md`
- `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/CHATGPT_FULL_RUNTIME_PROMPT_R06.md`

R06 is integration/runtime-readiness only:
- reconcile the known local tracked `project.godot` drift if it is proven machine-local UID/path normalization only;
- preserve current owner save/progression;
- verify normal ApplicationShell startup and latest Home/World Map/Island Map/gameplay flow;
- open the actual Godot 4.7.2 project and run the normal main-scene/F5 flow for owner testing;
- finish with local/GitHub clean and synchronized.

Deferred M07/M08 findings remain open and must not be falsely closed by this task.

Required stop marker:
`AWAITING_OWNER_FULL_GAME_RUNTIME_REVIEW_R06`

BCM-M21-006 remains blocked.

## Active M21 Island Map + star mastery owner remediation — 2026-10-06

R06 reached owner runtime review. The Home composition is accepted, but the owner returned bounded changes required for:
- PLAY plaque text fit;
- automatic Island Map frontier-page focus;
- island-title placement;
- level-node readability;
- removal of Island Map BEST/SCORE text;
- complete 1/2/3-star mastery semantics.

Active R07 package:
- `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/OWNER_ISLAND_MAP_STAR_RULING_R07.md`
- `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/CHATGPT_ISLAND_MAP_STAR_CRITERIA_R07.md`
- `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/CHATGPT_ISLAND_MAP_STAR_PROMPT_R07.md`

Owner-locked behavior:
- Home PLAY plaque = `LEVEL N`, dynamic frontier level;
- 10→11 through 90→91 automatically shows/focuses the new ten-level Island Map page;
- `SUNNY COVE` centered inside existing plaque;
- node labels = readable `LVn`;
- exactly three visible star positions;
- no visible BEST/SCORE on Island Map nodes;
- 1 star = normal completion;
- 2 stars = 2-star score threshold;
- 3 stars = 3-star score threshold, plus VIP completion only when that level has VIP;
- stars never gate progression;
- replay never downgrades stored stars/best score;
- existing cumulative-star reward semantics remain.

Sunny Cove thresholds must be generated deterministically using the exact formula in the owner ruling and must be non-null for all 100 levels.

The Economy Draft V01 remains inactive and MUST NOT be implemented in R07.

Required stop marker:
`AWAITING_OWNER_ISLAND_MAP_STAR_REVIEW_R07`

BCM-M21-006 remains blocked.

## Active M21 Home frontier authority remediation — 2026-10-06

Independent audit of R07 + Sunny Cove full-background follow-up:
`coordination/sessions/BCM-M21-HOME-FRONTIER-R08/CHATGPT_R07_FULL_BACKGROUND_AUDIT.md`

Verdict:
`CHANGES_REQUIRED / HOME_FRONTIER_AUTHORITY_MISMATCH`

R07 Island Map/star/full-background work is frozen and should be preserved.

The only active defect:
- Home top LEVEL currently derives from selected replay level;
- Home PLAY plaque derives from campaign frontier;
- Home PLAY still launches selected replay level.

This can produce a false Home state such as:
`top LEVEL 4 / plaque LEVEL 11 / PLAY launches 4`.

Active R08 package:
- `coordination/sessions/BCM-M21-HOME-FRONTIER-R08/CHATGPT_HOME_FRONTIER_CRITERIA_R08.md`
- `coordination/sessions/BCM-M21-HOME-FRONTIER-R08/CHATGPT_HOME_FRONTIER_PROMPT_R08.md`

Owner-locked correction:
- Home top LEVEL = campaign frontier;
- Home plaque = `LEVEL <frontier>`;
- Home PLAY launches that same frontier;
- explicit old-level replay from Island Map remains allowed;
- replay never redefines Home frontier.

Do not modify R07 Island Map visuals, 720×1280 full background, landmark coordinates, title, LV labels, stars, threshold generator/data, World Map, gameplay surfaces, or inactive economy draft.

Required stop marker:
`AWAITING_GPT_M21_HOME_FRONTIER_AUDIT_R08`

BCM-M21-006 remains blocked.

## Active M21 World Map real-input regression closure — 2026-10-06

Independent R08 audit:
`coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/CHATGPT_R08_AUDIT.md`

Verdict:
`R08_SCOPE_PASS / PROJECT_REGRESSION_GATE_FAIL`

R08 Home frontier behavior is frozen and accepted technically:
- Home top LEVEL = campaign frontier;
- PLAY plaque = LEVEL frontier;
- Home PLAY launches frontier;
- explicit old-level replay from Island Map remains supported.

Remaining inherited V05 failures:
1. Island Map Back does not satisfy the production probe's return-to-World-Map assertion.
2. ScreenTouch Sunny Cove entry does not satisfy the exactly-once assertion.
3. World Map Back does not satisfy the return-to-Main-Menu assertion.

The same failures reproduce on clean pre-R08 baseline, so R08 must not be reverted.

Active R09 package:
- `coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/CHATGPT_WORLD_MAP_INPUT_CRITERIA_R09.md`
- `coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/CHATGPT_WORLD_MAP_INPUT_PROMPT_R09.md`

R09 must classify each failure as PRODUCT_DEFECT, STALE_PROBE, or HARNESS_LIMITATION with evidence, then close it with equal-or-stronger real pointer/touch coverage. Final V05 must pass twice consecutively.

Do not modify accepted Home geometry/art, R07 Island Map visual/mastery/full-background work, gameplay, or inactive Economy Draft V01.

Required stop marker:
`AWAITING_GPT_M21_WORLD_MAP_INPUT_AUDIT_R09`

BCM-M21-006 remains blocked.

## M21 Sunny Cove Back R09 independent audit — 2026-10-06

Independent audit:
`coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/CHATGPT_SUNNY_COVE_BACK_AUDIT_R09.md`

Verdict:
`TECHNICAL_AUDITED_PASS / OWNER_F5_CONFIRMATION_REQUIRED`

Verified:
- production root cause was real pointer interception by the scrollable LevelNodes layer;
- the existing Back button is now in the Island Map root input layer at z=10 with unchanged visible rect/style;
- mouse Back returns Sunny Cove → World Map exactly once;
- touch Sunny Cove entry and touch Back both pass;
- World Map → Home remains working;
- V05 passes twice consecutively;
- R08 Home frontier behavior and accepted R07 visuals/mastery/full-background work remain frozen.

Current owner gate:
`Home → World Map → Sunny Cove → top-left Back → World Map`

Owner acceptance marker:
`OWNER_SUNNY_COVE_BACK_ACCEPTED_R09`

BCM-M21-006 remains blocked until this fresh owner runtime confirmation and later closure work.

## Active BCM-M21 final release closure R03 — 2026-10-06

Owner acceptance of BCM-M21-001:
`coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/OWNER_M21_001_ACCEPTANCE_R09.md`

BCM-M21-001 is complete.

Active task:
`BCM-M21-006`

Active release closure package:
- `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/CHATGPT_FINAL_RELEASE_CRITERIA_R03.md`
- `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/CHATGPT_FINAL_RELEASE_PROMPT_R03.md`

R03 must:
- preserve all accepted current visuals and gameplay semantics;
- reconcile the lingering tracked project.godot local drift;
- close current M07 HUD regression authority without weakening tests;
- close the prior M08 PASS-marker/nonzero-process crash with two clean exit-0 runs;
- rerun current R08/R09/R07/M18/M20/progression/performance/save/release checks;
- verify export/release configuration truthfully;
- finish with tracked repository state clean and local/origin/remote parity.

Economy Draft V01 remains inactive and must not be implemented during release closure.

Required stop marker:
`AWAITING_GPT_M21_FINAL_RELEASE_AUDIT_R03`

Do not start M22 until BCM-M21-006 passes independent audit and ChatGPT records M21 complete.

## Active BCM-M21 final release evidence closure R04 — 2026-10-06

Independent R03 audit:
`coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/CHATGPT_FINAL_RELEASE_AUDIT_R03.md`

Verdict:
`CHANGES_REQUIRED / EVIDENCE_PUBLICATION_CLOSURE_ONLY`

R03 production/test-semantic work is frozen. The only active blocker is publication of mandatory final-run evidence that remained local because `*.log` is ignored.

Active R04 package:
- `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/CHATGPT_FINAL_RELEASE_EVIDENCE_CRITERIA_R04.md`
- `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/CHATGPT_FINAL_RELEASE_EVIDENCE_PROMPT_R04.md`

R04 must:
- publish exact R03 logs as commit-eligible .txt evidence, or rerun only missing commands;
- publish M08 x2 and R09 V05 x2 hard-gate evidence;
- publish all remaining locked current regression evidence;
- reconcile the conflicting project.godot SHA-256 claims;
- distinguish product baseline / R03 implementation / R03 handoff SHAs in the final manifest;
- publish final Git cleanliness/ref proof.

No production runtime, accepted visual, gameplay, test tolerance/assertion, campaign/save/economy semantic, or M22 work is authorized.

Required stop marker:
`AWAITING_GPT_M21_FINAL_RELEASE_AUDIT_R04`

M22 remains blocked until R04 passes independent audit.

## BCM-M21 final closure / M22 gate — 2026-10-08

Final M21 independent audit:
`coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/CHATGPT_FINAL_RELEASE_AUDIT_R04.md`

Verdict:
`AUDITED_PASS / BCM-M21 COMPLETE`

Closed:
- BCM-M21-001 owner runtime/navigation acceptance;
- BCM-M21-006 final technical/evidence/release closure;
- M07 current HUD regression authority;
- M08 clean process exit twice;
- R09 real mouse/touch navigation twice;
- R07/R08/M18/M20 current campaign regressions;
- fresh L1→L100 progression and Tiki unlock;
- host performance/stability and save/restart evidence;
- canonical project.godot reconciliation;
- final release evidence publication.

Recorded limitations remain truthful:
- no export_presets.cfg;
- no distributable/signed package;
- physical-device performance unverified;
- native install/signing unverified.

Next canonical milestone:
`BCM-M22`

Next canonical task:
`BCM-M22-001 — Lock exact installed plugin APIs, packaging, and graceful no-plugin behavior.`

Before any M22 production effect work, ChatGPT must publish the locked M22-001 prompt and audit criteria. Exact installed GameFeelFlow/Saltmire Spark repository bytes override historical/public planning shorthand.

Economy Draft V01 remains inactive unless the owner explicitly activates it.

## Active BCM-M22 MASTER V01 — 2026-10-08

BCM-M21 is complete. M22 is now authorized as one continuous master batch.

Master authority:
- `coordination/sessions/BCM-M22-MASTER-V01/CHATGPT_M22_MASTER_PROMPT_V01.md`
- `coordination/sessions/BCM-M22-MASTER-V01/CHATGPT_M22_MASTER_AUDIT_CRITERIA_V01.md`
- matching child prompt/criteria files for BCM-M22-001, BCM-M22-002, BCM-M22-003.

Execution sequence:
1. BCM-M22-001 — exact installed plugin contract/fallback;
2. BCM-M22-002 — FeedbackService semantic bus + sole plugin bridge;
3. BCM-M22-003 — effect language / FULL-REDUCED / restriction-budget policy.

The first action of the master is mandatory non-destructive synchronization of:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`
with GitHub `main`, preserving all owner-local work.

Exact plugin baseline already inspected on current main:
- Game Feel Flow 1.0.0, autoload GameFeelFlow;
- Saltmire Spark 1.0.0, autoload Spark;
- installed source in `addons/game_feel_flow` and `addons/saltmire_spark`.

M22 constitution:
- presentation-only;
- sole bridge is the only production plugin caller;
- plugin absence/failure = no-op;
- no GFF impulse/velocity/freeze_frame/time_scale;
- full-screen flash forbidden;
- camera/screen shake disabled;
- no physics/collision/root/camera authority transforms;
- no production effects/particles activated during M22;
- M21 owner-accepted product frozen;
- Economy Draft V01 inactive.

Codex must commit/push each child and continue automatically to the next child, but must never edit root TASKS.md.

Required final builder marker:
`AWAITING_GPT_M22_MILESTONE_AUDIT_V01`

M23 is blocked until independent M22 audit PASS and owner approval of the effect-language matrix.

