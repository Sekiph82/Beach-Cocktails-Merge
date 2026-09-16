# BCM-M04-R01 — ChatGPT Strict Re-Audit V01

Decision: **CHANGES_REQUIRED**

This re-audit supersedes the earlier unconditional M04 acceptance for purposes of project progression. It does not claim the owner-approved PNGs are wrong. It finds that the original M04 validation evidence and tests were too weak/circular to justify an audited visual/semantic PASS.

## Audited against

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `docs/prompts/BCM-M04_MILESTONE_COMPLETION_V01_PROMPT.md`
- `docs/codex-logs/BCM-M04_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- implementation commit `b3dd8b43fc6d47c48d17368d77d9c0a24a961048`
- `tools/m04_asset_validation.py`
- `tests/m04_asset_import_probe.gd`
- canonical asset inventory under `assets/`
- owner-approved master visual `/b75ee426-9568-4ed6-b35e-140600a7c995.png`

## Evidence classification

### Implementer evidence

The M04 Codex log reports direct visual inspection of all cocktail/UI/environment assets, 12 progression slots, garnish/straw semantics, launch-zone cleanliness, blank dynamic panel areas, and background semantic cleanliness.

Those statements are builder evidence only.

### Independently verified repository evidence

ChatGPT independently verified the validation-tool/test bodies and Git scope. The tools do prove:

- the explicit 22-path inventory exists in code;
- each path is attempted for load;
- width/height and alpha statistics are measured;
- Godot can load the textures when the builder run is trusted;
- no M05+ production integration was introduced by M04.

They do **not** independently prove the material semantic visual requirements.

## Findings

### F-M04-STRICT-001 — Asset validator reports PASS without enforcing the visual/alpha contract — MAJOR

`tools/m04_asset_validation.py` prints `PASS` for every file that merely opens successfully. It records alpha/full-opacity statistics but never fails when a cocktail/UI/effect that is expected to have transparency is fully opaque, when transparency is otherwise semantically wrong, or when dimensions/shape violate the intended contract.

The final result is based only on `missing/load` failures. Therefore `M04_PYTHON_RESULT=PASS` is not equivalent to the M04 acceptance contract.

### F-M04-STRICT-002 — Asset-count evidence is tautological — MINOR

Both Python and Godot probes print expected and observed asset counts from the same hardcoded list length. In particular `M04_GODOT_ASSET_COUNT expected=%d observed=%d` uses `CANONICAL.size()` for both values. This does not independently count repository assets or prove there are no missing/extra/conflicting canonical files.

Individual load attempts partly mitigate missing-file risk, but the count claim itself is not valid evidence.

### F-M04-STRICT-003 — Progression-strip 12-slot acceptance is not tested — MAJOR

The Python tool literally prints:

`M04_PROGRESS_OVERLAY_MANUAL intended_empty_slots=12 (direct visual inspection)`

No image analysis or retained independently inspectable evidence backs the exact 12-slot claim. The original log's manual count is implementer evidence only.

### F-M04-STRICT-004 — Cocktail straw/garnish semantics are builder assertions only — MAJOR

The original log contains a strong per-level semantic matrix, but the deterministic tools do not inspect or prove those semantic details. There is no retained M04 contact sheet/crop/annotation package tying each semantic claim to inspectable evidence.

### F-M04-STRICT-005 — Environment/UI semantic cleanliness is builder assertion only — MAJOR

Claims such as:

- background contains no baked gameplay UI;
- To-Go/Next panels have blank dynamic areas;
- launch zone has a transparent center and no clutter;
- To-Go trail has no dominant garnish object;

are not established by the deterministic checks. Alpha statistics alone cannot prove these claims.

### F-M04-STRICT-006 — Owner master was not used as an explicit canonical comparison target — MAJOR

The repository contains the owner-approved master visual at `/b75ee426-9568-4ed6-b35e-140600a7c995.png`. The original M04 validation did not make a retained master-to-asset comparison package or lock the master as visual truth for the separated assets.

This matters because later M06/M07 composition can technically use valid PNGs while still diverging from the intended overall visual language.

### F-M04-STRICT-007 — Best Score / Score panel 2 px source-width mismatch is correctly disclosed — NOTE

This is not an M04 source-asset defect by itself. Runtime displayed parity belongs to M07. The mismatch must remain documented and must not be hidden by editing owner PNGs.

## Acceptance matrix

| Criterion | Re-audit result |
|---|---|
| 22 required paths enumerated | PASS |
| Files/loadability evidenced | PASS |
| Dimensions/alpha metrics measured | PASS |
| Alpha/transparency contract actually enforced | FAIL |
| L01-L12 semantic straw/garnish contract independently evidenced | UNVERIFIED |
| Background semantic cleanliness independently evidenced | UNVERIFIED |
| Blank dynamic UI regions independently evidenced | UNVERIFIED |
| Progression strip exactly 12 empty slots independently evidenced | UNVERIFIED |
| Launch-zone semantic contract independently evidenced | UNVERIFIED |
| To-Go trail semantic contract independently evidenced | UNVERIFIED |
| Owner-master relationship explicitly evidenced | FAIL |
| No M05+ implementation leakage | PASS |
| TASKS untouched by Codex | PASS |

## Verdict rationale

Under the corrected audit policy, material visual criteria may not be converted to PASS from builder prose. Several core M04 requirements are `UNVERIFIED`, and the deterministic validation script overstates what its PASS means.

Therefore M04 cannot remain unconditionally accepted.

## Required remediation

M04 remediation must:

1. strengthen the deterministic validator so PASS means the machine-checkable contract actually passed;
2. distinguish machine-checkable facts from human visual semantics;
3. create retained M04 visual evidence for all 12 cocktails, environment, UI and effect assets;
4. explicitly tie separated assets to the owner master visual;
5. preserve all owner-approved source PNG bytes unless a genuine source defect is discovered and separately owner-approved;
6. produce a new immutable remediation log and stop for independent re-audit.

## Final verdict

**CHANGES_REQUIRED**
