# BCM-M04 — V7 Asset Library Import and Validation V01

## Purpose

Complete all M04 work for Beach Cocktails Merge in one Codex session. Validate the complete owner-approved V7 asset library as canonical, import-safe, alpha-correct, semantically consistent with the approved visual contract, and ready for later dynamic Godot integration.

Do not start M05 sprite integration, M06 environment integration, M07 HUD integration, or any other V7 composition work.

## Canonical repository and workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: `4.7.x`

## Mandatory governance

Read and obey before working:

- `AGENTS.md`
- root `TASKS.md`
- `docs/audits/BCM-M03_REWARD_VALUES_REMEDIATION_V01_AUDIT.md`
- M03 Codex/remediation logs as relevant
- this prompt

Codex must never edit `TASKS.md`.
Codex must not self-approve M04 or advance the tracker.

## Sync-first preflight

Run and log exact outputs:

```powershell
git status --short --branch
git remote -v
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
git rev-list --left-right --count HEAD...origin/main
```

Safely reconcile any owner-local work. Never use destructive reset, force-push, automatic rebase, destructive checkout, or silent stash.

## Canonical V7 asset inventory

Validate all of these canonical paths:

```text
assets/cocktails/L01.png
assets/cocktails/L02.png
assets/cocktails/L03.png
assets/cocktails/L04.png
assets/cocktails/L05.png
assets/cocktails/L06.png
assets/cocktails/L07.png
assets/cocktails/L08.png
assets/cocktails/L09.png
assets/cocktails/L10.png
assets/cocktails/L11.png
assets/cocktails/L12.png
assets/environment/game_board_background.png
assets/ui/logo_beach_cocktails_merge.png
assets/ui/panel_best_score.png
assets/ui/panel_score.png
assets/ui/panel_to_go_orders.png
assets/ui/panel_next.png
assets/ui/progression_strip.png
assets/ui/launch_zone.png
assets/ui/danger_line.png
assets/effects/to_go_trail.png
```

`guide_line` is explicitly out of scope and must not be introduced.

## M04.01 — Cocktail assets

For L01-L12:

1. confirm each file exists, is tracked, and imports successfully in Godot 4.7.x;
2. record dimensions, PNG color type/alpha presence, and transparent-pixel statistics;
3. confirm the background is transparent rather than a baked rectangular backdrop;
4. record non-transparent bounding boxes and visible-content dimensions for later scale/pivot planning;
5. assess whether all 12 are visually readable as distinct progression levels;
6. verify a straw is visibly present on every cocktail;
7. verify garnish differences are preserved rather than homogenized;
8. do not resize, redraw, recolor, crop, or regenerate owner-approved cocktail art merely to make metrics uniform.

Use deterministic image analysis plus direct image inspection where technically possible. Do not claim semantic visual facts from filenames alone. If a semantic detail cannot be reliably established, mark it `UNVERIFIED` rather than inventing evidence.

Owner-approved cocktail semantic references to check against, without redesigning:

- L01: small rounded yellow/orange citrus tumbler, blue/white straw, citrus slice.
- L02: red short tumbler, red/white straw, cherry.
- L03: tall green lime/mint mojito highball, green/white straw.
- L04: blue martini/tropical cocktail, striped straw, cherry/lime/tropical garnish.
- L05: orange tropical hurricane/goblet, straw, orange/tropical garnish.
- L06: pink martini, straw + cherry only; no orange/hibiscus requirement.
- L07: long straight orange-yellow highball, pipet/straw, orange slice/green leaves.
- L08: blue rounded goblet/hurricane, mint/straw/ice.
- L09: coconut cocktail, blue/white straw, plumeria/leaves.
- L10: pink/magenta premium goblet, yellow/white straw, hibiscus/orange.
- L11: tall layered red-orange highball, red/white straw, cherry + apple slice, apple on straw side.
- L12: pineapple-body legendary cocktail, red/white straw, garnish limited to the full circular pineapple slice.

## M04.02 — Environment asset

Validate `assets/environment/game_board_background.png`:

- tracked and Godot-importable;
- dimensions and alpha characteristics recorded;
- visually represents tropical beach-bar environment with slightly perspective long wooden table;
- table is empty and suitable for dynamic gameplay composition;
- must not contain baked dynamic UI or gameplay overlays: logo, score numbers/panels, To-Go order content, Next content, cocktail pieces, progression strip, danger line, guide line, or launch ring.

If any of those elements are visibly baked in, record the exact conflict as a finding. Do not silently edit the asset in M04 unless it is a clearly accidental technical defect and the owner-approved source remains recoverable.

## M04.03 — UI assets

Validate:

### `logo_beach_cocktails_merge.png`
- owner-approved logo asset, clean transparency/import.

### `panel_best_score.png` and `panel_score.png`
- record dimensions;
- compare dimensions/proportions;
- verify blank/dynamic numeric content areas rather than baked changing scores.

