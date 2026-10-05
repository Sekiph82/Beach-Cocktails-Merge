# Codex Execution Log — BCM-M21-001-R04 Exact Home Target

## Start record

- Prompt: `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/CHATGPT_HOME_EXACT_TARGET_PROMPT_R04.md`
- Ruling: `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/OWNER_HOME_EXACT_TARGET_RULING_R04.md`
- Criteria: `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/CHATGPT_HOME_EXACT_TARGET_CRITERIA_R04.md`
- Starting HEAD: `3db2d2e45b1beaa33d367e0dca0d5f1ff7ee9d19`; branch `main`; remote `origin`.
- Sync preflight: initial HEAD `92c34f7c6d243b719921241751111f98653c2cf1`, ahead/behind `0/10`. Tracked dirty path `project.godot`; untracked owner assets: all 14 PNGs in `assets/ui_assets/screens/home/`. Incoming diff paths were disjoint. Applied tracked-only stash `owner-local-safe-sync-92c34f7`, fast-forwarded to `3db2d2e45b1beaa33d367e0dca0d5f1ff7ee9d19`, then reapplied only that exact stash without dropping. All 14 untracked PNGs remained present; `project.godot` diff restored. No local commits ahead; synchronized HEAD equals `origin/main`.
- Root `TASKS.md` read-only; active task `BCM-M21-001-R04`.

## Owner PNG pre-implementation inventory

All files were present and SHA-256 hashed before product edits. Measured file dimensions are recorded as actually supplied; several differ from prompt estimates.

| File | Dimensions | SHA-256 |
|---|---:|---|
| `TARGET beach cocktails merge home.png` | 941×1672 | `38d937b8a4345906fe69e436965d1f0feb9d69105d25a3455048488df07c15e1` |
| `home background.png` | 941×1672 | `da4c61e225c52049c89d8f7b9be9b8476a25e4b6cf9c89a75bcffeef5fcbe56a` |
| `level bari.png` | 2053×766 | `9f343f75cf251b0d52f8e6b62c58a00018b58053b6b35c8c555b195f24a53aa3` |
| `enerji bari.png` | 2053×766 | `fbabb516cf67c00b22fa5e54c4e806f00d79831ccba0889cb82c1cb5cf886946` |
| `coin bari.png` | 2054×766 | `c3c2375d075e09c34d7f352dd436d5b42eece71218b3ad9f6dc70133dd26eba3` |
| `elmas bari.png` | 2053×766 | `3ede1d9af75ad7d3d2137d524135458a2146c08e92cab0626a7c8b81673a4b68` |
| `ekle gorseli.png` | 1266×1242 | `6a432c656d17093cc3c7315aaed20355711268e38b3a11103ec95b8ed71c2788` |
| `settings.png` | 1254×1254 | `27cc0d1e7651ad27013874654257d994a26c1a875293ea6a08ebd3d327fc9fb1` |
| `play butonu.png` | 1916×821 | `9063f83cc43c4ed116fb777e72f12f2682a8f80e3f1c50faf4c057a587e04953` |
| `world map.png` | 2172×724 | `2caff4e52e80b0b17832b409d5dce1ec32ed1f9cd28919be0b4b9d1daa9c74b2` |
| `shop.png` | 1313×1198 | `2ec896f639dfd265c1651438097f435b8be205f542c4e515bfe7c85e92829170` |
| `Events.png` | 1313×1198 | `1669f940650f904893495712ff6cc873f90beae28f8945dcb115e01a791645be` |
| `daily rewards.png` | 1263×1246 | `6dc64b823e79253ed3b409e2e8644b8a00f87b3ee758d3aa5f71515b7d715868` |
| `achievements.png` | 1313×1198 | `9480ab45ea9e1c49df41a739a7aafdb5c7b444860aad0c39171d1c55ed3fc89b` |

No source PNG was edited, renamed, cropped, or regenerated during inventory.

## Execution record

### Implementation and evidence

