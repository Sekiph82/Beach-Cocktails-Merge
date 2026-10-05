# BCM-M21-001 — World Map 720×1280 Layout Closure Independent Audit V01

Date: 2026-10-05  
Auditor: ChatGPT  
Builder handoff: `7016a9852ab61e23702cda2cd170e7b5bca4dc62`  
Implementation commit: `a0304d3`  
Log publication commit: `7016a98`

## 1. Verdict

**AUDITED_PASS / BCM-M21-001 COMPLETE / OWNER_F5_ACCEPTANCE_REQUIRED**

The World Map 720×1280 regression is technically closed.

No further Codex remediation is required for BCM-M21-001 unless the owner F5 run identifies a visible/runtime defect.

## 2. Scope and authority preservation

Independent compare from tracker handoff `70f9230...` to builder handoff `7016a98...` shows exactly two commits.

Product-source changes are limited to:
- `scripts/campaign/world_map_controller.gd`;
- `tests/m12_world_map_probe.gd`.

The remaining changes are required evidence/log files.

Confirmed unchanged:
- `data/campaign/islands.json` blob is identical before/after;
- all ten canonical semantic `map_position` values are unchanged;
- `assets/ui_assets/ASSET_MANIFEST.json` is unchanged;
- no owner-approved R04 `gameplay_surface_v07_r04.png`, `gameplay_surface.png`, `playable_geometry_r04.json`, or protected island map/completion asset changed;
- root `TASKS.md` was not modified by Codex.

## 3. Pre-fix diagnosis

The committed pre-fix evidence reproduces the old M12 failure.

The cleanup causality finding remains correct:
- `world_map_controller.gd` at the cleanup baseline and pre-task handoff was the same Git blob;
- the cleanup did not create this layout regression;
- canonical map positions predate this task.

Renderer evidence and the diagnostic report identify two real presentation defects:
1. Frozen Paradise and Volcano Bay marker/ring presentation crossed behind the old 138 px header band.
2. MapBoat expanded to its texture/native presentation size and covered Sunny Cove content.

Therefore this was not closed by merely weakening or renaming the old assertion.

## 4. Implementation review

The controller remediation is bounded and consistent with the locked criteria:

- header height: 138 → 76;
- Back button, title panel, eyebrow/title text, and compass moved into that 76 px safe band;
- title panel and compass authored sizes are reapplied after parenting so TextureRect minimum-size behavior cannot silently expand them;
- MapBoat intended size is reapplied after parenting;
- MapBoat moves from x=38 to x=205 and z-index 5 → 1, placing it in open water behind marker presentation;
- semantic island centers remain untouched;
- report semantics now split horizontal vs vertical clipping and explicitly measure header/status/selection overlap and header-control containment.

No blanket coordinate retuning, campaign logic change, hitbox weakening, or hard-coded PASS was found.

## 5. Independent layout-report verification

For all three canonical states in committed post-fix evidence:
- `canonical_fresh`;
- `canonical_locked`;
- `canonical_selected_current`;

the report states:
- `horizontal_clipping=false`;
- `vertical_clipping=false`;
- `overlap=false`;
- `header_overlap=false`;
- `status_overlap=false`;
- `selection_boundary_overlap=false`;
- `navigation_overlap=false`;
- `header_controls_fit=true`;
- `entries_fit_width=true`;
- `duplicate_nodes=false`;
- 10 entries / 10 visual markers.

The two-island fixture has the same clean status.

The geometry also has real positive clearance:
- header ends at y=76;
- Frozen Paradise selection ring starts at y≈80.81;
- Volcano Bay selection ring starts at y≈90.43.

Sunny Cove's selection ring ends at x=192 while the fixed MapBoat begins at x=205, with the boat also drawn behind markers.

## 6. M12 regression

Two consecutive post-fix M12 runs are committed.

Both:
- exit 0;
- report every functional/layout assertion PASS;
- end with `M12_WORLD_MAP_RESULT=PASS`.

No source change is reported between the two runs.

The probe still verifies:
- two-island fixture;
- ten-island canonical map;
- fresh state;
- locked rejection;
- one navigation boundary per selection;
- duplicate-node absence;
- COMPLETE/OPEN/CURRENT state transitions;
- save round-trip.

## 7. Required regression matrix

Committed evidence reports PASS / exit 0 for:
- clean Godot import/parse/boot;
- M10 campaign architecture;
- M11 save/migration/progression;
- M13 Island Map;
- M14 gameplay session bridge;
- M20 app-shell/navigation;
- R04 surface/profile authority — 10 islands / 71 checks;
- asset validator — 356/356 checksums, 10/10 R04 families, invalid semantic duplicates 0;
- git diff check.

No regression blocker is present in the required set.

## 8. GUI / Godot AI evidence

The evidence package contains renderer-capable 720×1280 pre/post PNG captures for:
- full fresh map;
- top area;
- bottom area;
- locked selection;
- selected/current state.

The renderer diagnostic ran under OpenGL Compatibility on Intel Iris Xe at 720×1280 and exited 0.

Builder records a live Godot AI runtime inspection with a non-stale framebuffer and matching live UI rectangles.

### Independent visual-audit boundary

The connected GitHub repository interface exposes these PNGs as binary repository files but does not render their pixel content to this auditor. Therefore this audit independently verifies:
- file existence/commit scope;
- renderer provenance;
- exact geometric layout reports;
- source implementation;
- functional regressions;

but does **not** substitute for the owner's final visual F5 acceptance of the changed header/boat presentation.

That owner visual/runtime gate remains intentionally open under BCM-M21-006.

## 9. Defects

### Blocker
None.

### Major
None for BCM-M21-001.

### Minor
None requiring remediation.

### Owner gate
Final subjective World Map appearance plus end-to-end F5 runtime acceptance remains required before M21 release closure.

## 10. Final disposition

**BCM-M21-001 = AUDITED_PASS / COMPLETE.**

BCM-M21-006 remains open for final owner F5 acceptance and v1 campaign release closure.

Next actor: **OWNER**.

Use:
`coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_ACCEPTANCE_CHECKLIST_V03.md`

If every V03 item passes, ChatGPT may record final M21 release closure and unlock the planned M22 presentation program.

If any item fails, report the failing checklist number(s) and evidence; M21 remains open.
