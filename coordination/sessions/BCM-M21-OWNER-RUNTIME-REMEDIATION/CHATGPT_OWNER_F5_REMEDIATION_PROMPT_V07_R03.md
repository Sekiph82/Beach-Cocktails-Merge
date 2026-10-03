# BCM-M21-001 + BCM-M21-006 — V07-R03 Sunny Cove Owner Visual Candidate Remediation

Work in the canonical Beach Cocktails Merge checkout on `main`.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CODEX_LOG_OWNER_F5_REMEDIATION_V07_R02.md`
4. `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V07_R02.md`
5. `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R03.md`
6. `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V07.md`
7. V07-R02 runtime review image:
   `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v07-r02/SC-01_single_flattened_surface_720x1280_REVIEW.jpg`

Root `TASKS.md` is read-only to Codex.

## Owner ruling

V07-R02 is technically functional but visually rejected.

The table is too small and too far from the player. It reads as an object placed inside a beach scene instead of the dominant gameplay stage.

The corrected composition is simple:

- the table begins high enough to leave the existing upper UI and island scenery readable;
- it then extends strongly toward the player and fills most of the central/lower screen;
- the player-facing edge is close to the camera;
- the current cocktail is naturally visible near the player-facing portion of the tabletop;
- a deadline line is drawn ON the tabletop a short distance farther into the table;
- after that line, the table continues for a large, clear gameplay depth before ending at the rear edge;
- two table legs descend from the player-facing structure;
- the L1-L12 cocktail progression panel sits BETWEEN those two legs;
- island scenery remains visible behind and to the left/right of the table.

That is the target. Do not reinterpret it into a small centered table.

## 1. Freeze V07-R02 production behavior

Do not change production behavior or bindings in this task.

Preserve:
- V07-R02 World Map positions;
- navigation;
- Island Map;
- score;
- To-Go Orders;
- Next;
- Best Score;
- PAUSE;
- logo;
- result lifecycle;
- mouse/touch behavior;
- no timer;
- persistence;
- existing production Sunny Cove binding and collision.

Do not update `data/campaign/islands.json`.

## 2. Build exactly three 720×1280 visual candidates

Create three fresh Sunny Cove visual candidates from blank-canvas art, but use the existing Beach Cocktails Merge visual language as reference.

All three candidates MUST use the same gameplay architecture. They may differ only in tasteful Sunny Cove art treatment/details.

### Mandatory table envelope

Target:
- rear tabletop edge: y=300..360;
- rear tabletop width: >=460 px;
- player-facing tabletop edge: y=880..950;
- player-facing tabletop width: >=650 px;
- visible tabletop depth: >=520 px.

The table should feel physically close to the player and occupy most of the screen.

Do not reproduce the V07-R02 distant-table composition.

### Mandatory tabletop arrangement

The current cocktail must appear naturally near the player-facing portion of the tabletop in the review composite.

A single deadline line must appear on the tabletop a short distance farther into the table than the current cocktail.

The deadline must NOT be on the front rim/apron.

Beyond the deadline there must be a long, clean, unobstructed table surface suitable for many cocktails.

Do not add any special colored, outlined, boxed, shaded, labeled, or arrow-marked region around the held cocktail. Do not add target markings or any second gameplay boundary.

### Mandatory table front / progression relationship

The table has two visible legs.

The existing L1-L12 cocktail progression panel must be composited BETWEEN those legs.

It must not:
- sit below the legs;
- float detached at the bottom of the screen;
- cover the tabletop.

Treat it visually as part of the table's player-facing assembly while keeping it as a UI element for preview purposes.

## 3. Keep the real upper UI in the candidate review

Every full-frame candidate review must use the existing production UI assets and show the actual required composition:

- PAUSE;
- Beach Cocktails Merge logo;
- To-Go Orders;
- Next;
- Best Score;
- Score.

Do not substitute generic placeholder rectangles.

The logo must be fully readable and not hidden by PAUSE.

The table must leave enough room for all of these while still being much larger than V07-R02.

## 4. Sunny Cove environment

Use:
- tropical beach;
- ocean;
- palms/tropical vegetation;
- Sunny Cove atmosphere.

Scenery should remain visible behind and on both sides of the table.

The table may use tropical wood/material treatment that belongs to Sunny Cove, but the surface must remain clean enough for gameplay readability.

This composition will later become the template for other island identities. Do not implement other islands now.

## 5. References are required

V07-R02 declared `reference_images_used: []`. Do not repeat that.

Use:
- V07-R02 screenshot as a NEGATIVE composition reference;
- existing Beach Cocktails Merge HUD/art assets as POSITIVE style references;
- any accepted Sunny Cove/Island art already in the repository as style reference where useful.

Record all reference paths used.

Old geometry/masks/polygons may be inspected for history but must not control candidate shape.

## 6. No production geometry yet

This is an owner visual candidate gate.

Do NOT:
- generate/promote final collision geometry;
- bind any candidate into production gameplay;
- edit production table physics;
- change level data;
- change World Map;
- change root `TASKS.md`;
- claim that one candidate is accepted.

You may create non-production measurement overlays solely to verify candidate dimensions. Keep them separate from clean art/review images.

## 7. Required candidate evidence

For A, B, and C produce:

1. clean Sunny Cove surface candidate;
2. 720×1280 full-frame review composite using production UI;
3. measurement JSON containing:
   - rear tabletop edge y;
   - rear tabletop width;
   - player-facing tabletop edge y;
   - player-facing tabletop width;
   - visible tabletop depth;
   - deadline y;
   - current cocktail center;
   - L1-L12 panel bounding box;
   - left/right leg bounding boxes;
   - logo/PAUSE/To-Go/Next/Best Score/Score clearance result.

Reject and regenerate any candidate that misses the locked criteria.

## 8. Handoff

Create:
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/SUNNY_COVE_VISUAL_CANDIDATES_V07_R03.md`
- matching JSON companion;
- review/composite assets under `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/visual-candidates/v07-r03/`
- `docs/codex-logs/CODEX_LOG_OWNER_F5_REMEDIATION_V07_R03.md`

Do not edit root `TASKS.md`.

Do not continue into geometry/runtime integration.

Finish exactly:

`AWAITING_OWNER_VISUAL_SELECTION_V07_R03`
