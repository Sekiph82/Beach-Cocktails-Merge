# BCM-M06-R07 — Visible-Body Table Containment Audit Criteria V02

Status: **LOCKED BEFORE IMPLEMENTATION — OWNER SCREENSHOT SUPERSEDES V01**

Authority: owner runtime screenshot/annotation dated 2026-09-17 18:37 showing cocktails can still appear outside the visible tabletop and behind the rear lip. This V02 supersedes the earlier regression-only M06-R07 intent.

## Goal
Make the actual visible wooden tabletop, and only that tabletop, the playable surface. The previous R06 widening must not allow cocktail glass/container bodies to leave the table or sit visually behind the rear edge.

## PASS requirements
1. The playable region is treated as a perspective-aware **2D tabletop polygon/envelope**, not only independent left/right X rails.
2. The envelope includes independently measured rear/top, left, right and front visible tabletop boundaries from the active runtime/background render.
3. Rear/top containment is explicit. A cocktail glass/container body cannot cross the visible rear tabletop lip into the beach/background area.
4. Left/right containment is explicit. A cocktail glass/container body cannot cross the visible wooden side edges.
5. The corrected geometry must not recreate the old narrow center corridor. Valid visible wood remains usable up to the physical glass/container body boundary.
6. At least 5 independent depth samples per side remain, plus independent rear/top-boundary measurements across multiple X positions.
7. Production geometry is compared against independent render-space measurements that are not generated from the production geometry helpers.
8. Validation uses the **visible glass/container body footprint**, not garnish/full-alpha extents and not merely the collider center/radius math.
9. For representative L01, L06 and L12 placements at rear-left, rear-center, rear-right, mid-left/right and near-left/right, the visible glass/container body remains on wood while approaching the valid boundary.
10. Garnish/straw/fruit/flowers may naturally overhang where visually acceptable, but glass/container pixels must remain on the tabletop.
11. If current M05 collider/body mapping is too small to guarantee requirement 8-10, Codex must document the mismatch and make the smallest evidence-backed body/collider correction necessary. It must not silently fake containment with a large arbitrary inset.
12. Any M05 correction must preserve monotonic level footprint intent, masses unless strictly necessary, merge behavior, 700 px/s launch, 180 px/s² deceleration, momentum, scoring, economy and persistence.
13. Static walls and clamp logic must describe the same intended playable envelope. No double wall-thickness inset.
14. HUD is never part of physics bounds.
15. Current danger Y and launch Y remain unchanged unless a genuine geometry blocker is proven and explicitly logged.
16. The stale `tests/m06_environment_geometry_probe.gd` and its geometry datasets are reconciled to the new authoritative envelope rather than excluded from the suite.
17. Do not weaken meaningful old assertions. Replace obsolete two-endpoint assumptions with equivalent or stronger polygon/piecewise containment checks.
18. Evidence for 720x1280, 720x1440 and 800x1280 includes clean screenshots plus overlays showing: visible wood boundary, production boundary, visible-body contact placements and rear/top stop.
19. Evidence includes close-up rear-left, rear-center and rear-right contact views proving glass bodies do not float behind the table.
20. Full M01-M07 regression, reconciled baseline M06 probe, R06/R07 geometry probe, Godot import/startup and `git diff --check` all pass.
21. No canonical PNG, TASKS.md, ChatGPT-owned audit/prompt/criteria/policy file, historical log or M08+ work is modified by Codex.

Any material failure blocks AUDITED_PASS.
