# BCM-M07-R03 — Independent ChatGPT Audit V01

## Verdict
**FAIL / CHANGES_REQUIRED**

## Root dependency failure
M07-R03 was required to rebuild the HUD around the owner's final replacement UI artwork. The actual owner attachments are:

- panel_best_score 5(1).png — 1671x941 — SHA `62a237642c2007d538c12653e7fa60c7e4208291b35d4070df7f55e87d12c988`
- panel_score 2(2).png — 1672x941 — SHA `8b540fbad12d1d4c76ff4af935ee48d39cee5c33d2a25dd0e1a077b3e67a56ec`
- panel_next 4(2).png — 1103x1426 — SHA `46527d3e6161d72e0960473c313f845efe6140222ba00c752200b8c5c1802996`
- panel_to_go_orders 3(1).png — 1132x1389 — SHA `4871dee116d04a906c8b467e82c511895c427ef8c6cbca8566ef91d6169f8828`
- progression_strip 5(2).png — 2048x684 — SHA `fff4228423e5381ee3972231d71aa3d5c948c57c5a38f29030d64789d9d49873`

M07-R03 instead rebuilt around different canonical files, including progression `2170x725` SHA `6354b44c...`.

## Findings
1. **BLOCKER — HUD was rebuilt against the wrong owner art.** All content boxes, panel scales and progression slot measurements are invalid for the actual final files.
2. The progression implementation is structurally improved: runtime cell frames were removed and only cocktail sprites are added. This should be preserved.
3. Shared `Drink.texture_for_level()` mapping, top L07-L12 / bottom L01-L06 order, dynamic Score/Best/To-Go/NEXT behavior and no-guide-line behavior are correct in architecture and should be preserved.
4. The current baked-slot measurements (`2170x725`, x ranges starting at 499 etc.) cannot be accepted for the actual owner progression PNG (`2048x684`). The final strip must be remeasured from the real `fff42284...` image.
5. The current outer panel rectangles preserve the wrong files' aspect ratios. They must be recomputed from the actual canonical bytes after replacement.
6. The current final screenshots and visible-bounds evidence prove the wrong asset set, so they do not satisfy final visual acceptance.
7. M07 is also downstream of failed M06-R04 because launch/danger/table positions were derived from the wrong background.

## Required remediation
Canonicalize the exact five owner UI attachments and exact owner background first. Then rebuild content windows and 2x6 progression slot centers from those exact PNGs, preserve the improved runtime architecture (no extra progression frames), regenerate all three viewport captures/visible-bound overlays, and rerun M01-M07 regressions.
