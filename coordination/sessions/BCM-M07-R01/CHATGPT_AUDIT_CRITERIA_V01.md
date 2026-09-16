# BCM-M07-R01 — ChatGPT Audit Criteria V01

`AUDITED_PASS` requires every material criterion below to pass.

Canonical visual truth:
`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

Explicit later override: no dotted/persistent guide line.

## Required PASS criteria

1. M04-R01, M05-R01 and M06-R02 remediation states are present before M07-R01 is evaluated.
2. Actual fresh production screenshots exist for 720x1280, 720x1440 and 800x1280.
3. ChatGPT can independently inspect the visual evidence package rather than relying only on hashes/builder prose.
4. Runtime composition visibly derives from the owner master and corrected M06 table/environment composition.
5. The long perspective table remains the dominant lower gameplay surface, with narrow far end and broad near end.
6. Active accumulation remains on visible wood; upper HUD does not consume the primary accumulation region.
7. Top-left canonical logo placement/hierarchy agrees with the master.
8. Canonical Best Score panel is directly below logo.
9. Canonical Score panel is directly below Best Score.
10. Best/Score displayed sizes and spacing have coherent visual rhythm.
11. Score and best values are live production text/data.
12. Canonical To-Go panel is upper-center and visually prominent without obscuring the playable top region excessively.
13. To-Go target uses shared canonical M05 mapping and follows production target state.
14. To-Go reward follows exact production reward data.
15. Exactly one To-Go presentation exists.
16. Canonical Next panel is upper-right.
17. Exactly one Next presentation exists; no legacy/bottom duplicate remains.
18. Next preview follows the true next drink before/after launch.
19. Rapid launches keep held/current/next state coherent.
20. Canonical progression strip is near bottom and fully on-screen.
21. Exactly 12 icons L01-L12 are populated in order with no L13.
22. Each progression icon fits its authored slot envelope with no material clipping/chaotic overlap.
23. Held cocktail sits naturally above/on canonical launch-zone oval in corrected table launch region.
24. Launch zone remains non-colliding and does not alter shot physics.
25. Canonical danger line replaces procedural duplicate and tracks actual death-line threshold.
26. Danger line is visually low/near launch side while preserving most usable table area.
27. Danger-line span/placement agrees with corrected visible table geometry.
28. No guide-line node/asset/persistent dotted aiming path exists.
29. No conflicting legacy prototype Score/Best/Next/target/hint UI remains visible.
30. All required HUD rectangles are fully inside each required viewport.
31. No material HUD overlap in 720x1280.
32. No material HUD overlap in 720x1440.
33. No material HUD overlap in 800x1280.
34. No black bars or stretching distort the approved composition.
35. Canonical source PNGs remain byte-for-byte unmodified.
36. M05 shared texture mapping is reused; no duplicate L01-L12 mapping table is introduced.
37. Corrected M06 geometry is used; M07 does not conceal or reintroduce rejected M06 composition assumptions.
38. Layout tests use independent expected/reference envelopes for machine-checkable geometry and are not purely production-self-consistency tests.
39. Master-vs-runtime comparison sheets/overlays are retained for all three required viewport cases.
40. Progression slot-fit evidence is retained and independently inspectable.
41. Launch speed remains 700 px/s and deceleration remains 180 px/s².
42. Immediate next, simultaneous moving drinks, wake/momentum, forward-only response, merge momentum and L12 cap remain intact.
43. M03 score/combo/To-Go/persistence/Game Over/restart contracts remain intact.
44. M01-M06 regressions are rerun after final M07 remediation.
45. Strengthened M07 focused validation passes.
46. Godot 4.7.x import/parse and configured startup pass.
47. `git diff --check` is clean.
48. No M08+ implementation leakage.
49. `TASKS.md` remains untouched by Codex.
50. ChatGPT-owned audit/re-audit/prompt/criteria/policy files remain untouched by Codex.
51. Matching `CODEX_LOG_V01.md` contains exact implementation/test/evidence/push facts.
52. Codex does not self-audit.
53. Any material visual item ChatGPT cannot independently inspect is `UNVERIFIED` and blocks `AUDITED_PASS`.

## Verdict rule

- `AUDITED_PASS`: all material criteria pass; no BLOCKER/MAJOR defect; visual evidence is independently inspectable and consistent with the owner master.
- `CHANGES_REQUIRED`: any material visual mismatch/unverified requirement, gameplay regression, wrong base geometry, weak/circular critical validation, governance violation, or other blocking defect.
