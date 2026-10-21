# BCM-M34-006/007 — V09 Store Kit + V10 Apple Portal Independent Audit V01

**Date:** 2026-10-21. **Reviewer:** ChatGPT. **Audited builder main:** `f334526a78687fb02b69cabe3c66d132212a4589`; previous coordinator head `5bc30eace35c1f16c0a55ac184711770da2bf066`. GitHub compare shows five builder commits `2587b63`, `6fe7df1`, `c695a15`, `dec436a`, `f334526`; no change to root `TASKS.md`. Sources: `docs/codex-logs/CODEX_LOG_2026-10-21_M34_STORE_SUBMISSION_KIT_V09.md`, `docs/codex-logs/CODEX_LOG_2026-10-21_M34_APPLE_APPROVED_APP_ID_AND_RECORD_V10.md`, `docs/release/store_media/submission_candidates_v09/submission_manifest_v09.json`, `tools/release/prepare_store_submission_v09.py`, `docs/release/BCM_M34_APP_STORE_CONNECT_APPROVED_RECORD_PACKET_V10.md`.

**Canonical status source:** only root `TASKS.md`. This audit is immutable evidence, not a second tracker.

## Independent verdict

**V09: SOURCE + COMMITTED-MANIFEST PASS for store SUBMISSION CANDIDATE assembly and staging, NOT STORE_READY.** Builder's local Python/PNG decoding/dimension/hash tests are reported successful but were not independently rerun against owner's Windows files. Private image binaries were not rendered for independent aesthetic review; screenshots are desktop-origin, not device-accepted. Google Play candidates await owner visual inspection and actual Android QA; Apple screenshots remain CAPTURE_PENDING.

**V10: BLOCKED_APPLE_SESSION_NOT_ACCESSIBLE_TO_CODEX.** The four Apple immutable fields have owner approval, but Apple **standalone App ID NOT CREATED** and **App Store Connect app record NOT CREATED**. This was an honest security-controlled stop, not an Apple Console operation. No status can be inferred about current Apple team Apps, signed-in account, agreements, role, or duplicate-ID conditions from the V10 access failure. Existing older "No Apps" finding only applies to the team previously inspected at that time.

**Both public mobile releases: NO-GO**; canonical M34-006/007 native AdMob and Billing stay BLOCKED, 146/148 tasks unchanged. Do not misinterpret 146/148 as store readiness.

## V09 evidence reconciliation

GitHub source includes the 280-line `prepare_store_submission_v09.py` which copies existing candidate assets without altering them and records source hashes/real Godot capture identities. Committed manifest contains exactly **eight** Google Play media files: **512x512 567,144-byte RGBA icon**, **1024x500 901,737-byte RGB feature graphic**, and **six 1080x1920 RGB compositions** for Home, World Map, Island Map, latest tutorial-free gameplay, live merge and To-Go gameplay. **Three** are gameplay captures; Daily Rewards is intentionally omitted. All marked `CANDIDATE_ONLY_NOT_STORE_READY`, `DEVICE_REVIEW_PENDING`. Contact sheet reported 960x1438. Source-relative paths and hashes are reproducibly referenced; originals preserved.

Manifest status `PASS_CANDIDATE_VALIDATION` / release `BLOCKED_DEVICE_VISUAL_REVIEW` is internally coherent. This means **file schema/dimensions/hash/reference integrity passed**, NOT that storefront accepted the visuals, screenshots are on-device, tutorial overlay is absent from all old V03 compositions, icon is owner-approved, or store account access exists. Source notes that some older compositions still show the real tutorial layer. No Apple iPhone media was generated because the team did not have a genuine iPhone production-build capture; target 1179x2556 only a technical requirement, not captured.

Six locally staged EN/TR HTML pages exist: each language has index/privacy/support. HTML includes `OWNER_REVIEW_REQUIRED` for publisher legal identity, privacy and support contacts, data retention/deletion, audience/children, processor disclosures and app/SDK truth. They are **not publicly hosted**, so there are **no approved HTTPS Privacy/Support URLs**; `data/ui/settings_links.json` keeps both disabled. No Cloudflare deployment was authorized and none was performed.

