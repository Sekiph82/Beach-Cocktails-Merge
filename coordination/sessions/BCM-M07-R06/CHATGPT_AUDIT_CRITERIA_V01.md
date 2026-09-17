# BCM-M07-R06 — Owner-Annotated HUD Refinement Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

Authority: latest owner-annotated runtime screenshot dated 2026-09-17.

## PASS requirements
1. BEST SCORE remains left under the logo and fully visible.
2. BEST SCORE digits use the existing fixed font size and are visually centered inside the dark recessed rectangle using rendered glyph bounds.
3. SCORE moves to the right side beneath/near NEXT as annotated by the owner.
4. SCORE remains fully visible, non-overlapping and HUD-only; it does not reduce gameplay bounds.
5. SCORE digits use the existing fixed font size and are visually centered inside the dark recessed rectangle using rendered glyph bounds.
6. The 7-digit maximum contract through `9999999` remains intact with no digit-count font shrinking.
7. To-Go runtime content remains target cocktail + reward digits only; no Lx/name and no leading plus.
8. To-Go reward is moved fully inside the cream board to the owner-marked lower-middle area and is visually balanced with the target cocktail.
9. To-Go ropes remain attached to the viewport top and behind the panel.
10. NEXT L01-L12 containment remains intact.
11. Held-drink placement validates BOTH vertical body-bottom alignment and horizontal glass/body centering on the gold launch oval center.
12. The glass/container body, not garnish centroid or texture center, defines held horizontal centering.
13. Launch halo remains behind the held drink and centered on launch position.
14. Current baked 2x6 progression remains unchanged: top L07-L12, bottom L01-L06, no runtime frames.
15. M06-R06 widened rear-table geometry is preserved and not reduced to make room for HUD.
16. Responsive validation covers 720x1280, 720x1440 and 800x1280.
17. Retained screenshots show BEST centered left, SCORE centered right, To-Go reward inside its board, and held body centered on halo.
18. Full M01-M07 regression, Godot import/startup and `git diff --check` pass.
19. No canonical PNG, TASKS.md, ChatGPT-owned file, historical log or M08+ work is modified.

Any material failure blocks AUDITED_PASS.