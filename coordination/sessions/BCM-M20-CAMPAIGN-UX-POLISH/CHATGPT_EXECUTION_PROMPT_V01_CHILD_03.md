# BCM-M20-003 — Settings / Accessibility

Execute only after Child 02 publication equality.

Add a dedicated user-settings store and Settings UI.

Minimum:
- master audio level/mute;
- music level/mute;
- SFX level/mute;
- haptics on/off;
- reduced motion;
- high-contrast/readability mode.

Preferences must be independent from campaign save. Missing/corrupt settings must fall back safely.

Apply settings through bounded presentation APIs only. Do not change gameplay math, physics, objectives, timers or reward logic.

Add persistence, corrupt-file, AudioServer-safe-fallback and presentation-state tests.

Populate/publish `CODEX_LOG_V01_CHILD_03.md`; prove equality before Child 04.
