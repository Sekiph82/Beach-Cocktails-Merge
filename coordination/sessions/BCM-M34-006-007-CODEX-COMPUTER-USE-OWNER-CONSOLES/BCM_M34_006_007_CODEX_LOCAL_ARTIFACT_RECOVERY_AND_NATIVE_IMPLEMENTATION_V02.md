# BCM-M34-006/007 | Codex Computer Use | Owner Artifact Recovery + Native Completion | V02
**2026-10-18, addendum to V01. Existing task IDs ONLY: BCM-M34-006, BCM-M34-007. Root `TASKS.md` is the sole live tracker and ChatGPT writes it; Codex MUST NOT change it.**

## Newly provided owner information: take action now
The owner corrected the V01 report that no IPA/APK was located. Codex had searched the **Downloads root** but apparently not these exact **named paths**:
- `C:\Users\sekip\Downloads\BeachCocktails-ipa`
- `C:\Users\sekip\Downloads\BeachCocktails-apk`

These are **owner-provided paths**, not verified artifact file types. They may be folders, extensionless files, extracted builds or a mix. Use Windows Computer Use / local terminal to inspect the *exact* paths and their children read-only before saying artifacts are missing. This finding supersedes V01's scoped negative result.

Owner also reports having already created in Apple Developer:
- Merchant ID: `merchant.com.sekiph82.beachcocktails`
- Description: `Beach Cocktails Merge`

**Merchant ID is exclusively relevant to a separately chosen Apple Pay integration, NOT StoreKit IAP or Apple in-app purchase setup. Do NOT configure Apple Pay, add an Apple Pay entitlement, create a Merchant certificate or a payment-provider account for BCM-M34-007. Do NOT mistake Merchant ID for the app Bundle ID.** The release Bundle ID remains `com.sekiph82.beachcocktails` unless the owner explicitly changes it. The historical XTool-prefixed `XTL-A5DEDA47.com.sekiph82.beachcocktails` is a different identifier, and is NOT the release identifier.

## Phase 1: reproduce/prove the previously working mobile builds
1. Run required AGENTS.md sync-first Git commands, inspect HEAD and V01/V02 Codex logs, then inspect *both exact Downloads paths*. Non-destructive commands: `Get-Item -LiteralPath`, `Get-ChildItem -LiteralPath ... -Force`, bounded recursive enumeration only inside these two paths, and `Get-FileHash -Algorithm SHA256`. Be mindful that `-Force` shows protected files but must never trigger deletion.
2. Find real `.ipa`, `.apk` and if present `.aab` or ZIP artifacts; if extensionless, inspect file signatures before deciding type. Log exact file path, bytes, timestamp, hash; do not copy binaries to GitHub, overwrite, delete or distribute them.
3. For IPA, inspect ZIP `Payload/*.app/Info.plist` using Python `zipfile`+`plistlib` (read-only). Extract *metadata in memory* when possible: `CFBundleIdentifier`, short version, build number, min OS, architectures, signatures/provisioning presence, and names of code-sign files. Avoid dumping secret provisioning/certificate bytes. If bundle is XTool-prefixed, report explicitly; do not rewrite old binaries or treat it as App Store-signed.
4. For APK, use installed SDK `aapt2`/`apkanalyzer` and `apksigner verify --print-certs` (or other verifiable read-only tools) to extract package name, version/build, min/target SDK and signer fingerprint when available. Distinguish Android APK from Play Store AAB. Compare to expected `com.sekiph82.beachcocktails`; do not claim source-to-artifact equivalence without provenance.
5. Reconcile with GitHub Actions iOS IPA / Android APK run IDs, available artifact dates, commit SHA, and existing XTool BAT. Preserve `C:\Users\sekip\Desktop\iPhone_Yukle.bat` **exactly**, hash and inspect if needed. The owner has an iPhone 16, Windows 11 and no Mac or available personal Android phone.
6. If owner iPhone is not connected, do not say iOS build is impossible. Verify the build/download/sideload pipeline **without executing the BAT**, without changing Windows USB/firewall/WSL settings or installing over phone save data. Schedule the specific on-device manual step only when physical phone connects and owner authorizes potentially save-impacting reinstall. Do NOT ask the owner to re-download IPA/APK already present.

## Phase 2: finish safe technical work instead of listing blockers
Start immediately after read-only artifact inspection. Do as much **real implementation** as can be independently done without Apple/Google account approvals, test devices or production-serving permission.

