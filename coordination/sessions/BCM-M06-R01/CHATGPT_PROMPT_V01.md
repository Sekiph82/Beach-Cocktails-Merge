# BCM-M06-R01 — Visual Environment/Table Realignment V01

Status: **ISSUED**

## Reason for remediation

The previous M06 audit is superseded for visual acceptance. Owner review rejected the committed M06 evidence as materially inconsistent with the intended gameplay composition.

Canonical owner master:

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

Locked audit criteria:

`coordination/sessions/BCM-M06-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

Read both before implementation. Do not modify either file.

## Goal

Realign the production **environment/table/playfield** to the owner master before M07 HUD acceptance. The result must visually read as the same long perspective tabletop composition, not simply satisfy geometric tests on a generic tropical background.

## Required work

1. Safely sync `main`; preserve owner work.
2. Read `AGENTS.md`, `TASKS.md`, this prompt, the locked audit criteria, previous M06 implementation/log/audit, and the owner-master PNG.
3. Inspect the actual committed M06 production screenshots against the owner master before changing code.
4. Identify the concrete visual mismatches: table silhouette/proportions, far/near rail positions, launch region, danger region, world-to-art alignment, background crop/scale, or incorrect source asset/layout assumptions.
5. Correct the production environment/table mapping so the long perspective wooden table occupies the same broad gameplay role/proportions as the owner master.
6. Ensure left/right/top/bottom gameplay boundaries visually follow the corrected table.
7. Keep danger threshold low/near launch side and preserve most of the table as usable play area.
8. Keep launch position in the lower table region.
9. Do not implement M07 HUD composition in this remediation.
10. Do not add guide line.
11. Do not casually retune accepted gameplay constants/economy.
12. If the current `game_board_background.png` itself cannot reproduce the owner master environment/table composition, document that as the root cause and use the correct owner-approved source/layout available in the repo. Do not disguise an incompatible asset with arbitrary coordinate tests.
13. Preserve the owner-approved canonical source assets; no destructive/redrawn substitute unless explicitly required and recoverable.
14. Retain actual production captures after remediation:
    - `docs/evidence/m06-r01/canonical_720x1280.png`
    - `docs/evidence/m06-r01/taller_720x1440.png`
    - `docs/evidence/m06-r01/shorter_wider_800x1280.png`
15. Screenshots must show real production background/table, cocktail sprites, launch region and danger boundary. HUD may remain prototype/absent because M07 owns final HUD.
16. Add or update a focused production geometry/visual-contract probe only where it validates measurable production truth. Do not use the test itself as a substitute for screenshot similarity.
17. Rerun M01-M05 regressions after production changes.
18. Inspect any existing test you modify and keep assertions at least as strict as before.
19. Run Godot version/import/parse/main-scene startup and `git diff --check`.
20. Do not edit `TASKS.md`.
21. Do not edit ChatGPT-owned coordination session files.
22. Write immutable builder evidence to:
    `coordination/sessions/BCM-M06-R01/CODEX_LOG_V01.md`
23. Commit/push all intended remediation work and evidence, return `AWAITING_AUDIT`, then stop. Do not self-audit.

## Locked gameplay invariants

- launch speed 700 px/s;
- slide deceleration 180 px/s²;
- immediate next-held generation;
- simultaneous moving drinks;
- settled-body wake/momentum transfer;
- forward-only/no intentional backward return;
- merge momentum;
- L12 cap;
- accepted M03 score/combo/To-Go/persistence/Game Over/restart;
- accepted M05 cocktail mapping/scales/colliders unless a directly evidenced visual-body defect is found.

## Out of scope

M07 HUD, M08 effects, M09 audio/haptics, M10 menus/onboarding, M11 export/device QA, M12 release closure.
