# BCM-M28 Master V02 | Actions-first planning HOLD

STATUS: OWNER_REVIEW_REQUIRED. Do not give this to Codex for implementation yet. Owner requested discussion before determining M28-001/002/003 scope. Supersedes the previous M28 V01 instruction to start work immediately.

## Existing live CI (verified GitHub runs 2026-10-10)

Android APK: .github/workflows/android-apk.yml; run https://github.com/Sekiph82/Beach-Cocktails-Merge/actions/runs/38078255160, SUCCESS; SHA b2e09946c6a9a5d7f8254934425d335ffd6f2edf; artifact BeachCocktails-apk, 145267886 bytes. ubuntu-latest, Godot 4.7.2, Android export-debug, ephemeral debug keystore, package com.sekiph82.beachcocktails, manually triggered, accepts optional ref input. This is a debug sideload APK, not Google Play release signing.

iOS IPA: .github/workflows/ios-ipa.yml; run https://github.com/Sekiph82/Beach-Cocktails-Merge/actions/runs/38063815860, SUCCESS; SHA c131189a952e5cabfce9a6af326944ffc84defc1; artifact BeachCocktails-ipa, 146697875 bytes. macos-latest, Godot 4.7.2 export_project_only=true, Xcode Release with CODE_SIGNING_ALLOWED=NO then manual Payload zip. The artifact is an UNSIGNED IPA; owner uses xtool or own device-signing process, and has accepted iPhone gameplay/visuals. This workflow is not App Store Connect submission, TestFlight upload, nor an Apple-signed release. The user's Ubuntu/Swift/xtool setup is outside these Actions jobs. Apple API key creation does not imply CI uses that key.

Both workflows already build functioning artifacts. DO NOT create duplicate APK/IPA workflows, replace existing CI, start a fresh build, or revise a working pipeline without owner authorization. Preserve two canonical paths.

## Potential M28 discussion items (NOT IMPLEMENTATION AUTHORIZATION)

M28-001: Existing workflow inventory, traceable source SHA and artifact, unsigned-vs-signed delivery distinction, reproducibility and optional signing/release channel only if owner wants. iOS workflow has no ref input, unlike Android; both successful runs build DIFFERENT commits. Avoid calling the two artifacts one matched-version pair. Godot import has || true in workflows; failures could be hidden. Current assets inclusion/exclusion review should be evidence-led, not speculative cleanup.

M28-002: Targeted owner-first mobile release QA for existing Android APK and device-tested iPhone IPA. Prioritize actual remaining release gaps, user data/save lifecycle, privacy/permission/export resources, version/bundle identity. Keep already accepted gameplay, visuals, physics and effects unchanged. Avoid repeating M27 automated testing without cause.

M28-003: Only if owner confirms delivery target (family sideload, TestFlight/App Store, Play Store), collect existing artifact provenance, minimal release-candidate checklist and unresolved caveats. No new upload or publication without explicit owner authorization.

Known low-severity log warnings: iOS invalid UID text-path fallback for scenes/main.tscn and WorldMapScene.tscn; iOS locale 'two'/'three' missing translation; GitHub Node20/action version deprecation. None negated the successful artifacts, and they do not independently justify disrupting working workflows. Do not expose signing keys or App Store Connect API key.

## Next step

Wait for explicit owner M28-001/002/003 decisions. ChatGPT alone updates TASKS.md. No Codex assignment until owner approves revised scoped master.
