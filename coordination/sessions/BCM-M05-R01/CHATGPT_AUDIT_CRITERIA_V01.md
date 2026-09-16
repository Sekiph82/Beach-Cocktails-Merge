# BCM-M05-R01 — ChatGPT Audit Criteria V01

`AUDITED_PASS` requires all material criteria below to pass.

1. Single canonical L01-L12 production texture mapping remains intact.
2. Invalid levels and L13 remain safely absent.
3. Owner PNG bytes remain unchanged.
4. Per-level body measurements have explicit provenance/evidence; no false attribution to old M04 alpha-bounds work.
5. `presentation_manifest.json` or equivalent records source hash/dimensions/bbox, body measurement, runtime scale/offset/radius/mass for L01-L12.
6. `all_levels_collider_overlay.png` exists and is generated from actual production runtime scale/offset/collider APIs.
7. Overlay evidence shows all 12 levels with collider and center/pivot markers.
8. `all_levels_clean.png` exists and shows the same runtime progression without debug overlays.
9. Representative `touching_pairs.png` or equivalent contact evidence exists across small/mid/high levels.
10. No representative contact case shows a material invisible gap caused by an oversized collider.
11. No representative contact case shows extreme body overlap caused by an undersized collider.
12. Garnish/straw extremes do not materially determine collision footprint.
13. Martini/highball/goblet/coconut/pineapple shape diversity is explicitly reviewed rather than assumed correct from width alone.
14. Runtime sprite pivot/body-center alignment is visually credible for all 12 levels.
15. L01-L12 relative visual size progression is readable and bounded.
16. Collider/visual evidence is not considered proven merely because runtime values equal the same constants under test.
17. Merge result uses the correct next texture and collider atomically.
18. Merge position/momentum continuity remains valid.
19. Rapid launch preserves canonical held/current visuals.
20. Restart and Game Over leave no orphan drink visuals.
21. Compressed runtime mass progression remains intact.
22. Launch speed remains 700 px/s and deceleration 180 px/s².
23. Forward-only collision/wake/merge-momentum/L12-cap behavior remains intact.
24. M03 scoring/combo/To-Go/persistence/Game Over/restart remains intact.
25. M01-M03 regression tests pass after remediation.
26. Any existing regression test modified by Codex is inspected for weakened/circular assertions.
27. Historical pre-M05 JSON radius correction is truthfully recorded in the new log and the old immutable log is untouched.
28. Godot 4.7.x import/parse and main-scene startup pass.
29. `git diff --check` is clean.
30. No M06/M07 implementation leaks into the M05 remediation commit.
31. `TASKS.md` remains untouched by Codex.
32. ChatGPT-owned audit/criteria/prompt files remain untouched by Codex.
33. `coordination/sessions/BCM-M05-R01/CODEX_LOG_V01.md` contains exact implementation/evidence/test/push output.
34. Codex does not self-audit.
35. Any material visual-fit criterion not independently inspectable remains `UNVERIFIED` and blocks `AUDITED_PASS`.

Verdict rule:

- `AUDITED_PASS`: all material criteria pass.
- `CHANGES_REQUIRED`: any material criterion fails or remains unverified.
