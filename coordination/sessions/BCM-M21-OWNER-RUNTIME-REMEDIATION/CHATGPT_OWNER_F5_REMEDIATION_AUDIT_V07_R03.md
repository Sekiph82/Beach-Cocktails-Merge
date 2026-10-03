# BCM-M21 V07-R03 — Independent Sunny Cove Candidate Audit

Date: 2026-10-03  
Scope: BCM-M21-001 + BCM-M21-006, V07-R03 visual-candidate gate only  
Audited product commit: `743eb18773f33bee763539b2da59e7b130386812`  
Audited handoff HEAD: `4c943b2e7ed856163d4cd824b0591fe75c39654b`  
Verdict: **AUDITED_PASS / OWNER_VISUAL_SELECTION_REQUIRED**

## Audit boundary

This audit accepts only the V07-R03 candidate gate. It does **not** accept production geometry, production binding, gameplay/runtime calibration, SC-01..SC-08 runtime behavior, World Map runtime acceptance, or final M21 release closure.

The V07-R03 prompt explicitly forbids promotion before owner selection, so static candidate composites are valid evidence for this gate. After the owner selects one candidate, the selected art must still be frozen, integrated into production, have playable geometry derived from the final art, and pass the real Godot GUI/runtime visual loop required by the owner V07 ruling.

## Source and publication verification

- Start-to-product compare `4aa0d45...743eb187` contains exactly the candidate package: the Markdown/JSON manifest, three measurement JSON files, three clean surfaces, and three review composites. No production gameplay/art binding, campaign data, World Map, collision, or root TASKS path is changed by the product commit.
- Product-to-handoff compare `743eb187...4c943b2` adds only `docs/codex-logs/CODEX_LOG_OWNER_F5_REMEDIATION_V07_R03.md`.
- The handoff therefore preserves the candidate-only scope.
- The repository later received tracker/planning commits; this audit remains pinned to the immutable V07-R03 product/handoff SHAs above.

## Direct visual inspection of every generated PNG

All six GitHub-hosted PNGs were opened individually and inspected visually, not merely inferred from JSON measurements.

| File | Visual result | Independent visual observation |
|---|---|---|
| `sunny_cove_candidate_a_surface_720x1280.png` | **PASS** | Fresh Sunny Cove beach composition. The table clearly dominates the central/lower screen, rear edge remains high enough for scenery, near edge is strongly enlarged, two front legs are fully visible, and the central tabletop is unobstructed. No baked launch box, target region, arrow, second boundary, or other gameplay marking is present. |
| `sunny_cove_candidate_a_review_720x1280.png` | **PASS** | Production PAUSE/logo/To-Go/Next/Best Score/Score art is readable and non-overlapping. Current cocktail is near the player-facing tabletop, the single deadline lies farther into the tabletop, a long clean play surface remains beyond it, and the L1-L12 strip is fully visible between the two legs. |
| `sunny_cove_candidate_b_surface_720x1280.png` | **PASS** | Same accepted architecture with a lighter sun-washed tabletop. Perspective and table dominance remain clear; scenery survives around the table; the playfield remains clean and leg separation is readable. |
| `sunny_cove_candidate_b_review_720x1280.png` | **PASS** | Required UI and cocktail/deadline/progression sequence remains visually correct. The lighter tabletop reduces contrast slightly relative to A for very pale objects, but the shown production cocktail and boundary remain legible and this is not a gate failure. |
| `sunny_cove_candidate_c_surface_720x1280.png` | **PASS** | Same close-table architecture with small floral inlays at the far left/right tabletop corners. The decorations do not occupy the central play corridor or create a second gameplay region; the rear-central surface remains open. |
| `sunny_cove_candidate_c_review_720x1280.png` | **PASS** | Required production UI remains clear. Cocktail, single tabletop deadline, long post-deadline surface, two legs, and between-leg progression strip remain readable. The floral corner treatment is a stylistic owner choice, not a compliance blocker. |

### Visual criterion cross-check

- **Table dominance / scale:** PASS on A/B/C. None repeats the rejected distant-table composition.
- **Natural perspective:** PASS. Near edge is visually much wider than rear edge and the table advances toward the player.
- **Current cocktail placement:** PASS. It sits in front of the deadline and close to the near edge rather than behind table/UI art.
- **Deadline sequence:** PASS. One line only, visibly on the tabletop, farther into the table than the cocktail, with substantial clean gameplay depth continuing toward the rear.
- **No extra gameplay markings:** PASS. No launch-zone box, colored region, target outline, arrow, label, or second boundary was observed.
- **Progression strip relationship:** PASS. The strip is centered between the visible table legs, does not cover the tabletop, remains readable, and visually uses the same tropical wood/floral language rather than appearing as an unrelated bottom HUD card.
- **Upper UI clearance:** PASS. PAUSE, logo, To-Go Orders, Next, Best Score, and Score are all visible; PAUSE does not cover the logo.
- **Sunny Cove identity:** PASS. Tropical beach, ocean, palms/vegetation, and side scenery remain visible in all candidates.
- **Gameplay surface cleanliness:** PASS for the candidate gate. A/B are completely clear; C adds only small far-corner floral decoration outside the central corridor.
- **Owner choice preserved:** PASS. The three candidates use one architecture and differ only in material/decor treatment. No candidate is independently promoted or declared owner-selected.

## Measurement/evidence consistency

The manifest and per-candidate JSON report:
- rear tabletop edge y = 357 on all candidates;
- rear width = 495 / 495 / 468 px;
- near edge y = 880;
- near width = 700 px;
- visible tabletop depth = 523 px;
- deadline y = 752;
- cocktail center = (360, 814);
- progression strip = x140 y1022 w440 h147.

Those values are internally consistent with the direct visual inspection and satisfy the locked R03 envelope. They remain builder measurements, not collision calibration.

## Independent verdict

**AUDITED_PASS / OWNER_VISUAL_SELECTION_REQUIRED**

V07-R03 successfully clears the independent candidate-quality gate, including direct visual inspection of all six generated GitHub images.

No candidate may be promoted automatically. The owner must explicitly select **A, B, or C**. Production geometry/binding and the real runtime SC/WM acceptance loop remain blocked until that selection.

Required next actor: **OWNER**  
Required next action: select one V07-R03 candidate; then prepare a bounded production-integration/runtime-validation task for only the selected art.

Marker: `AWAITING_OWNER_VISUAL_SELECTION_V07_R03`
