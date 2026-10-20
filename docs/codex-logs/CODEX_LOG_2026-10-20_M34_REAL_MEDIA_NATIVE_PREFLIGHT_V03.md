# Codex Execution Log — BCM-M34-006/007 V03

**Work item:** BCM-M34-006/007 — Real Store Media + Native Build Preflight
**Prompt:** `coordination/sessions/BCM-M34-006-007-CODEX-COMPUTER-USE-OWNER-CONSOLES/BCM_M34_STORE_REAL_MEDIA_AND_NATIVE_BUILD_PREFLIGHT_V03.md`
**Execution date:** 2026-10-20
**Branch / remote:** `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`)
**Implementation commit:** `53ecc38e49d236f7c085c894e2b47aa5436e77af`
**Start HEAD for V03:** `1feec20aef702ee93bc35193b79b6b7ce2026542`
**End HEAD for implementation deliverables:** `53ecc38e49d236f7c085c894e2b47aa5436e77af`

## Sync preflight

- Canonical checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- The task session began after the required sync-first procedure had safely fast-forwarded the checkout from `a2a0c0c0df116c2234975dc5e5e59f5461e0568b` to `1feec20aef702ee93bc35193b79b6b7ce2026542`. The pre-sync divergence was `0 ahead / 3 behind`; incoming changes were path-disjoint from inventoried owner-local untracked paths. Those untracked owner files were left untouched and unstaged.
- At V03 start: branch `main`, `HEAD=origin/main=1feec20aef702ee93bc35193b79b6b7ce2026542`, divergence `0/0`; remote `origin` was the canonical GitHub URL above.
- Implementation commit was pushed to `origin/main`. Immediately after push: `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `53ecc38e49d236f7c085c894e2b47aa5436e77af`; `git rev-list --left-right --count HEAD...origin/main` returned `0 0`.
- `TASKS.md` was not modified. `git diff -- TASKS.md` was empty.

## Files changed

- Added safe, project-local GUI capture runner: `tools/release/capture_live_game.gd`, `tools/release/capture_live_game_input.gd`.
- Added 9 original 720×1280 PNG captures and 9 JSON sidecars under `docs/release/store_media/captures_v03/`.
- Added 6 captioned 1080×1920 marketing compositions from the actual captures under `docs/release/store_media/compositions_v03/`. All carry desktop-candidate/device-review-pending status.
- Added `BCM_M34_STORE_MEDIA_INVENTORY_V03_2026-10-20.json`, `BCM_M34_REAL_CAPTURE_README_V03.md`, `BCM_M34_STORE_COPY_V03_EN_TR.md`, `BCM_M34_ICON_REPLACEMENT_SPEC_V03.md`, and `BCM_M34_ANDROID_IOS_NATIVE_PREFLIGHT_V03.md` under `docs/release/store_media/`.
- Added English and Turkish privacy/support staging pages: `privacy_policy_staging_en.html`, `privacy_policy_staging_tr.html`, `support_staging_en.html`, `support_staging_tr.html`.
- Existing `google_play_feature_graphic_v02.png` was preserved unchanged; SHA-256 remains `b1f1bc784b9c31ee0438aa5bce27949805becf030ed606d22a23c90972f272f5`.
- No other owner-local untracked files were staged or committed.

## Implementation and evidence

- Launched a separate visible Godot 4.7.2 production `ApplicationShellScene` with `tools/release/capture_live_game.gd`. The runner validated `tests/support/test_sandbox_guard.gd` and reported `BCM_LIVE_CAPTURE_SANDBOX_OK`; its isolated profile was under `.godot/bcm_sandboxes/bcm_m34_v03_20261020_01/`. Owner save paths were not used.
- Actual visible UI input and F12 viewport capture produced the nine images. The capture trace at `.godot/bcm_release_preflight/live_capture_runner.log` contains the sandbox marker and nine `BCM_LIVE_CAPTURE_OK` rows. Sidecars identify source scene, runtime version, capture revision, resolution, `DESKTOP_GAMEPLAY_CANDIDATE`, and `DEVICE_REVIEW_PENDING`.
- Captured Home, World Map, Sunny Cove Island Map, gameplay/To-Go state, actual gameplay after real launches, a real L3 merge (`MERGE L3 +50`, score 50), and Daily Rewards without claiming it. Six optional marketing compositions use factual English headings on separate bands and a desktop/device-pending footer; the gameplay viewport content was not state-edited.
- Did not fabricate a Level Won state (no level was completed) or Boosters state (captured level has boosters disabled). Physical device screenshots were not available. The icon audit found no trustworthy high-resolution square source; no low-resolution upscale or fabricated final icon was made. Details and an owner-source replacement brief are recorded in the icon specification.
- Expanded Apple/Google English and Turkish listing fields, policy risks, reviewer/rights placeholders, age/alcohol review notes and data-safety cautions. Added four standalone local HTML staging pages with legal/contact/retention placeholders. No public URLs were invented or configured.
- Inspected `scripts/campaign/application_shell.gd::_build_settings()`: Settings has audio/accessibility/tutorial controls and navigation but no Privacy/Support control or URL; no dead link was found. A visible Settings screenshot was not obtained after the capture session ended during the attempt to open that view. No runtime route was added; visual Settings behavior remains unverified.
- Preserved development AdMob support. Production ad delivery remains off/no-go until owner decisions, native SDK and consent review, trusted SSV/reward verification, exact-package privacy disclosures and real-device evidence. Store products remain `buyable=false`; no purchase grant or live ad claim was introduced.

## Android and iOS preflight

- Godot 4.7.2 executable and export templates exist locally. Android SDK root is `C:\Users\sekip\AppData\Local\Android\Sdk`; platform `android-36`, build-tools `36.0.0` and `36.1.0`, `adb.exe`, and `sdkmanager.bat` were found. `adb devices -l` returned no devices.
- Android Studio JBR is `C:\Users\sekip\AppData\Local\Programs\Android Studio\jbr\bin\java.exe`, OpenJDK 25.0.3. The bundled Android template's wrapper pins Gradle 8.11.1. Per the Gradle compatibility matrix, Java 25 support starts with Gradle 9.1; this combination is not a compatible execution setup. No JDK 17 was found in the bounded standard paths inspected.
- NDK is absent at `C:\Users\sekip\AppData\Local\Android\Sdk\ndk`, `...\ndk-bundle`, `C:\Program Files\Android\Android Studio\sdk\ndk`, and `C:\Users\sekip\AppData\Local\Programs\Android Studio\sdk\ndk`. The Godot export template archive contains Gradle wrapper files, but no NDK.
- No NDK/JDK was installed, no system setting changed, and no APK/AAB built. The preflight document records an owner-authorized minimal setup plan (JDK 17; Godot 4.7-compatible NDK r28b and CMake) and a synthetic preview application ID for a later debug-only package. That package, its manifest/permissions/ABI/16 KB native-library review, and physical-device validation remain pending.
- This Windows machine has no `xcodebuild` or macOS/Xcode environment. Per [Godot 4.7 iOS export requirements](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_ios.html), export requires macOS and Xcode; no signed iOS project or IPA was produced.

## Commands and checks

- `git status --short --branch`, `git remote -v`, `git fetch origin main`, and `git rev-list --left-right --count HEAD...origin/main` — completed at session sync; path-disjoint behind-only sync as recorded above.
- Visible Godot 4.7.2 launch of production scene with isolated profile and F12 capture runner — passed; log reported sandbox-safe profile and 9 full-resolution capture successes.
- Local media validation (Python/Pillow + JSON and HTML parser) — `MEDIA_VALIDATION=PASS`: 9 PNG captures at 720×1280, 6 PNG compositions at 1080×1920, 9 sidecars, 4 valid HTML staging pages, zero local links, hashes valid, inventory entries present, feature-graphic SHA preserved.
- `Godot_v4.7.2-stable_win64.exe --headless --path . --check-only --script res://tools/release/capture_live_game.gd` — exit 0.
- `Godot_v4.7.2-stable_win64.exe --headless --path . --check-only --script res://tools/release/capture_live_game_input.gd` — exit 0.
- `git diff --check` and staged `git diff --cached --check` — exit 0 after normalizing inventory JSON line endings.
- No PCK coverage checks, prior V02 suites, emulator, device install, native export, store upload, ad request, or billing flow was run. This follows V03's instruction that V02 PCK coverage was accepted and should not be repeated.

## Limitations and handoff

- Release readiness remains `NO-GO`: desktop captures and captioned compositions are pending physical-device review; no approved icon master; native Android build blocked by missing NDK and Java/Gradle mismatch; iOS blocked by Mac/Xcode; public privacy/support page ownership/contact placeholders remain open; store age/data declarations require exact signed-package review.
- This log records the implementation commit and its verified remote parity. It is an execution record, not owner or independent acceptance and does not change the canonical project tracker.
- Explicit confirmation: `TASKS.md` was not modified.
