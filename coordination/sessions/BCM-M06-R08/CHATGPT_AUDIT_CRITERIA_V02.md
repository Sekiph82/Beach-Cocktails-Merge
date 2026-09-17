# BCM-M06-R08 — Owner Runtime Rear-Table Physics Audit Criteria V02

Status: **LOCKED BEFORE IMPLEMENTATION — SUPERSEDES V01**

Authority: owner clarification dated 2026-09-17 after review of V01.

## Critical owner clarification
The owner does **not** want smaller cocktails to have a different rear gameplay limit from larger cocktails.

The intended physical rule is:

> **Every cocktail level L01-L12 must be able to travel until the rear-most edge of its visible glass/container body reaches and touches the same visible rear tabletop boundary.**

The cocktail center position will naturally differ by level because body sizes differ, but the **body-edge contact boundary is common**.

Do not interpret size-awareness as giving smaller drinks a farther table boundary. Size-awareness exists only to compute the correct center position required for that drink's body edge to be tangent to the same table edge.

## Observed problem
The current running build still stops cocktails too far from the visible rear tabletop edge. A substantial strip of clearly usable rear wood remains unreachable.

The owner also wants rear corner behavior to feel rounded rather than like an abrupt invisible square wall. If needed, a subtle organic tendency toward the table center may be used near the extreme rear-left/rear-right corners, provided it does not change the common rear-edge contact rule.

## Required end state
1. Every cocktail level L01-L12 can reach the same visible rear tabletop boundary with its **glass/container body rear edge tangent to that boundary**.
2. No level is intentionally assigned a farther or nearer rear table boundary than another level.
3. Per-level body size/footprint is used only to determine the cocktail center position necessary for its body edge to touch the common rear boundary.
4. Larger cocktails therefore have centers that stop farther from the rear boundary than smaller cocktails, but their visible body rear edges touch the same boundary.
5. The visible glass/container body must remain on the tabletop. Decorative garnish, fruit, straw or leaves may overhang naturally if visually credible.
6. The implementation must remove the current unjustified rear dead zone. Drinks must not stop while a visible gap remains between the glass/container body and the valid rear tabletop boundary.
7. Rear-left and rear-right corner behavior must not feel like an abrupt square collision. A subtle smooth center-seeking curvature/steering behavior near extreme rear corners is acceptable if Codex determines it is appropriate.
8. Any corner steering must be gentle, local, visually unobtrusive and must not overpower player momentum, snap drinks sideways or prevent legitimate rear-edge contact.
9. Drinks must not become stuck in rear corners, tunnel through the table boundary, oscillate unnaturally or leave the visible wooden tabletop with their glass/container body.
10. The implementation method is deliberately NOT prescribed. Codex must inspect the current RigidBody2D movement, collider/body measurements, wall/clamp system and runtime table geometry and choose the safest solution.
11. Validation must prove **body-edge tangency to the common rear boundary**, not merely center coordinates or agreement with production constants.
12. Evidence must include L01-L12 rear-contact validation, with representative small/mid/large levels shown clearly in retained runtime imagery.
13. For each validated level, evidence should make clear that the visible glass/container rear edge reaches the table boundary with no artificial gap and no body overflow.
14. Rear-left, rear-center and rear-right contact cases must be covered.
15. Do not regress accepted forward slide, collision, momentum transfer, same-level merge, combo, score, To-Go, persistence, Game Over, restart or rapid-launch behavior.
16. Preserve launch speed 700 px/s and deceleration 180 px/s² unless a genuine dependency is proven and documented. No arbitrary retuning.
17. Preserve the current accepted danger-line and launch-zone world positions unless a genuine dependency is proven and documented.
18. HUD placement must not define gameplay bounds.
19. Canonical PNGs are not modified.
20. All active M06 tests must reflect the final authoritative behavior and remain meaningful; no known failing test may simply be excluded.
21. Full active M01-M07 regression, Godot import/startup and `git diff --check` pass.
22. `TASKS.md`, ChatGPT-owned audit/prompt/criteria/policy files, historical logs and M08+ work are not modified by Codex.

Any material owner-visible rear-table mismatch or gameplay regression blocks AUDITED_PASS.
