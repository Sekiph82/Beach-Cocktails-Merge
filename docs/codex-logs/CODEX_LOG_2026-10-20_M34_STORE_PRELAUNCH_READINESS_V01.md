# Codex Execution Log — BCM-M34-006/007 Store Prelaunch Readiness V01

## Identity and synchronization

- Work item: BCM-M34-006/007, implementation and forensic release-package audit.
- Prompt version: `BCM_STORE_RELEASE_READINESS_IMPLEMENTATION_AND_FORENSIC_AUDIT_V01.md`.
- Start HEAD: `381974c35cbe637a4dc072c781ecade0722f6cff`.
- Branch / remote: `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge` (`origin`).
- Start sync: fetched `origin/main`; local `main` was 9 behind and 0 ahead, with tracked tree clean. Existing untracked owner paths were inventoried, left untouched, and did not overlap incoming changed paths. Safe fast-forward completed to the recorded start HEAD.
- End implementation HEAD: `f5ddc5279e59aaa3170ec2f8768b6aaf569a57ce`.
- End verification: `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` each returned `f5ddc5279e59aaa3170ec2f8768b6aaf569a57ce`; ahead/behind `0/0`.
- Root `TASKS.md` was not edited. Owner untracked files/directories remain unstaged and unchanged. No save or credential was inspected.

## Changed files

- `addons/AdmobPlugin/AdmobPlugin.gd` — native Android/iOS AdMob dependency injection is opt-in and defaults off; existing AdMob runtime API/configuration remains in source.
- `addons/GodotGooglePlayBilling/export_plugin.gd` — native Billing library injection is opt-in and defaults off.
- `export_presets.cfg` — added separate `Android Store Candidate (NOT SHIPPING)` and `iOS Store Candidate (NOT SHIPPING)` export profiles with runtime JSON allowlists and package development/source exclusions.
- `scripts/campaign/application_shell.gd` — owner playtest console remains a dynamically loaded debug-only tool.
- `scripts/campaign/campaign_navigation_controller.gd` — AdMob and Play Billing test adapters are dynamically loaded only from their debug-only entry points, allowing their source to be omitted from candidate packs.
- `tests/test_release_export_boundaries.py` — nine static release boundary and debug-only adapter contracts.
- `tools/release/check_export_boundaries.py`, `tools/release/inspect_godot_pck.py`, `tools/release/inspect_godot_pck.gd`, and its `.uid` — static preset checks plus actual Godot pack loading, per-file size/SHA-256 inventory, and fail-closed package assertions.
- `docs/release/BCM_M34_STORE_PACKAGE_AUDIT_2026-10-20.md` — store-readiness findings, package hashes, copy draft, screenshot spec, blockers, and asset review status.
- `docs/release/evidence/BCM_M34_ANDROID_CANDIDATE_PCK_MANIFEST_2026-10-20.json` and `BCM_M34_IOS_CANDIDATE_PCK_MANIFEST_2026-10-20.json` — inspected PCK file manifests.

## Implementation and package results

