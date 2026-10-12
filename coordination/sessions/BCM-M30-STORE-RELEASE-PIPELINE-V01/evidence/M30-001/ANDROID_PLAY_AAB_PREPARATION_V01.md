# M30-001 Android Play AAB Preparation V01

## Outcome

Added `.github/workflows/android-play-aab.yml` as a separate manually dispatched workflow. The existing debug APK workflow is retained unchanged. The new workflow defaults to `validate_only`; a separate `signed_aab` mode is gated by the protected `android-play-upload` environment and four owner-provided upload signing secrets. No secrets were present or inspected, and the workflow was not dispatched.

## Locked configuration

- Godot `4.7.2` and matching Android export templates.
- Explicit package ID `com.sekiph82.beachcocktails`.
- Owner-entered semantic `release_version`; version code uses the workflow run number and attempt (`run_number × 100 + run_attempt`) to keep reruns distinct.
- Minimum API `24`; target API `36`, arm64-v8a only.
- Android Gradle export enabled with `gradle_build/export_format=1` for AAB.
- `package/signed=true`; release export is configured only with the protected owner upload keystore. No debug keystore is configured or generated in this release path. Because Godot exposes one Android release password option, the workflow fails closed unless the owner-configured keystore and alias passwords match.
- Android SDK installation pins platform API 36, Build Tools 36.1.0 and NDK 29.0.14206865, matching Godot 4.7.2's tagged Android Gradle configuration (`compileSdk 36`, `targetSdk 36`, `minSdk 24`, Java 17).
- Missing signing secrets stop before SDK installation, project import, or export. The artifact is a short-retention GitHub Actions artifact; no Play upload, Play Console mutation, or publication step exists.
- Import/export failures fail the job. A generated AAB is checked for non-empty bytes and `jarsigner -verify -certs` output before artifact retention; self-signed upload-key warnings do not invalidate the cryptographic verification.

## Current Play policy

Google's current policy, checked 2026-10-12, requires new apps and updates to target API 36 or higher starting 2026-08-31. The workflow pins API 36; a later policy change still requires rechecking before release. Godot documents the Android export format and min/target SDK options, and its Gradle export path supports AAB output.

References: [Google Play target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en), [Godot 4.7 Android export options](https://docs.godotengine.org/en/4.7/classes/class_editorexportplatformandroid.html), [Godot Gradle builds for Android](https://docs.godotengine.org/en/4.7/tutorials/export/android_gradle_build.html), [Godot 4.7.2 Android Gradle configuration](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/platform/android/java/app/config.gradle).

## Validation boundary

**PREPARED / NOT A SIGNED AAB DELIVERY.** Local review confirms an additive workflow file and its fail-closed configuration. No GitHub Actions run was started, no release build was performed, and no AAB, merged manifest, actual target SDK, permission set, upload signature, device install, or Play validation was verified. A signed AAB and Play App Signing setup remain owner/account required.
