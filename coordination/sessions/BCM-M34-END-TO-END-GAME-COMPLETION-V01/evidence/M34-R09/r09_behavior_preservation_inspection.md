R09 owner feature preservation inspection

- Tutorial/MOVES: source/data are unchanged from the synchronized baseline. Existing tutorial resources remain present; this R09 task did not edit campaign or gameplay code.
- Focus: no active Focus item/UI was introduced. The economy regression explicitly verifies schema migration retires legacy Focus boosters and preserves non-Focus boosters. Remaining `retired_focus_inventory` fields are compatibility/save migration only.
- Timer: no active campaign countdown was introduced. The production gameplay bridge sets `time_limit_sec` to 0.0 and `timer_configured` to false; timer callbacks are inert for production campaign sessions. Existing gameplay-local combo/danger/settlement timers remain gameplay mechanics and were not changed.
- Gameplay/economy/navigation scripts and data were not modified by R09. R09 regression probes ran after fresh import and after enabling the Android ETC2/ASTC import profile.
- This is builder source/regression evidence, not owner visual/device acceptance.
