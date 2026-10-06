# BCM-M21-001-R08 — Make Home LEVEL + PLAY Use the Same Frontier

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Branch:
`main`

## Why this remediation exists

Independent audit found one remaining functional mismatch.

R07 correctly changed the PLAY plaque to `LEVEL N`, but Home currently has two different level authorities:

- top LEVEL bar uses `selected_level_id`;
- PLAY plaque uses campaign frontier;
- Home PLAY still launches `selected_level_id`.

That means a replay can create this broken state:

```
frontier = 11
selected replay = 4

Home top LEVEL = 4
Home PLAY plaque = LEVEL 11
press PLAY -> launches level 4
```

The owner explicitly decided that Home must represent the player's latest/current campaign frontier.

Fix this and nothing else.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-HOME-FRONTIER-R08/CHATGPT_R07_FULL_BACKGROUND_AUDIT.md`
4. `coordination/sessions/BCM-M21-HOME-FRONTIER-R08/CHATGPT_HOME_FRONTIER_CRITERIA_R08.md`
5. current `ApplicationShell`
6. current `CampaignNavigationController`
7. current `CampaignManager.get_frontier_level_id()`
8. current R07 Home/page/node probes.

Root `TASKS.md` is READ-ONLY.

## 1. Safe sync

Follow AGENTS safe-sync rules.

Preserve owner-local untracked screenshots.

Do not reset/clean/rebase/force.

## 2. One Home authority

Use:

`campaign_manager.get_frontier_level_id(current_island_id)`

as the one Home frontier authority.

### Top LEVEL bar

Change the Home top LEVEL value to the frontier.

Do NOT use `selected_level_id` for the Home LEVEL display.

### PLAY plaque

Keep:

`LEVEL N`

where N = the same frontier.

### PLAY action

Change Home `continue_campaign()` behavior so normal Home PLAY launches the frontier level, not an old selected replay level.

Do not make the label lie.

## 3. Preserve Island Map replay

Do NOT remove the ability to replay old unlocked levels.

When the player explicitly clicks LV4 on Island Map:
- LV4 may launch directly.

But that explicit replay selection must not redefine Home's frontier.

When player later returns Home:
- top LEVEL = frontier;
- plaque = LEVEL frontier;
- pressing PLAY = frontier.

## 4. Do not disturb R07 work

Freeze:
- full Sunny Cove 720×1280 background;
- page height/origin;
- all ten page landmark coordinates;
- automatic 10→11 ... 90→91 page focus;
- Sunny Cove title;
- LV label sizes/positions;
- visible stars;
- no-BEST rule;
- star contract;
- all 100 score thresholds;
- threshold generator/report.

Do not regenerate or tweak any of these unless a test accidentally rewrites evidence; restore incidental rewrites before commit.

## 5. Required real-input proof

Create a focused test using the real ApplicationShell/Home control.

Fixture:

```
frontier = 11
selected replay = 4
```

Prove:

```
top LEVEL == 11
PLAY plaque == "LEVEL 11"
real mouse/touch PLAY -> gameplay level 11
```

Then separately prove explicit Island Map selection/click can still launch level 4.

Return Home and prove Home still uses 11.

Complete frontier 11 and prove Home switches to 12 and PLAY launches 12.

Do not satisfy this only with helper-return assertions; use the actual production navigation path and visible control input.

## 6. Fix stale tests

The existing R07 Home probe currently asserts that the top Level bar retains independent selected-level behavior.

That assertion is now known to contradict owner authority.

Replace it with the correct frontier invariant.

Do not weaken coverage.

## 7. Regression

Run every command in the locked R08 criteria.

All must exit 0.

## 8. Evidence/log/publish

Create:

`coordination/sessions/BCM-M21-HOME-FRONTIER-R08/evidence/`

Create:

`docs/codex-logs/CODEX_LOG_M21_HOME_FRONTIER_R08.md`

Do not edit root `TASKS.md`.

Push to main.

Stop exactly at:

`AWAITING_GPT_M21_HOME_FRONTIER_AUDIT_R08`

Do not start M21-006.
