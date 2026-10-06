# Codex Execution Log — BCM-M21-001-R04 Owner Critique Corrections V03

## Start record

- Owner direction (2026-10-06): Home is the player welcome screen. Move the Energy bar closer to Level; align all three add icons so their white plus-symbol centers land on the vertical marks in the new owner screenshot and their vertical centers align with their bars; raise Continue text by 12 reference pixels total (the owner added a further 5 px during implementation); prove World Map opens the production map and Play launches the player's current saved/selected level.
- Active contract: `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/CHATGPT_HOME_EXACT_TARGET_PROMPT_R04.md`, with the newer direct owner screenshot instructions governing the requested corrections.
- Starting HEAD: `8b6d8595f04ab1e456f45f913082cb30965100d4`; branch `main`, remote `origin`.
- Sync preflight: status showed owner-local `project.godot` and two untracked owner-provided annotated screenshots; canonical `origin` confirmed; fetch succeeded; `HEAD...origin/main` was `0 0`.
- Preserve unchanged: `project.godot`, `evidence/02_home_reference_941x1672 kritik.png`, and `evidence/owner-critique-v02/02_home_owner_critique_v02_941x1672 kritik.png`.
- Root `TASKS.md` was read-only; active tracker still identifies BCM-M21-001-R04. `TASKS.md` must not be modified.

## Execution record

- `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/HOME_TARGET_LAYOUT_R04.json`: shifted Energy left 18 px and expanded its rectangle by the same amount so its right endpoint stays fixed and its gap to Level shrinks. Positioned add-icon geometric/white-plus centers at annotated x=393, 589, and 802; each icon center-y matches its bar center-y. Continue label is now 12 px above its pre-V03 location (V03 requested 7 px, then the owner requested 5 px more). Coin value rectangle was shifted left within the coin bar to avoid the relocated plus icon.
- `tests/m21_home_exact_target_r04_probe.gd`: asserts the V03 bar and icon rectangles, annotated plus centers, vertical bar/icon alignment, total Continue offset, selected-level launch, and visible production World Map after real pointer clicks. Evidence output uses `evidence/owner-critique-v03/`.
- Owner annotation was copied unchanged to `evidence/owner-critique-v03/owner_home_annotation_v03.png`; SHA-256 `d8c9a18f7612ff968dd65e7b8e1adac1a2ae145bab79a6432b60dc90aabe5adb`. Measured vertical guide ranges were x=392..394, x=588..590, and x=800..804; their centers are recorded in the layout/report.
- Reviewed production screenshot: `evidence/owner-critique-v03/02_home_owner_critique_v03_941x1672.png`; SHA-256 `af438195ea213c96e637ac265ed92ea6f45c6399d3be1b21c5ac0c1c5722399c`.
- Additional production-size and real-navigation captures are in `evidence/owner-critique-v03/`; `HOME_TARGET_PARITY_R04_OWNER_CRITIQUE_V03.json` records the annotation/capture hashes, measured corrections, and probe outcomes. Full pixel parity with the original TARGET remains `UNVERIFIED` per the existing R04 evidence.

## Verification

- `godot_console.exe --path . --script res://tests/m21_home_exact_target_r04_probe.gd` — exit 0; `M21_HOME_R04_RESULT=PASS`. It exercised real mouse input: Play started selected level 7 and World Map made the production map visible. It also captured 941x1672, 720x1280, 800x1422, and navigation views.
- `godot_console.exe --headless --path . --script res://tests/m20_app_shell_probe.gd` — exit 0; `M20_CHILD_01_RESULT=PASS`.
- `python tools/ui_assets/rebuild_asset_catalog_r04.py` — exit 0; `R04_ASSET_CATALOG=PASS current_pngs=373 dimensions=373`.
- `python tools/ui_assets/validate_assets.py` — exit 0; checksums 373/373, R04 families 10/10, retired art absent, invalid semantic duplicates 0.
- `godot_console.exe --headless --path . --editor --quit` — exit 0; clean filesystem scan/import/editor initialization.
- M21 V05 World Map suite was not rerun because no World Map implementation was changed; the Home-to-World-Map action was exercised through the real production button in this turn. Its prior published V05 result remains in `CODEX_LOG_M21_WORLD_MAP_PRODUCTION_V05.md`.
- `git diff --check` and `git diff --exit-code HEAD -- TASKS.md` — pending final publication check. Manual inspection was limited to the generated Home captures; no independent owner acceptance audit was performed.

## Scope and handoff

- Intended files: Home layout JSON, focused Home probe, V03 annotated input/render/navigation/parity evidence, and this new immutable log.
- Preserved outside the change: owner-local `project.godot`, the original owner annotations in V02 evidence, and root `TASKS.md`.
- No source PNGs in `assets/ui_assets/screens/home/` were modified. `TASKS.md` was not modified.
- Branch `main`, remote `origin`; start SHA `8b6d8595f04ab1e456f45f913082cb30965100d4`; end/final commit SHA and three-way SHA equality pending publication.
- Known limit: overall pixel-identical match to the original R04 TARGET remains unverified; this work implements and measures the newer owner annotations only.
