# BCM-M21-007 — R04 Repository Hygiene Independent Audit V01

Date: 2026-10-04  
Auditor: ChatGPT  
Builder handoff HEAD: `fdd1e5349c07594dfa8be616e6dd9bd8f9f7bd21`  
Baseline: `6febc28526ba43691e003f64f5a4c8d1e3665e06`

## 1. VERDICT

**CONDITIONAL — CLEANUP_SCOPE_PASS / M21_WORLD_MAP_REGRESSION_REMAINS_OPEN**

The repository-hygiene work itself is accepted. The cleanup did not delete protected current R04 authority, did not touch owner-local plugin/project files, and did not modify root `TASKS.md`.

M21 cannot close because the current M12 World Map 720×1280 layout regression probe is not green. That failure is independently shown to be outside the cleanup's causal scope, but it is still a current release regression and must be resolved or reclassified by a bounded M21-001 remediation before M21 release closure.

## 2. CONTRACT RECOVERY

Locked authority reviewed:
- `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/OWNER_RULING_R04_REPOSITORY_HYGIENE_V01.md`
- `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_R04_REPOSITORY_HYGIENE_CRITERIA_V01.md`
- `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_R04_REPOSITORY_HYGIENE_PROMPT_V01.md`
- `docs/ui-assets/GAMEPLAY_SURFACE_CONTRACT_V07_R04.md`
- `AGENTS.md`

Protected per-island authority is:
- `gameplay_surface_v07_r04.png`
- `gameplay_surface.png`
- `playable_geometry_r04.json`
- `complete_badge.png`
- `map_background.png`
- `map_title.png`
- `theme_badge.png`
- `world_icon.png`

The owner has already accepted the current R04 gameplay surfaces/playable geometry for all ten islands.

## 3. BRANCH / HEAD / DIFF SCOPE

Independent compare `6febc285...fdd1e534`:
- 4 commits;
- 165 changed tracked paths;
- 136 tracked removals;
- 25 modifications;
- 4 additions;
- root `TASKS.md`: untouched;
- `project.godot`, `scenes/main.tscn`, and `addons/**`: not touched by the published diff.

The 136 tracked-removal count exactly matches the builder manifest.

## 4. ACCEPTANCE CRITERIA MATRIX

| Criterion | Result | Independent finding |
| --- | --- | --- |
| A. Pre-delete inventory | **PASS** | Committed inventory declares `inventory_generated_before_deletion=true`, 1,269 candidates: KEEP 840 / DELETE 335 / REVIEW 94. |
| B. Protected ten-island packs | **PASS** | All 80 protected island files remain. No protected path appears in the removal diff. |
| C. Godot import cleanup | **PASS WITH EVIDENCE LIMIT** | Inventory records 199 DELETE import sidecars with none marked existing after cleanup; reference audit reports orphan count 0; clean Godot import passed. Ignored local sidecars are not independently visible from GitHub remote. |
| D. Superseded visual-pipeline cleanup | **PASS** | Rejected R03 candidates, superseded R04 draft/review sets, retired V1/V2 table metadata, old M06/R09 evidence, stale visual probes/helpers were removed within authorized scope. |
| E. Evidence cleanup | **PASS** | Current nonvisual campaign/VIP/difficulty/mastery evidence remains; rejected/retired visual evidence is selectively removed rather than indiscriminately wiped. |
| F. JSON / manifest / catalog cleanup | **PASS** | Current manifest has 356 entries and no sampled deleted-path hits. Ten `playable_geometry_r04.json` profiles remain. |
| G. Test/rule cleanup | **PASS** | Retired split-table probes were removed; active campaign/gameplay fixtures were reconciled to R04. |
| H. `game_board_background.png` | **PASS** | Legacy file removed; top-level `map_background` fields removed; LevelDatabase no longer requires them; current gameplay uses per-island R04 surface and Island Map uses `theme.island_map_background`. |
| I. No broken current references | **PASS** | Reference audit reports zero active exact refs to deleted paths; active R04 probes and campaign probes load. |
| J. Required tests | **PARTIAL** | R04, asset, gameplay, M10/M11/M13-M20 selected regressions pass. M12 World Map has one current 720×1280 layout assertion failure. |
| K. Evidence/handoff | **PASS** | Inventory, deletion manifest, reference audit, builder log, commit chain, and final equality are published. |

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH

Verified:
- **136 tracked files removed**: exact diff count matches.
- **199 generated/untracked import deletions**: committed inventory contains 199 DELETE import records; none are marked present after cleanup.
- **94 REVIEW preserved**: all 94 inventory REVIEW records remain marked present/retained; zero REVIEW item is marked deleted.
- **840 KEEP preserved**: zero KEEP item is marked deleted/missing in the committed inventory.
- **TASKS untouched by Codex**: confirmed in compare.
- **owner-local project/plugin paths excluded**: confirmed in published diff.
- final remote handoff HEAD is `fdd1e5349c07594dfa8be616e6dd9bd8f9f7bd21`.

## 6. FILE / SYMBOL EVIDENCE

All ten island source/runtime PNG pairs have identical Git blob SHAs per island.

All ten profiles:
- schema version 1;
- correct island id;
- canonical `gameplay_surface.png` path;
- matching R04 source path;
- equal source/runtime SHA-256 inside each profile;
- viewport 720×1280;
- 24-point gameplay polygon;
- shared `launch_y=963`, `spawn_y=963`, `death_y=846`.

