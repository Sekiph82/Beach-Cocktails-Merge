# Codex Execution Log — BCM-M34-006/007 V04

**Prompt:** `BCM_M34_ANDROID_PREVIEW_PRIVACY_UI_ICON_V04.md`  
**Start HEAD:** `f7bfdac16f805a79ea9d134c09d9ee69ff67bbd6`  
**Implementation end HEAD:** `ccd0fcca` (`Polish BCM-M34 V04 evidence formatting`)  
**Branch / remote:** `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`

## Sync-first preflight

The canonical checkout was initially at `4eb999d623d12033dcdf2bd3f47a2b530b73b07b`. `git fetch origin main` reported local `main` 0 ahead / 3 behind. Before syncing, all dirty/untracked owner paths were inventoried; they included the existing M21/M23/M26/M33 evidence, `_m32_validation/`, `data/campaign/shop_catalog.json`, `f647e4ff-b906-40e7-93f8-3c4b59d95b23.png`, `docs/codex-logs/CODEX_LOG_M23_R01_V01.md`, and `tools/capture_godot_window.ps1`. The incoming diff was path-disjoint and limited to upstream `TASKS.md`, the V04 prompt, and the V03 audit. `git merge --ff-only origin/main` advanced to `f7bfdac16f805a79ea9d134c09d9ee69ff67bbd6`; there were no conflicts. Owner-local paths were left in place. Root `TASKS.md` was read-only for this task and no Codex change to it was made.

Immediately before the implementation push, `git fetch origin main` showed 0/0 divergence and no incoming paths. The implementation/evidence commits were pushed to existing `main`, without creating a branch or rewriting history. The post-push proof at the implementation end HEAD was:

```text
git rev-parse HEAD                         ccd0fcca... (full value below)
git rev-parse origin/main                  ccd0fcca... (full value below)
git ls-remote origin refs/heads/main       ccd0fcca... refs/heads/main
git rev-list --left-right --count HEAD...origin/main  0  0
```

Full implementation end SHA: `ccd0fccad660aca02228266db9d7c93fad7f3862`.

## Files changed

- `scripts/campaign/application_shell.gd`
- `scripts/campaign/settings_link_config.gd`
- `data/ui/settings_links.json`
- `tests/m34_settings_link_probe.gd`
- `export_presets.cfg`
- `tools/release/build_store_icon_v04.py`
- `tools/release/validate_store_icon_v04.py`
- `assets/ui_assets/brand/beach_cocktails_merge_icon_v04.png`
- `docs/release/store_media/icons_v04/beach_cocktails_merge_icon_master_v04.png`
- `docs/release/store_media/icons_v04/google_play_icon_candidate_512_v04.png`
- `docs/release/store_media/BCM_M34_V04_ICON_PRIVACY_UI_EVIDENCE.md`
- `docs/release/store_media/privacy_policy_staging_en.html`
- `docs/release/store_media/privacy_policy_staging_tr.html`
- `docs/release/store_media/support_staging_en.html`
- `docs/release/store_media/support_staging_tr.html`
- This immutable execution log.

No other preexisting untracked owner path was staged or committed.

## Implementation summary

- Added Privacy Policy and Support entries to the actual Settings UI. URLs are sourced from `data/ui/settings_links.json`, which defaults to empty. The controls remain disabled until a syntactically valid public HTTPS URL is configured; invalid/missing/unknown-schema config fails closed. Link opening is test-injectable; the test used a fake opener and contacted no endpoint.
- Added the settings-links JSON to Android and iOS store-candidate export filters.
- Generated a new 1024×1024 master from owned high-resolution ocean, logo, and cocktail artwork; exported a byte-identical runtime icon and a 512×512 Play listing candidate. The 512 PNG is 567,144 bytes, below 1 MiB. Both store icon and runtime file are explicitly marked pending owner visual approval.
- Updated EN/TR staging privacy and support pages to describe the in-game links accurately without inventing legal contacts or active endpoints.
- Reviewed all six V03 Play compositions and the icon visually. Five screenshots are authentic game UI but gameplay/live-merge candidates still show tutorial overlays; the Daily Rewards composition is held because its transition is blurred/unsettled. No synthetic win/booster or device image was created.
- Preserved AdMob development support. No AdMob SDK, production ad delivery, consent prompt, billing, or buyable catalog state was enabled or edited.
- Did not restart PCK cleanup. No GitHub Actions or Android emulator was used.

