# BCM-M12 World Map — Final Closure Remediation V02

Execute this remediation against:
- `coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_FINAL_CLOSURE_V01.md`
- `coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_FINAL_CLOSURE_V02.md`

Read `AGENTS.md`, `TASKS.md`, both V2 table contracts, and the locked V02 criteria before editing.

## Primary objective

Clear the three M12 closure blockers without starting M13:

1. convert the remaining eight island table families to the canonical Azure Bay V2 structure;
2. synchronize canonical manifest/checksum truth and enforce global semantic duplicate validation;
3. restore deterministic M12 World Map probe PASS from a clean Godot 4.7 import state.

## Table remediation

Do NOT redesign Azure Bay or Billionaire Island.

Remediate exactly these remaining islands:
- Coconut Beach
- Final Island
- Frozen Paradise
- Party Beach
- Sunny Cove
- Sunset Island
- Tiki Island
- Volcano Bay

For each:
1. treat the current island `gameplay_table.png` as island-specific source/material art, not geometry authority;
2. deterministically fit/promote the final table to the canonical V2 playable + structure footprint;
3. preserve island material/color/motif as much as possible;
4. preserve rear/tabletop transition, two-leg structure, and progression clearance;
5. derive `table_edge_overlay.png` from the FINAL table using `table_edge_extraction_mask_v2.png`;
6. do not reuse the full table bytes as overlay;
7. copy `table_shadow_master_v2.png` exactly as the island shadow;
8. produce fit-proof evidence.

No independent AI-generated overlay or shadow geometry is allowed.
Do not retune R11 gameplay physics.

Promote all ten islands in `table_geometry_v2.json` only after they actually pass V2 validation.

## Manifest / validator remediation

Regenerate `ASSET_MANIFEST.json` SHA256/provenance from current final bytes so every manifest checksum is truthful.

Synchronize any related dimensions/status metadata required by the canonical validation path.

Extend the canonical validator so it:
- checks all 398 current manifest paths/checksums;
- checks all ten V2 table families;
- reconstructs/compares expected overlays from each final gameplay table + extraction mask;
- requires exact shadow-master use;
- scans every duplicate SHA256 group across all 398 manifest assets;
- emits paths + classification + allowlist reason;
- fails when `invalid_semantic_duplicate_count > 0`;
- does not rely on stale V1 table or obsolete logo-preservation authority;
- does not use a stale fixed baseline that produces false scope failures.

Do not blindly regenerate unrelated assets. Preserve already-remediated global UI and selected V02 brand pixels.

## M12 regression diagnosis

The previous closure probe failed on World Map PNG preloads/resource loading.

Diagnose before editing source.

Use a clean synchronized state and perform the normal Godot 4.7 headless editor/import bootstrap first.

Run:
- M12 probe after import;
- M12 probe a second time with no intervening file changes.

Both runs must PASS.

If this is only an import/cache bootstrap issue, fix the execution/validation harness and leave valid runtime source unchanged.

If a real source defect is proven, make the smallest bounded correction. Do not weaken `tests/m12_world_map_probe.gd`, delete assertions, or hardcode test-only bypasses.

## Regression and evidence

Run M10, M11 and M12 focused probes plus the established relevant asset/import/HUD regression set.

Rebuild `CONTACT_SHEET_TABLES.png` and any other contact sheet affected by changed table pixels.

Do not begin M13.

Do not edit root `TASKS.md`.

## Builder log

Write and commit:
`coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_FINAL_CLOSURE_V02.md`

Return only:
- implementation SHA;
- final main HEAD;
- invalid semantic duplicate groups before/after;
- all-ten V2 validation result;
- manifest checksum result;
- M12 run 1 / run 2 results;
- regression result;
- builder log GitHub URL;
- `AWAITING_M12_FINAL_AUDIT_V02`.

Then STOP.
