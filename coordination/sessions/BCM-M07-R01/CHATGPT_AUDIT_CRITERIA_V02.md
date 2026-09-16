# BCM-M07-R01 — ChatGPT Audit Criteria V02

`AUDITED_PASS` requires every material criterion below to pass. This V02 supersedes V01 where they conflict.

Canonical owner visual truth:
`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

Explicit later owner directions:
- no persistent/dotted guide line;
- preserve the improved M07 tropical composition as the starting point;
- move Best Score + Score higher;
- give To-Go + NEXT more usable vertical presentation downward;
- correct all live content placement inside UI frames;
- make gameplay cocktails somewhat larger;
- move danger line lower;
- center the held drink properly over a halo beneath it;
- replace the single-row progression with a 2x6 layout: top L07-L12, bottom L01-L06.

## Required PASS criteria

1. M04-R01, M05-R01 and M06-R02 remediation states are present before M07-R01 V02 is evaluated.
2. Fresh actual production screenshots exist for 720x1280, 720x1440 and 800x1280.
3. Clean screenshots are independently inspectable by ChatGPT.
4. The remediated screen remains visibly closer to the owner master than the old M06 prototype-style evidence and preserves M07's successful tropical HUD direction.
5. Long perspective wooden table remains dominant and usable.
6. Active accumulation remains on visible wood.
7. Canonical logo remains top-left.
8. Best Score is directly below logo.
9. Score is directly below Best Score.
10. Best Score + Score stack is visibly higher than the pre-remediation M07 baseline and no longer intrudes materially into tabletop accumulation space.
11. Best/Score displayed sizes and spacing form a coherent pair.
12. Best/Score values are live production data.
13. Best value visible bounds stay inside the independently defined Best Score value content box.
14. Score value visible bounds stay inside the independently defined Score value content box.
15. Best/Score values do not overlap heading text, icons, flowers/leaves or frame borders.
16. To-Go remains upper-center.
17. To-Go retains upper anchoring while usable content presentation extends farther downward than pre-remediation baseline.
18. To-Go target cocktail visible bounds stay inside its target content box.
19. To-Go level/name text stays inside its dedicated text content box.
20. To-Go reward stays inside its dedicated reward content box.
21. To-Go target, text and reward do not materially overlap one another.
22. To-Go target/reward are live production data using shared M05 mapping and exact reward table.
23. Exactly one To-Go presentation exists.
24. NEXT remains upper-right.
25. NEXT retains upper anchoring while usable content presentation extends farther downward than pre-remediation baseline.
26. NEXT cocktail visible bounds are centered inside the independently defined inset content box.
27. NEXT cocktail does not clip into the wood frame/header or outside the inset.
28. Exactly one NEXT presentation exists.
29. NEXT follows the actual next launch drink before and after shots/rapid launches.
30. Gameplay cocktail visual scale is visibly larger than pre-remediation M07 baseline.
31. Final gameplay cocktail scale agrees with M05-R01 evidence-backed sprite/collider mapping; no obvious new visual/collision mismatch is introduced.
32. Relative L01-L12 progression remains readable.
33. Canonical danger-line artwork and actual `death_line_y` move downward together relative to pre-remediation M07 baseline.
34. Danger line remains above the held launch area and preserves a usable launch region below it.
35. Most tabletop above the danger line remains usable accumulation space.
36. M03 danger timing/Game Over behavior remains deterministic after the Y change.
37. Launch halo z-order is below the held drink.
38. Held drink horizontal center is aligned to the halo center within a defined tolerance.
39. Held glass visually sits inside the halo footprint and halo scale is appropriate for the final larger drink.
40. Launch halo remains non-colliding and does not alter launch physics.
41. Progression presentation is exactly two rows by six columns.
42. Top progression row level order is L07,L08,L09,L10,L11,L12 left-to-right.
43. Bottom progression row level order is L01,L02,L03,L04,L05,L06 left-to-right.
44. No L13 slot/icon exists.
45. Progression icons are visibly larger than the old single-row M07 baseline.
46. Every progression icon visible bound stays inside its cell with bounded padding and no material clipping/overlap.
47. Two-row progression frame looks intentional and consistent with tropical wooden/flower UI language, not like two raw duplicated 12-slot strips.
48. Original canonical source PNGs remain byte-for-byte unmodified.
49. Any new derived progression/runtime asset has documented provenance from approved art and is not presented as a replacement source truth.
50. No guide-line node/asset/persistent dotted aiming path exists.
51. No conflicting legacy prototype Score/Best/Next/target/hint UI remains visible.
52. All required HUD outer rectangles are fully on-screen in 720x1280.
53. All required HUD outer rectangles are fully on-screen in 720x1440.
54. All required HUD outer rectangles are fully on-screen in 800x1280.
55. No material HUD overlap occurs in any required viewport.
56. No black bars or stretching distort the approved composition.
57. M05 shared texture mapping is reused; no duplicate L01-L12 path table is introduced.
58. Corrected M06 geometry is used and not concealed/reverted by M07.
59. Layout tests use independent expected/reference envelopes, including inner content boxes, rather than only production-self-consistency checks.
60. Master-vs-runtime side-by-side evidence is retained for all three required viewports.
61. Annotated HUD-content-box evidence is retained for all three required viewports.
62. Progression 2x6 close-up evidence is retained and independently inspectable.
63. Table/collider/danger/launch overlay evidence is retained where relevant.
64. Launch speed remains 700 px/s and slide deceleration remains 180 px/s².
65. Immediate next, simultaneous moving drinks, settled wake/momentum, forward-only response, merge momentum and L12 cap remain intact.
66. M03 scores/combo/To-Go/persistence/Game Over/restart remain intact.
67. M01-M06 regressions rerun after final M07 remediation.
68. Strengthened M07 V02 focused validation passes.
69. Godot 4.7.x import/parse and configured startup pass.
70. `git diff --check` is clean.
71. No M08+ implementation leakage.
72. `TASKS.md` remains untouched by Codex.
73. ChatGPT-owned audit/re-audit/prompt/criteria/policy files remain untouched by Codex.
74. Matching `CODEX_LOG_V02.md` contains exact implementation/test/evidence/push facts.
75. Codex does not self-audit.
76. Any material visual item ChatGPT cannot independently inspect remains `UNVERIFIED` and blocks `AUDITED_PASS`.

## Verdict rule

- `AUDITED_PASS`: all material criteria pass; no BLOCKER/MAJOR defect; owner-directed M07 layout corrections are visibly present and independently inspectable.
- `CHANGES_REQUIRED`: any owner-directed correction is missing, material visual evidence is unverified, gameplay regresses, critical tests remain circular/weak, or governance is violated.
