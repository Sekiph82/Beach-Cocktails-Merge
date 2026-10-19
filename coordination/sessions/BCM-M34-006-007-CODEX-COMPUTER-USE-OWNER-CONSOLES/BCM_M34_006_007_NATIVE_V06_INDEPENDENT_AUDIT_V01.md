# BCM-M34-006/007 — V06 Independent Source Audit V01
**Date:** 2026-10-19. **Auditor:** ChatGPT. **Audited GitHub SHA:** `3d67cfdec87d93e981f02cffa6668639b0425b23`, implementation `1a4387a5bc63f1cfed9238c7e6720946cabd1578`. **Builder evidence:** `docs/codex-logs/CODEX_LOG_2026-10-19_M34_006_007_NATIVE_V06.md`. Historical evidence only. Root `TASKS.md` is the sole live tracker; ChatGPT is sole editor.

## Verdict
**CONDITIONAL ACCEPTANCE of V06 source remediation, NOT completion of M34-006/007.** Previously identified AdMob SSV `user_id` omission is repaired at Godot LoadAdRequest source level; Google-documented numeric `ad_unit` SSV form is handled separately; asynchronous reward/profile checks and local APK signing improved. No real Android/iOS native runtime, signed Google callback, deployed Worker/D1, actual identity/consent, StoreKit or Play transaction was verified. Keep `146/148`; both tasks BLOCKED.

**Separate high-priority owner-data incident:** builder disclosed one `CampaignNavigationController` run outside the isolated test runner before capturing a baseline for owner `user://campaign_save.json`. This could have read, repaired or written actual owner save and backup. There is **no pre-run hash**, so neither impact nor lack of impact can be established. Do not infer corruption, do not silently restore files, do not repeat unsandboxed probes. Owner can authorize **read-only** metadata/hash/backup/validity inspection; any actual restore or mutation requires separate explicit approval. No source audit can recover a missing earlier hash.

## Audited scope and positive findings
- `scripts/campaign/admob_test_adapter.gd`: in `_on_claim_created`, gets authenticated subject from Worker transport, verifies response binding, sets both `LoadAdRequest.set_user_id(authenticated_subject)` and `set_custom_data(nonce)`, checks serialized request fields. Exact Android/iOS native SDK transport remains untested.
- `backend/mobile-rewards/src/index.js`, `migrations/0002_admob_ssv_unit_binding.sql`: separates full SDK ad unit string `ca-app-pub-.../...` from signed SSV callback numeric `ssv_ad_unit`; checks user/nonce/unit/amount. Old claims with absent SSV unit fail closed. Queue SQL caps outstanding claims plus undelivered rewards at 50 and rejects next claim at bound.
- `scripts/campaign/mobile_reward_http_transport.gd`, `campaign_navigation_controller.gd`: re-check authenticated subject↔active save identity, snapshot/clear completed HTTP operation state before callbacks, schedule reconcile, and retry pending when energy becomes available.
- `scripts/campaign/mobile_reward_delivery.gd`, GameEconomy and SaveManager: matching user, validated server-row amounts, transaction-keyed idempotency, durable save before ACK, recover on failed save with pending replay; full Energy remains a non-acknowledged pending reward.
- `scripts/campaign/play_billing_test_adapter.gd`: durable completion *interface* and restart recovery using verifier/test ledger; not a production Apple/Google receipt verification implementation.
- `tests/run_regressions.py`: each selected Godot probe receives a distinct `.godot/bcm_sandboxes`-scoped `APPDATA`/`LOCALAPPDATA` environment; the **unprotected direct invocation** disclosed by builder was outside that protection.

