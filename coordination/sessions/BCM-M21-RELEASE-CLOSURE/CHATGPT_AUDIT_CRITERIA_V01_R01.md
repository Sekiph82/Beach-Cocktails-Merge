# BCM-M21 V01-R01 — Locked Evidence-Closure Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `CHATGPT_AUDIT_V01.md`;
- original M21 V01 prompts/criteria;
- audited builder handoff `8d8cf5453f484647b37dd59c374c5327855b9eda`.

## A — remediation type

This is **evidence-only**.

Frozen:
- all product/source files;
- `project.godot`;
- all campaign data;
- all canonical assets;
- all original M21 V01 reports/logs/manifests;
- all 14 original M21 mobile QA PNG captures;
- root `TASKS.md`.

No M22/future feature work.

If any product defect is discovered, stop and report it. Do not fix product code inside R01.

## B — supplemental release manifest

Create new files without overwriting the historical V01 manifest:

- `evidence/release/M21-005_RELEASE_MANIFEST_R01.json`
- `evidence/release/M21-005_RELEASE_MANIFEST_R01.md`

They must explicitly contain at minimum:

- `release_candidate_source_sha = 8d8cf5453f484647b37dd59c374c5327855b9eda`;
- Godot version;
- campaign save schema version `2`, derived/verified from current SaveManager/progression evidence;
- production main scene;
- canonical viewport;
- export preset status;
- available/unavailable toolchain status;
- generated distributable list;
- SHA-256 for every generated distributable, or an explicit empty/null list when none exists;
- known limitations;
- owner-native gate status;
- exact reproducible commands for persistence smoke, import/editor smoke, and attempted export;
- explicit statement that R01 changes evidence only and does not alter the release-candidate product bytes.

Do not fabricate an export artifact or signed build.

## C — audit-readable visual review copies

Preserve every original file under:

`evidence/mobile_qa/*.png`

byte-for-byte.

Create:

`evidence/mobile_qa/audit_review/`

with one review copy for each of the 14 original M21 captures.

Requirements:
- derived only from the corresponding committed original PNG;
- no crop;
- no layout edit;
- no retouching;
- no content addition/removal;
- preserve original pixel dimensions: canonical images remain 720×1280; tall images remain 720×1440;
- image re-encoding/compression only;
- use JPEG or WebP as needed so each review file is <= 400 KiB and connector-readable;
- text/control layout must remain visually inspectable.

Create provenance files:
- `M21-001_AUDIT_REVIEW_MANIFEST_R01.json`
- `M21-001_AUDIT_REVIEW_MANIFEST_R01.md`

For each of 14 pairs record:
- original path;
- original SHA-256;
- original width/height;
- review path;
- review SHA-256;
- review width/height;
- review byte size;
- encoding;
- explicit `derived_from_original=true`;
- explicit `crop=false`, `resize=false`.

The review copies are audit transport derivatives only. The original PNGs remain the authoritative production captures.

## D — integrity proof

R01 must prove:
- no file under `scripts/`, `scenes/`, `data/`, `assets/`, or `project.godot` changed from builder handoff `8d8cf545...`;
- original M21 mobile PNG blob/SHA-256 set is unchanged;
- original V01 reports/logs/manifests are unchanged;
- root `TASKS.md` unchanged by CODEX;
- no test bypass or regression artifact is modified;
- `git diff --check` passes.

No full gameplay regression rerun is required because product bytes are frozen.

## E — handoff

Create/populate:
`CODEX_LOG_V01_R01.md`

Record:
- synchronized start;
- exact files created;
- original/review image provenance;
- supplemental manifest fields and verification commands;
- frozen-product diff proof;
- frozen-original-capture proof;
- root tracker freeze proof;
- final local/origin/remote equality.

Successful marker:

`AWAITING_M21_AUDIT_V01_R01`

Any product mutation, original-evidence rewrite, missing manifest field, missing review copy, unreadable review image, provenance mismatch, or equality failure is `CHANGES_REQUIRED`.

Owner-native acceptance remains outside CODEX authority and remains pending after technical R01 completion.
