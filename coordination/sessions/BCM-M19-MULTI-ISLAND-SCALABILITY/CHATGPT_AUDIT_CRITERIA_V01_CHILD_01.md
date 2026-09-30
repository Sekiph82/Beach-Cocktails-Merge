# BCM-M19-001 — Locked Criteria

- Multi-island level roots load into one LevelDatabase instance.
- Existing single-root loading remains backward compatible.
- FULL validation is correct per loaded island and permits zero-level placeholders.
- Duplicate/cross-island malformed data remains rejected.
- One shared CampaignManager, SaveManager, map pair, session bridge and gameplay implementation serves both fixture islands.
- No duplicated island-specific engine/service classes or scenes.
- Focused probe PASS and clean synchronized publication required.

Any material failure is `CHANGES_REQUIRED`.
