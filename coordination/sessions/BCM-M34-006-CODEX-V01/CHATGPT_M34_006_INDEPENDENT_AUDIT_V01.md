# BCM-M34-006 independent audit V01

**Verdict: CONDITIONAL PASS for credential-free preparation ONLY. Task BCM-M34-006 remains BLOCKED.**

Reviewed committed Codex execution log and actual source in `scripts/campaign/ads_service.gd`, `scripts/campaign/ads_provider_config.gd`, and `data/campaign/ads_provider_policy.json`. Did not independently execute Godot, Android, iOS, SDK or live AdMob tests.

Confirmed in source: production configuration always fails closed; all placements disabled by default; Android/iOS owner-field policy gates; debug-only test-provider injection; session-bound asynchronous callbacks; bounded load retries and timeout handling; cancellation; receipt and transaction duplicate guards; explicit refusal to credit unverified reward or native callback. Builder reports baseline 12/12, focused 5/5, final 13/13, diff/JSON validation PASS, and UID parity. These are BUILDER-REPORTED tests, not independently rerun results.

**Cannot close:** repository lacks integrated native AdMob provider, consent/ATT interface, SSV backend, real devices, and owner privacy and app IDs. No production ad delivery proven. Debug-only reward path does not constitute secure live SSV proof. Billing BCM-M34-007 untouched and still blocked on approved catalog/store/backend.

**Safety observations:** All 100 preserved stashes and owner untracked groups reportedly unchanged. Important technical limit: `accept_provider_reward` accepts a supplied boolean `ssv_verified` only in debug and hard-rejects release; correct fail-closed behavior today, but NOT a server-authenticated production verifier. The in-memory duplicate maps are session guards, not persistent cross-reinstall production anti-fraud; existing economy ledger must remain authoritative. Native SDK compatibility remains unverified. No claims of production readiness.

**Disposition:** M34-006 stays [!] BLOCKED; write progress showing credential-free preparation finished. Owner must supply AdMob Android/iOS app/reward-unit IDs (official test IDs may be used during development), privacy-policy URL, age/families decision, UMP and iOS ATT decisions, SSV backend hosting decision, and permission for device/emulator tests. M34-007 also remains [!] pending catalog, store tester access and backend choice. Do not issue another remediation prompt merely for missing external credentials. No new tasks added and no existing closed tasks reopened.
