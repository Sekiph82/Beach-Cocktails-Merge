# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner runtime screenshots/annotations, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M05 + M06 + M07 STRICT REMEDIATION
- Current Sprint: BCM-M06-R06 + BCM-M07-R06
- Current Task: Fix rear-table playable geometry, then apply latest owner HUD annotations.
- Current Task Status: READY
- Next Task/Action: Codex executes `coordination/sessions/BCM-M06-R06-M07-R06/CHATGPT_EXECUTION_PROMPT_V01.md`, writes separate M06-R06 and M07-R06 logs/commits, runs final regression, then STOPS for independent ChatGPT audit.
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
- [~] BCM-M06-001 — Reopened: latest owner runtime evidence shows rear-left/rear-right tabletop is still artificially restricted.
- [~] BCM-M07-001 — Reopened: latest owner annotations require score relocation/centering, To-Go reward repositioning, and held-body centering on launch halo.
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
- The owner explicitly confirmed the currently running Godot build is using the intended refreshed background and HUD artwork.
- No guide line.

## M00-M03 — Audited gameplay baseline

- [x] Launch speed 700 px/s.
- [x] Slide deceleration 180 px/s².
- [x] Immediate next-held generation and simultaneous moving drinks.
- [x] Settled-body wake/momentum transfer and no intentional +Y rebound.
- [x] Deferred merge processing, L12 hard cap and merge momentum.
- [x] Merge score/combo/To-Go reward contracts accepted.
- [x] Persistence, Game Over and restart accepted.

## M04-R03 — Accepted visual asset family

Latest audit:
`coordination/sessions/BCM-M04-R03/CHATGPT_AUDIT_V03.md`

Verdict: **AUDITED_PASS**.

## M05-R02 — Still open

Audit:
`coordination/sessions/BCM-M05-R02/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Open concerns remain around independently evidenced body/collider measurements, shape classification, and contact-fit proof.

## M06-R05 — Latest audit

Audit:
`coordination/sessions/BCM-M06-R05/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Latest owner runtime screenshot shows substantial visible rear-left and rear-right tabletop remains unreachable. The R05 probe proved only tangency to production rails, not that those rails match the visible table edge.

Active replacement criteria:
`coordination/sessions/BCM-M06-R06/CHATGPT_AUDIT_CRITERIA_V01.md`

## M07-R05 — Latest audit

Audit:
`coordination/sessions/BCM-M07-R05/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Latest owner annotations require:
- BEST SCORE digits visually centered in the dark value window;
- SCORE moved to the right beneath/near NEXT and digits centered in its value window;
- To-Go reward moved inside the cream board to the owner-marked lower-middle area;
- held cocktail visible glass/container body centered horizontally on the gold launch oval while keeping the accepted body-bottom baseline;
- all accepted M07-R04 rules preserved.

Active replacement criteria:
`coordination/sessions/BCM-M07-R06/CHATGPT_AUDIT_CRITERIA_V01.md`

## Active remediation sequence

Master prompt:
`coordination/sessions/BCM-M06-R06-M07-R06/CHATGPT_EXECUTION_PROMPT_V01.md`

Required order:
1. BCM-M06-R06 — independently remeasure/fix rear/full tabletop boundaries.
2. BCM-M07-R06 — apply latest owner HUD annotations without shrinking the corrected playfield.
3. Final M01-M07 regression.
4. STOP for independent ChatGPT audit.

M08 may not start until M06-R06 and M07-R06 are independently accepted and the separate M05 strict-audit state is resolved or explicitly superseded.

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
