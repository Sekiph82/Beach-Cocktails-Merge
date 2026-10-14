# M34-R01 independent source and evidence audit

**Verdict: CONDITIONAL PASS, daily service behavior / focused builder probes; RELEASE NOT APPROVED.**

Reviewed on current GitHub main: `scripts/campaign/daily_reward_service.gd`, `data/campaign/daily_rewards.json`, execution log `docs/codex-logs/CODEX_LOG_M34_R01_DAILY_REWARDS_V01.md`. Source contains five correct values, UTC reset and per-day ledger keys, fails closed for ad slots when adapter is absent; builder reports `M34_DAILY_RESULT=PASS` and `M34_ECONOMY_RESULT=PASS`. This is an independent review of sources and evidence, not independent local Godot execution or owner-device testing.

**Discrepancy requiring remediation:** versioned `data/campaign/daily_rewards.json` still declares `reset_policy: OWNER_DECISION_REQUIRED`, and slot 3 reward null and disabled. Runtime script currently hardcodes the correct owner-approved UTC reset and +40 Coins instead, explicitly overriding the stale file. Data-versus-code authority split is NOT eligible for final closure. Reconcile canonical JSON safely with overlap-aware source preserving both valid owner changes and current decisions; make a single authoritative source, test that actual runtime loads it, prevent future drift. Do not modify unrelated owner-dirty JSON or force-sync canonical Desktop.

**Secondary quality caveat:** reported economy probe passes but its fixture emits 15 leaked ObjectDB instances and 3 live resources on shutdown. Investigate fixture cleanup and verify no product lifecycle leak; never represent run as clean shutdown while warnings persist.

R01 safe bounded PASS aspects: free 40 Coins slot; ad-gated +20 Energy / +40 Coins / +2 Gems / +80 Coins; UTC-date ledger, rollback high-water, schema1–3 save migration, failed/unavailable ad gates; headless layout-bounds test. Unverified: real SDK receipt, physical device/timezone change, manual Home layout and claims. M34-005 26 asset candidates REVIEW with zero deletion, not broad cleanup. Canonical Desktop sync still blocked by two owner-dirty overlapping JSON files and deliberately not touched.

Decision: **R01 implementation accepted provisionally, data reconciliation and shutdown investigation needed before final closure**. Owner real visual and native monetization validation separate gates. Next prompt should focus JSON authority reconciliation without disturbing local owner work.
