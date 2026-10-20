# Codex Execution Log â€” BCM-M34-006/007 PCK Coverage and Store Media V02

## Identity and synchronized start

- Work item: BCM-M34-006/007; prompt version: V02 (`coordination/sessions/BCM-M34-006-007-CODEX-COMPUTER-USE-OWNER-CONSOLES/BCM_M34_STORE_PCK_COVERAGE_AND_MEDIA_EXECUTION_V02.md`).
- Start HEAD: `9869ec4e8a792e0448a33b733003edd69f29c989`.
- Branch / remote: `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge` (`origin`).
- Required sync preflight: `git status --short --branch`; `git remote -v`; `git fetch origin main`; `git rev-list --left-right --count HEAD...origin/main`.
- Initial history was 0 ahead / 3 behind. All pre-existing dirty/untracked owner paths were inventoried. Their paths were disjoint from the incoming diff; the tree had no tracked modifications. `git merge --ff-only origin/main` advanced to the start HEAD above. Existing owner-local untracked items were left untouched. No reset, checkout discard, stash, rebase, or branch creation was used.
- `TASKS.md` was read-only and is absent from both implementation and log commits.

## Implementation and changed files

Implementation commit: `61fc055ef19921c1f0a486e79f23e4afb099fa8f`.

- `export_presets.cfg`: exclude only proven non-runtime asset catalogs, historical report/status files, and related translation metadata from both NOT SHIPPING candidate profiles; retain importer metadata generally and preserve all corresponding source files in the repository.
- `tools/release/pck_directory.py`, `tools/release/inspect_godot_pck.py`, `tools/release/inspect_godot_pck.gd`: replace visible-directory enumeration with hidden-inclusive PCK directory parsing and fail-closed payload/path/checksum/coverage accounting; retain Godot engine load checks, required runtime data checks, and AdMob API/source-presence plus production-disabled assertions.
- `tools/release/check_export_boundaries.py`: interpret nested PCK inspector output correctly and report the Godot AI helper as excluded from the inspected PCK.
- `tests/test_release_export_boundaries.py`: add focused PCK coverage, hidden forbidden-entry, fail-closed gap, metadata profile, retained `.import`, store-copy, graphic and pending-policy checks.
- `docs/release/evidence/BCM_M34_ANDROID_CANDIDATE_PCK_MANIFEST_V02_2026-10-20.json` and `BCM_M34_IOS_CANDIDATE_PCK_MANIFEST_V02_2026-10-20.json`: full entry manifests with hashes and inspection results.
- `docs/release/evidence/BCM_M34_RELEASE_METADATA_FILTER_INVENTORY_V02_2026-10-20.json`: path/size/hash/reference/disposition inventory for 23 candidate metadata paths.
- `docs/release/evidence/BCM_M34_STORE_PCK_MEDIA_V02_ADDENDUM_2026-10-20.md`: V02 evidence addendum; it does not claim independent acceptance.
- `docs/release/store_media/BCM_M34_STORE_COPY_V02.md`, `BCM_M34_PRIVACY_AND_SUPPORT_DRAFT_EN_TR_V02.md`, `BCM_M34_SCREENSHOT_LAYOUT_PLAN_V02.md`: bilingual store-copy and policy drafts plus an eight-slot screenshot plan. Store/legal fields remain owner-review items; zero real screenshots were captured or accepted.
- `docs/release/store_media/google_play_feature_graphic_v02.png`: 1024Ã—500 opaque RGB Play feature graphic using existing approved project imagery; not a gameplay screenshot. SHA-256 `b1f1bc784b9c31ee0438aa5bce27949805becf030ed606d22a23c90972f272f5`.

No gameplay/source artwork was deleted. The previous asset audit had 23 REVIEW / 0 DELETE; therefore no unused-art deletion was justified. The 21 proven derived/non-runtime metadata files and two associated CSV importer sidecars are filtered from candidate PCKs while retained in the repository. Other `.import` and `.remap` files remain included where present.

## Candidate PCK exports and verification

