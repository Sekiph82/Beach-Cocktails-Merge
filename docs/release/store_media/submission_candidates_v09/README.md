# Store submission candidate package — V09

**Status:** `SUBMISSION_CANDIDATE`; not `STORE_READY`. See `submission_manifest_v09.json` for actual dimensions, byte lengths, SHA-256 values, source paths, and source capture identities.

## Google Play candidate contents

- One 512×512 RGBA listing icon candidate (existing V04 asset; 567,144 bytes).
- One 1024×500 RGB feature graphic candidate (existing artwork; 901,737 bytes).
- Six distinct 1080×1920 RGB screenshot compositions from existing genuine runtime captures: Home, World Map, Island Map, current tutorial-free gameplay, live merge, and To-Go gameplay. Three are gameplay screens. Daily Rewards is intentionally omitted.
- Source screenshots and existing compositions were copied byte-for-byte; originals remain intact. Each screenshot remains a desktop-origin candidate and needs owner/device visual review.

The asset validator checks candidate bytes and metadata, source identity, current listing field lengths, public HTTPS URL formats if present, local staging-page links, settings-link schema, unsigned/no-destination iOS export configuration, disabled ad placements, and nonbuyable products. It does not execute an export or modify the game.

## Apple iPhone screenshots

`apple_iphone/CAPTURE_PENDING.md` records why there is no Apple upload set: this workspace has no physical iPhone capture or signed iOS release UI. The current App Store Connect reference accepts a 1179×2556 portrait iPhone Dynamic Island medium display size. Do not rename or upscale the desktop captures as iPhone screenshots.

## Privacy and support staging

`../site_staging_v09/en/` and `../site_staging_v09/tr/` contain local index, privacy, and support pages copied from the existing bilingual staging drafts. They contain unresolved publisher/contact, retention, audience, signed-package data-flow, and legal-review fields. They are not deployed and provide no public HTTPS URL. The in-game Settings links remain unconfigured and disabled.

## Monetization and release status

Future AdMob source/configuration remains in the project; all seven placements remain disabled, store products remain nonbuyable, and no live ads/consent/SSV/billing claim is made. No PCK/AAB test or build, Android emulator, GitHub Actions run, signing, account write, or public release occurred in V09.
