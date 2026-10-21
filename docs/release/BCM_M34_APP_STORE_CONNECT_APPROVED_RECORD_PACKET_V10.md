# App Store Connect approved identity packet — BCM-M34 V10

**State:** Owner-approved inputs are recorded; App Store Connect app record and standalone Apple App ID are **not created** in this run because no owner-authorized signed-in Apple browser session was available to Codex. This packet is local preparation only.

| Field | Approved value | Portal status |
| --- | --- | --- |
| Platform | iOS only | Pending creation |
| App name | Beach Cocktails Merge | Pending name availability check |
| Release Bundle ID | `com.sekiph82.beachcocktails` | Standalone explicit App ID needs creation or exact reuse check |
| SKU | `BCM-IOS-2026-001` | Approved; account uniqueness check pending |
| Primary language | English (U.S.) | Pending creation |
| User access | Least privilege; choose Limited Access only if it limits this app to the Account Holder without changing collaborator access | Portal gate pending; do not choose Full Access by assumption |

## One-time actions authorized by owner

After the official authenticated Apple Developer and App Store Connect session is visible, verify the intended owner team and roles, check the exact standalone identifier and duplicate app/SKU, then create at most one matching iOS App ID and one nonpublished app record. If team, role, uniqueness, account agreement, or access is ambiguous, stop before the affected create action. Never accept legal or paid agreements, add users, set pricing, create purchases, upload a build, submit for review, or publish.

## Facts and open gates

- A prior authenticated-team audit on 2026-10-20 reported no app in that inspected team and found only the XTool-prefixed development identifier; it did not establish global absence. The V10 user-approved release identifier above is a separate standalone ID.
- The current Codex Computer Use inventory on 2026-10-21 exposed no application windows and no tabs in the available in-app browser. The prior Chrome profile is not present as an accessible signed-in session in this run.
- Do not infer an Apple numeric App ID, team, account agreement state, app record status, or successful creation.
- No legal agreement was accepted and no Apple account state was changed by this run.

## Official portal sources

- [Add a new app](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app)
- [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/)
