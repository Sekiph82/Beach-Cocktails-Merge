# BCM-M18-003 - Sunny Cove Cumulative Star and Reward Track

Read the M18 master prompt/criteria, Child 02 handoff, and this child’s locked criteria. Execute only Child 03.

Add the Sunny Cove cumulative star/reward track through the existing `reward_track`, `GameEconomy`, `CampaignManager`, and save schema. Keep rewards non-blocking: star totals and milestone claims must not gate level completion, next-level progression, or island unlock. Claims must be deterministic, persisted, and duplicate-safe. Preserve the existing level milestones (10,20,30,40,50,60,70,80,90,100) and existing booster/coin ledger semantics.

Do not invent unapproved economy values, purchases, ads, or backend behavior. If the repository does not contain an owner-approved reward payload for the required new cumulative-star track, stop with `OWNER_REQUIRED` in the child log and do not guess. Otherwise add focused tests for cumulative totals, threshold crossing, partial progress, persistence, and duplicate claims. Do not start Child 04 until the child log and clean remote equality are complete.

Handoff log: `CODEX_LOG_V01_CHILD_03.md`.
