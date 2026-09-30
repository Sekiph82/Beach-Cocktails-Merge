# BCM-M18-005 - Locked Audit Criteria

- Completed levels remain replayable and are not treated as locked by star count.
- Island Map level buttons display authoritative prior completion, 0-3 stars, and best-score state without stale or duplicated records.
- Replay entry uses the existing navigation/session boundary and cannot create duplicate gameplay/map instances.
- Returning from gameplay preserves the selected level and required scroll/focus context.
- Worse replay leaves the visible stored record unchanged; better replay updates it after reload/refresh.
- Focused runtime/probe evidence and captures cover the required states; unavailable owner/native visual checks remain explicitly unverified.
- No World Map, table, HUD, physics, or unrelated asset behavior changes.

Any failed or unverified material item is `CHANGES_REQUIRED` and stops M18.
