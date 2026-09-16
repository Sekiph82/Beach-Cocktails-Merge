# BCM-M05 — Cocktail Sprite Integration and Level Presentation V01

## Purpose

Complete all M05 cocktail-sprite integration work for Beach Cocktails Merge in one bounded Codex session. Replace placeholder drink presentation with canonical L01-L12 V7 cocktail sprites while preserving the accepted M01-M03 gameplay/physics/economy contract.

Do not start M06 environment composition, M07 HUD composition, or later visual/effects work.

## Canonical repository and workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: `4.7.x`

## Mandatory governance

Read and obey before working:

- `AGENTS.md`
- root `TASKS.md`
- `docs/audits/BCM-M04_MILESTONE_COMPLETION_V01_AUDIT.md`
- `docs/codex-logs/BCM-M04_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- this prompt

Codex must never edit `TASKS.md` and must stop for independent ChatGPT audit after M05.

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

Safely reconcile remote governance commits without discarding owner-local work. Never use destructive reset, force-push, automatic rebase, destructive checkout, or silent stash.

## Accepted gameplay invariants that must remain unchanged

Do not retune or redesign these as a side effect of art integration:

- launch speed `700 px/s`;
- slide deceleration `180 px/s²`;
- no artificial cruise/minimum-speed assist;
- held drink frozen/non-colliding until release;
- immediate next-held generation;
- multiple moving drinks supported;
- settled drinks remain physically movable when hit;
- forward-only/no intentional +Y rebound behavior;
- merge momentum preservation;
- L12 hard cap;
- merge score table and combo behavior accepted in M03;
- To-Go reward table L6=1000, L7=1800, L8=3000, L9=5000, L10=8000, L11=12000, L12=18000;
- stored-drink To-Go payout semantics;
- persistence, danger-line, Game Over and restart behavior.

## Canonical cocktail assets

Use only:

`assets/cocktails/L01.png` through `assets/cocktails/L12.png`.

Do not regenerate, redraw, recolor, crop, overwrite, or replace these owner-approved files.

## M05.01 — Deterministic level-to-texture mapping

1. Add one clear production mapping from level 1..12 to the exact canonical cocktail PNG.
2. Use the same canonical texture source for:
   - table drinks;
   - held launch drink;
   - merge results;
   - future Next/To-Go/progression consumers through reusable mapping/API where practical.
3. Avoid duplicated hardcoded texture paths scattered across unrelated scripts.
4. Invalid/out-of-range levels must fail safely without inventing an L13 asset.

## M05.02 — Replace placeholder drink visuals

1. Replace current placeholder drink geometry/presentation with `Sprite2D` or another appropriate Godot 2D visual node using the canonical texture.
2. Keep physics/body ownership in `Drink`; visual nodes must not become independent gameplay bodies.
3. Remove or hide obsolete placeholder geometry only where it is superseded by the sprite; do not delete useful debug/test affordances if tests rely on them.
4. Ensure held, sliding, settled, merging and target-captured visual states remain coherent.
5. Ensure texture changes atomically when level changes/merge result is created.

## M05.03 — Visual scale and pivot strategy

Use the M04 transparent-bound evidence rather than raw canvas dimensions alone.

Define a deterministic per-level scale/pivot strategy such that:

- all L01-L12 cocktails fit the portrait playfield;
- levels remain visually distinguishable;
- apparent size progression is sensible without runaway growth;
- garnish/straw extremes do not dictate collision size;
- sprite pivots/offsets make the visible glass body sit naturally on the physical body center;
- no sprite visibly floats far from its collider or teleports on state changes.

The original PNG canvases are large and not uniform; runtime scaling is expected.

## M05.04 — Collider-to-visible-glass footprint alignment

This is the deferred M02 acceptance item and must now be addressed.

1. Inspect each cocktail's visible glass/body footprint separately from garnish/straw/flowers/leaves.
2. Define/document a per-level collision footprint that approximates the physical glass/body region, not decorative extremes.
3. Avoid oversized colliders that leave large invisible gaps between apparently touching drinks.
4. Avoid colliders so small that sprites visibly overlap unrealistically.
5. Preserve the accepted compressed runtime mass progression; do not restore JSON mass doubling as physics mass.
6. Any radius adjustments must be evidence-backed and bounded to visual/body alignment, not gameplay retuning.
7. Rerun M01-M03 physics/economy regressions after any collider/radius production change.

## M05.05 — Merge visual continuity

Deterministically verify:

- two same-level cocktails merge into the correct next sprite;
- result appears at a physically plausible merge/contact position;
- result texture/level/collider are updated atomically;
- merge result retains accepted forward/lateral momentum;
- no obvious visual teleport beyond expected replacement positioning;
- L12 remains L12-cap behavior and no L13 visual/path appears.

## M05.06 — Reusable presentation hooks for later HUD milestones

M05 must not build the M07 HUD, but production code should expose a reusable canonical level texture accessor or equivalent so M07 can populate Next, To-Go and progression strip without duplicating asset mapping.

Do not place logo, score panels, To-Go panel, Next panel, progression strip, launch zone, danger line, or background in M05.

## Deterministic validation

Add/extend focused non-production probe(s) under `tests/` as needed. Evidence must use the production main scene/classes rather than reimplementing game rules.

At minimum provide PASS/FAIL evidence for:

- all 12 canonical textures load through production mapping;
- L01-L12 table/held presentation can be instantiated;
- rendered Sprite2D/visual node exists for each level;
- per-level scale/offset/collider strategy is deterministic and documented;
- collider footprint is aligned to visible glass body using recorded evidence/measurements;
- merge produces the correct next-level sprite and preserves momentum;
- L12 has no L13 texture/merge;
- rapid launches still produce coherent held/current/next visuals;
- restart and Game Over leave no orphan visual nodes;
- M01, M02 and M03 regression probes still PASS;
- Godot import/parse and main-scene startup remain clean.

Where direct pixel/body-footprint measurement cannot be perfectly automated, retain exact derived measurements and mark the human visual interpretation explicitly. Do not falsely claim native-device visual acceptance.

## Production-change policy

M05 may modify production visual code and collider/radius mapping only as necessary for accepted cocktail sprite integration. Keep changes bounded.

Do not change:

- scoring/combo/To-Go economy;
- launch/deceleration physics tuning;
- environment/background composition;
- HUD layout;
- danger-line position for design reasons;
- guide-line behavior/assets;
- audio/haptics/menu/export work;
- owner-approved source PNGs.

## Evidence-first log

Create one immutable log:

`docs/codex-logs/BCM-M05_MILESTONE_COMPLETION_V01_CODEX_LOG.md`

The log must include:

- sync-first outputs;
- exact files changed;
- production level-to-texture mapping;
- per-level source texture, source dimensions, transparent bounds, runtime scale, visual offset/pivot, collider radius/footprint and runtime mass;
- before/after collider values if changed;
- direct explanation of how garnish/straw extremes were excluded from collision sizing;
- Godot asset load and runtime visual evidence;
- merge visual-continuity evidence;
- rapid-launch/restart/Game-Over visual-state evidence;
- M01/M02/M03 regression results and exit codes;
- import/parse/startup results and exit codes;
- `git diff --check` result;
- explicit confirmation canonical PNGs were not modified;
- explicit confirmation `TASKS.md` was not modified;
- explicit confirmation M06/M07 and later integration were not started;
- verified vs source-inferred/manual-inspection vs unverified matrix;
- known limitations.

The owner must not be used as a clipboard for terminal evidence.

## Completion procedure

1. Inspect final diff/status.
2. Confirm source PNGs are byte-for-byte untouched by this task.
3. Run focused M05 validation.
4. Rerun M01, M02 and M03 regression probes.
5. Run Godot import/parse and main-scene smoke checks.
6. Commit and push all intended M05 work and immutable log to `main`.
7. Fetch `origin/main` again and verify no intended work remains uncommitted.
8. Do not edit `TASKS.md`.
9. Do not start M06/M07 or later work.
10. STOP for independent ChatGPT audit.

## Completion response

Return only:

- M05 Codex log GitHub URL;
- pushed commit SHA;
- one-line M05 result or exact blocker;
- confirmation canonical PNGs were not modified;
- confirmation `TASKS.md` was not edited;
- confirmation M06/M07 were not started.
