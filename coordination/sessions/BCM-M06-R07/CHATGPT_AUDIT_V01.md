# BCM-M06-R07 — ChatGPT Strict Audit V01

Verdict: **CHANGES_REQUIRED / OWNER-VISUAL PROOF NOT INDEPENDENTLY CLOSED**

## Scope audited
- `coordination/sessions/BCM-M06-R07/CODEX_LOG_V01.md`
- locked criteria `coordination/sessions/BCM-M06-R07/CHATGPT_AUDIT_CRITERIA_V03.md`
- implementation commit `62b868fa97d482a33ae163eda5e97b9535508f5d`
- current `scripts/game_manager.gd`
- reconciled M06 baseline and R05/R06/R07 probes/datasets described in the log

## What is accepted in source/regression evidence
1. The stale baseline M06 probe is no longer simply excluded. It was reconciled to the current R07 geometry/evidence path and returns PASS.
2. Production no longer uses the R06 outer-frame samples. It now uses the R07 inner tabletop samples at five depths: `(154,472)`, `(96,620)`, `(48,800)`, `(20,1000)`, `(8,1186)` on the left and the corresponding right-side points.
3. The horizontal boundary remains piecewise rather than reverting to the old single straight interpolation.
4. HUD is not used to compute table bounds.
5. Danger/launch coordinates and the established gameplay/economy constants were preserved.
6. The active baseline M06 probe, R05 probe and current R07 geometry probe all report exit code 0 in the builder log.

## Blocking finding F-M06-R07-STRICT-001 — owner-visible result is not independently closed
The locked V03 criteria explicitly require validation to prove the **running-game visible result**, not merely agreement between production code and a test dataset.

The R07 implementation commit adds an `independent_table_edges.json` dataset and then copies those same measured values into production constants. The builder log states that clean/overlay screenshots were visually inspected by Codex, but this is builder evidence, not independent audit evidence.

The repository PNGs are present, but the current GitHub connector exposes them as binary objects without decodable pixel content in this audit environment. Therefore this audit cannot independently verify from the retained PNGs that:
- rear-left/rear-center/rear-right usable wood is genuinely reachable;
- representative cocktail glass/container bodies stay on visible wood at side/rear contacts;
- the R07 inner-edge measurements actually match the owner-visible table surface rather than another internally consistent but visually wrong boundary.

Because the previous R05/R06 rounds both produced internally green geometry tests while the owner runtime screenshot still showed a visible mismatch, this limitation is material and cannot be waived.

## Classification
- Production/source regression: **technically improved and internally consistent**.
- Full regression chain: **green per builder evidence**.
- Owner-visible geometry acceptance: **not independently proven**.

## Required closure
Do not redesign the geometry merely to satisfy this audit. The next closure must provide independently inspectable runtime evidence or fresh owner runtime evidence from the current R07 build showing rear-left, rear-center and rear-right critical placements with the glass/container body on visible wood while usable wood remains reachable.

Until that visible result is independently confirmed, M06 remains `CHANGES_REQUIRED` under the locked V03 criteria.
