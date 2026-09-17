# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner runtime screenshots/annotations, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M05 + M07 STRICT REMEDIATION
- Current Sprint: BCM-M07-R04
- Current Task: Focused owner-annotated M07 HUD/content-placement remediation.
- Current Task Status: READY
- Next Task/Action: Codex executes `coordination/sessions/BCM-M07-R04/CHATGPT_REMEDIATION_PROMPT_V01.md`, writes `coordination/sessions/BCM-M07-R04/CODEX_LOG_V01.md`, commits/pushes, then STOPS for independent ChatGPT audit.
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
- [x] BCM-M06-001 — Refreshed tropical background/table/responsive geometry accepted from owner runtime evidence plus M06-R04 tests.
- [~] BCM-M07-001 — Dynamic HUD integration active; refreshed asset family accepted, owner-annotated content-fit/launch-anchor remediation required.
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

## M04-R03 — Corrected audit result

Latest audit:
`coordination/sessions/BCM-M04-R03/CHATGPT_AUDIT_V03.md`

Verdict: **AUDITED_PASS**.

Owner supplied a direct runtime screenshot and explicitly confirmed the intended refreshed asset family is active in the Godot build. The prior attachment-vs-local SHA identity inference is superseded.

## M05-R02 — Still open

Audit:
`coordination/sessions/BCM-M05-R02/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Open concerns remain around independently evidenced body/collider measurements, shape classification, and contact-fit proof. M07-R04 must not retune M05 physics/collider behavior.

## M06-R04 — Corrected audit result

Latest audit:
`coordination/sessions/BCM-M06-R04/CHATGPT_AUDIT_V02.md`

Verdict: **AUDITED_PASS**.

Owner runtime screenshot confirms the intended refreshed tropical background/table composition is active. No owner annotation rejects table geometry. M06-R04 tests support current danger/launch/table baseline.

## M07-R03 — Corrected audit result

Latest audit:
`coordination/sessions/BCM-M07-R03/CHATGPT_AUDIT_V02.md`

Verdict: **CHANGES_REQUIRED**.

Accepted:
- refreshed BEST SCORE, SCORE, To-Go, NEXT and 2x6 progression artwork;
- current tropical/table composition;
- baked 2x6 progression, top L07-L12 / bottom L01-L06;
- current M06 danger/launch world geometry.

Owner-annotated fixes required:
- auto-fit BEST SCORE number inside its dark value rectangle;
- auto-fit SCORE number inside its dark value rectangle;
- fit To-Go cocktail/name/reward fully inside the baked board without overlap;
- fit each L01-L12 NEXT cocktail inside the cream safe window with no garnish overflow;
- align all held cocktail visible body bottoms to one common launch baseline/halo reference using visual-only per-level body-foot anchoring;
- preserve current progression strip and background/table geometry.

## Active M07-R04

Locked criteria:
`coordination/sessions/BCM-M07-R04/CHATGPT_AUDIT_CRITERIA_V01.md`

Remediation prompt:
`coordination/sessions/BCM-M07-R04/CHATGPT_REMEDIATION_PROMPT_V01.md`

Required log:
`coordination/sessions/BCM-M07-R04/CODEX_LOG_V01.md`

M08 may not start until M07-R04 is independently accepted and the separate M05 strict-audit state is resolved or explicitly superseded.

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
