# CODEX Execution Log — BCM-M21 V01-R01

Status: `COMPLETE_BUILDER_EVIDENCE_CLOSURE_AWAITING_AUDIT`

## Authority and synchronized start

- Remediation prompt: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_REMEDIATION_PROMPT_V01_R01.md`.
- Locked criteria: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01_R01.md`.
- Independent audit: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_AUDIT_V01.md`.
- Canonical branch: `main`.
- Canonical remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Sync-first preflight fetched `origin/main`, observed `0 5` behind-only divergence, and fast-forwarded from `8d8cf5453f484647b37dd59c374c5327855b9eda` to audit-authorized `6ad1595`.
- Start worktree was clean after synchronization.
- Root `TASKS.md` start SHA-256: `9cd4a179c929da53a1624d88450181f5439b43194f0ade4f26801166a11db0ae`.

R01 was evidence-only. No product code, `project.godot`, campaign data, canonical assets, original M21 V01 evidence, tests, or tracker was edited.

## Supplemental release manifest

Created without overwriting V01:

- `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/release/M21-005_RELEASE_MANIFEST_R01.json`
- `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/release/M21-005_RELEASE_MANIFEST_R01.md`

Recorded and verified:

- Release-candidate source SHA: `8d8cf5453f484647b37dd59c374c5327855b9eda`.
- SHA command: `git rev-parse 8d8cf5453f484647b37dd59c374c5327855b9eda; git cat-file -t 8d8cf5453f484647b37dd59c374c5327855b9eda` → exact SHA, object type `commit`.
- Godot: `4.7.2.stable.official.ed1daf0bf`.
- Campaign save schema: `2`, verified by `rg -n "SCHEMA_VERSION|schema_version" scripts/campaign/save_manager.gd` → `scripts/campaign/save_manager.gd:7:const SCHEMA_VERSION := 2`.
- Production main scene: `res://scenes/campaign/ApplicationShellScene.tscn`.
- Canonical viewport: `720x1280 portrait`.
- Export preset/toolchain status, generated distributable list, empty artifact hash list, reproducible smoke/import/export commands, known limitations, and owner-native gate are explicit.

## Audit-readable mobile review copies

Created exactly 14 JPEG transport derivatives under:

`coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/mobile_qa/audit_review/`

Provenance files:

- `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/mobile_qa/M21-001_AUDIT_REVIEW_MANIFEST_R01.json`
- `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/mobile_qa/M21-001_AUDIT_REVIEW_MANIFEST_R01.md`

Verification result:

```text
PAIR_COUNT=14
BAD_COUNT=0
```

Every pair records original SHA-256, review SHA-256, source/review dimensions, byte size, JPEG encoding, `derived_from_original=true`, `crop=false`, and `resize=false`. All review copies preserve exact dimensions and are below 409600 bytes. Representative review copies were visually inspected locally and remained readable.

The original PNGs were not rerun or replaced. Their authoritative paths remain `evidence/mobile_qa/*.png`.

## Freeze proof

- Product/source freeze command: `git diff --quiet 8d8cf5453f484647b37dd59c374c5327855b9eda -- scripts scenes data assets project.godot` → exit `0`.
- Test/regression freeze command: `git diff --quiet 8d8cf5453f484647b37dd59c374c5327855b9eda -- tests` → exit `0`.
- Historical V01 evidence explicit-file freeze command → exit `0`.
- Original 14 PNG capture freeze command → exit `0`.
- `git diff --check` → PASS.
- No test bypass or regression artifact was modified.
- R01 did not rerun the full regression matrix.

## Publication and equality

- Evidence commit pushed: `dd0447bc33ffc45a2926f81864fc7c28c0c5c44d`.
- Evidence equality immediately after push:
  - local `HEAD`: `dd0447bc33ffc45a2926f81864fc7c28c0c5c44d`
  - `origin/main`: `dd0447bc33ffc45a2926f81864fc7c28c0c5c44d`
  - remote `main`: `dd0447bc33ffc45a2926f81864fc7c28c0c5c44d`
- R01 log publication commit: to be recorded by the final publication equality below.
- Owner-native mobile/release acceptance remains pending and is outside Codex authority.

## Final handoff

R01 closes only the audited evidence gaps. It does not claim final v1 release-ready acceptance.

AWAITING_M21_AUDIT_V01_R01
