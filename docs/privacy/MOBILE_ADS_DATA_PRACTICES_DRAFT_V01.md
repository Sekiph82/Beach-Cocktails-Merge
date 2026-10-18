# Mobile ads data practices — owner/legal review draft V01

**Not a published privacy policy. Not legal advice. Owner must review this against the exact release SDK, app behavior, audience/age decision, consent settings, and jurisdiction before enabling ads or submitting store disclosures.**

This app is preparing an optional rewarded-ad feature using the Google Mobile Ads SDK and Google User Messaging Platform (UMP). If enabled, Google documents that its SDK may collect and share device IP address (which may estimate general location), app/ad interactions such as launches, taps and video views, diagnostics/performance data, and device identifiers for advertising, analytics and fraud-prevention purposes. iOS disclosures also identify advertising data and user-associated performance data. Which data is processed can depend on SDK version, consent, device/platform settings, region, and optional features.

The intended ad format is opt-in rewarded video. A reward is delivered only after the app's trusted server verifies Google's signed server-side callback; a device callback alone does not grant in-game value. Ad functionality stays disabled until privacy/age/consent choices, a public policy URL, a trusted backend, and device tests are complete.

## Owner/legal questions still open

- Final audience and age-directed / under-age-of-consent treatment, including whether the game is directed to children.
- Regions served and applicable consent law; exact UMP message/configuration, consent revocation behavior and non-personalized/limited-ad behavior.
- iOS ATT decision, user-facing purpose string, and App Store privacy-manifest/data declarations.
- Google Play Data safety answers and App Store Connect privacy answers for the exact shipped app and all SDKs.
- Final public privacy policy URL and data-retention/contact/deletion wording, based on the owner’s actual account and support processes.

## Official SDK references consulted

- [Google Mobile Ads SDK iOS data disclosure](https://developers.google.com/admob/ios/privacy/data-disclosure)
- [Google Mobile Ads SDK Android Play data disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure)
- [Google UMP consent SDK overview](https://support.google.com/admob/answer/10113209)

Recheck these disclosures at release time. The included AdMob release pins Android GMA 24.9.0 and iOS Google Mobile Ads SPM 12.14.0; upstream privacy disclosure pages change as the SDK changes. Do not copy this draft into a public legal page without owner/legal review.