Current `ASSET_MANIFEST.json` parses to 356 entries.

## 7. FOCUSED TEST EVIDENCE

Builder evidence records PASS for:
- `tools/ui_assets/validate_assets.py` — 356/356, R04 10/10;
- R04 surface authority probe — 10 islands / 71 checks;
- Godot asset import — 25/25;
- R10 V10 containment;
- M21 V07-R02 gameplay probe — 10/10 mouse + 10/10 touch;
- clean Godot 4.7.2 import/parse;
- `git diff --check`.

These claims are consistent with the current source/diff and protected-asset inventory.

## 8. REGRESSION EVIDENCE

Selected campaign/gameplay probes reported PASS:
M10, M11, M13, M14, M15, M17, M18, M19, M20.

Current M12 World Map probe reports one failure in the 720×1280 geometry cleanliness gate.

## 9. SECURITY / SAFETY REVIEW

No secrets, package credentials, export signing material, or unsafe runtime dependency changes were introduced by the cleanup.

The cleanup used explicit path classification rather than repository-wide destructive clean/reset.

## 10. ARCHITECTURE CONSISTENCY

The cleanup improves architectural consistency:
- one per-island R04 gameplay-surface authority;
- one per-island R04 geometry profile;
- no generic gameplay background fallback;
- no current split-table V1/V2 runtime authority;
- current Island Map background remains separate under `theme.island_map_background`.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS

Builder log truthfully reports:
- the M12 failure;
- absence of headless visual screenshots;
- preservation of owner-local files;
- `TASKS.md` unchanged;
- builder evidence only, not self-acceptance.

No false release-ready claim was found.

## 12. FINAL REPOSITORY STATE

Published HEAD:
`fdd1e5349c07594dfa8be616e6dd9bd8f9f7bd21`

Builder records local HEAD = `origin/main` = remote main and `0/0` divergence at publication.

## 13. OPEN CROSS-MILESTONE FINDINGS

### M12 720×1280 World Map geometry gate

This is a real current regression gate, but it was **not introduced by BCM-M21-007**:

- `scripts/campaign/world_map_controller.gd` is byte-identical between cleanup baseline `6febc285...` and handoff `fdd1e534...`.
- `tests/m12_world_map_probe.gd` changed only to remove the retired `map_background` fixture field; the geometry assertions themselves are unchanged.
- current canonical map positions were established before cleanup.
- `get_layout_report()` sets the field named `horizontal_clipping` when **either X or Y** is outside the MapCanvas.
- at a 720×1280 viewport, MapCanvas height is approximately 962 px. Current Frozen Paradise `map_position.y=0.005` gives marker top roughly `-53 px` in MapCanvas coordinates; Volcano Bay `y=0.015` gives roughly `-44 px`. Therefore the current report necessarily flags clipping with the current 136×116 IslandEntry rectangle.

This may be:
1. a stale test/report definition relative to intentionally calibrated semantic marker centers; or
2. a real visible header/marker overlap.

Headless capture cannot distinguish those. A real GUI/Godot-AI visual inspection is required before changing marker positions or weakening the assertion.

## 14. DEFECTS BY SEVERITY

### BLOCKER

None for the cleanup product itself.

### MAJOR

**M12 current 720×1280 World Map geometry assertion is failing.** M21 release closure cannot proceed until the failure is diagnosed and resolved.

### MINOR

The 199 ignored/untracked sidecar deletions cannot be independently observed from GitHub after deletion; audit relies on the committed pre/post inventory, reference audit, and clean-import result.

### NOTE

94 ambiguous candidates were correctly retained as REVIEW. They are not cleanup defects.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES

- Rename/split `horizontal_clipping` so vertical clipping is not reported under a horizontal-only label.
- Make World Map layout reporting measure the actual visible/interactable marker footprint rather than hidden or non-authoritative child extent where appropriate.
- Add a renderer-capable visual-capture path; headless null viewport textures are insufficient for owner-facing layout acceptance.

## 16. UNVERIFIED ITEMS

- physical local filesystem absence of ignored `*.import` files cannot be re-read through GitHub;
- actual current 720×1280 World Map pixels after cleanup were not captured by the builder because the renderer was headless.

## 17. REGRESSION RISK

**LOW for R04 cleanup assets/runtime. MEDIUM for current World Map layout until M12 is closed.**

## 18. AUDIT CONFIDENCE

**HIGH** for tracked cleanup scope and protected R04 authority.  
**MEDIUM** for local ignored-sidecar state and World Map visual appearance.

## 19. FINAL VERDICT

**CONDITIONAL — BCM-M21-007 CLEANUP ACCEPTED; M21 REMAINS BLOCKED ON BCM-M21-001 WORLD MAP 720×1280 CLOSURE.**

The cleanup does not need to be rolled back.

Do not move the current calibrated World Map marker centers merely to satisfy the old probe without visual proof.

## 20. REQUIRED REMEDIATION

Execute a bounded BCM-M21-001 World Map diagnostic/closure task:
1. reproduce the exact failing M12 assertion;
2. generate a per-marker layout report;
3. inspect the real 720×1280 World Map with Godot AI / GUI screenshots;
4. determine stale-test/report vs real overlap;
5. fix the minimum correct layer only;
6. run M12 twice consecutively plus campaign/R04 regressions;
7. return for independent audit.

Required marker:
`AWAITING_GPT_M21_WORLD_MAP_LAYOUT_AUDIT_V01`
