# BCM-M21-001-R04 — Independent GPT Audit of Owner Home Critique V03

Date: 2026-10-06

## VERDICT

**TECHNICAL_AUDITED_PASS / OWNER_HOME_VISUAL_APPROVAL_REQUIRED**

The latest owner-directed V03 Home corrections are technically consistent with the committed layout/test evidence and the requested navigation semantics.

This audit does NOT grant final visual acceptance. The owner must visually confirm the latest runtime Home.

## CONTRACT RECOVERY

Audited against:
- `OWNER_HOME_EXACT_TARGET_RULING_R04.md`
- `CHATGPT_HOME_EXACT_TARGET_CRITERIA_R04.md`
- later owner V02/V03 screenshot corrections communicated during execution;
- Codex V03 log;
- committed Home layout JSON;
- focused Home runtime probe.

## BRANCH / HEAD / DIFF SCOPE

Latest GitHub main:
`6f35b4579fe8a7c16cde3e6206753d84911a5e46`

Owner-critique V03 range:
`8b6d8595f04ab1e456f45f913082cb30965100d4..6f35b4579fe8a7c16cde3e6206753d84911a5e46`

Exactly two commits are present in this range.

Changed tracked scope is limited to:
- `HOME_TARGET_LAYOUT_R04.json`;
- focused Home probe;
- V03 evidence;
- V03 execution log.

No supplied Home PNG was modified in this range.
No production World Map, Island Map, gameplay, To-Go, economy, save, or root `TASKS.md` source was changed in this V03 correction range.

## ACCEPTANCE CRITERIA MATRIX

### Energy bar moved toward Level
**PASS**

Committed target rect:
- x = 229.0
- y = 15.0
- width = 181.5
- height = 81.0
- right edge = 410.5

This moves the Energy bar 18 reference pixels toward the Level bar while preserving the requested endpoint.

### Three plus icons align to owner marks
**PASS**

Committed geometric centers:
- Energy plus x = 393
- Coin plus x = 589
- Diamond plus x = 802

Each plus icon center-y equals its corresponding bar center-y.

The focused probe asserts these exact values.

### Continue text raised 7 px + 5 px
**PASS**

The final committed Continue rect is 12 reference pixels above its pre-V03 position.

The probe asserts the final center at:
`(467.5, 1224.857)`

This matches the owner's cumulative instruction: first +7 px upward, then +5 px more upward.

### Home is player welcome screen
**PASS at architecture/source level**

The Home remains the ApplicationShell welcome screen and the focused production-path probe starts from that shell.

### PLAY resumes current player level
**PASS**

The focused test explicitly:
1. selects Sunny Cove level 7;
2. refreshes Home values;
3. asserts `CONTINUE LEVEL 7`;
4. sends real mouse input to the visible PLAY control;
5. asserts Gameplay is entered with active level id 7.

This proves the PLAY behavior is campaign-state-driven rather than hardcoded to level 12.

### WORLD MAP opens production World Map
**PASS**

The focused test sends real mouse input to the visible WORLD MAP control and asserts:
- campaign view is active;
- navigation view is `VIEW_WORLD_MAP`;
- the production World Map instance is visible.

### SETTINGS remains functional
**PASS**

Real pointer input is used and the Settings screen is asserted visible.

### Root tracker ownership
**PASS**

Codex did not modify root `TASKS.md` in the audited V03 range.

## BUILDER CLAIMS VS REPOSITORY TRUTH

Builder claims about:
- Energy shift;
- plus-center alignment;
- Continue +12 px total upward adjustment;
- PLAY launching selected level 7;
- WORLD MAP visibility;
- passed Home/M20/asset/import checks

are consistent with the committed layout/test/log evidence inspected by the independent audit.

## FILE / SYMBOL EVIDENCE

`HOME_TARGET_LAYOUT_R04.json` is now the current coordinate authority for the owner-adjusted Home.

The V03 evidence report records:
- Energy bar correction;
- plus centers;
- Continue rect;
- real selected-level Play fixture;
- World Map visibility.

The focused probe asserts production art rectangles against the normalized layout authority at the 941×1672 reference viewport.

## REGRESSION EVIDENCE

Builder reports exit 0 for:
- focused R04 Home probe;
- M20 app shell;
- asset catalog rebuild;
- asset validator;
- Godot editor import/scan;
- git diff check.

The V05 World Map regression suite was not rerun, but real Home→World Map input was executed in the focused Home probe. No World Map implementation source changed in the V03 correction range.

## SECURITY / SAFETY REVIEW

No credential, external service, unsafe filesystem change, or new machine-specific path was introduced by the V03 correction commits.

## ARCHITECTURE CONSISTENCY

PASS.

No duplicate campaign authority was introduced. PLAY continues through the existing campaign/session system. WORLD MAP uses the production campaign navigation path.

## TRACKER / LOG / DOCUMENTATION TRUTHFULNESS

PASS.

The builder explicitly states:
- no owner acceptance was self-assigned;
- full original TARGET pixel parity remains unverified;
- `TASKS.md` was untouched.

## FINAL REPOSITORY STATE

GitHub main is:
`6f35b4579fe8a7c16cde3e6206753d84911a5e46`

The builder reports local/origin/remote synchronization after push.

A pre-existing owner-local `project.godot` modification remains outside this R04 Home visual scope. Its reconciliation remains deferred to the previously identified post-Home technical closure.

## OPEN CROSS-MILESTONE FINDINGS

Still deferred after Home approval:
1. M07 current regression authority reconciliation;
2. M08 post-PASS Windows crash closure;
3. `project.godot` canonical clean-state reconciliation.

These do not invalidate the V03 Home correction audit because R04 explicitly deferred them.

## DEFECTS BY SEVERITY

BLOCKER: none found in the V03 Home correction source/test scope.
MAJOR: none found.
MINOR: none found.
NOTE: full-screen pixel identity against the older original TARGET is still not established because later owner screenshot corrections supersede portions of that original layout.

## UNVERIFIED ITEMS

The private GitHub binary evidence could not be independently pixel-rendered inside this audit environment.

Therefore the final visual question remains owner-native:
- do the latest Energy/plus/Continue positions visually match the owner's annotated intent;
- is this now the desired permanent welcome-screen look?

## REGRESSION RISK

LOW for the V03 correction itself.

## AUDIT CONFIDENCE

HIGH for layout/source/navigation semantics.
MEDIUM for final rendered visual acceptance until owner review.

## FINAL VERDICT

**TECHNICAL_AUDITED_PASS / OWNER_HOME_VISUAL_APPROVAL_REQUIRED**

## REQUIRED NEXT ACTION

Owner reviews the latest production Home.

If accepted, return:

`OWNER_HOME_EXACT_TARGET_ACCEPTED_R04`

If not accepted, return:

`OWNER_HOME_EXACT_TARGET_CHANGES_REQUIRED_R04`

with the exact visual changes required.
