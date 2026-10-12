# CODEX LOG — BCM-M29-002 — V01

Status: `SOURCE_INVENTORY_COMPLETE; DISTRIBUTION_SIGNING_AND_PACKAGE_EVIDENCE_OPEN`.

## Authority and scope

- Work item: `BCM-M29-002`, M29 master prompt V01 and `BCM_M29_AUDIT_CRITERIA_V01.md`.
- Start HEAD: `4d2fd67dd6e6472dd09762994a61d522a9f07618`; branch `main`; remote `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- The synchronized `HEAD` and `origin/main` matched before review. Seven pre-existing tracked owner diffs and five untracked owner-evidence groups were preserved and excluded. The dirty owner `project.godot` was not treated as canonical source.
- Read-only inspection of `.github/workflows/ios-ipa.yml`, synchronized `project.godot`, M28 evidence logs, and current Apple guidance. No workflow was triggered, artifact downloaded, Apple account inspected, credential accessed, build run, or store action taken.

## Existing workflow and identity

- `.github/workflows/ios-ipa.yml` is manually dispatched on `macos-latest`, installs Godot `4.7.2`, creates an export preset in CI, and uses bundle ID `com.sekiph82.beachcocktails` with placeholder team ID `AAAAAAAAAA`.
- The preset requests an Xcode project export. The workflow runs `xcodebuild` with code signing disabled and empty signing identity, then zips the unsigned `.app` into `BeachCocktails.ipa`. It does not create a signed App Store archive, use a distribution certificate/profile, or upload to App Store Connect.
- The iOS preset has no explicit app version/build-number policy. `project.godot` names the project `CocktailMerge`; the actual generated iOS display name, bundle version/build, minimum iOS deployment target, entitlements, privacy manifest contents, and final package identity were not inspected. The shared icon is `assets/ui_assets/brand/app_icon.png`.
- Prior M28 evidence records successful production of an unsigned IPA for the owner's private iPhone install path. It does not establish App Store signing or upload readiness.

## Apple requirements and remaining gates

- App Store Connect requires an app record with an explicit App ID matching the bundle ID and an App Store Connect provisioning profile paired with a distribution certificate, unless Xcode automatic signing manages distribution provisioning. The current workflow has neither a real team ID nor a signing/export path.
- Apple states that, starting in 2026, iOS apps uploaded for customer distribution or TestFlight must be built using Xcode 26 or later. The workflow uses floating `macos-latest` and does not assert or record the effective Xcode version; the upload toolchain remains unverified.
- Owner/account actions remain: confirm Apple Developer Program/team access, registered App ID and ownership of `com.sekiph82.beachcocktails`, signing/certificate and provisioning approach, bundle display name, supported iOS/iPadOS floor, and version/build numbering. Any certificate/private key/API token must remain in protected account or CI secret storage and must not be logged.
- App Store Connect preparation remains: create/confirm the app record, supply privacy-policy URL and accurate app privacy answers, complete age-rating questionnaire, app name/subtitle/category/description/keywords, localized screenshots and previews, support/contact details, export-compliance answers, review notes/access, and copyright/content-rights metadata as applicable. These answers require owner-supplied decisions and final package inspection.

## Evidence limits and validation

- Official references reviewed on 2026-10-12: [App Store provisioning profile](https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile), [upload builds and Xcode requirements](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds), [manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy), [age rating](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/), [privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), and [required-reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).
- No test or build was run. Source/workflow inspection is not a signed-package, device, or account acceptance result. The master log records final publication SHA and parity after publication.
- `TASKS.md` was not modified. This log is builder evidence only; independent audit remains pending.