## Commands and test evidence

- `godot --version` — `4.7.2.stable.official.ed1daf0bf`.
- `python tools/release/build_store_icon_v04.py` — passed; emitted master 1024×1024, Play icon 512×512, and runtime icon.
- `python tools/release/validate_store_icon_v04.py` — `ICON_VALIDATION=PASS owner_visual_review=REQUIRED`; checked dimensions, PNG format/mode, 512 PNG ≤1 MiB, runtime/master byte parity, and printed SHA-256 for every output/source.
- `& .\tools\run_isolated_godot_probe.ps1 -Probe tests/m34_settings_link_probe.gd -TimeoutSeconds 180` — `PROBE_EXIT_CODE=0`; all URL, disabled-state, Settings-route, layout and injected-opener assertions passed in an isolated in-project sandbox.
- `& .\tools\run_isolated_godot_probe.ps1 -Probe tests/m20_settings_probe.gd -TimeoutSeconds 180` — `PROBE_EXIT_CODE=0`; all existing settings persistence/accessibility regressions passed. The test intentionally writes malformed preference JSON to verify fallback, so Godot printed the expected parse diagnostic.
- `git diff --check` — passed after removing a Markdown hard-break whitespace from the evidence document.
- No PCK audit/re-export, full regression suite, emulator/device run, or APK inspection was performed.

## Android native build preflight / blocker

- Direct bounded file checks verified SDK API 36 (`platforms/android-36/android.jar`), Build Tools 36.0.0/36.1.0, command-line tools, and ADB. `adb version` returned 1.0.41 / Android Debug Bridge 37.0.1.
- Android Studio JBR is OpenJDK 25.0.3 (`C:\Users\sekip\AppData\Local\Programs\Android Studio\jbr\bin\java.exe`). Bounded checks of standard Java installation paths found no JDK 17 or 21. No recursive scan of C: was used.
- The existing SDK lacks `ndk/28.1.13356709` and `cmake/3.10.2.4988404`. V03's Android template inspection identified Gradle 8.11.1; its supported Java runtime does not include Java 25. Godot 4.7's official guidance recommends JDK 17 and specifies NDK r28b/CMake versions above.
- `Get-PSDrive C` returned 132,400,422,912 free bytes (about 123.3 GiB). No files were deleted and no SDK/system dependency was installed.
- Prepared exact official Adoptium JDK 17 + existing `sdkmanager.bat` package-install steps in `docs/release/store_media/BCM_M34_V04_ICON_PRIVACY_UI_EVIDENCE.md`. Owner permission to install dependencies into the external existing SDK/system locations is required before executing that procedure. Google SDK legal terms must be reviewed/accepted directly by the owner.
- No APK was produced. State: `ANDROID_TOOLCHAIN_INSTALL_OWNER_AUTH_REQUIRED`. No production signing identity/key or store identity was used or created.

## Manual checks and limitations

- Manually reviewed the V04 icon composition and six existing V03 Play compositions at actual image resolution using the local image viewer.
- Focused Godot probes exercised the actual Settings scene and fake URL opener under sandboxed `user://` data. Physical phone/tablet display, native Android export, manifest/ELF/16-KB inspection, device installation and store-console behavior remain unverified.
- The Privacy/Support URLs are empty until the owner supplies verified public HTTPS endpoints and legal controller/contact identity. Store policy drafts and data-safety declarations remain owner/legal review items.
- iOS build/signing still requires an owner Mac with supported Xcode and approved identity. No App Store Connect app was created or submitted.
- The V03 Daily Rewards screenshot requires a genuine stable-state recapture. Other store screenshot candidates remain desktop candidates, not device-approved assets.

## Repository boundaries and final state

- `TASKS.md` was not modified by Codex.
- AdMob source/policy and disabled production settings were left unchanged.
- Preexisting owner-local untracked paths listed in sync preflight remain untouched and untracked.
- The implementation commits were published to `origin/main`; the implementation end SHA and remote main matched at the recorded post-push verification. The execution log is added as a follow-up immutable evidence commit and its final push parity is separately reported in the handoff.
