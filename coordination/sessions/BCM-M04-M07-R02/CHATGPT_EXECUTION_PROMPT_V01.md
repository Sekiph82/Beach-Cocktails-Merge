# BCM-M04-M07-R02 — Single Execution Prompt for Strict Visual Remediation Sequence

Status: **ISSUED**

## Goal

Execute all currently required M04, M05, M06 and M07 remediations in **one Codex session**, while keeping each milestone's scope, commit and execution log separate.

Required order:

1. M04-R01
2. M05-R01
3. M06-R02
4. M07-R01 V02
5. STOP for independent ChatGPT audits

This orchestration supersedes the earlier `BCM-M04-M07-R01` execution prompt.

## Canonical repository/workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: 4.7.x

## Visual authority

Primary canonical owner master:

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

Explicit later owner directions:

- no dotted/persistent guide line;
- the current M07 canonical evidence is **closer to the desired master than the old M06 evidence** and must be treated as a useful positive starting point, not discarded;
- owner-annotated M07 corrections are canonicalized in `coordination/sessions/BCM-M07-R01/CHATGPT_REAUDIT_V02.md` and `CHATGPT_REMEDIATION_PROMPT_V02.md`.

Do not regress the project toward the old M06 prototype-style screenshot while repairing lower layers.

## Mandatory first step

Read and obey:

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- root `TASKS.md`

Then read **all** of the following before editing anything.

### M04-R01
- `coordination/sessions/BCM-M04-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

### M05-R01
- `coordination/sessions/BCM-M05-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M05-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M05-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

### M06-R02
- `coordination/sessions/BCM-M06-R02/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M06-R02/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M06-R02/CHATGPT_AUDIT_CRITERIA_V01.md`

### M07-R01 V02
- `coordination/sessions/BCM-M07-R01/CHATGPT_REAUDIT_V02.md`
- `coordination/sessions/BCM-M07-R01/CHATGPT_REMEDIATION_PROMPT_V02.md`
- `coordination/sessions/BCM-M07-R01/CHATGPT_AUDIT_CRITERIA_V02.md`

Also read the original M07 implementation/log so existing good work is preserved rather than recreated blindly.

## Safe synchronization

Run the normal AGENTS sync-first preflight and reconcile safely.

Never use:

- `reset --hard`;
- force push;
- automatic rebase;
- destructive checkout;
- silent stash.

Preserve all owner/local work. If safe reconciliation is impossible, stop and log the blocker.

## Phase 1 — M04-R01

Execute the existing M04 remediation exactly.

Required log:

`coordination/sessions/BCM-M04-R01/CODEX_LOG_V01.md`

Create and push one bounded M04 remediation commit.

Key outcomes:

- truthful machine-checkable asset validation;
- non-tautological inventory evidence;
- retained contact-sheet/manifest evidence for semantic inspection;
- explicit owner-master relationship;
- no destructive source PNG edits.

Do not self-audit. Continue only because this master prompt explicitly sequences all remediations.

## Phase 2 — M05-R01

Execute the existing M05 remediation using the strengthened M04 evidence.

Required log:

`coordination/sessions/BCM-M05-R01/CODEX_LOG_V01.md`

Create and push one bounded M05 remediation commit.

Key outcomes:

- real provenance for visible body measurements;
- L01-L12 sprite/collider/pivot evidence;
- touching-pair/contact evidence;
- evidence-backed final visual scale/collider mapping;
- preserve M01-M03 gameplay/economy.

Important owner refinement: final M05 presentation should support the M07 direction that **all gameplay cocktails become somewhat larger than the current pre-remediation M07 baseline**, without creating obvious collision mismatch. Do not force enlargement before evidence; use M05 overlay/contact evidence to choose the bounded final scale/radius mapping.

## Phase 3 — M06-R02

Execute the existing M06 remediation on the remediated M04/M05 state.

Required log:

`coordination/sessions/BCM-M06-R02/CODEX_LOG_V01.md`

Create and push one bounded M06 remediation commit.

Key outcomes:

- strengthen environment/table geometry against independent master/background landmarks;
- fix any real table-edge/rail/aspect problems;
- retain clean + overlay captures;
- preserve gameplay contracts.

### Critical correction to interpretation

The owner has now reviewed the M07 canonical evidence and considers its overall background/table/HUD composition **much closer to the master than the old M06 evidence**.

