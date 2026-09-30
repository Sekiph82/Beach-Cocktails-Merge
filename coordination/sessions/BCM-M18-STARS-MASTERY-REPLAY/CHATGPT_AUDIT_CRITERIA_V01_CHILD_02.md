# BCM-M18-002 - Locked Audit Criteria

- Stored per-level best score is monotonic and persists under the campaign save authority.
- Stored stars are monotonic and bounded to the valid 0-3 range.
- Better replay upgrades the record; worse and equal replay preserve the prior record.
- First completion/unlock behavior remains idempotent; replay does not duplicate one-time rewards or corrupt VIP history.
- Save reload and relevant migration/recovery paths preserve the monotonic record.
- Focused tests prove all replay directions and no regression to legacy best-score persistence.
- No duplicate save authority, tracker change, or frozen gameplay/data change is introduced.

Any failed or unverified item is `CHANGES_REQUIRED` and stops M18.
