# BCM-M18-002 - Monotonic Best Score and Replay Records

Read the M18 master prompt/criteria, Child 01 handoff, and this child’s locked criteria. Execute only Child 02.

Preserve the existing campaign save schema and make level records monotonic across replay: a better score may replace the stored best score, a higher star result may replace stored stars, and a worse/equal replay must not lower either value. Preserve first-completion semantics, VIP history, schema migration, atomic save/reload, and existing legacy best-score behavior. Use existing `CampaignManager`/`SaveManager` boundaries rather than duplicating persistence.

Add focused tests for first completion, better replay, worse replay, equal replay, save reload, and malformed/older save compatibility as applicable. Do not start Child 03 until the child log and clean remote equality are complete.

Handoff log: `CODEX_LOG_V01_CHILD_02.md`.
