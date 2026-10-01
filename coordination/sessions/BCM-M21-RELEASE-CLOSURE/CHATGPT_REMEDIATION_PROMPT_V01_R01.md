# BCM-M21 V01-R01 — Evidence Closure Remediation

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `CHATGPT_AUDIT_V01.md`
5. `CHATGPT_AUDIT_CRITERIA_V01_R01.md`
6. original M21 V01 logs/reports/manifests.

## Purpose

Do **not** reimplement M21.

The M21 product package is technically sound. This R01 only closes two evidence gaps:
1. release manifest lacks explicit Git SHA + save schema;
2. several large production captures need connector-readable audit-review derivatives.

## Job 1 — supplemental release manifest

Create:
- `evidence/release/M21-005_RELEASE_MANIFEST_R01.json`
- `evidence/release/M21-005_RELEASE_MANIFEST_R01.md`

Use the exact locked fields in `CHATGPT_AUDIT_CRITERIA_V01_R01.md`.

The release-candidate source SHA is:
`8d8cf5453f484647b37dd59c374c5327855b9eda`

Campaign save schema is:
`2`

Verify both from repository truth and record the verification command/source.

Do not overwrite the V01 manifest.

## Job 2 — audit-review images

For all 14 original M21 mobile QA PNGs:
- preserve originals byte-for-byte;
- create same-dimension JPEG/WebP review copies under `evidence/mobile_qa/audit_review/`;
- no crop, resize, edit, retouch, overlay, or content change;
- compression/re-encoding only;
- each review file <= 400 KiB.

Create the required JSON/Markdown provenance manifest mapping original SHA-256 → review SHA-256.

Do not rerun or replace the production captures.

## Job 3 — freeze proof

Prove no changes from audited product handoff `8d8cf545...` under:
- `scripts/`
- `scenes/`
- `data/`
- `assets/`
- `project.godot`

Also prove:
- original 14 PNG hashes unchanged;
- historical V01 evidence unchanged;
- root `TASKS.md` unchanged;
- `git diff --check` PASS.

No full regression rerun is needed.

## Handoff

Populate:
`coordination/sessions/BCM-M21-RELEASE-CLOSURE/CODEX_LOG_V01_R01.md`

Commit/push all R01 evidence, verify clean local/origin/remote equality, and stop exactly at:

`AWAITING_M21_AUDIT_V01_R01`

Do not claim final v1 release-ready status. Owner-native acceptance remains pending.