Future AdMob source remains present while seven placements OFF; store catalog nonbuyable. No real native AdMob SSV, UMP/ATT consent, StoreKit or Google Play Billing acceptance. No new build/export or old PCK repeated tests. Builder reported `python -m py_compile`, media validator and `git diff --check` PASS; these were not rerun here.

## V10 source and browser access evidence

Owner explicitly approved iOS display name `Beach Cocktails Merge`, standalone Bundle ID `com.sekiph82.beachcocktails`, immutable SKU `BCM-IOS-2026-001`, primary language `English (U.S.)`. The published V10 packet correctly lists these as APPROVED INPUTS and the actual Apple resource as `NOT CREATED_SESSION_UNAVAILABLE`.

Codex's fresh Computer Use inventory `apps=[]`; in-app browser had 0 tabs. Thus no verified origin/team/role or normal signed-in session was accessible. It DID NOT create the standalone identifier or draft app, add users, accept agreements, upload IPA or perform store writes. Do not recharacterize this as a failed registration, account disapproval, or evidence no app exists globally.

**Additional reviewer tool probe:** Connected Browser tab-list attempt from this ChatGPT desktop session returned exactly: `Browser access requires the originating browser context. Open ChatGPT in the browser with the connected extension and try again.` This confirms a browser-origin/session-visibility blocker for this route **here**, not proof that the owner is logged out of Apple everywhere. The needed remedy is **an authenticated, authorized and visible Apple browser context**, not another empty Apps search, bypass or token/cookie export.

The prior V10 prompt remains the correct executable instruction ONCE access is genuinely available. Do not create a V11 recheck just to record apps=[]. For direct browser automation, the user may use an eligible Work/Computer Use browser session after owner-controlled login/2FA. If authenticated official Apple portal is not controllable, explicitly stop and request a manual official-account handoff; do not pretend the assistant or Codex completed account writes.

Outstanding **User Access Limited/Full selection, intended team and any Account Holder latest agreement** were not among the four approved values. Require real official UI evidence and least privilege; never accept legal/finance agreements on behalf of the account owner. Bundle and SKU must be exact; no silent suffix.

## Next real work

1. **Apple controlled account handoff:** owner uses normal official Apple Developer and App Store Connect browser sign-in and 2FA, in a context actually shared with authorized automation (browser extension/origin or Work cloud browser); user must not send password, 2FA code or session tokens. On verified team/role, Codex/authorized browser agent follows existing V10 one-time owner-approved **create** instruction (not another presence-only check). Only if access/team/User Access or agreements block, ask the narrow remaining owner decision.
2. **Google Play candidate visual owner review:** present the committed contact sheet and 8 individual image candidates where pixels can be viewed, reject old tutorial-heavy or unreadable visuals and replace with genuine stable gameplay if needed; physical Android QA later.
3. **Apple release iPhone capture:** real iOS signed/TestFlight-appropriate runtime and iPhone screenshot set still unavailable. Do not counterfeit mobile screenshots from 720x1280 Godot desktop renders.
4. **Privacy/support publication:** obtain truthful publisher identity, contact, retention and final SDK/consent practices; only with explicit owner legal review and hosting approval publish HTTPS pages and configure in-game URLs. Store privacy declarations depend on signed final app.
5. **Native store blockers:** Android debug preview AAB is not shipping signed, Google Play account still gated on physical-device owner verification; iOS Xcode26+/macOS signing and App Store Connect app record pending; AdMob & Billing M34-006/007 remain disabled/unverified.

## Final acceptance

**V09 candidate-kit implementation SOURCE+MANIFEST ACCEPTED, store readiness NOT ACCEPTED. V10 identity approval accepted, Apple record still BLOCKED due absent authenticated controllable browser. No false task closure.** Preserve owner files, GitHub Actions disabled, no emulator, no old APK/AAB/IPA overwrite, no unapproved legal/account actions.
