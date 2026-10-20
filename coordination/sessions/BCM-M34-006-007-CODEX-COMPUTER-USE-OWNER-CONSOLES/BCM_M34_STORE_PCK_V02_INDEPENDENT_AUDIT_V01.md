# BCM-M34-006/007 — V02 PCK and Store Media Independent Audit V01

**Date:** 2026-10-20. **Reviewer:** ChatGPT, independent GitHub source/manifests review. **Builder implementation:** `61fc055ef19921c1f0a486e79f23e4afb099fa8f`. **Builder immutable log and source HEAD:** `a2a0c0c0df116c2234975dc5e5e59f5461e0568b`. **Primary evidence:** `docs/codex-logs/CODEX_LOG_2026-10-20_M34_PCK_COVERAGE_MEDIA_V02.md`; `docs/release/evidence/BCM_M34_STORE_PCK_MEDIA_V02_ADDENDUM_2026-10-20.md`; platform V02 PCK JSON manifests. This is historical acceptance evidence, not a new tracker. **Only root `TASKS.md` holds live status.**

## 1. INDEPENDENT VERDICT
**SOURCE/COMMITTED-MANIFEST PASS** for correcting prior PCK hidden-entry coverage, exact file accounting, safe exclusion of identified non-runtime generator metadata, and store-media/copy **draft** delivery. **Windows execution CONDITIONAL on Codex's reported 15/15, Godot real export and pack checks**; reviewer did not rerun local Godot or Python, nor hash physical PCK files because those reside in owner's ignored local project. This closes the **specific V01 PCK inventory-gap finding** at audited source-and-manifest level.

**NOT a release certification:** neither candidate PCK is an installed/signed iOS or Android build; both remain explicitly **NOT SHIPPING / NO-GO**. BCM-M34-006 and BCM-M34-007 remain **BLOCKED**, 146/148 (98.6%) unchanged.

## 2. Verified source-level correction to previous PCK enumeration flaw
The V01 `inspect_godot_pck.gd::_collect` skipped dot-prefixed folders. V02 now uses `tools/release/pck_directory.py::inventory_pck` to read the Godot PCK index directly and enumerate all indexed paths, including dot-prefixed imported and exported resources. The parser validates format/header/directory bounds, duplicate/unsafe paths, payload MD5, SHA-256, overlapping payloads, and zero-filled alignment gaps. Unsupported encryption/sparse/entry flags fail closed. A separate actual Godot `ProjectSettings.load_resource_pack` + `ResourceLoader` check proves main scene and mandatory runtime data are readable. `inspect_godot_pck.py` combines index and engine checks and fails on forbidden entries or metadata residue. Synthetic tests cover hidden forbidden entries and nonzero unindexed bytes.

**Note on claim strength:** Python parser correctness was source reviewed; submitted manifest fields and arithmetic independently reconciled. This is not an independent byte-for-byte reinspection of the actual 116MB physical PCKs. Store acceptance later requires inspecting the signed archive/AAB and app/native binary too.

## 3. V02 PCK arithmetic checked independently
| Metric | Android | iOS |
| --- | ---: | ---: |
| Directory entries | 1,049 | 1,049 |
| Hidden entries (included) | 425 | 425 |
| Hashed payload bytes | 115,980,534 | 115,980,586 |
| Verified zero padding bytes | 7,498 | 7,510 |
| Directory bytes | 109,332 | 109,332 |
| Header bytes | 112 | 112 |
| Total PCK container bytes | **116,097,476** | **116,097,540** |
| Submitted SHA-256 | `efe205c90509ccfa385e8d71c622ee192b463a6433a95c3bc261eff4a3d29eb4` | `00ec7dfb9de83842431a34e89fd5970404a320df4ad1c9286a82b204d871d4a5` |
| Manifest status | PASS | PASS |

Independent arithmetic: Android `115980534+7498+109332+112=116097476`; iOS `115980586+7510+109332+112=116097540`. No unaccounted nonzero gaps according to submitted inventories. Previous visible-only listing of 645 did not represent the complete packs; new index counts 1,049.

