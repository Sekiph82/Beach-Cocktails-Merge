# BCM-M07-R04 — Locked Audit Criteria V02

Status: **LOCKED BEFORE REMEDIATION — OWNER REFINEMENT V02**

This V02 supersedes `CHATGPT_AUDIT_CRITERIA_V01.md` for BCM-M07-R04.

Authority: owner-annotated running Godot DEBUG screenshot dated 2026-09-17 plus the owner's later explicit refinements:

- To-Go Orders hanging ropes must visually attach to the top edge of the gameplay viewport;
- BEST SCORE and SCORE must use one fixed font size, selected so values up to 7 digits fit safely inside their dark recessed value windows;
- To-Go Orders must NOT display `Lx/name` text;
- To-Go reward must be displayed without a leading plus sign.

## Scope

Perform a focused M07 HUD/content-placement remediation only. Preserve the currently accepted refreshed artwork, background/table geometry, danger/launch world coordinates, baked 2x6 progression artwork and M01-M06 gameplay/economy behavior.

## PASS requirements

1. Current refreshed canonical assets remain in use. Do not replace or revert the background, BEST SCORE, SCORE, To-Go, NEXT or progression artwork.
2. BEST SCORE runtime value is the only dynamic numeric content in its dark recessed value window and remains fully contained inside that window.
3. SCORE runtime value is the only dynamic numeric content in its dark recessed value window and remains fully contained inside that window.
4. BEST SCORE and SCORE use a **fixed font size**, not dynamic per-value auto-fit/shrink logic.
5. The fixed font size is chosen from actual rendered font bounds so every integer value from `0` through `9,999,999` can be displayed safely within the corresponding recessed value window with documented padding.
6. The production code must enforce or otherwise document the score-display contract as maximum 7 digits. Values used for fit validation must include at least `0`, `321`, `24380`, `999999` and `9999999`.
7. If BEST SCORE and SCORE windows differ materially, the implementation may use one fixed size per panel, but each panel's size must remain fixed across values. Dynamic font-size changes based on digit count are not allowed.
8. To-Go target cocktail alpha-visible bounds stay inside the baked cream board and do not cover the baked `To-Go Orders` title.
9. No runtime `Lx`, level label, cocktail name or `Lx/name` text is displayed anywhere inside To-Go Orders.
10. To-Go reward is displayed as digits only, for example `1000`, `1800`, `12000`; it must not contain a leading `+` character.
11. To-Go reward text stays completely inside its dedicated lower safe region and never overlaps the target cocktail or exits the cream board.
12. To-Go title/artwork is never recreated or covered by dynamic content.
13. The two To-Go hanging ropes visually continue from the baked rope anchors to the top edge of the gameplay viewport, so the board reads as physically suspended from the screen ceiling/top frame.
14. Left and right runtime rope continuations align with their corresponding baked rope anchors with no visible gap at the join.
15. Rope continuations visually match the baked rope thickness/color/shading closely enough that the join is not materially distracting.
16. Rope continuations remain behind the To-Go board/artwork and do not cover the title, target cocktail, reward, logo, NEXT or other HUD elements.
17. Rope continuations are decorative only and introduce no input, physics or collision behavior.
18. At 720x1280, 720x1440 and 800x1280, both rope continuations remain attached to the visible viewport top and to the baked rope anchors after responsive layout.
19. NEXT uses a measured cream content rectangle from the active artwork.
20. Every L01-L12 NEXT cocktail is validated individually against that safe rectangle using actual alpha-visible bounds.
21. No NEXT cocktail garnish, straw, fruit, leaf, flower, body or glass pixel materially crosses into the wooden header/frame/border.
22. Relative visual-size progression between cocktails is preserved where possible, but safe containment is mandatory and takes precedence.
23. Held-drink visual placement uses a visible glass/container body-bottom anchor or equivalent per-level foot point, not only texture-center/full-alpha-center alignment.
24. For L01-L12, the held visible body bottom aligns to one common launch baseline within a documented small tolerance.
25. Held-drink body-bottom alignment is visual only and does not retune collider radius, physics center, launch speed, deceleration, momentum, merge or economy.
26. Launch halo remains behind the held drink and centered on the gameplay launch position.
27. Current danger line and launch world Y from accepted M06-R04 remain unchanged unless an owner-approved blocker is documented.
28. Current refreshed table/background composition remains unchanged.
29. Current baked 2x6 progression artwork remains unchanged.
30. Progression top row stays L07-L12 and bottom row stays L01-L06.
31. Runtime adds cocktail sprites only to progression. No extra Panel/StyleBox/cell rectangles are reintroduced.
32. Exactly one NEXT panel and one To-Go panel exist.
33. Shared `Drink.texture_for_level()` mapping remains the sole cocktail texture source for NEXT, To-Go and progression.
34. No guide line and no permanent prototype instruction text.
35. Required responsive validation covers 720x1280, 720x1440 and 800x1280.
36. Retained evidence includes clean screenshot plus visible-content overlay for all three viewports.
37. Retained focused evidence includes: fixed-font BEST/SCORE 7-digit fit sheet; To-Go L06-L12 target/reward fit sheet proving no Lx/name and no plus sign; To-Go rope-to-top close-up/overlay for all required viewports; NEXT L01-L12 fit sheet; held L01-L12 body-bottom anchor sheet; progression close-up.
38. M01-M07 regression suite passes on final candidate main.
39. Godot 4.7.x import/startup and `git diff --check` pass.
40. `TASKS.md`, ChatGPT-owned prompt/audit/criteria/policy files and historical logs are not edited by Codex.
41. No M08+ work is started.

Any material failure blocks AUDITED_PASS.
