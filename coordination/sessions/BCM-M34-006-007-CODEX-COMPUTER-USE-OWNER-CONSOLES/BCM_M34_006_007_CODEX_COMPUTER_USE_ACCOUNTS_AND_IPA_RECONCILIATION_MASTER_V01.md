# BCM-M34-006 / BCM-M34-007 — Codex Computer Use: Store Accounts, AdMob, and Existing iPhone IPA Path
**Master execution prompt V01 | 2026-10-18 | Coordinator: ChatGPT | Builder: Codex**
**Repository:** `Sekiph82/Beach-Cocktails-Merge` (`main`) | **Existing canonical tasks only:** `BCM-M34-006` (rewarded ads) and `BCM-M34-007` (native billing).
**Purpose:** Complete the maximum safe, real desktop/browser account configuration, reconcile the existing iPhone installation toolchain, then implement and verify native integration with truthful end-to-end evidence. **This is not a new milestone or a second task tracker.** Root `TASKS.md` alone controls status. Do not edit it; ChatGPT performs independent audit and any tracker updates.

## 0. User request and critical distinction
Owner supplied 18 Oct 2026 Chrome screenshots of App Store Connect, Apple Developer, Play Console, and AdMob, plus an attached Windows BAT named `iPhone_Yukle(2).bat`. Owner recalls Claude made an IPA ~10–15 days before and installed that earlier Beach Cocktails Merge build to the owner's **actual iPhone** with a desktop BAT. That memory is compatible with repository history: the personal-iPhone **XTool sideload** path is different from an Apple App Store **distribution-signed upload**. **Never declare iOS testing impossible merely because store-distribution signing is absent. Never claim the prior personal sideload proves App Store signing, TestFlight, billing, or SDK advertising.**

Use **Codex Computer Use on the owner's Windows 11 desktop** with authorized Chrome sessions and the local repository. Don't ask the owner to re-enter credentials that an authorized UI session already has. If computer-use capability is not enabled, do not pretend it was used: request owner to enable that capability; continue with read-only repo preparation. Before performing any nontrivial irreversible account action, inspect live UI, identify the exact account/app, and respect all owner checkpoints below.

## 1. Non-negotiable repo and local integrity
1. Follow root `AGENTS.md` and `TASKS.md`, especially sync-first: `git status --short --branch`, `git remote -v`, `git fetch origin main`, `git rev-list --left-right --count HEAD...origin/main`. Preserve all owner changes. No hard reset, force push, destructive stash, branch switch, silent cleanup, or disk space detour.
2. Verify actual live head, current task status, local/remote cleanliness, applicable prior builder logs and independent audits. On 18 Oct 2026 the evidence head was `17111e1051d75d22a28f95914d357885f6835940` and `TASKS.md` said **146/148 complete**, 006/007 blocked. Refresh; do not treat snapshot as immutable truth.
3. Owner desktop repo was documented at `C:\Users\sekip\Desktop\Beach Cocktails - Merge`. Locate and verify rather than assume a path.
4. Never edit root `TASKS.md`, previous logs, or historical game/asset acceptance. Create a new **immutable Codex builder log** under `docs/codex-logs/` for this run; report genuine browser/account outcomes and blockers without a parallel status dashboard.
5. Protect `iPhone_Yukle.bat`, `.ipa` files, XTool/Ubuntu/Swift environments, Apple signing files, App Store Connect API key, owner browser sessions, and local save data. Do not delete, rename, overwrite, rebuild, repurpose, or modify the BAT unless owner *separately explicitly approves*. Do not run invasive USB/firewall/portproxy changes merely to gather information. Do not require a new IPA to prove the previous deployment already happened.
6. No auto-submission, store publishing, public TestFlight, automatic app purchase, charge, paid API fallback, ad campaigns, production advertisement traffic, license/legal agreement acceptance, or identity/phone/device verification impersonation. These are explicit owner actions.
7. Treat credentials, OTPs, legal names, addresses, personal phone numbers, certificates, keys, p12 passwords, API tokens, App Store Connect private keys, and secret-bearing screenshots as sensitive: do not put them in prompts, repo, logs, Actions output, public links, or ChatGPT handoff. A mobile ad **app ID/unit ID** is a config identifier, not a secret, but redact personal/account financial data in evidence.
8. After any genuine owner-gated blocker, **work independently on all remaining safe tasks**. Stop only at a required owner interaction/authorization or a real technical blocker. Never counterfeit validation to remove the block.

