# Native build preflight — BCM-M34-006/007 V03

**Result: Android `BLOCKED_NDK_MISSING`; iOS `BLOCKED_MACOS_XCODE`; no APK/AAB/IPA produced.** This is a local toolchain inventory, not a release sign-off. No emulator, installer, SDK manager mutation, system configuration change, signing identity, or existing owner package was used.

## Android inventory

| Component | Observed | Result |
|---|---|---|
| Godot | `C:\Users\sekip\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe` | Present, 4.7.2 stable |
| Java | `C:\Users\sekip\AppData\Local\Programs\Android Studio\jbr\bin\java.exe` | Present, OpenJDK 25.0.3; not compatible with the bundled Gradle 8.11.1 runtime (Java 25 support starts in Gradle 9.1). No JDK 17 found in the bounded standard installation paths checked. |
| Android SDK | `C:\Users\sekip\AppData\Local\Android\Sdk` | Present |
| SDK platform | `platforms\android-36` | Present |
| Build tools | `build-tools\36.0.0`, `build-tools\36.1.0` | Present |
| Platform tools | `platform-tools\adb.exe` | Present; `adb devices -l` reported no devices |
| SDK manager | `cmdline-tools\latest\bin\sdkmanager.bat` | Present; not run |
| NDK | `C:\Users\sekip\AppData\Local\Android\Sdk\ndk`, `...\ndk-bundle`, `C:\Program Files\Android\Android Studio\sdk\ndk`, `C:\Users\sekip\AppData\Local\Programs\Android Studio\sdk\ndk` | All absent |
| Godot Android template | `%APPDATA%\Godot\export_templates\4.7.2.stable\android_source.zip` and debug/release APK templates | Present; archive contains `gradlew`, `gradlew.bat`, wrapper JAR/properties, `build.gradle`, `settings.gradle` |
| Gradle wrapper | `android_source.zip` → `gradle/wrapper/gradle-wrapper.properties` | Pins Gradle 8.11.1. Java 25 is outside this wrapper's documented runtime support; a cached Gradle 9.3.1 does not change the template's pinned wrapper. |
| Gradle distributions cache | `%USERPROFILE%\.gradle\wrapper\dists` | Gradle 8.11.1 and 9.3.1 caches observed; no system `gradle` command |
| Godot Android editor settings | `%APPDATA%\Godot\editor_settings-4.tres` | File absent; no configured custom SDK path recorded there |

**Blocking prerequisites:** use a supported JDK for the existing Gradle 8.11.1 wrapper and install the missing NDK/CMake in an owner-approved SDK location; then configure Java SDK, Android SDK and NDK paths in Godot Editor Settings. Godot 4.7's Android setup recommends OpenJDK 17 and lists NDK `28.1.13356709` (r28b) plus CMake `3.10.2.4988404`. A minimal SDK package command after owner-authorized setup is `sdkmanager --sdk_root="C:\Users\sekip\AppData\Local\Android\Sdk" "ndk;28.1.13356709" "cmake;3.10.2.4988404"`; install a compatible JDK 17 separately. This command was recorded, not run. Godot's official requirements are in [Exporting for Android](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html); Gradle documents Java 25 runtime support beginning at 9.1 in its [compatibility matrix](https://docs.gradle.org/current/userguide/compatibility.html). Android's current 16 KB page guidance says NDK r28+ emits 16 KB-aligned ELF segments by default; all prebuilt native libraries must also comply. Source: [Android 16 KB page-size guidance](https://developer.android.com/guide/practices/page-sizes).

**Minimal next procedure after owner-authorized NDK setup:** confirm Godot's SDK/JDK/NDK paths; export a separate debug-only package with application ID `com.sekiph82.beachcocktails.m34preview`; inspect the resulting manifest, permissions, target/min SDK, enabled ABI set, native library alignment, package contents and SHA-256. Do not use the production application ID, release signing, live ad configuration or payment grants. A debug APK is not a Play AAB or public-release pass. No package was produced because NDK is absent.

## iOS inventory

This Windows host has no `xcodebuild` command or local macOS/Xcode environment. Godot's iOS export requires macOS and Xcode. An owner-provided Mac with a current supported Xcode is a hard gate for generating and signing a device IPA. No GitHub Actions or remote signing was used. Keep the iOS bundle identity, signing team/profile, privacy manifest, icon asset catalog and device validation for that Mac handoff; do not alter the personal sideload workflow.

## Monetization and package boundaries

- Preserve future AdMob/consent/reward implementation sources in the development project.
- Production ad delivery remains disabled. Do not claim ads, rewarded delivery, UMP/ATT consent, server-side reward verification, or device behavior as implemented/accepted without signed-package and real-device evidence.
- Store products remain `buyable=false`; this preflight creates no purchase grant or billing claim.
- Store app IDs, signing credentials and publishing account settings remain owner-controlled.

## In-game privacy/support route inspection

Static inspection of `scripts/campaign/application_shell.gd::_build_settings()` shows audio, mute, haptics, reduced-motion, high-contrast and tutorial controls plus navigation buttons; there is no Privacy or Support button and no URL configured by Settings. No dead URL was found and no production route was added. A visible Settings screenshot was not obtained because the capture session ended during the attempt to open that screen, so visual behavior remains `UNVERIFIED`; no runtime interaction changes were made.

## Official platform references

- Godot 4.7 Android export setup documents JDK, SDK, NDK/CMake, the Android SDK path and the template requirements: [Exporting for Android](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html).
- Gradle 8.11.1's wrapper/JDK mismatch is checked against Gradle's [Java compatibility matrix](https://docs.gradle.org/current/userguide/compatibility.html).
- Godot 4.7 iOS export explicitly requires macOS with Xcode: [Exporting for iOS](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_ios.html).
- Android's 16 KB page-size guidance recommends verifying native ELF alignment and prebuilt libraries; NDK r28+ emits 16 KB alignment by default: [Android 16 KB page-size guidance](https://developer.android.com/guide/practices/page-sizes).
