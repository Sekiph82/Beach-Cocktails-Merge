# BCM-M22 MASTER V01 — Presentation Architecture Milestone

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

GitHub:
`https://github.com/Sekiph82/Beach-Cocktails-Merge`

Branch:
`main`

Execute BCM-M22-001 → BCM-M22-002 → BCM-M22-003 continuously in this one master run.

Do not wait for a new prompt between children unless a true STOP condition below is reached.

# 0 — FIRST ACTION: NON-DESTRUCTIVE LOCAL ↔ GITHUB SYNC

Before reading implementation details or changing files:

1. `cd "C:\Users\sekip\Desktop\Beach Cocktails - Merge"`
2. record:
   - `git status --short --branch`
   - `git rev-parse HEAD`
   - `git rev-parse origin/main`
   - `git ls-remote origin refs/heads/main`
   - `git stash list`
3. `git fetch origin main`
4. compute ahead/behind.
5. inventory every tracked modification and untracked file.
6. compare local changed paths with incoming `HEAD..origin/main`.
7. preserve all owner-local work non-destructively.
8. If local is behind-only and incoming paths do not collide, fast-forward with:
   `git merge --ff-only origin/main`
9. If owner-local tracked work must be temporarily protected, use a named tracked-only stash and reapply it. Never silently drop it.
10. Do NOT:
   - hard reset
   - clean
   - force checkout owner files
   - rebase automatically
   - force push
   - delete untracked owner evidence
11. Verify after sync:
   - local canonical source contains latest `AGENTS.md`, `TASKS.md`, this master package;
   - local/origin/remote relationship is understood and recorded.
12. If there is a real path collision or ambiguous owner-local semantic change, STOP:
   `OWNER_SYNC_RECONCILIATION_REQUIRED_M22`

Only after safe sync, read:
- AGENTS.md
- root TASKS.md
- this master prompt
- master audit criteria
- all three child prompts + criteria
- exact installed plugin source.

# 1 — GOVERNANCE

- Root TASKS.md is read-only to Codex.
- ChatGPT is the sole TASKS.md lifecycle writer.
- Do not create a second roadmap/dashboard/session tracker.
- Child logs are evidence, not acceptance.
- Commit/push after each child.
- Before moving to the next child, fetch and verify local HEAD = origin/main = remote main and ahead/behind 0/0.
- Preserve historical stashes and owner-local evidence.
- Use commit-eligible `.txt/.json/.md` evidence. Do not rely on ignored `.log` files only.
- Do not start M23.

# 2 — FROZEN OWNER-ACCEPTED PRODUCT

Do not alter the accepted visual/gameplay product unless a M22 architecture blocker proves unavoidable:
- Home
- World Map
- Sunny Cove Island Map
- Back/navigation
- LV/star presentation
- R04 gameplay surfaces
- HUD/To-Go/VIP accepted geometry
- untimed campaign
- physics/collision/merge/scoring
- campaign progression/save
- Economy Draft V01

M22 is architecture/policy only.

# 3 — EXACT INSTALLED PLUGIN BASELINE

ChatGPT inspected current GitHub bytes before this handoff. Verify locally after sync.

Game Feel Flow:
- plugin version 1.0.0
- canonical autoload name `GameFeelFlow`
- exact core source `addons/game_feel_flow/core/game_feel_flow.gd`
- 31 registered effect names in current implementation
- 15 built-in combo names
- APIs include `play`, `play_combo`, `play_global`, `stop`, `stop_all`, registry/query methods
- stock combos commonly contain shake/flash; several contain freeze-frame

Saltmire Spark:
- plugin version 1.0.0
- canonical autoload name `Spark`
- `burst(position, opts)`, `at(node, opts)`, `clear()`
- presets: spark, hit, explode, pickup, dust, confetti

Current project.godot has both autoloads and both editor plugins enabled.

Installed source overrides every statement above if local synced bytes differ. If they differ, document exact truth and continue only if compatible; otherwise STOP for GPT review.

# 4 — PRESENTATION-ONLY CONSTITUTION

Gameplay/campaign truth remains authoritative outside presentation.

Forbidden always:
- GameFeelFlow impulse
- velocity
- freeze_frame
- time_scale
- full-screen camera_flash
- gameplay/root physics transforms

Camera/screen shake is OFF by default and is NOT enabled in M22.

Never transform RigidBody2D/collision roots/table/rails/camera authority.

Presentation target examples only:
- Drink/Visual
- CocktailSprite
- HUD visual panels
- result visual controls
- map entry visuals
- LevelButton visual children

Plugin failure/missing API/missing singleton = presentation no-op.

# 5 — CHILD EXECUTION

## CHILD 1 — BCM-M22-001
Read:
- `BCM-M22-001_PROMPT_V01.md`
- `BCM-M22-001_AUDIT_CRITERIA_V01.md`

Execute fully.
Publish evidence + child log.
Run child regression.
Commit/push.
Verify clean ref parity.

If PASS, continue immediately.

## CHILD 2 — BCM-M22-002
Read:
- `BCM-M22-002_PROMPT_V01.md`
- `BCM-M22-002_AUDIT_CRITERIA_V01.md`

Execute fully.
Publish evidence + child log.
Run child regression.
Commit/push.
Verify clean ref parity.

If PASS, continue immediately.

## CHILD 3 — BCM-M22-003
Read:
- `BCM-M22-003_PROMPT_V01.md`
- `BCM-M22-003_AUDIT_CRITERIA_V01.md`

Execute fully.
Publish owner-review effect-language matrix + evidence + child log.
Run child regression.
Commit/push.
Verify clean ref parity.

# 6 — MASTER FINAL REGRESSION

After all three children:

1. run the complete master criteria;
2. run current M21 critical navigation/gameplay/save regression subset;
3. run direct plugin-call scan proving only the sole bridge calls plugin APIs;
4. run plugin present/absent/failure parity;
5. run semantic exact-one/dedupe/listener lifecycle tests;
6. run policy/forbidden/budget validators;
7. run Godot editor parse/import and headless boot;
8. run `git diff --check`;
9. prove no visible production effect/particle was activated by M22;
10. prove no gameplay/campaign/save output changed because of presentation architecture.

# 7 — MASTER LOG

Create:
`docs/codex-logs/CODEX_LOG_M22_MASTER_V01.md`

Record:
- sync preflight;
- exact installed plugin inventory;
- each child commit SHA;
- every command + exit;
- source/evidence paths;
- final parity;
- known limitations;
- explicit statement that M23 was not started.

# 8 — FINAL REPOSITORY STATE

Required:
- tracked tree clean;
- owner-local untracked evidence preserved;
- no unresolved temporary stash required to reproduce canonical working tree;
- local HEAD = origin/main = remote main;
- ahead/behind 0/0.

Do not edit TASKS.md.

Do not claim M22 complete or owner matrix acceptance.

STOP exactly at:

`AWAITING_GPT_M22_MILESTONE_AUDIT_V01`
