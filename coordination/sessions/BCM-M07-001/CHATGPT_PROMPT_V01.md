# BCM-M07-001 — Dynamic HUD and Final Gameplay-Screen Composition V01

Status: **ISSUED**

## Canonical visual reference

The owner-approved master gameplay composition is:

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

This image is authoritative for the intended visual hierarchy, table silhouette, HUD placement and overall tropical casual-game composition, except for explicit later owner decisions. The later owner decision **no guide line** overrides the dotted aiming guide visible in the historical master.

The locked audit contract for this work item is:

`coordination/sessions/BCM-M07-001/CHATGPT_AUDIT_CRITERIA_V01.md`

Codex must read both this prompt and that audit-criteria file before implementation. Codex must not modify either file.

## Goal

Compose the owner-approved gameplay screen from the canonical V7 assets and live production data so the actual running game is visually recognisable as the same composition as the owner master, while preserving the accepted M01-M06 gameplay contracts.

## Required work

1. Safely sync `main` and preserve owner work.
2. Read `AGENTS.md`, `TASKS.md`, this prompt, the locked audit criteria, M05/M06 source and relevant prior logs/audits.
3. Use the canonical M06 beach/table background and M05 cocktail sprites.
4. Build the final gameplay HUD with:
   - logo at top-left;
   - Best Score directly below logo;
   - Score directly below Best Score;
   - upper-center To-Go Orders panel with live target cocktail and live reward;
   - exactly one upper-right NEXT panel with the true next cocktail;
   - canonical 12-slot L01-L12 progression strip near the bottom;
   - canonical launch-zone oval under the held cocktail;
   - canonical danger-line PNG at the actual production danger threshold.
5. Reuse `Drink.texture_for_level()` / the single M05 production texture mapping for To-Go, NEXT and progression icons. Do not create a duplicate cocktail path table.
6. Remove/suppress visible legacy prototype Score/Best/NEXT/target UI that would duplicate the final panels.
7. Preserve the owner-approved master visual rhythm. Do not treat “all nodes exist” as sufficient if the production screenshot looks materially different from the master.
8. The historical master contains a dotted aiming guide. Do **not** implement it. The owner explicitly removed guide-line behavior from the design.
9. A bottom instruction band/text may be retained only if intentionally styled/placed to match the owner master. Do not leave an unrelated prototype/debug hint merely because it already exists.
10. Keep score, best score, target, reward, NEXT and other changing content dynamic in Godot rather than baking it into PNGs.
11. Keep exactly one active To-Go presentation and one NEXT presentation.
12. Ensure immediate-next generation and rapid consecutive launches keep NEXT/current/held visuals coherent.
13. Keep the progression strip exactly 12 slots L01-L12 in order with no L13.
14. Keep launch-zone and danger-line visuals non-colliding and input-transparent.
15. Do not move the gameplay danger threshold merely to fit the visual asset.
16. If M06 geometry/background is discovered to be visually incompatible with the owner master, record it as a blocker and make only the bounded correction required to restore the master composition. Do not conceal the mismatch with HUD placement.
17. Validate 720x1280, 720x1440 and 800x1280.
18. Retain actual production screenshots:
   - `docs/evidence/m07/canonical_720x1280.png`
   - `docs/evidence/m07/taller_720x1440.png`
   - `docs/evidence/m07/shorter_wider_800x1280.png`
19. The screenshots must show a representative live state proving the background/table, real cocktails, logo, Best Score, Score, To-Go target/reward, exactly one NEXT, 12 progression icons, launch zone and danger line.
20. Add/maintain a focused production M07 probe. It must interrogate real production nodes/state rather than recreate the rules in a fake model.
21. Rerun M01-M06 regressions after production changes and inspect any pre-existing test that you modify so assertions are not weakened to obtain PASS.
22. Run Godot version, import/parse, configured startup and `git diff --check`.
23. Do not modify canonical source PNGs.
24. Do not implement M08+ effects/audio/menu/export work.
25. Do not edit `TASKS.md`.
26. Do not edit ChatGPT-owned files under `coordination/sessions/BCM-M07-001/`.
27. Write the immutable builder log to:
   `coordination/sessions/BCM-M07-001/CODEX_LOG_V01.md`
28. The log must contain exact sync, changed files, implementation, tests, screenshots/hashes, limitations, commit and push evidence.
29. Commit/push safely, return `AWAITING_AUDIT`, then stop. Do not self-audit.

## Locked gameplay invariants

- launch speed 700 px/s;
- deceleration 180 px/s²;
- no artificial minimum-speed/cruise assist;
- held drink non-colliding until released;
- immediate next-held generation;
- simultaneous moving drinks;
- settled drinks can wake/move on collision;
- no intentional +Y/backward rebound toward the player;
- merge momentum preserved;
- L12 hard cap;
- accepted M03 scoring/combo/To-Go/persistence/Game Over/restart behavior;
- accepted M05 cocktail mapping/scales/colliders unless a separately evidenced defect is found;
- accepted M06 world coordinates may not be casually retuned for HUD convenience.

## Out of scope

Do not implement M08 delivery trail/merge VFX polish, M09 audio/haptics, M10 menus/onboarding, M11 export/device QA, or M12 release work.

## Output

Write only the builder evidence log named above, commit/push all intended work, return `AWAITING_AUDIT`, and stop for independent ChatGPT audit against the pre-issued criteria.
