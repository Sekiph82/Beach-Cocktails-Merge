# BCM-M07-R04 — Locked Audit Criteria V01

Status: **LOCKED BEFORE REMEDIATION**

Authority: owner-annotated screenshot captured from the running Godot DEBUG build on 2026-09-17 plus `coordination/sessions/BCM-M07-R03/CHATGPT_AUDIT_V02.md`.

## Scope

Perform a focused M07 HUD/content-placement remediation only. Preserve the currently accepted refreshed artwork, background/table geometry, danger/launch world coordinates, 2x6 progression artwork and M01-M06 gameplay behavior.

## PASS requirements

1. Current refreshed canonical assets remain in use. Do not replace/revert the background, BEST SCORE, SCORE, To-Go, NEXT or progression artwork.
2. BEST SCORE runtime value is the only dynamic numeric content in its value window and is fully contained inside the actual dark recessed rectangle.
3. SCORE runtime value is fully contained inside its actual dark recessed rectangle.
4. Score and Best Score use deterministic fit-to-window sizing based on rendered font bounds, not one fixed font size that can overflow for longer values.
5. Tests exercise multiple representative score lengths, including at least 0, a 3-digit value, a 5-digit value and a long/high score value appropriate to the game.
6. To-Go target cocktail alpha-visible bounds stay inside the baked cream board.
7. To-Go `Lx + cocktail name` rendered text stays inside its dedicated safe content region and never overlaps the target cocktail materially.
8. To-Go reward text stays inside its dedicated safe region and never falls below/outside the baked board.
9. To-Go title/artwork is never recreated or covered by dynamic content.
10. NEXT uses a measured cream content rectangle from the active artwork.
11. Every L01-L12 NEXT cocktail is validated individually against that safe rectangle using actual alpha-visible bounds.
12. No NEXT cocktail garnish, straw, fruit, leaf, flower, body or glass pixel materially crosses into the wooden header/frame/border.
13. Relative visual-size progression between cocktails is preserved where possible, but safe containment is mandatory and takes precedence.
14. Held-drink visual placement uses a visible glass/container body-bottom anchor or equivalent per-level foot point, not only texture-center/full-alpha-center alignment.
15. For L01-L12, the held visible body bottom aligns to one common launch baseline within a documented small tolerance.
16. The held-drink body-bottom alignment is visual only and does not retune collider radius, physics center, launch speed, deceleration, momentum, merge or economy.
17. Launch halo remains behind the held drink and centered on the gameplay launch position.
18. Current danger line and launch world Y from accepted M06-R04 remain unchanged unless an owner-approved blocker is documented.
19. Current refreshed table/background composition remains unchanged.
20. Current baked 2x6 progression artwork remains unchanged.
21. Progression top row stays L07-L12 and bottom row stays L01-L06.
22. Runtime adds cocktail sprites only to progression. No extra Panel/StyleBox/cell rectangles are reintroduced.
23. Exactly one NEXT panel and one To-Go panel exist.
24. Shared `Drink.texture_for_level()` mapping remains the sole cocktail texture source for NEXT, To-Go and progression.
25. No guide line and no permanent prototype instruction text.
26. Required responsive validation covers 720x1280, 720x1440 and 800x1280.
27. Retained evidence includes clean screenshot plus visible-content overlay for all three viewports.
28. Retained focused evidence includes: score/best value-window close-up; To-Go close-up; NEXT L01-L12 fit sheet; held L01-L12 body-bottom anchor sheet; progression close-up.
29. M01-M07 regression suite passes on final candidate main.
30. Godot 4.7.x import/startup and `git diff --check` pass.
31. `TASKS.md`, ChatGPT-owned prompt/audit/criteria/policy files and historical logs are not edited by Codex.
32. No M08+ work is started.

Any material failure blocks AUDITED_PASS.
