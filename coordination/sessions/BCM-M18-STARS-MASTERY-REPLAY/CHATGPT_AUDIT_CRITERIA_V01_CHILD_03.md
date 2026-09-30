# BCM-M18-003 - Locked Audit Criteria

- Sunny Cove has a data-driven cumulative star/reward track using the repository’s approved reward schema; no guessed or monetized behavior is added.
- Cumulative stars derive from completed level records and do not require perfect stars on every level.
- Threshold crossing grants eligible rewards exactly once, persists claims, and is idempotent on replay/reload.
- Reward claims cannot block normal completion, next-level progression, island completion, or Tiki Island unlock.
- Existing level milestone metadata and `GameEconomy` ledger behavior remain intact.
- Focused tests cover partial progress, threshold crossing, duplicate claim, reload, and non-blocking progression.
- If exact approved reward payloads are absent, the truthful result is `OWNER_REQUIRED`, later children do not start, and no speculative values are committed.

Any failed, unverified, or speculative item is `CHANGES_REQUIRED`.
