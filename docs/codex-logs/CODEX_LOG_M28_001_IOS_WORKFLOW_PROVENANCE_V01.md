# CODEX LOG — BCM-M28-001 — V01

Status: `BUILDER_EVIDENCE_COMPLETE; INCLUDED_IN_M28_MASTER_AUDIT_HANDOFF`.

## Scope and authority

- Work item: `BCM-M28-001`, prompt V04 at `coordination/sessions/BCM-M28-RELEASE-READINESS-V01/CHATGPT_M28_MASTER_PROMPT_V01.md` (the file retains its V01 filename).
- Locked criteria: `coordination/sessions/BCM-M28-RELEASE-READINESS-V01/BCM-M28_MASTER_AUDIT_CRITERIA_V01.md`.
- Start HEAD: `41609fc289e3df6bac25632b67186b675005aef4`; branch `main`; remote `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Sync preflight: canonical checkout was `9667a1c` and 0/26 ahead/behind after fetch. Seven tracked owner paths were inventoried; none overlapped the 507 incoming paths. Fast-forwarded to `41609fc`, reapplied the exact named tracked-only stash, retained untracked evidence, and confirmed no conflicts.
- This is a read-only workflow and artifact provenance review. No APK/IPA artifact was downloaded, no workflow was rerun, and no signing secret was accessed or emitted.

## Source and run findings

Both workflow files at their recorded build commits are byte-identical to the versions reviewed at start HEAD (`git diff <run SHA>..41609fc -- .github/workflows/<file>` produced no output).

| Platform / run | Run source SHA | Result | Artifact | Size | Artifact ID | Expiry |
|---|---|---|---|---:|---:|---|
| Android APK / [38078255160](https://github.com/Sekiph82/Beach-Cocktails-Merge/actions/runs/38078255160) | `b2e09946c6a9a5d7f8254934425d335ffd6f2edf` | `workflow_dispatch`, attempt 1, success | `BeachCocktails-apk` | 145,267,886 bytes | `11679690170` | 2027-01-08 19:03 UTC |
| iOS IPA / [38063815860](https://github.com/Sekiph82/Beach-Cocktails-Merge/actions/runs/38063815860) | `c131189a952e5cabfce9a6af326944ffc84defc1` | `workflow_dispatch`, attempt 1, success | `BeachCocktails-ipa` | 146,697,875 bytes | `11674780517` | 2027-01-08 15:29 UTC |

GitHub Actions currently reports both artifacts present and unexpired. The different source SHAs are intentional and preserved as supplied in the active prompt; both are ancestors of the synchronized main HEAD. The IPA source commit is the touch single-shot fix. The Android source commit adds its workflow. Different SHAs are not evidence of an export mismatch.

### Android pipeline

- `.github/workflows/android-apk.yml` manually dispatches with a `ref` input (default `main`), uses Godot `4.7.2`, and exports arm64 debug APK.
- CI creates an ephemeral debug keystore using Android's conventional public debug alias/password values; no production keystore is present. The output is debug-signed and suitable for controlled sideload/family testing, not a release-signing artifact.
- Bundle/application identity is `com.sekiph82.beachcocktails` / `Beach Cocktails Merge`; version code and version name are derived from `GITHUB_RUN_NUMBER` (`0.1.<run number>`). The workflow references `assets/ui_assets/brand/app_icon.png`.
- The workflow grants only `contents: read`. It uploads the APK as a retained Actions artifact.

### iOS pipeline

- `.github/workflows/ios-ipa.yml` manually dispatches on `main` (no ref input), uses Godot `4.7.2`, exports an Xcode project and builds Release for `iphoneos`.
- The preset uses bundle identifier `com.sekiph82.beachcocktails`, `export_project_only=true`, the shared project icon at multiple iOS icon slots, and placeholder team ID `AAAAAAAAAA`.
- `xcodebuild` explicitly sets `CODE_SIGNING_ALLOWED=NO`, `CODE_SIGNING_REQUIRED=NO`, and empty `CODE_SIGN_IDENTITY`; the workflow zips the unsigned `.app` into the uploaded IPA. The team ID placeholder is not a usable distribution identity and does not turn this build into a signed store package.
- The action does not set an explicit iOS version/build number in its generated preset. The exported bundle version was not inspected because the artifact was not downloaded.
- The owner-managed `iPhone_Yukle.bat`/WSL/xtool path is external to the repository. Per the prompt, the owner successfully used the iPhone build and accepted its graphics, effects, and gameplay. That owner operation is not a store-signed export and no App Store approval is claimed.

## Reproducible release record

- Workflow source commits, run IDs, statuses, artifact IDs, sizes and expiry were queried from GitHub Actions metadata on 2026-10-12. Artifact contents and cryptographic digests were not retrieved; byte identity of a later download is therefore unverified.
- Workflow file hashes at review HEAD: Android `$(git rev-parse HEAD:.github/workflows/android-apk.yml)`; iOS `$(git rev-parse HEAD:.github/workflows/ios-ipa.yml)`.
- Exact Git blob IDs at review HEAD: Android `c431b6723cc3aaf77b761b3d65babd0ed147333b`; iOS `481c73141d7cae4451cb633a4cb7099b1d132c8e`.
- No code, workflow, project configuration, export preset, or secret changed for this child.
- `TASKS.md` was not modified.

## Commands and manual checks

- `gh run view 38078255160 --json ...` and `gh run view 38063815860 --json ...`: both `completed/success`, attempt 1; all export/build/upload steps succeeded.
- `gh api repos/Sekiph82/Beach-Cocktails-Merge/actions/runs/<run-id>/artifacts`: both named artifacts exist, unexpired; IDs, byte sizes and expiry recorded above.
- `git diff <run-sha>..41609fc -- .github/workflows/<workflow>`: no diff for either workflow; `git merge-base --is-ancestor <run-sha> 41609fc`: both true.
- Manually inspected both workflow YAML files and the exact iOS signing/export step. Artifact bytes, embedded signatures, install behavior, and actual generated Info.plist were not manually inspected.
- No test suite or Godot command was run; no product code changed.

## Limits

Successful workflow execution proves artifact production and upload, not device installability, signature validity, supported OS floor, or App Store/Play approval. The owner iPhone report is accepted only for the graphics/effects/gameplay scope stated in the owner ruling. Public distribution remains a separate future gate.

## Publication and child result

- Files changed for this child: this immutable log only.
- End HEAD/final publication SHA: the docs-only publication commit containing this log; it is recorded by Git history and the master handoff's final `git rev-parse`/remote equality check.
- Child result: `PASS — current manual test artifact provenance confirmed; public-store signing/provenance not provided by either pipeline.`
- Stop boundary: do not modify working workflows or start store publication; await the one independent M28 audit.
