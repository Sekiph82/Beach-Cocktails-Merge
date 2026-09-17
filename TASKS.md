# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner visual review, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M04-M07 STRICT REMEDIATION
- Current Sprint: BCM-M04-M07-R03-AUDIT
- Current Task: Independent strict audit of M04-R02, M05-R02, M06-R03 and M07-R02.
- Current Task Status: CHANGES_REQUIRED
- Next Task/Action: Prepare and execute a bounded follow-up remediation for the unresolved strict-audit findings below. M08 remains blocked.
- Required Actor: CHATGPT -> CODEX after new remediation prompt is issued.
- Tracking Repository: Sekiph82/Beach-Cocktails-Merge
- Tracking Branch: main

## Tasks

- [x] BCM-M00-001 — Repository synchronization and evidence baseline.
- [x] BCM-M00-002 — Repository hygiene, canonical structure, and Godot import baseline.
- [x] BCM-M01-001 — Recover and verify playable gameplay contract from synchronized v6.7 state.
- [x] BCM-M02-001 — Formalize physics, collision, merge, and rapid-launch regression suite.
- [x] BCM-M03-001 — Formalize scoring, combo, To-Go Orders, persistence, and game-over systems.
- [!] BCM-M04-001 — V7 visual asset library validation: M04-R02 machine truth improved; strict visual evidence remains independently unverified.
- [!] BCM-M05-001 — Cocktail sprite/collider integration: M05-R02 independent-evidence design still fails strict audit.
- [!] BCM-M06-001 — Environment/table/responsive geometry: M06-R03 render-space evidence still fails strict independence/visual-verification bar.
- [!] BCM-M07-001 — Dynamic HUD integration: M07-R02 visible-bound machinery improved, but progression reference boxes remain production-derived and final pixels remain independently unverified.
- [ ] BCM-M08-001 — Integrate To-Go delivery animation and visual effects.
- [ ] BCM-M09-001 — Add gameplay feedback polish, audio, and optional haptics.
- [ ] BCM-M10-001 — Add menus, settings, onboarding, accessibility, save migration, and UX polish.
- [ ] BCM-M11-001 — Mobile layout, performance, export, device QA, and release readiness.
- [ ] BCM-M12-001 — Final regression, acceptance, packaging, documentation, and v1 release closure.

Legend: `[x]` audited complete, `[!]` reopened / changes required, `[ ]` planned.

## Governance

- Codex must never edit this file.
- Prompt and locked audit criteria are created before implementation/remediation.
- Codex logs are builder evidence, not acceptance proof.
- ChatGPT independently audits actual diff/source/tests/evidence against locked criteria.
- Owner visual annotations are authoritative when later than earlier audit interpretations.
- Any material visual criterion that is not independently inspectable remains `UNVERIFIED` and blocks `AUDITED_PASS`.
- Only ChatGPT updates this tracker after audit.
- Owner visual truth is `/b75ee426-9568-4ed6-b35e-140600a7c995.png`, subject to later explicit owner directions.
- The historical dotted guide line is explicitly excluded by later owner direction.
- Preserve the improved M07 tropical composition; do not regress to old prototype-style M06 presentation.

## M00-M03 — Audited gameplay baseline

- [x] Launch speed 700 px/s.
- [x] Slide deceleration 180 px/s².
- [x] Immediate next-held generation and simultaneous moving drinks.
- [x] Settled-body wake/momentum transfer and no intentional +Y rebound.
- [x] Deferred merge processing, L12 hard cap and merge momentum.
- [x] Merge score/combo/To-Go reward contracts accepted.
- [x] Persistence, Game Over and restart accepted.

## M04-R02 — Strict audit result

Audit:
`coordination/sessions/BCM-M04-R02/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Resolved: effects exact-set truth is now 4 effects / 25 total approved-retained PNGs, with actual-vs-expected repository set validation.

Open: material semantic PNG evidence is still not independently pixel-inspected under the locked visual-verification rule.

## M05-R02 — Strict audit result

Audit:
`coordination/sessions/BCM-M05-R02/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Open blockers:

- supposedly independent body boxes/center offsets/radii reproduce production values exactly;
- shape-diversity classification is factually wrong for multiple levels;
- zero-gap touching-pair result is structurally produced by duplicated body/radius targets rather than convincingly independent contact evidence;
- final collider/pivot/contact pixels remain independently unverified.

## M06-R03 — Strict audit result

Audit:
`coordination/sessions/BCM-M06-R03/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Open blockers:

- screenshot-space landmark values are rounded near-copies of the production/source-transform coordinates, so independence provenance is not convincing;
- final clean/overlay pixels remain independently unverified under the locked M06 visual rule.

## M07-R02 — Strict audit result

Audit:
`coordination/sessions/BCM-M07-R02/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Resolved/improved:

- text visible bounds use real font metrics/shadows;
- cocktail bounds use imported alpha used-rect transformed by runtime scale/pivot;
- To-Go/NEXT/progression have hard overflow/overlap checks;
- improved tropical composition and owner-directed M07 structure are preserved.

Open blockers:

- progression 'independent' cells use the same six-column and 0.08/0.54/0.34 row formulas as production, so the reference is not independent;
- final clean/visible-bounds/master/progression evidence pixels remain independently unverified.

## R03 execution history

Master prompt:
`coordination/sessions/BCM-M04-M07-R03/CHATGPT_EXECUTION_PROMPT_V01.md`

Builder logs:

- `coordination/sessions/BCM-M04-R02/CODEX_LOG_V01.md`
- `coordination/sessions/BCM-M05-R02/CODEX_LOG_V01.md`
- `coordination/sessions/BCM-M06-R03/CODEX_LOG_V01.md`
- `coordination/sessions/BCM-M07-R02/CODEX_LOG_V01.md`

Implementation commits:

- M04-R02 `ae59e48b57e71109512427a15c14a5cef5337762`
- M05-R02 `5c9f4d6c437b28d28920329b80dd12685eb5a735`
- M06-R03 `b1445fe1ea3d9b94a1e29d60ab7765db1ff1cc0e`
- M07-R02 `260fe0317b3eb50962d76515e1277959de3b5651`

M08 may not start until the unresolved M04-M07 strict-audit findings receive independent acceptance.

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
