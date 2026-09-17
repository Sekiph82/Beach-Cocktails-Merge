# BCM-M07-R07 — Owner Visual Alignment Audit Criteria V02

Status: **LOCKED BEFORE IMPLEMENTATION — OWNER SCREENSHOT SUPERSEDES V01**

Authority: owner runtime screenshot/annotation dated 2026-09-17 18:37.

## PASS requirements
1. BEST SCORE remains left under the logo and fully visible.
2. SCORE remains on the right beneath/near NEXT as previously accepted.
3. SCORE number keeps the existing fixed production font size and 7-digit maximum contract.
4. SCORE number receives an explicit **optical upward adjustment** so the visible glyphs sit visually centered in the dark recessed rectangle, matching the owner annotation. Do not achieve this by dynamic font shrinking.
5. BEST SCORE remains visually centered; do not regress it while adjusting SCORE.
6. Score/Best validation uses rendered glyph bounds plus the intended optical offset, not only Label rectangle coordinates.
7. To-Go runtime content remains target cocktail + reward digits only; no Lx/name and no leading plus.
8. To-Go reward remains inside the cream board and does not overlap target art.
9. The two To-Go hanging ropes must appear **visually continuous** from the baked rope ends to the visible top edge/ceiling of the gameplay viewport.
10. Merely having a Line2D endpoint at y=0 is insufficient. The retained screenshot must show no visually obvious gap, discontinuity or disconnected rope join.
11. Rope extensions match baked rope width/color closely enough to read as one rope, remain behind panel art, and do not cover title/target/reward/NEXT/logo.
12. NEXT L01-L12 containment remains intact.
13. Held cocktail placement is validated against the **rendered gold launch oval** and independently measured visible glass/container body footprint.
14. For each L01-L12 held cocktail, the visible glass/container body bottom-center must land on the intended center reference of the gold oval within a small documented tolerance.
15. Validation must not be circular: the test may not derive the expected held anchor from the same `HELD_BODY_FOOT_SOURCE_PX` / `VISIBLE_BODY_CENTER_OFFSET_PX` values it is testing.
16. Retained evidence includes an L01-L12 held-cocktail sheet with the rendered gold oval center crosshair and independently measured glass body bottom-center overlay.
17. Launch halo remains behind the drink and centered on the gameplay launch position.
18. Current baked 2x6 progression remains unchanged: top L07-L12, bottom L01-L06, no runtime cell frames.
19. M06-R07 corrected tabletop envelope is preserved and HUD never shrinks gameplay geometry.
20. Responsive validation covers 720x1280, 720x1440 and 800x1280.
21. Retained screenshots include close-ups proving: SCORE optical Y placement, seamless To-Go ropes, reward placement, NEXT containment, and held-drink/halo alignment.
22. Full M01-M07 regression, reconciled baseline M06 test, Godot import/startup and `git diff --check` pass.
23. No canonical PNG, TASKS.md, ChatGPT-owned file, historical log or M08+ work is modified by Codex.

Any material failure blocks AUDITED_PASS.
