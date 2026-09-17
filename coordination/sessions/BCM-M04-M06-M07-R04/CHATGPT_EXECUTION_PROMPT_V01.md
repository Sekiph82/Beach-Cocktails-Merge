# BCM-M04-M06-M07-R04 — Owner Canonical Asset Replacement Master Prompt V01

Status: ISSUED

## Goal
Replace the currently used canonical background/HUD assets with the six NEWER owner-supplied PNGs listed below, then rebuild M06 geometry and M07 layout around the actual new artwork.

These newer owner files supersede older versions of the same canonical assets and override any earlier visual interpretation where they conflict.

Execute in one Codex session but keep the three affected remediation phases isolated:

1. M04-R03 — exact owner-asset replacement and asset-contract refresh
2. M06-R04 — remeasure/rebuild table geometry for the new background
3. M07-R03 — rebuild dynamic HUD layout for the new panels and baked 2x6 progression artwork
4. Run final regressions
5. Push all intended commits and STOP for independent ChatGPT audit

Do not start M08+.
Do not self-audit or assign AUDITED_PASS.

## Canonical repository/workspace
- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot: 4.7.x

## Mandatory governance
Before editing anything, read:
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- root `TASKS.md`
- `coordination/sessions/BCM-M04-R03/CHATGPT_AUDIT_CRITERIA_V01.md`
- `coordination/sessions/BCM-M06-R04/CHATGPT_AUDIT_CRITERIA_V01.md`
- `coordination/sessions/BCM-M07-R03/CHATGPT_AUDIT_CRITERIA_V01.md`

Then run the governed sync preflight from `AGENTS.md`.

Codex MUST NOT edit:
- root `TASKS.md`
- ChatGPT-owned audit/prompt/criteria/policy files
- historical Codex logs

## Exact newer owner files
Locate the following owner-provided files on the user's Windows machine. Search the repository root, `%USERPROFILE%\Downloads`, `%USERPROFILE%\Desktop`, and reasonable immediate subfolders. Verify by SHA-256 BEFORE using a file.

| Owner source file | Dimensions | SHA-256 | Replace canonical target |
|---|---:|---|---|
| `game_board_background 2.png` | 1024x1536 | `5d3d795935e2a69175e048c354ab4ce82ef13627cd27a8894f0605f78f0559b3` | `assets/environment/game_board_background.png` |
| `panel_best_score 5(1).png` | 1671x941 | `62a237642c2007d538c12653e7fa60c7e4208291b35d4070df7f55e87d12c988` | `assets/ui/panel_best_score.png` |
| `panel_score 2(2).png` | 1672x941 | `8b540fbad12d1d4c76ff4af935ee48d39cee5c33d2a25dd0e1a077b3e67a56ec` | `assets/ui/panel_score.png` |
| `panel_next 4(2).png` | 1103x1426 | `46527d3e6161d72e0960473c313f845efe6140222ba00c752200b8c5c1802996` | `assets/ui/panel_next.png` |
| `panel_to_go_orders 3(1).png` | 1132x1389 | `4871dee116d04a906c8b467e82c511895c427ef8c6cbca8566ef91d6169f8828` | `assets/ui/panel_to_go_orders.png` |
| `progression_strip 5(2).png` | 2048x684 | `fff4228423e5381ee3972231d71aa3d5c948c57c5a38f29030d64789d9d49873` | `assets/ui/progression_strip.png` |

If any exact SHA-256 source cannot be found, STOP the entire task and write a blocker log. Do not substitute a visually similar file. Do not regenerate any owner asset.

### Source-discovery rule
Filename alone is not sufficient. SHA-256 is authoritative.

### Byte-preservation rule
Copy the selected owner source bytes directly to the canonical targets. Do NOT resize, crop, re-encode, recompress, recolor, clean up, optimize or otherwise edit these six PNGs. After copying, canonical target SHA-256 must exactly equal the owner SHA above.

---

