# BCM-M05-STRICT-CLOSURE — ChatGPT Independent Audit V01

Verdict: **AUDITED_PASS**

Audited evidence commit:
`4bc5c2c245974b0d9249be8db8e333280d1f7398`

Builder log:
`coordination/sessions/BCM-M05-STRICT-CLOSURE/CODEX_LOG_V01.md`

Locked criteria:
`coordination/sessions/BCM-M05-STRICT-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01.md`

## 1. VERDICT

**PASS.**

The remaining M05-R02 provenance blocker is resolved without changing the owner-accepted R11 production gameplay.

## 2. CONTRACT RECOVERY

The session was evidence-only. It was required to:
- independently derive L01-L12 visible body measurements from canonical PNG pixels;
- avoid production measurement constants during the independent phase;
- correct the old inaccurate shape classifications;
- compare only after the independent dataset was frozen;
- preserve all protected R11 production symbols;
- provide representative collider/body evidence;
- keep canonical PNGs and gameplay untouched.

## 3. BRANCH / HEAD / DIFF SCOPE

The evidence commit adds only:
- independent evidence JSON/Markdown/overlay;
- evidence/comparison tools;
- focused provenance probe.

No production implementation file is changed by the audited evidence commit.

## 4. ACCEPTANCE CRITERIA MATRIX

- Independent PNG-derived measurement phase: **PASS**
- No production constants/helpers used by independent generator: **PASS**
- L01-L12 independent records: **PASS**
- Source SHA-256 and dimensions recorded: **PASS**
- Independently derived body bounds/width/center offsets: **PASS**
- Garnish/transparency exclusion method documented: **PASS**
- Ambiguity notes present: **PASS**
- Corrected shape-diversity review with rationale: **PASS**
- Production comparison occurs after frozen independent dataset: **PASS**
- Non-circular differences surfaced rather than forced to equality: **PASS**
- Protected R11 symbols unchanged: **PASS**
- Representative multi-family overlay produced: **PASS**
- Focused provenance probe: **PASS**
- Active non-superseded regression evidence: **PASS**
- Production retuning: **NONE**

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH

The independent generator `tools/m05_strict_closure_evidence.py` contains no import/read of `scripts/drink.gd`, no production measurement-symbol references, and no production helper calls.

Its only measurement inputs are:
- canonical cocktail PNGs;
- explicit independently selected image-space review windows;
- alpha threshold 32.

The final bounding boxes are then deterministically derived from alpha-positive pixels inside those review windows.

The comparison tool is separate and reads production only after the independent JSON exists.

## 6. FILE / SYMBOL EVIDENCE

The new independent measurements differ materially from production in many levels, demonstrating that the dataset is not merely a copied target table.

Examples:
- L02 width: independent 653 vs production 725
- L07 width: independent 419 vs production 575
- L08 width: independent 510 vs production 615
- L09 width: independent 731 vs production 650
- L12 width: independent 731 vs production 710

Center offsets also differ materially across multiple levels.

This directly resolves the previous M05-R02 circular-evidence blocker.

The production-comparison evidence reports byte-for-byte protected-symbol equality against R11 baseline `9d6d8950da5f62f6c22d495f58414d70d034d893` for:
- `COCKTAIL_TEXTURE_PATHS`
- `VISIBLE_BODY_WIDTH_PX`
- `BOUNDARY_CONTACT_HULL_SOURCE_PX`
- `VISIBLE_BODY_CENTER_OFFSET_PX`
- `HELD_BODY_FOOT_SOURCE_PX`
- `COLLIDER_RADII`

## 7. SHAPE-DIVERSITY REVIEW

The new classification corrects the prior inaccurate dataset and matches the canonical artwork contract:

- L01/L02: tumbler / rocks glass
- L03/L07/L11: highball / tall glass
- L04/L06: martini / coupe
- L05/L08/L10: goblet / rounded glass
- L09: coconut / special container
- L12: pineapple / special container

Each classification includes explicit visual rationale and garnish exclusions.

## 8. CONTACT-FIT EVIDENCE

A representative overlay is generated for:
- L04 martini/coupe
- L03 highball
- L08 goblet
- L09 coconut
- L12 pineapple

The generator source confirms that it composes canonical artwork with:
- independent body bounds;
- independent body center marker;
- unchanged production collider circle.

This evidence is diagnostic only and does not alter production behavior.

## 9. FOCUSED TEST EVIDENCE

`tests/m05_strict_closure_probe.py` verifies:
- 12 records;
- no L13;
- no production import/symbol use in generator;
- independent-before-comparison phase ordering;
- canonical hashes;
- shape rationale presence;
- non-circular comparison differences;
- required overlay representative set;
- R11 protected-symbol equality;
- 12-level texture mapping.

Builder result: `M05_STRICT_PROBE_RESULT=PASS`.

## 10. REGRESSION EVIDENCE

Builder evidence reports exit code 0 for active non-superseded:
- M01
- M02
- M03
- M04
- M05 sprite integration
- M07 HUD composition
- M07 owner-layout probe
- R09 no-input runtime
- R10 desktop idle
- R11-compatible V09 failure reproduction path
- production script check-only
- Godot editor import/startup
- `git diff --check`

No current regression evidence indicates gameplay breakage.

## 11. SECURITY / SAFETY REVIEW

No secrets, machine-specific generated artifacts, production assets, gameplay code, `TASKS.md`, or ChatGPT-owned criteria were modified by the evidence commit.

## 12. ARCHITECTURE CONSISTENCY

The evidence workflow correctly separates:
1. independent image measurement;
2. frozen independent dataset;
3. post-freeze production comparison.

This is the separation that the failed M05-R02 attempt lacked.

## 13. TRACKER / DOCUMENTATION TRUTHFULNESS

The Codex log correctly states this is evidence-only and does not claim tracker authority.

Historical M05-R02 evidence remains intact.

## 14. DEFECTS BY SEVERITY

- BLOCKER: none.
- MAJOR: none.
- MINOR: none blocking closure.
- NOTE: the independent review windows are human-selected image-space regions rather than a fully automatic segmentation model. This is acceptable here because their provenance is separated from production constants and the derived results materially differ from production targets.

## 15. UNVERIFIED ITEMS

No material M05 closure criterion remains unverified.

The overlay is supporting diagnostic evidence, not a new visual design acceptance gate. Current owner-approved production artwork and R11 runtime behavior remain unchanged.

## 16. REGRESSION RISK

**LOW.**

This session adds evidence/tests/tools only.

## 17. AUDIT CONFIDENCE

**HIGH.**

## 18. FINAL VERDICT

**AUDITED_PASS**

M05-R02 is closed.

M00-M07 are now closed, and the project may proceed to M08 under the current governance rules.