- Android profile: target API 36, arm64, min SDK 24; signing disabled. iOS profile: project export only. Both use the planned bundle/package identifier and placeholder version values and are explicitly nonshipping.
- Both actual Godot 4.7.2 PCK exports contain 645 entries and pass inspection. Main scene loads; all required runtime JSON files, including the dynamically referenced content-generation profile set, are present. Each pack has zero inspector-forbidden entries and preserves the AdMob runtime API source.
- Android pack: 116,587,916 bytes, SHA-256 `0ba9e1d0629d89fe8b59f6ec297846975f3992b65527789b07dfb30463eb161d`.
- iOS pack: 116,587,980 bytes, SHA-256 `1c1074c78ab04b15085d96e008d9a5f94cfad5aea0373b87e6a6d8f5cccec1e8`.
- Verified excluded from both packs: coordination/docs/tests/tools/backend, Godot AI, Google Play Billing, native AdMob binaries, AdMob export-editor code/config/model, game-feel editor UI/icons, plugin-only helper files, debug test adapters, M17/M32 tooling, owner playtest console, source/master art folders, and owner-local `data/campaign/shop_catalog.json`.
- `project.godot` has the `_mcp_game_helper` autoload, but Godot's export hook logged that it stripped this autoload from the export; its helper resource is absent from both PCKs. The actual pack check found no Godot AI package entry.
- Ads remain disabled (`default_enabled=false`; every placement disabled). Native ads are not attached to either candidate; future AdMob source and rewarded placement semantics remain preserved. Store products remain `buyable=false` with empty product IDs.
- The final Android pack still contains 383 `.import` and 14 generated `.translation` sidecars, 358,739 bytes combined. Godot's all-resources PCK exporter emitted them despite the release filters; they are reported as a residual rather than claimed absent.
- Asset review did not authorize source deletion. The existing M34-005 cleanup inventory remains 23 `REVIEW`, zero `DELETE`; no audio assets of the listed formats are tracked. Store icon is 256×256 RGBA, below platform listing sizes. No factual store screenshots or Play feature graphic were produced.

## Commands and exact results

- `git status --short --branch`, `git remote -v`, `git fetch origin main`, `git rev-list --left-right --count HEAD...origin/main` — completed; safe behind-only fast-forward from 9 behind, 0 ahead.
- `godot --headless --editor --path . --quit` — exit 0, no reported parse errors.
- `python -m unittest discover -s tests -p test_release_export_boundaries.py -v` — `Ran 9 tests`, `OK`.
- `python tests/run_regressions.py --strict-runtime-errors` — `SUMMARY 21/21 passed`; tests used the isolated `.godot/bcm_sandboxes` user-data root and reported `saves_created=false`.
- Godot `--export-pack` with each candidate preset — exit 0 for Android and iOS.
- `python tools/release/inspect_godot_pck.py --pack ... --manifest-output ...` for both packs — exit 0; both reported `status: PASS`, `forbidden_entries: []`, `missing_required_runtime_files: []`.
- `python tools/release/check_export_boundaries.py --preset "Android Store Candidate (NOT SHIPPING)" --archive .godot/bcm_release_preflight/android_candidate.pck` — exit 0; actual PCK verdict `PCK_INSPECTED_PASS`, debug helper `EXCLUDED_FROM_INSPECTED_PCK`.
- Corresponding iOS boundary check — exit 0 with the same verdict and helper result.
- `git diff --cached --check` — clean before implementation commit.

## Manual checks and unperformed checks

- Manually inspected both generated PCK manifests, release preset inputs/exclusions, AdMob policy/configuration, the preexisting M34-005 asset cleanup inventory, current privacy draft, and app icon dimensions/hash.
- `adb devices -l` listed no attached device. `java`, `gradle`, Android NDK 29, and `xcodebuild` were unavailable. Godot export templates were present, enabling PCK-only checks.
- No signed AAB, IPA, iOS Xcode archive, Android merged manifest, Play upload bundle, 16 KB native-library compliance check, TestFlight/Play install, device QA, store screenshot capture, support/privacy URL publication, portal write, legal agreement, GitHub Actions workflow, live ad, payment, or deployment was performed.
- Public release is `NO-GO` for both stores. App listing, support/privacy URLs, final marketing icon/art/screenshots, account/store records, owner launch-mode and age/privacy decisions, signed packages, and device evidence remain unresolved.

## Final implementation commit

`f5ddc5279e59aaa3170ec2f8768b6aaf569a57ce` was committed to `main` and pushed normally. Immediately after push, local HEAD, `origin/main`, and `git ls-remote origin refs/heads/main` all matched this SHA. This execution log is committed separately as documentation; it does not change the implementation/PCK hashes recorded above.

**Explicit tracker confirmation:** `TASKS.md` was not modified.
