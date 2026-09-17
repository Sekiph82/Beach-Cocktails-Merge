# BCM-M07-R05 — Independent Audit V01

Verdict: **CHANGES_REQUIRED**

Authority: locked M07-R05 criteria plus the later owner-annotated runtime screenshot captured on 2026-09-17 after BCM-M07-R05 implementation.

## What passed
- BEST SCORE and SCORE remain HUD-only and do not define physics bounds.
- The fixed-font / 7-digit score contract remains implemented.
- To-Go runtime level/name text is removed and reward has no leading plus sign.
- To-Go ropes remain connected to the viewport top.
- NEXT / progression / no-guide-line contracts remain intact.

## Owner-visible blockers from the latest runtime screenshot
1. BEST SCORE numeric value is not visually centered enough inside its dark recessed rectangle.
2. SCORE numeric value is not visually centered enough inside its dark recessed rectangle.
3. The owner now explicitly wants the SCORE panel moved to the right side, below/near NEXT, instead of remaining under BEST SCORE on the left.
4. To-Go reward is still too low / visually outside the intended cream-board composition. It must be moved into the owner-marked internal area of the To-Go board.
5. Held cocktail placement is still visually wrong: the visible glass/container bottom must be centered over the gold launch oval, with the body centered on the oval rather than merely sharing a numeric baseline.
6. M06-R05 rear-table geometry remains owner-rejected and must be fixed first; M07 must adapt to the corrected geometry without shrinking it.

## Required remediation direction
- Use actual rendered glyph bounds to place the fixed-size BEST/SCORE numbers dead-center in their dark value windows. Font size remains fixed; only position/alignment may change.
- Keep BEST SCORE on the left under the logo.
- Move SCORE to the right side under/near NEXT as annotated, with no overlap and no effect on playfield physics.
- Move To-Go reward fully inside the cream board to the owner-marked lower-middle area; target cocktail and reward must remain visually balanced.
- For the held drink, validate both common body-bottom contact and horizontal centering of the visible glass body over the launch halo center. A shared Y baseline alone is insufficient.
- Preserve all accepted M07-R04 rules: fixed score font, no Lx/name, no reward plus sign, ceiling ropes, NEXT containment, baked 2x6 progression.

BCM-M07-R05 is not accepted until these owner-visible layout defects are corrected.