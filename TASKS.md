# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner runtime screenshots/annotations, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M05 + M06 + M07 STRICT REMEDIATION
- Current Sprint: BCM-R10-RUNTIME-PHYSICS-CLOSURE
- Current Task: Close the two R09 blockers: stale physical TopRail still using the old rear boundary, and unresolved desktop/F5 uncommanded firing/score behavior.
- Current Task Status: READY
- Next Task/Action: Codex executes `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V01.md`, writes the R10 log/commit, runs full active regression, then STOPS for independent ChatGPT audit.
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
- [~] BCM-M06-001 — R09 rear formula/boundary improved, but physical TopRail still uses stale y=472 geometry and blocks full rear contact.
- [~] BCM-M07-001 — R08 HUD/held changes remain preserved; desktop runtime still has unresolved uncommanded-fire/score behavior that must be closed before acceptance.
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

## BCM-R09-RUNTIME-RECOVERY — Strict audit

Audit:
`coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Accepted:
- dirty `project.godot` inspected and found not to launch probes;
- deterministic headless 30.5 s no-input run stayed idle;
- candidate real rear boundary independently measured at source y=457;
- `rear_table_y` / clamp now use the size-derived formula against y=457.

Blocking issues:
1. `_build_walls()` still constructs the physical `TopRail` from the old side-polyline first points at source y=472, so the RigidBody can collide before reaching the new rear clamp target.
2. R09's own Windows-display exploration generated non-held drinks from input-like events. Headless no-input PASS does not close the owner's actual desktop/F5 symptom.

## Active R10 closure

Locked criteria:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V01.md`

Required closure:
1. Physical TopRail inward face, clamp and rear solver all use the same independently measured y=457 rear boundary.
2. Real moving-body collision evidence proves L01/L06/L12 can physically reach rear tangency.
3. Reproduce the Windows/display-backed idle path and identify any unintended input event sequence reaching `ShotController`.
4. Prevent held-to-fired transitions without intentional owner input while preserving real mouse/touch shooting and rapid launch.
5. Preserve legitimate stored To-Go auto-fulfillment and all accepted HUD/held behavior.
6. Full active regression then STOP for independent audit.

M08 may not start until M06/M07 are independently accepted and the separate M05 strict-audit state is resolved or explicitly superseded.

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
