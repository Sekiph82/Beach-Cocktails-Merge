# CODEX LOG — BCM-M29-003 — V01

Status: `SOURCE_AND_DECLARATION_INVENTORY_COMPLETE; OWNER_DECISIONS_AND_FINAL_PACKAGE_AUDIT_OPEN`.

## Authority and scope

- Work item: `BCM-M29-003`, M29 master prompt V01 and `BCM_M29_AUDIT_CRITERIA_V01.md`.
- Start HEAD: `4d2fd67dd6e6472dd09762994a61d522a9f07618`; branch `main`; remote `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Review covered synchronized source/configuration, all three tracked addons at a high level, M28 release/privacy evidence, and official current store requirements. The owner's dirty `project.godot` was preserved; statements about project configuration below refer to synchronized `HEAD`.
- No store account, package, user device, credential, network capture, or platform console was accessed. No declaration was submitted and no store upload occurred.

## Observed source facts and boundaries

- The synchronized project uses portrait orientation and project name `CocktailMerge`. The Android workflow overrides its package display name to `Beach Cocktails Merge`; the iOS generated display name was not inspected. Both workflows use `com.sekiph82.beachcocktails`.
- Game save/settings source and M28 evidence describe local `user://` persistence. The targeted production-source scan found no gameplay HTTP client, analytics, advertising, account, or network-service calls in the reviewed `scripts/`, `scenes/`, and `data/` paths. Local validation telemetry in test harness code is not evidence of production user analytics.
- `project.godot` in synchronized `HEAD` enables the Godot AI editor plugin and registers `_mcp_game_helper` as an autoload. Godot AI source includes an editor telemetry feature and editor-side HTTP/WebSocket integrations. Its game helper describes itself as debugger-channel-only and idle when no debugger is active. The final exported package's included files, runtime debugger state, network behavior, and any third-party SDK data flow were not inspected. Therefore this source review does not support a final “no data collected” or “no tracking” declaration.
- `game_feel_flow`, `godot_ai`, and `saltmire_spark` are tracked addons. Their complete shipped footprint and any transitive components/privacy manifests have not been reconciled against final Android/iOS packages. No app privacy manifest (`PrivacyInfo.xcprivacy`), platform permission usage text, or generated package manifest/plist was found in the tracked source inventory; this does not prove the export has none.
- No final target-audience, children/families, advertising, age-rating, data-collection/sharing, data deletion, tracking, content-rights, or privacy-policy decision was invented. Store declarations require the owner to make and approve these decisions using final package and dependency evidence.

## Required store disclosure/listing work

- Google Play: privacy policy URL; Data safety covering app and SDK/library transmissions; target audience and content; ads status; app access/review instructions; IARC content-rating questionnaire; store listing name, descriptions, screenshots/graphics, category, contact details and country availability; permissions declarations if generated manifest requests restricted permissions.
- Apple: privacy-policy URL; App Privacy data types/practices across app and third-party partners; privacy manifests/required-reason APIs where applicable; App Store age-rating questionnaire; app name/subtitle/category/description/keywords, screenshots/previews, support URL/contact, copyright/content rights, export-compliance answers, review notes/access, and availability/localization choices.
- Open owner decisions: publisher/legal display name and contact; privacy policy owner/URL; target audience and whether children are intended; age/content questionnaire responses (including alcohol references, chance-based features and user controls as actually present); ad/data collection/sharing answers; support URL; locales/markets; copyright/content-rights representation; permitted collection/retention/deletion practices; whether the Godot AI editor/plugin helper should be excluded from store builds; final minimum OS/API and supported-device policy.

## Evidence, source references, and validation

- Official references reviewed on 2026-10-12: [Google Play Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en), [Play target audience and App content](https://support.google.com/googleplay/android-developer/answer/9867159?hl=en), [Play content-rating questionnaire](https://support.google.com/googleplay/android-developer/answer/9859655?hl=en), [Apple app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy), [Apple privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), and [Apple age ratings](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/).
- No tests or builds were run because this child is an evidence inventory and no product code changed. No static privacy scan can substitute for final package and dependency review.
- `TASKS.md` was not modified. This log is builder evidence only; independent audit remains pending.