## 4. Runtime and source hygiene checks
- Submitted manifests and source verifier require **zero** forbidden `coordination/docs/tests/tools/backend` and Godot AI/test-adapter items; exact `forbidden_entries: []`, `excluded_metadata_leaks: []`, `missing_required_runtime_files: []` in each V02 manifest.
- Source manifest reports `engine_checks.main_scene_resource_loaded=true`, `admob_runtime_source_preserved=true`, `ads_default_and_placements_disabled=true`, `godot_ai_game_helper_present=false`; both `admob_native_binary_entries` and `billing_plugin_entries` empty. Reused future AdMob source/placement contracts remain; native SDK/SSV consent flow is not active.
- A focused provenance inventory for **23** report/catalog/status/source+sidecar entries documents why they are not runtime dependencies; removed **21** metadata resources and **2** related .import maps from candidate packs, without deleting tracked source files. Other `.import` and `.remap` required for Godot asset use remain. Asset-image cleanup still **23 REVIEW, 0 proven DELETE**.
- The V02 design requires actual clean exports, not claiming that root repository must be destructively pruned. This resolves prior owner concern about publishing historical coordination/test documents, scoped to candidate PCK exports.

## 5. Validated builder evidence boundaries
Builder reports **15/15** focused Python, Godot 4.7.2 headless import exit 0, two `--export-pack` exit 0, both actual PCK engine/recursive-index inspector reports PASS and `git diff --check` PASS. A full 21/21 core suite was **not rerun** (no gameplay source change). No physical mobile QA. `TASKS.md` unchanged in builder commit diff, owner untracked paths preserved by builder report. Preserve historical iPhone BAT/XTool, IPA/APK and real Godot campaign save; no owner save access authorised.

## 6. Store assets and compliance are PARTIAL, not completed
- `docs/release/store_media/google_play_feature_graphic_v02.png`: builder reported 1024x500 opaque RGB PNG and SHA256 `b1f1bc784b9c31ee0438aa5bce27949805becf030ed606d22a23c90972f272f5`. Feature art is not a gameplay screenshot and is **owner visual review pending**.
- EN/TR App Store/Play store copy drafts meet reported length checks, but no signed final build or approved in-app localization confirmation.
- EN/TR privacy/support drafts contain `OWNER_REVIEW_REQUIRED` placeholders and are **not approved legal policies**; no actual hosted privacy/support URLs or verified publisher/support email is present.
- Eight screenshot layouts defined, **0 actual captures**, **0 device accepted**; icon remains **256x256 RGBA**, no final 1024 Apple/512 Google art. This is a blocker, not an invitation to label a mock concept screenshot authentic.

## 7. Definite remaining platform blockers
Android: Java/Gradle/SDK/NDK toolchain incomplete on Codex host, physical Google account Android verification blocks Play Console, no owner-approved release ID and upload signing, no signed API36/16KB-compliant AAB, merged manifest/permission or device QA, screenshot/icon/privacy/data safety forms.

Apple: inspected App Store Connect team Apps `No Apps`; standalone canonical App ID not established, app record not created, iOS distribution certificate/provisioning/Xcode26+ macOS build not tested, no signed IPA/Xcode archive, App Store Connect processing/TestFlight, final metadata/screenshots/icon or legal privacy review.

Real rewarded AdMob native SSV/consent/UMP/ATT and StoreKit/Play verified purchase/grant also remain unimplemented and disabled.

## 8. Next engineering decision
**Stop iterative PCK cleanup unless a fresh concrete leaked source is proven.** This technical gap was addressed. The highest-value follow-on is to build a real reproducible release preparation pipeline and acquire actual UI screenshots and icons, verify operating-system/export toolchain feasibility (Android Java/Gradle/NDK install only with owner host/disk authority; Apple Xcode/macOS environment), and draft complete, publishable privacy/support text with owner-supplied legal name/contact/host. Do not self-generate another mock-pack milestone. Owner has already demanded technical work; Codex should perform safe actual source/media tasks without asking the owner to do mechanics.

## 9. FINAL STATUS
**V02 PCK source/manifest cleanup ACCEPTED; builder runtime evidence CONDITIONAL; store release still NO-GO; M34-006/007 BLOCKED, 146/148 unchanged.** Continued work must move to actual visual, native signed install, store/app records, and legal privacy gates.
