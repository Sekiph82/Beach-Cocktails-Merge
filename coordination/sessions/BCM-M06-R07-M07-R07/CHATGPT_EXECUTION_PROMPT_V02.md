# BCM-M06-R07 + BCM-M07-R07 — Owner Screenshot Remediation Master Prompt V02

Status: **ISSUED — SUPERSEDES V01**

This V02 supersedes the earlier regression-only R07 prompt. The latest owner runtime screenshot shows remaining production defects, so the sequence must correct production first, then close regression.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R06/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M07-R06/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M06-R07/CHATGPT_AUDIT_CRITERIA_V02.md`
- `coordination/sessions/BCM-M07-R07/CHATGPT_AUDIT_CRITERIA_V02.md`

Do not edit TASKS.md or ChatGPT-owned files. Do not start M08+.

---

# PHASE 1 — BCM-M06-R07 — Correct the actual playable tabletop envelope

The latest owner screenshot proves R06 over-widened some rear/side placements. Cocktails can visually leave the wooden tabletop and appear behind the rear lip/background.

Do NOT solve this by restoring the old narrow center corridor.

## Required geometry model
Treat the playable region as a perspective-aware **2D tabletop envelope/polygon** with:
- rear/top visible wood boundary;
- left side visible wood boundary;
- right side visible wood boundary;
- front/near boundary.

R06 left/right five-point polylines may remain useful, but they are insufficient by themselves.

### Independent measurement
Remeasure from the active owner-approved runtime/background render:
- at least 5 left-side depth samples;
- at least 5 right-side depth samples;
- rear/top boundary at multiple x positions, including rear-left, rear-center and rear-right.

Do not generate expected points by calling production helpers.

### Visible-body containment
Acceptance is based on the visible **glass/container body**, not garnish and not merely collider center/radius math.

Validate representative L01/L06/L12 contact placements at:
- rear-left;
- rear-center;
- rear-right;
- mid-left;
- mid-right;
- near-left;
- near-right.

The glass/container must remain visibly on wood. Garnish may naturally overhang.

If M05 collider/body mapping is too small and causes the body to cross the wood edge while the collider remains valid, make the smallest evidence-backed correction needed and document it. Do not arbitrarily shrink the playfield or silently retune physics.

Preserve:
- 700 px/s launch;
- 180 px/s² deceleration;
- merge/momentum behavior;
- scoring/economy/persistence/Game Over;
- danger Y and launch Y unless a genuine blocker is demonstrated;
- canonical PNGs;
- no guide line.

### Baseline regression reconciliation
Update `tests/m06_environment_geometry_probe.gd` and stale M06 geometry datasets so the baseline test represents the new authoritative tabletop envelope. Do not exclude it from the final suite and do not weaken meaningful assertions.

### Evidence
Retain for 720x1280, 720x1440 and 800x1280:
- clean screenshot;
- full geometry overlay;
- rear-left/rear-center/rear-right close-ups;
- visible-body contact overlays for L01/L06/L12.

Write:
`coordination/sessions/BCM-M06-R07/CODEX_LOG_V01.md`

Commit and push separately before Phase 2.

---

# PHASE 2 — BCM-M07-R07 — Fix the latest owner visual annotations

Preserve all accepted M07-R06 structure and assets unless this prompt explicitly changes it.

## SCORE number optical position
The SCORE panel stays on the right beneath/near NEXT.

Keep:
- fixed production font size;
- 7-digit maximum through `9999999`;
- no per-digit auto shrink.

Adjust the SCORE glyphs slightly upward so they are **visually centered** in the dark recessed rectangle, as annotated by the owner. Use rendered glyph bounds plus an explicit documented optical Y offset if needed. Do not move the whole panel merely to fix the number baseline.

BEST SCORE should remain visually centered and must not regress.

## To-Go ropes
Current technical endpoint-at-y=0 proof is insufficient because the owner screenshot still shows a visible disconnected join.

Make both ropes visually continuous from the baked panel rope endpoints to the visible top edge/ceiling.

Requirements:
- no visible gap at baked/runtime join;
- no visible gap at top/ceiling;
- width/color/shading close enough to read as one rope;
- rope remains behind panel artwork;
- no overlap over title, target, reward, NEXT or logo.

Use screenshot evidence, not only node-coordinate assertions.

## Held cocktail on gold oval
The current self-referential body-anchor test is insufficient.

For L01-L12:
- independently measure the rendered gold oval center/reference;
- independently measure the visible glass/container body bottom-center;
- align the visible body bottom-center to the intended oval center reference.

Do not derive expected values from the same `HELD_BODY_FOOT_SOURCE_PX` or `VISIBLE_BODY_CENTER_OFFSET_PX` constants under test.

This is visual-only unless a proven M05 body/collider mismatch from Phase 1 requires a bounded correction.

Retain an L01-L12 comparison sheet with:
- gold oval center crosshair;
- visible body bottom-center marker;
- per-level delta.

## Preserve
- To-Go target + reward digits only;
- no Lx/name;
- no leading plus;
- reward inside cream board;
- NEXT L01-L12 containment;
- baked 2x6 progression, top L07-L12 / bottom L01-L06;
- canonical PNGs;
- corrected M06-R07 tabletop envelope;
- no guide line.

Write:
`coordination/sessions/BCM-M07-R07/CODEX_LOG_V01.md`

Commit and push separately.

---

# FINAL SUITE — NO EXCLUSIONS

Run and retain exact exit codes/results for:
- M01 contract probe;
- M02 physics probe;
- M03 economy/To-Go probe;
- M04 asset import probe;
- M05 sprite/collider probe;
- reconciled `tests/m06_environment_geometry_probe.gd`;
- current M06-R07 full-tabletop/envelope probe;
- M07-R04 focused probe;
- current M07-R07 owner-layout probe;
- Godot 4.7.x import/startup;
- `git diff --check`.

No known failing test may be excluded by calling it retired.

## Final response
Return only:
- M06-R07 log URL + commit SHA;
- M07-R07 log URL + commit SHA;
- exact final suite result;
- `AWAITING_AUDIT`.

Then STOP.