## 2. Baseline observations that need live recheck
### iPhone BAT / signed-vs-sideload distinction
Owner-provided BAT text was read on 18 Oct 2026. It:
- Receives a dragged `.ipa` path and restarts with Windows administrator rights;
- Uses Windows Apple Devices/AppleMobileDeviceProcess, `usbipd`, WSL Ubuntu, Windows-to-WSL port 27015 `netsh` forwarding, `idevice_id -l` and `xtool install` on the translated IPA path.
- It is an **installer**, not proof that the IPA is App Store-distribution signed. XTool may perform its own device signing workflow.
- Existing `.github/workflows/ios-ipa.yml` exports `com.sekiph82.beachcocktails`, has `application/app_store_team_id="AAAAAAAAAA"` and disabled Xcode code signing. It produces an **unsigned CI IPA**.
- Existing `.github/workflows/ios-appstore-export.yml` has a distinct owner-gated signed App Store export path (checks signing credentials, no upload). Android has separate opt-in signed `.aab` workflow.
Check local desktop tool, exact IPA artifact provenance, phone install verification, package bundle ID, app version/date, signing identity where measurable, and repo/CI history. A screen of the app on owner's phone can be genuine personal-device acceptance without implying public release readiness. Preserve all old working mechanisms.

### 18 Oct 2026 screenshots, not live account truth
- **App Store Connect > New App**: `iOS` must be selected; Bundle ID option appears `XTool com sekiph82 beachcocktails — XTL-A5DEDA47.com.sekiph82.beachcocktails`. **Important:** this screen does **NOT** display the canonical `com.sekiph82.beachcocktails` identifier as a stand-alone choice. The XTool-prefixed ID is visibly **different**, not automatically compatible with the store workflow. Never select this XTool bundle ID for the release app without comparing exact identifiers and obtaining owner authorization for any release-ID change. Inspect Apple Developer Identifiers and establish whether the canonical `com.sekiph82.beachcocktails` is registered; if missing, prepare/create the correct explicit App ID subject to owner permission. Do not use the XTool Team ID as a substitute for owner Apple Team ID.
- App Store Connect shows an **updated Apple Developer Program License Agreement** requiring Account Holder review/acceptance; **Free Apps Agreement** active with newer terms available; **Digital Services Act** in review. These are different from a fully-ready paid IAP/distribution state.
- Apple Developer Account screen confirms developer-program access but not distribution signing readiness.
- **Google Play Console** shows a personal account and **two actions required:** verify access to a physical Android device, and verify contact phone. `Create app` is disabled until verifications complete.
- **Google AdMob** new account shows setup 1/4 and account verification in progress. No completed Android/iOS app or rewarded units evidenced. Review again rather than guessing acceptance/approval. AdMob is the in-game ad monetization system; Apple Developer/App Store Connect are platform distribution and IAP systems, **not an Apple in-game ad network**.

## 3. Computer Use execution phases: inspect once, act safely, verify each write
Use open browser sessions without logging out or resetting cookies. Navigate only official Apple/Google/GitHub sites. Verify domain carefully. Reuse a preexisting account app/ID instead of creating duplicates. Screenshots/evidence must be private/redacted. Check each committed console change by reloading UI and reading its persisted value.

### Phase A — existing iPhone deployment evidence
1. Locate original Desktop BAT and an installed or prior `.ipa`, the previous build's CI artifact/run (if available), and XTool config. Hash BAT and IPA, record filenames, SHA-256, size, known created/modified time and workflow run. Do not upload binary/private build artifacts without owner instruction.
2. Inspect BAT **read-only**; establish USB/WSL/xtool prerequisites non-destructively. Distinguish personal sideload from the `signed_export` App Store workflow and from TestFlight.
3. Verify observed `CFBundleIdentifier`/signing, when technically possible, against `com.sekiph82.beachcocktails`. If previous user-installed IPA has `XTL-A5DEDA47.com.sekiph82.beachcocktails`, report it as XTool-specific and not the canonical App Store ID.
4. If an iPhone is connected and the owner authorizes a physical test, only then perform a no-data-loss install/open smoke test using the **existing** installer. Do not reinstall over an app containing owner progress without explaining possible save-data effects.
5. Keep this fully separate from store distribution readiness.

