# BCM-M21 Owner F5 Remediation V07 — Locked Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Active:
- BCM-M21-001
- BCM-M21-006

## A. Fresh art requirement

Sunny Cove V07 must create:
`assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface_v07.png`

Acceptance:
- 720×1280;
- newly authored composition from blank canvas;
- no inherited V06 layer coordinates;
- no runtime table/shadow/edge/decor layers for Sunny Cove;
- provenance explicitly documents that V06 transforms are not reused as placement authority.

## B. Art-first geometry

Freeze/hash the V07 PNG before final geometry calibration.

Then derive Sunny Cove playable_geometry from that exact hash.

Required calibration:
- polygon;
- spawn_y;
- launch_y;
- death_y;
- debug overlay;
- 12-glass stress overlay.

Runtime source must use this geometry whenever the V07 surface is active.

## C. Mandatory runtime visual self-audit

Run Godot GUI through production navigation.

Capture evidence for SC-01..SC-08 and WM-01..WM-10.

Create both:
- `BUILDER_SELF_VISUAL_AUDIT_V07.md`
- `BUILDER_SELF_VISUAL_AUDIT_V07.json`

Every entry must be PASS.

FAIL/UNCERTAIN means CODEX must iterate before handoff.

## D. World Map

All ten markers must be visually rechecked against the actual runtime World Map.

Coordinates alone are insufficient.

Marker/ring/label/lock/click target share one center.

No route line.
No duplicate thumbnail.

## E. Gameplay stress

Mandatory:
- real mouse 10/10;
- real touch 10/10;
- 12 visible stress drinks;
- no visual footprint outside the visible tabletop;
- collision/bounds debug evidence;
- clean production capture without debug overlays.

## F. Preserve accepted flows

PASS required:
- Main Menu PLAY;
- SETTINGS;
- BACK;
- Island Map unchanged;
- WIN / Next Level / Island Map;
- post-result Main Menu input;
- no timer;
- Pause/Resume;
- persistence;
- zero red runtime errors;
- `git diff --check`.

## G. Handoff files

Create:
- `BUILDER_SELF_VISUAL_AUDIT_V07.md`
- `BUILDER_SELF_VISUAL_AUDIT_V07.json`
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V07.md`
- `CODEX_LOG_OWNER_F5_REMEDIATION_V07.md`

Final marker:
`AWAITING_OWNER_F5_ACCEPTANCE_V07`

No release-ready claim.
