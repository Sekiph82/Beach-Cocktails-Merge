# BCM-M07-R01 — ChatGPT Strict Re-Audit V02

Decision: **CHANGES_REQUIRED**

This V02 re-audit supersedes the interpretation in `CHATGPT_REAUDIT_V01.md` where they conflict. The owner has now supplied and annotated the actual M07 `canonical_720x1280` evidence directly in the review conversation, allowing independent visual inspection.

## Corrected visual conclusion

The M07 `canonical_720x1280` production evidence is **materially closer to the owner master visual than the earlier M06 evidence**. M07 successfully moved the project from a prototype/text-overlay look toward the intended polished tropical composition:

- canonical logo is present top-left;
- decorated Best Score and Score panels are present;
- decorated To-Go panel is present upper-center;
- decorated NEXT panel is present upper-right;
- long perspective wooden table dominates the gameplay area;
- canonical cocktail sprites are on the tabletop;
- canonical danger-line and launch-zone art are present;
- the progression presentation uses the tropical frame/art language.

Therefore the M07 remediation must **preserve this improved composition and refine it**, not discard it or revert toward the old M06 evidence.

The V01 statement that M07 was simply unacceptable because it preserved M06 geometry was too coarse. M07 visibly improved the rendered composition even though lower-layer M06 geometry still needs stronger evidence/remediation.

## Owner-annotated visual findings

The owner supplied an annotated M07 screenshot and requested the following concrete changes.

### F-M07-V02-001 — Best Score and Score stack is too low — MAJOR

Both left-side score panels should move **higher** so they do not intrude into or obscure the tabletop accumulation area where drinks will collect.

Preserve order:

1. logo;
2. Best Score;
3. Score.

The two score panels should remain visually grouped but sit higher in the upper-left decorative/background region.

### F-M07-V02-002 — To-Go and NEXT panels need more downward content space — MAJOR

The owner marked both upper panels with downward extension arrows. Their top anchoring/hierarchy is useful, but their usable content presentation should extend farther downward so the internal live content has room to breathe.

Do not merely move the whole panels lower into the playfield. Preserve their upper HUD anchoring and increase/reshape their vertical content presentation downward without distorting the overall tropical visual language.

### F-M07-V02-003 — Text and cocktail placement inside UI assets is poor — BLOCKER for M07 acceptance

The live content is not properly fitted into the blank/decorative regions of the UI artwork.

Observed examples:

- To-Go target cocktail overlaps/competes with the level/name text;
- To-Go reward `+1000` sits awkwardly below the intended content region instead of being cleanly composed within the panel;
- target level/name text is not cleanly centered/aligned with the panel's intended blank region;
- NEXT cocktail should be centered and scaled cleanly inside its cream/inset content area;
- Best Score and Score numeric values need to be centered inside their intended value fields and must not collide with headings/icons/decorations;
- progression icons need consistent centering/scale inside their containers.

M07 remediation must treat each UI asset as a designed frame with a defined inner content box. Live labels/sprites must be laid out inside those boxes, not positioned approximately over the whole image bounds.

### F-M07-V02-004 — Gameplay cocktails are too small — MAJOR

All table/held cocktails should be **somewhat larger** than in the current M07 evidence.

This must be coordinated with M05 remediation so visual/body/collider fit remains credible. Do not arbitrarily enlarge sprites while leaving obviously mismatched collision footprints.

### F-M07-V02-005 — Danger line should move lower — MAJOR

The owner explicitly marked the danger line to be moved farther downward, closer to the launch region, preserving more usable tabletop above it.

The visual danger line and actual gameplay `death_line_y` must remain synchronized. Do not move only the artwork. Rerun M03 danger/game-over regression after the geometry adjustment.

### F-M07-V02-006 — Launch-zone halo is not correctly under/around the held drink — MAJOR

The gold launch halo must be visually **under the glass**, and the held glass must sit centered within the halo/ring footprint. The current M07 evidence places the glass/ring relationship awkwardly.

Correct z-order, center, vertical offset and scale so the halo reads as a floor marker beneath the drink.

### F-M07-V02-007 — Progression UI should become a 2x6 presentation with larger icons — MAJOR

The current single-row 12-icon strip makes the cocktail icons too small.

Owner direction:

- create a new two-row progression presentation;
- **top row = L07-L12**;
- **bottom row = L01-L06**;
- six icons per row;
- make the cocktail icons visibly larger;
- preserve clear left-to-right progression within each row;
- no L13.

The source canonical PNGs must not be destructively edited. The runtime may compose a new two-row frame from existing art or create a documented derived runtime asset if necessary, while preserving source provenance.

### F-M07-V02-008 — M07 visual composition is directionally good and should be preserved — PASS / NOTE

Do not throw away the current tropical HUD styling. The remediation is a refinement pass around layout, inner-content geometry, icon size, progression format, danger/launch placement and table-play-space balance.

## Architecture/state findings to preserve

The following remain useful and should survive remediation:

- live Score/Best Score data;
- live To-Go target/reward;
- exactly one live NEXT;
- shared `Drink.texture_for_level()` mapping;
- no guide line;
- canonical decorated UI assets;
- M01-M03 gameplay/economy behavior;
- M07's improved overall master-relative visual language.

## Revised acceptance summary

M07 is **not** a failed visual direction. It is a substantially improved composition with specific owner-identified layout defects.

`AUDITED_PASS` is blocked until those defects are remediated and fresh production screenshots show:

- higher Score/Best stack;
- To-Go/NEXT with better downward content capacity;
- correctly fitted internal live text/images;
- larger gameplay cocktails with credible collider fit;
- lower synchronized danger line;
- properly centered launch halo beneath held drink;
- two-row 2x6 progression layout with larger icons;
- preserved master-like overall tropical composition across required portrait cases.

## Final verdict

**CHANGES_REQUIRED**
