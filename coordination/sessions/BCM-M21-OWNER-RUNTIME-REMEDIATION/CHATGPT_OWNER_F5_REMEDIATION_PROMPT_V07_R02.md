# BCM-M21-001 + BCM-M21-006 — V07-R02 Fresh Art + Semantic World Map Remediation

Work in the canonical Beach Cocktails Merge checkout on `main`.

## Read first
1. AGENTS.md
2. root TASKS.md
3. OWNER_F5_RULING_V03.md
4. OWNER_F5_RULING_V04.md
5. OWNER_F5_RULING_V07.md
6. CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V07.md
7. CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R02.md

Do not edit root TASKS.md.

## 1. Preserve owner-local godot_ai integration

Keep the existing authorized owner-local:
- modified `project.godot`;
- untracked `addons/godot_ai/`;
- 14 generated translation sidecars;
- retained preservation stash.

Do not commit/stage them.

Synchronize safely using the existing V07-R01 preservation policy before product work.

## 2. Rebuild Sunny Cove surface truly art-first

The current V07 surface is not accepted as the final fresh redesign because V2/R11 masks still control its table shape.

Create a new V07-R02 surface from a blank 720×1280 canvas.

Do NOT use the following as table shape/placement masks:
- table_geometry_v2.json
- table_playable_surface_mask_v2.png
- table_structure_mask_v2.png
- table_edge_extraction_mask_v2.png
- table_shadow_master_v2.png
- prior playable polygons.

You may look at old art only as visual reference.

Design the complete static scene first:
- environment;
- table;
- frame/legs;
- shadow;
- fixed decoration.

Freeze and hash the final image.

Only after that:
- trace the visible playable table boundary;
- generate new playable_geometry;
- generate debug/stress overlays;
- wire runtime physics to that new geometry.

## 3. Restore semantic World Map identity

Do not globally remap island names.

Use the owner-approved V04 semantic seed regions as locked neighborhoods:
- Sunny Cove [0.15,0.88]
- Tiki [0.12,0.65]
- Azure [0.64,0.80]
- Coconut [0.28,0.52]
- Sunset [0.50,0.52]
- Party [0.81,0.59]
- Frozen [0.75,0.03]
- Volcano [0.23,0.04]
- Billionaire [0.61,0.19]
- Final [0.82,0.36]

Refine only locally within each region.

Sunny Cove MUST remain lower-left.
Volcano Bay MUST visibly center on the lava/volcano body.

## 4. Mandatory visual loop

Open Godot GUI and run production navigation.

Self-audit:
- SC-01..SC-08
- WM-01..WM-10
- PROC-01 / PROC-02
- MAP-SEM-01

If any item is FAIL or uncertain:
- fix;
- rerun;
- recapture;
- re-audit.

No handoff until all are PASS.

## 5. Review-copy requirement

For every screenshot >700 KB create a connector-readable `*_REVIEW.jpg`/PNG under 500 KB.

These review copies must preserve the full frame.

## 6. Preserve working behavior

Do not regress:
- PLAY / SETTINGS / BACK;
- Island Map accepted layout;
- WIN / Next / Island Map;
- post-result input;
- mouse/touch gameplay;
- no timer;
- Pause/Resume;
- persistence.

Runtime red errors = 0.

## 7. Handoff

Create:
- BUILDER_SELF_VISUAL_AUDIT_V07_R02.md
- BUILDER_SELF_VISUAL_AUDIT_V07_R02.json
- OWNER_F5_ACCEPTANCE_CHECKLIST_V07_R02.md
- CODEX_LOG_OWNER_F5_REMEDIATION_V07_R02.md

Do not edit root TASKS.md.

Finish exactly:
`AWAITING_OWNER_F5_ACCEPTANCE_V07_R02`
