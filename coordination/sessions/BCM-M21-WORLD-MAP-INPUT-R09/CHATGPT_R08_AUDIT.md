# BCM-M21-001-R08 — Independent GPT Audit

Date: 2026-10-06

## VERDICT

**R08_SCOPE_PASS / PROJECT_REGRESSION_GATE_FAIL**

The R08 Home-frontier defect is fixed correctly and independently supported by source/test evidence.

However, the locked R08 regression matrix required the production V05 World Map real-input probe to exit 0. It exits 1 with three navigation/input failures, and the same failures reproduce on the clean pre-R08 baseline. Therefore R08 did not cause them, but the project cannot receive an overall technical PASS while this production navigation gate remains red.

## Audited range

R08 authority HEAD before implementation:
`cda89c59706051ba6f3bfde1dccdd7845f268836`

R08 implementation/evidence commit:
`ff1ab6d7414fe16aaf904c45e961a07f0024e1ad`

R08 publication receipt / audited main:
`dd6f65f3f101ef370d966c09a9fb57f632de3132`

Codex did not modify root `TASKS.md`.

## R08 functional findings

### 1. Home top LEVEL
PASS.

`ApplicationShell._refresh_home_values()` now resolves one `frontier_level` and uses it for the Home top LEVEL field.

The prior selected-replay resolver was removed.

### 2. PLAY plaque
PASS.

The same frontier value drives the visible `LEVEL N` PLAY plaque.

### 3. Home PLAY action
PASS.

`CampaignNavigationController.continue_campaign()` now resolves:

`campaign_manager.get_frontier_level_id(current_island_id)`

and launches that level.

It no longer launches stale `selected_level_id` from an old replay.

### 4. Explicit old-level replay
PASS.

Island Map selection still routes through `_on_level_selected()` → `_launch_selected_level(island_id, level_id)`.

The R08 focused production-path probe demonstrates:
- frontier 11;
- old replay selection 4;
- Home LEVEL 11;
- plaque LEVEL 11;
- real Home mouse input launches 11;
- real World Map → Island Map path opens Sunny Cove;
- real Island Map click launches replay 4;
- returning Home preserves frontier 11;
- Home touch PLAY launches 11;
- completing 11 advances frontier to 12;
- Home shows/launches 12.

### 5. R07 Island Map/star/full-background freeze
PASS.

The R08 commit range contains no R07 Island Map/star/background product changes.

### 6. Other locked checks
PASS per retained command logs:
- R07 Home label;
- Home R04;
- R07 Island Map page focus;
- R07 node visual;
- M18 star contract;
- M18 replay persistence;
- M20 ApplicationShell;
- full Sunny Cove 720×1280 background follow-up;
- asset validator 373/373;
- Godot editor parse;
- headless boot;
- git diff check.

## Remaining project regression

The exact locked V05 command:

`godot_console.exe --path . --script res://tests/m21_world_map_production_v05_probe.gd`

fails with:

1. `real Island Map Back returns to one visible World Map`
2. `real InputEventScreenTouch enters Sunny Cove Island Map exactly once`
3. `real World Map Back button returns to Main Menu`

The same three failures reproduce on clean pre-R08 baseline `cda89c59706051ba6f3bfde1dccdd7845f268836`.

Therefore:
- this is **not an R08 regression**;
- it is still an unresolved production-navigation/test-authority regression;
- the locked regression gate is not green;
- owner F5 acceptance should not be requested yet.

## Required next action

Run one bounded R09 diagnosis/closure task.

R09 must determine, separately for all three failed assertions, whether the defect is:
- production input/navigation behavior;
- stale V05 probe sequencing/coordinate assumptions;
- touch emulation/test harness behavior;
- overlay/mouse-filter/z-order interception;
- signal-count bookkeeping mismatch.

R09 must not simply delete the assertions or label them inherited.

If production is wrong, fix production minimally.

If the V05 probe is stale, update it only after proving current production behavior with equal-or-stronger real pointer/touch coverage.

## Final verdict

**R08 implementation: PASS**

**BCM-M21 technical gate: CHANGES_REQUIRED due unresolved V05 World Map real-input regression**
