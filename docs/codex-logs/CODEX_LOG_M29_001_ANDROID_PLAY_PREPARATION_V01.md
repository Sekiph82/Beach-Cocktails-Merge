# CODEX LOG — BCM-M29-001 — V01

Status: `SOURCE_INVENTORY_COMPLETE; STORE_SIGNING_AND_PACKAGE_EVIDENCE_OPEN`.

## Authority and scope

- Work item: `BCM-M29-001`, M29 master prompt V01 and `BCM_M29_AUDIT_CRITERIA_V01.md`.
- Start HEAD: `4d2fd67dd6e6472dd09762994a61d522a9f07618`; branch `main`; remote `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- The synchronized `HEAD` and `origin/main` matched before review. The canonical Desktop checkout contains seven pre-existing tracked owner diffs, including `project.godot`, plus five untracked owner-evidence groups. They were preserved, left unstaged, and excluded from this task. `project.godot` was inspected from synchronized `HEAD`, not from the owner's dirty working copy.
- Read-only inspection of `.github/workflows/android-apk.yml`, M28 evidence logs, current Google Play requirements, and project source. No workflow was triggered, artifact downloaded, credential accessed, build run, store action taken, or Android device acceptance claimed.

## Existing workflow and package identity

- `.github/workflows/android-apk.yml` is a manually dispatched private-test workflow. It accepts a source ref, uses Godot `4.7.2`, grants `contents: read`, generates an ephemeral debug keystore on the runner, and exports `build/BeachCocktails.apk`.
- Export settings specify package ID `com.sekiph82.beachcocktails`, display name `Beach Cocktails Merge`, arm64-v8a only, `versionCode = GITHUB_RUN_NUMBER`, and version name `0.1.<run number>`. This is a debug APK workflow; it does not produce an Android App Bundle (AAB), use a production upload key, or set up Play App Signing.
- The workflow does not pin a Play release target API or minimum API in its generated export preset. The actual target/minimum API, merged manifest, permission set, signing certificate, and exported metadata remain unverified because no package was built or inspected. No tracked `export_presets.cfg` exists; the workflow synthesizes a CI-only preset.
- Existing M28 evidence records Android run `38078255160` and artifact `11679690170` as a successful debug APK for controlled testing. No Android owner-device acceptance is recorded.

## Play requirements and remaining gates

- Google Play requires new apps to use Android App Bundles; Play App Signing is configured through Play Console for the first release. The owner must decide upload-key custody and the Play App Signing enrollment/key choice before any production signing setup.
- As of the current Google Play target API page, starting August 31, 2026, new apps and updates must target Android 16/API 36 or later; the published extension deadline is November 1, 2026. Current workflow configuration does not establish that requirement. This is a release blocker until a pinned export configuration and generated AAB are inspected.
- Owner/account actions remain: confirm Play developer account and package-ID ownership, Play App Signing choice/key custody, release version policy, supported Android/minimum API/device matrix, and authorize any protected signing setup. No secrets should be placed in Git or logs.
- Play Console work remains: complete Data safety and App content declarations from the final package and dependency data-flow inventory; choose target audience and ads status; complete the IARC content-rating questionnaire; prepare listing assets/text, support contact, privacy-policy URL, app access/review instructions, and any permission declarations required by the actual manifest.

## Evidence limits and validation

- Official references reviewed on 2026-10-12: [Android App Bundle and app setup](https://support.google.com/googleplay/android-developer/answer/9859152), [Play App Signing and app bundles](https://support.google.com/googleplay/android-developer/answer/9842756), [target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en), [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en), [content ratings](https://support.google.com/googleplay/android-developer/answer/9859655?hl=en), and [target audience/App content](https://support.google.com/googleplay/android-developer/answer/9867159?hl=en).
- No test or build was run. The source and workflow findings are an inventory, not package-level acceptance.
- End HEAD / M29 evidence publication commit: `7c44b008724595de20142f10480ab979ccc1a896`. At that publication, local `HEAD`, `origin/main`, and live `refs/heads/main` matched; ahead/behind was `0/0`. The final repository receipt is in the master log.
- `TASKS.md` was not modified. This log is builder evidence only; independent audit remains pending.
