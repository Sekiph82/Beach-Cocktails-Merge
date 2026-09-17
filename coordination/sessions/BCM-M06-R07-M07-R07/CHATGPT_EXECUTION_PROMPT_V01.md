# BCM-M06-R07 + BCM-M07-R07 — Strict Regression Closure Master Prompt V01

Status: **ISSUED**

## Goal
Close the only remaining blocker from the independent M06-R06/M07-R06 audit without redoing the accepted production geometry/HUD work.

The owner-facing R06 production changes are provisionally accepted from source/diff evidence. The blocker is that the legacy baseline M06 geometry probe still fails against stale M06-R04 datasets, so the repository does not yet have a genuinely green full M01-M07 regression.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R06/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M07-R06/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M06-R07/CHATGPT_AUDIT_CRITERIA_V01.md`

Run governed sync preflight and preserve any owner-local dirty file such as `project.godot`.

## PHASE 1 — BCM-M06-R07
Reconcile the baseline M06 regression harness with the current authoritative M06-R06 piecewise geometry.

Required:
- update `tests/m06_environment_geometry_probe.gd` so it validates the current five-sample/piecewise full-tabletop geometry rather than stale M06-R04 two-endpoint assumptions;
- update the datasets that this baseline test reads (`docs/evidence/m06/expected_landmarks.json`, `docs/evidence/m06/render_space_landmarks.json`, or replacement equivalents) to the current R06 authoritative independent measurements;
- preserve meaningful coverage for background asset, perspective, wall topology, danger/launch coordinates, collision-safe bounds, responsive cases and no-guide-line contract;
- if the old assertion `production walls use four bounded perspective rail segments` is obsolete because R06 intentionally uses multiple piecewise segments, replace it with an assertion that validates the complete segmented rail chain and top/bottom stops;
- do not weaken assertions merely to get green;
- do not change production geometry unless this reconciled independent test proves a genuine mismatch.

Required phase log:
`coordination/sessions/BCM-M06-R07/CODEX_LOG_V01.md`

Commit/push this phase separately.

## PHASE 2 — BCM-M07-R07 verification closure
Do not redesign M07-R06. Re-run and preserve its current behavior.

Required verification:
- BEST left under logo;
- SCORE right beneath/near NEXT;
- fixed 20 px / 7-digit score contract;
- glyphs centered in the recessed value windows;
- To-Go target + reward only, no Lx/name, no leading plus;
- reward remains inside the cream board;
- ropes remain attached to viewport top;
- NEXT L01-L12 containment;
- held visible glass/container X center + body-bottom Y aligned to halo/baseline;
- baked 2x6 progression unchanged;
- M06-R06 widened full-tabletop geometry preserved.

Required phase log:
`coordination/sessions/BCM-M07-R07/CODEX_LOG_V01.md`

This phase should ideally be evidence/test only. Production changes are allowed only if the reconciled suite exposes a genuine bug; document any such change explicitly.

## FINAL SUITE
Run serially on final candidate main:
- M01 contract probe
- M02 physics probe
- M03 economy/To-Go/persistence/Game Over probe
- M04 asset import probe
- M05 sprite/collider probe
- reconciled `tests/m06_environment_geometry_probe.gd`
- `tests/m06_r06_full_tabletop_probe.gd`
- `tests/m07_r04_focused_probe.gd`
- `tests/m07_r06_owner_layout_probe.gd`
- Godot 4.7.x import/startup
- `git diff --check`

No known failing test may be excluded from the final regression by simply calling it retired.

## Governance
- Do not edit `TASKS.md`.
- Do not edit ChatGPT-owned prompt/audit/criteria/policy files.
- Do not rewrite historical logs.
- Do not modify canonical PNGs.
- Do not start M08+.
- Do not self-audit or write AUDITED_PASS.

## Final response
Return only:
- BCM-M06-R07 log URL + commit SHA
- BCM-M07-R07 log URL + commit SHA
- exact final suite result summary
- `AWAITING_AUDIT`
Then STOP.
