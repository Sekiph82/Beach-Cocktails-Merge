# BCM-M05 — Cocktail Sprite Integration V01 Audit

## 1. VERDICT

**PASS**

M05 is accepted. The production drink presentation now uses the canonical L01-L12 cocktail PNGs through one reusable mapping, placeholder drink geometry has been replaced by Sprite2D presentation, per-level visual scale/offset and collider footprints are deterministic, merge/rapid-launch/restart/Game Over behavior remains regression-protected, and M01-M03 continue to pass.

One non-blocking evidence-truthfulness defect is recorded below: the M05 Codex log incorrectly states the prior production/JSON collider-radius series as `18,22,26,30,35,41,48,55,63,71,79,89`. Repository truth immediately before M05 is `14,21,29,38,48,59,71,84,98,113,129,146` from `data/drinks.json`, and `Drink.create()` used those JSON values directly. This does not invalidate the independently verified current M05 implementation or runtime regressions, but the historical builder log must not be treated as authoritative for the old-radius table.

## 2. CONTRACT RECOVERY

The M05 prompt requires canonical L01-L12 mapping, Sprite2D replacement of placeholder visuals, deterministic scale/pivot strategy, visible-glass-based collider alignment, preserved compressed runtime mass, merge visual continuity, reusable texture hooks for later HUD work, and no M06/M07 composition work.

Accepted gameplay invariants remain 700 px/s launch speed, 180 px/s² deceleration, no cruise assist, immediate next-held generation, simultaneous moving drinks, settled-body wake/momentum transfer, forward-only collision handling, merge momentum, L12 cap, accepted M03 scoring/To-Go economy, persistence, danger-line, Game Over, and restart behavior.

## 3. BRANCH / HEAD / DIFF SCOPE

Audited M05 range:

- base: `31f8a088d77a29c89ba34b2e5bf2552fd3b225f7`
- implementation: `39edae709baf35c368bed643744007c104984bef`
- evidence-log finalization: `56a21dc503fb72e1a00f8fcec78334555b3a92ef`

GitHub compare reports only:

- `scripts/drink.gd`
- `tests/m01_contract_probe.gd`
- `tests/m05_sprite_integration_probe.gd`
- `docs/codex-logs/BCM-M05_MILESTONE_COMPLETION_V01_CODEX_LOG.md`

No canonical PNG, `TASKS.md`, environment/HUD asset, economy data, or later-milestone composition file was changed.

## 4. ACCEPTANCE CRITERIA MATRIX

- Canonical L01-L12 production mapping: **PASS**.
- Invalid level/L13 path safety: **PASS**.
- Placeholder drink visuals replaced by Sprite2D: **PASS**.
- Physics body remains owned by `Drink`: **PASS**.
- Held/table/merge results use canonical cocktail sprites: **PASS**.
- Reusable texture accessor for future Next/To-Go/progression use: **PASS**.
- Deterministic per-level visual scale/offset: **PASS**.
- Per-level collider footprint based on visible glass body rather than garnish extremes: **PASS**, with human-measured body widths/centers retained in the log.
- Compressed runtime mass progression preserved: **PASS**.
- Correct next-level merge sprite and atomic level/collider/texture replacement: **PASS**.
- Merge result physically plausible and momentum-preserving: **PASS**.
- L12 hard cap/no L13 visual: **PASS**.
- Rapid-launch visual/current-next integrity: **PASS**.
- Restart/Game Over orphan-visual checks: **PASS**.
- M01/M02/M03 regressions: **PASS**.
- Godot import/parse/main-scene startup: **PASS**.
- Full native-device final visual acceptance: **UNVERIFIED**, appropriately deferred to later integrated visual acceptance.

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH

The core M05 implementation claims match repository truth. `Drink` owns the mapping and presentation APIs, the focused M05 probe exists, and Git history shows the bounded implementation scope.

One builder-log historical claim does not match repository truth: the claimed pre-M05 JSON radius series `18,22,26,30,35,41,48,55,63,71,79,89` is incorrect. The actual pre-M05 `data/drinks.json` radii were `14,21,29,38,48,59,71,84,98,113,129,146`, and pre-M05 `Drink.create()` assigned `d.radius` directly from `info["radius"]`.

The current M05 runtime collider series `20,23,27,31,36,42,49,56,64,72,80,90` is independently evidenced by the production mapping and M05/M02 runtime probes.

## 6. FILE / SYMBOL EVIDENCE