Godot 4.7.2 headless exports completed with exit code 0:

- `godot --headless --path . --export-pack "Android Store Candidate (NOT SHIPPING)" .godot/bcm_release_preflight/android_candidate_v02.pck`
- `godot --headless --path . --export-pack "iOS Store Candidate (NOT SHIPPING)" .godot/bcm_release_preflight/ios_candidate_v02.pck`

Both candidates passed the hidden-inclusive inspector and release-boundary check (`PCK_INSPECTED_PASS`):

- Android: 1,049 entries (425 hidden), 115,980,534 payload bytes, 7,498 zero alignment bytes, 109,332 directory bytes, 112 header bytes, 116,097,476 total bytes; SHA-256 `efe205c90509ccfa385e8d71c622ee192b463a6433a95c3bc261eff4a3d29eb4`.
- iOS: 1,049 entries (425 hidden), 115,980,586 payload bytes, 7,510 zero alignment bytes, 109,332 directory bytes, 112 header bytes, 116,097,540 total bytes; SHA-256 `00ec7dfb9de83842431a34e89fd5970404a320df4ad1c9286a82b204d871d4a5`.
- Both: no forbidden entries, no excluded-metadata leaks, no missing required runtime JSON, main-scene load succeeded, AdMob runtime API/source remains present, production ads remain disabled, and no native AdMob/Billing/test-adapter binaries were included.
- The repaired accounting includes hidden entries. The earlier visible-only scan found 645 entries while the old PCK held 1,070; the new PCKs account for all 1,049 retained entries. Each record's payload bounds and MD5 were verified and a SHA-256 recorded; non-zero uncovered gaps/trailers fail closed.
- The parser follows the Godot PCK directory and packing format represented by `core/io/file_access_pack.cpp` and `core/io/pck_packer.cpp`.

## Commands and results

- `python -m unittest discover -s tests -p test_release_export_boundaries.py -v` â€” **15/15 passed**.
- `godot --headless --editor --path . --quit` â€” exit code **0** (clean editor import/parse).
- `git diff --cached --check` before each commit and `git diff --check` â€” exit code **0**.
- Both Godot `--export-pack` commands above â€” exit code **0**; both inspected candidates passed.
- `git rev-list --left-right --count HEAD...origin/main` after pushing the implementation commit â€” `0 0`.

## Manual checks, limitations, and release status

- Inspected current Android/iOS export profiles, package inventories, feature graphic dimensions/alpha, store copy length constraints, and policy/screenshot draft markers.
- No Android device was connected (`adb devices -l` returned no devices). Xcode, Java, and Gradle were unavailable in this environment. Consequently no installable AAB/APK or IPA, native signing/build validation, physical-device install/visual acceptance, or real store screenshot was produced.
- Store account/portal publication, privacy/legal approval, public support/privacy URLs, deployment, and release acceptance were not performed. Store candidates remain **NOT SHIPPING / NO-GO** pending owner/legal, signing, device, and store evidence.
- The Android Play owner real-device verification remains pending. Apple team inspection showed no Apps. These are blockers, not passing criteria.
- AdMob integration remains preserved for future work, with production delivery off and no invented IDs, consent, SSV, or native SDK. Store billing remains disabled and grants none.
- The PCK parser intentionally fails closed on unsupported encrypted/sparse/flagged entry forms and on unaccounted non-zero bytes; such artifacts require an explicit parser extension and fresh validation.

## Repository result and ownership

- Implementation end HEAD / pushed source SHA: `61fc055ef19921c1f0a486e79f23e4afb099fa8f`.
- After the implementation push: `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `61fc055ef19921c1f0a486e79f23e4afb099fa8f`; ahead/behind was `0/0`.
- This execution log is a separate documentation-only commit, pushed afterward; its final repository parity is reported after that push.
- Explicit confirmation: `TASKS.md` was not modified or committed.
- Pre-existing owner-local untracked paths and ignored `.godot/bcm_release_preflight/` candidate artifacts were not staged or committed.
