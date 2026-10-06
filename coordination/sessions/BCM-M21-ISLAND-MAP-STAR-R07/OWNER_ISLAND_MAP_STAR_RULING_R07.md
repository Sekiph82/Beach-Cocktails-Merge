# BCM-M21-001-R07 — Owner Runtime Ruling: Home Label, Island Map UX, and Star Mastery

Date: 2026-10-06

Status: **OWNER_RUNTIME_CHANGES_REQUIRED_R07**

This ruling records the owner's runtime review after R06 and supersedes the R06 owner-review wait.

## 1. Home PLAY plaque

The owner reports that `CONTINUE LEVEL 10` does not fit cleanly.

Replace the dynamic PLAY-plaque text:

`CONTINUE LEVEL N`

with:

`LEVEL N`

Only the word `CONTINUE` is removed.

The level number remains fully dynamic and continues to use the current/latest campaign frontier authority.

Do not move or resize the accepted Home art/layout unless the shorter label requires only a text-box-safe internal adjustment. The accepted Home visual remains frozen otherwise.

## 2. Island Map automatic page focus

Sunny Cove uses ten-level map/background pages.

The player must NOT be required to manually scroll down to find the newly unlocked frontier after completing the last level on the visible page.

Required behavior:

- after first-time completion of Level 10, returning to Island Map automatically shows the 11–20 page and focuses Level 11;
- 20→21 shows 21–30;
- 30→31 shows 31–40;
- 40→41 shows 41–50;
- 50→51 shows 51–60;
- 60→61 shows 61–70;
- 70→71 shows 71–80;
- 80→81 shows 81–90;
- 90→91 shows 91–100.

The same principle applies whenever campaign progression advances to a new ten-level page.

The player may still manually browse/scroll old pages. The requirement is that the current/new frontier is automatically brought on screen when progression advances.

Replay of an old level must not incorrectly move the campaign frontier backward.

## 3. Sunny Cove title plaque

The `SUNNY COVE` title currently sits outside/too high relative to its decorative frame.

The island title must be centered inside the visible inner area of the existing island-name plaque.

Do not replace or redraw the plaque art.

## 4. Island level-node readability

Current `L1`, `L2`, etc. and BEST/SCORE text are too small and visually lost.

New node contract:

- level label format is `LV1`, `LV2`, ..., `LV100`;
- level text must be materially larger and high contrast;
- exactly three star positions are always visible;
- completed levels display stored earned stars, e.g. `★★☆`;
- uncompleted/open/locked levels display `☆☆☆` unless an existing locked visual rule requires the stars to remain visible but visually subdued;
- remove BEST/SCORE text from Island Map level nodes entirely;
- do not show `BEST 1234` below nodes;
- milestone chest marker remains separate;
- VIP marker remains separate;
- node input/click area remains usable.

## 5. Owner-approved star mastery contract

The owner approves this semantic rule:

- **0 stars**: level not completed / failed.
- **1 star**: normal mandatory level objective completed.
- **2 stars**: normal objective completed AND the 2-star score threshold is reached.
- **3 stars, non-VIP level**: normal objective completed AND the 3-star score threshold is reached.
- **3 stars, VIP-enabled level**: normal objective completed AND the 3-star score threshold is reached AND the optional VIP objective is completed.

Important:
- VIP is NOT required for level progression.
- Stars are mastery only, not an unlock gate.
- Completing a level still unlocks progression even with only one star.
- Replays may improve stored stars/best score.
- A worse replay may never reduce stored stars or best score.
- Existing cumulative-star reward semantics remain intact.

## 6. Sunny Cove threshold population

Current Sunny Cove data has null 2-star/3-star thresholds, so 3 stars are currently impossible.

R07 must populate deterministic, non-null thresholds for all 100 Sunny Cove levels using the current production scoring model.

Use this owner-authorized deterministic calibration model:

### 6.1 Minimum favorable-spawn mastery baseline

Current gameplay legally spawns levels 1–3. For threshold calibration use level 3 as the most favorable direct spawn baseline.

Define a no-combo construction score:

- `construct_score(3) = 0`
- for target level `L > 3`:
  `construct_score(L) = 2 * construct_score(L-1) + Drink.merge_score(L)`

For each normal order entry:
`normal_entry_base = quantity * (construct_score(cocktail_level) + Drink.order_reward(cocktail_level))`

`mastery_base = sum(normal_entry_base for all mandatory normal orders)`

VIP reward/score is NOT included in `mastery_base`; VIP is a separate 3-star condition on VIP-enabled levels.

### 6.2 Thresholds

Round UP to the next multiple of 50:

`two_stars = ceil_to_50(mastery_base * 1.10)`

`three_stars = ceil_to_50(mastery_base * 1.35)`

Hard invariants:
- `two_stars > 0`
- `three_stars > two_stars`
- every Sunny Cove level 1–100 has non-null integer values;
- threshold generation is deterministic from current canonical `data/drinks.json` and level orders;
- no hand-edited per-level arbitrary numbers.

Create a generator/validator so the values are reproducible.

If a future level contains only targets <=3 or produces a zero baseline, use a documented minimum floor of:
- two stars = 100
- three stars = 150.

## 7. Existing records

No destructive save reset.

Existing stored stars remain valid.

On replay, the new star calculation may upgrade a prior 1/2-star record to a higher value. It may never downgrade historical progress.

## 8. Frozen boundaries

Do not change:
- accepted Home art other than label text;
- World Map composition;
- gameplay surface geometry;
- physics;
- To-Go/VIP HUD geometry;
- timer policy (campaign remains untimed);
- economy draft;
- Energy/Coin/Gem systems;
- cumulative-star reward amounts;
- level unlock rules.

Required builder stop marker:

`AWAITING_OWNER_ISLAND_MAP_STAR_REVIEW_R07`
