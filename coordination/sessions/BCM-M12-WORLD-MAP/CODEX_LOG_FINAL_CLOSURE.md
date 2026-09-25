# BCM-M12 Final Closure — Codex Builder Log

- Start HEAD: `28f32f4d5a34fa8b5a433389486c8c57bcc0400b`
- Branch/remote: `main` / `origin`
- Implementation commit: `a1370fc`
- Final main HEAD: verified after the log commit and reported with the remote verification below.

## Validation

- Manifest: 398/398 current canonical paths present; PNG decode, declared dimensions, RGBA/alpha checks passed after the seven evidence sheets were rebuilt.
- Duplicate scan: completed against current SHA-256 identities. The two shadow groups are intentional semantic reuse. Eight gameplay-table/edge-overlay groups are invalid semantic reuse because each overlay is byte-identical to its gameplay table; invalid semantic duplicate groups: **8**.
- V2 tables: **FAIL / changes required**. All ten gameplay/overlay/shadow files decode as 720x1280 RGBA and all island shadows are pixel-equal to `table_shadow_master_v2.png`, but the eight regenerated island overlays are byte-identical to their gameplay tables and the gameplay alpha/structural footprint is not common across all ten families. No canonical table PNG was modified in this closure cycle.
- V02 brand: six current canonical brand files and `logo_concept_v02.png` exist and pass the manifest decode/dimension/alpha checks. No brand PNG was modified.
- Contact sheets: VA-176 through VA-182 rebuilt as technical composites from current canonical assets only, at their declared manifest dimensions and RGBA format.
- M12 regression: **FAIL / UNVERIFIED**. `tests/m12_world_map_probe.gd` hit `world_map_controller.gd` PNG preload parse errors (`no resource loaders`) and then could not assign `level_database` to the loaded scene; the probe did not reach a PASS result.

## Documentation state

- `CODEX_VISUAL_ASSET_TASKS.md`: VA-348 through VA-375 requested global items and VA-176 through VA-182 evidence sheets marked complete; current main/V02/V2 closure notes added.
- `ui-assets-tasks.md`: concise historical/superseded note added; no mass historical completion.
- `TASKS.md`: not modified.

## Scope / publication

- Changed by this closure: seven evidence-only contact sheets and the two permitted visual-task documentation files, plus this builder log.
- No canonical production table, brand, global UI, V04 master, or M13 implementation file was regenerated or modified by this closure.
- HTTP 429: not encountered in this no-generation closure cycle.
- Remote verification: final `main` HEAD, local `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` recorded after the log commit.
- Status: `AWAITING_M12_FINAL_AUDIT` with the V2 table duplicate and M12 probe blockers above.
