# BCM-M21-006-R03 — Independent Final Release Audit

Date: 2026-10-06

## VERDICT

**CHANGES_REQUIRED / EVIDENCE_PUBLICATION_CLOSURE_ONLY**

The R03 implementation itself is substantially sound:
- no production visual/gameplay files changed;
- stale M07 probes were reconciled without loosening their key bounds;
- project.godot was restored to canonical tracked form;
- the release manifest truthfully reports no export preset/distributable;
- progression/performance machine-readable reports are present;
- the builder log reports the full required regression matrix passing.

However, the locked R03 criteria explicitly required published release evidence for the mandatory runs. The repository does not contain most of those run logs.

## Audited range

R03 authority baseline:
`8801136b18a502d08e5f03b1995f470ad5b1ecad`

Implementation/evidence commit:
`c2ef88d772c8a5ae38a99f9c1b24e92eb09af2fe`

Builder handoff:
`7a00da5e5163e0e31e7e6a7ed621ce845413890d`

## Product/source scope

PASS.

The R03 diff contains no accepted production visual/gameplay implementation changes.

Changed runtime-adjacent files are limited to regression/performance probes:
- M07 HUD probes;
- M21 performance probe.

No Home, World Map, Island Map, gameplay, star/mastery, campaign data, economy draft, or production scene implementation changed.

## M07 reconciliation

PASS at source-review level.

The key R06 correction is principled:
- the historical BEST/SCORE expected rectangles were source-panel coordinates;
- the new probe scales those source rectangles by actual runtime panel dimensions;
- the 1.5 px center tolerance remains unchanged;
- the 4 px containment tolerance remains unchanged.

The M07 composition probe is updated to current accepted one-row L01–L12 progression and current launch-indicator authority rather than restoring retired APIs.

No obvious tolerance inflation or assertion deletion was found.

## project.godot reconciliation

PASS semantically, but evidence needs one correction.

Published evidence states the only drift was the GameFeelFlow autoload path:
- canonical repository-relative path;
- local Godot UID form resolving to the same script via sidecar.

Canonical tracked form was restored.

However, the builder log and the dedicated reconciliation note report two different SHA-256 values for canonical project.godot. That inconsistency must be corrected in the evidence package.

## M08 closure

**NOT INDEPENDENTLY AUDITABLE FROM PUBLISHED EVIDENCE.**

The builder log states two consecutive M08 runs:
- PASS marker;
- exit 0;
- no access violation;
- no SCRIPT ERROR / ERROR.

But the required R03 evidence folder on GitHub contains no M08 run logs.

Because `*.log` is globally ignored, local logs were not published.

The locked criteria required:
- M08 run 1;
- M08 run 2;
- exact process exits/no crash evidence.

Builder narrative alone is not sufficient for final independent release closure.

## R09/V05 navigation closure

**NOT FULLY PUBLISHED IN R03 EVIDENCE.**

The builder log reports two current R09/V05 runs passing, but those R03 run logs are not committed in the R03 evidence folder.

Historical R09 evidence exists elsewhere and was previously audited, but the R03 locked final matrix required fresh current closure evidence.

## Other missing mandatory run evidence

The repository does not publish the R03 command logs claimed in the builder log for:
- M07 final runs;
- M08 run 1/run 2;
- R08 Home frontier;
- R09 V05 run 1/run 2;
- R07 page focus;
- R07 node visual;
- full Sunny Cove background;
- M18 star/replay/cumulative reward/reward claim;
- M20 ApplicationShell;
- save/restart persistence;
- accepted gameplay regression set;
- asset validator;
- Godot import/parse;
- Godot boot;
- final git diff check;
- final ref/cleanliness proof.

The actual Git tree under:
`coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/evidence/`

contains only:
- `M21-002_PERFORMANCE_STABILITY_PROFILE.json`
- `M21-003_FULL_PROGRESSION.json`
- `m07_regression_closure.md`
- `project_godot_reconciliation.md`
- `release_manifest.json`

This is insufficient for the locked evidence gate.

## Progression evidence

PASS.

The machine-readable report records:
- fresh save;
- schema 2;
- levels 1–100 completed;
- 100 completed total;
- Tiki unlocked after L100;
- no debug progression bypass;
- no failed checks.

## Performance evidence

PASS as host-only evidence.

The report records:
- 12 map cycles;
- 8 gameplay cycles;
- 20 I/O cycles;
- 21 samples;
- zero orphan nodes;
- 60 frame samples;
- physical device explicitly marked unverified.

No physical-device claim is made.

## Release/export truthfulness

PASS with a metadata caveat.

The release manifest truthfully states:
- Godot 4.7.2;
- save schema 2;
- ApplicationShellScene main scene;
- 720×1280 viewport;
- no export_presets.cfg;
- no generated distributable;
- physical-device/native install/signing remain unverified.

However, the manifest should distinguish:
- frozen product baseline SHA;
- R03 implementation/evidence SHA;
- final builder handoff SHA.

Its current single `source_sha_tested` value points to the pre-R03 baseline, while R03 also changed test/probe files.

## Repository cleanliness

Builder reports tracked tree clean and local/origin/remote parity.

Two owner critique PNGs remain untracked and outside release inputs.

This is acceptable if documented, but final Git/ref proof must be published as evidence rather than existing only in the builder narrative.

## Defects

BLOCKER:
- none in product runtime established by this audit.

MAJOR:
- mandatory R03 release evidence is not published, preventing independent verification of the final gate.

MINOR:
- conflicting project.godot SHA-256 values across R03 evidence/log.
- release manifest needs explicit distinction between product baseline, implementation/evidence commit, and builder handoff.

## Required remediation

R04 is evidence-only.

Do NOT modify production runtime.

If the original local logs still exist:
- copy their exact contents into committed `.txt` evidence files (or force-add the exact logs);
- record SHA-256 of the source local log and committed copy to prove identity.

If any required local log no longer exists:
- rerun only that required command and capture stdout/stderr + exit code into a commit-eligible `.txt` file.

Correct:
- project.godot SHA evidence consistency;
- release manifest SHA fields;
- final synchronization/cleanliness evidence.

## FINAL VERDICT

**CHANGES_REQUIRED / EVIDENCE_PUBLICATION_CLOSURE_ONLY**

No product redesign or gameplay remediation is authorized.
