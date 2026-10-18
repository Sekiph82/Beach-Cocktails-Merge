# BCM-M34-006/007 Computer Use and Store Account Reconciliation — Codex Log V01

## Scope and authority

- Work items: existing canonical tasks `BCM-M34-006` (rewarded ads) and `BCM-M34-007` (native billing).
- Prompt: `coordination/sessions/BCM-M34-006-007-CODEX-COMPUTER-USE-OWNER-CONSOLES/BCM_M34_006_007_CODEX_COMPUTER_USE_ACCOUNTS_AND_IPA_RECONCILIATION_MASTER_V01.md`.
- Start HEAD after mandatory sync: `89efbcaebea429d14851803a82a230bbf5d58a45`.
- Branch/remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- `TASKS.md` was not modified; ChatGPT retains tracker and independent-audit authority.
- Execution timestamp: 2026-10-18 UTC. Windows Computer Use was used against the already-open authorized Chrome tabs.

## Sync-first preflight and preservation

- Ran `git status --short --branch`, `git remote -v`, `git fetch origin main`, and `git rev-list --left-right --count HEAD...origin/main` before reading the active prompt.
- Before sync, local `main` had no tracked modifications and was 0 ahead / 3 behind. Current untracked owner files/directories were inventoried; incoming paths (`TASKS.md` and the two new M34 prompt/audit files) did not overlap any untracked path.
- `git merge --ff-only origin/main` fast-forwarded from `c36aad16846416f2311e2409eddc48c1ad2dfe37` to `89efbcaebea429d14851803a82a230bbf5d58a45`. Local `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` matched after sync.
- No stash, branch, worktree, reset, rebase, cleanup, or task-tracker edit was made. Existing untracked owner work remained present and unstaged.

## Live owner-console findings and actions

### Apple Developer and App Store Connect

- Developer Program membership was active. The Developer account agreement panel showed the October 14, 2026 program agreement accepted October 18, while App Store Connect continued to display an updated-agreement warning requiring the Account Holder. The contradictory live states were left for the Account Holder to resolve; no legal agreement was accepted by Codex.
- Free Apps Agreement was active with a newer version available. The Paid Applications Agreement was not active/available as an accepted agreement in the inspected view; Apple states it is required for paid apps and IAP.
- Apple Identifiers contained an XTool-prefixed ID `XTL-A5DEDA47.com.sekiph82.beachcocktails`; no standalone canonical `com.sekiph82.beachcocktails` App ID was present. No identifier or App Store Connect app record was created because this requires the owner’s explicit release-identifier approval and the agreement warning remained.
- App Store Connect Apps was empty. No submission, TestFlight distribution, upload, signing credential inspection, or financial/legal action occurred.

### Google Play Console

- The personal developer account showed two outstanding gates: real Android mobile-device verification and contact-phone verification after identity verification. `Create app` was disabled until verification. Codex did not emulate device verification, submit identity/phone details, or create an app record.
- No Play App Signing, license tester, product, or app-record state was available without a Play app. No AAB upload, purchase, release, or publication occurred.

### AdMob

- Account home initially showed setup 1/4 and account verification pending. After app setup, it showed setup 2/4, “Your account isn’t approved yet”, and “Link to app store”; earnings, requests, and impressions remained zero.
- Created one unpublished AdMob app record per platform, without falsely claiming store publication:
  - Android app ID: `ca-app-pub-9989151157632993~6639288823` (AdMob record `6639288823`).
  - iOS app ID: `ca-app-pub-9989151157632993~7625067439` (AdMob record `7625067439`).
- Created and verified persisted opt-in `Rewarded` units with reward metadata matching current game placements. Energy 20 is shared by `energy_20` and `daily_slot_2`; the other placements have distinct units:

| Platform | Placement(s) | AdMob unit ID | Reward metadata |
|---|---|---|---|
| Android | `energy_20`, `daily_slot_2` | `ca-app-pub-9989151157632993/9764145618` | 20 Energy |
| Android | `daily_slot_3` | `ca-app-pub-9989151157632993/1128861711` | 40 Coins |
| Android | `daily_slot_4` | `ca-app-pub-9989151157632993/5274236265` | 2 Gems |
| Android | `daily_slot_5` | `ca-app-pub-9989151157632993/4876535032` | 80 Coins |
| iOS | `energy_20`, `daily_slot_2` | `ca-app-pub-9989151157632993/7241924059` | 20 Energy |
| iOS | `daily_slot_3` | `ca-app-pub-9989151157632993/2759928570` | 40 Coins |
| iOS | `daily_slot_4` | `ca-app-pub-9989151157632993/5082664575` | 2 Gems |
| iOS | `daily_slot_5` | `ca-app-pub-9989151157632993/5998045018` | 80 Coins |

