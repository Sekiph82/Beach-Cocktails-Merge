# BCM-M07-001 — ChatGPT Audit Criteria V01

`AUDITED_PASS` requires **every** criterion below to pass. A Codex PASS line is never sufficient by itself.

## Canonical visual truth

The owner-approved master gameplay composition is the repository image:

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

This master is authoritative for visual hierarchy, proportions, table silhouette, HUD placement and overall tropical casual-game composition, subject only to explicit later owner decisions. One explicit later decision overrides the master: **no guide line / dotted aiming line**.

The audit must compare committed M07 production screenshots directly against this master. Visual similarity may not be inferred from coordinates, filenames, tests, or Codex prose alone.

## Required PASS criteria

1. Actual production screenshots exist for 720x1280, 720x1440 and 800x1280.
2. ChatGPT independently inspects the screenshot pixels/images, not only file metadata, hashes or Codex descriptions.
3. The integrated screen clearly reads as the same visual design language and composition as the canonical owner master, not merely a generic beach background with UI placed somewhere on top.
4. The long perspective wooden table dominates the lower gameplay screen as in the master: narrow toward the horizon/top, broad toward the player/bottom, with a large usable central play surface.
5. Table/world collision rails visually agree with the table edges closely enough that drinks do not appear to collide with invisible rails far from the wood boundaries.
6. The active accumulation/play region remains visibly on the tabletop and is not pushed into the beach/background scenery.
7. Top-left logo uses the canonical logo asset and matches the master hierarchy.
8. Best Score panel sits directly below the logo and uses the canonical panel asset.
9. Score panel sits directly below Best Score and uses the canonical panel asset.
10. Best Score and Score displayed panel sizes/visual rhythm are effectively matched despite the 2 px source-width difference.
11. Best Score and Score numeric values are live Godot text/data, not baked into PNGs.
12. To-Go Orders panel is upper-center, visually prominent, and uses the canonical panel asset.
13. To-Go target cocktail is live and uses the shared M05 canonical cocktail texture mapping.
14. To-Go reward is live and matches production reward data.
15. Exactly one active To-Go presentation exists.
16. NEXT panel is upper-right and uses the canonical panel asset.
17. Exactly one NEXT presentation exists. No duplicate bottom/legacy NEXT text or preview remains.
18. NEXT preview follows the actual next launch drink before and after a shot.
19. Rapid launches do not desynchronize held/current/next HUD state.
20. Progression strip uses the canonical 12-slot asset and is positioned near the bottom in the master visual rhythm.
21. Exactly 12 canonical cocktail icons are populated left-to-right L01 through L12. No L13 slot exists.
22. Progression icons are legible and fit their slots without obvious clipping or chaotic overlap.
23. The held launch cocktail sits naturally above/on the canonical glowing launch-zone oval.
24. Launch-zone visual is non-colliding and does not alter launch/spawn physics.
25. Canonical danger-line PNG replaces the old procedural danger-line duplicate.
26. Danger-line visual tracks the actual accepted gameplay `death_line_y`; gameplay threshold is not moved merely to fit art.
27. Danger line is low/near the launch zone, preserving most of the table as usable play area, consistent with the owner direction.
28. No guide-line node, dotted aiming line, persistent arrow path or guide-line asset is present, even though the historical master image contains one.
29. The permanent bottom instruction band/text is allowed only if it is intentionally retained to match the master; any legacy prototype hint styling that visibly conflicts with the master must be removed. This criterion is visual, not merely node-name based.
30. No legacy prototype Score/Best/NEXT/target labels remain visibly duplicated behind or over the final art.
31. UI does not visibly overlap/collide in the three required portrait aspect ratios.
32. Upper HUD does not consume or obscure the playable accumulation zone excessively.
33. No important HUD element is clipped off-screen in the three required portrait aspect ratios.
34. No black bars or stretching distort the approved composition in the three required portrait aspect ratios.
35. Canonical source PNGs remain byte-for-byte unmodified by M07.
36. M05 shared texture mapping is reused. M07 does not introduce a second duplicated L01-L12 path table.
37. M06 gameplay geometry is not silently retuned merely to make HUD placement easier. If M06 itself is discovered visually wrong against the master, that is a blocker to M07 acceptance and must be remediated rather than hidden by HUD placement.
38. Launch speed remains 700 px/s and slide deceleration remains 180 px/s².
39. Immediate next-held generation, simultaneous moving drinks, settled-drink wake, forward-only response, merge momentum and L12 cap remain intact.
40. M03 scoring, combo, To-Go rewards/semantics, persistence, Game Over and restart remain intact.
41. Focused M07 tests assert actual production nodes/state rather than reimplementing expected values in an isolated fake model.
42. Any pre-existing regression test modified by Codex is independently inspected to ensure the assertion was not weakened merely to make the suite pass.
43. M01-M06 regression suites are rerun after production changes and exact outputs/exit codes are recorded.
44. Godot 4.7.x import/parse and configured main-scene startup succeed.
45. `git diff --check` is clean.
46. The implementation diff is bounded to M07; no M08+ implementation leakage.
47. `TASKS.md` is untouched by Codex.
48. ChatGPT-owned audit/session criteria files are untouched by Codex.
49. Matching Codex log contains actual sync, implementation, test, screenshot-generation, commit and push evidence.
50. Codex does not self-audit or assign the authoritative verdict.
51. Any evidence ChatGPT cannot independently reproduce/inspect is explicitly classified as implementer evidence, not independent proof.
52. Any visually material criterion that remains `UNVERIFIED` blocks unconditional `AUDITED_PASS`.

## Verdict rule

- `AUDITED_PASS`: all material criteria PASS; no BLOCKER/MAJOR defect; required screenshots independently inspected and visually consistent with the owner master.
- `CHANGES_REQUIRED`: any material visual mismatch, missing independent screenshot inspection, wrong table/HUD composition, duplicate/incorrect dynamic state, gameplay regression, governance violation, or other blocking criterion.
- Minor non-material defects may be recorded without blocking only when they do not alter the owner-approved gameplay or visual contract.
