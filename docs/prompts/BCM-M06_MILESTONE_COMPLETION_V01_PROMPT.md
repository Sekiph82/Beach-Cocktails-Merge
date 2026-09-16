# BCM-M06 — Environment, Table Composition, and Responsive Playfield Integration V01

## Purpose

Complete all M06 environment/background and responsive playfield integration work for Beach Cocktails Merge in one bounded Codex session. Integrate the owner-approved tropical beach-bar environment and align production gameplay geometry to the visible perspective table while preserving the accepted M01-M05 gameplay, economy, collision, and cocktail-sprite contracts.

Do not start M07 HUD composition, M08 effects, or later milestones.

## Canonical repository and workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: `4.7.x`

## Mandatory governance

Read and obey before working:

- `AGENTS.md`
- root `TASKS.md`
- `docs/audits/BCM-M05_MILESTONE_COMPLETION_V01_AUDIT.md`
- `docs/codex-logs/BCM-M05_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- this prompt

Codex must never edit `TASKS.md` and must stop for independent ChatGPT audit after M06.

The M05 audit records one historical builder-log correction: the true pre-M05 JSON radius series was `14,21,29,38,48,59,71,84,98,113,129,146`. Do not propagate the incorrect historical `18,22,26...` series into new documentation or tests.

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

Safely reconcile remote audit/prompt/tracker commits without discarding owner-local work. Never use destructive reset, force-push, automatic rebase, destructive checkout, or silent stash.

## Accepted gameplay and presentation contracts to preserve

Do not retune these as a side effect of environment integration:

- launch speed `700 px/s`;
- slide deceleration `180 px/s²`;
- no artificial cruise/minimum-speed assist;
- held drink frozen/non-colliding until release;
- immediate next-held generation;
- multiple moving drinks supported;
- settled drinks remain physically movable when hit;
- no intentional +Y/backward rebound;
- merge momentum preservation;
- L12 hard cap;
- accepted M03 scoring/combo/To-Go/persistence/Game Over behavior;
- canonical L01-L12 Sprite2D mapping and M05 presentation/collider mapping;
- no `guide_line` asset or persistent aiming line.

## Canonical environment asset

Use only:

`assets/environment/game_board_background.png`

Do not regenerate, redraw, crop, recolor, overwrite, or replace the owner-approved background.

M04 verified that this asset is a 1024x1536 tropical beach-bar scene with an empty long perspective wooden table and no baked dynamic HUD/gameplay overlays.

## M06.01 — Background composition

1. Add the canonical background as the base visual layer behind gameplay.
2. Keep it visually stable and independent of drink physics transforms.
3. Fit/crop/scale through Godot runtime composition only; never modify the PNG bytes.
4. Preserve the portrait composition and avoid distortion.
5. Ensure dynamic cocktails remain visually above the table/background.
6. Do not place M07 logo, score, To-Go, Next, progression strip, launch-zone art, or danger-line PNG in this milestone unless a minimal temporary/debug overlay is already production-owned and necessary for geometry evidence. M07 owns final HUD composition.

## M06.02 — Perspective table / physics playfield alignment

Inspect the approved background directly and define/document a production mapping between the visible table and gameplay geometry.

At minimum establish and retain evidence for:

- visible table top usable left/right boundaries by Y/depth;
- top accumulation/stop region;
- launch X/Y;
- danger/deadline Y;
- bottom launch-zone region;
- production wall/rail positions and shapes;
- relation between the circular cocktail colliders and perspective table edges.

The approved table narrows toward the top. Use appropriate Godot collision geometry/polygons/segments or bounded runtime geometry so drinks remain inside visually credible table rails. Do not force a rectangular playfield onto a visibly perspective table if it produces obvious floating/gap conflicts.

Preserve the tabletop sliding mechanic. Do not introduce gravity/Suika behavior.

## M06.03 — Play-space tuning

Owner direction: the danger line should remain closer to the launch zone than in the early master mockup, preserving more usable table area.

Within that constraint:

1. align the launch position naturally to the lower table;
2. keep enough room below/around the danger line for the held launch cocktail;
3. maximize usable table area without hiding the top accumulation zone behind future HUD space;
4. keep the top stop boundary visually credible;
5. any coordinate adjustment must be justified as visual-table alignment, not general gameplay retuning;
6. if danger-line/playfield coordinates change, rerun all accepted gameplay/economy regressions.

## M06.04 — Canonical portrait and responsive scaling

Establish/document the canonical design-space relationship between the current Godot viewport and the 1024x1536 source background.

Validate representative portrait conditions, at minimum:

- project logical/design viewport;
- current desktop debug override;
- one taller-phone aspect;
- one shorter/wider-phone portrait aspect.

For each, demonstrate that:

- background fills the screen appropriately without geometric distortion;
- critical table/launch/top regions remain visible;
- gameplay coordinates stay coherent with the table;
- no gameplay-critical black bars are introduced where avoidable;
- cocktails remain inside the visible table at representative depths;
- future M07 HUD safe areas are not consumed by accidental cropping.

Do not build final M07 HUD in M06.

## M06.05 — Deterministic geometry validation

Create/extend non-production probe support under `tests/` as needed. Use production scene/classes and actual production geometry.

At minimum provide PASS/FAIL evidence for:

- canonical background is present in production scene/runtime and uses the exact asset;
- background node is behind gameplay drinks;
- background aspect/scale strategy is deterministic;
- left/right/top/bottom playfield geometry corresponds to the visible perspective table rather than arbitrary hidden bounds;
- representative L01, mid-level, and L12 colliders remain inside table rails at representative top/middle/bottom Y positions;
- held launch cocktail starts in a visually valid launch position;
- danger line remains near launch side while leaving usable play area;
- top accumulation/stop region is visible and physically usable;
- direct/glancing collision, rapid launch, merge, restart, Game Over and To-Go behavior remain intact after geometry changes;
- M01, M02, M03 and M05 focused probes still PASS;
- Godot import/parse and main-scene startup remain clean.

If exact visual-table boundaries require human interpretation, record the measured pixel/design-space points and clearly mark the interpretation as manual visual evidence. Do not claim native-device aesthetic acceptance unless actually performed.

## M06.06 — Screenshot / visual evidence

Produce retained runtime screenshots or equivalent deterministic rendered captures for at least:

- canonical design portrait;
- taller portrait;
- shorter/wider portrait;

Each capture should show enough of the production scene to evaluate background fit, visible table, cocktail placement, launch area, top region and rail alignment. These are audit evidence, not owner-final visual acceptance.

Do not commit machine-specific temporary screenshots unless the project governance/tooling has a canonical evidence path. If screenshots are committed, place them under a clearly named `docs/evidence/m06/` path and keep only purposeful evidence images.

## Production-change policy

Allowed:

- production background node/composition;
- bounded playfield/wall/rail geometry changes necessary to match the visible table;
- bounded launch/danger/top-stop coordinates necessary for visual-table alignment;
- responsive background/geometry helpers;
- deterministic M06 test/evidence support.

Not allowed:

- modifying canonical background/cocktail/UI PNGs;
- M07 HUD composition;
- M08 delivery/merge effects;
- guide line;
- broad gameplay retuning;
- scoring/combo/To-Go reward changes;
- audio/haptics/menu/export work.

## Evidence-first log

Create one immutable log:

`docs/codex-logs/BCM-M06_MILESTONE_COMPLETION_V01_CODEX_LOG.md`

The log must include:

- sync-first outputs;
- exact files changed;
- canonical background asset/path and proof its bytes were not modified;
- production background node/layer evidence;
- design-space and source-background dimensions;
- measured visible-table boundary points/geometry;
- before/after production rail/wall/launch/danger/top-stop coordinates if changed;
- explanation for each geometry change;
- responsive/aspect-ratio strategy and tested dimensions;
- screenshot/render-capture evidence and where retained;
- representative collider-inside-table checks across depth;
- M01/M02/M03/M05 regression results and exit codes;
- focused M06 probe result and exit code;
- Godot import/parse/startup results and exit codes;
- `git diff --check` result;
- explicit confirmation canonical PNGs were not modified;
- explicit confirmation `TASKS.md` was not modified;
- explicit confirmation M07+ was not started;
- verified/manual-visual/unverified matrix;
- known limitations.

The owner must not be used as a clipboard for terminal evidence.

## Completion procedure

1. Inspect final diff/status.
2. Confirm canonical background and cocktail/UI PNGs are byte-for-byte untouched.
3. Run focused M06 geometry/responsive validation.
4. Rerun M01, M02, M03 and M05 probes.
5. Run Godot import/parse and main-scene smoke checks.
6. Produce/retain bounded runtime visual evidence.
7. Commit and push all intended M06 work and immutable log to `main`.
8. Fetch `origin/main` and verify synchronization.
9. Do not edit `TASKS.md`.
10. Do not start M07 or later work.
11. STOP for independent ChatGPT audit.

## Completion response

Return only:

- M06 Codex log GitHub URL;
- pushed commit SHA;
- one-line M06 result or exact blocker;
- confirmation canonical PNGs were not modified;
- confirmation `TASKS.md` was not edited;
- confirmation M07+ was not started.
