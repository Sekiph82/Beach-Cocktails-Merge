# BCM-M06-R08 — Owner Runtime Rear-Table Physics Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

Authority: latest owner runtime screenshot and written clarification dated 2026-09-17 21:35.

## Observed problem
The current running build still stops cocktails too far from the rear tabletop edge. The owner expects more of the clearly visible rear wood to be usable while larger cocktails must still stop earlier than smaller cocktails according to their current physical body size.

The owner also wants rear corner behavior to feel rounded rather than like an abrupt invisible square wall: when a cocktail approaches the extreme rear-left or rear-right area, a subtle organic tendency toward the table center is acceptable so the drink follows the apparent curved corner instead of sticking or falling off.

## Required end state
1. Small, medium and large cocktail levels can travel materially closer to the visible rear tabletop edge than in the current R07 owner screenshot, wherever visible wood is clearly available.
2. Rear stopping distance is size-aware. A larger cocktail must stop farther from the rear edge than a smaller cocktail when necessary to keep the visible glass/container body on the table.
3. The stopping rule must be based on the cocktail's current effective physical/visible body footprint, not a single hardcoded distance shared by all levels.
4. The visible glass/container body must remain on the tabletop. Decorative garnish, fruit, straw or leaves may overhang naturally if visually credible.
5. Rear-left and rear-right corner behavior must not feel like an abrupt square collision. A subtle smooth center-seeking curvature/steering behavior near extreme rear corners is acceptable and may be used if Codex determines it is the best technical solution.
6. Any corner steering must be gentle, local to the rear corner region, visually unobtrusive, and must not overpower player momentum or make drinks snap sideways.
7. Drinks must not become stuck in the rear corners, tunnel through the table boundary, or oscillate unnaturally.
8. The implementation method is deliberately NOT prescribed. Codex must inspect the current RigidBody2D movement, collider/body measurements, wall/clamp system and runtime table geometry and choose the safest solution.
9. Do not regress accepted forward slide, collision, momentum transfer, same-level merge, combo, score, To-Go, persistence, Game Over, restart or rapid-launch behavior.
10. Preserve launch speed 700 px/s and deceleration 180 px/s² unless a genuine dependency is proven and documented. No arbitrary retuning.
11. Preserve the current accepted danger-line and launch-zone world positions unless a genuine dependency is proven and documented.
12. HUD placement must not define gameplay bounds.
13. Canonical PNGs are not modified.
14. Retained runtime evidence for 720x1280, 720x1440 and 800x1280 must demonstrate rear-center, rear-left and rear-right behavior for representative small/mid/large levels.
15. Evidence must make the size-aware stopping difference visible, not merely print numerical bounds.
16. Evidence must include at least one rear-corner trajectory/contact case showing any center-guidance behavior is subtle and smooth if such behavior is implemented.
17. All active M06 tests must reflect the final authoritative behavior and remain meaningful; no known failing test may simply be excluded.
18. Full active M01-M07 regression, Godot import/startup and `git diff --check` pass.
19. `TASKS.md`, ChatGPT-owned audit/prompt/criteria/policy files, historical logs and M08+ work are not modified by Codex.

Any material owner-visible rear-table mismatch or gameplay regression blocks AUDITED_PASS.
