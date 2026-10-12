# M30-002 Apple App Store Distribution Preparation V01

## Outcome

Added `.github/workflows/ios-appstore-export.yml` as a separate opt-in workflow. The existing unsigned family-test IPA workflow remains untouched. Default `validate_only` checks the actual runner's Xcode and iOS SDK majors. `signed_export` requires protected owner-provided Team ID, distribution P12/password, and App Store provisioning-profile secrets before signing or archiving. No secrets were present or inspected, and the workflow was not dispatched.

## Signed export gate

- Pinned app identifier `com.sekiph82.beachcocktails`; owner-entered numeric marketing version and workflow run/attempt build number.
- Signed mode runs only from canonical `main`; the owner must also restrict the `app-store-distribution` environment's deployment branches to `main` before adding secrets.
- GitHub-hosted `macos-26`, with runtime checks for Xcode >=26 and iOS SDK >=26. The workflow does not trust the runner label alone.
- Godot `4.7.2` with matching iOS templates exports an Xcode project.
- Protected certificate/profile material is imported into a temporary runner keychain; the profile Team ID, exact App ID, and Apple Distribution identity are checked before export.
- Xcode uses manual signing, the owner profile/team, release configuration, App Store Connect export method, and creates a signed IPA artifact only. There is no App Store Connect API key, upload, TestFlight submission, or public release step.
- Missing or mismatched credentials fail before project export. Archive/export errors stop the job. Temporary signing material is removed in an always-run cleanup step.

## Current Apple platform rule

Apple's requirement effective 2026-04-28 says App Store Connect uploads must be built with Xcode 26 or later using an iOS 26 SDK or later. The workflow validates both actual versions. GitHub's published runner reference lists `macos-26`; the build still rejects an image that does not meet Apple's current toolchain floor.

References: [Apple SDK minimum requirements](https://developer.apple.com/news/upcoming-requirements/?id=04282026a), [Apple upload-build requirements](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/), [GitHub-hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [Godot 4.7 iOS export options](https://docs.godotengine.org/en/4.7/classes/class_editorexportplatformios.html), [Godot iOS export guide](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_ios.html).

## Validation boundary

**PREPARED / BLOCKED ON OWNER CREDENTIALS; NO SIGNED IPA DELIVERY CLAIM.** No Xcode archive/export, artifact inspection, device test, account change, upload, or submission occurred. A valid App Store distribution certificate/profile and account-side app record remain owner required.
