# Codex Execution Log — BCM-M30 Store Release Pipeline Master V01

**Stop marker: `AWAITING_GPT_M30_MILESTONE_AUDIT`**

## Work item and repository baseline

- Work item: `BCM-M30-001`, `BCM-M30-002`, and `BCM-M30-003`, one continuous milestone; prompt `CHATGPT_M30_MASTER_PROMPT_V01.md`, locked criteria `BCM_M30_MASTER_AUDIT_CRITERIA_V01.md`.
- Canonical branch/remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`). Godot target: 4.7.x.
- Pre-task local HEAD: `d4c67f487bfb8dd1075a2f7260818b6ab301ee9e`; synchronized start HEAD: `f594822c8426331e11308e4d3cf97500312edb14`.
- Required sync preflight: initial status was `main...origin/main` with seven modified tracked paths and five untracked owner paths; `git remote -v` identified canonical `origin`; `git fetch origin main` fetched `f594822`; `git rev-list --left-right --count HEAD...origin/main` returned `0 5`. Incoming changes were `TASKS.md` and M29/M30 coordination files, disjoint from every dirty path.
- Preserved owner work with the documented safe procedure: recorded all dirty paths; created tracked-only stash `owner-local-safe-sync-d4c67f4` with an explicit seven-path list and no `-u`; left untracked files untouched; fast-forwarded via `git merge --ff-only origin/main`; applied the new stash without dropping it. No conflict. All owner-local changes remain unstaged and outside every M30 commit.
- Preserved modified tracked owner paths: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/mobile_qa/M21-001_MOBILE_LAYOUT_TOUCH_QA.json`; `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/progression/M21-003_FULL_PROGRESSION.json`; `coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-001/plugin_runtime_inventory.json`; `coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-002/semantic_bridge_probe.json`; `coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-003/policy_validation.json`; `coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-003/state_hash_parity_report.json`; and `project.godot`.
- Preserved untracked owner paths: two M21 Home reference/critique PNGs; M23 initial mobile QA text; M23-R01 evidence directory; and `docs/codex-logs/CODEX_LOG_M23_R01_V01.md`.
- Owner/source hash integrity: `git hash-object --path=<path> <path>` matched `git rev-parse 'stash@{0}:<path>'` for all seven restored tracked owner files, including `project.godot`. Blob IDs: `9cf04d8bdfc59f6fe4c280e74b2be3c528a721b9`, `5a5874f6c9e88bfc6790e66e46b5e27ef0da82db`, `c544e04999a311253ad05a78fb3062620aa63233`, `a68549c80cee7112f7541496b82174a62a2da91e`, `8d6a2e26b3baac21eab6d4063ffa09c8decae48b`, `d2d36f8282e7d96e96649b545e9628b7196684da`, `9121d5008a528c6cc8b620c5194b9b5cb82916f9` respectively. All five untracked owner paths were present. Both new workflow files' working-tree blob IDs matched committed HEAD: Android `a78e36d62bdae1380fc675204cec272ac5bcce3f`; iOS `b4a10cea013758a976108cf2b5f2460877f04c85`.

## Child results and commit sets

### M30-001 — Android Play AAB

- Added a separate manually dispatched AAB workflow with validation-only default and protected-secrets signed mode. It pins package ID `com.sekiph82.beachcocktails`, owner-entered version name, a distinct run/attempt version code, min API 24, target API 36 and arm64; uses Godot 4.7.2 and its matching export templates; pins Android platform 36, Build Tools 36.1.0 and NDK 29.0.14206865; enables Gradle AAB output and release signing; and verifies the resulting AAB signature before retaining an internal CI artifact.
- Missing owner signing secrets or unequal store/alias passwords fail closed. No debug keystore is generated/configured in the release preset. The signed job is restricted to canonical `main`; owner must restrict the GitHub `android-play-upload` environment to `main` before secrets are added.
- Current policy was checked on 2026-10-12: Google Play requires API 36+ for new apps and updates from 2026-08-31. Godot 4.7.2's tagged Android Gradle config supports API 36 and pins the corresponding platform toolchain. References: [Google Play API policy](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en), [Godot 4.7.2 Android config](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/platform/android/java/app/config.gradle).
- Commits: `679091d105c517e5cd23242a60621abdcccad9dc`, `645bc5d61871195f8d5d1a717cc02eab1e7f309d`, `8fc8dbbefb12dd36c27c078a6dee4e850e6e002c`; child log commit `5e96318665ce6ab8e15273c0157a4d389ae1dfe1`.
- Evidence/log: `coordination/sessions/BCM-M30-STORE-RELEASE-PIPELINE-V01/evidence/M30-001/ANDROID_PLAY_AAB_PREPARATION_V01.md`; `docs/codex-logs/CODEX_LOG_M30_001_ANDROID_AAB_V01.md`.

