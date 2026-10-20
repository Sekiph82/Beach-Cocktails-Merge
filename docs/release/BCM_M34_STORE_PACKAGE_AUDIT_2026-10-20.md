# BCM-M34-006/007 Store Package Hygiene and Readiness Audit

**Status: source/package hygiene implemented; public release NO-GO.** This is builder evidence, not the independent acceptance audit or a store submission. The two produced artifacts are Godot resource packs only, marked `NOT SHIPPING`; neither is an Android App Bundle (AAB) nor an iOS application archive/IPA.

## Repository and scope

- Canonical checkout: `main`, `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge`.
- Safe sync start: local `main` was 9 commits behind `origin/main`, with no ahead commits. The tracked worktree was clean; existing owner-local untracked paths were inventoried and preserved. A path-disjoint fast-forward synchronized the checkout to `381974c35cbe637a4dc072c781ecade0722f6cff` before reading this task prompt.
- `TASKS.md` was not modified. No owner untracked file, source asset, historical proof, save, credential, or GitHub Actions workflow was changed.
- Work covers two separate nonshipping export presets, package-boundary fixes, source tests, real PCK exports and their file/hash manifests, and this readiness report.

## Changes made

- Added `Android Store Candidate (NOT SHIPPING)` and `iOS Store Candidate (NOT SHIPPING)` presets. The Android profile targets API 36, arm64, min SDK 24; both profiles use the planned `com.sekiph82.beachcocktails` identifier and clearly placeholder versions. Android signing is off, iOS exports a project only, and neither preset enables the native monetization feature tags.
- Both presets exclude coordination/evidence, docs, tests, tools, backend, M32 local validation evidence, Godot AI, Google Play Billing, native AdMob binaries, editor-only third-party plugin files, development adapters, owner playtest code, retired M17/M32 tooling, source/master-art folders, and the owner-local `shop_catalog.json`. Runtime JSON is explicitly included, including `content_generation_profiles_m33.json`, which the island-level JSON references.
- Removed static preloads for AdMob and Play Billing test adapters from `campaign_navigation_controller.gd`. Their source remains available to debug builds through guarded dynamic loading; the release package can now omit those test adapters without breaking the production script parse.
- The owner playtest console remains dynamically loaded only for debug builds. AdMob Android/iOS native dependency injection is explicitly opt-in through the `m34_admob_native_enabled` feature; Google Play Billing native injection is similarly gated by `m34_store_billing_enabled`. AdMob runtime API/configuration and rewarded-placement semantics remain in source. Candidate exports omit the AdMob binaries and all Billing plugin content.
- Extended the export-boundary checker and regression tests to handle quoted Godot preset values, verify both candidate presets and runtime JSON coverage, distinguish a static check from an inspected PCK, and enforce package checks for AdMob/Billing gates and debug-only adapters.
- No source assets or historical evidence were deleted. The existing M34-005 inventory records 23 `REVIEW`, 0 `DELETE`; no asset met its proof threshold for removal. The tracked tree has no audio files in the reviewed WAV/OGG/MP3/FLAC/M4A formats.

## Actual PCK content evidence

Both packs were exported locally with Godot 4.7.2 and opened through Godot's `ProjectSettings.load_resource_pack`, `DirAccess`, and `ResourceLoader` APIs. The inspector confirmed the main scene loads, all 18 required runtime JSON paths are present, the AdMob runtime API is present, and the ads policy has `default_enabled=false` with every placement disabled.

| Candidate PCK | Files | Size | SHA-256 | Content result |
|---|---:|---:|---|---|
| Android | 645 | 116,587,916 bytes | `0ba9e1d0629d89fe8b59f6ec297846975f3992b65527789b07dfb30463eb161d` | PASS; 0 forbidden entries |
| iOS | 645 | 116,587,980 bytes | `1c1074c78ab04b15085d96e008d9a5f94cfad5aea0373b87e6a6d8f5cccec1e8` | PASS; 0 forbidden entries |

The inspected packs contain no `coordination/`, `docs/`, `tests/`, `tools/`, `backend/`, Godot AI, Billing, AdMob native binary, M17/M32 validation source, playtest console, or test-adapter entries. The `_mcp_game_helper` autoload is stripped by the Godot export hook; the export log records that removal, and the helper is absent from each pack. Godot's all-resources export still emits 383 `.import` files and 14 generated `.translation` sidecars (358,739 combined bytes in the Android manifest); these small sidecars are reported as a residual, not misrepresented as absent. The manifests contain per-entry sizes and SHA-256 hashes:

- [Android PCK content manifest](evidence/BCM_M34_ANDROID_CANDIDATE_PCK_MANIFEST_2026-10-20.json)
- [iOS PCK content manifest](evidence/BCM_M34_IOS_CANDIDATE_PCK_MANIFEST_2026-10-20.json)

