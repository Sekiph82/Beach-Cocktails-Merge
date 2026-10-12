# M30-003 Store Package Policy Gate V01

## Scope and status

This is a source/configuration inventory only. No signed AAB or App Store IPA was available in the repository during this task, so package-derived permissions, entitlements, linked SDKs, minimum OS/API, version metadata, privacy manifests, and signatures are **UNVERIFIED**. Source observations below are not store privacy declarations. The public release remains **NO-GO** pending a final artifact and owner decisions.

## Observed from repository source/configuration

| Area | Observation | Status |
|---|---|---|
| Android identity | New opt-in workflow pins `com.sekiph82.beachcocktails`, version name is a dispatch input, version code is the workflow run number, min API 24, target API 36, arm64 only, and requests an AAB. | CONFIGURED; signed package not produced |
| iOS identity | New opt-in workflow pins `com.sekiph82.beachcocktails`, uses a dispatch marketing version and run number, and requires an App Store provisioning profile and Apple Distribution identity. | CONFIGURED; signed package not produced |
| Existing family-test paths | `.github/workflows/android-apk.yml` and `.github/workflows/ios-ipa.yml` are preserved unchanged by this task. | SOURCE-CHECKED |
| App icon/name | Android release preset sets package name `Beach Cocktails Merge`; both family workflows reference `assets/ui_assets/brand/app_icon.png`. Synchronized `project.godot` has `config/name="CocktailMerge"`; the actual iOS display name, generated icons, and final package metadata have not been inspected. | SOURCE-CONFIGURED; STORE DISPLAY NAME OWNER-REVIEW REQUIRED; package unverified |
| Addons and helper | `game_feel_flow`, `godot_ai`, and `saltmire_spark` are project dependencies. The synchronized `project.godot` enables the Godot AI plugin and registers its game-helper autoload. Whether editor-only helper/plugin files or any third-party runtime components land in final store binaries is unknown. | SOURCE-OBSERVED; SHIPPED FOOTPRINT UNVERIFIED; OWNER must decide whether to exclude Godot AI from store builds |
| First-party data flow | Reviewed M28/M29 source evidence describes bundled resources and local `user://` saves, with no established first-party analytics, ads, account, or game-service flow. This does not establish complete transitive or final-package behavior. | PARTIAL SOURCE EVIDENCE |
| Third-party/editor data flow | Godot AI source has editor-side telemetry and HTTP/WebSocket integrations; runtime helper behavior and inclusion in release archives have not been inspected. Do not infer a “no data collected” or “no tracking” answer. | UNVERIFIED; OWNER/FINAL-PACKAGE REVIEW |
| Permissions and entitlements | No generated Android manifest, iOS `Info.plist`, code-signing entitlements, or merged dependency permission report was available. | UNVERIFIED |
| Privacy manifest | No `PrivacyInfo.xcprivacy` was identified in the source inventory reviewed for M29. Final SDK/app required-reason API obligations are unknown until the exported binary and dependency footprint are audited. | SOURCE SEARCH ONLY; PACKAGE UNVERIFIED |
| Play and App Store declarations | Data Safety, App Privacy, privacy-policy URL, collection/sharing/tracking/deletion, advertising, target audience, age/content ratings, app access, support/contact, markets/locales, and listing text/assets require owner-approved answers based on final package behavior. | OWNER_REQUIRED |

## Required inspection when signed artifacts exist

1. Android: use `bundletool dump manifest --bundle <AAB> --module base` and `bundletool validate`; record package, version code/name, min/target SDK and every permission from the merged manifest. Verify AAB upload signature with `jarsigner -verify -strict -certs`. Reconcile the full AAB module/dependency inventory and all included addons/SDKs against privacy declarations.
2. iOS: inspect the exported `.ipa` `Payload/*.app/Info.plist`, every embedded framework/plugin, `PrivacyInfo.xcprivacy` files and required-reason APIs; use `codesign -d --entitlements :-` on the archived app and verify signing identity/profile/team/App ID/expiry. Record all privacy-sensitive APIs and permission usage descriptions.
3. Compare the actual artifacts against owner-approved Play Data Safety, App Store App Privacy, age/content ratings, target audience, ads status, policy URL, listing assets, support details and review instructions. Preserve unknowns as `UNVERIFIED`; do not infer answers from source search.

## Owner actions before any public submission

- Configure protected Android upload keystore/alias/password secrets and decide Play App Signing custody in the Google Play owner account.
- Configure Apple Team ID, App Store distribution certificate and App Store provisioning profile as protected CI secrets; verify account/App ID access.
- Decide whether the Godot AI plugin and game-helper autoload should be excluded from store builds; then inspect the exact exported package.
- Approve privacy policy, data collection/sharing/tracking/retention/deletion answers, target audience/children status, ads status, ratings (including applicable beverage/alcohol themes and chance features), app name/listing, support contacts, markets/locales, content rights and review access.
- Perform broader device/OS QA and review final manifests, entitlements, SDK inventory and signed artifact provenance.

## Current external platform requirements checked 2026-10-12

- Google Play new apps and app updates require target API 36 or higher from 2026-08-31: [Play Console target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en).
- Apple uploads require Xcode 26 or later built with the iOS 26 SDK or later since 2026-04-28: [Apple SDK minimum requirements](https://developer.apple.com/news/upcoming-requirements/?id=04282026a).
- The Apple workflow uses the GitHub-hosted `macos-26` runner and independently fails if its actual Xcode/iOS SDK majors fall below those floors: [GitHub-hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).

## Gate result

**PARTIAL / OWNER_REQUIRED.** Separate fail-closed preparation workflows and a package-review checklist are committed, but there was no authorized CI dispatch, no signing secret, no AAB/IPA artifact, no package permission/entitlement/privacy verdict, and no store submission. Public release remains NO-GO.
