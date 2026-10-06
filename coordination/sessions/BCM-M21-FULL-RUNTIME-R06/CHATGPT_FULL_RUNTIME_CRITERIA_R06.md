# BCM-M21-001-R06 — Approved Home Full Integration & Godot Runtime Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `OWNER_HOME_ACCEPTANCE_R06.md`
- accepted Home HEAD `d265865f67770be34e3c45f83ea07141feb3c5ca`

## A. Scope

This is integration/runtime-readiness only.

The accepted Home visual is frozen.

Allowed:
- synchronize local Desktop checkout to current GitHub main safely;
- reconcile the known tracked `project.godot` local drift if it is only machine-local UID/path churn;
- fix only defects that prevent normal ApplicationShell startup or navigation;
- run current campaign/Home/World Map/Island Map/gameplay smoke probes;
- launch the real project in normal Godot GUI/F5 for owner testing;
- publish a runtime-readiness log.

Forbidden:
- Home visual changes;
- World Map visual changes;
- Island Map visual changes;
- gameplay/HUD redesign;
- To-Go visual changes;
- economy design changes;
- save reset;
- progression reset;
- clearing owner user:// data;
- starting BCM-M21-006;
- editing root `TASKS.md` by Codex.

## B. Canonical Home freeze

Before and after execution verify:
- `HOME_TARGET_LAYOUT_R04.json` is unchanged from accepted main unless a nonvisual serialization-only correction is explicitly required;
- all PNG files under `assets/ui_assets/screens/home/` are byte-identical;
- Home production uses the current accepted layout and assets;
- no old R02 Home visual is visible;
- TARGET PNG is not used as the production runtime background;
- PLAY / WORLD MAP / SETTINGS remain real distinct controls.

Record SHA-256 for:
- Home layout JSON;
- all Home PNGs;
- `application_shell.gd`.

## C. Local/GitHub synchronization

Start from:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Record:
- local HEAD;
- origin/main;
- remote main;
- ahead/behind;
- `git status --short`;
- full `git diff -- project.godot`.

Known issue:
a local tracked `project.godot` modification has been repeatedly preserved.

Reconcile it now.

If the only local difference is a Godot-generated UID or equivalent machine-local representation of the same canonical addon/autoload path:
- restore the canonical portable GitHub version;
- verify plugin/autoload behavior still works.

If the diff contains any other owner-authored semantic change:
STOP:
`OWNER_PROJECT_GODOT_RECONCILIATION_REQUIRED`

Final required Git state:
- `git status --short` empty;
- local HEAD = origin/main = remote main;
- ahead/behind 0/0.

## D. Production startup authority

Verify canonical `project.godot` still has:

`run/main_scene="res://scenes/campaign/ApplicationShellScene.tscn"`

Normal F5 must start through the actual ApplicationShell.

Do not launch a test harness as the owner's game.

Do not replace the main scene.

Preserve current owner save/progression/onboarding data. Do not wipe `user://`.

## E. Home runtime contract

At normal runtime:
- accepted Home is the welcome/menu screen after any already-required onboarding state;
- current Level number comes from campaign state;
- `CONTINUE LEVEL N` uses the same real level N;
- coin value comes from canonical economy;
- current presentation-only Energy/Gems behavior remains unchanged;
- PLAY continues the current valid campaign level;
- WORLD MAP opens the production World Map;
- SETTINGS opens Settings;
- returning from Settings returns safely to Home;
- no duplicate ApplicationShell, map, or gameplay instance is created.

## F. Full latest-game smoke path

Run/verify this real production route without test shortcuts:

`Home → World Map → Sunny Cove Island Map → current playable Level → Pause/Resume → gameplay → back/result route as currently available → Island Map → World Map → Home`

Minimum acceptance:
- Home renders;
- World Map renders current owner-approved composition;
- Sunny Cove opens from visible island input;
- Island Map renders current owner-approved node/header system;
- level launches;
- owner-approved R04 gameplay surface loads;
- +25% To-Go/VIP panel remains;
- no timer/+Time/TIME UP appears;
- Pause/Resume works;
- navigation back to campaign/Home does not duplicate screens.

Do not modify product logic merely to make the smoke path easier.

## G. Automated regression set

All commands must exit 0 unless explicitly marked historical/deferred in existing governance:

- focused latest Home probe;
- M20 ApplicationShell;
- M21 V05 real mouse/touch World Map entry;
- M13 Island Map;
- M14 gameplay session bridge;
- current R04 gameplay-surface authority validation;
- asset catalog rebuild/validator;
- Godot editor import/parse;
- normal application boot smoke;
- `git diff --check`.

R03's M07 historical-regression reconciliation and M08 post-PASS crash are still open technical-debt findings. Do not silently claim them closed in R06. Record them as deferred carry-forward items unless this task must touch their code for a startup blocker.

## H. Normal Godot owner test

After all automated checks and synchronization:

1. launch the repository in the installed Godot 4.7.2 editor in normal GUI mode;
2. run the project via normal F5/main-scene flow;
3. ensure the visible running game is the real current project, not a probe;
4. leave the editor/project in the state needed for the owner to test manually if the environment supports persistent GUI processes.

If the execution environment cannot keep the GUI process open:
- do not fake success;
- report the exact executable/command used and the limitation;
- still confirm normal non-headless main-scene boot.

## I. Evidence

Create:
`coordination/sessions/BCM-M21-FULL-RUNTIME-R06/evidence/`

Required:
- synchronization report;
- project.godot reconciliation report;
- Home freeze hash report;
- latest production startup screenshot if capture tooling supports it;
- Home→World Map screenshot;
- Island Map screenshot;
- gameplay screenshot;
- runtime smoke report.

Do not generate substitute artwork.

## J. Publication

Create:
`docs/codex-logs/CODEX_LOG_M21_FULL_RUNTIME_R06.md`

Log:
- starting/final SHA;
- project.godot reconciliation result;
- exact Home freeze hashes;
- automated test results + exits;
- full smoke-path result;
- normal Godot GUI/F5 launch result;
- whether Godot was left open for owner review;
- remaining deferred M07/M08 findings;
- confirmation `TASKS.md` unchanged;
- final clean/synchronized Git proof.

Push only justified integration/evidence/log changes to `main`.

Final marker exactly:

`AWAITING_OWNER_FULL_GAME_RUNTIME_REVIEW_R06`

STOP. Do not start BCM-M21-006.