Therefore M06-R02 must **not** blindly redesign/revert the currently visible full-screen table/background composition. Use the M07 canonical render as evidence that the current production background integration can look directionally correct once HUD/art are present.

M06-R02 should repair measurable geometry/aspect/collider alignment defects and strengthen evidence, while preserving the successful long-table/full-screen tropical composition seen in M07 unless independent reference evidence proves a specific correction is required.

The owner additionally requests the danger threshold be moved lower. Coordinate this geometry change with final M07:

- actual `death_line_y` must move downward;
- visual danger line must follow it;
- preserve launch room below;
- rerun M03 danger/Game Over regression.

## Phase 4 — M07-R01 V02

Execute **only the V02** M07 remediation prompt/criteria. V01 remains historical context and must not override V02 owner directions.

Required log:

`coordination/sessions/BCM-M07-R01/CODEX_LOG_V02.md`

Create and push one bounded M07 remediation commit.

### Owner-required M07 outcomes

Preserve the current improved tropical M07 visual direction, then make these exact corrections:

1. Move Best Score and Score **higher** so they do not occupy tabletop accumulation space.
2. Keep logo → Best Score → Score order.
3. Give To-Go and NEXT more usable presentation space **downward** while keeping their upper anchoring.
4. Fix internal placement of all live content inside UI frames:
   - Score/Best values centered in their numeric insets;
   - To-Go target, level/name and reward each in dedicated non-overlapping content boxes;
   - reward stays inside the panel composition;
   - NEXT preview centered and fitted inside its inset;
   - progression icons centered in cells.
5. Make gameplay cocktails somewhat larger using the final evidence-backed M05 mapping.
6. Move danger line and actual `death_line_y` farther downward together.
7. Put the gold launch halo visually under the held glass, with the glass centered inside the ring footprint.
8. Replace the one-row 12-icon progression with an intentional **2x6** progression presentation:
   - top row = L07-L12 left-to-right;
   - bottom row = L01-L06 left-to-right;
   - larger cocktail icons;
   - no L13.
9. Preserve live/dynamic Score, Best, To-Go, NEXT and shared texture mapping.
10. No guide line.

### M07 evidence

Generate for 720x1280, 720x1440 and 800x1280:

- clean runtime screenshots;
- annotated outer HUD + inner content-box screenshots;
- master/runtime side-by-side comparison sheets;
- table/collider/danger/launch overlays where relevant;
- 2x6 progression close-up evidence.

Strengthen tests exactly as required by the V02 audit criteria.

## Required regression suite

At the appropriate phase and again after final M07 remediation, run:

- M01 gameplay contract;
- M02 physics/collision/merge/rapid launch;
- M03 economy/To-Go/persistence/danger/Game Over/restart;
- strengthened M04 validation;
- strengthened M05 validation;
- strengthened M06 validation;
- strengthened M07 V02 validation;
- Godot 4.7.x import/parse;
- main-scene startup;
- `git diff --check`.

Do not weaken old assertions to obtain green tests. Document every changed test assertion and why it is stricter/equivalent.

## Governance

- Do not edit root `TASKS.md`.
- Do not edit ChatGPT-owned `CHATGPT_REAUDIT`, `CHATGPT_REMEDIATION_PROMPT`, `CHATGPT_AUDIT_CRITERIA`, policy or audit files.
- Do not rewrite immutable historical Codex logs.
- Do not self-audit or assign `AUDITED_PASS`.
- Do not start M08+.
- Do not add guide line.
- Do not destructively alter owner-approved source PNGs merely to make tests pass.

## Final verification

After all four bounded commits:

```powershell
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
git rev-list --left-right --count HEAD...origin/main
git status --short --branch
git diff --check
git diff -- TASKS.md
```

Local/origin/remote `main` must match.

## Completion response

Return only:

- M04-R01 log URL + commit SHA + `AWAITING_AUDIT`;
- M05-R01 log URL + commit SHA + `AWAITING_AUDIT`;
- M06-R02 log URL + commit SHA + `AWAITING_AUDIT`;
- M07-R01 `CODEX_LOG_V02.md` URL + commit SHA + `AWAITING_AUDIT`;
- final synchronized main SHA;
- confirmation `TASKS.md` untouched;
- confirmation ChatGPT-owned files untouched;
- confirmation M08+ not started.

Then STOP.