### `panel_to_go_orders.png`
- blank central dynamic content area for runtime target/reward composition.

### `panel_next.png`
- blank dynamic preview area; no baked next cocktail.

### `progression_strip.png`
- verify exactly 12 intended empty visual slots;
- no baked cocktail icons or dynamic text that would conflict with runtime population.

### `launch_zone.png`
- clean transparency;
- simple thin glowing gold/yellow perspective oval/ring;
- transparent center;
- no text, wooden sign, flowers, leaves, rope, cocktail, guide arrows, or other decorative clutter.

### `danger_line.png`
- verify it is suitable as the horizontal danger/deadline boundary visual;
- record dimensions/transparency and whether it can be placed dynamically.

No persistent guide-line asset is allowed.

## M04.04 — Effects asset

Validate `assets/effects/to_go_trail.png`:

- clean transparency/import;
- simplified gold light trail suitable for To-Go delivery;
- small sparkles/bubbles are acceptable;
- no large garnish/fruit/flower objects that dominate the effect;
- identify whether additional future merge/order feedback should be procedural Godot particles/tweens rather than static PNGs.

Do not implement those effects in M04.

## Deterministic asset inspection

Create a bounded non-production validation script/tool under `tests/` or `tools/` if needed. It should inspect production assets rather than generate replacements.

At minimum capture for every canonical PNG:

- path;
- file size;
- width × height;
- image mode/color type where available;
- alpha-channel presence;
- count/percentage of fully transparent pixels;
- count/percentage of non-transparent pixels;
- non-transparent bounding box;
- whether the image is fully opaque when transparency is expected;
- load/import success.

For `panel_best_score.png` vs `panel_score.png`, explicitly compare dimensions.
For `progression_strip.png`, provide visual/manual evidence for the 12 empty slots; image dimensions alone are insufficient.
For cocktail straw/garnish and environment/UI semantic rules, use direct visual inspection where technically possible and distinguish `VERIFIED`, `SOURCE/OWNER-CONTRACT-CONSISTENT`, and `UNVERIFIED` honestly.

## Godot validation

Use installed Godot 4.7.x and record exact commands/output/exit codes for:

- version;
- import/parse;
- configured main-scene startup;
- asset load/import probe if created;
- M01, M02, and M03 regression probes after any production-file change.

M04 should normally require no gameplay production change. If a technical asset import fix is necessary, keep it minimal, preserve original owner art, and rerun all accepted regression probes.

## Change policy

M04 is validation/import-readiness, not visual integration.

Allowed:
- deterministic test/support tooling;
- import-safe metadata or documentation fixes that do not alter approved art;
- narrowly necessary technical repair of a malformed asset only if the approved source is preserved and evidence is explicit.

Not allowed:
- redesign/regenerate owner-approved art;
- integrate sprites into gameplay;
- alter colliders for V7 art;
- compose background/table/UI in scene;
- add runtime HUD;
- add guide line;
- retune gameplay, economy, physics, To-Go logic, or layout.

## Evidence-first logging

Create one immutable log:

`docs/codex-logs/BCM-M04_MILESTONE_COMPLETION_V01_CODEX_LOG.md`

The log must include:

- sync-first Git outputs;
- exact canonical asset inventory;
- tracked/missing status;
- deterministic image metrics for all canonical PNGs;
- Godot import/load evidence;
- cocktail alpha/background/bounds results L01-L12;
- direct visual/semantic inspection notes for each L01-L12, including straw/garnish status;
- environment semantic inspection;
- each UI asset inspection;
- progression strip 12-slot evidence;
- launch-zone transparent-center/clutter evidence;
- danger-line evidence;
- To-Go trail evidence;
- any conflicts/findings by severity;
- clear distinction between verified, source-inferred/contract-consistent, and unverified items;
- files changed;
- `git diff --check` result;
- exact Godot version/import/startup results;
- regression results if any production file changed;
- explicit confirmation `TASKS.md` was not edited;
- explicit confirmation M05+ integration work was not started.

The owner must not be used as a clipboard for terminal evidence. Retained evidence belongs in the committed log.

## Completion procedure

1. Inspect full repository/asset state.
2. Run deterministic asset metrics/validation.
3. Perform direct visual semantic inspection where technically possible.
4. Run Godot import/load/startup checks.
5. Fix only bounded M04 technical defects if necessary.
6. Inspect final diff/status.
7. Commit and push all intended M04 support/log/documentation changes to `main`.
8. Fetch `origin/main` and confirm synchronization.
9. Do not edit `TASKS.md`.
10. Do not start M05 or later integration.
11. STOP for independent ChatGPT audit.

## Completion response

Return only:

- M04 Codex log GitHub URL;
- pushed commit SHA;
- one-line asset-validation result or exact blocker;
- confirmation `TASKS.md` was not edited;
- confirmation M05+ V7 integration was not started.

All detailed evidence must already be inside the committed Codex log.
