# BCM-M21 V07-R02 — Locked Remediation Criteria

Status: **LOCKED BEFORE EXECUTION**

Active tasks:
- BCM-M21-001
- BCM-M21-006

## A — frozen PASS behavior

Do not change:
- Main Menu / SETTINGS / BACK;
- result lifecycle;
- no timer;
- Pause/Resume;
- persistence;
- accepted Sunny Cove Island Map layout;
- connector-lines-off;
- progression/reward behavior.

## B — true fresh Sunny Cove art-first redesign

Create V07-R02 Sunny Cove surface from a blank 720×1280 canvas.

Forbidden as shape/placement authority:
- `table_geometry_v2.json`;
- `table_playable_surface_mask_v2.png`;
- `table_structure_mask_v2.png`;
- `table_edge_extraction_mask_v2.png`;
- `table_shadow_master_v2.png`;
- V06/V07 playable polygons or table offsets.

Old assets may be viewed as stylistic references only.

Required order:
1. design final complete static image;
2. freeze/hash image;
3. only then trace/derive new playable geometry from visible table pixels;
4. bind runtime physics to that newly derived profile.

The build/provenance must explicitly prove no old geometry/mask controlled the table shape.

## C — gameplay design requirements

The final one-piece static image must include:
- Sunny Cove scene;
- complete table;
- table frame/legs/shadow;
- approved fixed decoration.

The table must:
- provide a large clear central play area;
- keep HUD clear;
- keep progression strip below/outside active surface;
- provide a clear launch area;
- support visible 12-glass crowded state;
- expose visually obvious side/rear/front boundaries.

## D — World Map semantic regions are locked

Use the V04 owner seed positions as semantic-region anchors.

The identity of an island may NOT move to another map region.

Seed regions:
- sunny_cove [0.15,0.88]
- tiki_island [0.12,0.65]
- azure_bay [0.64,0.80]
- coconut_beach [0.28,0.52]
- sunset_island [0.50,0.52]
- party_beach [0.81,0.59]
- frozen_paradise [0.75,0.03]
- volcano_bay [0.23,0.04]
- billionaire_island [0.61,0.19]
- final_island [0.82,0.36]

Calibration may refine marker centers only within the corresponding semantic neighborhood.

Sunny Cove must remain lower-left.

Do not globally remap island names based on visual resemblance.

## E — World Map visual acceptance

For all ten islands:
- marker/ring/label/lock/click target share exact center;
- center sits on the baked island body in its locked semantic region;
- Volcano Bay ring must center on the volcanic/lava focal body;
- no runtime route lines;
- no duplicate island thumbnails.

## F — builder visual audit v2

The builder must self-audit:
- SC-01..SC-08;
- WM-01..WM-10;
- plus:
  - PROC-01: no old geometry/mask controls V07-R02 art;
  - PROC-02: art hash existed before final geometry file was generated;
  - MAP-SEM-01: all 10 island ids remain in their V04 semantic regions.

Any FAIL/UNCERTAIN blocks handoff.

## G — connector-readable review copies

For every canonical screenshot >700 KB:
- publish matching `*_REVIEW.jpg` or `*_REVIEW.png`;
- target <=500 KB;
- preserve full-frame composition;
- no annotations unless a separate debug copy is also kept.

Canonical lossless screenshots remain required.

## H — regressions

PASS:
- GUI real-click flow;
- mouse 10/10;
- touch 10/10;
- 12-glass crowded runtime;
- WIN / Next / Island Map;
- no timer;
- Pause/Resume;
- persistence;
- 0 red runtime errors;
- `git diff --check`.

## I — handoff

Create:
- `BUILDER_SELF_VISUAL_AUDIT_V07_R02.md/json`;
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V07_R02.md`;
- `CODEX_LOG_OWNER_F5_REMEDIATION_V07_R02.md`.

Finish exactly:
`AWAITING_OWNER_F5_ACCEPTANCE_V07_R02`

Do not claim release-ready.
