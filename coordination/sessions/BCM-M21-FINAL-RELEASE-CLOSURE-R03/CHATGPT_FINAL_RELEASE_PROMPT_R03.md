# BCM-M21-006-R03 — Final Beach Cocktails Merge v1 Campaign Release Closure

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

GitHub:
`https://github.com/Sekiph82/Beach-Cocktails-Merge`

Branch:
`main`

## Owner state

BCM-M21-001 is now owner-accepted.

The Sunny Cove Back issue is solved and manually confirmed.

Your job is now the FINAL M21 release-closure pass.

Do not redesign anything.

Do not start M22.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/CHATGPT_SUNNY_COVE_BACK_AUDIT_R09.md`
4. `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/OWNER_M21_001_ACCEPTANCE_R09.md`
5. `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/CHATGPT_FINAL_RELEASE_CRITERIA_R03.md`
6. historical M21 release closure audits/manifests;
7. current project.godot / export presets / save manager.

Root `TASKS.md` is READ-ONLY.

## 1. Safe sync

Use AGENTS safe-sync rules.

Record:
- local HEAD;
- origin/main;
- remote main;
- ahead/behind;
- status;
- tracked/untracked files;
- any stash.

Do not reset/clean/rebase/force.

## 2. Resolve project.godot cleanly

The local tracked project.godot drift has been preserved for many tasks.

Compare it semantically and byte-wise with canonical GitHub main.

If it is only UID/path normalization for the same plugin/autoload authority, restore canonical GitHub bytes and verify plugins/autoloads still load.

If it contains any other owner-authored semantic change:
STOP:
`OWNER_PROJECT_GODOT_RECONCILIATION_REQUIRED`

Final release closure cannot finish with a tracked project.godot diff.

## 3. Close M07 current HUD regression authority

Run current M07 HUD probes.

If old tests are stale against current accepted architecture:
- prove why;
- replace/update only the stale expectation;
- preserve or strengthen coverage;
- do not weaken tolerances just to pass;
- do not restore retired APIs.

Final current HUD authority must be green.

## 4. Close M08 nonzero/crash issue

Run M08 twice consecutively.

Both runs must:
- report PASS;
- exit 0;
- have no access violation / teardown crash.

If not, diagnose and fix the actual process/teardown defect.

Do not wrap or suppress the exit code.

## 5. Full current release regression

Run every check in the locked R03 criteria.

Specifically include:
- R08 Home frontier;
- R09 V05 real input twice;
- R07 page focus;
- R07 node visual;
- full Sunny Cove background;
- M18 stars/replay/cumulative rewards;
- M20 shell;
- fresh-save L1→L100/Tiki unlock;
- accepted gameplay regression;
- performance/stability;
- save/restart persistence;
- assets;
- Godot import/parse/boot;
- git diff --check.

All current mandatory commands must exit 0.

## 6. Freeze owner-approved product

Do not change accepted visuals unless a release-blocking product defect is proven.

Frozen:
- Home;
- World Map;
- Sunny Cove;
- LV/stars/title;
- full Island Map background;
- Sunny Cove Back appearance/position;
- gameplay surfaces;
- To-Go/VIP layout;
- no-timer policy.

The Economy Draft V01 is inactive. Do NOT implement Energy/Gems/Daily Rewards here.

## 7. Export/release manifest

Inspect current export toolchain.

If a real distributable can be built, build it and record SHA-256.

If not, truthfully record unavailable tooling and leave artifact list empty.

Update/create a final R03 release manifest with:
- source SHA;
- Godot version;
- save schema;
- main scene;
- viewport;
- export preset status;
- generated artifacts/hashes;
- known limitations.

## 8. Evidence and log

Evidence:
`coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/evidence/`

Log:
`docs/codex-logs/CODEX_LOG_M21_FINAL_RELEASE_CLOSURE_R03.md`

Do not edit TASKS.md.

## 9. Final repository state

Required:
- tracked working tree clean;
- no unresolved project.godot diff;
- local HEAD = origin/main = remote main;
- ahead/behind 0/0.

Owner-local critique PNGs may remain untracked only if explicitly documented and outside release inputs.

## STOP

Finish exactly:

`AWAITING_GPT_M21_FINAL_RELEASE_AUDIT_R03`

Do not start M22.
