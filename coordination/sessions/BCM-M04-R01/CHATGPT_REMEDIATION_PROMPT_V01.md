# BCM-M04-R01 — M04 Asset Validation Remediation V01

Status: **ISSUED**

## Goal

Repair M04 auditability without redesigning owner-approved art. The objective is not to make the PNGs different; it is to make the validation truthful, deterministic where possible, and independently auditable.

## Read first

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_AUDIT_CRITERIA_V01.md`
- original M04 prompt/log
- owner master visual `/b75ee426-9568-4ed6-b35e-140600a7c995.png`

## Required work

1. Safely sync `main`; preserve all owner work.
2. Do not edit `TASKS.md` or ChatGPT-owned criteria/audit files.
3. Keep the 22 canonical owner-approved source assets byte-for-byte unchanged unless a genuine malformed-file blocker is found. If that happens, STOP and report instead of silently repairing art.
4. Replace the misleading all-purpose PASS semantics in `tools/m04_asset_validation.py` with explicit contract assertions.
5. Machine-check, at minimum:
   - exact required path count and exact required path set;
   - all 22 files exist and are tracked;
   - each loads successfully;
   - expected alpha policy: cocktails/UI/effect assets must have usable transparency; environment may be opaque;
   - non-empty alpha bounds for transparent assets;
   - no required file is zero-sized/corrupt;
   - explicit Best Score vs Score dimension delta reporting;
   - no canonical `guide_line` asset.
6. Do not label semantic visual facts as machine PASS when they are not machine-verifiable.
7. Create retained visual evidence under `docs/evidence/m04/`:
   - `cocktails_contact_sheet.png` showing L01-L12, clearly labelled;
   - `ui_contact_sheet.png` showing logo, Best Score, Score, To-Go, Next, progression strip, launch zone, danger line;
   - `environment_reference.png` or a non-destructive copy/reference capture of the canonical environment asset;
   - `effects_contact_sheet.png` for `to_go_trail.png` and any existing canonical/adjacent effect assets relevant to M04;
   - `master_reference.png` as a non-destructive evidence copy of the owner master, or retain a deterministic reference to the root master if duplication is undesirable.
8. Add a machine-readable evidence manifest, e.g. `docs/evidence/m04/manifest.json`, recording source path, SHA256, dimensions, alpha policy/result, bbox, and evidence-sheet placement for every canonical asset.
9. For `progression_strip.png`, retain a labelled visual evidence crop/contact-sheet region where exactly 12 empty slots can be independently counted. Do not pretend a filename or hardcoded number proves the count.
10. For L01-L12 semantic checks, retain a per-level table in the log describing straw/garnish observations and point to the contact-sheet position. Keep semantic result classification as `MANUAL_VISUAL_EVIDENCE`, not machine PASS.
11. Explicitly compare separated assets to the owner master direction. Record which master elements are represented by which canonical assets and which master-only elements are intentionally excluded from current product contract, especially the forbidden guide line.
12. Rerun Godot asset import/load probe and strengthen it if needed so its count/result is not tautological.
13. Run Godot import/parse/main-scene smoke checks.
14. Run `git diff --check`.
15. Write all execution evidence to:

`coordination/sessions/BCM-M04-R01/CODEX_LOG_V01.md`

16. Commit the M04 remediation as a bounded commit. Do not start M05 remediation inside the M04 log/commit scope except where the master orchestration prompt explicitly sequences the next task after this commit.

## Out of scope

- no cocktail sprite runtime retuning;
- no collider changes;
- no M06 environment composition changes;
- no M07 HUD composition;
- no source-art redesign;
- no guide line.

## Completion state

Return `AWAITING_AUDIT` for M04-R01. Do not self-approve.
