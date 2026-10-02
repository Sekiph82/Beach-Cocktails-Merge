# BCM-M21-001 + BCM-M21-006 — Owner F5 Remediation V07

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repo: `Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

## Read first
1. AGENTS.md
2. root TASKS.md
3. coordination/AUDIT_POLICY.md
4. OWNER_F5_RULING_V07.md
5. CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07.md
6. V06 audit/log only as historical evidence.

## Task 1 — redesign Sunny Cove gameplay image from scratch

Do not tweak or shift V06.

Start from a blank 720×1280 canvas and author a new single flattened gameplay image:
`assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface_v07.png`

You may reuse approved art as source material/reference, but placement is new.

Design gameplay-first:
- reserve a large unobstructed table region first;
- reserve bottom launch/held-drink region;
- keep HUD clear;
- then compose environment/decor around those constraints.

The final runtime Sunny Cove static presentation must be exactly one image.

## Task 2 — freeze art, then calibrate physics

Hash/freeze gameplay_surface_v07.png.

Only then trace its visible tabletop and create the final Sunny Cove playable_geometry.

Physics source of truth:
- playable polygon;
- spawn_y;
- launch_y;
- death_y.

No old table Y offset.
No V06 geometry as authority.
No independent runtime table/decor layers.

## Task 3 — real visual loop, not test-only acceptance

After implementation, open Godot GUI and use production navigation.

You MUST self-evaluate SC-01..SC-08 from OWNER_F5_RULING_V07.md.

Take a dedicated clean 720×1280 screenshot for each meaningful state.

If any answer is not clearly PASS:
- fix it;
- rerun;
- recapture;
- reevaluate.

Do not hand off with uncertainty.

## Task 4 — World Map markers

Open actual runtime World Map.

Visually evaluate WM-01..WM-10, one island at a time.

Coordinates/report are not enough.

Move markers until each ring/label/lock/click center visibly sits on its intended baked island.

Capture final full map plus close crops where useful.

Repeat until all ten builder answers are PASS.

## Task 5 — regression

Preserve:
- accepted Sunny Cove Island Map layout;
- no connector lines;
- PLAY/SETTINGS/BACK;
- post-result input;
- result lifecycle;
- no timer;
- mouse/touch 10/10;
- Pause/Resume;
- persistence.

Runtime errors = 0.

## Mandatory self-audit artifacts

Create:
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/BUILDER_SELF_VISUAL_AUDIT_V07.md`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/BUILDER_SELF_VISUAL_AUDIT_V07.json`

For every SC and WM question record:
- PASS/FAIL;
- screenshot;
- visual reason;
- iteration.

All must be PASS before commit/push/handoff.

## Handoff

Do not edit root TASKS.md.

Create:
- OWNER_F5_ACCEPTANCE_CHECKLIST_V07.md
- CODEX_LOG_OWNER_F5_REMEDIATION_V07.md

Finish exactly:
`AWAITING_OWNER_F5_ACCEPTANCE_V07`