`Drink` now provides the canonical texture-path mapping and safe accessors used by production drink presentation. `Drink.create()` creates `CocktailSprite`, applies deterministic per-level scale/offset, and uses the bounded collider mapping. The previous placeholder rim/body/shine/level-label presentation is removed.

The M05 log records source dimensions, alpha bounds, manually interpreted visible body widths/centers, scale, offset, collider radius, and compressed runtime mass for L01-L12.

Pre-M05 repository evidence confirms JSON radii were `14,21,29,38,48,59,71,84,98,113,129,146`, not the historical series stated in the builder log.

## 7. FOCUSED TEST EVIDENCE

`tests/m05_sprite_integration_probe.gd` reports:

- all L01-L12 table drinks use canonical Sprite2D mapping;
- held launch drink uses canonical Sprite2D;
- invalid level 13 resolves to no texture/path;
- all presentation/body scales remain bounded;
- L2+L2 creates L3 with canonical L03 texture, expected collider and retained momentum;
- L12 has no L13 path;
- six rapid launches preserve coherent current/next visuals;
- restart and Game Over produce no orphan drink visuals;
- final `M05_PROBE_RESULT=PASS`, exit code 0.

## 8. REGRESSION EVIDENCE

Post-M05 production changes:

- M01: PASS / exit 0, preserving launch speed, immediate next, touch/mouse routes, simultaneous motion, deceleration, forward-only response, settled wake, merge momentum, Game Over, persistence, restart.
- M02: PASS / exit 0, including direct/glancing 700 px/s collision, no tunneling, single merge, chain stress, L12 cap, rapid launch, moving restart and moving Game Over.
- M03: PASS / exit 0, preserving score table, combo, owner-approved To-Go rewards, stored-delivery semantics, save handling, danger line, Game Over and restart.
- Godot 4.7.2 import/parse and main-scene smoke checks: exit 0.

## 9. SECURITY / SAFETY REVIEW

No secrets, save data, editor caches, build output, generated `.godot/` data, or machine-specific production files were added. No destructive Git operation is evidenced.

## 10. ARCHITECTURE CONSISTENCY

PASS. Texture ownership remains centralized in `Drink` rather than duplicated across future consumers. Visual nodes remain presentation children of the production physics body. Runtime mass remains compressed and separate from JSON design mass. M06 environment and M07 HUD responsibilities remain separated.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS

`TASKS.md` was not edited by Codex. M06/M07 were not started.

Historical-log defect: the before-radius table is inaccurate. This is a **MINOR** evidence/documentation defect, not an implementation blocker. This audit records the authoritative correction rather than rewriting the immutable Codex log.

## 12. FINAL REPOSITORY STATE

M05 implementation is committed on `main`. The implementation commit was verified synchronized at `39edae709baf35c368bed643744007c104984bef`; the subsequent `56a21dc503fb72e1a00f8fcec78334555b3a92ef` commit changes only the immutable evidence log.

## 13. OPEN CROSS-MILESTONE FINDINGS

- Full integrated native visual acceptance remains for later visual milestones/final acceptance.
- M06 must align the production physics playfield to the approved perspective table/background without retuning accepted physics.
- M07 must consume the same canonical texture accessor for Next, To-Go and progression visuals rather than duplicate mapping.

## 14. DEFECTS BY SEVERITY

### MINOR — F-M05-EVIDENCE-001

The M05 Codex log's claimed pre-M05 production/JSON radius values are incorrect. Correct repository-truth values are `14,21,29,38,48,59,71,84,98,113,129,146`.

No BLOCKER or MAJOR defects found.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES

Future visual/native testing may justify small presentation/collider refinements, but such changes must remain evidence-backed and rerun M01-M03 regressions. Do not treat this as authorization for broad physics retuning.

## 16. UNVERIFIED ITEMS

- Final combined aesthetic on the approved background/HUD.
- Native phone readability/feel of all 12 cocktails in the final composed screen.
- Final safe-area/device-specific visual behavior.

These are outside M05 scope.

## 17. REGRESSION RISK

**MEDIUM** because M05 changes production collision radii and visual representation, mitigated by focused M05 coverage plus full M01-M03 regression passes.

## 18. AUDIT CONFIDENCE

**HIGH**.

## 19. FINAL VERDICT

**PASS**

M05 may close and M06 may begin.

## 20. REQUIRED REMEDIATION

None required before M06. Preserve F-M05-EVIDENCE-001 as a historical evidence correction; do not mutate the immutable M05 Codex log.
