# BCM-UI-ASSETS-FULL-PRODUCTION — Codex Remediation Prompt V02

Work only on branch `ui-assets`.

This is a **narrow corrective pass**. Do not redo the full visual asset library.

Read:
1. `ui-assets-tasks.md`
2. `CHATGPT_REMEDIATION_REAUDIT_V01.md`
3. `CHATGPT_REMEDIATION_AUDIT_CRITERIA_V02.md`
4. prior remediation criteria/prompt
5. full manifest

## Problem

The V01 remediation fixed the generic fallback problem, but direct manifest SHA evidence shows several opposite UI states are still identical files.

You must fix these state families:

### Stars
- small empty vs filled
- reward empty vs filled
- large empty vs filled

### Chests
- small closed/open
- big closed/open
- premium closed/open
- milestone closed/open

### Settings toggle
- OFF vs ON

### Island-map level nodes
- LOCKED vs UNLOCKED

### Global tabs
- ACTIVE vs INACTIVE

Then audit all other named UI state families for the same defect.

## Required behavior

Opposite states must not merely have different filenames. They must visibly communicate different meaning.

Examples:
- empty star = outline/hollow/desaturated; filled star = bright solid earned star;
- closed chest = lid closed; open chest = lid open with visible interior/reward light;
- toggle OFF = knob left, muted; ON = knob right, illuminated;
- locked node = lock/desaturated/inaccessible; unlocked node = bright/selectable;
- active tab = highlighted/raised/selected; inactive tab = subdued.

Preserve the existing tropical premium design system.

## Validation

Create:
`assets/ui_assets/STATEFUL_PAIR_REPORT.json`

Extend validation so it fails on identical/insufficiently differentiated opposite states.

Create:
`assets/ui_assets/CONTACT_SHEET_STATEFUL_UI.png`

Regenerate:
- `ASSET_MANIFEST.json`
- `ASSET_DIMENSIONS.csv`
- any affected existing contact sheets

## Preserve

Do not change:
- canonical owner logo;
- table geometry/mask;
- live gameplay/runtime code;
- existing runtime asset folders;
- main;
- root `TASKS.md`.

Do not merge/rebase/cherry-pick main.

Push only `ui-assets`.

## Log

Create:
`coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/CODEX_REMEDIATION_LOG_V02.md`

Record exact state-pair before/after SHA values and validation results.

Then stop. Do not self-audit and do not mark tasks complete.
