# BCM-M12 World Map — Final Closure Independent Audit V01

Verdict: **CHANGES_REQUIRED**

Auditor: ChatGPT  
Builder: Codex  
Branch: `main`  
Audited start HEAD: `28f32f4d5a34fa8b5a433389486c8c57bcc0400b`  
Implementation commit: `a1370fc3acd1533850dae01957a1f229440f3ca3`  
Audited final builder HEAD: `62c6255825b97c2e44594cadb316e8239f7b8b0e`

Locked criteria:
`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_FINAL_CLOSURE_V01.md`

Execution prompt:
`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_EXECUTION_PROMPT_FINAL_CLOSURE_V01.md`

Builder log:
`coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_FINAL_CLOSURE.md`

## 1. VERDICT

**CHANGES_REQUIRED.**

M12 cannot close. Three material blockers remain:

1. Eight island table families still violate the V2 table-production rulechain because `table_edge_overlay.png` is byte-identical to the island `gameplay_table.png`.
2. Canonical asset metadata is not synchronized with current repository bytes: `ASSET_MANIFEST.json` still records historical duplicate SHA256 values for assets whose current Git blobs are distinct.
3. The focused M12 World Map probe did not reach PASS.

No M13 implementation may begin.

## 2. CONTRACT RECOVERY

The controlling acceptance contract is Final Closure Audit Criteria V01.

The mandatory V2 authorities are:
- `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md`
- `docs/ui-assets/TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md`
- `assets/ui_assets/tables/table_geometry_v2.json`
- `table_playable_surface_mask_v2.png`
- `table_structure_mask_v2.png`
- `table_edge_extraction_mask_v2.png`
- `table_shadow_master_v2.png`

Azure Bay remains the owner-approved V2 structural authority. R11 gameplay physics remain frozen.

## 3. BRANCH / HEAD / DIFF SCOPE

At audit start, GitHub `main` resolved to `62c6255825b97c2e44594cadb316e8239f7b8b0e`.

Independent compare from `28f32f4d...` to `62c6255...` shows exactly two commits and only:
- seven evidence-only contact sheets;
- `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md`;
- `ui-assets-tasks.md`;
- the immutable Codex closure log.

No production table PNG, brand PNG, World Map source, M13 code, or root `TASKS.md` was modified by this closure cycle.

## 4. ACCEPTANCE CRITERIA MATRIX

| Gate | Result | Independent finding |
| --- | --- | --- |
| A. Manifest / canonical asset integrity | **FAIL** | 398/398 manifest paths exist, but invalid semantic duplicate count is not zero. Manifest SHA metadata is also stale relative to current bytes. |
| B. V2 table family integrity | **FAIL** | Only Azure Bay and Billionaire Island are listed as V2-converted. Eight remaining island overlays are byte-identical to their gameplay tables. |
| C. Brand canonical state | **PASS** | V02 source and the six canonical brand outputs exist; closure diff did not modify brand PNGs. |
| D. Visual-task state cleanup | **PARTIAL** | Requested tracker rows and seven contact sheets were updated. Binary visual content of every sheet was not independently render-inspected in this connector audit. |
| E. M12 World Map regression | **FAIL / UNVERIFIED** | Builder probe did not reach PASS. Static source review confirms PNG preloads are in the World Map controller; runtime root cause is not independently reproduced here. |
| F. Write-scope integrity | **PASS** | Closure changes stayed inside allowed evidence/docs scope and `TASKS.md` was untouched by Codex. |

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH

Builder claim: 398/398 canonical paths present.  
Independent result: **confirmed**. `ASSET_MANIFEST.json` contains 398 entries and repository tree contains all 398 paths.

Builder claim: eight invalid gameplay-table / edge-overlay duplicate groups.  
Independent result: **confirmed exactly at Git blob level** for:
- Coconut Beach
- Final Island
- Frozen Paradise
- Party Beach
- Sunny Cove
- Sunset Island
- Tiki Island
- Volcano Bay

