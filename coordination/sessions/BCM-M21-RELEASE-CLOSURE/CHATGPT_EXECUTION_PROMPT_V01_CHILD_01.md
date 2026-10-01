# BCM-M21-001 — Mobile Layout & Touch QA

Execute only Child 01.

Exercise production UI at the canonical 720×1280 viewport and at least one representative taller phone/window presentation.

Cover:
- onboarding;
- Main Menu;
- Settings;
- World Map;
- 100-level Island Map;
- gameplay;
- pause;
- locked feedback;
- WIN;
- LOSE.

Add production-path touch/input QA for PLAY, island selection, level selection/scroll, Settings, pause/resume, and result actions.

Generate/update immutable QA captures/report. Do not redesign UI unless a concrete clipping/unreachable-control defect requires a narrow fix.

Carry the M20 observation that terminal overlays may cover stale underlying HUD values; determine only whether it causes a user-visible release problem, and do not alter gameplay authority.

Populate/publish `CODEX_LOG_V01_CHILD_01.md`; prove equality before Child 02.