- All eight rewarded units were present in their platform app’s Ad units list with `Rewarded` format and zero active campaigns; account and app approval/review are still pending. Ad unit IDs are configuration identifiers, not secrets. No production ad request, impression, click, campaign, or payout was generated.
- No app-store link was added to AdMob because neither store record exists. No privacy, age/families, UMP, iOS ATT, payment, or account-verification choice was made.

## Existing iPhone IPA path

- Located the existing owner desktop installer at `C:\Users\sekip\Desktop\iPhone_Yukle.bat`; read it only. Size: 2,352 bytes; SHA-256: `AACC57EF3FEEEA3C62E3D3764835131BEC6C8F562257B081B7220B083AC630CA`; last-write time: `2026-10-10T13:08:54.7839352Z`.
- The BAT remains unchanged. It is a personal-device XTool installer and performs USB detach/unbind, firewall/portproxy changes, `usbmuxd` restart, and `xtool install`; Codex did not execute or modify it. Current `usbipd list` showed no iPhone; WSL has `xtool` and `idevice_id`, but `idevice_id -l` returned `Unable to retrieve device list` (exit 255). No physical-device install/open smoke was run.
- No `.ipa` was found in the canonical repository, Desktop root, or Downloads root. Historical M28 logs cite a successful unsigned IPA CI artifact and owner-reported personal-iPhone use; that historical report was not re-run or independently reverified in this task. The exact artifact bytes were not downloaded or hashed.
- `.github/workflows/ios-ipa.yml` remains unchanged: it produces an unsigned IPA using canonical bundle ID `com.sekiph82.beachcocktails` and placeholder Team ID, intended for the separate personal sideload route. `.github/workflows/ios-appstore-export.yml` is a separate owner-secret-gated signed export path and contains no App Store Connect upload. No workflow was dispatched, no keys/certificates were read, and no IPA was rebuilt.
- Android signed AAB workflow inspection showed protected owner signing inputs and no Play upload step. Secrets were not inspected or emitted.

## BCM-M34 implementation and test evidence

- Updated `data/campaign/ads_provider_policy.json` with the genuine AdMob app IDs and per-placement rewarded unit maps. All ad placements remain disabled, consent is still required, age/UMP/ATT remain owner decisions, SSV remains required, and device authorization remains false.
- Updated `scripts/campaign/ads_provider_config.gd` to validate the required Android/iOS placement maps, reject malformed AdMob unit IDs, return a unit only for a known platform/placement, and keep the production gate blocked until the remaining owner/privacy/SSV/device/native-SDK requirements close.
- Extended `tests/m34_rewarded_ads_lifecycle_probe.gd` to verify exact platform IDs and placement mapping, unknown placement/platform rejection, and unchanged fail-closed diagnostics.
- Commands and results:
  - `python -m json.tool data/campaign/ads_provider_policy.json` — PASS.
  - `python tests/run_regressions.py tests/m34_rewarded_ads_lifecycle_probe.gd tests/m34_economy_closure_probe.gd tests/m34_daily_rewards_probe.gd` — **5/5 PASS** (editor import, 3 focused probes, startup smoke).
  - `python tests/run_regressions.py` — **13/13 PASS**, including M33 navigation, gameplay bridge, VIP/economy, production routes, campaign-content, editor import, and startup smoke.
  - `git diff --check` — PASS.
- No native ad SDK/plugin or production provider was integrated; no trusted SSV backend, UMP consent, ATT, mobile native runtime, or device callback was exercised. M34-006 remains blocked on those requirements.
- M34-007 remains blocked: project store catalog still contains placeholders; product IDs/prices/entitlement and restore/refund decisions plus receipt-validation backend, Play app/testers, Apple app/sandbox testers, and legal agreement state remain unresolved. No billing purchase, store product, or receipt was created.

## Files and repository state

- Intended tracked changes: `data/campaign/ads_provider_policy.json`; `scripts/campaign/ads_provider_config.gd`; `tests/m34_rewarded_ads_lifecycle_probe.gd`; this new log.
- No source/screen/workflow for the existing iPhone personal-install route was changed. No screenshot containing account/profile information was added to the repository.
- Root `TASKS.md` was not modified. Existing owner-local untracked paths were not staged or altered.
- Local `HEAD`, `origin/main`, and live remote `main` must be equal after the implementation commit is pushed; SHA verification is recorded in the publication closeout below.
- Final marker: `AWAITING_GPT_M34_006_007_INDEPENDENT_AUDIT_V01`.

## Publication closeout

- Implementation commit: pending at log creation.
- Final local `HEAD` / `origin/main` / remote `main`: pending post-push verification.
