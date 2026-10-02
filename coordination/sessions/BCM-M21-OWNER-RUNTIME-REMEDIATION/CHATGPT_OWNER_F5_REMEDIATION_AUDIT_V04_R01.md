# BCM-M21 Owner F5 Remediation V04-R01 — Independent Audit

Verdict: **TECHNICAL_AUDITED_PASS / OWNER_F5_ACCEPTANCE_REQUIRED**

Auditor: ChatGPT  
Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`  
Audited HEAD: `abb60b3b08621e37deaeb90f36a81159f4c2e19c`

## 1. Sync / preservation

V04-R01 began from the guarded sync-preserve path.

Builder evidence records:
- tracked-only stash preserved the two pre-existing modified scripts;
- 14 generated `.translation` sidecars remained untracked and untouched;
- incoming commits did not touch the two preserved scripts;
- fast-forward sync completed;
- stash was applied without conflict;
- restored hunks were whitespace/indent-only under ignore-all-space classification;
- stash remains retained as rollback evidence.

No owner-local content loss is evidenced.

## 2. World Map calibration — TECHNICAL PASS

The canonical campaign data now contains calibrated positions for all ten islands.

Runtime report records all ten centers and a 720×1280 capture.

Requirements preserved:
- duplicate island thumbnails hidden;
- no runtime route Line2D;
- one center shared by marker/ring/state/click target.

Final subjective centering remains an owner F5 visual gate.

## 3. Sunny Cove landmark pages — PASS

Sunny Cove island map metadata is data-driven and includes:
- `page_size = 10`;
- `connector_lines = false`;
- owner-authored landmark centers;
- repeated island-map background pages.

The controller maps each level to:
- slot = (level-1) mod 10;
- page = floor((level-1)/10).

Evidence proves:
- L1-L10 use slots 1-10 on page 1;
- L51-L60 reuse the same slots on page 6;
- the model scales through L100;
- Sunny Cove does not use the old zig-zag fallback;
- connector path is not visible.

## 4. Table +150 px rigid translation — PASS

`V04_TABLE_TRANSLATION_INVARIANCE.json` records:
- canonical shift = 150 px;
- viewport shift = 150 px;
- max source-point error = 0;
- max rail-query error = 0;
- max physics-wall midpoint error = 0;
- max rail-shape error ≈ 0.000061 px.

This is consistent with a rigid translation rather than a rail-shape retune.

Background/HUD remain fixed while the table/playable coordinate system shifts.

## 5. Launch/decor cleanup — PASS technically

Runtime layer inventory confirms:
- gameplay_background visible;
- gameplay_table_shadow visible;
- gameplay_table visible;
- table_edge_overlay visible;
- full-screen `launch_zone.png` not instantiated;
- `decor_left/right/back` not present as runtime texture nodes.

Launch mechanics remain represented by a programmatic line.

No canonical PNG was modified.

## 6. Result lifecycle — PASS

Source inspection confirms:
- result creation is deferred;
- result CanvasLayer is owned under `CampaignNavigationController`, not synchronously added to SceneTree root;
- pending terminal payload is retained;
- presentation waits for `is_node_ready()`;
- `CampaignFeedbackOverlay._show()` guards shell controls before assignment.

Production probe log confirms:
- `ERROR:` count = 0;
- `SCRIPT ERROR:` count = 0;
- `Parent node is busy setting up children` count = 0;
- `Invalid assignment ... on Nil` count = 0;
- first WIN appears once;
- terminal WIN hides all Drink nodes;
- transient world effects count = 0;
- second WIN reuses result surface correctly;
- Island Map action is available;
- LOSE result appears;
- Retry restarts the same level with one live gameplay instance.

Terminal report:
- visible Drink count = 0;
- visible transient world effect count = 0;
- result canvas layer = 2;
- result canvas parent = CampaignNavigation.

## 7. Input / no-timer preservation — PASS

V04 production-path probe reports:
- mouse shots = 10/10;
- touch shots = 10/10;
- direct launch method calls = 0;
- untimed one-hour survival passes;
- pause/resume remains valid.

## 8. Regression — PASS

Builder evidence records PASS for the required current regression surface, including:
- M02;
- M03;
- M07-R06;
- M08;
- M09;
- untimed M14/M15/M16;
- M18;
- M19;
- M20;
- M21 progression 100/100;
- persistence;
- import/parse;
- `git diff --check`.

Headless capture limitations were rerun under GUI GL compatibility and passed.

Historical superseded R10 probes remain non-gates.

## 9. Owner checklist

`OWNER_F5_ACCEPTANCE_CHECKLIST_V04.md` exists with all owner PASS/FAIL fields blank.

Builder did not claim owner acceptance or release-ready status.

## 10. Final verdict

**TECHNICAL_AUDITED_PASS.**

No further CODEX remediation is authorized unless the owner F5 V04 review identifies a defect.

- BCM-M21-004 may return to technical PASS.
- BCM-M21-001 remains pending owner visual/input acceptance.
- BCM-M21-006 remains pending owner F5 acceptance and final release closure.

Next actor: **OWNER**.

Required marker after owner review:
- all checklist items PASS → final M21 closure may be recorded;
- any FAIL → release remains blocked and the failing owner-visible surface must be remediated.
