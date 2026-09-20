# BCM-UI-ASSETS-FULL-PRODUCTION — Independent Remediation Re-Audit V01

## VERDICT

**CHANGES_REQUIRED**

The remediation materially improved the branch:
- no unknown-stem fallback remains;
- semantic-icon and island-icon uniqueness checks were added;
- table geometry/logo preservation passed;
- major visual families were regenerated;
- protected scope remained clean.

However, the branch still fails the locked remediation criteria because several asset pairs/groups that are required to represent different states are **byte-identical** in the canonical manifest. This is not a subjective visual-quality complaint; it is direct repository evidence.

## AUDITED STATE

Remediation start HEAD:
`3a04d06fe51a620d4af24fd966cb5e01668b6522`

Remediation implementation/log HEAD observed:
`58a3a332f9e1218f2c139b709117c973966b1a34`

Branch:
`ui-assets`

Main moved independently during the period because other work is active. No protected-path evidence attributes those main changes to this asset branch.

## WHAT PASSED

### R1 Preservation
PASS.
- branch isolation preserved;
- owner logo checksum preserved;
- table geometry/mask preserved;
- no live gameplay integration;
- protected runtime paths untouched.

### R2 Unknown fallback removal
PASS.
The generator now raises on unresolved final assets rather than silently generating a filename/stem badge.

### R3 Semantic icons
PASS BY SOURCE + UNIQUENESS EVIDENCE.
- 27 semantic assets are explicitly covered;
- no near-duplicate pair was reported at the locked threshold;
- dedicated renderers/dispatch exist.

### R4 Island world icons
PASS BY SOURCE + UNIQUENESS EVIDENCE.
Ten island icons are no longer simple palette/text variants and the uniqueness report contains no near-duplicate pair.

### R5 Table geometry
PASS.
The accepted shared alpha silhouette and 720×1280 geometry remain intact.

### R9/R10 Evidence and technical validation
PASS in structure.
The added contact sheets, uniqueness reports, manifest, dimensions, and validator are present.

## BLOCKING REMAINING DEFECTS

### B-01 — Empty and filled star states are identical

Manifest SHA evidence:

`campaign/island_map/star_small_empty.png`
=
`campaign/island_map/star_small_filled.png`

Both SHA-256:
`2bca1857e66aace2c29c9ad3319b6d2d1d756b23a9ab12db3eff22f272f04f7e`

The same exact file is also used for:
- `ui/rewards/star_empty.png`
- `ui/rewards/star_filled.png`
- `ui/rewards/star_large_empty.png`
- `ui/rewards/star_large_filled.png`

This violates R7.03 and the fundamental state-readability requirement.

### B-02 — Closed/open chest states are identical

Manifest SHA evidence:

`ui/rewards/small_chest_closed.png`
=
`ui/rewards/small_chest_open.png`

`ui/rewards/big_chest_closed.png`
=
`ui/rewards/big_chest_open.png`

`ui/rewards/premium_chest_closed.png`
=
`ui/rewards/premium_chest_open.png`

All use SHA:
`d08d8f1fe2538fa8bae81b05a1add8149b30ab4c4220d3c3aefd66dd0f743d20`

Milestone chest open/closed are also identical to each other.

This violates R7.03 and prevents the UI from communicating claim/open state.

### B-03 — Settings toggle ON/OFF are identical

`screens/settings/toggle_on.png`
=
`screens/settings/toggle_off.png`

Both SHA:
`bf30c4b2f3c9e2966abf0730588c0d603f5cbd62332fd057279820ade7dded57`

A settings toggle must have visually distinct ON and OFF states.

### B-04 — Island-map locked/unlocked level nodes are identical

`campaign/island_map/level_node_locked.png`
=
`campaign/island_map/level_node_unlocked.png`

Both SHA:
`bca38704ca2d91f08e04256b777f7543d228b49b4cb13754b5c7bbf6c99f7fa0`

These states must be visually distinguishable without external prose.

### B-05 — Active/inactive tab states are identical

`ui/global/tab_active.png`
=
`ui/global/tab_inactive.png`

Both SHA:
`f3f845d4abed1d102166930e6081786c9dee64ce3f16dd80189400b99442c3b8`

This violates basic state hierarchy.

## ADDITIONAL MAJOR FINDINGS

The manifest contains several very large exact-duplicate groups. Some duplication is legitimate for reusable bases, but several groups mix assets whose names imply different semantic/state functions.

Examples include:
- reward/star-track/chest state families;
- multiple badges with distinct semantic meaning;
- several island-map state assets;
- multiple fixed-result titles;
- certain shop tab states.

This means the current validator's uniqueness scope is too narrow. It validates only the selected semantic icon list and island icons, not stateful UI pairs.

## REMEDIATION CRITERIA STATUS

| Criterion | Result |
|---|---|
| R1 Preservation | PASS |
| R2 No unknown fallback | PASS |
| R3 Semantic icons | PASS |
| R4 Island icons | PASS |
| R5 Table skins/geometry | PASS for geometry; no new blocker found from source evidence |
| R6 Major screens | PARTIAL, no repository-text blocker found |
| R7 UI family quality | **FAIL** |
| R8 Effects | PARTIAL/PASS by source dispatch; no blocker established |
| R9 Evidence | PASS |
| R10 Validation | **FAIL** because state-pair duplication is not covered |
| R11 Builder log | PASS |
| R12 Overall | **FAIL** |

## FINAL VERDICT

# CHANGES_REQUIRED

Do not merge `ui-assets`.

The next remediation is narrow. Do not redo the entire asset library.

Required corrective pass:
1. create visually distinct empty/filled star assets;
2. create distinct closed/open chest assets, including small/big/premium and milestone variants;
3. create distinct toggle ON/OFF assets;
4. create distinct level-node LOCKED/UNLOCKED assets;
5. create distinct ACTIVE/INACTIVE tabs;
6. audit every named state-pair in the manifest and ensure opposite states are not byte-identical;
7. extend validation with explicit state-pair SHA/perceptual-difference assertions;
8. regenerate manifest, dimensions, relevant contact sheets, and state-difference report;
9. preserve accepted logo, table geometry, island icons, semantic icons, and protected branch scope.
