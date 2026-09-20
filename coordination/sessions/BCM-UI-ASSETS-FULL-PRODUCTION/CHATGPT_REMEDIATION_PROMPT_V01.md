# BCM-UI-ASSETS-FULL-PRODUCTION — Codex Remediation Prompt V01

Work only on:
`ui-assets`

Repository:
`https://github.com/Sekiph82/Beach-Cocktails-Merge`

Read first:
1. `ui-assets-tasks.md`
2. `CHATGPT_AUDIT_V01.md`
3. `CHATGPT_REMEDIATION_AUDIT_CRITERIA_V01.md`
4. original V01 prompt/criteria
5. full manifest
6. table geometry contract

## Goal

Remediate the independent audit's blocking visual-quality failure.

Do **not** redo valid isolation/geometry/logo work. Preserve:
- branch isolation;
- canonical owner logo;
- table geometry JSON;
- common table alpha silhouette;
- 720×1280 table canvas;
- front corners;
- centered ~64% rear edge;
- deferred runtime integration.

## Core defect to fix

The current production pass routes too many distinct final assets through generic programmer-art/template logic.

The following approach is no longer acceptable for final runtime assets:
- unknown asset -> generic badge containing its filename/stem;
- unrelated semantic icons -> same generic circle/person-like symbol;
- ten island icons -> same island composition with only palette/text changes;
- major screens -> same background recipe with only palette/variant changes;
- effects -> same ring/rays treatment for unrelated feedback types.

The remediation must replace those outputs with intentional, final-quality, semantically correct assets.

## Required work

### 1. Semantic icon family

Create dedicated recognizable pictograms for every semantic icon required by the locked remediation criteria.

Examples:
- settings = gear/cog
- map = folded map/compass
- info = information mark
- help = question/help symbol
- sound = speaker/waves
- music = musical note
- haptic = phone/vibration
- language = globe/language cue
- privacy = shield/lock
- accessibility = accessibility/person symbol
- share = share arrow/nodes
- friend = two-person/friend cue

Do not rely on text labels to explain them.

### 2. Boosters

Create distinct polished icons:
- +Time
- Hammer
- Upgrade
- Shuffle

They must read instantly at intended mobile size.

### 3. Ten island world icons

Redesign the island icons so every destination has a distinct silhouette/composition/motif corresponding to its identity.

Do not use one fixed island graphic with palette + text swaps.

### 4. Ten table material skins

Keep the exact existing shared table mask and geometry.

Improve the material rendering so each island expresses the required material identity beyond color:
- wood grain species/tone;
- bamboo/carving;
- yacht-deck striping/resin;
- woven/coconut;
- mahogany/amber;
- lacquer/neon;
- frost/crystal;
- basalt/lava;
- marble/gold;
- blackwood/mother-of-pearl/turquoise.

Nothing may alter the silhouette.

### 5. Major screen compositions

Create dedicated final compositions for:
- splash
- main menu
- world map
- shop
- daily reward
- island map family
- island gameplay background family

The world map must visually function as a world map. The shop must look like a shop interface/environment. Daily reward must read as reward/streak/calendar content.

### 6. Results/milestones/rewards

Upgrade any assets still reading as flat programmer art. Reusable panel bases may remain system-driven, but complete screens must have clear hierarchy and purpose.

### 7. Effects

Differentiate merge, order complete, VIP complete, timer warning, combo, win, and milestone effects. Keep them restrained.

### 8. Remove final fallback dependency

The generator may keep helpers, but final manifest outputs must not rely on a catch-all unknown-asset fallback.

Prefer explicit renderer mapping or explicit authored/generated source art for every semantic family.

If a mandatory asset truly cannot be produced to final quality with your available tools, report it as blocked rather than generating fake “complete” placeholder art.

## Evidence

Regenerate the existing four contact sheets and add:
- `assets/ui_assets/CONTACT_SHEET_SEMANTIC_ICONS.png`
- `assets/ui_assets/CONTACT_SHEET_MAJOR_SCREENS.png`

Regenerate manifest/dimensions metadata.

Add validation for:
- no final fallback assets;
- semantic icon uniqueness;
- island icon uniqueness;
- unchanged table mask;
- unchanged owner logo;
- unchanged protected/main scope.

## Scope restrictions

Do not edit:
- root `TASKS.md`
- `scripts/game_manager.gd`
- live gameplay scenes
- existing runtime asset folders
- main branch

Do not merge/rebase/cherry-pick main.

Push only `ui-assets`.

## Builder log

Create:
`coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/CODEX_REMEDIATION_LOG_V01.md`

Then push `ui-assets` and stop.

Do not self-audit and do not mark tracker tasks complete. ChatGPT will re-audit against the remediation criteria.
