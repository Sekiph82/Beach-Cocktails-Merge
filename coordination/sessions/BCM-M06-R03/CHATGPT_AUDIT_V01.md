# BCM-M06-R03 — ChatGPT Strict Audit V01

Verdict: **CHANGES_REQUIRED**

## Scope audited

- `coordination/sessions/BCM-M06-R03/CODEX_LOG_V01.md`
- `docs/evidence/m06/render_space_landmarks.json`
- current M06 geometry/source state and R03 master requirements
- historical locked M06 criteria

## What improved

M06-R03 correctly adds a screenshot-space evidence layer instead of relying only on source-space transforms. It retains three portrait cases and compares far/middle/near rail coordinates against a separate JSON dataset. No gameplay or canonical PNG changes were introduced.

## Blocking findings

### F-M06-R03-001 — Screenshot-space dataset does not convincingly break landmark circularity — BLOCKER

`render_space_landmarks.json` claims manual pixel inspection, but its values are effectively rounded forms of the existing production/source-transform geometry:

- canonical production far rail about `(176.667,543.333)` becomes `(176,544)`;
- middle `(98.333,621.667)` becomes `(99,621)`;
- near `(20,700)` remains `(20,700)`;
- danger `916.667` becomes `917`;
- launch `953.333` becomes `953`;

The same pattern is repeated for the taller and shorter/wider cases. The repository contains no independent measurement provenance showing that these points were actually selected from final screenshot pixels without reference to the production values. Merely storing rounded copies in another JSON file is insufficient to prove independence.

The resulting sub-pixel errors therefore do not constitute strong independent evidence; they are exactly what one would expect when rounded production coordinates are compared back against production coordinates.

### F-M06-R03-002 — Material visual acceptance remains independently unverified — BLOCKER

The locked M06 contract requires ChatGPT to independently inspect clean/overlay screenshot pixels and determine whether the owner-rejected composition has actually been resolved. The GitHub connector exposes current PNG paths, hashes, and metadata but not the binary pixels in a form available for independent inspection in this audit.

Builder claims that the captures were manually inspected cannot substitute for independent audit under the project policy.

## Passing areas

- no M07 HUD implementation leaked into M06-R03;
- no guide line was introduced;
- canonical PNGs were not modified;
- M01-M05 regression markers are present and passing;
- danger threshold remains lower at source Y=1100 and launch at Y=1144;
- responsive cases remain explicitly represented;
- current production geometry was not needlessly reverted toward the old prototype composition.

## Final verdict

**CHANGES_REQUIRED**.

The production geometry may be directionally correct, but the R03 evidence still does not satisfy the strict independence requirement. A future remediation must derive/retain genuinely independently selected screenshot landmark points with auditable provenance, rather than values that numerically mirror the production transform, and the final pixels must be independently inspectable before `AUDITED_PASS`.
