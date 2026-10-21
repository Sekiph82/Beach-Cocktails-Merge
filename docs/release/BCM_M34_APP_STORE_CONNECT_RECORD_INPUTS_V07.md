# Apple App Store Connect record creation inputs — V07

**State: PREPARED — OWNER AUTHORIZATION REQUIRED; NO APP RECORD CREATED.**

This is a copy-ready draft for the New App form. The previously inspected signed-in Apple team showed `Apps: No Apps`; that observation is scoped to that team and is not repeated here as a new portal audit. The App Store Connect record must not be created until the owner authorizes the exact immutable bundle identifier and SKU, confirms the team/role and user-access setting, and the official signed-in portal is verified.

| App Store Connect field | Prepared value | Gate |
| --- | --- | --- |
| Platform | iOS | Prepared |
| App name | Beach Cocktails Merge | Prepared; confirm name availability at creation |
| Primary language | English (U.S.) | Proposed from the English-source listing copy; owner to confirm before record creation |
| Bundle ID proposal | `com.sekiph82.beachcocktails` | Exact canonical release proposal; not confirmed as a registered standalone Apple App ID. Do not select the XTool-prefixed `XTL-A5DEDA47.com.sekiph82.beachcocktails` identifier as a substitute. Owner must authorize the immutable identifier and Apple Developer registration must be verified first. |
| SKU | `OWNER_TO_SUPPLY_UNIQUE_IMMUTABLE_SKU` | Required owner input. No SKU is invented or submitted. It must be unique in the Apple team and approved before creation because it cannot be changed after app creation. |
| User access | Owner to select Limited Access or Full Access | Requires the account’s intended collaborator access decision |

## Creation checklist

1. Owner confirms the Apple Developer team and Account Holder/Admin/App Manager authority.
2. Owner authorizes `com.sekiph82.beachcocktails` as the immutable release bundle ID; verify a standalone explicit App ID is registered for the same team. A differently prefixed identifier does not satisfy this check.
3. Owner supplies and approves the exact unique SKU. Do not use this document's placeholder as a value.
4. Owner confirms English (U.S.) as the primary language and chooses the access setting.
5. Verify the official signed-in `appstoreconnect.apple.com` origin and team, then create only the draft app record if all prior gates pass. Do not accept legal agreements or submit the app as part of this preparation.

## Existing release blockers

- The Windows host has no Xcode/macOS build path. No signed iOS archive or IPA was created in this task.
- Store privacy/support URLs, controller identity, age treatment, privacy disclosures, and final listing materials remain owner/legal review items.
- The V07 proposal does not enable ads or purchases. Future AdMob source remains preserved and ad placements remain disabled.

## Official Apple references

- [Add a new app](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app) — required record fields, roles, and the current agreement prerequisite.
- [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) — primary-language meaning, bundle-ID and SKU immutability, and SKU character rules.

These references were checked on 2026-10-21. No portal was opened or changed for V07.
