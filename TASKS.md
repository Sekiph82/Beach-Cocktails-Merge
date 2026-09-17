# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner runtime screenshots/annotations, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M05 + M06 + M07 STRICT REMEDIATION
- Current Sprint: BCM-R10-RUNTIME-PHYSICS-CLOSURE
- Current Task: Close only the remaining rear tabletop contact defect. Auto-fire, BEST/SCORE centering, To-Go top placement and held-drink alignment are owner-approved and frozen.
- Current Task Status: READY
- Next Task/Action: Codex executes `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V03.md`, writes the R10 V02 log, runs full active regression, then STOPS for independent ChatGPT audit.
- Required Actor: CODEX
- Tracking Repository: Sekiph82/Beach-Cocktails-Merge
- Tracking Branch: main

## Tasks

- [x] BCM-M00-001 — Repository synchronization and evidence baseline.
- [x] BCM-M00-002 — Repository hygiene, canonical structure, and Godot import baseline.
- [x] BCM-M01-001 — Recover and verify playable gameplay contract from synchronized v6.7 state.
- [x] BCM-M02-001 — Formalize physics, collision, merge, and rapid-launch regression suite.
- [x] BCM-M03-001 — Formalize scoring, combo, To-Go Orders, persistence, and game-over systems.
- [x] BCM-M04-001 — Canonical refreshed visual asset family accepted from owner runtime evidence.
- [!] BCM-M05-001 — Cocktail sprite/collider evidence still has unresolved strict-audit concerns from M05-R02.
- [~] BCM-M06-001 — Active: rear contact only. Mandatory owner formula is `rear_target_y = rear_table_y`; moving cocktails must physically reach the real rear table line with no stale hidden wall/dead strip.
- [~] BCM-M07-001 — Owner-approved/frozen: auto-fire fixed, BEST/SCORE centered, To-Go top placement correct, held-drink/gold-oval alignment correct; preserve only.
- [ ] BCM-M08-001 — Integrate To-Go delivery animation and visual effects.
- [ ] BCM-M09-001 — Add gameplay feedback polish, audio, and optional haptics.
- [ ] BCM-M10-001 — Add menus, settings, onboarding, accessibility, save migration, and UX polish.
- [ ] BCM-M11-001 — Mobile layout, performance, export, device QA, and release readiness.
- [ ] BCM-M12-001 — Final regression, acceptance, packaging, documentation, and v1 release closure.

Legend: `[x]` audited complete, `[~]` active/pending owner closure, `[!]` reopened/changes required, `[ ]` planned.

## Governance

- Codex must never edit this file.
- Prompt and locked audit criteria are created before implementation/remediation.
- Codex logs are builder evidence, not acceptance proof.
- ChatGPT independently audits actual diff/source/tests/evidence against locked criteria.
- Owner runtime screenshots and annotations are authoritative when later than earlier audit interpretations.
- Only ChatGPT updates this tracker after audit.
- No guide line.

## M00-M04 — Accepted baseline

- [x] M00 repository baseline.
- [x] M01 launch/current/next/gameplay contract.
- [x] M02 collision/merge/rapid-launch physics.
- [x] M03 scoring/combo/To-Go/persistence/Game Over.
- [x] M04 refreshed canonical visual asset family.

## M05-R02 — Still open

Audit:
`coordination/sessions/BCM-M05-R02/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Open concerns remain around independently evidenced body/collider measurements, shape classification, and contact-fit proof.

## Latest owner runtime state — accepted/frozen

Latest owner runtime screenshot and written confirmation establish:
- auto-fire / uncommanded drink creation is resolved;
- BEST SCORE digits are correctly centered;
- SCORE digits are correctly centered;
- To-Go Orders top placement / rope-to-ceiling result is correct;
- held drink is correctly positioned on the gold launch oval;
- NEXT and baked 2x6 progression show no visible regression.

These areas are preservation targets only and must not be redesigned during the current closure.

## Active R10 V03 — rear-contact-only closure

Locked criteria:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V03.md`

Execution prompt:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V03.md`

Mandatory owner rule for all L01-L12:

`rear_target_y = rear_table_y`

Forbidden rear-target adjustments include collider radius, body half extent, sprite/drink height, width, per-level Y offsets or per-level rear-target tables.

Required closure:
1. Moving RigidBody2D cocktails physically reach the owner-defined `rear_table_y` contact line.
2. No stale hidden TopRail or other rear wall stops them earlier.
3. Physical rear collision, clamp/target and `rear_table_y` are coherent.
4. Current visible unused rear-table strip is removed.
5. Validate actual moving L01/L06/L12 rear contacts, not direct-spawn coordinate agreement only.
6. Re-run desktop idle smoke only to confirm the already-fixed auto-fire behavior does not regress.
7. Preserve all owner-approved HUD/held/input behavior and full gameplay contracts.
8. Full active regression then STOP for independent audit.

M08 may not start until M06/M07 are independently accepted and the separate M05 strict-audit state is resolved or explicitly superseded.

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
