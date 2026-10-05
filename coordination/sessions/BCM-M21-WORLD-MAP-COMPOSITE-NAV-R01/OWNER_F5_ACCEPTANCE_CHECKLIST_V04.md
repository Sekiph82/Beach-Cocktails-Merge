# BCM-M21 — Owner F5 Acceptance Checklist V04

Date: 2026-10-05

Status: **OWNER_RUNTIME_REVIEW_REQUIRED**

Technical authority:
`CHATGPT_WORLD_MAP_PRODUCTION_AUDIT_V05.md` — TECHNICAL_AUDITED_PASS / OWNER_F5_ACCEPTANCE_REQUIRED.

Run the normal production project with F5. Review the real game, not a test screenshot.

## 1. App shell / Main Menu

PASS if:
- game opens normally;
- Main Menu is clean;
- PLAY/CONTINUE works.

## 2. New production World Map visual

PASS if the real World Map matches the owner-approved V04 direction:
- owner V02 ocean background;
- title/frame in the sky above the ocean;
- Sunny Cove begins upper-right;
- all ten islands are visible as separate island bodies;
- island sizes are intentionally different;
- placement is irregular, not same row/column;
- route, clouds and boat look correct;
- no clipping/obvious overlap;
- Back and compass are unobstructed.

## 3. Sunny Cove real click/touch

PASS if:
- clicking/tapping the visible Sunny Cove island itself opens Sunny Cove Island Map;
- there is no displaced/invisible click target;
- one click/tap causes one navigation;
- Island Map shows the Sunny Cove 100-level path.

## 4. Island Map presentation

PASS if:
- Sunny Cove Island Map art/layout is the previously accepted version;
- level path and nodes are readable;
- current/open/locked/completed feedback looks correct;
- Back returns to World Map.

## 5. Gameplay launch

From Sunny Cove, open a playable level.

PASS if:
- owner-approved R04 gameplay surface appears;
- current logo, To-Go Orders, Best Score, Score and Next remain correct;
- no rejected legacy/split gameplay background returns.

## 6. Gameplay input / no-timer rule

PASS if:
- mouse drag/release remains usable;
- touch remains usable if available;
- no countdown, TIME UP, +Time or gameplay time limit appears;
- Pause/Resume still works.

## 7. To-Go / VIP / HUD

PASS if:
- To-Go Orders work;
- VIP behavior remains optional/correct where applicable;
- HUD does not block gameplay.

## 8. Result flow

Complete a level.

PASS if:
- result screen appears cleanly and above gameplay;
- no timer wording appears;
- Retry / Next / Island Map actions work;
- gameplay drinks clear appropriately at WIN.

## 9. Full navigation round trip

PASS if this full route works without duplication or stale overlays:

Main Menu → World Map → Sunny Cove Island Map → Level → Result → Island Map → World Map → Main Menu

## 10. Persistence / restart

PASS if:
- restart preserves campaign/settings/unlocks/save truth;
- reopening campaign returns to a coherent current island/level state;
- no test-only progression bypass appears.

## Final owner marker

If 1-10 all PASS:

`OWNER_F5_ACCEPTED_V04`

If any item fails:

`OWNER_F5_REJECTED_V04`

Report:
- failing item number(s);
- what was observed;
- screenshot/video if useful.

Do not start BCM-M21-006 until ChatGPT records the owner decision in root TASKS.md.
