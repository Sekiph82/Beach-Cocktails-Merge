# BCM-M34 V04 — Icon, Settings Links, and Android Preflight Evidence

**Evidence date:** 2026-10-20  
**State:** implementation and local validation complete; store/public release remains blocked by owner-supplied legal endpoints and Android toolchain installation approval. `TASKS.md` was not edited.

## Store icon candidate

The new, original V04 composition uses only owned high-resolution project art: the owner ocean background, logo concept V03, and L01 cocktail sprite. `tools/release/build_store_icon_v04.py` is the editable deterministic Pillow recipe. The 1024 master is also copied byte-for-byte into the runtime brand asset used by the Android and iOS export presets. `tools/release/validate_store_icon_v04.py` checks PNG dimensions, runtime/master parity, the Play 1 MiB size ceiling, and reports source/output SHA-256 values.

| Candidate | Dimensions | Bytes | SHA-256 | State |
| --- | ---: | ---: | --- | --- |
| `icons_v04/beach_cocktails_merge_icon_master_v04.png` | 1024×1024 RGBA | 1,864,162 | `5495be0ec052d98738f9729332a267d71faace0535bbee1a217e430385b2146b` | Owner visual approval required |
| `icons_v04/google_play_icon_candidate_512_v04.png` | 512×512 RGBA | 567,144 | `d8dd09b1fd0a4d7d23fb2b631917421489b10da1bf13a21f8e6628077801160a` | Owner visual approval required; below 1 MiB |
| `assets/ui_assets/brand/beach_cocktails_merge_icon_v04.png` | 1024×1024 RGBA | 1,864,162 | `5495be0ec052d98738f9729332a267d71faace0535bbee1a217e430385b2146b` | Runtime export candidate; owner visual approval required |

Source hashes:

- `assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v02.png`: `dca5feb7283588d59158388bca87ea7d8f5796ccfa37559daecec11e4606a4e2`
- `assets/ui_assets/brand/logo_concept_v03.png`: `9e78c2b36fed466a9be1c186b8069af94cd291c23bd220cffc671f88f692f552`
- `assets/cocktails/L01.png`: `5cc060adf501562c2920fcb04a251e7a679a069f8d865f898e13adb87ac1e425`

The candidate was reviewed at full composition size. The logo, drink, safe border, and tropical background are legible and visibly related to the game. It is new artwork for owner review, not a previously approved store icon. The existing V03 screenshot compositions were visually reviewed: the home, World Map, Sunny Cove map, gameplay, and live merge images depict real game UI; gameplay/live-merge candidates retain tutorial overlays and need clean-capture review. The Daily Rewards composition has a visibly unsettled/blurred transition and is **HOLD — recapture after a stable real runtime state**. No win, booster, or phone screenshot was fabricated.

## In-game Privacy and Support links

`data/ui/settings_links.json` is packaged by both Android and iOS store-candidate export filters. It deliberately contains empty policy/support URLs. `ApplicationShell` adds accessible Privacy Policy and Support buttons to Settings. Each is disabled and labeled `NOT CONFIGURED` until its value is a syntactically valid public HTTPS URL. The validator rejects non-HTTPS schemes, credentials, whitespace, local/single-label hosts, IP literals, and invalid ports. Invalid/missing/unknown-schema JSON fails closed to both links empty. A valid configured address opens with `OS.shell_open`; tests substitute a fake opener and never visit any endpoint.

The EN/TR staging privacy and support pages now describe the Settings links as present but disabled until owner-approved public HTTPS endpoints are configured. Those files remain staging drafts with owner/legal fields; no legal controller, mailbox, response commitment, public URL, or data-safety claim was invented. Current AdMob development support remains in source; native ad delivery and purchase products remain disabled pending separate owner approval and evidence.

## Android build preflight

Local bounded checks found Android SDK Platform API 36, Build Tools 36.0.0 and 36.1.0, command-line tools, platform-tools/ADB, and the Android Studio JBR. The JBR is OpenJDK 25.0.3. Exact bounded standard JDK locations for Java 17/21 were checked and none were found. The SDK does not contain `ndk/28.1.13356709` or `cmake/3.10.2.4988404`. Godot is 4.7.2; V03 identified the Gradle export template as 8.11.1. Gradle's compatibility table lists Java 25 runtime support starting at Gradle 9.1; the installed template cannot use the JBR 25 as its supported runtime. Godot recommends OpenJDK 17 and specifies NDK r28b plus CMake 3.10.2.4988404 for its Android export setup.

At check time, C: had **123.3 GiB free**. No cleanup or SDK installation was performed. `sdkmanager --list_installed` returned no package rows despite the directly verified API/build-tools files; the direct file checks above are the positive package evidence. No emulator or GitHub Actions were used. No APK was produced; state is `ANDROID_TOOLCHAIN_INSTALL_OWNER_AUTH_REQUIRED`.

After owner authorization, the bounded setup procedure is:

1. Install an official Eclipse Temurin OpenJDK 17 x64 build from [Adoptium](https://adoptium.net/temurin/releases/?version=17) into its normal JDK location. Do not change global `JAVA_HOME`; use that JDK path for the Godot/export process only.
2. With that JDK active in the process, install only the missing packages into the existing SDK using its official command-line tools:

   ```powershell
   $env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17'
   $env:Path = "$env:JAVA_HOME\bin;$env:Path"
   & 'C:\Users\sekip\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat' `
     --sdk_root='C:\Users\sekip\AppData\Local\Android\Sdk' `
     'ndk;28.1.13356709' 'cmake;3.10.2.4988404'
   ```

   The owner must review/accept Google's SDK license prompts directly; Codex will not accept legal terms on the owner's behalf. Do not install or start an emulator.
3. In Godot Editor Settings, configure Java SDK Path to the installed JDK 17 and Android SDK Path to the existing SDK. Export only the configured nonshipping Android candidate to `.godot/build/` after a fresh bounded preflight. Verify APK manifest, target/min SDK, arm64 library alignment, permissions, icon and package contents before claiming a technical candidate.

Official version guidance: [Godot 4.7 Android export](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html), [Android NDK/CMake installation](https://developer.android.com/studio/projects/install-ndk), and [Gradle compatibility](https://docs.gradle.org/current/userguide/compatibility.html). No release signing key or store identity was created or used.

## Remaining owner/store gates

- Owner visual acceptance of V04 master and 512 Play icon.
- Owner/legal verified public policy and support URLs, controller/contact identity, and completed policy review before enabling app Settings links.
- Owner authorization before installing JDK/NDK/CMake into external system/SDK locations.
- Android preview export and artifact inspection after toolchain setup; no physical-device acceptance is claimed.
- iOS still needs an owner Mac with current Xcode and approved signing identity. No portal/app creation or store submission was performed.
- App Privacy / Play Data safety declarations must be reconciled against the exact signed release and its SDK/data flows. Future AdMob source remains preserved but ads are OFF and buyables remain false.
