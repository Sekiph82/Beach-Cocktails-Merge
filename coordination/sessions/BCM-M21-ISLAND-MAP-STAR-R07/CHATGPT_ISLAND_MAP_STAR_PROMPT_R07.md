# BCM-M21-001-R07 — Fix Home Label + Island Map Page UX + Stars

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Branch:
`main`

## OWNER RUNTIME RESULT

R06 is NOT finally accepted.

The owner accepts the Home composition, but runtime review found bounded UX issues:

1. `CONTINUE LEVEL 10` does not fit.
2. Island Map makes the player manually scroll to the next ten-level map page.
3. SUNNY COVE title is not centered inside its frame.
4. LV labels are nearly unreadable.
5. BEST/SCORE text should not appear on Island Map nodes.
6. Stars must be clearly visible.
7. Current Sunny Cove data makes 3 stars impossible because score thresholds are null.
8. Owner approved the corrected 1/2/3-star mastery contract.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/OWNER_ISLAND_MAP_STAR_RULING_R07.md`
4. `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/CHATGPT_ISLAND_MAP_STAR_CRITERIA_R07.md`
5. current `scripts/campaign/island_map_controller.gd`
6. current `scripts/campaign/level_button.gd`
7. current `scripts/campaign/gameplay_session_bridge.gd`
8. current `scripts/campaign/campaign_navigation_controller.gd`
9. current `data/campaign/levels/sunny_cove.json`
10. current M18 star/replay tests and audits.

Root `TASKS.md` is READ-ONLY.

## 1. Safe sync

Use AGENTS safe-sync rules.

Preserve owner-local files.

Do not reset/clean/rebase/force.

Record local/origin/remote SHA and status before implementation.

## 2. Home text only

Change the PLAY plaque dynamic label from:

`CONTINUE LEVEL N`

to exactly:

`LEVEL N`

Do not hardcode 10.

Use the current/latest campaign frontier authority.

Do not move or resize any owner-approved Home art.

Do not change the top LEVEL bar.

## 3. Fix frontier vs selected-level semantics

The Home label and automatic Island Map focus must represent the player's true campaign frontier, not merely an old replay selection.

Inspect current `selected_level_id`, `highest_unlocked_level`, current island, and replay behavior.

Use one truthful frontier resolver.

Required:
- if frontier is 11 and player replays 4, Home remains `LEVEL 11`;
- first-time completion of frontier 10 advances frontier to 11;
- old replay never moves frontier backward.

Do not fork campaign progression authority.

## 4. Automatic 10-page navigation

Current Island Map already knows page_size/page_height and stores restoration scroll.

Fix the stale-restoration behavior.

When first-time completion advances frontier across a page boundary, returning to Island Map must override old-page restoration and focus the new frontier page.

Explicitly prove all:

```
10 -> 11
20 -> 21
30 -> 31
40 -> 41
50 -> 51
60 -> 61
70 -> 71
80 -> 81
90 -> 91
```

No manual scroll may be required to see the new level.

Keep manual browsing/scrolling available.

Do NOT flatten all 100 levels into one background.

Do NOT create 10 separate IslandMap controllers.

## 5. SUNNY COVE title

Use the existing plaque.

Move/resize only the title Label as needed so its visual center sits in the plaque's visible inner center.

Prefer making the title label use the plaque rect/inner rect with true horizontal + vertical centering rather than another magic y-offset.

Capture proof.

## 6. Level node redesign within current node

Do NOT redraw node PNGs.

Use existing state art.

Change overlays:

### Level
`L1` -> `LV1`
`L10` -> `LV10`
`L100` -> `LV100`

Make it materially larger/readable.

Use strong outline/shadow.

### Stars

Always show 3 positions:

`☆☆☆`
`★☆☆`
`★★☆`
`★★★`

Saved best stars determine the filled count.

Make stars large enough to read in the real 720×1280 Island Map.

### Remove score

Remove/hide:
`BEST 1234`

Do not replace it with SCORE.

Do not show best score anywhere on Island Map level nodes.

Best score may remain stored internally for mastery/replay logic.

Milestone and VIP indicators remain.

## 7. Implement owner-approved star contract

Update `GameplaySessionBridge.calculate_stars` exactly:

- incomplete -> 0
- completed + score < two threshold -> 1
- completed + score >= two threshold but < three -> 2
- non-VIP completed + score >= three -> 3
- VIP level completed + score >= three + VIP complete -> 3
- VIP level completed + score >= three but VIP NOT complete -> 2

VIP must NEVER block normal win/unlock.

## 8. Populate all Sunny Cove thresholds deterministically

Current threshold values are null.

Do not hand-type arbitrary values.

Create a generator.

Use owner formula:

```
construct_score(3) = 0
construct_score(L) = 2 * construct_score(L-1) + Drink.merge_score(L)
```

For every mandatory normal order:

```
entry_base =
quantity *
(
    construct_score(cocktail_level)
    + Drink.order_reward(cocktail_level)
)
```

Then:

```
mastery_base = sum(entry_base)
two_stars   = CEIL_TO_50(mastery_base * 1.10)
three_stars = CEIL_TO_50(mastery_base * 1.35)
```

Floor only if baseline is zero:
```
two_stars = 100
three_stars = 150
```

VIP is NOT included in baseline.

VIP remains an additional condition for 3 stars only.

Write thresholds into canonical Sunny Cove level data.

Generate the locked JSON report.

Run generator twice; second run must be byte/diff idempotent.

## 9. Preserve replay/save behavior

Existing best stars and best score are monotonic.

Do not reset current owner saves.

Do not migrate/reset schema merely for this task.

Old 1/2-star records remain valid.

Replaying may upgrade to 3 stars under the new contract.

Worse replay never downgrades.

## 10. Preserve cumulative rewards

Sunny Cove maximum remains 300 cumulative stars.

Existing 30/60/.../300 cumulative-star reward semantics remain.

Do not change reward amounts or booster payloads.

Do not touch the separate Economy Draft V01.

## 11. Evidence

Create:

`coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/evidence/`

Capture the exact evidence required by criteria.

The 10→11, 20→21 and 90→91 screenshots must show the actual production Island Map after progression advancement, not a mockup.

## 12. Tests

Create focused R07 probes for:
- Home `LEVEL N`;
- frontier vs replay selection;
- all 9 ten-page transitions;
- node label/stars/no-BEST state;
- exact star truth table;
- threshold generator all 100 levels;
- threshold idempotency.

Run all locked regressions.

## 13. No unrelated work

Do not:
- implement Energy/Coin/Gem economy draft;
- implement Daily Rewards;
- change Home art;
- change World Map art;
- change gameplay surfaces;
- reintroduce timer;
- change To-Go panel geometry;
- start M21-006.

## 14. Publish

Create:

`docs/codex-logs/CODEX_LOG_M21_ISLAND_MAP_STAR_R07.md`

Push implementation/evidence/log to main.

Do not edit root `TASKS.md`.

Return links to:
- latest Island Map screenshot;
- 10→11 screenshot;
- threshold JSON report.

Finish exactly:

`AWAITING_OWNER_ISLAND_MAP_STAR_REVIEW_R07`

STOP.