### Phase B — App Store Connect / Apple Developer
1. Read updated Developer Program terms and highlight changes. **Account Holder must personally accept**; do not click Agree for them. Resume immediately after owner acceptance, if required.
2. Inventory Apple Membership status, Team ID (mask if sensitive), Identifiers, certificates, provisioning profiles, App Store Connect API access, app list, bundle IDs, and signed export prerequisites. Do not misclassify the XTool prefixed ID as canonical.
3. Confirm/reconcile an explicit release identifier `com.sekiph82.beachcocktails` with project/workflows. If available, use this release ID. If not, surface the safest registration procedure and exact user confirmation before an irreversible identifier choice. No silent renaming of the game package.
4. If no existing correct app record and all legal/identity gates are satisfied, prepare/create one **draft iOS app record** (not submission): title `Beach Cocktails Merge`, the **exact release bundle ID**, appropriate primary language based on actual game content (English if confirmed), stable non-secret SKU (e.g. `BCM-IOS-001` only after duplicate/owner review), and safe account access setting. Do not click Create with an unconfirmed app ID, language, or SKU. Report persisted Apple App ID and record URL after creation.
5. Audit Free Apps Agreement vs **Paid Applications Agreement** for IAP; DSA status; App Privacy, ATT, age-rating, export compliance, privacy policy, banking/tax/account roles, sandbox tester eligibility. The owner handles binding declarations/legal/financial data; leave them open until genuine resolution. Do not invent privacy answers or claim ATT unnecessary without examining actual installed SDK behavior.
6. Verify signed export only if protected owner credentials actually exist and owner authorizes. The distribution workflow must remain upload-disabled unless separately approved. Never embed Apple certs or private keys in source.

### Phase C — Google Play Console
1. Identify the account owner and screenshot's incomplete device verification + phone verification. A real non-rooted Android device running Android 10+ is required for the Play Console mobile-app device check. **Owner must perform** device QR/app login/Verify and OTP/phone verification (and any other identity prerequisites); do not emulate or bypass these checks.
2. After owner clears them, create/reuse ONE draft game record for `Beach Cocktails Merge`, using `com.sekiph82.beachcocktails` when pairing the AAB. Check game/free-language/support fields with owner for binding declarations and irreversible selections. Do not upload/sign/publish automatically.
3. Audit Play App Signing, registered package, license testers, internal testing path, account testing requirements, product catalog, policies and privacy/data safety declarations. In-App Products and billing remain separate until owner catalog/pricing/receipt backend and agreements are resolved.
4. Check protected `android-play-aab.yml` prerequisites **without exposing keystore secrets**. Never confuse debug APK with a signed production upload AAB.

### Phase D — AdMob, separate iOS + Android app entries
1. Inspect account approval/verification status and app list. No assumption that pending approval is complete.
2. For each platform, if the project is not on a supported public store, use Google's **Unpublished / not listed** flow to create/reuse a platform-specific app entry for `Beach Cocktails Merge`. Do not falsely claim it is live in either store.
3. Obtain the genuine **iOS AdMob App ID** and **Android AdMob App ID**, then create appropriate **rewarded** ad units for existing *implemented* in-game reward placements. Match reward metadata to the real game logic; do not create speculative formats or hard-code fake payout assumptions. Capture genuine ad unit IDs and the relevant nonsecret configuration file. Distinguish app IDs (`ca-app-pub-...~...`) from ad unit IDs (`ca-app-pub-.../...`).
4. Review account-level AdMob approval, serving limitations, app-ads.txt ownership requirements, publisher website domain and privacy-policy availability. No claims of production monetization until actually eligible.
5. Use only Google's official **test ad units/test devices** until the app has verified SDK integration, consent compliance and owner production authorization. Never click own production ads or generate artificial earnings.
6. UMP consent, advertising-data collection, EEA/UK consent, age/families eligibility and iOS ATT need owner-approved policy decisions informed by real code/SDK behavior, not invented defaults.
7. SSV: inspect current reward architecture; design server-side verification (Google signed callback, signature/key verification, exact-once transaction ledger, expiry/replay handling, authenticated reward grant, outage fail-closed) with a real backend choice requested from owner. A client-only callback is not proof of secure paid/rewarded ad fulfillment.

### Phase E — actual Godot native SDK + Billing integration, not checkbox theater
1. Audit current Godot 4.7.x plugins/addons and M34-006/007 abstractions against official supported Android/iOS SDK/plugin interfaces, versions, release signing requirements and existing store/campaign/economy/save authority. Fix compile/logic issues only within 006/007; avoid broad refactor.
2. Implement real **platform native providers** for rewarded ads and billing only as far as SDKs, approval, accounts and live identifiers support. Debug simulation must remain debug-only; shipping builds are fail-closed without native providers. No reward for canceled, duplicate, expired, malformed, unverified or denied events.
3. For billing, derive a proposed final product inventory from `data/campaign/store_catalog.json` and gameplay economy, then obtain **owner approval** for final purchase product IDs, prices, entitlement semantics and refund/restore behavior. Do not publish placeholders as real prices or set financial terms on owner's behalf.
4. Validate product IDs, Apple sandbox / StoreKit test, Google Play billing testers/closed or internal testing and receipt/purchase-token validation backend. Cross-device lifecycle, interruptions, restore, replay protection, chargebacks/refunds are required.
5. Tests must include actual Godot runtime + Android/iOS device flows **only when actually available**. Report exact test ID, build SHA, device/OS, native SDK initialization, test ad view callback, validation, grants and logs (redacted). Never mark simulator or mocked SDK runs as physical device tests.
6. Regression: NO TIMER, gameplay physics/merge/To-Go/VIP, reward idempotency, daily rewards, energy/coins/gems, save/progression, no-tracking fallbacks, pause/retry, no duplicate transactions and no payout when offline/fail-closed. Preserve all accepted art and app shell behavior.

