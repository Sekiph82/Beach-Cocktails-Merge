# BCM-M21 Owner F5 Remediation V04 — Locked Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Active task IDs:
- BCM-M21-001
- BCM-M21-004
- BCM-M21-006

Authority:
- `OWNER_F5_RULING_V04.md`
- `OWNER_F5_AUDIT_V04.md`
- owner F5 screenshots dated 2026-10-02;
- no-timer owner ruling;
- accepted current physics except the explicitly authorized pure +150 px Y translation.

## A — governance
- Work on synchronized `main`.
- CODEX must not edit root `TASKS.md`.
- Preserve all current PASS behavior.
- Do not reintroduce timers, +Time, yellow World Map route lines, or decor_left/right/back.
- Do not invent economy/content changes.

## B — World Map calibration
- Update canonical island marker centers to actual baked island visuals.
- Use V04 seed coordinates from owner ruling and refine only as needed.
- Final center table must contain all 10 ids.
- Marker ring, lock state, name/state and click target use one shared center.
- Duplicate island thumbnail stays hidden.
- No runtime route Line2D.
- 720×1280 capture required.
- Visual centroid error target: <= 20 canonical pixels from the themed island-body target chosen in calibration evidence.

## C — Sunny Cove 10-slot landmark pages
Add data-driven island-map layout metadata for Sunny Cove:
- page_size = 10;
- connector_lines = false;
- owner landmark centers from V04 ruling;
- 10 pages for 100 levels.

Controller requirements:
- no deterministic zigzag for Sunny Cove;
- no visible `DeterministicLevelPath`;
- one repeated Sunny Cove map-background page per 10-level block;
- L1-L10, L11-L20, ... L91-L100 map to slots 1..10;
- focus opens the page containing current/selected level;
- vertical navigation still reaches all 100 levels;
- completed/current/open/locked/VIP/milestone semantics remain intact.

Capture page 1 and a later page (at least L51-L60) to prove repeatability.

## D — table +150 px rigid translation
Implement a data-driven Sunny Cove table Y offset = +150 px.

Apply the exact same offset to:
- table shadow;
- table;
- edge overlay;
- logical launch indicator;
- table top/rear/bottom geometry;
- launch Y;
- death Y;
- all R11 boundary points/queries/projection inputs.

Do not apply it to:
- background;
- HUD;
- result UI;
- supply selector UI.

Regression proof:
- after subtracting 150 px from translated geometry, R11 source/shape values match pre-V04 geometry;
- rail widths/slopes unchanged;
- M02 merge/collision still PASS;
- real mouse/touch launch still PASS.

## E — launch-zone/decor cleanup
- `launch_zone.png` is no longer rendered as a full-screen art layer.
- Logical launch behavior remains.
- Optional simple programmatic launch line is allowed.
- decor_left/right/back remain absent.
- Create a runtime visible-layer inventory and isolation report.
- If another layer contains owner-rejected foreground decoration, identify it by path.
- If cleanup requires a derivative PNG, preserve original and record source SHA-256 → derivative SHA-256 plus exact masked region/process.
- no wooden-table pixels may be removed.

## F — result lifecycle hard gate
Fix result presentation architecture.

Required:
1. Result CanvasLayer must not be added to SceneTree root synchronously while root is setting up children.
2. Prefer ownership under CampaignNavigationController or a predeclared scene child; otherwise use a fully deferred ready-safe creation path.
3. Result payload received before overlay readiness must be retained and presented after readiness.
4. `CampaignFeedbackOverlay` must defensively guarantee shell controls exist before assigning text.
5. Result card appears exactly once.
6. WIN: Next Level when available + Island Map.
7. LOSE: Retry + Island Map.
8. terminal gameplay world remains frozen/hidden.
9. no post-terminal progression/score/delivery mutation.
10. no duplicate result overlays or leaked CanvasLayers after repeated wins/retries.

Mandatory real production-path probe:
- start a level;
- complete required To-Go objective through gameplay/session API path;
- observe terminal WIN;
- wait until result card is visible;
- trigger Next Level;
- complete another level;
- trigger Island Map;
- run a LOSE fixture and Retry;
- capture debugger error stream.

Acceptance:
- result cards/actions all work;
- **0 red Godot runtime errors**;
- specifically zero occurrences of:
  - `Parent node is busy setting up children`;
  - `Invalid assignment ... on Nil`.

## G — regression
Run:
- real mouse 10/10 + touch 10/10;
- no timer / one-hour survival;
- M02;
- translated R11 invariance;
- M03;
- M07-R06;
- M08/M09;
- untimed M14/M15/M16;
- M18;
- M19;
- M20;
- M21 progression 100/100;
- save/restart;
- `git diff --check`.

Historical superseded R10 probes remain non-gates.

## H — owner evidence
Generate 720×1280 captures:
1. World Map with all ten markers on actual island visuals.
2. Sunny Cove Island Map L1-L10 landmark layout with no lines.
3. Sunny Cove Island Map later page.
4. Gameplay with table shifted down.
5. Layer-isolation/clean gameplay proof.
6. WIN result visible and clean.
7. LOSE result visible and clean.

Create:
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V04.md`
- `CODEX_LOG_OWNER_F5_REMEDIATION_V04.md`

Technical success marker:
`AWAITING_OWNER_F5_ACCEPTANCE_V04`

Do not claim release-ready.