## Acceptance / evidence matrix
| Criterion | Source-based audit verdict |
|---|---|
| Former P0 SSV user-ID binding | **PASS SOURCE**, native device bridge UNVERIFIED |
| Signed callback numeric unit check | **PASS SOURCE**, documented numeric example; actual Google callback test UNVERIFIED |
| Async ACK, profile switch, save-failure recovery | **PASS SOURCE / MOCK TESTS**, not verified with deployed network or Android device |
| Worker 50-row bound + DB migration | **PASS SOURCE**, builder reports production cap SQL 50 accepted / 51st rejected using in-memory SQLite |
| Play Billing completion journal | **PARTIAL:** test fake, no real trusted persistent verifier or store |
| Core Godot 20/20; focused 9/9; Worker 20/20 | **BUILDER-REPORTED PASS**, not independently executed |
| Android APK Gradle, 205,849,502 bytes, hash `BA6CB30FD05BBF60BF7423FE476453AEFCC38E7CCF228DA78979823316846F1F` | **BUILDER-REPORTED**, owner-local artifact not accessible to auditor |
| `apksigner verify` v2 true, exit 0, debug signing | **BUILDER-REPORTED**, appropriate project-local JDK approach |
| Personal save data unaffected | **UNVERIFIABLE**, unsandboxed execution and missing pre-run baseline |
| Production rewarded ads, trustworthy UMP/ATT, deployed SSV and native Android runtime | **BLOCKED** |
| iOS IPA/StoreKit + Play/App Store commercial acceptance | **BLOCKED** |

## Important limits and additional review findings
1. **Owner save safety is not a routine source cleanup:** `SaveManager.write_state` writes a temp file, copies recoverable old primary to `.bak`, then renames temp over the primary. A mistakenly unisolated controller could change both primary and backup, but the available log does not prove it happened. At current state, neither running the game nor restoring a backup is an approved audit step. Safest next step is read-only inventory under explicit user authorization.
2. **SSV SDK option propagation:** Google SSV docs confirm optional `user_id`, numeric `ad_unit` example, and that server-side verification options must reach the *loaded rewarded ad* before showing. Bundled Godot plugin `LoadAdRequest` has the fields, but no physical bridge/device test proves that Android/iOS native SDK applies them. Do not mark SDK end-to-end PASS from request serialization alone. citeturn842004search0turn842004search3
3. **SSV reward policy is distinct from test ad setup.** Actual deployed config must bind each platform, full unit, numeric callback unit, item/amount and user/nonce. Test Google sample IDs and real AdMob app IDs must not be mixed in production. AdMob callback URL not configured.
4. **Full Energy pending:** not ACKing a 20-Energy reward at cap preserves existing game economy, but it can occupy one of 50 queue slots until Energy drops. Test retry and eventual recovery, user-visible explanation, and policy for never consumed pending reward before release. No silent expiry or paid-token substitution.
5. **Client consent assertions** `consent_granted=true` and `UMP_OBTAINED` are not independently validated legal consent; owner decisions and native UMP/ATT verification still required.
6. **Billing:** `/v1/store/verify` and `/v1/store/restore` remain 503, `buyable=false` catalog, and compatible StoreKit native integration remains absent. Android package is `com.sekiph82.beachcocktails.m34debug`, not Play release.
7. **Coverage:** test runner `20/20` represents the configured core + editor + smoke, not all headful/device/manual tests. Isolated test runner is good; direct invocation of save-aware scripts remains dangerous.

## Required next actions
- **P0 data safety:** No unisolated campaign tests, unsupervised loading/saving/restoring of user's real `campaign_save.json` or backup. Add a fail-fast sandbox assertion to save-mutating test entry points and/or safe wrapper, prove `user://` resolves within a test-only profile before startup. All validation must leave actual player data untouched. For owner save: request optional read-only investigation; report current metadata/hash and structural validity with no restore/delete/copy unless explicitly authorized.
- **P1 local end-to-end:** use only isolated test profiles, test identity/consent+SSV simulated HTTP flow with local Worker runtime/SQLite when possible, fail/timeout/queue full and virtual Android SDK option bridge, compare to official native SSV APIs.
- **P2 owner-gated work:** choose actual identity provider + privacy/age/UMP/ATT policy and Worker deployment only with owner; native device test after explicit permission; prepare honest StoreKit/Play roadmap, no live IAP.
- **No GitHub Actions, Expo/Orbit, unsafe Computer Use or changes to `iPhone_Yukle.bat`.** Codex source/test builder commits and logs, ChatGPT audits & updates root TASKS.md.

## Final rating
**CONDITIONAL PASS for V06 source-level improvements; RELEASE BLOCKED for M34-006/M34-007; owner save incident UNRESOLVED, not proof of damage.** Evidence confidence HIGH source, MEDIUM builder tests, LOW physical/account/save historical state.
