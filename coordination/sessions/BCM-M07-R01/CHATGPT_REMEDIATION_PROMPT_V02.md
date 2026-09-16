# BCM-M07-R01 — ChatGPT Remediation Prompt V02

Status: **ISSUED**

This V02 prompt supersedes `CHATGPT_REMEDIATION_PROMPT_V01.md` where they conflict.

## Goal

Refine the existing M07 composition. Do **not** discard the current M07 visual direction: the owner explicitly considers the M07 canonical evidence substantially closer to the master than the earlier M06 evidence.

Canonical owner visual truth:
`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

Explicit later override: no persistent/dotted guide line.

Owner visual review also supplied a directly annotated M07 screenshot. The requirements below are the textual canonicalization of those annotations and are authoritative for this remediation.

## Read first

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- root `TASKS.md`
- `coordination/sessions/BCM-M07-R01/CHATGPT_REAUDIT_V02.md`
- `coordination/sessions/BCM-M07-R01/CHATGPT_AUDIT_CRITERIA_V02.md`
- completed M04-R01, M05-R01 and M06-R02 remediation logs/state
- original M07 prompt/log/probe

## Preserve

Preserve these successful M07 foundations unless a direct owner requirement below needs bounded adjustment:

- tropical master-like HUD composition;
- canonical logo top-left;
- decorated canonical score/To-Go/NEXT art;
- live production Score, Best Score, To-Go target/reward and NEXT state;
- single shared `Drink.texture_for_level()` cocktail mapping;
- no guide line;
- existing gameplay/economy contracts.

## Owner-directed visual corrections

### 1. Move Best Score + Score higher

Move both score panels upward as a pair so they remain in the upper-left decorative/background region and do not occupy the tabletop accumulation region.

Required hierarchy remains:

- logo;
- Best Score immediately below logo;
- Score immediately below Best Score.

Do not move the logo down to compensate. Do not allow either score panel to cover likely drink accumulation space on the table.

### 2. Give To-Go and NEXT more vertical content room downward

Keep their top-region anchoring, but make the usable presentation extend farther downward as indicated by the owner annotations.

Do not simply shift both panels downward into the table. Instead adjust wrapper/content geometry or non-destructive runtime composition so the upper edge/hierarchy remains stable while the panel/content presentation has more room vertically.

Avoid destructive stretching that visibly deforms the artwork. If a panel must be composed from regions/runtime pieces to gain vertical room, do so non-destructively and document it.

### 3. Fix ALL live content placement inside UI assets

Treat every HUD artwork item as having an explicit **inner content box**. Define these boxes independently from the outer asset rectangle and retain their measurements in code/evidence.

#### Best Score / Score

- center numeric values inside the intended blank numeric inset;
- keep values clear of headings, crown/coin icons, flowers/leaves and wood borders;
- keep typography vertically centered and visually balanced;
- normalize Best/Score visual rhythm despite source width mismatch.

#### To-Go

- target cocktail centered in the intended visual content region;
- target drink must not collide with `Lx`/name text or panel header/decorations;
- level/name text placed in a dedicated readable area;
- reward placed clearly within the intended lower content region, not hanging awkwardly outside the panel;
- reward must remain live production data;
- avoid cocktail garnish/text overlap.

#### NEXT

- preview cocktail centered in the cream/inset viewing region;
- scale to fit without garnish clipping;
- do not place the preview on the wood frame/header;
- exactly one NEXT remains.

#### Progression

- every icon centered consistently in its cell;
- fit full visible drink/garnish inside the cell with bounded padding;
- no clipping into the frame or neighboring icons.

Add deterministic geometry checks for these inner content boxes. Do not merely check that nodes exist.

### 4. Make all gameplay cocktails somewhat larger

Increase production table/held drink visual size relative to current M07 evidence.

This change must be coordinated with the evidence-backed M05 sprite/collider remediation:

- do not create obvious sprite/collider mismatch;
- preserve relative progression readability;
- held drink and table drinks should use coherent final scale rules;
- rerun collision/merge/rapid-launch regressions.

Do not invent a fixed percentage merely to satisfy the prompt. Determine the bounded increase from the owner visual target plus M05 overlay/contact evidence and retain before/after scale data.

### 5. Move the danger line lower

Move the gameplay danger threshold farther downward, closer to the launch region, as explicitly annotated by the owner.

Requirements:

- actual `death_line_y` and canonical danger-line artwork move together;
- retain most of the tabletop above as usable accumulation area;
- keep enough room below the line for held launch interaction;
- rerun M03 danger timing/Game Over tests;
- regenerate M06/M07 geometry evidence after the new threshold.

### 6. Fix launch halo / held drink relationship

The gold launch halo must read as a floor marker **beneath** the held drink.

Required:

- halo z-order below held drink;
- held drink horizontally centered in the ring;
- held glass visually sits inside the ring footprint rather than above/offset from its center;
- halo scale is appropriate to the final larger drink scale;
- do not make the halo colliding;
- do not change launch physics merely for art.

### 7. Replace the single-row progression with a 2x6 progression presentation

Owner direction is explicit:

- **top row: L07, L08, L09, L10, L11, L12**;
- **bottom row: L01, L02, L03, L04, L05, L06**;
- exactly six icons in each row;
- icons should be visibly larger than in the current single-row strip;
- each row is left-to-right ascending;
- no L13.

Create a new runtime progression presentation/shape suited to two rows.

Do not destructively edit `assets/ui/progression_strip.png`. Allowed approaches include:

- non-destructive runtime composition using existing art regions;
- a new documented derived runtime asset created from existing approved art with provenance;
- a Godot-composed frame that preserves the tropical wooden/flower visual language.

The final result must look intentional, not like two raw duplicated 12-slot strips stacked on top of each other.

### 8. Preserve the improved M07 overall composition

Do not regress to the old M06 text/prototype HUD evidence. The current M07 canonical evidence is the starting point.

The remediation should look like a polished refinement of that screen.

## Required viewport evidence

Regenerate actual production captures for:

- 720x1280;
- 720x1440;
- 800x1280.

For each viewport retain:

- clean runtime screenshot;
- annotated layout screenshot showing outer HUD rectangles + inner content boxes;
- master/runtime side-by-side sheet;
- table/collider/danger/launch overlay where relevant;
- progression 2x6 close-up showing icon fit.

## Strengthen M07 tests

Extend `tests/m07_hud_composition_probe.gd` or equivalent so it checks independent expected/reference envelopes rather than only production-self-consistency.

At minimum test:

- all HUD outer rectangles on-screen;
- independent inner content rectangles for Best, Score, To-Go and NEXT;
- live content visible bounds remain inside those inner boxes;
- score stack is above the table accumulation envelope;
- To-Go/NEXT preserve upper anchoring and required downward usable extent;
- progression has exactly 2 rows x 6 columns in the required level order;
- icon visible bounds stay inside cells;
- final cocktail scale is larger than pre-remediation M07 baseline and matches remediated M05 accepted scale table;
- danger line is lower than pre-remediation baseline and matches actual `death_line_y`;
- launch halo center/held-body center relationship is within a defined tolerance;
- no legacy duplicate UI;
- no guide line.

Do not weaken old gameplay tests.

## Regression requirements

After final M07 remediation run:

- M01 gameplay contract;
- M02 physics/collision/merge/rapid-launch;
- M03 economy/To-Go/persistence/danger/Game Over/restart;
- remediated M04 validation;
- remediated M05 sprite/collider validation;
- remediated M06 table/environment validation;
- strengthened M07 HUD validation;
- Godot 4.7.x import/parse;
- main-scene startup;
- `git diff --check`.

## Out of scope

Do not implement:

- M08 effects;
- audio/haptics;
- menus/settings/export;
- guide line;
- unrelated gameplay redesign.

Do not edit `TASKS.md` or ChatGPT-owned audit/prompt/criteria files.

## Required log

Write only:

`coordination/sessions/BCM-M07-R01/CODEX_LOG_V02.md`

The log must include:

- exact before/after HUD rectangles;
- exact inner content boxes;
- before/after drink visual scales and relation to M05 collider data;
- before/after danger/launch geometry;
- 2x6 progression structure and level order;
- screenshot/evidence inventory and hashes;
- exact tests/exit codes;
- changed files;
- final commit/push/equality evidence;
- explicit source-asset preservation statement;
- explicit `TASKS.md` untouched statement.

Commit/push bounded M07 remediation, return `AWAITING_AUDIT`, then stop.
