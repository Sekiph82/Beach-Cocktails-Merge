# BCM-M34-R06-003 — Windows Android setup and footprint plan

**R06 V02 owner approval is present.** The capacity gate passed. During the live inventory, the bounded `%LOCALAPPDATA%\BCM-M34-Android-4.7.2` root appeared with three downloaded archives and empty `jdk17`, `sdk`, and staging directories. Their hashes matched the official publisher values. No installer process was active. The actual extraction/install command was rejected by the execution shell's policy review before launch (`CreateProcess ... Rejected ... blocked by policy`); no JDK/SDK files or Android templates were installed by that command, and no alternate command path was attempted. Existing 4.7.2 templates contain web files only. See `android_install_outcome.md` for exact boundary and current measurements.

## Pinned requirements and official sources

- Godot: **4.7.2 stable**, including matching Android export templates from [the official archive](https://godotengine.org/download/archive/4.7.2-stable/). Template asset: `Godot_v4.7.2-stable_export_templates.tpz`.
- Java: **OpenJDK 17 x64**. Suggested current archive: Eclipse Temurin `17.0.20.1+1`, `OpenJDK17U-jdk_x64_windows_hotspot_17.0.20.1_1.zip`; official release and matching `.sha256.txt` asset: [Temurin 17 release](https://github.com/adoptium/temurin17-binaries/releases/tag/jdk-17.0.20.1%2B1). The pinned release was the latest surfaced on 2026-10-14; recheck its published checksum before use.
- Android SDK packages per [Godot 4.7 Android export docs](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html): Platform-Tools `35.0.0+`, Build-Tools `35.0.1`, Platform `android-35`, Command-line Tools `latest`, CMake `3.10.2.4988404`, NDK `28.1.13356709` (r28b).
- Command-line tools archive: [official Android Studio downloads](https://developer.android.com/studio#command-line-tools-only). Check the current Windows archive checksum on that page; install to `sdk\cmdline-tools\latest` so `bin\sdkmanager.bat` is present.
- [sdkmanager reference](https://developer.android.com/tools/sdkmanager), including `--sdk_root` and interactive license handling.

## Approval-gated PowerShell sequence

Run in a fresh PowerShell window only after the owner explicitly approves the reserved disk and bandwidth. The existing `android_setup_preflight.ps1` defaults to a report-only mode. This sequence keeps Java/Android paths local and does not modify global `PATH`.

```powershell
$ErrorActionPreference = 'Stop'
$root = Join-Path $env:LOCALAPPDATA 'BCM-M34-Android-4.7.2'
$sdk = Join-Path $root 'sdk'
$jdk = Join-Path $root 'jdk17'
$downloads = Join-Path $root 'downloads'
New-Item -ItemType Directory -Force -Path $root, $sdk, $jdk, $downloads | Out-Null
$free = (Get-PSDrive -Name ([IO.Path]::GetPathRoot($root).TrimEnd(':\'))).Free
if ($free -lt 15GB) { throw 'Stop: reserve at least 15 GiB free before installation.' }

# Download only the three official archives linked above into $downloads.
# Verify Temurin's adjacent .sha256.txt against Get-FileHash before extraction.
# Verify the Android command-line-tools checksum shown by the Android download page.
# Verify the Godot template file is the 4.7.2 stable template archive.
Expand-Archive -LiteralPath (Join-Path $downloads 'OpenJDK17U-jdk_x64_windows_hotspot_17.0.20.1_1.zip') -DestinationPath $jdk
# Move the archive's single extracted JDK directory contents into $jdk if needed.
Expand-Archive -LiteralPath (Join-Path $downloads 'commandlinetools-win-latest.zip') -DestinationPath (Join-Path $sdk 'cmdline-tools\latest')
& (Join-Path $sdk 'cmdline-tools\latest\bin\sdkmanager.bat') --sdk_root=$sdk 'platform-tools' 'build-tools;35.0.1' 'platforms;android-35' 'cmdline-tools;latest' 'cmake;3.10.2.4988404' 'ndk;28.1.13356709'
if ($LASTEXITCODE -ne 0) { throw "sdkmanager package install failed: $LASTEXITCODE" }
& (Join-Path $sdk 'cmdline-tools\latest\bin\sdkmanager.bat') --sdk_root=$sdk --licenses
if ($LASTEXITCODE -ne 0) { throw "SDK license step failed: $LASTEXITCODE" }
java -version 2>&1
& (Join-Path $sdk 'cmdline-tools\latest\bin\sdkmanager.bat') --sdk_root=$sdk --list_installed
& (Join-Path $sdk 'platform-tools\adb.exe') version
```

Then install the matching `.tpz` using Godot's **Editor > Manage Export Templates > Install from File**. In Godot Editor Settings for this Windows user only, set Java SDK Path to the extracted JDK root and Android SDK Path to `$sdk`. Do not change machine/user `PATH`. Capture `java -version`, installed SDK package listing, `adb version`, and the Godot template version. R06 does not authorize an Android project export, device install, or ad test.

## Stop checks and rollback

- Before any download, verify at least 15 GiB free and owner approval for bandwidth. Stop if either is absent.
- Verify archive SHA-256 values against the publishers' current official checksum listings before extraction. Never proceed on a mismatch.
- After install, require Java 17, all six specified SDK packages, working `adb`, and template version `4.7.2.stable`; stop on a mismatch.
 - If setup is abandoned, first inventory creation time and hashes of the exact task-owned `$root` and Godot `4.7.2.stable` template directory. Remove only paths created by the approved run after review. Preserve pre-existing directories, unrelated Godot templates, and all project/user saves. Clear the two Godot path settings if they were set by this setup. No rollback was run in R06.

## R06 V02 observed package verification

| Archive | Size | Expected publisher hash | Observed hash | Result |
|---|---:|---|---|---|
| Temurin 17.0.20.1+1 Windows x64 JDK ZIP | 190,817,615 B | SHA-256 `e53a79c3c3d86865bd7e787903884331068e71321714ffd44f145785affc7cb0` | Same | PASS |
| Android command-line tools `15859902` Windows ZIP | 155,655,386 B | SHA-256 `90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a` | Same | PASS |
| Godot 4.7.2 stable export templates TPZ | 1,281,349,702 B | SHA-512 `ca4d71c4d7b81dfc15d1a98baa07534aa95b03fdda78a0075b06672e1648d2e5f40980c9adc28d23e1b92e732ee7bf3461997aa804af74ec2fcd7a93ccb84079` | Same | PASS |

The verified Android templates in the archive total 446,482,269 uncompressed bytes (`android_debug.apk`, `android_release.apk`, and `android_source.zip`). The complete archive expands to about 2.07 GB; only the Android entries were planned for installation. The existing template directory is 88,369,145 B and contains web templates, not Android templates.
