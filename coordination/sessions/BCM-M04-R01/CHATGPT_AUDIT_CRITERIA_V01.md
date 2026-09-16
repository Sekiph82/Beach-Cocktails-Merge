# BCM-M04-R01 — ChatGPT Audit Criteria V01

`AUDITED_PASS` requires all material criteria below to pass.

1. Exact 22-file canonical asset set is checked against repository truth, not only a hardcoded expected-count echo.
2. Every required asset exists, is tracked, non-empty, and loads successfully.
3. Cocktails L01-L12 have usable transparency and non-empty alpha bounds.
4. UI/effect assets expected to be transparent have usable transparency and non-empty alpha bounds.
5. Environment opacity/transparency policy is explicitly allowed and correctly classified.
6. Validator fails on contract violations instead of merely printing metrics and returning PASS.
7. Godot asset-load probe does not claim an observed count by echoing the expected list length.
8. `guide_line` remains absent.
9. Best Score / Score source dimension delta is truthfully retained; no source PNG is edited to hide it.
10. `docs/evidence/m04/cocktails_contact_sheet.png` exists and contains labelled L01-L12 evidence.
11. `docs/evidence/m04/ui_contact_sheet.png` exists and contains all canonical M04 UI assets.
12. Environment and effect visual evidence is retained under `docs/evidence/m04/`.
13. A retained owner-master visual reference exists or is deterministically referenced from the root master.
14. `manifest.json` (or equivalent) maps every canonical asset to SHA256, dimensions, alpha result/bbox and visual-evidence location.
15. Progression-strip evidence makes exactly 12 empty slots independently countable.
16. Cocktail semantic evidence makes each L01-L12 straw/garnish claim inspectable and clearly labels it manual visual evidence rather than machine proof.
17. Environment evidence supports the claim that no dynamic HUD/gameplay pieces are baked into the canonical environment asset.
18. To-Go and Next panel evidence supports blank dynamic content/preview areas.
19. Launch-zone evidence supports transparent center and no forbidden clutter/guide graphics.
20. To-Go trail evidence supports the intended simplified trail semantics.
21. Separated assets are explicitly mapped back to the owner-master visual direction.
22. The guide-line shown in the old owner master is explicitly documented as intentionally excluded by later owner direction, not accidentally reintroduced.
23. Canonical source PNG hashes remain unchanged from pre-remediation unless an explicit owner-approved source correction exists.
24. Godot 4.7.x import/parse and main-scene startup pass.
25. `git diff --check` is clean.
26. No M05/M06/M07 production implementation leaks into the M04 remediation commit.
27. `TASKS.md` remains untouched by Codex.
28. ChatGPT-owned audit/criteria/prompt files remain untouched by Codex.
29. `coordination/sessions/BCM-M04-R01/CODEX_LOG_V01.md` contains exact implementation/test/evidence/push output.
30. Codex does not self-audit.
31. Any material visual criterion not independently inspectable remains `UNVERIFIED` and blocks `AUDITED_PASS`.

Verdict rule:

- `AUDITED_PASS`: all material criteria pass.
- `CHANGES_REQUIRED`: any material criterion fails or remains unverified.
