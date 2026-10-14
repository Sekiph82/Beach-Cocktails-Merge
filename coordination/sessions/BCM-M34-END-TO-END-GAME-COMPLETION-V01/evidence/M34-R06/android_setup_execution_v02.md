# R06 V02 Android setup — execution correction

This file records the later successful installation performed after the immutable V01 builder log. It supersedes only the Android setup outcome in `docs/codex-logs/CODEX_LOG_M34_R06_V02_DISK_RECOVERY_ANDROID_SETUP_V01.md`; that log remains unchanged.

## Capacity and install

- C: free before the package install: 91,453,231,104 bytes (85.17 GiB). Conservative peak budget: 15 GiB; the required 25 GiB floor and preferred 40 GiB reserve both passed.
- C: free after setup and the bounded probes: 90,264,719,360 bytes (84.04 GiB). Tooling plus import/test activity did not approach the reserve threshold.
- Install root: `C:\Users\sekip\AppData\Local\BCM-M34-Android-4.7.2`. No Desktop folder, shortcut, or global PATH change was made.
- Temurin OpenJDK 17.0.20.1+1, SHA-256 `e53a79c3c3d86865bd7e787903884331068e71321714ffd44f145785affc7cb0`; `java -version` succeeded.
- Android command-line tools revision 22.0, archive SHA-256 `90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a`. `sdkmanager --licenses` received yes responses for all eight prompts and wrote the license markers listed in `android_setup_manifest_v02.json`; this includes optional Preview, Google TV/GDK, XR, and system-image license IDs beyond the packages installed here. No corresponding preview, TV, XR, or system-image package was installed. This broader-than-needed license acceptance is disclosed for audit. The full interactive license text remains in the local console capture and is not duplicated into the repository.
- Installed SDK packages: `platform-tools` 37.0.1; `platforms;android-35`; `build-tools;35.0.1`; `ndk;28.1.13356709`; `cmake;3.10.2.4988404`. `adb version` succeeded (1.0.41 / 37.0.1).
- Godot 4.7.2 templates archive SHA-512 `ca4d71c4d7b81dfc15d1a98baa07534aa95b03fdda78a0075b06672e1648d2e5f40980c9adc28d23e1b92e732ee7bf3461997aa804af74ec2fcd7a93ccb84079`, verified against the official release checksum. The three Android template entries were installed to `%APPDATA%\Godot\export_templates\4.7.2.stable`: debug APK SHA-256 `59E0073F0FA59F552684A861D8F4266B0B34B488A140D6657EAC7DD70D1A0A0D`, release APK `6D1BB2CFA126A1B1C87E064A35B3CBD181BEF0EC784DEC1EFD1D64DFFA8BE6CB`, and source ZIP `A15416B528EFB0A19A7D187E4D9F4E5336D0689144B111329FB4BD12C4447AD3`.
- Godot's user editor settings now point `export/android/java_sdk_path` and `export/android/android_sdk_path` to the task-scoped JDK and SDK. The prior settings file was copied to the install root first (SHA-256 `E9C3C3EC1F7FFDEF6DCC4222B42CF7D823877BFD5A5A806A603259C7AB2D02A2`); the resulting settings SHA-256 is `427E2CE6A6A6B3518D9896AF050AC14E11D215ABE75F3BEBD49A7A29D705798F`.
- Original verified archives remain in the task download folder. Removing the five exact files (1,627,828,502 logical bytes) was rejected by execution policy before PowerShell launched. No alternative deletion mechanism was tried. The current reserved capacity remains over 40 GiB.

## Verification and limits

- `java -version`, `adb version`, `sdkmanager --list_installed`, and `godot --version` succeeded. Installed package identities and license marker hashes are recorded in `android_setup_manifest_v02.json`; the raw command captures remain local.
- The project has no `export_presets.cfg`, so no APK export was attempted. No device, signing key, store, ad account, or payment account was configured.
- A clean Godot editor import reached `100%`/`DONE`, then Godot exited with native code `-1073741819` during editor shutdown. It had changed one generated plugin UID in the isolated worktree's `project.godot`; that one-line generated change was restored and the worktree file now matches HEAD. `godot_editor_import_summary.txt` records the result and SHA-256 of the locally retained raw console file.
- Test outcome correction is in `regression_run_summary.json`: Economy passed 24/24; Daily Rewards produced 35 passes then failed in `application_shell.gd`/probe initialization; navigation produced 4 passes then failed in `campaign_navigation_controller.gd`/probe initialization. The two failed probes emitted fallback warnings for invalid World Map and main-scene UIDs. Their exact captured output is retained. Neither production code nor tests were changed.
- `protected_state_after_android.json` confirms the seven dirty tracked paths, 15 untracked files, canonical `project.godot`, `TASKS.md`, and all 72 stashes still match their before-task snapshot.

## Publisher references

- [Godot 4.7 Android export requirements](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html)
- [Godot 4.7 export templates](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_projects.html)
- [Android Studio command-line tools](https://developer.android.com/studio)
- [Android SDK Manager](https://developer.android.com/tools/sdkmanager)
- [Temurin 17.0.20.1+1 release](https://github.com/adoptium/temurin17-binaries/releases/tag/jdk-17.0.20.1%2B1)
- [Godot 4.7.2 official archive](https://godotengine.org/download/archive/4.7.2-stable/)
