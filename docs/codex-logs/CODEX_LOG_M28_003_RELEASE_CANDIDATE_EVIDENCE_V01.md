# CODEX LOG — BCM-M28-003 — V01

Status: `RELEASE_EVIDENCE_PACKAGE_PREPARED; MILESTONE_AUDIT_PENDING`.

## Scope

- Work item: `BCM-M28-003`, prompt V04 and locked M28 criteria V01.
- Start HEAD: `41609fc289e3df6bac25632b67186b675005aef4`; branch `main`; remote `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Sync preflight: local HEAD and `origin/main` were synchronized at `41609fc`; path-disjoint owner changes remain restored and uncommitted.
- Produced the compact release manifest, separate current/future gates, checklist, and caveat register in this log. Artifact contents were not downloaded; no workflow was rerun and no store upload was attempted.

## Candidate provenance manifest

| Candidate | Source / CI run | Signing and identity | Current purpose | Evidence boundary |
|---|---|---|---|---|
| Android `BeachCocktails-apk`, artifact `11679690170`, 145,267,886 bytes | SHA `b2e09946c6a9a5d7f8254934425d335ffd6f2edf`; run [38078255160](https://github.com/Sekiph82/Beach-Cocktails-Merge/actions/runs/38078255160), success | CI-generated debug signature; ID `com.sekiph82.beachcocktails`; run-number version; icon points to tracked app icon | Controlled manual sideload/family test | Build/upload verified; Android device install and compatibility not verified; not a Play release AAB or production signing |
| iOS `BeachCocktails-ipa`, artifact `11674780517`, 146,697,875 bytes | SHA `c131189a952e5cabfce9a6af326944ffc84defc1`; run [38063815860](https://github.com/Sekiph82/Beach-Cocktails-Merge/actions/runs/38063815860), success | Unsigned Xcode Release app zipped as IPA; bundle ID `com.sekiph82.beachcocktails`; placeholder team ID; iOS version metadata not inspected | Owner-managed WSL/xtool device install for private iPhone testing | Build/upload verified; owner reports successful iPhone use and accepts graphics/effects/gameplay. Action itself does not create App Store-signed IPA; package bytes not downloaded or hash-verified |

Artifact expiry recorded by GitHub: Android `2027-01-08 19:03 UTC`; iOS `2027-01-08 15:29 UTC`. Artifact retention is temporary; keep an owner-controlled copy and record a SHA-256 before any family distribution if exact-byte provenance is required. The Android and iOS run SHAs differ intentionally because they were built at different times; both run commits are ancestors of start HEAD.

## Release decisions

### CURRENT private family/device testing: `GO WITH SCOPE LIMITS`

- iPhone: `GO / OWNER-ACCEPTED` for the owner's tested device and graphics, effects, and gameplay only, using the owner-managed installer. This does not represent broad iPhone/iPad compatibility or store signing.
- Android: `GO / TEST CANDIDATE` for controlled sideload/family QA using the existing debug APK. The successful pipeline and debug signature make it a testing artifact; Android device installation/behavior is still an open test, not an acceptance pass.
- Keep distribution private and manual. Do not publish to Play, App Store, or TestFlight under M28.

### FUTURE public Google Play + Apple App Store: `NO-GO`

Neither existing artifact is a public-store candidate. Android is debug-signed APK output, not a release-signed Android App Bundle. iOS is explicitly unsigned, has a placeholder team ID, and does not establish an App Store provisioning/export path. Privacy/store declarations, final package metadata, device coverage, listing material, and platform review are not complete. No platform approval is claimed.

## Minimal private-test checklist

1. Use the still-unexpired artifacts from the recorded run IDs; independently record downloaded file SHA-256 and keep the run/source SHA beside the file.
2. Keep the Android debug APK on a private testing channel; verify installation and launch on the intended Android device before inviting family testers.
3. For iPhone, use only the owner's existing WSL/xtool install process and credentials; never copy or execute `iPhone_Yukle.bat` from this task.
4. On each tester device, verify first launch, a save-changing action, force close/relaunch, background/resume, and airplane-mode play. Record model, OS version, artifact SHA, and outcome without UDIDs or account secrets.
5. Capture issues and stop distribution if installation, save recovery, privacy disclosure, or crash behavior differs from the stated private-test scope.

## Prioritized future public-release backlog

1. **P0 — Signing and provenance:** configure protected release credentials and reproducible build identity. Android: production key custody/Play App Signing decision and signed AAB pipeline. Apple: valid developer team, App ID, distribution certificate/profile, signed archive/export and upload path. Never store credentials in Git or logs. Apple explains App Store provisioning in [Create an App Store provisioning profile](https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile); Google explains [Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756?hl=en-GB).
2. **P0 — Privacy and package audit:** inspect final APK/IPA manifests, permissions, minimum OS/API, bundle identity/version/build, icons, included addons/SDKs and privacy manifests; verify no developer-only capability or unintended permission ships. Complete Apple privacy policy/details and Google Data safety/App content based on actual data flows.
3. **P1 — Release QA:** expand Android/iOS device and OS coverage; cold install/upgrade, persistence and recovery, interruption/background/resume, offline, crash/log handling, accessibility, and performance. Keep owner-approved visuals/gameplay frozen unless a concrete defect is reproduced.
4. **P1 — Store listing readiness:** confirm registered package/App ID ownership, display name, versioning, screenshots, descriptions, age/content rating, support/privacy URLs, export/compliance answers, and review notes. Store-specific declarations/review remain pending until the owner explicitly starts that publication phase.

## Caveat register

| ID | Priority | Caveat | Evidence needed to close |
|---|---|---|---|
| M28-C01 | P0 public | Android artifact is debug-signed APK; no release AAB/signature | Owner-approved Play signing plan and protected release pipeline |
| M28-C02 | P0 public | iOS action produces unsigned IPA; placeholder team ID; no explicit version override | Valid team/App ID, distribution signing/provisioning/export, bundle/version inspection |
| M28-C03 | P0 public | Final package permissions, minimum OS/API, generated plist/manifest, and transitive privacy manifests not inspected | Package-level audit of release candidates and dependency inventory |
| M28-C04 | P1 private | Android device install and behavior not owner-accepted in evidence reviewed | Device install/launch/save/resume/offline report per target device |
| M28-C05 | P1 private/public | Owner iPhone acceptance covers one device and graphics/effects/gameplay; no broad compatibility or complete background/termination lifecycle matrix | Additional device/OS and lifecycle QA as the release audience expands |
| M28-C06 | P1 public | No App Store privacy policy/details, Play Data safety/App content, listing, rating, screenshots, or review package evidence in repository | Owner-approved store disclosures and complete store metadata |
| M28-C07 | P2 | `project.godot` project name is `CocktailMerge`; actual iOS display label not checked from artifact | Inspect final iOS package and confirm intended display name |
| M28-C08 | P2 | Four historical rotated diagnostics remain unrecovered; M27 owner accepted the residual caveat | No M28 action; preserve the owner ruling and avoid claiming those logs were recovered |

This register is a release-readiness evidence list, not a new live status tracker. `TASKS.md` was not modified.

## Commands, checks, and publication

- Reconciled the evidence package against both Actions run/artifact metadata, the iOS/Android workflow source, M27 builder logs, and the owner M27 ruling.
- No artifact download, build, device test, store upload, or test suite was performed. Exact downloaded-artifact SHA-256 and final app metadata remain unverified.
- Files changed for this child: this immutable log only. End HEAD/final publication SHA is the docs-only publication commit containing this log; see the master handoff equality check. `TASKS.md` remained unchanged.
