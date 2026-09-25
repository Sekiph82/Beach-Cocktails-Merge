# BCM-M12 World Map — Final Closure Remediation Audit Criteria V02

Status: **LOCKED BEFORE EXECUTION**  
Auditor: ChatGPT  
Builder: Codex  
Branch: `main`

## Scope

This remediation exists only to clear the blockers in:
`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_FINAL_CLOSURE_V01.md`

No M13 implementation may begin.

R11 gameplay physics, accepted launch/merge behavior, V02 brand direction, Azure Bay V2 geometry authority, and the accepted Billionaire Island V2 family are frozen unless a direct defect is proven.

## Locked authorities

- `TASKS.md`
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md`
- `docs/ui-assets/TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md`
- `assets/ui_assets/tables/table_geometry_v2.json`
- `assets/ui_assets/tables/table_playable_surface_mask_v2.png`
- `assets/ui_assets/tables/table_structure_mask_v2.png`
- `assets/ui_assets/tables/table_edge_extraction_mask_v2.png`
- `assets/ui_assets/tables/table_shadow_master_v2.png`
- selected brand source `assets/ui_assets/brand/logo_concept_v02.png`

## Gate A — Canonical manifest truth

PASS requires:
- exactly 398 canonical manifest entries;
- all 398 paths present;
- every PNG decodes at declared dimensions/mode/alpha;
- every `ASSET_MANIFEST.json` SHA256 equals the current file bytes;
- related dimension/status metadata agrees with the current bytes;
- no stale pre-remediation checksum metadata remains.

## Gate B — All ten V2 table families

PASS requires all ten islands to be canonical V2 families:
- Azure Bay
- Billionaire Island
- Coconut Beach
- Final Island
- Frozen Paradise
- Party Beach
- Sunny Cove
- Sunset Island
- Tiki Island
- Volcano Bay

For every island:
- `gameplay_table.png` = 720x1280 RGBA;
- gameplay-table alpha/structural footprint matches the same canonical V2 playable + lower-structure geometry;
- rear/tabletop placement and front transition remain aligned to V2/R11;
- exactly two visible front legs/supports exist;
- progression corridor remains unobstructed;
- `table_edge_overlay.png` equals the deterministic derivation from the SAME island final `gameplay_table.png` through `table_edge_extraction_mask_v2.png`;
- the center gameplay region of the overlay is transparent/open as required;
- overlay must not be byte-identical to the full gameplay table;
- `gameplay_table_shadow.png` is an exact copy of `table_shadow_master_v2.png`;
- no island-specific geometry drift exists.

`table_geometry_v2.json` must identify all ten as V2-converted/current families.

## Gate C — Global semantic duplicate validation

PASS requires a validator/report covering the full 398-entry canonical manifest.

For every identical SHA256 group:
- paths are enumerated;
- the group is explicitly classified as intentional reuse or invalid semantic reuse;
- intentional reuse is backed by a narrow allowlist/reason;
- any semantically different assets must not remain byte-identical;
- `invalid_semantic_duplicate_count = 0`.

Known table shadows are intentional common reuse.
A gameplay table and its edge overlay are never intentional reuse.

## Gate D — Validator truth

`tools/ui_assets/validate_assets.py` or a clearly canonical replacement must:
- validate all ten table families, not a partial converted-island subset;
- verify manifest checksums from current bytes;
- enforce the V2 overlay derivation;
- enforce exact shadow-master use;
- enforce global semantic-duplicate classification;
- avoid obsolete fixed-baseline assumptions that create false protection failures;
- not reintroduce V1 table authority;
- not treat old logo-byte preservation as stronger authority than the current V02 brand contract.

The validator itself must be committed and rerunnable.

## Gate E — V02 brand preservation

PASS requires:
- `logo_concept_v02.png` remains selected source authority;
- the six canonical current brand outputs remain present;
- no brand redesign/regeneration occurs;
- manifest/checksum metadata may be updated to current truth without changing brand pixels.

## Gate F — M12 deterministic regression

PASS requires a clean Godot 4.7 validation sequence that demonstrates M12 is not relying on stale import cache.

Required evidence:
1. start from a synchronized clean checkout/worktree state;
2. regenerate/import project resources with a headless editor/import step or equivalent safe Godot 4.7 project import;
3. run `tests/m12_world_map_probe.gd`;
4. run the probe again without changing files;
5. both runs must end with `M12_WORLD_MAP_RESULT=PASS` and exit code 0.

The probe must still cover:
- data-driven WorldMapScene;
- OPEN / LOCKED / CURRENT / COMPLETE rendering;
- sequential lock enforcement;
- navigation boundaries;
- 720x1280 mobile-safe layout;
- repeated refresh without duplicate nodes;
- ten-island scalability;
- save reload/state restoration.

Do not delete, bypass, or weaken assertions to obtain PASS.

If the defect is only import/bootstrap state, repair the harness/process rather than changing valid runtime code.
If a real source/runtime defect is independently proven, make the smallest source fix and document it.

## Gate G — Regression preservation

After table and any minimal World Map remediation:
- M10 campaign architecture probe PASS;
- M11 save/migration/progression probe PASS;
- M12 World Map probe PASS;
- established relevant asset/import/HUD regressions pass;
- any known historical non-gating probe issue must be reported accurately, not hidden;
- no accepted R11 physics behavior is retuned.

## Gate H — Evidence/contact sheets

PASS requires:
- `CONTACT_SHEET_TABLES.png` rebuilt from the final ten table families;
- any other contact sheet affected by changed table/island pixels rebuilt;
- before/after or fit-proof evidence exists for the eight remediated table families;
- visual evidence shows common geometry, open overlays, exact two-leg structure, and clear progression corridor.

Any changed visible gameplay-table art remains subject to owner visual acceptance before unconditional visual closure.

## Gate I — Write scope / governance

PASS requires:
- Codex does not edit root `TASKS.md`;
- no M13 code or data is created;
- no R11 physics constants/colliders/merge/launch behavior are changed;
- Azure Bay and Billionaire Island are not redesigned;
- V02 brand pixels are not regenerated;
- builder log is committed and pushed;
- local HEAD, `origin/main`, and remote main agree at completion.

## Required builder log

Write:
`coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_FINAL_CLOSURE_V02.md`

The log must include:
- start HEAD and final HEAD;
- implementation SHA(s);
- exact changed files;
- eight-island table remediation summary;
- all-ten V2 validation result;
- manifest checksum result;
- semantic duplicate scan before/after;
- validator result;
- exact Godot import/probe commands and exit codes;
- M10/M11/M12 regression results;
- affected contact-sheet/evidence paths;
- manual checks performed/not performed;
- explicit confirmation that `TASKS.md` was not modified;
- remote synchronization proof.

## Final acceptance

`AUDITED_PASS` is allowed only if every material gate above passes or is directly owner-accepted where owner visual review is explicitly required.

Any material FAIL or UNVERIFIED remains `CHANGES_REQUIRED`.
