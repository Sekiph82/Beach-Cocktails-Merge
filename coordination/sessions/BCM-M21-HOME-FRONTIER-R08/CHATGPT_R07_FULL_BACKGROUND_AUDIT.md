# BCM-M21-001-R07 + Full Background Follow-up R01 — Independent GPT Audit

Date: 2026-10-06

## VERDICT

**CHANGES_REQUIRED / HOME_FRONTIER_AUTHORITY_MISMATCH**

The R07 Island Map/star work and the follow-up full-background correction are substantially correct, but one owner-locked behavior is still inconsistent:

**Home does not use one authoritative campaign frontier for both its displayed LEVEL and PLAY behavior.**

## Audited range

Authority base:
`5800039af5a0670e446262e6fe5fc4a8ec1bdc98`

Latest audited GitHub main:
`0d99991ba3e1d653a8b843622662da0d06c0286a`

R07 product commit:
`d0df2040b357a8850e9aaa5235ec64add38d9700`

R07 publication receipt:
`79811cec9988efd2dec51b3b74d511695b5e6a80`

Full-background follow-up:
`e7abee759534ebd6bdbd198a95ad0380bf9b6a77`

Follow-up publication receipt:
`0d99991ba3e1d653a8b843622662da0d06c0286a`

Root `TASKS.md` was not modified by Codex.

## PASS findings

### Home plaque text
PASS.

The visible PLAY plaque now uses `LEVEL N` rather than `CONTINUE LEVEL N`.

### Island Map automatic frontier paging
PASS at source/test level.

The restoration state now records `frontier_level_id`. When the frontier advances, stale scroll restoration is cleared and the new frontier page is focused.

The focused probe covers all nine boundaries:
10→11, 20→21, 30→31, 40→41, 50→51, 60→61, 70→71, 80→81, 90→91.

### Sunny Cove title plaque
PASS at source/test level.

The title is aligned to the measured inner plaque aperture and the focused probe enforces <=2 px center error.

### Level node readability
PASS at source/test level.

Nodes now use:
- `LVn` labels;
- three star positions;
- readable font sizes/outlines;
- no visible BEST/SCORE label;
- retained milestone/VIP markers.

### Star mastery contract
PASS.

`GameplaySessionBridge.calculate_stars()` now implements:
- incomplete = 0;
- completion = 1;
- two-star threshold = 2;
- non-VIP three-star threshold = 3;
- VIP-enabled three-star threshold requires VIP completion.

VIP does not gate normal level progression.

### Sunny Cove thresholds
PASS.

The deterministic generator:
`tools/campaign/generate_sunny_cove_star_thresholds.py`

implements the locked formula and produces non-null 2-star/3-star thresholds for all 100 Sunny Cove levels.

The report contains 100 entries and the builder recorded a second idempotent run with no changes.

### Replay persistence
PASS.

`CampaignManager.mark_level_completed()` preserves monotonic best stars and best score.

### Full 720×1280 Sunny Cove background follow-up
PASS at source/test level.

The follow-up changes page height to 1280, background origin to 0, translates the ten authored level landmarks by +178 px, removes the covering sky wash, and verifies page 1/page 10/full source dimensions.

## BLOCKER / MAJOR defect

### Home top LEVEL and PLAY do not share frontier authority

Owner decision before R07:
- Home LEVEL shows the player's latest/current campaign frontier.
- PLAY resumes the player's latest/current campaign level.
- Replaying an older level must not make Home behave as though that replay level is the player's frontier.

Current source does not fully satisfy that.

In `ApplicationShell._refresh_home_values()`:
- top `level` label is populated from `_current_selected_level()`;
- PLAY plaque is populated from `_current_frontier_level()`.

Therefore after selecting/replaying an older unlocked level, the two Home level indicators can disagree.

Example:
- frontier = 11;
- old level 4 selected for replay;
- PLAY plaque = `LEVEL 11`;
- top LEVEL bar = `4`.

The R07 Home probe explicitly preserves this wrong split by asserting that the top Level bar retains the independent current selection.

More importantly, `CampaignNavigationController.continue_campaign()` still launches:

`campaign_manager.selected_level_id`

rather than:

`campaign_manager.get_frontier_level_id(...)`

So after replaying level 4 while frontier is 11, returning Home and pressing PLAY can launch level 4 even though the Home plaque says `LEVEL 11`.

This violates the owner-defined welcome-screen behavior and creates a visible/action mismatch.

## Required correction

Use one truthful frontier authority on Home:

1. top LEVEL number = campaign frontier;
2. PLAY plaque = `LEVEL <frontier>`;
3. Home PLAY launches that same frontier level;
4. selecting an older level from Island Map may still launch that replay immediately;
5. after leaving replay and returning Home, Home remains/returns to the frontier;
6. replay never lowers frontier.

Do not change the accepted R07 Island Map visual, star thresholds, title, node labels, stars, full 720×1280 background, World Map, gameplay, or economy draft.

## DEFECT SEVERITY

BLOCKER: none.
MAJOR: Home display/action frontier mismatch.
MINOR: none independently established.

## Final verdict

**CHANGES_REQUIRED / HOME_FRONTIER_AUTHORITY_MISMATCH**

The Island Map/star/full-background work should be preserved. A bounded R08 remediation is required before owner F5 review.