### M30-002 — Apple App Store distribution

- Added a separate manually dispatched App Store export workflow with toolchain-validation-only default. Signed mode requires protected owner-provided Team ID, distribution P12/password, and App Store profile; verifies profile Team/App ID and distribution properties; uses manual signing and exports a signed IPA as a CI artifact without uploading to App Store Connect or TestFlight.
- Workflow checks the runner's actual Xcode and iOS SDK versions and stops below Xcode 26/iOS 26 SDK. Signed mode is restricted to canonical `main`; owner must restrict the `app-store-distribution` GitHub environment to `main` before adding credentials.
- Apple's current requirement effective 2026-04-28 is Xcode 26+ and iOS 26 SDK+. References: [Apple SDK requirement](https://developer.apple.com/news/upcoming-requirements/?id=04282026a), [Apple upload guidance](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/), [GitHub-hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [Godot iOS export](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_ios.html).
- Commits: `10c9f43fa812264521ef5b3fd2ae32f70976ad36`, `dd9a3621f861b2a4bd01879c8dc06952918ed5dc`, `83a53431726cdb4d7b9a642212150f8b32d1a11d`; child log commit `0f4e33968c1938f65e61d987f5a9e9334b6406f3`.
- Evidence/log: `coordination/sessions/BCM-M30-STORE-RELEASE-PIPELINE-V01/evidence/M30-002/APPLE_APPSTORE_DISTRIBUTION_PREPARATION_V01.md`; `docs/codex-logs/CODEX_LOG_M30_002_APPLE_DISTRIBUTION_V01.md`.

### M30-003 — Package policy gate

- Added a concise source-versus-package evidence gate recording known identity/icon/addon/helper facts and explicitly unverified package permissions, entitlements, SDKs, manifests, signatures and data flows. It includes the exact Android/iOS artifact inspection steps to run when real packages exist and the owner decisions required for Google Play/App Store declarations, listings and ratings.
- No privacy declaration was inferred. The Godot AI/editor-helper footprint in store builds remains a package-review question. Public store release remains `NO-GO`.
- Commits: `fae67cf39f7f13bafb8681cd7683c02f20991b2c`, `2633c4df77732f363f71366ec6a3ef552363ec4d`, `af363689bb13eda095b442de625c7b6962bf778a`; child log commits `97b10672a18eff246e676e35c5d85afd324e959a` and `02cb1b4df77ea5eed587da023af1b05dbace9aa2` (corrected inventory command record).
- Evidence/log: `coordination/sessions/BCM-M30-STORE-RELEASE-PIPELINE-V01/evidence/M30-003/STORE_PACKAGE_POLICY_GATE_V01.md`; `docs/codex-logs/CODEX_LOG_M30_003_PACKAGE_POLICY_V01.md`.

## Validation and explicit limits

- `python` with PyYAML parsed both new workflow files and confirmed `workflow_dispatch` is present.
- Every embedded workflow `run` block passed `bash -n` using Git for Windows Bash.
- `git diff --check` and staged-diff checks passed.
- `git diff --exit-code origin/main -- .github/workflows/android-apk.yml .github/workflows/ios-ipa.yml` passed: the successful family-test APK and unsigned IPA workflows are unchanged.
- Source inventory search `rg --files -g '*PrivacyInfo.xcprivacy'` returned no paths. This is not package evidence.
- No Godot import, parse, runtime, export, Android/iOS build, device test, CI dispatch, credential inspection, GitHub environment edit, Play Console/App Store Connect action, upload, TestFlight submission, or public release was performed. No tests were added or run. No signed AAB/IPA existed, so generated manifest/plist, permissions, entitlements, SDK inventory, privacy manifests and signatures remain `UNVERIFIED`.
- Known owner requirements: add owner-held protected signing secrets; configure both GitHub environment deployment branch restrictions to `main`; determine whether the Godot AI helper/plugin should ship; inspect final signed packages and approve account-specific privacy/listing/rating declarations. Release remains `NO-GO` until these blockers are resolved.

## Repository publication checkpoint

- Before the master log was added, all 12 implementation/evidence/child-log commits had been pushed. At that checkpoint: local HEAD `97b10672a18eff246e676e35c5d85afd324e959a`; `origin/main` `97b10672a18eff246e676e35c5d85afd324e959a`; `git ls-remote origin refs/heads/main` returned `97b10672a18eff246e676e35c5d85afd324e959a`.
- Final implementation/evidence commit SHA at that checkpoint: `97b10672a18eff246e676e35c5d85afd324e959a`. This master log is a separate audit-handoff record; the final master-log commit is verified and published in the Codex handoff status.
- Root `TASKS.md` was not modified.

**Builder status: `AWAITING_GPT_M30_MILESTONE_AUDIT`.**