The complete source repository remains much larger than these packages because historical coordination evidence and source-only assets are preserved. Package footprint is not a signed-install size or a claim that all source artwork is used. The 23 previously reviewed artwork candidates remain in source; their historical “no literal reference found” result is insufficient proof for deletion or exclusion from dynamic loading.

## Monetization and privacy state

- `ads_provider_policy.json` keeps rewarded placements and other ad placements disabled by default. The AdMob runtime API, app/unit configuration, and future native export source remain available in the repository; native SDK injection stays off unless a future export explicitly supplies the opt-in feature tag and completes owner/privacy/device acceptance.
- Store products remain `buyable=false`; product IDs are empty and verified store providers are not configured. No purchase or ad test was conducted against a live service.
- The existing [mobile ads data-practices draft](../privacy/MOBILE_ADS_DATA_PRACTICES_DRAFT_V01.md) is a draft for future optional ads, not a published privacy policy or final disclosure for a signed package. No public privacy/support URL or owner-approved support mailbox was verified. Legal copy, audience/age treatment, UMP, ATT, data retention, and platform declarations remain owner/legal review items.

## Draft listing text (owner review required)

**Title:** Beach Cocktails Merge

**Short description:** Merge colorful drinks, serve To-Go orders, and explore tropical islands.

**Full description:** Merge matching drinks to create bigger cocktails, complete To-Go orders, and explore tropical island stages. Plan each launch, build drink combinations, and find the right merge for each order. Ads and in-app purchases are disabled in this nonshipping candidate build. This draft must be reconciled with the final approved monetization choice and tested release behavior before publication.

**Support draft:** “For help with Beach Cocktails Merge, contact [OWNER-APPROVED SUPPORT EMAIL]. Please do not send passwords or payment details.” Do not publish until the owner supplies a working support mailbox and support/privacy process.

## Store media and icon readiness

- Current `assets/ui_assets/brand/app_icon.png` is 256×256 PNG, RGBA color type, 126,547 bytes; SHA-256 `1b4199b47ee7a92a22fc7133ff0831171ebe1525fbd202173f8a3f7ff6d6af83`. It is undersized for the 512×512 Play listing icon and 1024×1024 App Store icon; no platform-ready marketing icon was produced.
- No Play feature graphic (1024×500) or factual gameplay screenshot set was produced. Screenshots are `CAPTURE_PENDING`, not concepts presented as gameplay.
- Capture spec: obtain 6–8 actual final-build iPhone screenshots at 1179×2556 or 1206×2622, covering Home, gameplay/merge, To-Go completion, results, World Map, boosters, and Daily Rewards where available. For Play, prepare 6–8 factual portrait game screenshots (PNG/JPEG, no alpha for PNG, shortest side at least 320 px, longest side no more than twice the short side and no more than 3840 px), at least two for listing eligibility, plus the separately designed 512×512 icon and 1024×500 feature graphic. Capture from owner-approved real devices running the signed candidate; do not substitute editor previews or generated artwork.

## Release blockers and checks not performed

- Environment has Godot 4.7.2 export templates and can produce/inspect PCKs. It has no `java`, `gradle`, Android NDK 29, or `xcodebuild`; `adb devices -l` returned no attached Android device. A signed AAB, iOS Xcode archive/IPA, platform SDK validation, 16 KB page-size audit, device install/QA, TestFlight/Play track checks, and final store package inspection therefore remain blocked/unperformed.
- No Store Connect or Play Console write, signing/account action, GitHub Actions run, upload, legal agreement, live payment, live ad, or deployment was attempted.
- Store records, approved immutable IDs, final version numbers, support/privacy URLs, icon/feature artwork, age/rating, Data Safety/App Privacy declarations, device validation, and owner launch-mode decision remain unresolved. Public release is **NO-GO on both platforms**.

## Verification run

- `godot --headless --editor --path . --quit` — exit 0, no reported parse errors.
- `python -m unittest discover -s tests -p test_release_export_boundaries.py -v` — 9/9 passed.
- `python tests/run_regressions.py --strict-runtime-errors` — 21/21 passed; isolated user-data sandbox, `saves_created=false`.
- Android and iOS `--export-pack` candidate builds — exit 0 each; both actual PCK inspections PASS as above.
- `python tools/release/check_export_boundaries.py --preset "Android Store Candidate (NOT SHIPPING)" --archive .godot/bcm_release_preflight/android_candidate.pck` — exit 0, static source boundary plus inspected PCK PASS.
- `python tools/release/check_export_boundaries.py --preset "iOS Store Candidate (NOT SHIPPING)" --archive .godot/bcm_release_preflight/ios_candidate.pck` — exit 0, static source boundary plus inspected PCK PASS.
- `git diff --check` and final repository parity are recorded in the immutable Codex execution log after commit/push.
