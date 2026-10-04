# Codex Execution Log — R04 Gameplay Surface Technical Authority

## Work item and owner direction

- Work item: BCM-M21-001 + BCM-M21-006, R04 gameplay-surface authority migration.
- Prompt/ruling: owner instruction in this Codex session, 2026-10-04; supersedes the prior V2 split-table asset authority for the approved R04 gameplay composition.
- Start HEAD: `502a90b000eb8968f7a677df5ff0fcb29410bc98`.
- Branch/remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).

## Sync preflight

- `git status --short --branch`: local `main...origin/main`; pre-existing owner-local `project.godot`, `scenes/main.tscn`, three intentionally deleted contact sheets, untracked local addon directories, and 14 generated `.translation` sidecars were present and preserved.
- `git fetch origin main`: succeeded.
- `git rev-list --left-right --count HEAD...origin/main`: `0 0`.
- Start local HEAD, `origin/main`, and live remote main: `502a90b000eb8968f7a677df5ff0fcb29410bc98`.

## Authorized scope

- Make each island's own `gameplay_surface_v07_r04.png` the byte source of that island's canonical `gameplay_surface.png`.
- Bind runtime, per-island geometry records, validation, debug/stress evidence, and focused tests to the matching R04 image identity and SHA-256.
- Supersede the split gameplay background/table/edge/shadow production contract for this screen with the owner-approved single-surface contract.
- Retire obsolete gameplay-only table layers, proofs, geometry debug PNGs, generators/tests that only support the retired composition, and update manifests/catalogs accordingly.
- Preserve the five named map/completion assets, each per-island R04 source image, all non-gameplay UI/cocktail assets, gameplay physics/scoring/input behavior, historical logs/audits, `TASKS.md`, and all pre-existing owner-local work.

## Implementation and verification

- `AGENTS.md` and the new `docs/ui-assets/GAMEPLAY_SURFACE_CONTRACT_V07_R04.md` name the R04 per-island surface/profile as the gameplay art authority; V2 split-table requirements are explicitly historical for this screen.
- `data/campaign/islands.json` now points each island to its own generic runtime surface and R04 profile. The inline geometry copy is removed; `LevelDatabase` loads and validates profile identity, source/runtime byte identity, SHA-256, 720x1280 dimensions, and geometry. `GameManager` renders one surface and fails closed instead of falling back to split layers.
- Each of the ten source/runtime image pairs is byte-identical and uniquely bound to a per-island profile. The profile records measurements, the unchanged accepted R11 polygon/launch/spawn/death values, all twelve collider radii and fit centers, and hashes for three evidence overlays: geometry debug, collider-footprint fit, and embedded-shadow identity.
- Removed retired split gameplay images from the ten island packs, the old Sunny Cove v07/r02 images and geometry/debug proofs, the two obsolete Sunny Cove source plates, and six V1/V2 table-master PNGs. Kept the five map/completion images and each island's own `gameplay_surface_v07_r04.png`. Kept old JSON/provenance as historical evidence with superseded status.
- `tools/ui_assets/prepare_gameplay_surface_r04.py`, `rebuild_asset_catalog_r04.py`, and `validate_assets.py` now make/measure/index/check the R04 single-image pipeline. Legacy Sunny Cove split-table builders/calibrators stop with a migration message; the generator refuses retired split layers.
- The manifest and dimensions catalog cover exactly 356 current PNGs. The validator passed all 10 source/runtime/profile/evidence families and found only the 10 intentional exact source/runtime identity pairs.
- R04 runtime probe: `godot_console.exe --headless --path . --script res://tests/m21_r04_gameplay_surface_authority_probe.gd` — exit 0; `M21_R04_SURFACE_PROBE_RESULT=PASS islands=10 checks=71`. It loaded `GameManager`, applied all ten island themes, and verified one canonical surface, matching profile geometry, and no split layer per island.
- M19 multi-island regression: `godot_console.exe --headless --path . --script res://tests/m19_multi_island_scalability_probe.gd --quit-after 1200` — exit 0; Child 01–06 and `M19_SCALABILITY_RESULT=PASS`.
- M19 R01 Child 05 regression: `godot_console.exe --headless --path . --script res://tests/m19_r01_ordered_verification_probe.gd -- --child=5` — exit 0; `M19_R01_CHILD_05_RESULT=PASS`.
- R11 edge/physics regression: `godot_console.exe --headless --path . --script res://tests/r10_v10_visual_hull_containment_probe.gd` — exit 0; `R10_V10_VISUAL_HULL_CONTAINMENT_RESULT=PASS`. The probe now checks physical table-contact footprints and the fixed 12 px rear margin; full glass silhouettes may overhang the tabletop rails under the accepted R11 model.
- Main-project headless startup: exit 0. Godot 4.7.2 editor import: exit 0; it reported that `res://original_reference` contains another `project.godot` and skipped that folder. New R04 surfaces imported successfully. The import regenerated four `ASSET_DIMENSIONS.*.translation` sidecars while refreshing the CSV; the original synchronized CSV was reimported temporarily to restore them byte-for-byte. All 14 final sidecar hashes match their preflight hashes.
- Python syntax compilation: passed for the three R04 tools, legacy tool stubs, and asset generator. `python tools/ui_assets/validate_assets.py` — PASS (356/356 assets; 10/10 R04 families; 0 invalid semantic duplicates). The syntax compile created untracked `tools/__pycache__/` and `tools/ui_assets/__pycache__/`; the environment rejected removal of those generated bytecode files, so they remain untracked and excluded from publication.
- `TASKS.md` remained byte-identical to the start commit (`git hash-object`: `464029404fe0f6dba1df84341a77cc33a2954ce9`).
- Visual inspection performed on Sunny Cove R04 and its derived collider-fit proof. Individual art file dimensions/hashes/profiles are automated-checked for all ten islands; a human owner F5 review of every island is not claimed.
- Gameplay physics, drink collider sizes, score/order logic, and input behavior were not retuned. Interactive owner-native F5 acceptance remains pending for the independent audit/owner review.

## Final repository state

- Implementation commit SHA: `7574a5e`.
- Execution log is a separate evidence-only follow-up commit. Final `HEAD == origin/main == live refs/heads/main` is recorded in the handoff after publication verification.
- `TASKS.md` was not modified.
