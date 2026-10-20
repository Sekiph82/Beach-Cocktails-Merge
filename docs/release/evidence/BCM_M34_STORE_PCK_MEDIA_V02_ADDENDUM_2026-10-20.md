# BCM-M34 Store PCK Coverage and Media V02 — Static Evidence Addendum

**Scope:** Codex builder evidence for the V02 PCK/package remediation and store-material preparation. This is not an independent acceptance audit. Candidate Godot PCKs are marked `NOT SHIPPING`; public store status remains `NO-GO`.

## PCK coverage correction

The previous engine-only visible-file scanner skipped dot-prefixed directory names. On the existing ignored Android PCK, its submitted 645-entry manifest was reconciled against the actual Godot v4 directory index: 1,070 indexed payload entries, including 425 hidden `.godot/` entries. The iOS pack has the same count. The hidden entries include 381 `.godot/imported/` resources and 42 `.godot/exported/` entries. The former 645-entry listing was therefore incomplete.

`tools/release/pck_directory.py` now parses Godot PCK v2-v4 directory records directly and fails closed on unsupported/encrypted/sparse flags, invalid/duplicate paths, truncated records or payloads, invalid bounds, unsupported file flags, mismatched payload MD5, overlapping entries, or nonzero unindexed data gaps. Every indexed payload receives a SHA-256 and type/size record. Its PCK record/index layout follows the official Godot reader and writer implementation: [file_access_pack.cpp](https://github.com/godotengine/godot/blob/master/core/io/file_access_pack.cpp), [pck_packer.cpp](https://github.com/godotengine/godot/blob/master/core/io/pck_packer.cpp). `ProjectSettings.load_resource_pack` and `ResourceLoader` remain separate engine checks for main-scene loading, required runtime JSON, AdMob API availability, and disabled placements.

The PCK byte accounting is measured from directory index and payload ranges, not inferred from pack size:

| Candidate | PCK entries (hidden) | Payload bytes | Zero alignment bytes | Directory bytes | Header | PCK bytes | SHA-256 |
|---|---:|---:|---:|---:|---:|---:|---|
| Android | 1,049 (425) | 115,980,534 | 7,498 | 109,332 | 112 | 116,097,476 | `efe205c90509ccfa385e8d71c622ee192b463a6433a95c3bc261eff4a3d29eb4` |
| iOS | 1,049 (425) | 115,980,586 | 7,510 | 109,332 | 112 | 116,097,540 | `00ec7dfb9de83842431a34e89fd5970404a320df4ad1c9286a82b204d871d4a5` |

Both Godot 4.7.2 format-v4 candidate packs have complete directory coverage. All payload MD5 checks pass; all alignment gaps and trailing bytes are zero. The former Android visible PCK was 116,587,916 bytes and the new Android pack is 490,440 bytes smaller; iOS is likewise 490,440 bytes smaller. No nonzero unindexed bytes were found. The full per-file SHA-256 inventories are [Android V02](BCM_M34_ANDROID_CANDIDATE_PCK_MANIFEST_V02_2026-10-20.json) and [iOS V02](BCM_M34_IOS_CANDIDATE_PCK_MANIFEST_V02_2026-10-20.json).

Both rebuilt packs have zero forbidden development/source paths, zero asset metadata leaks, all required runtime JSON, a loadable main scene, preserved AdMob runtime API, no AdMob native binary, no Billing plugin/test adapter, and ads disabled in configuration. The owner-local shop catalog remains absent. The reports retain 381 current asset `.import` files and 127 `.remap` entries rather than deleting engine sidecars by extension. The two `.import` maps tied to the excluded metadata CSVs disappeared with their nonruntime sources; those repository files remain untouched.

## Asset-generation metadata and artwork review

The [metadata filter inventory](BCM_M34_RELEASE_METADATA_FILTER_INVENTORY_V02_2026-10-20.json) contains 23 exact files with type, size, source hash, search evidence, reason and disposition. Twenty-one report/catalog/status files and translation sidecars are excluded from both candidate profiles while retained in the repository. Two paired CSV `.import` maps are absent from the actual PCKs along with their nonruntime sources, but remain in the repository. Where consumers were found, they were confined to UI asset generation/validation tools or historical documentation; two report files had no current tool/runtime consumer. No runtime scene, script or data consumer was found. The PCK manifest independently proves those paths are absent.

No owner source art or historical evidence was removed. The current M34-005 R02 inventory remains 23 `REVIEW`, zero `DELETE`: no unused asset met the proof threshold for deletion. Its three contact sheets remain tool outputs. `.import` and `.remap` files for current runtime assets remain present in the PCK.

## Store media and text

- [Google Play feature graphic V02](../store_media/google_play_feature_graphic_v02.png): 1024×500 opaque RGB PNG, 901,737 bytes, SHA-256 `b1f1bc784b9c31ee0438aa5bce27949805becf030ed606d22a23c90972f272f5`. It uses the project’s current island-ocean background, brand logo and L03/L08 cocktail art; it is branded store art, not gameplay evidence, and remains owner-reviewable.
- No platform icon was falsely finalized. The square app-icon source is 256×256 RGBA; the inspected 1536×1024 higher-resolution logo is a landscape wordmark, not a square icon master. `OWNER_VISUAL_APPROVAL_REQUIRED`; no icon upscaling or arbitrary crop was retained.
- The screenshot plan contains eight real-screen capture layouts. Actual final-UI captures: **0**. Device-approved screenshots: **0**. Each layout remains `CAPTURE_PENDING`; the feature graphic is explicitly not a gameplay screenshot.
- [EN/TR listing copy](../store_media/BCM_M34_STORE_COPY_V02.md) includes Apple and Play titles, short descriptions, keywords, and descriptions, with platform limits tested. There are no claims that ads, purchases, accounts, or online play are ready.
- [EN/TR privacy and support drafts](../store_media/BCM_M34_PRIVACY_AND_SUPPORT_DRAFT_EN_TR_V02.md) mark owner/legal, provider, retention, access/deletion, age, UMP, ATT, URL and contact fields for review. No public policy/support URL or mailbox was verified. Store privacy declarations remain pending the exact signed packages.
- `ads_provider_policy.json` remains default-off and every placement remains disabled. Future AdMob API/placement source remains intact; candidate packs contain no native AdMob binary and do not prove native mobile ads.

## Verification and limits

- `python -m unittest discover -s tests -p test_release_export_boundaries.py -v` — **15/15 passed**, including hidden forbidden PCK paths, fail-closed incomplete coverage, release metadata boundaries, bilingual store text limits, feature-graphic PNG dimensions/alpha, and owner-review/capture-pending markers.
- `godot --headless --editor --path . --quit` — exit 0, no reported parse/import error.
- Android and iOS `--export-pack` for their exact `NOT SHIPPING` presets — exit 0 each; both actual PCK inventories and `check_export_boundaries.py --archive` — `PCK_INSPECTED_PASS`.
- Previous strict core 21/21 was not repeated because this batch did not change game/runtime scripts; current runtime entrypoint was independently loaded from each candidate PCK.
- Java, Gradle, Xcode, and a connected Android device were unavailable. `adb devices -l` listed no device. No signed AAB, IPA/archive, install, device screenshot, store portal, legal agreement, upload, public URL, deployment, live ad or purchase was performed.
- **Public release: NO-GO** until owner launch/legal/age/privacy choices, accepted icon and device captures, real signed platform outputs, platform compliance and review evidence are completed.