### BCM-M34-006 rewarded ads
- Evaluate and select a real maintainable Godot **4.7.x-compatible** mobile AdMob plugin/native integration for Android and iOS; check actual source/API/version/license and whether it supports consent/UMP and native device callbacks. Do not invent plugin compatibility. Distinguish plugin availability and runtime-tested compatibility. Integrate official test app/ad unit flow into separate debug build config where technically possible.
- Existing platform app IDs and rewarded ad unit IDs are ALREADY saved in `data/campaign/ads_provider_policy.json`, verified in Codex V01. Do **not** request them from the owner again or create duplicate AdMob app/ad units.
- Wire lifecycle to the existing `AdsService`, async callbacks, cancellation, retry, timeouts, scene lifecycle, accepted placement IDs and reward amounts. Ensure production remains fail-closed until SSV trust established. Preserve no-timer, gameplay physics, merge, VIP, daily rewards, game economy and existing art.
- Implement/test a standalone trustworthy SSV verification component, including signature checks using Google's public keys, transaction ID replay prevention, reward ledger, expiry and authenticated grant. Design for an economical hosted endpoint such as Cloudflare Workers (can use a provider subdomain, no purchased domain required), but **do not deploy to a user's account without authorization**. Provide a separate privacy-policy web-page draft based on *actual* SDK data practices rather than inventing legally binding answers. Host choice and final policy claims remain owner decisions.
- Add realistic deterministic adversarial unit/integration tests for bad signatures, replay, fake callbacks, double grant, wrong placement, consent denial, loading failures and cancelled ads. Cross-platform SDK/device validations stay `UNVERIFIED` if no real device.

### BCM-M34-007 StoreKit / Play Billing
- Separate native StoreKit IAP from the unrelated Apple Pay Merchant ID. Do not create Merchant certificates. Inspect the existing `store_service.gd` and `data/campaign/store_catalog.json` placeholders. Derive a proposed real product list from the existing gameplay/economy, with types, IDs and restore semantics, and a **clearly labeled proposed pricing table** for owner approval. Owner approves final sellable catalog/pricing, not technical prep.
- Prepare real Godot-compatible Apple StoreKit / Google Play Billing SDK interfaces and robust receipt/purchase-token verification architecture; reject client-only purchase assertions; make backend ledger replay/refund/restore safe. Use StoreKit sandbox/local test configurations if technically supported even without a store app record.
- Account creation blocks (legal terms / developer identity, physical Android verification / phone, Google Play app creation, StoreKit products and sandbox testers) do not block this preparatory coding. Do not pretend external stores were configured or purchases actually completed.
- Apple's standalone canonical `com.sekiph82.beachcocktails` App ID and App Store Connect record are **still absent according to V01**; live re-check first. Merchant ID does not create either. Proceed to safe account/record preparation, ask for owner approval ONLY at binding legal/irreversible identifier gates. Do not select the XTool-prefixed identifier. Never accept terms or supply user financial answers on owner's behalf.

## Phase 3: actual release/test readiness
- Recover how historical artifact(s) were produced, then add/repair required safe repeatable unsigned iOS personal-device test IPA and Android APK preparation. Never replace historical builds or sign as if App Store-ready.
- Build and run available Godot editor/headless and automated tests; report exact output, whether an APK/IPA export **actually happened**, plugin compile state, new artifact hashes and precise reason if a platform build is impossible on current environment.
- On Windows + iPhone, rely on the existing XTool/WSL personal sideload route for owner-authorized physical tests when available, without conflating it with StoreKit sandbox or App Store signed distribution. No Android emulator work unless separately permitted; a physical Play-account verification must never be emulated.
- Final truthful matrix: artifact **located/inspected**, app ID vs Merchant ID, AdMob configured / integrated / device-verified, StoreKit adapter / backend / store-verified, native Apple/Google release readiness, what the owner *actually* needs to do. Distinguish coding limitations from account gates. All production ads and purchases stay OFF until approved and verified.

## Rules and handoff
- Work on **both existing tasks as a coherent milestone batch**, and do not stop after updating one JSON file. No newly invented canonical tasks or milestones.
- Keep progress moving while owner-only gates remain; send a concise summary of only genuine human actions, with specific site/button when available.
- No destructive cleanup, stashing, wholesale reset, browser logouts, proprietary/private artifact uploads, credentials in GitHub, forced changes to BAT, paid services, live ads, real purchase orders, public releases, or unapproved Apple/Google agreement acceptance.
- Codex implements, tests, logs to a fresh `docs/codex-logs/` file, commits, pushes, verifies `HEAD == origin/main == remote main`, and leaves `TASKS.md` untouched for independent ChatGPT acceptance. The existing V01/V02 logs are immutable; this prompt is the new execution instruction, not a status tracker.
