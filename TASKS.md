# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the only authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M04-M07 STRICT REMEDIATION
- Current Sprint: BCM-M04-M07-R01
- Current Task: BCM-M04-M07-R01 — Execute strict remediation sequence for M04, M05, M06, and M07.
- Current Task Status: READY
- Next Task/Action: Codex must execute `coordination/sessions/BCM-M04-M07-R01/CHATGPT_EXECUTION_PROMPT_V01.md`, complete M04-R01 then M05-R01 then M06-R02 then M07-R01 with separate logs and commits, and STOP for independent ChatGPT audits before M08 opens.
- Required Actor: CODEX
- Tracking Repository: Sekiph82/Beach-Cocktails-Merge
- Tracking Branch: main

## Tasks

- [x] BCM-M00-001 — Repository synchronization and evidence baseline.
- [x] BCM-M00-002 — Repository hygiene, canonical structure, and Godot import baseline.
- [x] BCM-M01-001 — Recover and verify playable gameplay contract from synchronized v6.7 state.
- [x] BCM-M02-001 — Formalize physics, collision, merge, and rapid-launch regression suite.
- [x] BCM-M03-001 — Formalize scoring, combo, To-Go Orders, persistence, and game-over systems.
- [~] BCM-M04-M07-R01 — Coordinated strict remediation sequence for M04, M05, M06, and M07.
- [!] BCM-M04-001 — Import and validate the complete v7 visual asset library; reopened by strict re-audit.
- [!] BCM-M05-001 — Integrate L01-L12 cocktail sprites and level presentation; reopened by strict re-audit.
- [!] BCM-M06-001 — Integrate environment background, table composition, and responsive playfield geometry; owner visual rejection / strict re-audit.
- [!] BCM-M07-001 — Dynamic HUD integration; initial implementation completed but strict re-audit requires remediation on corrected M06 base.
- [ ] BCM-M08-001 — Integrate To-Go delivery animation and visual effects.
- [ ] BCM-M09-001 — Add gameplay feedback polish, audio, and optional haptics.
- [ ] BCM-M10-001 — Add menus, settings, onboarding, accessibility, save migration, and UX polish.
- [ ] BCM-M11-001 — Mobile layout, performance, export, device QA, and release readiness.
- [ ] BCM-M12-001 — Final regression, acceptance, packaging, documentation, and v1 release closure.

# Beach Cocktails Merge MASTER TASKS

Legend: `[x]` audited complete, `[~]` active, `[ ]` planned/pending, `[!]` reopened/blocked pending remediation.

## Governance

- Codex must never edit this file.
- Prompt and locked audit criteria are created before implementation/remediation.
- Codex logs are builder evidence, not acceptance proof.
- ChatGPT independently audits actual diff/source/tests/evidence against locked criteria.
- Any material visual criterion that is not independently inspectable remains `UNVERIFIED` and blocks `AUDITED_PASS`.
- Only ChatGPT updates this tracker after audit.
- Owner visual truth for current visual integration is `/b75ee426-9568-4ed6-b35e-140600a7c995.png`, subject to later explicit owner directions.
- The persistent dotted guide line in that historical master is intentionally excluded by later owner direction.

---

## M00-M03 — Audited gameplay/repository baseline

- [x] Repository synchronized and hygienic; Godot 4.7.x baseline established.
- [x] Launch speed 700 px/s.
- [x] Slide deceleration 180 px/s².
- [x] Immediate next-held generation and simultaneous moving drinks.
- [x] Settled-body wake/momentum transfer and no intentional +Y rebound.
- [x] Deferred merge processing, L12 hard cap and merge momentum.
- [x] Merge score table L2-L12 accepted.
- [x] Combo window 1.5 s; +0/+25/+50/+75/+100/+125% cap contract accepted.
- [x] To-Go targets L6-L12; rewards L6=1000, L7=1800, L8=3000, L9=5000, L10=8000, L11=12000, L12=18000.
- [x] Stored-drink To-Go semantics, persistence, Game Over and restart accepted.

---

## M04 — V7 asset library validation — REOPENED

Strict re-audit:
`coordination/sessions/BCM-M04-R01/CHATGPT_REAUDIT_V01.md`

Remediation prompt:
`coordination/sessions/BCM-M04-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`

Locked criteria:
`coordination/sessions/BCM-M04-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

Open findings include validator PASS semantics that do not enforce the full machine-checkable contract, tautological count evidence, unverified semantic visual claims, and missing retained owner-master-to-separated-asset comparison evidence.

---

## M05 — Cocktail sprite/collider integration — REOPENED

Strict re-audit:
`coordination/sessions/BCM-M05-R01/CHATGPT_REAUDIT_V01.md`

Remediation prompt:
`coordination/sessions/BCM-M05-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`

Locked criteria:
`coordination/sessions/BCM-M05-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

Open findings include unsupported body-measurement provenance, circular collider/scale checks, missing L01-L12 collider/pivot/contact overlays, unverified apparent-contact quality, and the already-recorded historical radius-log correction.

---

## M06 — Environment/table/responsive integration — REOPENED

Strict re-audit:
`coordination/sessions/BCM-M06-R02/CHATGPT_REAUDIT_V01.md`

Remediation prompt:
`coordination/sessions/BCM-M06-R02/CHATGPT_REMEDIATION_PROMPT_V01.md`

Locked criteria:
`coordination/sessions/BCM-M06-R02/CHATGPT_AUDIT_CRITERIA_V01.md`

Owner review explicitly rejected the previous M06 evidence composition. Open findings include missing independent screenshot inspection in the old audit, owner-master mismatch, destructive composition loss from current aspect adaptation, and weak/circular table-geometry validation.

---

## M07 — Dynamic HUD integration — REOPENED AFTER STRICT AUDIT

Strict re-audit:
`coordination/sessions/BCM-M07-R01/CHATGPT_REAUDIT_V01.md`

Remediation prompt:
`coordination/sessions/BCM-M07-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`

Locked criteria:
`coordination/sessions/BCM-M07-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

Initial M07 implementation usefully established live HUD architecture and reused the shared cocktail mapping, but cannot pass because:

- it intentionally preserves the visually rejected M06 base geometry/composition;
- locked M07 criterion 37 makes wrong M06 composition a direct blocker;
- required independent master-vs-runtime screenshot visual acceptance is not established;
- focused M07 tests mostly prove node/state self-consistency rather than master-relative composition;
- responsive/layout/slot-fit visual checks are incomplete.

M07-R01 must run after M04-R01, M05-R01 and M06-R02 in the coordinated remediation sequence.

---

## Active coordinated remediation

Master execution prompt:
`coordination/sessions/BCM-M04-M07-R01/CHATGPT_EXECUTION_PROMPT_V01.md`

Orchestration criteria:
`coordination/sessions/BCM-M04-M07-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

Required order:

1. M04-R01
2. M05-R01
3. M06-R02
4. M07-R01
5. STOP for independent ChatGPT audits

Each milestone must have a separate bounded commit and separate `CODEX_LOG_V01.md`. M08 may not start until the required visual remediations receive independent acceptance.

---

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
