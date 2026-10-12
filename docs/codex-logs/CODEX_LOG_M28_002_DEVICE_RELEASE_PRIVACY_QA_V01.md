# CODEX LOG — BCM-M28-002 — V01

Status: `SOURCE_REVIEW_COMPLETE; DEVICE_AND_PACKAGE_CHECKS_RETAINED_AS_CAVEATS`.

## Scope and method

- Work item: `BCM-M28-002`, prompt V04 and locked M28 criteria V01.
- Start HEAD: `41609fc289e3df6bac25632b67186b675005aef4`; branch `main`; remote `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Sync preflight: after the authorized path-disjoint safe sync, local HEAD equaled `origin/main` at `41609fc`; 0/0. Seven tracked owner diffs and all untracked owner evidence were restored/preserved. The retained stash is `owner-local-safe-sync-9667a1c`.
- Read-only review of production project settings, export workflows, save/settings source, M27 builder evidence and the M28 owner ruling. No Godot command or device test was run: no code changed, the prompt forbids redundant rebuilds, and device checks require owner devices.
- No artifact was downloaded. No credentials, UDIDs, or signing secrets were requested, inspected, or logged.

## Findings by area

### Platform identity, orientation, icon, and permissions

- `project.godot` sets portrait handheld orientation (`window/handheld/orientation=1`) and a 720×1280 portrait viewport. The iOS and Android CI presets use bundle/package ID `com.sekiph82.beachcocktails` and refer to `assets/ui_assets/brand/app_icon.png` (tracked image, 126,547 bytes).
- `project.godot` currently names the project `CocktailMerge`; Android explicitly sets package name `Beach Cocktails Merge`. The iOS workflow does not override the display name. Actual exported iOS display-name metadata was not inspected, so its on-device presentation remains unverified.
- No app-level camera, microphone, location, tracking, or notification usage-description strings or privacy manifest were found in the reviewed `project.godot`, `scripts/`, `scenes/`, `data/`, or export workflow. This source search does not establish the generated Android manifest/iOS Info.plist or transitive SDK manifests; package-level permissions and privacy manifests remain unverified.
- The production game code reviewed uses bundled `res://` resources and local `user://` saves. No gameplay network, analytics, advertising, or account service call was found in the reviewed app scripts. `addons/godot_ai/runtime/game_helper.gd` registers Godot debugger messages for development captures and is documented to sit idle when the exported release has no active debugger. A complete transitive dependency/data-flow and final-package inspection was not performed.

### Persistence and recovery

- `SaveManager` stores campaign progress in `user://campaign_save.json`, maintains a `.bak`, writes through a flushed temporary file and rename, validates schema, and can recover a valid backup or migrate the legacy score. `UserSettings` uses `user://user_settings.json`; onboarding uses `user://onboarding_state.json`.
- M27 builder evidence reports campaign progression/restart persistence across the full 100-level sequence and M11 save migration/recovery regression coverage. That is repository/test evidence, not an independent Android or iPhone cold-install/upgrade acceptance run.
- `GameManager` handles `NOTIFICATION_APPLICATION_PAUSED` and `NOTIFICATION_APPLICATION_RESUMED` by pausing/resuming the session bridge. No owner device evidence was found for force-quit during an unsaved transition, low-memory termination, phone call interruption, background duration, OS upgrade, or restore behavior. Such lifecycle scenarios remain device QA caveats.
- Core game content and save paths are local; offline operation is supported by the source design. A device network-disabled run was not performed, so offline remains source-supported but not physically verified.

### Existing acceptance evidence and scope

- `OWNER_M27_ACCEPTANCE_V01.md` records the owner's real iPhone graphics/effects/gameplay acceptance and explicitly states that one phone does not establish broad device compatibility.
- It also records that a formal per-effect paired FULL/REDUCED visual matrix was not produced; owner acceptance closes that M27 gate without representing the matrix as complete.
- `CODEX_LOG_M27_MASTER_V02.md` reports the 100-level progression and restart checkpoints, 30/30 M01–M20 regression suite, 100-level save/4T evidence, plugin fallback scenarios, 832 protected asset hashes, and two clean 16-capture GL QA sets. M27's older independent audit was superseded for closure by the later owner ruling; its unclosed visual-matrix finding remains a disclosed evidence limitation, not a new M28 retest trigger.
- Android build completion exists; no Android owner-device installation/compatibility acceptance is recorded in the supplied M28 evidence.

## Privacy and store disclosure boundary

Source inspection is not a privacy declaration. Before public submission, inventory the final app and all included third-party code, determine actual collection/sharing/tracking and required-reason APIs, then complete Apple App Store Connect privacy details/privacy policy and Google Play Data safety/App content declarations accurately. Apple documents the App Store privacy disclosures and privacy manifests at [User Privacy and Data Use](https://developer.apple.com/app-store/user-privacy-and-data-use/) and [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy). Google documents Data safety in [Play Console Help](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-EN).

## Child result

`PARTIAL — source architecture and existing regression evidence support persistence, portrait identity, and offline use; Android device acceptance, generated package metadata/permissions, broad lifecycle behavior, and final privacy-manifest/data-flow validation remain UNVERIFIED.`

No workflow/config/product changes were justified by this evidence review. `TASKS.md` was not modified.

## Commands, checks, and publication

- Read `project.godot`, `.github/workflows/android-apk.yml`, `.github/workflows/ios-ipa.yml`, save/settings/lifecycle source, M27 logs and the owner ruling.
- `rg` source searches for privacy declarations, permission usage, network/analytics APIs, app identity and save paths found no app-level privacy usage strings or game-service network/analytics calls in the reviewed production app paths. This search is not a generated package or transitive dependency audit.
- Confirmed existing M27 evidence references instead of rerunning gameplay tests. No tests or Godot commands were run because no implementation changed and the prompt prohibits redundant builds.
- Manual device tests not performed: Android install/use, iPhone lifecycle interruption/resume/offline matrix, broad device/OS coverage, package manifest inspection, and privacy declaration review against a final package.
- Files changed for this child: this immutable log only. End HEAD/final publication SHA is the docs-only publication commit containing this log; see the master handoff equality check. `TASKS.md` remained unchanged.
