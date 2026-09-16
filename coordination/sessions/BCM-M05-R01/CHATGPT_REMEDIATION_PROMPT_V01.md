# BCM-M05-R01 — Cocktail Sprite / Collider Alignment Remediation V01

Status: **ISSUED**

## Goal

Repair M05's visual-evidence and collider-alignment weakness without broad gameplay retuning. Preserve the working single texture mapping and runtime ownership model, but replace unsupported body-fit assumptions with retained, inspectable evidence.

## Read first

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_REAUDIT_V01.md`
- completed M04-R01 remediation outputs/log if already produced in the master sequence
- `coordination/sessions/BCM-M05-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M05-R01/CHATGPT_AUDIT_CRITERIA_V01.md`
- original M05 prompt/log
- owner master `/b75ee426-9568-4ed6-b35e-140600a7c995.png`

## Required work

1. Safely sync/preserve owner work; do not edit `TASKS.md` or ChatGPT-owned files.
2. Preserve the canonical L01-L12 texture mapping and owner PNG bytes.
3. Correct the provenance model. Do not claim body measurements came from M04 alpha bounds unless the new M04-R01 evidence actually establishes them.
4. Create an explicit per-level presentation evidence dataset, e.g. `docs/evidence/m05/presentation_manifest.json`, containing for L01-L12:
   - source texture path/hash;
   - source dimensions/alpha bbox;
   - selected visible-body bbox or body-width/body-center measurement;
   - measurement method/classification (`MANUAL_VISUAL_MEASUREMENT` where appropriate);
   - runtime scale;
   - runtime offset/pivot;
   - collider radius;
   - runtime mass.
5. Create retained visual evidence under `docs/evidence/m05/`:
   - `all_levels_collider_overlay.png`: all L01-L12 at runtime scale, each with visible collider outline and center/pivot markers;
   - `all_levels_clean.png`: same progression without debug overlays for readability comparison;
   - `touching_pairs.png`: representative adjacent-contact pairs across small/mid/high levels, showing that physical contact does not create a large invisible visual gap or extreme overlap;
   - `merge_continuity.png` or equivalent representative before/after merge evidence if practical.
6. The collider overlay must be generated from the actual production scale/offset/radius APIs, not a separately retyped table.
7. Add a focused independent-style test that verifies non-circular facts where possible:
   - canonical textures exist and load;
   - production overlay generation uses actual runtime nodes;
   - collider/scale/offset values are finite/positive and in documented bounds;
   - no duplicate texture mapping;
   - L13 remains absent;
   - runtime mass progression remains compressed;
   - merge/rapid-launch/restart/Game Over behavior remains intact.
8. Do not pretend a self-consistency assertion proves visual fit. Mark visual body/collider fit as requiring visual evidence.
9. Review every L01-L12 radius/scale/offset against the evidence. Adjust only values that visibly fail the body/collider contract.
10. Pay special attention to shape diversity: martini stems/bowls, tall highballs, rounded goblets, coconut and pineapple body. A single width-based assumption must not be treated as automatically correct for all shapes.
11. Keep garnish/straw outside the collision footprint unless doing so would make the body visibly overlap other pieces unrealistically.
12. Preserve launch 700, deceleration 180, forward-only collision behavior, compressed mass progression, merge momentum, scoring/combo/To-Go/persistence/Game Over/restart.
13. Rerun M01, M02, M03 and strengthened M05 probes after any production change.
14. Run Godot import/parse/main-scene startup and `git diff --check`.
15. New remediation log:

`coordination/sessions/BCM-M05-R01/CODEX_LOG_V01.md`

The log must explicitly correct the historical pre-M05 JSON radii to:

`14,21,29,38,48,59,71,84,98,113,129,146`

Do not edit the immutable old M05 log.

16. Commit the bounded M05 remediation separately, then continue to M06 remediation only when instructed by the master orchestration prompt.

## Out of scope

- no environment/table redesign;
- no HUD/M07 work;
- no score/economy changes;
- no guide line;
- no source PNG redesign.

## Completion state

Return `AWAITING_AUDIT` for M05-R01. Do not self-approve.
