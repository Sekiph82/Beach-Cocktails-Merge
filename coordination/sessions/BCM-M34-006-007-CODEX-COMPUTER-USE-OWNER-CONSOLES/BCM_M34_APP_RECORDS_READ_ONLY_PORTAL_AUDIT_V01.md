# BCM-M34-006/007 — Codex Read-Only Apple + Google App-Record Audit V01

**Owner's latest authorization (2026-10-19):** Apple Developer and Google Play Console developer registrations are complete. The owner does **not** recall whether the specific **Beach Cocktails Merge** applications were created and explicitly asks Codex to **go look**. Owner thinks they probably were **not** created. Do not substitute that recollection for observed evidence.

**Job:** Inspect real, authenticated Apple and Google developer portals **READ ONLY** via Codex Computer Use in the existing, officially verified signed-in browser if possible; distinguish account registration from per-game app registration. Return a factual result without asking owner to remember anything. No account configuration, app/product creation, payments, purchases, agreements or API setup is authorized yet.

## Security and access
- Trusted official targets: `https://appstoreconnect.apple.com/` (Apps section), `https://developer.apple.com/account/` (Certificates, Identifiers & Profiles if needed to inspect Bundle IDs), `https://play.google.com/console/` (All apps / Dashboard). Verify the exact origin, address bar and secure signed-in browser context **before interacting**. A public website, Google search result, generic GitHub file or Apple Pay Merchant ID is not app registration evidence.
- **Prior attempts to use Computer Use were BLOCKED when Chrome could not verify the URL origin.** The owner now authorizes a *new read-only attempt* ONLY if exact official origin and authenticated browser context can be verified normally. Do **NOT** bypass the browser restriction or use shell HTTP, cookies, Chrome debugging, injected JavaScript, alternate domains, saved credentials, leaked token/session material, scripts/APIs to impersonate a user, or remote automation hacks. If portal verification blocks, report `BLOCKED_PORTAL_ORIGIN_UNVERIFIED`, not `APP_NOT_CREATED`.
- If a normal login or 2FA challenge occurs, stop only that portal and report `LOGIN_OR_2FA_REQUIRED` without asking for credentials. Do not request user passwords, 2FA codes or secrets in GitHub. Other portal may still be inspected legitimately.
- **READ ONLY** means no Create app, no new Bundle ID, no package assignment, no product/pricing, no app upload, no tester invitation, no agreement acceptance, no App Store/Play publishing, no Cloudflare deploy, no app entitlement change and no real mobile/ads/payments.
- No GitHub Actions, Expo/Orbit/EAS, unrelated file cleanup, no changing XTool/iPhone_Yukle.bat, IPA/APK, owner Godot saves, root `TASKS.md` or owner untracked files. Keep all production ads/billing OFF.

## Apple inspection
1. In official App Store Connect `Apps`, use list/search (including drafts/recent if available) for `Beach Cocktails Merge`, `Beach Cocktails`, and associated owner/team accounts visible in the signed-in session.
2. If a candidate is found, record **only nonsecret facts**: exact app name, bundle ID (expected candidate `com.sekiph82.beachcocktails`), Apple numeric app ID if visible, status (draft/preparing/submitted/live), whether the app record is in *this* account/team. Also check whether in-app purchases exist (count/visible product IDs/status only, no financial/private data).
3. Independently, if accessible, inspect developer Identifiers for a matching **App ID/Bundle ID**, but do not equate Bundle ID registration with an **App Store Connect app record**. Apple Pay Merchant ID is **NOT** StoreKit or proof of an App Store Connect app.
4. If no app is found after inspecting the relevant signed-in Apps listing, report `APP_STORE_CONNECT_RECORD_NOT_FOUND_IN_INSPECTED_TEAM` with account/team label if nonsensitive. Do not claim absolute global nonexistence.

## Google inspection
1. In official Play Console `All apps`, review drafts, unpublished, internal/closed/open testing, archived if accessible and search for Beach Cocktails Merge/Cocktails.
2. If found, record exact name, package/application ID, status and whether monetization setup, in-app products or testers already exist (presence/status only).
3. **Do not mistake** the repo's older `export_presets.cfg` `org.example.bcm.r09slimdebug` or M34 debug `com.sekiph82.beachcocktails.m34debug` for a Play shipping package. A candidate shipping ID needs actual owner/store approval and matching source evidence.
4. If no matching game record exists in a visible authenticated account, report `PLAY_APP_RECORD_NOT_FOUND_IN_INSPECTED_ACCOUNT`; if console login or Play developer verification is incomplete, report the exact visible gate without guessing.

## Deliverables
- First, read `AGENTS.md` and root `TASKS.md` in the canonical `Sekiph82/Beach-Cocktails-Merge` repository and follow non-destructive sync-first rules. Do not edit root `TASKS.md`; only ChatGPT updates project status.
- Publish **ONE** concise immutable GitHub log under `docs/codex-logs/`: `CODEX_LOG_2026-10-19_M34_APP_RECORDS_READ_ONLY_AUDIT_V01.md` (change date if executed later). Record for each platform **FOUND / NOT_FOUND_IN_INSPECTED_ACCOUNT / BLOCKED**, portal domain, source UI section, nonsecret app record/package/bundle, testing/product existence if actually observable, and what **precise next owner decision** or creation step is needed. If screenshots are necessary, redact accounts, emails, billing details and tokens before publication; prefer text only. No secrets in Git. Commit/push log alone to main safely and verify remote main parity.
- If both apps are absent, propose a concrete **creation sequence**, exact proposed iOS bundle `com.sekiph82.beachcocktails` and an **unapproved** candidate Android release ID for owner review, but **do NOT create the applications** without separate approval. Ask only once for combined authorization when real creation is needed.
- If either portal can't be accessed due security, publish a truthful blocked log and stop trying that portal; continue with the other only if separately safe.
- Provide a concise Turkish final summary with the GitHub log link. No fake native/ad/commerce acceptance. M34-006 and M34-007 remain `BLOCKED`.
