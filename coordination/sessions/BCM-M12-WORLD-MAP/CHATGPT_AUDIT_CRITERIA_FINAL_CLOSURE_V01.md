# BCM-M12 World Map — Final Closure Audit Criteria V01

Status: LOCKED BEFORE EXECUTION
Auditor: ChatGPT
Builder: Codex
Branch: main

## Scope

This is the final M12 closure preparation/audit cycle.

No image generation is permitted in this cycle.
No canonical production PNG may be redesigned or regenerated.
No M13 implementation may begin.

The builder may only:
- validate the final visual library;
- validate V2 table families;
- confirm the selected V02 canonical brand state;
- rebuild evidence-only contact sheets from current canonical pixels;
- update visual-task/documentation state where explicitly allowed;
- run existing M12 regression tests;
- write the builder log.

Codex must not edit `TASKS.md`.

## Locked authorities

- `TASKS.md`
- `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md`
- `docs/ui-assets/TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md`
- `assets/ui_assets/tables/table_geometry_v2.json`
- current canonical assets on `main`
- selected brand source: `assets/ui_assets/brand/logo_concept_v02.png`

V1 table silhouette/mask geometry is historical only and is not acceptance authority.

## Audit gates

### A. Manifest / canonical asset integrity

PASS requires:
- all 398 canonical manifest target paths present;
- declared PNGs decode;
- dimensions match declarations;
- required transparency/alpha is valid;
- no empty/corrupt production assets;
- full duplicate-SHA scan completed across canonical manifest assets;
- every duplicate group classified as intentional reuse or invalid semantic reuse;
- invalid semantic duplicate count = 0.

### B. V2 table family integrity

PASS requires all 10 island table families to satisfy current V2 rules:
- `gameplay_table.png` is 720x1280 RGBA;
- R11/V2 structural geometry is preserved;
- rear/tabletop placement is preserved;
- front tabletop transition is approximately y=988.333;
- exactly two visible front legs/supports;
- L01-L12 progression corridor remains unobstructed;
- `table_edge_overlay.png` is derived/aligned to its island final gameplay table;
- `gameplay_table_shadow.png` matches the fixed V2 shadow recipe/master;
- no island-specific geometry drift.

No V1 mask requirement may be used to fail a valid V2 full-table asset.

### C. Brand canonical state

The owner selected `logo_concept_v02.png`.

PASS requires the following current files to remain the accepted canonical brand family:
- `assets/ui_assets/brand/app_icon.png`
- `assets/ui_assets/brand/brand_badge_small.png`
- `assets/ui_assets/brand/brand_wordmark_small.png`
- `assets/ui_assets/brand/legal_logo_mark.png`
- `assets/ui_assets/brand/logo_beach_cocktails_merge.png`
- `assets/ui_assets/brand/splash_logo.png`

The old byte-for-byte owner-logo preservation rule is superseded.
No brand regeneration is allowed in this closure cycle.

### D. Visual-task state cleanup

PASS requires:
- VA-348, 349, 350, 351, 352, 358, 359, 360, 362, 367, 370, 371, 372, 373, 374, 375 marked complete because their current assets were already regenerated and owner accepted;
- VA-176 through VA-182 rebuilt as evidence-only contact sheets from current canonical assets and marked complete;
- obsolete V1-table and old-logo completion assumptions superseded in the active visual tracker;
- `ui-assets-tasks.md` receives only a concise historical/superseded note, not a mass fake completion.

### E. M12 World Map regression

PASS requires existing M12 focused tests to confirm:
- data-driven WorldMapScene;
- island state rendering;
- OPEN / LOCKED / CURRENT / COMPLETE behavior;
- sequential island lock enforcement;
- navigation boundaries;
- mobile-safe layout;
- save reload/state restoration.

If an actual runtime/source regression is found, closure fails and Codex must not silently broaden scope to unrelated remediation.

### F. Write-scope integrity

PASS requires:
- no canonical production PNG modified except evidence-only contact sheets;
- no table/brand/global UI production art regenerated;
- no M13 code created;
- `TASKS.md` untouched by Codex;
- builder log committed.

## Required builder evidence

Codex must write:

`coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_FINAL_CLOSURE.md`

It must include:
- start HEAD;
- changed files;
- manifest validation result;
- duplicate semantic scan result;
- V2 10-table result;
- V02 brand-state confirmation;
- contact-sheet result;
- M12 regression result;
- visual task tracker result;
- implementation SHA;
- final main HEAD.

## Independent audit procedure

After Codex stops with `AWAITING_M12_FINAL_AUDIT`, ChatGPT will independently inspect:
- actual Git diff;
- builder log;
- changed tracker files;
- contact-sheet outputs;
- duplicate evidence;
- V2 table validation evidence;
- M12 regression evidence.

ChatGPT will then commit the independent audit as:

`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_FINAL_CLOSURE_V01.md`

If PASS, ChatGPT, not Codex, will update root `TASKS.md` to close M12 and advance the canonical next action to M13.
If CHANGES_REQUIRED, ChatGPT will update `TASKS.md` accordingly and create the next locked remediation prompt/criteria before further Codex execution.
