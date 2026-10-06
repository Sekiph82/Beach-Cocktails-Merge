# BCM-M21-001-R07 — Locked Audit Criteria: Island Map UX + Star Mastery

Status: **LOCKED BEFORE EXECUTION**

Authority:
`OWNER_ISLAND_MAP_STAR_RULING_R07.md`

## A. Scope

Allowed product changes:
- Home dynamic PLAY plaque text only;
- Island Map automatic frontier-page focus;
- Island title alignment;
- LevelButton visual labels/stars/removal of best-score text;
- star calculation semantics;
- Sunny Cove score-star threshold data plus deterministic generator/validator;
- focused tests/evidence.

Root `TASKS.md` remains read-only to Codex.

## B. Home label

PASS:
- visible label is exactly `LEVEL N`;
- no visible `CONTINUE`;
- N is dynamic and uses current/latest campaign frontier;
- replaying an older level does not regress Home N;
- accepted Home PNG/layout geometry is otherwise unchanged.

## C. Automatic ten-level page focus

For every boundary:
10→11, 20→21, 30→31, 40→41, 50→51, 60→61, 70→71, 80→81, 90→91:

After first-time completion and return to Island Map:
- the new frontier level is visible without user scroll;
- the correct ten-level page is at/near its page top;
- focus level equals the newly unlocked frontier;
- stale restoration scroll from the prior page may not override the new frontier page.

Replays:
- returning from an old replay must not lower frontier;
- existing reasonable restoration behavior within the same frontier page may be preserved.

## D. Sunny Cove plaque title

PASS:
- title visual center lies within 2 px of the visible plaque inner-area center at 720×1280 reference;
- title is fully inside frame;
- no clipping;
- no new plaque asset.

## E. Level node readability

At 720×1280:
- level label uses `LV%d`;
- font size is at least 24 reference px unless font metrics require a demonstrably equivalent visual size;
- strong outline/shadow gives readable contrast against node art;
- all 3 star positions are visible;
- star font/visual height is at least 20 reference px;
- score/BEST label is absent/hidden and consumes no visible space;
- milestone/VIP markers remain;
- no input regression.

Required evidence includes close crops of:
- completed 1-star;
- completed 2-star;
- completed 3-star;
- current/open;
- locked;
- milestone;
- VIP node.

## F. Star semantic truth table

Mandatory test matrix:

| completed | score vs thresholds | VIP enabled | VIP complete | stars |
|---|---|---|---|---|
| false | any | any | any | 0 |
| true | below 2-star | false | n/a | 1 |
| true | >= 2-star and < 3-star | false | n/a | 2 |
| true | >= 3-star | false | n/a | 3 |
| true | below 2-star | true | false/true | 1 |
| true | >= 2-star and < 3-star | true | false/true | 2 |
| true | >= 3-star | true | false | 2 |
| true | >= 3-star | true | true | 3 |

No star result may gate next-level unlock.

## G. Threshold generator

Create one canonical generator/validator, for example:
`tools/campaign/generate_sunny_cove_star_thresholds.gd`

It must:
- load canonical `data/drinks.json`;
- load canonical Sunny Cove level data;
- compute `construct_score`, `mastery_base`, two-star and three-star thresholds exactly per owner ruling;
- update/validate all 100 levels deterministically;
- be idempotent;
- produce a machine-readable report.

Required report:
`coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/SUNNY_COVE_STAR_THRESHOLDS_R07.json`

For each level record:
- level_id;
- normal orders;
- mastery_base;
- two_stars;
- three_stars;
- VIP enabled;
- formula version.

PASS:
- all 100 entries;
- no null thresholds;
- no negative/zero threshold;
- three > two;
- second generator run produces zero diff.

## H. Persistence / replay

PASS:
- current save schema remains compatible;
- old stored stars 0–3 load unchanged;
- improved replay upgrades stars/best score;
- worse replay does not downgrade;
- cumulative-star totals use stored best stars;
- existing cumulative-star reward claim idempotency remains green.

## I. Visual evidence

Create:
`coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/evidence/`

Required:
1. Home with `LEVEL 10`;
2. Sunny Cove header plaque;
3. levels 1–10 page showing readable LV/stars and no BEST;
4. automatic 10→11 page result;
5. automatic 20→21 page result;
6. automatic 90→91 page result;
7. node-state comparison crop;
8. 3-star non-VIP node;
9. 3-star VIP-complete node.

## J. Regression matrix

Run with exit 0:
- new R07 focused Home label probe;
- new R07 Island Map page-focus probe covering all nine boundaries;
- new R07 node visual/state probe;
- M18 star contract probe;
- M18 replay persistence probe;
- M18 cumulative-star reward/integration probes;
- M13 Island Map probe;
- M14 GameplaySessionBridge probe;
- M20 ApplicationShell probe;
- M21 V05 World Map mouse/touch entry;
- current R04 gameplay surface validator;
- asset validator;
- Godot import/parse/boot;
- `git diff --check`.

Do not reopen deferred M07/M08 technical debt unless an actual R07 blocker requires it.

## K. Publication

Create:
`docs/codex-logs/CODEX_LOG_M21_ISLAND_MAP_STAR_R07.md`

Record exact commands/exits, threshold report, evidence, changed files, and final synchronization.

Do not edit root `TASKS.md`.

Final marker exactly:

`AWAITING_OWNER_ISLAND_MAP_STAR_REVIEW_R07`
