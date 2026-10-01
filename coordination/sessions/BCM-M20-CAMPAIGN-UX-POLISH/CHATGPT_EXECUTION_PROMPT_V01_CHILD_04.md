# BCM-M20-004 — Pause / App Lifecycle

Execute only after Child 03 publication equality.

Build a minimal in-game pause control/overlay on top of the existing GameplaySessionBridge authority.

Actions:
- Resume;
- Island Map.

Prove:
- manual pause freezes timer;
- background freezes timer;
- background/resume does not auto-resume a manually paused session;
- background-paused session resumes correctly on application resume;
- terminal session cannot resume;
- Island Map exit does not grant completion/rewards;
- no duplicate gameplay/map/session instance.

Do not create a second timer or pause authority.

Populate/publish `CODEX_LOG_V01_CHILD_04.md`; prove equality before Child 05.
