# BCM-M21-001 + BCM-M21-006 — Owner F5 Remediation V05

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `OWNER_F5_RULING_V05.md`
5. `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V05.md`
6. V04 prompt/audit/log for preserved behavior.

## Root cause

The Main Menu is visible but PLAY / CONTINUE and SETTINGS do not respond.

Current source creates a layer-2 `CampaignResultCanvasLayer` with a full-screen Control root during CampaignNavigation setup.

ApplicationShell later sets:
`campaign_navigation.visible = false`

but CanvasLayer does not inherit that Control visibility, so the invisible result surface remains above Main Menu and blocks pointer input.

## Fix

Make result Canvas lifecycle explicit.

### Creation
- create result CanvasLayer hidden;
- root mouse filter = IGNORE;
- result feedback remains hidden.

### Show result
Immediately before actual WIN/LOSE presentation:
- show/enable result CanvasLayer;
- show result feedback;
- only the result feedback/card consumes input.

### Hide result
For all exits:
- hide result feedback;
- hide CanvasLayer;
- keep root input-ignored.

Apply on:
- Next Level;
- Retry;
- Island Map;
- World Map;
- Main Menu;
- CampaignNavigation hidden.

Connect/synchronize with CampaignNavigation `visibility_changed` so an invisible CampaignNavigation can never leave its CanvasLayer active.

## Mandatory real-input proof

Do not test Main Menu with direct method calls.

Dispatch real mouse events through the viewport and prove:

Main Menu → PLAY → World Map → Main Menu → SETTINGS → BACK TO MENU → PLAY → level → WIN result → Next Level → Main Menu → PLAY/SETTINGS still clickable.

Also preserve:
- real gameplay mouse/touch;
- no timer;
- V04 map/layout/table fixes;
- result lifecycle;
- persistence.

Godot red runtime errors = 0.

## Handoff

Do not edit root `TASKS.md`.

Create:
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V05.md`
- `CODEX_LOG_OWNER_F5_REMEDIATION_V05.md`

Finish exactly:
`AWAITING_OWNER_F5_ACCEPTANCE_V05`

Then stop. Owner F5 acceptance remains mandatory.