- Implementation/content commit: `98d070b8a6dc92c616a556beed19a008989bc7df`.
- Replaced the visible R02 menu composition in `scripts/campaign/application_shell.gd` with a JSON-driven Home layer. `home background.png` is the sole background; 14 local PNG files remain unchanged and TARGET is never loaded by production.
- PLAY, WORLD MAP, and top-right SETTINGS are distinct `TextureButton` bodies connected to existing production actions. Bottom Shop, Events, Daily Rewards, Achievements, plus art, and decorative bars ignore input because no canonical action exists.
- Campaign selected/unlocked level feeds both the top level and `CONTINUE LEVEL N`; the label is not hardcoded. Current `GameEconomy.coins` supplies coin display, formatted with periods. No canonical energy/gem authority was found in campaign runtime; Home displays presentation-only defaults 100 and 85 and does not persist or mutate them.
- Layout: `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/HOME_TARGET_LAYOUT_R04.json`. Runtime applies the reference coordinates normalized from 941×1672 and reflows on viewport resize.
- Evidence: `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence/` contains the byte-identical target copy, production captures at 941×1672 / 720×1280 / 800×1422, and actual PLAY / WORLD MAP / SETTINGS navigation captures.
- Focused probe: `tests/m21_home_exact_target_r04_probe.gd`.
- Asset catalog and dimensions were rebuilt to include the 14 owner Home files; duplicate report inventory count updated to 373.

### Commands and results

- `python tools/ui_assets/rebuild_asset_catalog_r04.py` — exit 0; `R04_ASSET_CATALOG=PASS current_pngs=373 dimensions=373`.
- `python tools/ui_assets/validate_assets.py` — exit 0; all 373 manifest checksums, 10/10 R04 source/runtime/profile/evidence families, retired art absent, semantic duplicates invalid=0.
- `godot_console.exe --path . --script res://tests/m21_home_exact_target_r04_probe.gd` — exit 0; `M21_HOME_R04_RESULT=PASS`. Verified live level transition 12→7→12, Continue follows the same selected level, 4250 formats to 4.250, display defaults, asset occurrences, no old visible nodes, normalized rects at reference size, rendered size captures, and real mouse input to PLAY / WORLD MAP / SETTINGS.
- `godot_console.exe --headless --path . --script res://tests/m20_app_shell_probe.gd` — exit 0; `M20_CHILD_01_RESULT=PASS`.
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m21_world_map_production_v05_probe.gd` — exit 0; `M21_WORLD_MAP_PRODUCTION_V05_RESULT=PASS captures=7 mouse=PASS touch=PASS`. Its existing Island Map output capture was restored exactly after the run; no unrelated V05 evidence is included in this change.
- `godot_console.exe --headless --path . --editor --quit` — exit 0; Godot 4.7.2 completed asset import, script class scan, and editor startup/quit without parse errors.
- `python -m json.tool coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/HOME_TARGET_LAYOUT_R04.json` — exit 0.
- `git diff --check` and `git diff --cached --check` — exit 0.
- Sync recheck before commit: `git fetch origin main`; `git rev-list --left-right --count HEAD...origin/main` returned `0 0`.
- The TARGET evidence copy SHA-256 matches the owner TARGET (`38d937b8a4345906fe69e436965d1f0feb9d69105d25a3455048488df07c15e1`). All 14 owner PNG hashes match the pre-implementation inventory above.

### Visual parity and manual review

- The production capture and TARGET were compared at 941×1672 with only the named dynamic text zones masked for the global comparison. The full-image RGB MAE after those masks is recorded in `evidence/HOME_TARGET_PARITY_R04.json`; target parity remains `UNVERIFIED`.
- Per-art RGB comparison is also recorded. The `delta_to_layout_rect_px` is the runtime-vs-layout transform check and is zero by construction; independent source-art-to-TARGET bounds are explicitly `null`/`UNVERIFIED`, so this log does not claim the required ≤2 px image-matching gate.
- The provided `home background.png` is visibly different from the backdrop in TARGET, and the supplied bottom utility PNG lettering also differs from the lettering displayed in TARGET. Source assets were not edited, cropped, recolored, or replaced, and TARGET was not flattened into production. This conflicts with strict full-scene pixel parity while following the designated production base and owner-supplied source files.
- Manual review performed on the 941×1672 production capture; the 720×1280 and 800×1422 captures were confirmed at their requested dimensions. Production mouse actions were exercised by the focused probe. Home touch input, native-device rendering, and exact pixel placement against every source silhouette were not independently verified.
- M07/M08 remediation was deliberately not run, per R04 scope.

### Repository and governance state

- Root `TASKS.md` was not modified (verified with `git diff --exit-code HEAD -- TASKS.md`).
- The owner-local `project.godot` change was preserved unstaged and excluded from the implementation commit.
- No Island Map, World Map, gameplay, HUD, To-Go, or M07/M08 product code was changed by this task.
- Publication is pending the final push/equality check. The implementation/content commit is `98d070b8a6dc92c616a556beed19a008989bc7df`; the containing log commit is recorded by repository history because a commit cannot encode its own hash. Final `HEAD`, `origin/main`, and remote `main` equality is verified at handoff after push.

Final owner handoff marker: `AWAITING_OWNER_HOME_EXACT_TARGET_APPROVAL_R04`.
