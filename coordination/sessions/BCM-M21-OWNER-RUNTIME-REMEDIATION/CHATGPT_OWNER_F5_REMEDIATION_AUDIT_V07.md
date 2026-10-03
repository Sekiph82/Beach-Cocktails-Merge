# BCM-M21 V07 — Independent Visual / Source Audit

Verdict: **CHANGES_REQUIRED / BUILDER_VISUAL_SELF-AUDIT_NOT_ACCEPTED**

Auditor: ChatGPT
Date: 2026-10-03
Repository: `Sekiph82/Beach-Cocktails-Merge`
Builder handoff HEAD: `8f9ce956d62ee2efb7df4b8d927319788ca672fc`

## 1. What was independently inspected

Directly opened and visually inspected:
- all ten V07 World Map runtime crops WM-01..WM-10;
- canonical per-island World Map reference assets for Sunny Cove, Tiki Island, Azure Bay, Coconut Beach, Sunset Island, Party Beach, Frozen Paradise, Volcano Bay, Billionaire Island and Final Island;
- V07 WIN runtime screenshots;
- V07 Pause runtime screenshot;
- Settings and Main Menu runtime screenshots.

Source/evidence inspected:
- `BUILDER_SELF_VISUAL_AUDIT_V07.md/json`;
- V07 gameplay surface provenance;
- V07 surface build script;
- V07 playable geometry calibration;
- V07 World Map visual review JSON;
- prior owner World Map rulings V03/V04.

Large >1 MB gameplay acceptance PNGs could not all be decoded directly through the GitHub connector. Their runtime/source/probe evidence was inspected, but this does not substitute for direct visual review. Future builder evidence must include connector-readable review copies.

## 2. Sunny Cove gameplay visual review

### SC-01 — visual presentation
**PASS visually / architecture caveat.**

The Pause and WIN runtime captures show one coherent static Sunny Cove scene behind dynamic gameplay/UI. No visible independent table-layer drift remains.

### SC-02 — central tabletop
**PASS visually.**

The visible tabletop occupies a large central trapezoidal gameplay region, leaving the HUD above and progression/supply region below.

### SC-03 — held/spawn cocktail
**PASS from accessible runtime evidence.**

The held cocktail is visible in front of the lower table/launch area rather than behind the table structure.

### SC-04 — ten launches
**TECHNICAL PASS / DIRECT LARGE-PNG VISUAL REVIEW UNAVAILABLE.**

Probe and runtime evidence report 10/10 real launches. The dedicated PNG exceeds connector binary decoding limits in this audit session.

### SC-05 — 12-glass crowded state
**TECHNICAL PASS / DIRECT LARGE-PNG VISUAL REVIEW UNAVAILABLE.**

Calibration/runtime evidence reports all 12 footprints inside the profile. The dedicated runtime PNG exceeds connector decoding limits.

### SC-06 — side/rear collision visual match
**TECHNICAL PASS / DIRECT LARGE-PNG VISUAL REVIEW UNAVAILABLE.**

The dedicated contact PNGs exceed connector decoding limits. Source/probe evidence is internally consistent but not independently image-accepted.

### SC-07 — HUD/progression clearance
**PASS visually.**

Accessible Pause/WIN captures show the HUD above the table and the 12-slot progression strip below the table plane, without covering the main playable surface.

### SC-08 — clean WIN
**PASS visually.**

The WIN card is topmost, readable and clean. No cocktail sprite is visible above it.

## 3. Critical Sunny Cove architecture failure

V07 owner ruling required:
- fresh single-surface redesign;
- final art frozen first;
- playable geometry derived from that final image;
- old V06/R11/V2 geometry not to control the new design.

The committed V07 provenance/build code does not satisfy that direction.

Evidence:
- `gameplay_surface_v07.provenance.json` states:
  `geometry_authority = assets/ui_assets/tables/table_geometry_v2.json and V2 master masks`.
- `tools/build_sunny_cove_gameplay_surface_v07.py` creates the visible table using:
  - `table_playable_surface_mask_v2.png`;
  - `table_structure_mask_v2.png`;
  - `table_edge_extraction_mask_v2.png`;
  - `table_shadow_master_v2.png`.
- `playable_geometry_calibration_v07.json` again states:
  `authority = V2/R11 playable master traced against final frozen V07 surface`.

