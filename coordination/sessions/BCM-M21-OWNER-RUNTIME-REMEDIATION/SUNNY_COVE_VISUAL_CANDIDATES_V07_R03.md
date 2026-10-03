# Sunny Cove Visual Candidates — V07-R03

Status: **READY FOR OWNER VISUAL SELECTION**
Scope: **BCM-M21-001 + BCM-M21-006; visual-candidate gate only**

These are three 720×1280 Sunny Cove compositions with one shared table architecture. Each clean surface is paired with a review composite showing the required cocktail, single tabletop deadline line, progression strip, and current production HUD art. The composites are static review images with representative values, not production runtime captures.

## Candidate files

| Candidate | Art treatment | Clean surface | Review composite | Measurements |
|---|---|---|---|---|
| A | Warm honey teak, restrained dark rim | `evidence/visual-candidates/v07-r03/sunny_cove_candidate_a_surface_720x1280.png` | `evidence/visual-candidates/v07-r03/sunny_cove_candidate_a_review_720x1280.png` | `evidence/visual-candidates/v07-r03/sunny_cove_candidate_a_measurements.json` |
| B | Lighter sun-washed teak, natural wood rim | `evidence/visual-candidates/v07-r03/sunny_cove_candidate_b_surface_720x1280.png` | `evidence/visual-candidates/v07-r03/sunny_cove_candidate_b_review_720x1280.png` | `evidence/visual-candidates/v07-r03/sunny_cove_candidate_b_measurements.json` |
| C | Honey teak with small hibiscus/plumeria corner inlays | `evidence/visual-candidates/v07-r03/sunny_cove_candidate_c_surface_720x1280.png` | `evidence/visual-candidates/v07-r03/sunny_cove_candidate_c_review_720x1280.png` | `evidence/visual-candidates/v07-r03/sunny_cove_candidate_c_measurements.json` |

## Shared visual measurements

Approximate pixel measurements read from the final 720×1280 surfaces:

| Criterion | A | B | C | Locked range |
|---|---:|---:|---:|---:|
| Rear tabletop edge y | 357 | 357 | 357 | 300–360 |
| Rear tabletop width | 495 px | 495 px | 468 px | ≥460 px |
| Player-facing tabletop edge y | 880 | 880 | 880 | 880–950 |
| Player-facing width | 700 px | 700 px | 700 px | ≥650 px |
| Clear tabletop depth | 523 px | 523 px | 523 px | ≥520 px |
| Deadline y | 752 | 752 | 752 | On tabletop, behind cocktail |
| Current cocktail center | (360, 814) | (360, 814) | (360, 814) | Near player-facing side |
| Progression panel box | x140 y1022 w440 h147 | x140 y1022 w440 h147 | x140 y1022 w440 h147 | Between legs |
| Left leg box | x0 y950 w125 h330 | x0 y950 w125 h330 | x0 y950 w125 h330 | Visible |
| Right leg box | x590 y950 w130 h330 | x590 y950 w130 h330 | x590 y950 w130 h330 | Visible |

All named upper HUD artwork is unobscured in each composite. The logo and PAUSE do not overlap. To-Go Orders, Next, Best Score, and Score remain visible. The progression strip sits below the tabletop edge in the gap between the legs and does not cover the clear gameplay surface. The only gameplay marking is the single deadline line; there is no held-cocktail box, arrow, target region, or second boundary.

## Reference and production notes

- Negative composition reference reviewed: `evidence/runtime/v07-r02/SC-01_single_flattened_surface_720x1280_REVIEW.jpg`. It informed the scale and placement corrections; its distant-table layout was not copied into the final art.
- Positive style reference for image generation: `assets/ui/panel_next.png`.
- Real production overlay assets used in the review composites: `assets/ui/logo_beach_cocktails_merge.png`, `assets/ui/panel_best_score.png`, `assets/ui/panel_score.png`, `assets/ui/panel_to_go_orders.png`, `assets/ui/panel_next.png`, `assets/ui/progression_strip.png`, and `assets/cocktails/L01.png` through `L12.png`.
- Candidate A was generated as a fresh blank-canvas scene. B and C use A as the locked composition reference and vary only tabletop material tone or small corner decoration.
- Review composites place production HUD artwork for legibility and clearance review; their static placement and sample values do not establish production runtime layout or behavior.
- No old table masks, polygons, or playable geometry controlled candidate shape. No production art, production binding, collision, level data, World Map, or gameplay behavior was changed.
- Measurements are visual estimates from the final composites/surfaces; they are builder evidence for owner review, not owner acceptance or geometry calibration.

## Handoff

The three candidates pass the locked visual envelope in the builder review and are ready for owner selection. No candidate is promoted. Production geometry and bindings remain unchanged pending the owner's selection.

Required marker: `AWAITING_OWNER_VISUAL_SELECTION_V07_R03`
