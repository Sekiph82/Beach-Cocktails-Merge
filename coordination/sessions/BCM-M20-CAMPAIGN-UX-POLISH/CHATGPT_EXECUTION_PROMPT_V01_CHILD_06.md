# BCM-M20-006 — Migration / Backward Compatibility Closure

Execute only after Child 05 publication equality.

Close M20 by proving upgrade safety for existing users.

Verify:
- current campaign save round-trip;
- v1 migration;
- M15/M18 reward/star/replay fields survive;
- legacy best score migration;
- corrupt-primary/valid-backup recovery;
- future unsupported schema stays non-destructive;
- settings/onboarding files are independent from campaign save;
- missing/corrupt settings never reset campaign progress.

Run the complete M20 focused suite and locked M10-M19/M18/protected regressions.

Populate/publish `CODEX_LOG_V01_CHILD_06.md`, then master `CODEX_LOG_V01.md`. Finish exactly at `AWAITING_M20_AUDIT_V01`. Do not start M21.