Thus the old V2/R11 geometry/masks still determine the new table silhouette and structure. The workflow is still geometry-first in substance, even though a new scenic plate and teak material were introduced.

This violates the owner's fresh-design/art-first requirement.

## 4. World Map direct visual audit

### WM-01 Sunny Cove — FAIL

Prior owner ruling V03 explicitly requires Sunny Cove to render in the **lower-left** World Map area. V04 recorded that lower-left placement as restored.

V07 `WM-01_sunny_cove_runtime_crop.png` is sourced from crop box:
`[240,150,500,410]`.

That places Sunny Cove in the upper/upper-middle map region, not lower-left.

Therefore the builder's WM-01 PASS contradicts the owner-locked semantic map placement.

### WM-02 Tiki Island — PASS visually
Ring is centered over the statue/village island body and matches the Tiki identity reference.

### WM-03 Azure Bay — PASS visually
Ring is centered over the marina/resort body and is consistent with Azure Bay identity.

### WM-04 Coconut Beach — visually centered, semantic identity not independently proven
Ring is centered over a lagoon/islet body. However V07 globally remapped semantic island identities, so this item cannot independently close until the owner-locked regional mapping is restored.

### WM-05 Sunset Island — semantic mismatch concern
Ring is centered on a lush palm/rock body, while the canonical Sunset Island reference carries a materially different sunset/volcanic identity. V07 evidence does not prove that this baked body is the correct canonical Sunset slot.

### WM-06 Party Beach — PASS visually
Neon party venue strongly matches the Party Beach identity reference.

### WM-07 Frozen Paradise — PASS visually
Snow/ice body clearly matches Frozen Paradise.

### WM-08 Volcano Bay — FAIL / materially off-center
The crop shows the visible volcanic/lava mass toward the upper-right while the runtime ring center is pulled down/left onto the tropical lower body. The marker is not convincingly centered on the volcanic focal body.

### WM-09 Billionaire Island — semantic mismatch concern
Ring is geometrically centered on a lush island body, but the canonical Billionaire reference is the luxury villa/yacht identity. V07 evidence does not establish this body as the canonical Billionaire slot.

### WM-10 Final Island — semantic mismatch concern
Ring is geometrically centered on a bare rock formation, while the canonical Final Island reference has a waterfall/resort identity. V07 evidence does not establish the remapped semantic identity.

## 5. Root cause in World Map calibration

V04 already defined owner-approved semantic seed regions:

- Sunny Cove: [0.15, 0.88]
- Tiki Island: [0.12, 0.65]
- Azure Bay: [0.64, 0.80]
- Coconut Beach: [0.28, 0.52]
- Sunset Island: [0.50, 0.52]
- Party Beach: [0.81, 0.59]
- Frozen Paradise: [0.75, 0.03]
- Volcano Bay: [0.23, 0.04]
- Billionaire Island: [0.61, 0.19]
- Final Island: [0.82, 0.36]

Those were calibration seeds inside fixed semantic regions, not permission to globally reassign island names based on visual resemblance.

V07 treated baked bodies as freely reassignable identities. This broke the owner-approved semantic map.

## 6. Builder self-audit process failure

The builder audit recorded 18/18 PASS, but independent inspection found:
- WM-01 contradicts an explicit owner ruling;
- WM-08 is not convincingly centered on the volcanic focal body;
- several other semantic identities are unproven after global remapping;
- the fresh-art pipeline still uses V2/R11 master masks as geometry authority.

Therefore the builder self-audit did not enforce all upstream owner constraints.

## 7. Evidence accessibility improvement required

For every future runtime screenshot larger than 700 KB, CODEX must also publish a review copy:
- JPEG or PNG;
- max dimension 720×1280;
- target <=500 KB;
- same uncropped frame unless the criterion explicitly requires a crop;
- filename suffix `_REVIEW`.

This is evidence-only and must not replace the lossless canonical screenshot.

## 8. Verdict

**CHANGES_REQUIRED.**

Accepted/frozen from V07:
- menu/settings/back behavior;
- result lifecycle;
- no-timer behavior;
- current accepted Island Map layout;
- single-runtime-surface concept;
- visible gameplay composition direction;
- current UI/result cleanup.

Reopened:
- fresh Sunny Cove art-first surface generation contract;
- Sunny Cove geometry derivation after final art;
- World Map semantic identity/marker calibration;
- builder self-audit evidence accessibility and upstream-owner-rule checking.

Next actor: **CODEX**.