# PHASE 1 — M04-R03 — Replace canonical assets exactly

## Required work
1. Replace the six canonical targets with the exact owner files above.
2. Preserve all other canonical visual assets unless a validator manifest needs textual/evidence updates.
3. Update `tools/m04_asset_validation.py`, `tests/m04_asset_import_probe.gd`, manifests/contact sheets/evidence as needed so they reflect the new target hashes/dimensions truthfully.
4. Keep the current complete 25-PNG asset truth unless actual repository scope differs after replacement.
5. Do not modify cocktail source PNGs or effect PNGs.
6. `guide_line` remains forbidden.
7. Regenerate M04 evidence from the new canonical files.
8. Record source file paths discovered on Windows, source SHA values and final canonical SHA values in the log.

## Required M04-R03 log
Write:
`coordination/sessions/BCM-M04-R03/CODEX_LOG_V01.md`

The log must include:
- preflight refs;
- each discovered owner source path;
- SHA-256 before copy;
- canonical target SHA-256 after copy;
- dimensions/mode/alpha checks;
- exact changed files;
- M04 validator/import probe outputs and exit codes;
- proof no unrelated PNG changed;
- TASKS untouched.

Commit and push M04-R03 separately before continuing.

---

# PHASE 2 — M06-R04 — Rebuild geometry for NEW background

The replacement background is not merely a cosmetic swap. Do not assume old table landmarks are still correct.

## Required work
1. Inspect the actual new 1024x1536 canonical background.
2. Independently remeasure the visible inner tabletop rail landmarks from the new artwork:
   - far left/right;
   - middle left/right;
   - near left/right;
   - visible tabletop top edge;
   - visible tabletop lower edge / transition to dark apron.
3. Update production geometry only where the new evidence requires it.
4. Do NOT blindly retain old values such as `(292,464)/(732,464)/(104,1208)/(920,1208)` unless independent measurement of the NEW background truly supports them.
5. Re-evaluate launch Y and danger Y on the new tabletop.
6. Preserve the gameplay intent:
   - most table area usable;
   - danger low on the table;
   - launch below danger but still on visible tabletop;
   - held drink must not sit on the dark apron.
7. Preserve aspect ratio. No stretching, no black bars.
8. Keep rails credible for 720x1280, 720x1440 and 800x1280.
9. Regenerate clean screenshots and runtime rail/danger/launch overlays from the new background.
10. Create independent screenshot-space visible-wood measurements from the NEW renders, not stale M06 values.
11. Preserve M01-M05 gameplay behavior and constants. No physics/economy retuning.
12. No guide line.

## Required M06-R04 log
Write:
`coordination/sessions/BCM-M06-R04/CODEX_LOG_V01.md`

Include exact new source landmarks, viewport-space measurements, tolerances, production values, screenshots/evidence hashes, commands/exits and changed files.

Commit and push M06-R04 separately before continuing.

---

# PHASE 3 — M07-R03 — Rebuild HUD around NEW panel artwork

## Critical design rule
The new PNGs already contain their decorative frames and headings. Godot must render only dynamic content inside the blank content areas.

### BEST SCORE
The PNG already includes the crown and `BEST SCORE` heading.
Runtime adds ONLY the numeric best-score value in the dark recessed content window.
Do not draw another `BEST SCORE` heading or crown.

### SCORE
The PNG already includes the star icon and `SCORE` heading.
Runtime adds ONLY the numeric score value in the dark recessed content window.
Do not draw another `SCORE` heading/icon.

### NEXT
The PNG already includes the `NEXT` heading.
Runtime adds ONLY the true next cocktail in the large light cream interior area below the title.
The cocktail must be as large as practical while its full alpha-visible garnish remains inside the cream content area, not on the wood/header/border.
Exactly one NEXT panel.

### TO-GO ORDERS
The PNG already includes the `To-Go Orders` heading and decorative background stamps.
Runtime adds ONLY:
- current target cocktail;
- live `Lx + cocktail name` text;
- live `+reward` text.
Place these in a clean vertical hierarchy inside the large cream board without overlapping one another or the baked title.
Use actual font/alpha-visible bounds, not just centers.

