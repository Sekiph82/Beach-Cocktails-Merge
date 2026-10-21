# Codex Execution Log — BCM-M34-006/007 V09 Store Submission Kit

**Date:** 2026-10-21
**Prompt:** `BCM_M34_STORE_SUBMISSION_ASSETS_AND_IDENTITY_V09.md`
**Branch / remote:** `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`)
**Start HEAD after sync:** `5bc30eace35c1f16c0a55ac184711770da2bf066`
**Implementation commit:** `2587b63`
**Final implementation/evidence SHA:** `c695a150f9745ad6a9a1bd5bb34e60e4a0640fbf`

## Sync and preserved owner work

- Preflight: local `main` was 0 ahead / 5 behind `origin/main`. The fetched incoming diff was `TASKS.md` plus the V09, V10, and V08-audit coordination documents. There were no modified tracked paths. The previously inventoried owner-untracked files remained untouched.
- `git merge --ff-only origin/main` advanced from `234fb4ce9b7aed6417b747a62a50b9a395a11df6` to `5bc30eace35c1f16c0a55ac184711770da2bf066`; no stash, reset, rebase, clean, or deletion was used.
- `TASKS.md` was read after synchronization and was not edited by V09/V10 implementation. Its staged, unstaged, and status checks are empty relative to synchronized `HEAD`; the upstream tracker change arrived only with the required fast-forward.

## Store media prepared

`tools/release/prepare_store_submission_v09.py` reproducibly assembles `docs/release/store_media/submission_candidates_v09/` from existing, genuine V03/V07 runtime captures and existing owner art. It preserves source files and writes the actual-byte inventory to `submission_manifest_v09.json`.

- Google Play candidate: 512×512 RGBA icon, 567,144 bytes, SHA-256 `d8dd09b1fd0a4d7d23fb2b631917421489b10da1bf13a21f8e6628077801160a`.
- Feature graphic: 1024×500 RGB, 901,737 bytes, SHA-256 `b1f1bc784b9c31ee0438aa5bce27949805becf030ed606d22a23c90972f272f5`.
- Six distinct 1080×1920 RGB screenshots: Home, World Map, Island Map, current tutorial-free gameplay, live merge, and To-Go gameplay. Three are gameplay scenes. Each row records file bytes/hash, source file/hash, source runtime capture metadata/hash, capture source HEAD, runtime view, and device-review state. Daily Rewards is omitted.
- Contact sheet: `docs/release/store_media/submission_review_contact_sheet_v09.png`, 960×1438, 1,200,562 bytes, SHA-256 `b3ad49235a9694ecc457c6fc44ee37c468bff89969435959c5f147dff70ebd0a`. It is a compact owner-review sheet; candidate asset files themselves are byte-identical to their existing sources.
- No Apple iPhone screenshot files were made. The exact-release physical iPhone capture is absent. `apple_iphone/CAPTURE_PENDING.md` records the current 1179×2556 accepted portrait target and the desktop-source limitation.
- Local EN/TR staging folders contain index, privacy, and support pages. Links resolve locally. Pages retain unresolved legal identity/contact, retention, audience, signed-package data-flow, and review fields. No public HTTPS URL was supplied or published; in-game Privacy and Support links remain unconfigured/disabled.
- `BCM_M34_APP_STORE_CONNECT_APPROVED_RECORD_PACKET_V10.md` records the exact owner-approved iOS title, standalone Bundle ID, SKU, and language, without claiming a portal resource was created.

## Validator and focused checks

- Final `python tools/release/prepare_store_submission_v09.py`: `PASS_CANDIDATE_VALIDATION`; 8 catalogued assets, 6 screenshots, 3 gameplay screenshots; release state `BLOCKED_DEVICE_VISUAL_REVIEW`; Apple screenshots `CAPTURE_PENDING`.
- Validator checks actual PNG decoding, dimensions, color modes, byte sizes, source/output SHA-256, capture metadata identity, listing title/short-description limits, EN/TR local links, `data/ui/settings_links.json` schema and public HTTPS URL format if supplied, seven disabled ad placements, nonbuyable products, and static iOS export preset identity/no-team/no-provisioning/no-export configuration. This is static preset checking only; no export was run.
- `python -m py_compile tools/release/prepare_store_submission_v09.py`: PASS.
- `git diff --check` and `git diff --cached --check`: PASS after normalizing generated text files to LF. An earlier check surfaced CRLF warnings; those files were normalized, rechecked, and committed.
- Visually inspected existing icon, feature graphic, current gameplay composition, and merge composition. The submitted set remains owner/device review pending; older gameplay compositions retain their genuine tutorial overlay where present.
- No PCK/AAB/APK tests, exports, Android emulator, GitHub Actions, Play Console writes, signing, privacy deployment, legal agreement, or public store action occurred. Old APK/AAB files were not accessed or changed.

## Monetization, limits, and handoff

Future AdMob source/configuration is preserved. The validator observed all seven placements disabled and all catalog products nonbuyable. No live ads, UMP/ATT consent, SSV reward verification, or billing behavior is claimed. Google Play and Apple public submission remain NO-GO pending owner/legal review, real device visual capture, public HTTPS support/privacy endpoints, final package verification, account setup, and signing.

The first validator run found a checker defect: it expected an Android-only `package/signed` option inside the iOS preset section. The checker was corrected to inspect the actual iOS preset’s empty export destination, empty team/provisioning values, approved bundle identifier, and `export_project_only=true`; the final run passed. The failed first run did not invoke Godot or modify project configuration.

Remote parity (`HEAD = origin/main = remote main`, 0/0) is verified after the final log publication in the task handoff. Owner-untracked paths remain unstaged. **`TASKS.md` was not modified.** Independent audit remains pending.
