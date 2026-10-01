# BCM-M20-004 — Locked Criteria

- Existing GameplaySessionBridge remains sole campaign timer authority.
- Pause overlay exists with Resume + Island Map.
- Manual/background pause semantics are correct and distinguish pause reason.
- Timer does not drain during valid pause/background.
- Manual pause survives background/resume.
- No progression/reward is granted by pause-to-map exit.
- No duplicate instance leak.
- Focused lifecycle probe PASS and separate publication/equality required.
