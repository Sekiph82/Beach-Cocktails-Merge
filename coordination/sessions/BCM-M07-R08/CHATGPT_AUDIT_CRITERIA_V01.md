# BCM-M07-R08 — Owner Runtime HUD Final Alignment Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

Authority: latest owner runtime screenshot and written clarification dated 2026-09-17 21:35.

## Observed problem
The current build is close, but three owner-visible issues remain:

1. The To-Go panel is too low because runtime rope-extension logic was used. The owner does not want the rope artwork extended or altered. The existing To-Go asset should simply be moved upward until the asset's own topmost visible artwork touches the top edge of the gameplay viewport.
2. BEST SCORE and SCORE digits are horizontally centered but still not vertically centered in the dark/gold-framed value recesses.
3. Held-drink alignment is now accepted by the owner and must not be changed.

## Required end state
1. The To-Go canonical PNG remains byte-for-byte unchanged.
2. Runtime must not lengthen, redraw, fake, extend or otherwise alter the To-Go ropes.
3. Any previously added runtime rope-extension geometry that exists only to bridge the ceiling gap must be removed or disabled.
4. The complete To-Go panel/asset is positioned upward so the **topmost visible pixel/artwork of the existing asset** visually touches the top edge of the gameplay viewport.
5. No part of the To-Go content that should remain visible is clipped by this placement.
6. To-Go still contains only the target cocktail and reward digits at runtime. No Lx/name and no leading plus.
7. To-Go reward remains fully inside the cream board and does not overlap the target cocktail.
8. BEST SCORE stays left under the logo.
9. SCORE stays right beneath/near NEXT.
10. BEST SCORE and SCORE retain the approved fixed font sizes and 7-digit maximum contract.
11. The rendered numeric glyphs must be centered both horizontally **and vertically** in their actual dark value recess / gold-framed value area.
12. Vertical centering must be judged from rendered glyph bounds against the actual visible recess, not merely Label node rectangles or a test box moved together with production.
13. Representative values include at least `0`, `321`, `24380`, `999999` and `9999999` for both panels.
14. BEST and SCORE must remain fully visible and non-overlapping across 720x1280, 720x1440 and 800x1280.
15. **Held-drink baseline and horizontal alignment are owner-approved in the current build. Do not modify held-drink anchor/baseline/halo alignment unless an unrelated build break makes preservation impossible.** Any such dependency must be documented before change.
16. NEXT containment and current baked 2x6 progression remain unchanged.
17. HUD must not alter gameplay/table boundaries.
18. Canonical PNGs are not modified.
19. Retained runtime evidence includes close-ups of To-Go top-edge placement and BEST/SCORE value centering in all required viewports.
20. Full active M01-M07 regression, Godot import/startup and `git diff --check` pass.
21. `TASKS.md`, ChatGPT-owned files, historical logs and M08+ work are not modified by Codex.

Any material owner-visible mismatch blocks AUDITED_PASS.
