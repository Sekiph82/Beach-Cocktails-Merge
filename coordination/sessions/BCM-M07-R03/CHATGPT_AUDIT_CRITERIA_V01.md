# BCM-M07-R03 — Locked Audit Criteria V01

Status: LOCKED BEFORE IMPLEMENTATION

## Scope
Rebuild the dynamic HUD around the newly owner-approved BEST SCORE, SCORE, NEXT, To-Go Orders and 2x6 progression PNGs. These files supersede prior versions.

## Canonical new UI assets
- `assets/ui/panel_best_score.png` ← owner SHA `62a237642c2007d538c12653e7fa60c7e4208291b35d4070df7f55e87d12c988`, 1671x941.
- `assets/ui/panel_score.png` ← owner SHA `8b540fbad12d1d4c76ff4af935ee48d39cee5c33d2a25dd0e1a077b3e67a56ec`, 1672x941.
- `assets/ui/panel_next.png` ← owner SHA `46527d3e6161d72e0960473c313f845efe6140222ba00c752200b8c5c1802996`, 1103x1426.
- `assets/ui/panel_to_go_orders.png` ← owner SHA `4871dee116d04a906c8b467e82c511895c427ef8c6cbca8566ef91d6169f8828`, 1132x1389.
- `assets/ui/progression_strip.png` ← owner SHA `fff4228423e5381ee3972231d71aa3d5c948c57c5a38f29030d64789d9d49873`, 2048x684.

## Visual/layout authority
1. Text already baked into the PNGs is not recreated by Godot. In particular `BEST SCORE`, `SCORE`, `NEXT`, and `To-Go Orders` headings come from the artwork.
2. Runtime content only:
   - Best Score panel: numeric best-score value only.
   - Score panel: numeric score value only.
   - NEXT panel: true next cocktail sprite only.
   - To-Go panel: target cocktail + live Lx/name + live reward only.
   - Progression: cocktail icons only.
3. Do not add duplicate decorative frames over baked artwork.
4. The new progression artwork already contains EXACTLY 12 physical slots in a 2x6 arrangement. Runtime must not draw/add `Panel`, `StyleBox`, rectangles or other extra slot frames over it.
5. Progression logical mapping is exactly TOP L07-L12, BOTTOM L01-L06.
6. Progression icons must be placed from independently measured centers/insets of the actual 12 baked slots, not from the old single-row layout or a generic guessed grid.
7. All icon alpha-visible bounds stay inside the cream interior of their intended baked slot without material overlap with gold borders or neighboring slots.
8. BEST/SCORE numbers stay inside their dark recessed value windows and do not overlap headings, flowers, frame or borders.
9. NEXT cocktail alpha-visible bounds stay within the large cream content window below the baked `NEXT` heading.
10. To-Go cocktail, level/name and reward remain inside the large cream board, do not overlap one another materially, and do not cover the baked `To-Go Orders` title.
11. Outer artwork aspect ratios are preserved. No stretching of the new vertical NEXT/To-Go panels or landscape Score/Best panels.
12. HUD remains on-screen at 720x1280, 720x1440 and 800x1280.
13. Logo remains top-left; Best Score then Score remain on the left and above the table accumulation region.
14. To-Go remains upper-center; exactly one NEXT remains upper-right.
15. Progression remains near the bottom but does not cover the held drink/launch halo or remove necessary launch space.
16. Launch halo remains behind and centered under the held cocktail.
17. Danger PNG remains synchronized with M06-R04 `death_line_y`.
18. No guide line or permanent instructional prototype text.
19. Shared M05 cocktail texture mapping is used for NEXT, To-Go and progression. No duplicated L01-L12 texture-path table in `game_manager.gd`.
20. Live Score/Best/To-Go/NEXT updates continue to work after rapid launch and target rotation.
21. Existing M01-M06 gameplay/economy contracts remain unchanged.
22. Retained screenshots for all three viewports include clean screenshot, visible-content bounds overlay, progression close-up and master/layout comparison.
23. Tests measure actual text/font bounds and texture alpha-used bounds, not only node centers.
24. New content-box/slot measurements are based on the actual owner replacement artwork and are not stale values from prior panels.
25. `TASKS.md` and ChatGPT-owned files remain untouched by Codex.
26. Godot import/startup and `git diff --check` pass.

Any material failure blocks AUDITED_PASS.