# BCM-M05-R01 — ChatGPT Strict Re-Audit V01

Decision: **CHANGES_REQUIRED**

This re-audit supersedes the earlier unconditional M05 acceptance for project progression. The current implementation may still be directionally correct, but the original evidence does not prove the core visual/collider contract strongly enough.

## Audited against

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- original M05 prompt/log
- M05 implementation range `31f8a088d77a29c89ba34b2e5bf2552fd3b225f7..56a21dc503fb72e1a00f8fcec78334555b3a92ef`
- `scripts/drink.gd`
- `tests/m05_sprite_integration_probe.gd`
- M01-M03 regression evidence
- M04 re-audit findings
- owner master visual `/b75ee426-9568-4ed6-b35e-140600a7c995.png`

## Findings

### F-M05-STRICT-001 — Visible-body measurements have unsupported provenance — MAJOR

`Drink.VISIBLE_BODY_WIDTH_PX` and `VISIBLE_BODY_CENTER_OFFSET_PX` are described as manual body-region measurements from the M04 transparent-bound inspection.

The original M04 deterministic work measured whole-image alpha bounding boxes, not glass-body-only widths/centers. The M04 log also did not establish the exact M05 body-width/center table later committed.

Therefore the values may be reasonable, but their claimed provenance is unsupported.

### F-M05-STRICT-002 — Collider/visual test is circular — MAJOR

`tests/m05_sprite_integration_probe.gd` verifies that runtime sprite scale/offset/radius equal the same production constants/functions under test.

That proves implementation consistency, not correctness of the visual-to-physical fit.

For example:

- `sprite.scale == Drink.visual_scale_for_level(level)`
- collider radius equals `Drink.collider_radius_for_level(level)`
- radius progression is monotonic

These assertions cannot prove that the visible glass body actually aligns with the collider.

### F-M05-STRICT-003 — “Bounded for portrait playfield” assertion is too weak — MAJOR

`_max_visual_extent(manager) <= 320.0` only checks full texture width/height multiplied by scale. It does not prove:

- body center vs collider center alignment;
- garnish exclusion correctness;
- adjacent-drink apparent contact;
- absence of large invisible gaps;
- absence of unrealistic sprite overlap;
- readability/relative scale in actual gameplay.

### F-M05-STRICT-004 — Collider sizing uses body width only, with no independent body-height/shape evidence — MAJOR

The runtime circular collider is sized from `VISIBLE_BODY_WIDTH_PX`. Cocktail shapes vary substantially: martini glasses, tall highballs, coconut, pineapple body, rounded goblets.

A circle can still be an acceptable gameplay approximation, but M05 did not retain evidence showing why the chosen circle is visually credible for each level. Width-only derivation is not sufficient proof.

### F-M05-STRICT-005 — No retained visual overlay/contact evidence for L01-L12 runtime fit — MAJOR

The M05 acceptance gate required every level to render correctly and the collider to approximate the visible glass/body rather than garnish extremes. No committed M05 evidence package shows:

- actual rendered sprites at production scale;
- collider outlines over each sprite;
- pivot/body-center markers;
- side-by-side L01-L12 relative size progression;
- representative touching pairs/clusters.

Therefore the key visual acceptance remains unverified.

### F-M05-STRICT-006 — Merge/rapid-launch runtime mechanics are meaningfully tested — PASS / NOTE

The probe does provide useful non-circular evidence for:

- canonical texture mapping exists;
- invalid L13 fails safely;
- merge creates L3 texture/result;
- rapid launch maintains canonical Sprite2D ownership;
- restart/Game Over do not orphan drink visuals;
- M01-M03 gameplay/economy regressions pass.

These should be preserved.

### F-M05-STRICT-007 — Historical radius statement in builder log is false — MINOR

The immutable M05 log says previous production JSON radii were `18,22,26,30,35,41,48,55,63,71,79,89`.

Repository truth before M05 was `14,21,29,38,48,59,71,84,98,113,129,146`.

This was already identified previously. Remediation must not rewrite the historical log; it must retain the correction in the new remediation log.

## Acceptance matrix

| Criterion | Re-audit result |
|---|---|
| Single L01-L12 texture mapping | PASS |
| Placeholder geometry replaced by canonical Sprite2D | PASS |
| Invalid/L13 mapping safe | PASS |
| Held/table/merge sprite ownership | PASS |
| Per-level scale/offset values deterministic | PASS |
| Body-measurement provenance | FAIL |
| Collider follows visible body rather than garnish | UNVERIFIED |
| Adjacent drinks visually close at contact | UNVERIFIED |
| No material sprite overlap at contact | UNVERIFIED |
| Relative L01-L12 size progression visually credible | UNVERIFIED |
| Pivot/body center visually credible | UNVERIFIED |
| Merge sprite/momentum continuity | PASS |
| M01-M03 regressions preserved | PASS |
| Historical-radius documentation truthful | FAIL in old log; correction required in new log |

## Verdict rationale

M05's most important integration-specific claim is visual/physical alignment. The existing tests primarily prove that code follows its own constants, not that those constants correspond to the owner-approved art.

Under the corrected strict audit policy, that is insufficient for an audited PASS.

## Required remediation

M05 remediation must:

1. derive or explicitly document body-region measurements with retained per-level evidence;
2. create runtime evidence showing sprite + collider + pivot for all 12 levels;
3. show representative touching pairs/clusters at actual production scale;
4. independently validate that garnish extremes do not determine collision radius;
5. adjust scale/offset/radius only where evidence proves a mismatch;
6. preserve accepted M01-M03 gameplay/economy behavior;
7. produce a new separate M05 remediation log and stop for re-audit.

## Final verdict

**CHANGES_REQUIRED**
