# Store icon replacement specification — V03

**Status: `BLOCKED_OWNER_ART_SOURCE` / `OWNER_VISUAL_REVIEW`**

## Audit result

Inspected the current owned brand sources under `assets/ui_assets/brand/` and `assets/ui_assets/v04_masters/` (and confirmed no suitable `v05_sources` icon master was present). The existing `app_icon.png` is 256×256; the other square marks are 220×220 and 128×128. `logo_beach_cocktails_merge.png` is 253×512, `logo_concept_v03.png` is 1536×1024 landscape artwork, and the menu master is 941×1672. These files do not provide a faithful high-resolution square icon master or separable vector/layer source for reconstruction.

No store icon candidate was created. Upscaling or cropping these sources would invent edge detail or composition and would not meet the prompt's source-fidelity requirement.

## Replacement brief

- Supply/approve a source-authentic square 1024×1024 RGBA or opaque PNG master, with documented source file(s), SHA-256, license/ownership, and owner visual approval.
- Preserve the current Beach Cocktails Merge identity, tropical palette, legibility at small sizes, and clean silhouette. Do not add store badges, ratings, prices, promotional text, or claims.
- Derive the Google Play 512×512, 32-bit PNG (alpha allowed, <=1 MB) from the approved master and validate it after export. Produce Apple's required App Store icon through the approved Xcode asset catalog workflow from the same approved design; check current App Store Connect requirements at handoff.
- Save previews, exact dimensions, color mode, and SHA-256 next to deliverables. Keep icon and gameplay screenshots as separate asset classes.

Google Play's current published requirement for its listing icon is 512×512 32-bit PNG with alpha, maximum 1024 KB; its feature graphic is 1024×500 JPEG or 24-bit PNG without alpha. See [Google Play preview asset requirements](https://support.google.com/googleplay/android-developer/answer/9866151). Apple requires an app icon asset in the Xcode project and upload flow; see [Apple app icon guidance](https://developer.apple.com/help/app-store-connect/manage-app-information/add-an-app-icon).
