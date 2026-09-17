# BCM-M07-R04 — Locked Audit Criteria V01

Status: **LOCKED BEFORE REMEDIATION — UPDATED WITH OWNER CEILING-ROPE REQUIREMENT**

Authority: owner-annotated screenshot captured from the running Godot DEBUG build on 2026-09-17, the later explicit owner instruction that the To-Go Orders ropes must be attached to the top of the game screen, plus `coordination/sessions/BCM-M07-R03/CHATGPT_AUDIT_V02.md`.

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
10. The two To-Go hanging ropes visually continue from the baked rope anchors to the top edge of the gameplay viewport, so the board reads as physically suspended from the screen ceiling/top frame.
11. Left and right runtime rope continuations align with their corresponding baked rope anchors with no visible gap at the join.
12. Rope continuations visually match the baked rope thickness/color/shading closely enough that the join is not materially distracting.
13. Rope continuations remain behind the To-Go board/artwork and do not cover the title, target cocktail, level/name, reward, logo, NEXT or other HUD elements.
14. Rope continuations are decorative only and introduce no input, physics or collision behavior.
15. For 720x1280, 720x1440 and 800x1280, both rope continuations remain attached to the visible viewport top and to the baked rope anchors after responsive layout.
16. NEXT uses a measured cream content rectangle from the active artwork.
17. Every L01-L12 NEXT cocktail is validated individually against that safe rectangle using actual alpha-visible bounds.
18. No NEXT cocktail garnish, straw, fruit, leaf, flower, body or glass pixel materially crosses into the wooden header/frame/border.
19. Relative visual-size progression between cocktails is preserved where possible, but safe containment is mandatory and takes precedence.
20. Held-drink visual placement uses a visible glass/container body-bottom anchor or equivalent per-level foot point, not only texture-center/full-alpha-center alignment.
21. For L01-L12, the held visible body bottom aligns to one common launch baseline within a documented small tolerance.
22. The held-drink body-bottom alignment is visual only and does not retune collider radius, physics center, launch speed, deceleration, momentum, merge or economy.
23. Launch halo remains behind the held drink and centered on the gameplay launch position.
24. Current danger line and launch world Y from accepted M06-R04 remain unchanged unless an owner-approved blocker is documented.
25. Current refreshed table/background composition remains unchanged.
26. Current baked 2x6 progression artwork remains unchanged.
27. Progression top row stays L07-L12 and bottom row stays L01-L06.
28. Runtime adds cocktail sprites only to progression. No extra Panel/StyleBox/cell rectangles are reintroduced.
29. Exactly one NEXT panel and one To-Go panel exist.
30. Shared `Drink.texture_for_level()` mapping remains the sole cocktail texture source for NEXT, To-Go and progression.
31. No guide line and no permanent prototype instruction text.
32. Required responsive validation covers 720x1280, 720x1440 and 800x1280.
33. Retained evidence includes clean screenshot plus visible-content overlay for all three viewports.
34. Retained focused evidence includes: score/best value-window close-up; To-Go L06-L12 fit sheet; To-Go rope-to-top close-up/overlay for all required viewports; NEXT L01-L12 fit sheet; held L01-L12 body-bottom anchor sheet; progression close-up.
35. M01-M07 regression suite passes on final candidate main.
36. Godot 4.7.x import/startup and `git diff --check` pass.
37. `TASKS.md`, ChatGPT-owned prompt/audit/criteria/policy files and historical logs are not edited by Codex.
38. No M08+ work is started.

Any material failure blocks AUDITED_PASS.
