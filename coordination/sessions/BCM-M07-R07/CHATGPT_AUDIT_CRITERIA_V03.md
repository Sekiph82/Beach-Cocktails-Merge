# BCM-M07-R07 — Owner Visual Alignment Audit Criteria V03

Status: **LOCKED BEFORE IMPLEMENTATION — OWNER SCREENSHOT AUTHORITY**

Authority: latest owner runtime screenshot and annotations dated 2026-09-17 18:37. This V03 supersedes V01/V02.

## Observed problem
The current running build still has three owner-visible HUD/alignment defects:

- the SCORE number sits slightly too low inside its dark recessed value area;
- the To-Go hanging ropes still read as visually disconnected from the top/ceiling;
- held cocktails still do not visually sit in the true center of the gold launch oval.

## Required end state
1. BEST SCORE remains left under the logo and fully visible.
2. SCORE remains on the right beneath/near NEXT as previously requested.
3. SCORE keeps the existing fixed production font size and 7-digit maximum contract.
4. SCORE digits are visually centered in the dark recessed rectangle, including vertical placement, across representative values up to `9999999`.
5. BEST SCORE remains visually centered and does not regress.
6. To-Go runtime content remains target cocktail + reward digits only, with no Lx/name and no leading plus.
7. To-Go reward remains fully inside the cream board and does not overlap the target cocktail.
8. The two To-Go hanging ropes look continuously attached from the panel to the visible top/ceiling in the final running game. A mathematically connected node is not enough if the screenshot still shows a visible gap.
9. Rope decoration remains behind the panel/HUD content and does not interfere with input or physics.
10. NEXT L01-L12 containment remains intact.
11. Every held cocktail L01-L12 visually sits correctly on the gold launch oval: the visible glass/container body must read as centered horizontally and vertically according to the owner-visible oval, not merely according to internal anchor constants.
12. Launch halo remains behind the held cocktail and stays centered on the gameplay launch position.
13. Current baked 2x6 progression remains unchanged: top L07-L12, bottom L01-L06, no runtime cell frames.
14. The corrected M06-R07 tabletop playfield is preserved and HUD never shrinks gameplay geometry.
15. Canonical PNGs are not modified.
16. The implementation method is deliberately NOT prescribed. Codex must inspect the current production implementation and choose the technical solution that best achieves the owner-visible result without regressions.
17. Validation must use retained runtime screenshots/evidence for 720x1280, 720x1440 and 800x1280 and must visibly demonstrate SCORE placement, rope continuity and held-cocktail/halo alignment.
18. Held-cocktail evidence must cover L01-L12, not a single level only.
19. Full active M01-M07 regression, Godot import/startup and `git diff --check` pass.
20. `TASKS.md`, ChatGPT-owned files and historical logs are not edited by Codex.
21. No M08+ work begins.

Any material owner-visible mismatch blocks AUDITED_PASS.