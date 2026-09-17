# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner runtime screenshots/annotations, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M05 + M06 + M07 STRICT REMEDIATION
- Current Sprint: BCM-M06-R08 + BCM-M07-R08 OWNER RUNTIME REFINEMENT
- Current Task: Apply the consolidated post-R07 owner refinements: common rear-edge tangency for all cocktail levels, natural rear-corner behavior, To-Go asset top alignment, and BEST/SCORE vertical centering while preserving the accepted held-drink alignment.
- Current Task Status: READY
- Next Task/Action: Codex executes `coordination/sessions/BCM-M06-R08-M07-R08/CHATGPT_EXECUTION_PROMPT_V04.md`, writes separate M06-R08 and M07-R08 logs/commits, runs the full active M01-M07 suite, then STOPS for independent ChatGPT audit.
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
- [~] BCM-M06-001 — Active: all L01-L12 glass/container bodies must reach one common rear tabletop boundary by size-derived center positioning, with no artificial rear dead zone.
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

R07 improved the rear boundary but the latest owner runtime evidence still showed cocktails stopping too far from the visible rear tabletop edge.

Current authoritative M06 rule:
- there is one common visible rear tabletop boundary for all L01-L12;
- every cocktail's visible glass/container body must touch that same rear boundary;
- per-level body size changes only the center position at which tangency occurs;
- no hardcoded per-level rear target Y values;
- mandatory formula in the consolidated V04 prompt:
  `rear_target_center_y = rear_table_y + body_half_extent_y`;
- invariant:
  `visible_body_top_y = rear_table_y` at rear contact;
- rear corners should feel organic rather than like abrupt square invisible walls, without changing the common rear-edge rule.

Active criteria:
`coordination/sessions/BCM-M06-R08/CHATGPT_AUDIT_CRITERIA_V03.md`

## M07-R07 — Superseded by latest owner runtime evidence

Latest owner requirements:
- held-drink launch placement is accepted and frozen;
- To-Go must not use runtime rope extensions; move the supplied To-Go asset itself upward until its own topmost visible artwork touches the viewport top;
- BEST SCORE and SCORE are horizontally centered but require true vertical centering in their actual dark/gold-framed value recesses;
- fixed font size and seven-digit maximum remain unchanged.

Active criteria:
`coordination/sessions/BCM-M07-R08/CHATGPT_AUDIT_CRITERIA_V01.md`

## Active consolidated remediation sequence

Master prompt:
`coordination/sessions/BCM-M06-R08-M07-R08/CHATGPT_EXECUTION_PROMPT_V04.md`

V04 is the only R08 execution prompt that should be given to Codex. The owner did not execute R08 V01, V02, or V03. V04 consolidates every post-R07 owner refinement into one sequence.

Required order:
1. BCM-M06-R08 — implement common rear-edge body tangency using the mandatory size-derived formula and preserve natural rear-corner behavior/gameplay contracts.
2. BCM-M07-R08 — move the unchanged To-Go asset to the viewport top; vertically center BEST/SCORE; preserve the owner-approved held drink.
3. Run the complete active M01-M07 regression.
4. STOP for independent ChatGPT audit.

M08 may not start until M06/M07 are independently accepted and the separate M05 strict-audit state is resolved or explicitly superseded.

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
