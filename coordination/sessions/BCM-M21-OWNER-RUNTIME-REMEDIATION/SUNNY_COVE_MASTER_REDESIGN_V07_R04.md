# Sunny Cove Master Redesign — V07-R04

**Tasks:** BCM-M21-001 + BCM-M21-006
**Gate:** static visual remediation only
**Status:** awaiting owner visual acceptance; no production promotion

## Owner direction applied

V07-R03 candidates A, B, and C remain rejected. This package contains one new close player-facing Sunny Cove composition. The current Beach Cocktails Merge logo, To-Go Orders, Best Score, Score, and Next are preserved with the current project PNG assets and the measured V07-R03 placement bounds. The owner master controls the rest of the composition: deep close tabletop, strong perspective, raised rails, front edge near the player, and a full-width progression row attached immediately below it. No table legs are shown.

The image is a static review composite. The current score/order values and cocktail placements are illustrative and do not represent a runtime capture.

## Composition measurements

Approximate visual measurements on the 720×1280 surface:

| Element | Measurement |
|---|---:|
| Rear tabletop edge | y=405; width≈424 px |
| Player-facing table edge | y≈1009; width≈720 px |
| Visible tabletop depth | ≈604 px |
| Single horizontal deadline | y=854 |
| Held L01 center | (360, 938), player-forward of deadline |
| Integrated L01-L12 progression strip | x=8, y=1018, w=704, h=168 px |
| Visible table legs | none |

The twelve current cocktail assets appear in one horizontal progression row. The review composite also includes a representative crowded tabletop using current L01-L12 assets. No vertical dotted guide, arrow path, target ray, launch zone, or substitute aiming cue is present.

## Frozen HUD bounds

The five frozen elements use current project art and preserve the R03 measured bounds:

| Element | Bounding box (x, y, w, h) |
|---|---:|
| Logo | (137, 6, 135, 90) |
| To-Go Orders | (277, 0, 170, 210) |
| Best Score | (14, 166, 190, 107) |
| Score | (518, 198, 190, 107) |
| Next | (564, 6, 140, 181) |

The Pause button appearance is retained in the review frame. No pause behavior or production HUD layout was changed.

## Files

- Clean surface: `evidence/visual-candidates/v07-r04/sunny_cove_master_surface_v07_r04_720x1280.png`
- Review composite: `evidence/visual-candidates/v07-r04/sunny_cove_master_review_v07_r04_720x1280.png`
- Evidence measurements: `evidence/visual-candidates/v07-r04/sunny_cove_master_measurements_v07_r04.json`
- Matching measurement JSON: `SUNNY_COVE_MASTER_REDESIGN_V07_R04.json`
- Source artwork and reproducible compositor: `evidence/visual-candidates/v07-r04/`
- Execution log: `docs/codex-logs/CODEX_LOG_OWNER_F5_REMEDIATION_V07_R04.md`

The clean surface contains only the Sunny Cove environment and close wooden board. HUD, representative cocktails, the deadline, and progression assembly are separate review-only overlays. The JSON records file digests and element bounds.

## Scope and handoff

No production collision/playable geometry, gameplay logic, score/order/campaign behavior, World Map/Island Map, persistence, or production surface binding was changed. Root `TASKS.md` remains byte-for-byte unchanged. Owner visual acceptance and any later production integration/runtime checks remain pending.

`AWAITING_OWNER_VISUAL_ACCEPTANCE_V07_R04`
