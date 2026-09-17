# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner runtime screenshots/annotations, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M05 + M06 + M07 STRICT REMEDIATION
- Current Sprint: BCM-M06-R07 + BCM-M07-R07
- Current Task: Reconcile the stale baseline M06 regression with the accepted R06 full-tabletop geometry, then reverify M07-R06 without redesigning it.
- Current Task Status: READY
- Next Task/Action: Codex executes `coordination/sessions/BCM-M06-R07-M07-R07/CHATGPT_EXECUTION_PROMPT_V01.md`, writes separate M06-R07 and M07-R07 logs/commits, runs the full no-exclusions M01-M07 suite, then STOPS for independent ChatGPT audit.
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
- [!] BCM-M06-001 — R06 production geometry is provisionally correct, but the legacy baseline M06 probe still fails against stale R04 geometry and blocks full regression closure.
- [!] BCM-M07-001 — R06 owner HUD refinements are provisionally correct, but final acceptance is blocked by the same unresolved full-regression failure.
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

## M06-R06 — Latest strict audit

Audit:
`coordination/sessions/BCM-M06-R06/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Accepted in production:
- five-sample source-space left/right tabletop edges;
- piecewise rail interpolation;
- segmented physical rails with outward wall offset;
- radius + epsilon center bounds;
- preserved danger/launch/gameplay constants.

Blocking issue:
`tests/m06_environment_geometry_probe.gd` remains an ordinary active M06 test and still fails because it asserts superseded M06-R04 two-endpoint geometry. Full M01-M07 regression therefore is not genuinely green.

## M07-R06 — Latest strict audit

Audit:
`coordination/sessions/BCM-M07-R06/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Accepted in production/source evidence:
- BEST remains left under logo;
- SCORE moved right beneath/near NEXT;
- fixed 20 px / 7-digit score contract;
- rendered score glyphs recentered in value windows;
- To-Go target + digits-only reward, reward moved into cream board;
- To-Go ropes top-attached;
- NEXT/progression contracts preserved;
- held visible glass/body X center and body-bottom Y aligned to launch halo/baseline.

Blocking issue:
M07 criterion requires a full green M01-M07 regression, which is impossible while the stale baseline M06 probe is knowingly failing.

## Active strict regression closure

Locked criteria:
`coordination/sessions/BCM-M06-R07/CHATGPT_AUDIT_CRITERIA_V01.md`

Master prompt:
`coordination/sessions/BCM-M06-R07-M07-R07/CHATGPT_EXECUTION_PROMPT_V01.md`

Required order:
1. BCM-M06-R07 — reconcile the baseline M06 probe/datasets with authoritative R06 piecewise geometry without weakening coverage.
2. BCM-M07-R07 — verification-only closure of current R06 HUD behavior unless a genuine regression is exposed.
3. Run the complete M01-M07 suite with no known failing test excluded.
4. STOP for independent ChatGPT audit.

M08 may not start until M06/M07 are independently accepted and the separate M05 strict-audit state is resolved or explicitly superseded.

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
