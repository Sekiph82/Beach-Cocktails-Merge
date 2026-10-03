# BCM-M21 V07-R03 — Locked Sunny Cove Visual Candidate Criteria

Status: **LOCKED BEFORE EXECUTION**

Active tasks:
- BCM-M21-001
- BCM-M21-006

R03 is a visual-candidate gate. It must not promote new geometry or production bindings before owner selection.

## A — preserve accepted behavior

Do not regress or redesign:
- Main Menu / SETTINGS / BACK;
- World Map V07-R02 semantic calibration;
- Island Map accepted layout;
- WIN / Next / Island Map;
- mouse/touch behavior;
- no timer;
- Pause/Resume;
- persistence;
- score/reward/progression rules.

## B — required 720×1280 composition

The table is the gameplay stage and must dominate the screen.

Hard visual envelope for every candidate:
- rear tabletop edge: approximately y=300..360;
- rear tabletop visible width: at least 460 px;
- player-facing tabletop edge: approximately y=880..950;
- player-facing visible width: at least 650 px;
- clear visible tabletop depth: at least 520 px;
- table must use strong perspective toward the player, with the near edge visually much larger than the far edge.

These values are acceptance guides, not permission to distort perspective merely to hit numbers. The visual result must look natural.

## C — tabletop sequence

From player-facing side toward the rear:
1. player-facing tabletop area with the current cocktail naturally positioned near the front portion;
2. a clear deadline line drawn ON the tabletop, slightly farther into the table than the current cocktail;
3. a large uninterrupted gameplay surface continuing beyond the deadline;
4. the rear tabletop edge.

The deadline:
- must be visibly part of the tabletop plane;
- must not sit on the front rim/apron;
- must remain readable without overwhelming the art.

Do not add any special colored/outlined/boxed/shaded/labeled region, arrows, target zone, or extra gameplay markings around the held cocktail.

## D — L1-L12 progression placement

The L1-L12 cocktail progression UI is mandatory in the composition preview.

It must:
- sit visually between the two table legs;
- read as part of the player-facing table assembly;
- remain fully visible and readable;
- not sit below both legs;
- not float as a detached lower-screen panel;
- not cover the usable tabletop.

The panel may remain a runtime UI element; it does not need to be baked into the surface art.

## E — surrounding UI clearance

The final composition must leave clean room for the existing:
- PAUSE control;
- Beach Cocktails Merge logo;
- To-Go Orders;
- Next;
- Best Score;
- Score.

The logo must remain readable and must not be hidden by PAUSE or table art.

Do not redesign these systems in R03. Candidate review composites must use the current production UI assets so the owner judges the real composition, not placeholder boxes.

## F — island art direction

Sunny Cove:
- tropical beach/ocean/palm environment;
- scenery visible behind, left, and right of the table;
- warm tropical table treatment compatible with the existing UI;
- table remains visually distinct from the scenery.

Future islands will keep the same gameplay composition while changing world identity. For example, a volcanic island may use volcanic rock/lava table treatment with volcano/lava scenery around it. R03 implements Sunny Cove only.

## G — reference discipline

Do not repeat V07-R02's reference-free text-only final-art approach.

Use the existing Beach Cocktails Merge UI/art language and the current V07-R02 screenshot as visual references:
- current screenshot is a negative composition reference for table scale/placement;
- accepted game UI/assets are positive style references.

Document all references used.

Do not use old playable geometry, masks, or polygons as shape authority.

## H — candidate gate

Create exactly three Sunny Cove candidate compositions:
- same locked gameplay architecture;
- only art-direction/detail differences;
- 720×1280 full-frame review composite for each;
- current production HUD/UI visible;
- current cocktail visible near the player-facing tabletop;
- L1-L12 progression panel visibly between the legs;
- deadline visible on the tabletop.

Also export each clean candidate surface without runtime UI.

Do not:
- update `data/campaign/islands.json`;
- replace the production Sunny Cove surface;
- derive/promote final playable geometry;
- change production collision;
- claim owner acceptance;
- continue to runtime integration.

## I — builder self-check

For each candidate, record:
- rear-edge y and width;
- near-edge y and width;
- visible tabletop depth;
- deadline y;
- current-cocktail visual center;
- progression panel bounding box;
- leg bounding boxes;
- whether all required upper UI is unobscured.

Any candidate failing a hard criterion must be discarded before handoff.

## J — handoff

Create:
- `SUNNY_COVE_VISUAL_CANDIDATES_V07_R03.md`
- machine-readable companion JSON;
- three full-frame review composites;
- three clean surface candidates;
- `CODEX_LOG_OWNER_F5_REMEDIATION_V07_R03.md`

Do not edit root `TASKS.md`.

Finish exactly:
`AWAITING_OWNER_VISUAL_SELECTION_V07_R03`
