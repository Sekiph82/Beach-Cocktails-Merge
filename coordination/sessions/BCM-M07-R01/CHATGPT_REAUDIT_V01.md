# BCM-M07-R01 — ChatGPT Strict Re-Audit V01

Decision: **CHANGES_REQUIRED**

This re-audit evaluates M07 against the locked `coordination/sessions/BCM-M07-001/CHATGPT_AUDIT_CRITERIA_V01.md`. Codex PASS lines are builder evidence only.

## Audited against

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `coordination/sessions/BCM-M07-001/CHATGPT_PROMPT_V01.md`
- `coordination/sessions/BCM-M07-001/CHATGPT_AUDIT_CRITERIA_V01.md`
- `docs/codex-logs/BCM-M07_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- implementation commit `6d7b85e11520d985e1acb3c8eed83ed1686e8fb1`
- final M07 evidence-log history through `fb42850672f3f4e329ba9d3d3744242c159fad95`
- `scripts/game_manager.gd`
- `tests/m07_hud_composition_probe.gd`
- M04/M05/M06 strict re-audits
- owner master visual `/b75ee426-9568-4ed6-b35e-140600a7c995.png`

## Evidence classification

### Builder evidence

Codex reports:
- three production screenshots;
- canonical HUD asset use;
- live score/best/To-Go/Next data;
- exactly 12 progression icons;
- launch zone and danger-line integration;
- M01-M06 regressions passing;
- Godot 4.7.2 import/startup passing.

These remain E2 implementer evidence until independently verified.

### Independently verified source/test evidence

ChatGPT independently inspected:
- locked M07 criteria;
- M07 implementation diff/history;
- full M07 probe body;
- M07 log scope/evidence claims;
- existing strict M04-M06 re-audits.

## Findings

### F-M07-STRICT-001 — M07 is built on a visually rejected M06 composition — BLOCKER

Locked M07 criterion 37 explicitly states that if M06 is visually wrong against the owner master, that is a blocker to M07 acceptance and must be remediated rather than hidden by HUD placement.

M06 strict re-audit is `CHANGES_REQUIRED`, including explicit owner rejection of the previous environment/table composition. M07 intentionally preserves the M06 geometry unchanged (`table_top_y`, `table_bottom_y`, `death_line_y`, `launch_y`, rails and background mapping).

Therefore M07 cannot receive `AUDITED_PASS` in its current base state.

### F-M07-STRICT-002 — Required independent screenshot visual comparison is not established — MAJOR

The locked criteria require ChatGPT to inspect the actual committed production screenshot pixels and compare them directly with the owner master.

The GitHub connector exposes the binary screenshot files, dimensions, hashes and repository identity, but not the decoded image pixels in this audit environment. The builder's own local visual inspection cannot substitute for the required independent inspection.

Under criteria 2, 51 and 52, visually material items remain `UNVERIFIED` and block unconditional PASS.

The remediation must generate an audit package that is independently inspectable in the available workflow, not only binary PNG paths/hashes plus builder prose.

### F-M07-STRICT-003 — Focused HUD probe proves node/state consistency, not master-composition similarity — MAJOR

`tests/m07_hud_composition_probe.gd` usefully proves production nodes and dynamic state, but most visual checks are self-consistency checks:

- panel assets exist at expected node names;
- Best/Score wrapper sizes match each other;
- To-Go and Next wrapper rectangles do not overlap;
- progression textures equal `Drink.texture_for_level()`;
- launch zone uses the expected asset and follows the held drink;
- danger line Y equals production `death_line_y`.

It does not independently validate master-relative proportions, screen occupancy, visual rhythm, icon clipping, HUD/table balance, or table-edge relationship.

### F-M07-STRICT-004 — Responsive acceptance checks are materially incomplete — MAJOR

The probe runs all three viewports but does not assert all locked visual requirements for each aspect ratio. In particular it does not establish:

- important HUD elements are fully on-screen;
- progression icons visually fit authored slots;
- upper HUD does not materially cover the active accumulation region;
- no master-breaking composition drift occurs between 720x1280, 720x1440 and 800x1280;
- the table remains visually dominant in the intended way.

The existence of screenshots is not sufficient by itself.

### F-M07-STRICT-005 — Progression-strip semantics are only partially tested — MAJOR

The probe verifies 12 icon nodes and canonical textures, but does not prove that each icon is visually centered/fitted to its authored slot or that garnish/extents do not cause clipping/overlap at runtime.

This depends on the still-open M04/M05 evidence defects and requires retained inspectable strip evidence after remediation.

### F-M07-STRICT-006 — Dynamic HUD/state architecture is directionally sound — PASS / NOTE

Independent source review supports useful parts of the implementation:

- shared M05 texture mapping is reused rather than duplicated;
- score/best values are live labels;
- To-Go and Next are dynamic production consumers;
- one progression sequence L01-L12 is constructed;
- guide line remains excluded;
- M07 scope is bounded and no M08+ feature is intentionally introduced.

These should be preserved through remediation.

### F-M07-STRICT-007 — M01-M03 regression evidence remains valuable — PASS / NOTE

The logged regressions for gameplay/economy contracts are useful builder evidence and should be rerun after the visual-base remediations. They do not cure the M06/M07 visual blockers.

## Acceptance matrix summary

| Area | Re-audit result |
|---|---|
| Production HUD architecture exists | PASS |
| Shared cocktail mapping reused | PASS |
| Live Score/Best/To-Go/Next data | PASS by source + builder runtime evidence |
| Exactly 12 progression nodes | PASS by source/test |
| No guide line | PASS by source/test |
| M06 base visually accepted | **FAIL / BLOCKER** |
| Direct master-vs-production screenshot inspection | **UNVERIFIED** |
| Master visual hierarchy/proportions | **UNVERIFIED** |
| Table/HUD composition agreement | **FAIL dependency on M06** |
| Progression slot visual fit | **UNVERIFIED** |
| Three-aspect visual acceptance | **UNVERIFIED** |
| M01-M03 gameplay/economy preservation | PASS as builder regression evidence |
| Governance scope | PASS |

## Required remediation

M07 remediation must occur **after** M04-R01, M05-R01 and M06-R02 in the same orchestrated repair sequence and must:

1. rebase/reconcile HUD placement against the corrected M06 table/environment composition;
2. preserve live/dynamic production state and shared texture mapping;
3. create independently inspectable master-vs-runtime visual evidence;
4. prove all three portrait cases against the locked M07 criteria;
5. strengthen the M07 probe so visual geometry checks use independent expected/reference data where machine-checkable;
6. provide explicit progression-slot fit evidence;
7. rerun M01-M06 plus strengthened M07 validation;
8. write a new immutable M07 remediation log;
9. stop for independent audit.

## Final verdict

**CHANGES_REQUIRED**
