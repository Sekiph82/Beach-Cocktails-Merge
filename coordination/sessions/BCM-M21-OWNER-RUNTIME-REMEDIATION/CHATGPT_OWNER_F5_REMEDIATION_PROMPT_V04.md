# BCM-M21-001 + BCM-M21-004 + BCM-M21-006 — Owner F5 Remediation V04

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

## Read first
1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `OWNER_F5_RULING_V04.md`
5. `OWNER_F5_AUDIT_V04.md`
6. `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V04.md`
7. previous V03 log/audit for historical context only.

## One bounded V04 job

### 1. World Map markers: calibrate to the actual baked island images

The owner confirms Sunny Cove is lower-left but rejects the current marker-to-island alignment for the full map.

Use the V04 owner seed centers, refine them visually/pixel-wise, and persist the final calibrated centers in campaign data.

Do not:
- show duplicate island thumbnails;
- restore yellow route lines.

All marker UI/state/click geometry must share one exact center.

### 2. Replace Sunny Cove zigzag with owner landmark pages

Owner supplied ten target landmark centers.

Implement a data-driven 10-slot layout:
- L1-L10 = slots 1-10;
- L11-L20 = same slots on page 2;
- ...
- L91-L100 = page 10.

Repeat the Sunny Cove island-map background per page so nodes remain attached to landmarks while navigating 100 levels.

Remove connector lines completely for Sunny Cove.

Do not alter progression state semantics.

### 3. Move the entire Sunny Cove table/playable system down exactly 150 px

Owner accepts the table design, rejects the vertical placement.

Translate together:
- shadow;
- wooden table;
- edge overlay;
- launch indicator/line;
- R11 table/rail geometry;
- launch/death Y.

Background and HUD stay fixed.

This is a rigid translation only. No scale or rail-shape retuning.

### 4. Remove remaining launch/decor foreground

Stop rendering `launch_zone.png` as a full-screen art layer.

Keep logical launch mechanics. Draw a simple launch line programmatically if required.

Keep decor_left/right/back absent.

Produce a visible-layer isolation report. If unwanted foreground still exists, identify the exact source layer and remove only that foreground presentation. Preserve canonical original PNGs.

### 5. Fix the broken WIN/LOSE result lifecycle

The owner debugger proved the current result surface creation is broken.

Current failure:
- `get_tree().root.add_child(_result_canvas_layer)` runs while root is busy setting up children;
- overlay never becomes ready;
- `CampaignFeedbackOverlay._show()` writes to null labels.

Fix the architecture, not just the symptom.

Recommended direction:
- own the result CanvasLayer under `CampaignNavigationController` or predeclare it in the campaign scene;
- never synchronously add to SceneTree root during setup;
- make creation idempotent;
- defer presentation until overlay `is_node_ready()`;
- retain pending terminal result if it arrives before ready;
- make `CampaignFeedbackOverlay` shell construction defensively idempotent.

Mandatory production flow:
WIN → result visible → Next Level → WIN → Island Map → LOSE → Retry.

Godot runtime error count for this flow must be **0 red errors**.

### 6. Preserve all current PASS behavior

Still required:
- 800×1422 debug view;
- real mouse/touch gameplay;
- no timer/TIME UP;
- Pause/Resume;
- restart persistence;
- retired +Time.

## Evidence and stop

Generate all V04 captures/reports required by the locked criteria.

Create:
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V04.md`
- `CODEX_LOG_OWNER_F5_REMEDIATION_V04.md`

Do not edit root `TASKS.md`.

Finish exactly:
`AWAITING_OWNER_F5_ACCEPTANCE_V04`

Then stop. Owner manual F5 review remains mandatory.
