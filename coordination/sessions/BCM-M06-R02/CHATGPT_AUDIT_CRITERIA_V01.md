# BCM-M06-R02 — ChatGPT Audit Criteria V01

`AUDITED_PASS` requires all material criteria below to pass.

## Canonical visual truth

Owner master: `/b75ee426-9568-4ed6-b35e-140600a7c995.png`

M06 audits the environment/table/playfield portion only. HUD widgets remain M07 scope.

## Required criteria

1. Actual production clean screenshots exist for canonical, taller, and shorter/wider portrait cases.
2. Actual production overlay screenshots exist for the same cases with rails/top/bottom/danger/launch geometry visible.
3. ChatGPT independently inspects the screenshot images/pixels; metadata/hashes alone are insufficient.
4. Owner master landmark evidence exists and is inspectable.
5. Canonical background landmark evidence exists and is inspectable.
6. Production composition is recognisably derived from the owner master, not merely a generic tropical table.
7. Far table is narrow, upper-middle, and leaves beach/horizon context visible around/above it.
8. Near table is broad and dominates most of the lower screen width.
9. Central playable wood area is large and proportionally close to the master intent.
10. Left/right visible rails remain coherent through far/middle/near depths.
11. Production collision rails align to independently recorded visual/reference landmarks within documented tolerances.
12. Top stop aligns to the far-table boundary, not open scenery.
13. Launch position is in the intended lower-table region and visibly on wood.
14. Danger threshold is low/near launch region while preserving most usable table area.
15. Canonical aspect adaptation is explicitly justified; 720x1280 is not accepted merely because it was historical prototype size.
16. No background/table stretching occurs.
17. Any crop is controlled and does not materially destroy table silhouette or gameplay-critical visual regions.
18. Both table rails remain materially credible in the taller portrait case; near rail cannot simply disappear off-screen and still PASS.
19. Both table rails remain materially credible in the shorter/wider case.
20. No gameplay-critical black bars are introduced.
21. Independent expected landmark/reference data is separate from the production helper under test.
22. Focused tests compare production geometry against independent expected data rather than validating a function against itself.
23. Responsive tests assert real far/middle/near widths/positions, not only center visibility.
24. L01/L06/L12 representative bodies remain inside the independently expected visual rail envelope.
25. M05 cocktail sprites remain correctly mapped/rendered.
26. Launch speed remains 700 px/s and deceleration 180 px/s².
27. Forward-only collision/wake/merge-momentum/L12-cap behavior remains intact.
28. M03 scoring/To-Go/persistence/Game Over/restart remains intact.
29. M01-M05 regressions pass after remediation.
30. Any existing regression test modified by Codex is inspected for weakened/circular assertions.
31. Godot 4.7.x import/parse and main-scene startup pass.
32. `git diff --check` is clean.
33. No M07 HUD implementation leaks into this remediation.
34. No guide line is introduced.
35. Canonical owner source PNGs are not destructively edited merely to make tests pass.
36. `TASKS.md` remains untouched by Codex.
37. ChatGPT-owned audit/criteria/prompt files remain untouched by Codex.
38. `coordination/sessions/BCM-M06-R02/CODEX_LOG_V01.md` contains exact implementation/screenshot/test/push evidence.
39. Codex does not self-audit.
40. Owner visual rejection is considered resolved only when the new clean captures materially address the rejected composition.
41. Any material visual criterion not independently inspectable remains `UNVERIFIED` and blocks `AUDITED_PASS`.

Verdict rule:

- `AUDITED_PASS`: all material criteria pass and the new production captures visibly agree with the owner-master table/environment composition.
- `CHANGES_REQUIRED`: any material mismatch, unverified visual criterion, gameplay regression, circular evidence, or governance violation.
