# BCM-M07 — Dynamic HUD and Final Gameplay-Screen Composition V01

## Purpose

Complete the entire M07 milestone for Beach Cocktails Merge in one bounded Codex session. Compose the owner-approved gameplay HUD from the already validated canonical assets and live Godot data so the game reaches its first owner-playable, near-final visual gameplay screen.

M07 is the point at which the owner should be able to launch the game and judge the integrated visual composition. Do not start M08 effects, M09 audio/haptics, M10 menus/onboarding, M11 export/device QA, or M12 final closure.

## Canonical repository and workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: 4.7.x

## Mandatory governance

Read and obey before work:

- `AGENTS.md`
- root `TASKS.md`
- `docs/audits/BCM-M06_MILESTONE_COMPLETION_V01_AUDIT.md`
- `docs/codex-logs/BCM-M06_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- this prompt

Codex must never edit `TASKS.md`. Codex does not self-approve M07. Stop after commit/push for independent ChatGPT audit.

## Sync-first preflight

Run and retain exact outputs:

```powershell
git status --short --branch
git remote -v
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
git rev-list --left-right --count HEAD...origin/main
```

Safely fast-forward/reconcile remote governance commits. Never use destructive reset, force-push, automatic rebase, destructive checkout, or silent stash.

## Accepted contracts that M07 must preserve

Do not retune or redesign:

- launch speed = 700 px/s;
- slide deceleration = 180 px/s²;
- immediate next-held generation;
- simultaneous moving drinks;
- settled-drink wake/momentum transfer;
- forward-only/no intentional +Y rebound;
- merge momentum and L12 cap;
- M05 cocktail texture mapping, visual scales, offsets and collider footprints;
- M06 background/table geometry, rail mapping, `death_line_y`, launch position and responsive source mapping;
- merge score table;
- combo window/percentages;
- To-Go target range/fulfillment behavior;
- To-Go rewards L6=1000, L7=1800, L8=3000, L9=5000, L10=8000, L11=12000, L12=18000;
- stored-drink To-Go semantics;
- best-score persistence, Game Over and restart.

## Canonical M07 UI assets

Use the already accepted files only:

```text
assets/ui/logo_beach_cocktails_merge.png
assets/ui/panel_best_score.png
assets/ui/panel_score.png
assets/ui/panel_to_go_orders.png
assets/ui/panel_next.png
assets/ui/progression_strip.png
assets/ui/launch_zone.png
assets/ui/danger_line.png
```

Cocktail previews/icons must use the canonical `Drink.texture_for_level()` / equivalent single production mapping from M05. Do not duplicate a second L01-L12 path table in HUD code.

Do not modify, crop, resize, recolor, redraw, or overwrite the canonical PNG source files.

`guide_line` remains forbidden. No persistent aiming line, guide arrow, or guide-line asset.

## Owner-approved screen composition contract

Portrait gameplay screen:

- tropical beach-bar background and long perspective wooden table from M06;
- **top-left:** Beach Cocktails Merge logo;
- directly below logo: **Best Score** panel;
- directly below Best Score: **Score** panel;
- **upper center:** To-Go Orders panel with a large current target cocktail and current reward;
- **upper right:** exactly one NEXT panel with the true next launch cocktail;
- no second/bottom NEXT presentation;
- near bottom: 12-slot progression strip populated L01 through L12 in exact order;
- held launch cocktail above/on the glowing gold launch-zone oval;
- danger line at the already accepted M06 gameplay `death_line_y` coordinate;
- no guide line.

The result should be a polished integrated gameplay screen, not placeholder debug UI layered on top of owner-approved panels.

## M07.01 — HUD architecture and prototype cleanup

1. Replace/supersede the current prototype score/best/next/target/hint presentation with canonical asset-backed HUD composition.
2. Keep changing values dynamic Godot nodes. Do not bake score, best score, target level, reward, Next cocktail, progression icons, combo text or runtime data into PNGs.
3. Use a clear HUD root/CanvasLayer architecture independent of physics bodies.
4. Do not leave duplicate prototype labels visible behind/on top of final panels.
5. Remove the old permanent instructional bottom hint from normal gameplay composition unless it is explicitly needed as a temporary debug-only element. M10 owns onboarding.
6. Keep Game Over functional; its final art polish may remain later, but M07 HUD must not become interactive obstruction during normal play.

## M07.02 — Logo, Best Score, and Score

1. Place canonical logo at top-left in the owner-approved visual hierarchy.
2. Place `panel_best_score.png` directly below logo.
3. Place `panel_score.png` directly below Best Score.
4. At runtime render live numeric Best Score and Score values over their blank content regions.
5. Normalize the two panels to the same displayed width/height despite the accepted 2 px source-width delta, without editing source PNGs.
6. Text must be readable at the canonical 720x1280 logical viewport and representative portrait variants.

## M07.03 — To-Go Orders panel

1. Place `panel_to_go_orders.png` in the upper-middle region without blocking the active table accumulation zone.
2. Populate the current target cocktail dynamically through the shared M05 canonical texture accessor.
3. Populate the current To-Go reward dynamically from production data.
4. When the target changes, the panel preview/reward must update to the actual new target.
5. There must be one active order presentation, matching production state.
6. M08 owns the polished delivery-flight/trail effect. M07 only needs correct dynamic completion/update state.

## M07.04 — NEXT panel

1. Place `panel_next.png` at upper-right.
2. Populate it with the true next launch drink texture from `ShotController` state.
3. Immediate next generation after every shot must update the panel coherently.
4. Exactly one NEXT panel/preview is allowed. Remove/hide prototype text or any secondary bottom NEXT representation.
5. Rapid consecutive launches must not desynchronize held/current/next preview state.

## M07.05 — Progression strip

1. Place `progression_strip.png` near the bottom while preserving useful play-table area.
2. Populate exactly 12 slots, L01 through L12 left-to-right, from the shared canonical texture accessor.
3. Do not create a duplicate asset mapping.
4. Icons must remain legible and fit their visual slots; garnish may visually extend within reason but must not break the strip.
5. No thirteenth/L13 slot.
6. Dynamic level labels are optional only if they improve clarity without cluttering the approved art.

## M07.06 — Launch zone

1. Place `launch_zone.png` centered under the held cocktail at the M06 launch position.
2. The launch zone must be a visual-only non-colliding HUD/world decoration.
3. It must not alter shot physics, drag behavior, collider, launch speed, or spawn position.
4. Keep it behind the held cocktail and readable above the background/table.
5. Hide or appropriately suppress it during Game Over if a held launch state no longer exists.

## M07.07 — Danger line

1. Replace/supersede the temporary procedural danger-boundary drawing with canonical `danger_line.png`.
2. The visual must be centered at the already accepted production `death_line_y`; do not change gameplay threshold to fit the art.
3. Scale/crop the visual dynamically as needed to fit the visible table width while keeping its source proportions sensible.
4. Danger-line visual must not intercept input or participate in physics.
5. Remove duplicate procedural red danger-line rendering once canonical art is active.

## M07.08 — Combo and transient gameplay text

The combo state remains live gameplay data. It may be shown with a restrained dynamic label near the central HUD/table area if it remains readable and does not conflict with the master composition. Do not build M08 merge effects here.

## Responsive composition

Validate at minimum:

- canonical 720x1280;
- taller portrait 720x1440;
- shorter/wider portrait 800x1280.

For each:

- logo/panels remain visible and non-overlapping;
- upper HUD does not consume the active accumulation region excessively;
- Next and To-Go do not overlap;
- progression strip remains visible;
- launch zone and held cocktail remain inside the playable table;
- danger line visually tracks `death_line_y`;
- no gameplay-critical clipping/black bars caused by HUD layout;
- no duplicate legacy labels/panels appear.

Use anchors/derived layout or a clear canonical-layout transform rather than unrelated hardcoded magic numbers scattered across scripts.

## Owner-playable visual evidence

M07 must retain deterministic screenshots from the actual production scene after final composition:

```text
docs/evidence/m07/canonical_720x1280.png
docs/evidence/m07/taller_720x1440.png
docs/evidence/m07/shorter_wider_800x1280.png
```

Screenshots should be taken from a representative live state that proves:

- real background/table;
- real cocktail sprites;
- logo;
- Best Score panel/value;
- Score panel/value;
- To-Go target + reward;
- exactly one NEXT preview;
- 12 populated progression icons;
- launch zone;
- danger line.

Where practical also retain a second representative gameplay-state screenshot showing multiple drinks on the table and updated Next/To-Go data, but do not create noisy evidence if the three required captures already prove the contract.

These screenshots are evidence for independent audit and then owner visual acceptance. They do not replace deterministic state assertions.

## Focused M07 deterministic probe

Create `tests/m07_hud_integration_probe.gd` or equivalent. It must instantiate/use production scene and production APIs, not duplicate game rules.

At minimum assert:

- exact canonical asset paths are used by each M07 visual;
- exactly one logo;
- exactly one displayed Best Score panel;
- exactly one displayed Score panel;
- exactly one To-Go panel;
- exactly one Next panel;
- exactly one progression strip with exactly 12 populated canonical textures in order;
- exactly one launch-zone visual;
- exactly one canonical danger-line visual and no old procedural duplicate;
- no `guide_line` node/asset;
- displayed score/best values follow production state;
- displayed To-Go target/reward follow production state;
- displayed Next preview follows actual next state after launch;
- rapid launch does not desync current/next HUD;
- restart restores coherent HUD;
- Game Over does not leave orphan/duplicate HUD nodes;
- all three responsive layouts pass bounds/overlap sanity checks.

## Regression suite

After production HUD changes rerun:

- M01 contract probe;
- M02 physics regression;
- M03 economy regression;
- M04 asset import probe;
- M05 sprite integration probe;
- M06 environment/geometry probe;
- M07 focused probe;
- Godot import/parse;
- configured main-scene startup.

All exact commands, retained outputs and exit codes go in the M07 Codex log.

## Change policy

Allowed:

- production HUD composition code;
- canonical UI Sprite2D/TextureRect/Control nodes and live labels;
- bounded layout helpers;
- canonical danger-line/launch-zone visual integration;
- deterministic test/evidence support;
- removal/suppression of superseded prototype HUD visuals.

Not allowed:

- source PNG edits;
- gameplay/economy/physics retuning;
- M06 rail/death/launch coordinate redesign solely for HUD fit;
- guide line;
- M08 delivery trail/merge VFX polish beyond minimal existing behavior;
- audio/haptics;
- menus/onboarding/export work;
- `TASKS.md` edits.

## Evidence-first log

Create:

`docs/codex-logs/BCM-M07_MILESTONE_COMPLETION_V01_CODEX_LOG.md`

Include:

- exact sync-first outputs;
- full changed-file list;
- HUD node/asset architecture;
- canonical displayed asset paths;
- exact layout coordinates/scales for canonical and representative portrait variants;
- proof source PNGs are untouched;
- proof duplicate prototype UI is removed/suppressed;
- proof exactly one Next and one To-Go presentation exist;
- progression 12-slot runtime mapping evidence;
- launch-zone alignment evidence;
- danger-line visual vs gameplay threshold evidence;
- dynamic score/best/target/reward/next state evidence;
- focused M07 probe output;
- M01-M06 regression results and exit codes;
- Godot version/import/startup outputs;
- retained M07 screenshot paths, dimensions, byte sizes and SHA256 values;
- `git diff --check` result;
- confirmation no `guide_line`;
- confirmation no M08+ work started;
- confirmation `TASKS.md` untouched;
- verified vs unverified limitations.

Do not ask the owner to relay terminal evidence. Put it in the committed log.

## Completion procedure

1. Sync and inspect.
2. Implement final M07 dynamic gameplay HUD composition.
3. Run focused M07 test.
4. Rerun M01-M06 regressions.
5. Run Godot import/parse/main-scene startup.
6. Generate/retain required M07 screenshots.
7. Inspect final diff/status and source PNG hashes/status.
8. Commit and push all intended M07 work/evidence/log to `main`.
9. Fetch remote and verify synchronization.
10. Do not edit `TASKS.md`.
11. Do not start M08+.
12. STOP for independent ChatGPT audit.

## Completion response

Return only:

- M07 Codex log GitHub URL;
- pushed commit SHA;
- one-line M07 result or blocker;
- confirmation canonical source PNGs untouched;
- confirmation `TASKS.md` untouched;
- confirmation M08+ not started.

All detailed evidence must already be in the committed log.