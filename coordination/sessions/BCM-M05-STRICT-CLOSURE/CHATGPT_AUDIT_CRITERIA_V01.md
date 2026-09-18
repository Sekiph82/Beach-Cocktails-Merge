# BCM-M05-STRICT-CLOSURE — ChatGPT Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

Close the remaining M05-R02 evidence blocker without changing the owner-accepted R11 gameplay or table-edge behavior.

This is an **evidence/provenance remediation**, not a physics-retuning task.

## Frozen production baseline

Do not change:
- `scripts/drink.gd` production constants or runtime behavior;
- `COLLIDER_RADII`;
- `VISIBLE_BODY_WIDTH_PX`;
- `VISIBLE_BODY_CENTER_OFFSET_PX`;
- `BOUNDARY_CONTACT_HULL_SOURCE_PX`;
- `HELD_BODY_FOOT_SOURCE_PX`;
- R11 footprint/table-edge behavior;
- canonical cocktail PNGs;
- merge, scoring, To-Go, launch/deceleration, HUD, persistence or Game Over behavior.

If independent evidence exposes a real mismatch, report it. Do not silently retune production in this session.

## Independence requirement

The new evidence generator must derive measurements from the canonical PNG pixels themselves.

It must NOT:
- import or parse production measurement constants as targets;
- copy BODY_BOXES, center offsets, collider radii or hull values from `scripts/drink.gd`;
- choose measurement outputs in order to reproduce production values;
- use production values to crop/seed the independent measurement.

Production constants may be read only **after** independent measurements are finalized, for comparison/reporting.

## Required independent evidence

For each L01-L12 canonical cocktail PNG, produce an independent record containing at minimum:
- source file path;
- source SHA-256;
- source dimensions;
- independently detected visible glass/container body bounding box;
- independently derived body width and body center offset relative to texture center;
- transparent/garnish exclusion method;
- confidence/notes where segmentation is ambiguous.

Store the independent dataset in a new evidence file under:
`docs/evidence/m05/`

The derivation method must be reproducible and documented.

## Correct shape-diversity classification

The prior M05-R02 classifications were wrong.

The new evidence must explicitly review the actual canonical artwork and classify each level using descriptive container categories supported by the image itself.

At minimum, the review must correctly distinguish representative:
- martini/coupe-style glasses;
- highball/tall glasses;
- goblet/rounded glasses;
- coconut/container shapes;
- pineapple/special containers where present.

Do not force every level into one of these labels if another description is more accurate.

Include visual/artifact rationale, not just a label table.

## Independent comparison to production

After the independent dataset is frozen, compare it to current production values.

Report per level:
- independent body width vs `VISIBLE_BODY_WIDTH_PX`;
- independent center offset vs `VISIBLE_BODY_CENTER_OFFSET_PX`;
- current collider diameter;
- runtime visual scale;
- independently estimated runtime body width after applying current scale;
- resulting collider/body-width ratio.

Do not require exact equality. Exact equality across all 12 levels is suspicious and must be explained.

Material differences must be surfaced, not rounded away.

## Contact-fit evidence

Provide a representative runtime/evidence overlay for at least:
- one martini/coupe-style level;
- one highball/tall level;
- one goblet/rounded level;
- one coconut/special-container level;
- L12.

Overlay:
- canonical rendered sprite;
- current CircleShape2D collider;
- independently derived body bounds/center;
- body-to-collider relationship.

The overlay is evidence only. Do not alter production based on it in this session.

## Tests / checks

Add a focused M05 strict-closure probe that verifies:
1. L01-L12 texture mapping remains intact;
2. no L13 texture exists;
3. all 12 canonical source hashes match the independent evidence file;
4. the independent evidence generator does not import/read production measurement constants before producing its output;
5. all 12 independent records exist;
6. shape classifications exist with explicit rationale;
7. comparison output contains non-circular independently derived measurements;
8. production gameplay constants remain byte-for-byte unchanged from the R11 baseline for the protected symbols.

Run the active non-superseded M01-M07/R09/R11 regression suite.

## Acceptance rule

This session passes only if independent provenance is demonstrated.

A copied or target-driven dataset is a blocker even if all numerical comparisons are perfect.

No production gameplay/source retuning is allowed in this session.

Codex must not edit `TASKS.md`, ChatGPT-owned audit/criteria files, canonical PNGs, or start M08+.
