# CODEX MASTER LOG — BCM-M29-STORE-PREPARATION-V01 — V01

Status: `BUILDER_SEQUENCE_COMPLETE; AWAITING_GPT_M29_MILESTONE_AUDIT`.

## Authority and scope

- Master prompt: `coordination/sessions/BCM-M29-STORE-PREPARATION-V01/CHATGPT_M29_MASTER_PROMPT_V01.md`.
- Locked criteria: `coordination/sessions/BCM-M29-STORE-PREPARATION-V01/BCM_M29_AUDIT_CRITERIA_V01.md`.
- Start HEAD after mandatory sync: `4d2fd67dd6e6472dd09762994a61d522a9f07618`; branch `main`; remote `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- The initial canonical checkout was four commits behind `origin/main`, with zero commits ahead. The seven modified tracked paths were inventoried; incoming changes touched none of them. A tracked-only stash named `owner-local-safe-sync-f8652a7` was created and applied after fast-forward. Five untracked owner-evidence groups were left untouched. No conflict occurred.
- After synchronization, local `HEAD = origin/main = 4d2fd67dd6e6472dd09762994a61d522a9f07618`, ahead/behind `0/0`. The same seven tracked owner diffs and five untracked owner-evidence groups remain present, unstaged, and excluded from M29 changes. `TASKS.md` is unmodified.
- Read-only release/store-preparation inventory was completed as one continuous three-child sequence. No product code, owner project settings, export workflow, secret, credential, user save, or visual/gameplay asset was changed. No Actions workflow was triggered, package built/downloaded, device test run, store listing edited, or store upload attempted.

## Child sequence and findings

### BCM-M29-001 — Android Play preparation

Evidence: `CODEX_LOG_M29_001_ANDROID_PLAY_PREPARATION_V01.md`.

The current Android workflow is a manually dispatched, debug-signed APK flow (`com.sekiph82.beachcocktails`, `Beach Cocktails Merge`, run-number version); it does not create an AAB or configure a production upload key/Play App Signing. It does not pin an Android target/minimum API in the generated preset. Google's current new-app requirement is AAB and Android 16/API 36 or later from August 31, 2026. A final AAB/manifest/signature inspection and Android device acceptance are open. Play account/key custody, version/support policy and accurate Console declarations require owner action.

### BCM-M29-002 — Apple App Store preparation

Evidence: `CODEX_LOG_M29_002_APPLE_STORE_PREPARATION_V01.md`.

The current iOS workflow exports an Xcode project and packages an unsigned `.app` as an IPA, uses placeholder team ID `AAAAAAAAAA`, and has no explicit version/build policy or App Store upload step. App Store distribution requires an explicit App ID/bundle identity and a real distribution signing/provisioning path. Apple's current 2026 upload policy requires iOS builds to use Xcode 26 or later; the workflow uses floating `macos-latest` and does not assert the installed Xcode version. Account ownership, display/package metadata, versioning, minimum OS, and signed-package review remain open.

### BCM-M29-003 — privacy and listing evidence

Evidence: `CODEX_LOG_M29_003_PRIVACY_AND_STORE_LISTING_V01.md`.

Reviewed gameplay paths indicate local saves and no first-party game-service/ads/analytics/network calls in the scanned production script/data paths. However, synchronized `project.godot` includes the Godot AI game-helper autoload and editor plugin; the plugin code has editor-side telemetry/network integrations. The game's final exported file set, debugger channel behavior, transitive dependencies, generated permissions/plists/manifests and actual collection remain unverified. Store declarations must not claim “no data collected” on this source-only evidence. Privacy, age/content, target-audience, support/contact, listing, market and data-practice decisions require owner input and package-level verification.

## Builder conclusion and open gates

- This pass documents the starting Android, Apple, privacy and listing state and current official platform requirements. No safe additive code/workflow check was needed to complete this evidence-only scope; changing owner-dirty `project.godot` or existing private-test workflows would exceed the demonstrated need.
- The existing family-test APK and unsigned IPA workflows remain unchanged. Their previous success is not upgraded into public-store readiness.
- Public store readiness remains `NOT READY / OWNER AND PACKAGE GATES OPEN`. This is a builder finding, not an independent verdict or a tracker transition.
- Required future evidence includes signed release AAB and App Store archive/package from owner-approved identities; actual API/minimum OS and version metadata; generated manifest/plist and permission/signature inspection; addon/SDK/privacy-manifest/data-flow inventory; Android device QA; Apple device/OS coverage; approved store disclosures/listings/ratings; and account-owner review. No public submission is authorized by this work.

## Files changed

- `docs/codex-logs/CODEX_LOG_M29_001_ANDROID_PLAY_PREPARATION_V01.md`
- `docs/codex-logs/CODEX_LOG_M29_002_APPLE_STORE_PREPARATION_V01.md`
- `docs/codex-logs/CODEX_LOG_M29_003_PRIVACY_AND_STORE_LISTING_V01.md`
- `docs/codex-logs/CODEX_LOG_M29_MASTER_V01.md`

## Commands, validation and publication

- Reviewed synchronized prompt/criteria, root governance and tracker; current Android/iOS workflow YAML; M28 child/master evidence; synchronized project configuration; tracked addon/plugin inventory; targeted source searches; and current official Google/Apple documentation.
- No tests, Godot runs, exports, workflows, artifact downloads or device checks were performed; no implementation change justified them. Validation is documentation/source evidence only. Run `git diff --check` before committing.
- Every commit must stage only these four new log files. `TASKS.md` must remain byte-for-byte unchanged. Owner-local diffs and untracked evidence remain outside the commit.
- Final start/end/commit SHAs and proof that local `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` match will be recorded in the publication handoff after push. This master log is builder evidence; independent ChatGPT audit is the stop condition.

Required stop marker: `AWAITING_GPT_M29_MILESTONE_AUDIT`.
