# BCM-M21 Owner F5 Remediation V06 — Locked Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Active task IDs:
- BCM-M21-001
- BCM-M21-006

BCM-M21-004 remains closed unless V06 introduces a new gameplay regression.

Authority:
- `OWNER_F5_RULING_V06.md`
- owner screenshots dated 2026-10-02;
- V05 technical PASS.

## A — Sunny Cove composite migration

Required production file:
`assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface.png`

Required:
- 720×1280;
- deterministic composition from existing Sunny Cove source assets;
- committed build/provenance report;
- only one static gameplay visual node for Sunny Cove;
- legacy table/shadow/edge/launch/decor presentation nodes absent in Sunny Cove production runtime.

## B — playable geometry

Sunny Cove island data must add a `playable_geometry` profile.

Minimum:
- playable_polygon;
- launch_y;
- spawn_y;
- death_y.

Runtime GameManager must derive:
- physical walls/rails;
- horizontal bounds;
- projection/clamping;
- spawn placement;
- launch/death lines

from the active island geometry profile.

No `table_y_offset_canonical` may affect Sunny Cove production physics or presentation.

Legacy geometry may remain fallback for non-migrated islands only.

## C — geometry/image alignment

Mandatory production evidence:
1. clean Sunny Cove gameplay surface;
2. geometry-debug overlay on the same 720×1280 surface;
3. 12-glass stress overlay;
4. actual runtime 12-glass/crowded capture.

Acceptance:
- every stress glass visual footprint remains visibly on the table;
- no glass is hidden behind/below table art;
- polygon edges visually follow the playable table boundary;
- no visual/physics offset drift.

## D — World Map marker calibration

Create a deterministic marker calibration artifact using:
- canonical world map background;
- per-island map assets and/or image-feature/template matching;
- manual refinement only when documented.

For all 10 islands record:
- final canonical pixel center;
- normalized center;
- matching/calibration method;
- confidence/residual.

Acceptance:
- marker visual centroid error <= 15 canonical px against the selected island-body anchor;
- marker/name/lock/click target use one shared center;
- no duplicate island thumbnail;
- no runtime route line.

Generate 720×1280 World Map capture with all markers visible.

## E — preserve accepted Island Map

Do not change Sunny Cove Island Map node positions/pagination in V06.

Connector lines remain absent.

## F — preserve V05 behavior

Re-run:
- real Main Menu PLAY / SETTINGS / BACK via viewport mouse input;
- post-result Main Menu input;
- result WIN / Next Level / Island Map;
- real gameplay mouse 10/10;
- real gameplay touch 10/10;
- no timer / one-hour survival;
- pause/resume;
- settings/save persistence;
- zero red Godot runtime errors;
- `git diff --check`.

## G — owner evidence

Generate:
- World Map final capture;
- Sunny Cove clean composite gameplay capture;
- Sunny Cove geometry overlay evidence;
- crowded/12-glass runtime capture;
- WIN result capture.

Create:
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V06.md`
- `CODEX_LOG_OWNER_F5_REMEDIATION_V06.md`

Technical marker:
`AWAITING_OWNER_F5_ACCEPTANCE_V06`

Do not claim release-ready.
