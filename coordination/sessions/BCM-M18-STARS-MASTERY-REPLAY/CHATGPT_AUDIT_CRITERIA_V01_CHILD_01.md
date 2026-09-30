# BCM-M18-001 - Locked Audit Criteria

- Star calculation is explicit, deterministic, data-aware, and returns only the contract’s 0-3 range.
- Normal level completion earns the base star; VIP and score mastery semantics match `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md` and existing data.
- Missing/disabled VIP does not block normal completion or cause a false VIP star.
- Stars do not gate level unlock, next-level resolution, island unlock, or normal completion.
- Focused tests cover normal, VIP, score-threshold, no-VIP, and progression-independence cases.
- No frozen gameplay/data/physics/HUD behavior changed; `TASKS.md` is unchanged.

Any failed or unverified item is `CHANGES_REQUIRED` and stops M18.