For each of those eight islands, `gameplay_table.png` and `table_edge_overlay.png` have the exact same Git blob SHA and size.

Azure Bay and Billionaire Island have distinct gameplay-table and overlay blobs and are not part of this defect.

Builder claim: all shadows are pixel-equal to the V2 shadow master.  
Independent result: **not independently pixel-verified** in this audit. Repository compression/blob identities differ across two shadow families, which does not by itself disprove pixel equality.

Builder claim: M12 regression failed.  
Independent result: **accepted as blocking builder evidence and consistent with the locked gate**. No PASS evidence exists for this closure cycle.

## 6. FILE / SYMBOL EVIDENCE

`assets/ui_assets/tables/table_geometry_v2.json` currently lists only:
- `azure_bay`
- `billionaire_island`

under `v2_converted_islands`.

`scripts/campaign/world_map_controller.gd` preloads:
- `world_map_background.png`
- `world_clouds_front.png`
- `world_map_title_panel.png`
- `world_map_compass.png`
- `world_map_boat.png`

and `WorldMapScene.tscn` attaches that controller as its root script.

The current validator `tools/ui_assets/validate_assets.py` validates V2 structure/overlay/shadow only for islands listed in `v2_converted_islands`, so the final ten-island closure is not yet enforced by the validator.

## 7. FOCUSED TEST EVIDENCE

The builder reports `tests/m12_world_map_probe.gd` failed before completing its assertions because World Map PNG preloads produced resource-loader parse errors and the scene then could not accept the injected `level_database`.

This auditor environment does not contain Godot 4.7, so the runtime failure cannot be independently rerun here.

Because the locked criterion requires a successful focused M12 test, absence of a PASS is itself blocking.

## 8. REGRESSION EVIDENCE

The closure diff contains no World Map runtime/source changes, so the failing probe was not introduced by the two closure commits.

Earlier V05 builder evidence reported M12 PASS after a headless Godot editor import scan. Therefore the present failure may be an import/bootstrap/harness-state problem rather than a newly introduced functional World Map defect.

That distinction must be diagnosed in remediation. The test must not be weakened merely to obtain PASS.

## 9. SECURITY / SAFETY REVIEW

No secret-bearing files, local caches, build output, or destructive Git operations are present in the audited closure diff.

No evidence of scope expansion into unrelated gameplay systems was found.

## 10. ARCHITECTURE CONSISTENCY

World Map architecture remains data-driven at source level: scene/controller accept `LevelDatabase` and `CampaignManager` state and render campaign destinations from definitions.

The table visual library is not architecture-consistent with V2 because eight island families have not been promoted to the same derived-overlay geometry pipeline as Azure Bay and Billionaire Island.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS

The Codex log correctly disclosed both major blockers and correctly left root `TASKS.md` unchanged.

However `assets/ui_assets/ASSET_MANIFEST.json` is not truthful as current checksum metadata. Example: the current global button variants have distinct Git blobs, while the manifest still assigns the same historical SHA256 to disabled/locked/primary/secondary/small buttons. The manifest likewise records historical shared overlay hashes inconsistent with current Azure/Billionaire bytes.

Manifest hashes/source metadata must be regenerated from the actual final bytes before M12 closure.

## 12. FINAL REPOSITORY STATE

Audited builder state:
- branch: `main`
- builder final HEAD: `62c6255825b97c2e44594cadb316e8239f7b8b0e`
- builder closure worktree claim: clean/synchronized
- root `TASKS.md`: unchanged by Codex

ChatGPT-owned audit/remediation/tracker commits follow this audited builder state.

## 13. OPEN CROSS-MILESTONE FINDINGS

- M13 remains deferred.
- R11 physics must remain unchanged.
- V02 brand direction remains selected and protected.
- Azure Bay and Billionaire Island V2 families are the current converted baseline and should not be redesigned during the eight-island remediation.

## 14. DEFECTS BY SEVERITY

### BLOCKER

**B1 — Eight invalid V2 overlay families**

