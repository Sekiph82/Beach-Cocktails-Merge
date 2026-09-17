# BCM-M06-R07 — Owner Runtime Table-Playfield Audit Criteria V03

Status: **LOCKED BEFORE IMPLEMENTATION — OWNER SCREENSHOT AUTHORITY**

Authority: latest owner runtime screenshot and annotations dated 2026-09-17 18:37. This V03 supersedes V01/V02.

## Observed problem
The current running build still does not match the intended tabletop playfield:

- some cocktail glass/container bodies can visibly leave the wooden tabletop at the side/rear area;
- at the same time, cocktails still do not reach/occupy all of the rear visible tabletop that the owner expects to be playable;
- therefore the current production boundary behavior is wrong in practice even where internal geometry tests are self-consistent.

## Required end state
1. The playable region matches the actual visible wooden tabletop surface in the running game.
2. Cocktail glass/container bodies stay on visible wood and do not occupy beach/background/air outside the table.
3. Rear-left, rear-center and rear-right visible tabletop regions are reachable where there is clearly usable wood.
4. The rear/top limit does not block a substantial visible strip of tabletop that should be playable.
5. Side limits do not allow glass/container bodies to leave the table.
6. Decorative garnish/straw/fruit/leaf elements may overhang naturally, but body containment must remain visually credible.
7. HUD placement does not define or shrink gameplay boundaries.
8. Current gameplay contracts remain intact: 700 px/s launch, 180 px/s² deceleration, momentum, merge, scoring, To-Go, persistence, Game Over and restart.
9. Danger/launch behavior remains unchanged unless Codex discovers and documents a genuine dependency that must change to satisfy the owner-visible result.
10. Canonical PNGs are not modified.
11. The implementation method is deliberately NOT prescribed. Codex must inspect production geometry, runtime behavior and evidence, then choose the most appropriate technical correction.
12. Validation must prove the owner-visible result, not only agreement between production code and a test dataset.
13. Retained evidence covers 720x1280, 720x1440 and 800x1280 and visibly demonstrates rear-left/rear-center/rear-right reachability plus left/right containment.
14. At least representative small/mid/large cocktail levels are shown near critical rear/side boundaries with glass/container bodies remaining on the tabletop.
15. Any active baseline M06 test remaining in the repository must be reconciled to the authoritative current behavior rather than silently excluded.
16. Full active M01-M07 regression, Godot import/startup and `git diff --check` pass.
17. `TASKS.md`, ChatGPT-owned files and historical logs are not edited by Codex.
18. No M08+ work begins.

Any material owner-visible tabletop mismatch blocks AUDITED_PASS.