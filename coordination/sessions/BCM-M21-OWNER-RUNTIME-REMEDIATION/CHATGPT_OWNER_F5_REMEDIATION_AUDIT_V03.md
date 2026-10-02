# BCM-M21 Owner F5 Remediation V03 — Independent Audit

Verdict: **TECHNICAL_AUDITED_PASS / OWNER_F5_ACCEPTANCE_REQUIRED**

Auditor: ChatGPT  
Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`  
Audited HEAD: `a7339ab1d05dfb5034ee90d55a5b79439fe8b7d4`

## Scope

Active tasks:
- BCM-M21-001
- BCM-M21-004
- BCM-M21-006

Authority:
- `OWNER_F5_RULING_V03.md`
- `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V03.md`
- current source, reports, captures, builder log and repository history.

## V03 owner-visible corrections

### Debug window — PASS
- canonical viewport remains 720×1280;
- desktop override is 800×1422.

### World Map — PASS technically
- runtime yellow `IslandRoute` line is removed;
- data-driven `islands.json.map_position` is authoritative;
- Sunny Cove resolves from [0.16, 0.83] to lower-left;
- duplicate island art remains hidden;
- machine-readable center report contains all ten islands.

Final visual owner acceptance remains required.

### Sunny Cove Island Map — PASS technically
- `IslandMapController` now resolves and renders `island_theme.island_map_background`;
- Sunny Cove resolves to its canonical `sunny_cove/map_background.png`;
- flat color is fallback behavior.

### Sunny Cove gameplay composition — PASS
Runtime texture inventory proves the visible campaign theme uses:
- gameplay_background;
- gameplay_table_shadow;
- gameplay_table;
- table_edge_overlay;
- launch_zone.

No `decor_left.png`, `decor_right.png`, or `decor_back.png` is present in the visible runtime inventory.

The actual prior occluder was the full-viewport LaunchZone sprite at z=-5 above the wooden table at z=-10. V03 moves LaunchZone to z=-15, leaving the wooden table unobscured.

### WIN/LOSE terminal cleanup — PASS
Machine-readable terminal report confirms:
- visible Drink count = 0;
- visible transient world effect count = 0;
- result overlay visible;
- result CanvasLayer = 2, above gameplay HUD layer 1.

Source changes also block post-terminal score/session mutations and stop gameplay input.

## Input / no-timer preservation — PASS
V03 runtime probe reports:
- mouse shots 10/10;
- touch shots 10/10;
- direct launch-method calls 0;
- no timer / one-hour survival remains intact.

## Regression classification

### Current locked regressions — PASS
Builder evidence reports PASS for:
- M02 physics/merge;
- M03;
- M07-R06;
- M08;
- M09;
- untimed M14;
- M15;
- M16;
- M18 suites;
- M19;
- M20;
- M21 progression 100/100;
- persistence;
- import;
- `git diff --check`.

### R10 V08 parse failure — NON-BLOCKING HISTORICAL PROBE
`tests/r10_v08_exact_edge_contact_probe.gd` references the removed `Drink.TABLE_EDGE_CONTACT_HALF_WIDTHS` API from the retired R10 contact model.

It is not a current acceptance gate and must not be repaired to manufacture a pass.

### R10 V10 crowd/rear failures — NON-BLOCKING HISTORICAL MODEL
The accepted R11 audit explicitly states that R10 V09/V10 full-visual-hull containment probes are superseded and are expected to fail under the R11 table-plane footprint model.

Independent V03 source comparison confirms the following R11 acceptance-critical blocks are byte/text identical between pre-V03 base `33681340...` and audited V03 HEAD:
- `TABLE_LEFT_EDGE_SOURCE_POINTS`;
- `TABLE_RIGHT_EDGE_SOURCE_POINTS`;
- `REAR_EDGE_MARGIN`;
- `get_table_rail_bounds_at_y()`;
- `_make_boundary_edge()`;
- `project_footprint_inside_table()`;
- `Drink.get_table_footprint_local()`;
- `Drink.set_settled()`;
- `Drink._integrate_forces()`.

Therefore V03 did not regress or retune R11 geometry.

## Final verdict

**TECHNICAL_AUDITED_PASS.**

No further Codex remediation is authorized at this point.

Remaining gate:
- owner manually runs `OWNER_F5_ACCEPTANCE_CHECKLIST_V03.md`;
- all owner-visible corrections and quick regressions must PASS.

BCM-M21-004 may return to technical PASS.
BCM-M21-001 and BCM-M21-006 remain pending explicit owner F5 acceptance.

No release-ready claim is permitted until owner V03 acceptance is recorded.
