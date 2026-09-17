# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner runtime screenshots/annotations, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M05 + M06 + M07 STRICT REMEDIATION
- Current Sprint: BCM-M06-R07 + BCM-M07-R07
- Current Task: Correct the latest owner-visible tabletop and HUD/launch-alignment defects from the 2026-09-17 18:37 runtime screenshot, then run full regression.
- Current Task Status: READY
- Next Task/Action: Codex executes `coordination/sessions/BCM-M06-R07-M07-R07/CHATGPT_EXECUTION_PROMPT_V03.md`, writes separate M06-R07 and M07-R07 logs/commits, runs the full active M01-M07 suite, then STOPS for independent ChatGPT audit.
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
- [~] BCM-M06-001 — Reopened by latest owner runtime evidence: cocktail bodies can leave the tabletop in some rear/side positions while usable rear wood remains unreachable.
- [~] BCM-M07-001 — Reopened by latest owner runtime evidence: SCORE vertical centering, To-Go rope continuity and held-cocktail/gold-oval alignment still need correction.
- [ ] BCM-M08-001 — Integrate To-Go delivery animation and visual effects.
- [ ] BCM-M09-001 — Add gameplay feedback polish, audio, and optional haptics.
- [ ] BCM-M10-001 — Add menus, settings, onboarding, accessibility, save migration, and UX polish.
- [ ] BCM-M11-001 — Mobile layout, performance, export, device QA, and release readiness.
- [ ] BCM-M12-001 — Final regression, acceptance, packaging, documentation, and v1 release closure.

Legend: `[x]` audited complete, `[~]` active, `[!]` reopened/changes required, `[ ]` planned.

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

## M06-R06 — Superseded by latest owner runtime evidence

Latest owner screenshot shows the running build still has a practical tabletop-boundary defect:
- some cocktail glass/container bodies can leave visible wood at the rear/side area;
- at the same time, clearly visible rear tabletop remains unreachable.

Therefore internal R06 geometry consistency is not sufficient for acceptance.

Active replacement criteria:
`coordination/sessions/BCM-M06-R07/CHATGPT_AUDIT_CRITERIA_V03.md`

## M07-R06 — Superseded by latest owner runtime evidence

Latest owner annotations show remaining visible defects:
- SCORE digits sit slightly too low in the dark recessed window;
- To-Go ropes still appear visually disconnected from the top/ceiling;
- held cocktails still do not visually sit in the true center of the gold launch oval.

Active replacement criteria:
`coordination/sessions/BCM-M07-R07/CHATGPT_AUDIT_CRITERIA_V03.md`

## Active problem-driven remediation sequence

Master prompt:
`coordination/sessions/BCM-M06-R07-M07-R07/CHATGPT_EXECUTION_PROMPT_V03.md`

V03 is intentionally problem-driven rather than solution-prescriptive. Codex must inspect the current implementation and choose the technical correction.

Required order:
1. BCM-M06-R07 — make the running-game playable region match the actual visible tabletop: no body outside wood and no unjustified unreachable rear wood.
2. BCM-M07-R07 — correct SCORE vertical centering, visible To-Go rope continuity, and held-cocktail/gold-oval alignment while preserving accepted HUD direction.
3. Run the complete active M01-M07 suite, including active baseline M06 tests.
4. STOP for independent ChatGPT audit.

M08 may not start until M06/M07 are independently accepted and the separate M05 strict-audit state is resolved or explicitly superseded.

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