### PROGRESSION STRIP
The NEW `progression_strip.png` already physically contains EXACTLY 12 baked cream slots arranged 2 rows x 6 columns.

This is extremely important:
- REMOVE the runtime-generated `Panel` / `StyleBoxFlat` / rectangle cell frames currently drawn over the strip.
- Do NOT draw 12 extra cells on top of the PNG.
- Runtime should add cocktail sprites ONLY.
- Independently measure the actual 12 baked cream slot rectangles/centers from the new canonical PNG.
- Do not derive acceptance from the old generic `1/6` grid constants if the artwork differs.

Logical mapping:
TOP ROW = L07, L08, L09, L10, L11, L12
BOTTOM ROW = L01, L02, L03, L04, L05, L06

Every cocktail icon must remain within the light cream interior of its intended slot. Full alpha-visible garnish must not materially cross the gold border or neighboring slot.

### OUTER HUD COMPOSITION
Re-layout the HUD to respect the new native aspect ratios:
- Best/Score are landscape panels.
- NEXT and To-Go are portrait-oriented panels.
- Progression is approximately 3:1 landscape.

Do not stretch any artwork.
Do not force a vertical panel into a landscape Control rectangle and rely on large empty margins.

Maintain:
- logo upper-left;
- Best Score under/near logo;
- Score under Best Score;
- both above the table accumulation zone;
- To-Go upper-center;
- one NEXT upper-right;
- progression near bottom, below gameplay accumulation and not covering the launch halo/held cocktail.

Because the new background has changed, use M06-R04's actual table top/launch/danger positions when placing HUD elements.

### LAUNCH / DANGER
- Launch halo stays behind and centered under the held cocktail.
- Danger PNG remains exactly synchronized with `death_line_y`.
- No guide line.
- No permanent prototype drag instruction.

### Shared cocktail mapping
NEXT, To-Go and progression must continue using the shared M05 `Drink.texture_for_level()` mapping. Do not create a second L01-L12 path table.

## Required visual validation
For each viewport:
- 720x1280
- 720x1440
- 800x1280

Retain:
1. clean production screenshot;
2. HUD content-box overlay;
3. actual visible text/alpha bounds overlay;
4. progression close-up showing all 12 baked slots with runtime icons;
5. layout close-up;
6. table/danger/launch overlay from M06-R04.

Tests must measure actual text bounds and alpha-used rect bounds.

## Required M07-R03 log
Write:
`coordination/sessions/BCM-M07-R03/CODEX_LOG_V01.md`

Include:
- final HUD rectangles;
- measured native aspect ratios;
- independently measured content-window/slot rectangles;
- actual visible bounds for runtime content;
- progression top/bottom mapping;
- proof runtime cell frames were removed;
- clean/evidence screenshot hashes;
- changed files;
- exact test commands/results/exits.

Commit and push M07-R03 separately.

---

# FINAL REGRESSION ON FINAL MAIN

After M07-R03 is committed, rerun on final candidate HEAD:
- M01 gameplay contract
- M02 physics/collision/merge/rapid launch
- M03 economy/To-Go/persistence/danger/Game Over/restart
- M04-R03 exact owner asset validation
- M05 current sprite/collider probe without weakening it
- M06-R04 new-background geometry probe
- M07-R03 new-HUD visual/bounds probe
- Godot 4.7.x import/parse
- main-scene startup
- `git diff --check`

Do not weaken prior regression tests to make the refresh green.

## Final stop condition
Push all three bounded commits to `main`, verify local HEAD/origin/main/remote main equality, then return ONLY:
- M04-R03 log URL + commit SHA
- M06-R04 log URL + commit SHA
- M07-R03 log URL + commit SHA
- one-line final suite result
- `AWAITING_AUDIT`

Then STOP. Do not start M08+.