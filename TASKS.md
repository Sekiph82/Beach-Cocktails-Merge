# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the only authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M07
- Current Sprint: M07-DYNAMIC-HUD-INTEGRATION
- Current Task: BCM-M07-001 — Integrate logo, score panels, To-Go panel, Next panel, progression strip, launch zone, and danger line.
- Current Task Status: ACTIVE
- Next Task/Action: Codex may complete the already-issued M07 session and push its immutable log. After the M07 log arrives, ChatGPT will strictly audit M07 together with the reopened M04, M05, and M06 findings and then issue the coordinated remediation sequence for all required fixes.
- Required Actor: CODEX
- Tracking Repository: Sekiph82/Beach-Cocktails-Merge
- Tracking Branch: main

## Tasks

- [x] BCM-M00-001 — Repository synchronization and evidence baseline.
- [x] BCM-M00-002 — Repository hygiene, canonical structure, and Godot import baseline.
- [x] BCM-M01-001 — Recover and verify playable gameplay contract from synchronized v6.7 state.
- [x] BCM-M02-001 — Formalize physics, collision, merge, and rapid-launch regression suite.
- [x] BCM-M03-001 — Formalize scoring, combo, To-Go Orders, persistence, and game-over systems.
- [!] BCM-M04-001 — Import and validate the complete v7 visual asset library; reopened by strict re-audit, remediation pending.
- [!] BCM-M05-001 — Integrate L01-L12 cocktail sprites and level presentation; reopened by strict re-audit, remediation pending.
- [!] BCM-M06-001 — Integrate environment background, table composition, and responsive playfield geometry; owner visual rejection / strict re-audit, remediation pending.
- [~] BCM-M07-001 — Dynamic HUD integration; current Codex implementation may complete before coordinated M04-M07 remediation.
- [ ] BCM-M04-M07-R01 — Coordinated remediation sequence to be issued after M07 strict audit.
- [ ] BCM-M08-001 — Integrate To-Go delivery animation and visual effects.
- [ ] BCM-M09-001 — Add gameplay feedback polish, audio, and optional haptics.
- [ ] BCM-M10-001 — Add menus, settings, onboarding, accessibility, save migration, and UX polish.
- [ ] BCM-M11-001 — Mobile layout, performance, export, device QA, and release readiness.
- [ ] BCM-M12-001 — Final regression, acceptance, packaging, documentation, and v1 release closure.

# Beach Cocktails Merge MASTER TASKS

Legend: `[x]` audited complete, `[~]` active, `[ ]` planned/pending, `[!]` reopened/blocked pending remediation.

## Governance

- Codex must never edit this file.
- Prompt and locked audit criteria are created before implementation.
- Codex logs are builder evidence, not acceptance proof.
- ChatGPT independently audits actual diff/source/tests/evidence against the locked criteria.
- Any material visual criterion that is not independently inspectable remains `UNVERIFIED` and blocks `AUDITED_PASS`.
- Only ChatGPT updates this tracker after audit.
- Owner visual truth for the current visual integration is `/b75ee426-9568-4ed6-b35e-140600a7c995.png`, subject to later explicit owner directions. The persistent dotted guide line in that old master is intentionally excluded by later owner direction.
- M07 is intentionally allowed to finish its already-issued implementation pass before the coordinated M04-M07 remediation. Its completion claim does not supersede the reopened M04-M06 findings.

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

Open findings include:

- validator PASS semantics do not enforce the machine-checkable alpha/visual contract;
- asset-count reporting is partly tautological;
- exactly-12 progression slots and semantic straw/garnish/UI/background claims rely on builder visual assertions;
- owner-master-to-separated-asset relationship was not retained as explicit audit evidence.

M04-R01 remains pending and will be included in the coordinated remediation after the M07 audit.

---

## M05 — Cocktail sprite/collider integration — REOPENED

Strict re-audit:
`coordination/sessions/BCM-M05-R01/CHATGPT_REAUDIT_V01.md`

Remediation prompt:
`coordination/sessions/BCM-M05-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`

Locked criteria:
`coordination/sessions/BCM-M05-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

Open findings include:

- body-width/body-center measurement provenance is unsupported by the original M04 evidence;
- collider/scale test is primarily self-consistency against the same production constants;
- no retained per-level runtime collider/pivot overlay evidence;
- no strong evidence that touching drinks avoid invisible gaps or extreme overlap;
- historical pre-M05 JSON radii in the immutable old log were incorrect; repository truth was `14,21,29,38,48,59,71,84,98,113,129,146`.

M05-R01 remains pending and will be included in the coordinated remediation after the M07 audit.

---

## M06 — Environment/table/responsive integration — REOPENED

Strict re-audit:
`coordination/sessions/BCM-M06-R02/CHATGPT_REAUDIT_V01.md`

Remediation prompt:
`coordination/sessions/BCM-M06-R02/CHATGPT_REMEDIATION_PROMPT_V01.md`

Locked criteria:
`coordination/sessions/BCM-M06-R02/CHATGPT_AUDIT_CRITERIA_V01.md`

Owner review explicitly rejected the previous M06 evidence composition as not matching the planned master closely enough.

Open findings include:

- previous audit passed without independent screenshot-pixel inspection;
- production/test geometry was not tied directly to the owner master;
- 1024x1536 master composition was adapted through center-cover into 9:16/taller ratios with material side cropping;
- taller case maps a near table landmark outside the viewport;
- responsive and collider-inside-table probes are too weak/circular to prove pixel-level visual alignment.

M06-R02 remains pending and will be included in the coordinated remediation after the M07 audit.

---

## M07 — Dynamic HUD integration — ACTIVE

Locked M07 session:
`coordination/sessions/BCM-M07-001/`

Codex may complete the already-issued M07 implementation and write its M07 log.

M07 will integrate:

- top-left Beach Cocktails Merge logo;
- Best Score directly below logo;
- Score directly below Best Score;
- upper-middle To-Go Orders with live target/reward;
- exactly one upper-right NEXT panel with the true next drink;
- 12-slot L01-L12 progression strip;
- launch-zone gold oval under held cocktail;
- canonical danger-line visual at the gameplay threshold;
- no persistent guide line.

When the M07 log arrives, ChatGPT will perform a strict M07 audit using the locked criteria and direct comparison to the owner master. The resulting M07 findings will then be combined with the already-open M04, M05, and M06 findings into one coordinated M04-M07 remediation execution prompt, while keeping separate milestone remediation logs and commits.

---

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