## 4. Mandatory acceptance/evidence matrix
For each category record `DONE_REAL`, `DONE_PREP_ONLY`, `OWNER_ACTION_REQUIRED`, `BLOCKED_PROVIDER`, `BLOCKED_TECHNICAL` or `UNVERIFIED`, with:
- Chrome screen/site (redacted), verified live state and timestamp;
- platform app record IDs/AdMob ad unit IDs as appropriate, identifier match to code;
- code path/commit SHA and how to reproduce verification;
- XTool previous IPA vs unsigned CI vs signed App Store IPA distinction;
- actual device and native SDK runtime evidence when performed;
- owner-only remaining actions and smallest number of explicit owner questions;
- what was **not** performed (including approvals, upload, billing activation, public launch).
No false PASS. An approved app record is not an approved AdMob account; AdMob IDs are not evidence of impressions; a sideloaded IPA is not TestFlight; a CI signed AAB is not Google Play publication.

## 5. Action gates and safe execution rules
**Codex may autonomously:** review all pages, inspect repository/workflows/identifiers, reconcile IPA history, draft app records and account data, prepare code/config/SDK tests and create accurate evidence; create non-public draft app/ad entries once all their fields are independently verified and no binding consent/identity/payment choice is needed. Do not duplicate existing entries.

**Owner must personally control or explicitly approve:** Apple/Google legal acceptance, identity verification, phone/SMS/2FA, physical Android app verification, any bank/tax/finance setup, payment, final SKU/bundle changes, privacy/age/family/ATT claims, publishing, public release, live ad traffic, TestFlight external distribution, granting bot persistent auth, deletion, private keys/cert export. If such a gate is reached, leave the UI at a safe place and ask **exactly the minimum owner action needed**, then continue all independent work.

**Do not** start unrelated milestones, add canonical task IDs, modify root `TASKS.md`, overwrite the desktop installer, delete temp/worktrees, claim production signing from XTool, or bypass platform verification. No arbitrary time/test limits; use meaningful test coverage and stop only for real blocker or owner-only control.

## 6. Deliverables and finish rule
1. Make legitimate necessary code/config/docs changes for BCM-M34-006/007; commit and push only intended files to `main` without trampling concurrent owner changes. Verify local `HEAD == origin/main == ls-remote origin main`. If synchronization is unsafe, preserve work and report.
2. Write a new immutable Codex log under `docs/codex-logs/` (filename with current UTC date and `M34_006_007_COMPUTER_USE`). Include source/preflight SHA, files, all real computer-use actions and outcomes, screenshots referenced privately without PII, tests, exact counts, missing evidence, app/SDK readiness and remaining owner actions.
3. Never edit `TASKS.md`; after evidence commit, hand off to ChatGPT for independent acceptance. Describe whether 006/007 remain blocked and why; do not close them on your own.
4. Owner-facing final reply (Turkish): concise table of Apple Developer/App Store Connect, Google Play, AdMob iOS, AdMob Android, personal iPhone BAT, iOS App Store signing, Android Play signing, rewarded ads, billing. Distinguish **what you actually performed** vs prepared vs owner-only pending. Supply the actual GitHub log link and precise 1–3 required owner actions when needed.

## Official procedural sources (verify live changes against current platform UI)
- Apple app record / Account Holder latest agreement: https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app and https://developer.apple.com/help/account/access/roles
- Apple privacy/ATT: https://developer.apple.com/app-store/user-privacy-and-data-use/
- Google Play physical-device verification: https://support.google.com/googleplay/android-developer/answer/14316361
- Google Play phone verification: https://support.google.com/googleplay/android-developer/answer/10841920
- Google Play app create: https://support.google.com/googleplay/android-developer/answer/9859152
- AdMob unpublished app: https://support.google.com/admob/answer/9989980
- AdMob rewarded ad units + SSV: https://support.google.com/admob/answer/7311747
- AdMob UMP: https://developers.google.com/admob/android/privacy
