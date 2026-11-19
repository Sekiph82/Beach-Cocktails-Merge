# BCM-M34-006 / 007 owner decisions, adopted from ScrubBots (2026-11-19)

Owner instruction (2026-11-19): answer the open ads / billing / privacy questions the way the
owner's ScrubBots game (github.com/Sekiph82/Scrubbots) answered them, adapted to Beach
Cocktails Merge. Sources read: ScrubBots `store/DATA_SAFETY_AND_RATINGS.md`,
`docs/RELEASE_BUILDS.md`, `docs/RELEASE_GATES.md`, `data/config/store_products_v1.json`,
`docs/privacy/index.html`, `scripts/economy/*provider*.gd`, `scripts/economy/store_service.gd`.

## Decisions

| Open question | ScrubBots answer | BCM decision |
|---|---|---|
| Privacy policy URL | GitHub Pages from `main` `/docs`: `https://sekiph82.github.io/Scrubbots/privacy/` (EN + TR) | `https://sekiph82.github.io/Beach-Cocktails-Merge/privacy/` and `/support/` (`docs/privacy/index.html`, `docs/support/index.html`, `docs/.nojekyll`); wired in `data/ui/settings_links.json` and `ads_provider_policy.json` |
| Contact / support e-mail | `sekiphayit1982@gmail.com` | same |
| Age / audience | 13-15, 16-17, 18+; not under 13; Made for Kids **No**; AdMob max ad content rating **G** | same (`age_policy` = `GENERAL_AUDIENCE_13_PLUS_NOT_CHILD_DIRECTED_MAX_AD_RATING_G`) |
| Consent | Google UMP form when required, before the SDK initializes | same (`admob_rewarded_provider.gd`) |
| iOS tracking | ATT prompt after UMP, before init; denied still initializes (non-personalised) | same |
| Reward verification / backend | No account, no own server; reward only when the SDK reports "user earned reward" before the ad closes | same: `AdsService.set_native_provider` + `accept_client_earned_reward`; the Cloudflare SSV Worker is no longer required (kept in `backend/` unused) |
| Purchase verification | Platform-verified purchase (Play `PURCHASED` / StoreKit transaction), grant saved **before** consume / finish, token granted once | same: `StoreService.deliver`, reward id `store:<token>` in the saved economy ledger |
| Product catalog | 5 currency packs `scrubbucks_<n>` at 0.99 / 1.99 / 2.99 / 4.99 / 9.99 USD reference + `no_ads` | 5 gem packs `gems_25 / gems_140 / gems_300 / gems_650 / gems_1750` at the same reference prices and bonus curve (25 gems = one full energy refill). Same id on Google Play and App Store. `no_ads` left out: BCM shows no banner / interstitial, so there is nothing for it to remove |
| Displayed prices | Store's localized strings only | same (`StoreService.price_text`) |
| Ad formats | Banner + interstitial every 5 plays + App Open + rewarded | Rewarded only (BCM's existing opt-in energy / daily placements). Adding banner / interstitial is a game-design change and needs new AdMob units: owner decision |
| Test vs real ads | Google TEST units in every build until an explicit release with real ids | same (`test_ads_until_release = true`); real rewarded unit comes from `ads_provider_policy.json` only in a non-debug export with `test_ads_until_release = false` |
| Plugins | GodotGooglePlayBilling 3.3.0, godot-admob v7.0, godot-ios-plugins `inappstore` | first two already in `addons/`; `inappstore` must be built on macOS (no Mac and no GitHub Actions here) |
| Builds | GitHub Actions workflows | **Not used** (owner rule for BCM: no GitHub Actions). Android builds locally on Windows; iOS needs a Mac with Xcode |

## Store questionnaires (ScrubBots answers, BCM deltas marked)

- **Google Play Data safety**: collects / shares through the Google Mobile Ads SDK only: approximate location (IP), device IDs (Advertising ID), app interactions (ad views / taps), crash logs / diagnostics; encrypted in transit; no account; no deletion request needed (uninstall deletes data). Advertising ID: yes. Contains ads: yes.
- **App Store privacy label**: Device ID (only after ATT allow, used for tracking), coarse location, product interaction, advertising data, diagnostics; none linked to the user. `NSUserTrackingUsageDescription` required.
- **IARC / App Store age rating**: ScrubBots expects PEGI 3 / ESRB Everyone / 4+. **BCM delta:** the game is cocktail-themed. If the drinks are presented as alcoholic, answer "alcohol references: yes (infrequent / mild)" (expected PEGI 12 / Apple 12+ or 13+ band); if they are non-alcoholic tropical drinks, answer "no". Owner to confirm on submission day.

## Still owner-only

- Create the five `gems_*` products in Play Console and App Store Connect (consumable, same ids), Play merchant profile, Apple Paid Apps agreement.
- Turn on real ads only for a public release (`test_ads_until_release = false`, AdMob app id in `addons/AdmobPlugin/*_export.cfg` with `is_real=true`).
- Android release signing key; iOS distribution certificate / profile (needs a Mac).
- `energy_20` and `daily_slot_2` use the same AdMob unit on each platform: keep or create a separate unit.