For eight islands, `table_edge_overlay.png` is exactly the same file as `gameplay_table.png`. This violates the mandatory extraction-mask derivation rule and leaves the center gameplay region non-transparent.

### BLOCKER

**B2 — M12 regression has no PASS**

The focused World Map probe fails during resource/scene setup. The locked closure gate cannot pass without deterministic M12 PASS evidence.

### MAJOR

**M1 — Manifest checksum metadata is stale**

`ASSET_MANIFEST.json` SHA256 entries do not describe the current repository bytes for multiple remediated assets. This breaks manifest truth and weakens any checksum-driven duplicate audit.

### MAJOR

**M2 — Ten-island V2 enforcement is incomplete**

`table_geometry_v2.json` lists only two converted islands, and the validator checks only that list. Final closure requires all ten families.

### NOTE

Seven contact sheets were rebuilt and their file changes are verified, but full pixel-level visual inspection of all seven is not independently available through this connector audit.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES

Update `tools/ui_assets/validate_assets.py` so final closure is self-policing:
- all 10 islands are mandatory V2 families;
- current manifest SHA256 values must equal actual bytes;
- duplicate SHA groups are globally classified through an explicit allowlist;
- invalid semantic duplicate count must be zero;
- V02 brand authority replaces obsolete historical logo-preservation assumptions where they conflict;
- no stale fixed start-commit constant may create false results.

## 16. UNVERIFIED ITEMS

- Pixel equality of every island shadow against `table_shadow_master_v2.png`.
- Pixel-level content quality of all seven rebuilt contact sheets.
- Exact runtime cause of the M12 PNG preload/scene setup failure.
- Owner visual acceptance of any table art changed in the next remediation.

These items do not rescue the current audit because independent blockers already fail locked criteria.

## 17. REGRESSION RISK

**MEDIUM.**

The closure commits themselves are documentation/evidence-only, but the required remediation will touch eight production table families and may touch the World Map load/test path. R11 gameplay physics must remain frozen.

## 18. AUDIT CONFIDENCE

**HIGH** for the CHANGES_REQUIRED verdict.

The table-overlay defect is directly proven from repository blob identities, the incomplete V2 conversion list is directly present in canonical geometry data, manifest drift is directly evidenced by mismatch between manifest duplicate hashes and distinct current Git blobs, and the builder itself reports the required M12 test did not pass.

## 19. FINAL VERDICT

**CHANGES_REQUIRED.**

M12 remains open.

## 20. REQUIRED REMEDIATION

1. Convert the remaining eight islands to the canonical V2 table family without redesigning Azure Bay or Billionaire Island:
   - Coconut Beach
   - Final Island
   - Frozen Paradise
   - Party Beach
   - Sunny Cove
   - Sunset Island
   - Tiki Island
   - Volcano Bay
2. Preserve each island's material/art language but fit `gameplay_table.png` to the exact canonical V2 playable + structure footprint.
3. Derive each `table_edge_overlay.png` from that island's final table through `table_edge_extraction_mask_v2.png`; full-table byte reuse is forbidden.
4. Use `table_shadow_master_v2.png` exactly for every island shadow.
5. Promote all ten islands in `table_geometry_v2.json` and make the validator enforce all ten.
6. Rebuild current SHA256/provenance metadata in `ASSET_MANIFEST.json` and related status/dimension reports from the actual final bytes.
7. Extend duplicate validation to the full 398-entry manifest with an explicit intentional-reuse allowlist and `invalid_semantic_duplicate_count = 0`.
8. Diagnose the M12 probe from a clean Godot 4.7 import state. Fix the import/test harness if that is the defect; make the smallest source fix only if a real runtime bug is proven. Do not weaken probe assertions.
9. Rerun focused M10/M11/M12 and the established regression set after remediation.
10. Rebuild affected table/island contact sheets and provide owner-review evidence for changed visible table art.
11. Codex must not edit root `TASKS.md` and must stop for independent audit.
