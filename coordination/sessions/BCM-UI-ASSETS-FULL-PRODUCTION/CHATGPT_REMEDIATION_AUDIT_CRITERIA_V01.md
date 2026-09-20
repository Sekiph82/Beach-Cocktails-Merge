# BCM-UI-ASSETS-FULL-PRODUCTION — Remediation Audit Criteria V01

Status: LOCKED BEFORE REMEDIATION EXECUTION  
Audit owner: ChatGPT  
Required branch: `ui-assets`

This remediation does **not** reopen valid branch isolation, canonical logo ownership, or the accepted table geometry. It targets visual-quality and semantic-specificity failures found in `CHATGPT_AUDIT_V01.md`.

## R1. Preservation — blocking

R1.01. Work remains only on `ui-assets`.  
R1.02. Main is not modified.  
R1.03. Root `TASKS.md` is untouched.  
R1.04. Existing runtime asset folders remain untouched.  
R1.05. Canonical owner logo is unchanged except previously allowed technical cleanup.  
R1.06. `table_geometry_v1.json`, canonical table silhouette, front corners, rear width, rear Y, centerline, and playable-area master remain geometrically identical.  
R1.07. No live gameplay/runtime integration is performed.

## R2. No fallback/programmer art in final paths — blocking

R2.01. No final manifest runtime asset may be produced by a generic unknown-asset fallback that writes the asset stem/filename onto a badge.  
R2.02. No final semantic asset may be a placeholder rectangle/circle/pill with only a label standing in for the requested visual meaning.  
R2.03. The generator may retain reusable primitive helpers, but every semantic family must have an intentional renderer/source asset.  
R2.04. Any intentionally generic base panel/button may remain generic only when its purpose is truly to be a reusable base skin and its manifest name reflects that role.

## R3. Semantic icons — blocking

The following must be visually distinct and immediately recognizable at mobile size:

- home
- settings
- map
- info
- help
- sound
- music
- haptic
- language
- privacy
- accessibility
- share
- friend
- video/ad
- play
- pause
- restart
- lock
- check
- close
- back/next/previous

Booster icons must also clearly represent:
- time
- hammer
- upgrade
- shuffle

R3.01. No two unrelated semantic icons may share the same central pictogram.  
R3.02. Labels must not be required to understand the icon.

## R4. Island world icons — blocking

Each island world icon must have a distinct composition/silhouette/motif, not merely a color swap or text label.

Required identity cues:
- Sunny Cove: sunny beach/cove
- Tiki Island: tiki/bamboo
- Azure Bay: marina/yacht/blue bay
- Coconut Beach: coconut palms/natural beach
- Sunset Island: sunset silhouette/warm horizon
- Party Beach: neon/party cue
- Frozen Paradise: ice/snow tropical cue
- Volcano Bay: volcano/lava
- Billionaire Island: luxury resort/yacht/marble/gold cue
- Final Island: exotic premium endgame landmark

Text may supplement an icon but may not be the primary differentiator.

## R5. Island tables — blocking

All ten tables must preserve the exact accepted common alpha silhouette and geometry.

Each table must materially communicate its locked identity:
- Sunny Cove: bright teak + turquoise resin + white trim
- Tiki: dark teak + bamboo + carved tiki motif
- Azure: yacht-deck whites + aqua resin/marina treatment
- Coconut: pale natural wood + woven/coconut texture
- Sunset: mahogany + amber/coral reflective inlay
- Party: dark lacquer + controlled neon inlay
- Frozen: frosted/icy crystalline treatment
- Volcano: obsidian/basalt + restrained lava seams
- Billionaire: walnut + white marble + gold trim
- Final: exotic blackwood + mother-of-pearl/turquoise + premium gold

R5.01. Theme differences must go beyond palette swaps.
R5.02. Surface/inlay/trim/motif details must remain inside the shared mask and may not alter the edge.

## R6. Major screen backgrounds/compositions — blocking

At minimum these screen families must have dedicated visual composition rather than one shared gradient recipe with color changes:
- splash
- main menu
- world map
- shop
- daily reward
- island map background family
- island gameplay background family

R6.01. World map must read as a navigable tropical world/map, not a generic background.
R6.02. Shop must read as a shop/storefront UI environment.
R6.03. Daily reward must read as a reward/calendar/streak environment.
R6.04. Main menu must frame the canonical logo and primary actions appropriately.

## R7. UI family quality

R7.01. Reusable panels/buttons may share a design system, but hierarchy variants must be intentional.  
R7.02. Fixed-label buttons may contain baked labels when appropriate; mutable values must remain dynamic.  
R7.03. Reward/chest/star assets must be visually polished and distinguish small/big/premium states.  
R7.04. Result, milestone, VIP, and timer assets must be recognizable without relying on filenames.

## R8. Effects

R8.01. Merge/order/VIP/timer/combo/win/milestone effects must not all be the same ring/rays drawing.  
R8.02. Each effect family must have a distinct visual function while remaining restrained.

## R9. Evidence — blocking

Regenerate:
- `ASSET_MANIFEST.json`
- `ASSET_DIMENSIONS.csv`
- all four required contact sheets

Add:
- `CONTACT_SHEET_SEMANTIC_ICONS.png`
- `CONTACT_SHEET_MAJOR_SCREENS.png`

The tables contact sheet must continue to prove shared geometry.

## R10. Validation — blocking

In addition to prior validation:
- verify no final manifest asset uses the forbidden fallback path;
- generate duplicate/near-duplicate report for semantic icons and island icons;
- verify all ten tables still share the same alpha mask;
- verify owner logo checksum or pixel identity remains unchanged from pre-remediation branch version;
- verify main and protected paths remain unchanged.

## R11. Builder log — blocking

Create:
`coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/CODEX_REMEDIATION_LOG_V01.md`

Include:
- remediation prompt/criteria versions;
- start/end HEAD;
- files/families replaced;
- asset-generation method;
- explicit list of any retained generic assets and why they are legitimate reusable bases;
- validation output;
- duplicate/uniqueness report summary;
- contact-sheet paths;
- main/protected-scope proof.

## R12. Verdict

PASS requires:
- no C03-style placeholder/fallback final assets;
- semantic icons readable/distinct;
- ten island icons visually distinct;
- ten table materials genuinely distinct with identical geometry;
- major screen backgrounds compositionally distinct;
- evidence and validation complete;
- branch isolation preserved.

Anything less remains CHANGES_REQUIRED.
