# M07 HUD regression closure — R03

The runtime HUD was unchanged. The historical probes were stale against the accepted current layout and did not track the relevant production geometry.

- `m07_hud_composition_probe.gd`: refreshed asset paths to the current `assets/ui_assets` authority, the accepted single-row L01–L12 progression order, and current launch indicator; retained visible-bound, overlap, and size assertions. Added a new independent geometry fixture `docs/evidence/m07/independent_inner_content_layout_v03.json`, leaving v02 immutable.
- `m07_r04_focused_probe.gd`: derives the score-value recess from actual score-panel dimensions and uses current To-Go geometry and held-body launch anchor. The 4 px fit bound is unchanged.
- `m07_r05_hud_adaptation_probe.gd`: replaces the retired “moved upward” and removed table-bound API expectations with accepted Best Score/Score columns, HUD clearance, fixed score behavior, and M06 danger/launch coordinates with no guide line.
- `m07_r06_owner_layout_probe.gd`: the stale recess boxes were source-panel coordinates used directly against smaller runtime panels. The initial run failed with about 9.3 px center deltas. Expected boxes now scale from source-panel coordinates using measured panel size. The original 1.5 px center tolerance and 4 px containment tolerance remain unchanged. Final center deltas are 0.000 px in all three tested viewports.

Final captured probe results:

- R04: PASS, exit 0 (`m07_r04_final_1.log`).
- R05: PASS, exit 0 (`m07_r05_current.log`).
- Composition: PASS, exit 0 (`m07_hud_composition_final_3.log`).
- R06 owner layout, normal GL renderer: PASS, exit 0 (`m07_r06_normal_final.log`).

The passing runs cover 720×1280, 720×1440, and 800×1280. Earlier failed/stale attempts are retained in the evidence logs and are superseded by these final runs.
