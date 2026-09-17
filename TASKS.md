# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner runtime screenshots/annotations, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M05 + M06 + M07 STRICT REMEDIATION
- Current Sprint: BCM-M06-R08 + BCM-M07-R08 OWNER RUNTIME REFINEMENT
- Current Task: Fix remaining rear-table stopping/corner behavior, then correct To-Go top placement and BEST/SCORE vertical centering without touching the accepted held-drink alignment.
- Current Task Status: READY
- Next Task/Action: Codex executes `coordination/sessions/BCM-M06-R08-M07-R08/CHATGPT_EXECUTION_PROMPT_V01.md`, writes separate M06-R08 and M07-R08 logs/commits, runs the full active M01-M07 suite, then STOPS for independent ChatGPT audit.
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
- [~] BCM-M06-001 — Active: rear stopping remains too conservative; size-aware rear stopping and natural rear-corner behavior required.
- [~] BCM-M07-001 — Active: move existing To-Go asset itself to viewport top and vertically center BEST/SCORE digits; held-drink alignment is accepted/frozen.
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

## M06-R07 — Superseded by latest owner runtime evidence

R07 improved the rear boundary but the latest owner runtime screenshot still shows cocktails stopping too far from the visible rear tabletop edge.

New owner requirement:
- stopping distance must respond to current cocktail body size/footprint rather than one shared fixed rear distance;
- small drinks may travel farther rearward than large drinks where their visible body allows it;
- rear corner behavior may use a subtle, smooth center-seeking tendency if needed so the apparent rounded corners do not behave like abrupt square walls.

Active criteria:
`coordination/sessions/BCM-M06-R08/CHATGPT_AUDIT_CRITERIA_V01.md`

## M07-R07 — Superseded by latest owner runtime evidence

Latest owner screenshot confirms:
- held-drink launch placement is now accepted and must not be modified;
- To-Go should not use runtime rope extensions; move the supplied asset itself upward until its own topmost artwork touches the viewport top;
- BEST SCORE and SCORE are horizontally centered but still require true vertical centering in the dark/gold-framed recesses.

Active criteria:
`coordination/sessions/BCM-M07-R08/CHATGPT_AUDIT_CRITERIA_V01.md`

## Active problem-driven remediation sequence

Master prompt:
`coordination/sessions/BCM-M06-R08-M07-R08/CHATGPT_EXECUTION_PROMPT_V01.md`

The prompt deliberately describes owner-visible problems and desired behavior instead of prescribing a specific implementation.

Required order:
1. BCM-M06-R08 — size-aware rear stopping and natural rear-corner behavior while preserving gameplay contracts.
2. BCM-M07-R08 — move existing To-Go asset to viewport top; vertically center BEST/SCORE; preserve accepted held-drink alignment.
3. Run complete active M01-M07 regression.
4. STOP for independent ChatGPT audit.

M08 may not start until M06/M07 are independently accepted and the separate M05 strict-audit state is resolved or explicitly superseded.

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
