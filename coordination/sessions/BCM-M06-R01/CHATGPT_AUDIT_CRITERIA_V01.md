# BCM-M06-R01 — ChatGPT Audit Criteria V01

`AUDITED_PASS` requires all material criteria below to pass.

## Canonical visual truth

Owner-approved master gameplay image:

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

M06-R01 audits only the **environment/table/playfield** portion of that master. HUD widgets belong to M07. The master is authoritative for table silhouette, placement, perspective, usable play-space proportions and tropical environment relationship.

## Required PASS criteria

1. Actual production screenshots exist for 720x1280, 720x1440 and 800x1280 after remediation.
2. ChatGPT independently inspects the screenshot pixels/images, not only metadata, hashes or builder descriptions.
3. The background/table composition is recognisably the same layout as the owner master, not merely a generic tropical scene.
4. The long wooden table is the dominant gameplay surface, starting in the upper-middle region and widening strongly toward the player/bottom.
5. The far end of the table is narrow and visually sits beneath the upper HUD region, leaving the beach/resort horizon visible above/around it as in the master.
6. The near end of the table is broad and occupies most of the lower screen width, leaving coherent decorative/environment margins rather than a small centered board floating in scenery.
7. The central playable wood surface is large enough for the intended accumulation gameplay and visually resembles the master proportions.
8. Production left/right collision rails closely follow the visible wood/table boundaries over far, middle and near depths.
9. Top stop boundary sits at a visually credible far-table boundary and does not stop drinks in open beach/background space.
10. Launch position is near the lower table area in the same broad visual region as the master.
11. Gameplay danger threshold is low/near the launch side while preserving most of the tabletop as usable space.
12. M06 remediation does not introduce HUD composition owned by M07.
13. No guide-line asset/node is introduced.
14. Canonical source PNGs are not destructively edited merely to make tests pass. If the current environment asset cannot reproduce the approved master, that incompatibility must be reported and the correct owner-approved source/layout must be used or the task remains blocked.
15. 720x1280 has no material table-edge/collider mismatch, clipping or distortion.
16. 720x1440 has no material table-edge/collider mismatch, clipping or distortion.
17. 800x1280 has no material table-edge/collider mismatch, clipping or distortion.
18. Background scaling preserves aspect ratio and does not stretch the table.
19. No gameplay-critical black bars are introduced.
20. M05 cocktail sprites remain correctly mapped/rendered on the table.
21. Launch speed remains 700 px/s and deceleration remains 180 px/s².
22. Collision/wake/forward-only/merge-momentum/L12-cap behavior remains intact.
23. M03 scoring/To-Go/persistence/Game Over/restart remains intact.
24. Any M01-M05 regression test modified by Codex is inspected for weakened assertions or assumptions that merely follow the new implementation.
25. M01-M05 regression suites pass after the remediation.
26. Godot 4.7.x import/parse and main-scene startup pass.
27. `git diff --check` is clean.
28. M07 HUD implementation does not leak into this remediation.
29. `TASKS.md` remains untouched by Codex.
30. ChatGPT-owned prompt/criteria/audit files remain untouched by Codex.
31. Matching `CODEX_LOG_V01.md` contains exact implementation, screenshot-generation, test and push evidence.
32. Codex does not self-audit.
33. Any material visual criterion not independently inspectable remains `UNVERIFIED` and blocks `AUDITED_PASS`.

## Verdict rule

- `AUDITED_PASS`: all material criteria pass and the independently inspected production captures visually agree with the owner master's table/environment composition.
- `CHANGES_REQUIRED`: any material visual mismatch, missing screenshot inspection, gameplay regression, wrong table/rail mapping or governance violation.
