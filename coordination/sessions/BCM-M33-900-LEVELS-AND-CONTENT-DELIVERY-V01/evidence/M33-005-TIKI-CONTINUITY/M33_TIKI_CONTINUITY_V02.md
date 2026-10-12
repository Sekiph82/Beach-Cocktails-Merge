# BCM-M33 Tiki Continuity Follow-up V02

Status: `BUILDER_EVIDENCE_PENDING_INDEPENDENT_AUDIT`.

## Owner direction

The owner selected: preserve M32 Tiki local levels 1–12 unchanged and document their Sunny Cove introductory-template overlap as an explicit exception. This follow-up implements that direction in the M33 runtime package.

## Package correction

- The original M32 `data/campaign/levels/tiki_island.json` remains byte-identical at SHA-256 `AD4AE20C26D482082E9FFD170CC5E66DDE895403FE5E6D260A5BEEC8CFFBFF53`.
- M33 `tiki_island_full.json` now carries the M32 L1–L12 gameplay fields and local IDs unchanged. M33 adds global IDs 101–112, a `PRESERVED_M32_SEED` tier marker, and derived theoretical-shot/4T metadata.
- Five preserved records share introductory normal objective templates with Sunny Cove: Tiki L1→Sunny L2, L2→L5, L3→L4, L5→L10, and L6→L9. Those inherited records are the documented exception. Generated Tiki L13–L100 and the other 800 campaign records have no Sunny Cove L1–L10 normal-template collision.
- The package remains 900 campaign records and 1,000 total levels. Of the 900 records at global 101–1000, 12 are preserved M32 Tiki records and 888 are generated (Tiki 13–100 plus 800 records across the other islands). All 900 full challenge recipes remain unique.
- The packaged content version is `BCM-M33.2`; the deterministic generator version is `BCM-M33-1.0.1`, with batch seed `330033`.

## Verification

- Deterministic Python generation/static validation: `PASS_STATIC_CANDIDATE_CHECKS_PHYSICS_NOT_CERTIFIED`; 900 packaged records, 12 preserved, 888 generated, and 900 unique full recipes.
- Godot 4.7.2 isolated import/parse: `PASS`.
- `tests/m33_campaign_content_probe.gd`: `M33_CONTENT_RESULT=PASS`, including source-field equality for all twelve M32 Tiki records and explicit collision boundary.
- `tests/m33_campaign_navigation_probe.gd`: `M33_NAV_RESULT=PASS`; campaign completion/unlock chain reaches global 1000 and production World Map navigation exposes first/middle/final levels on all ten maps.
- `tests/m33_content_unavailable_probe.gd`: `M33_UNAVAILABLE_RESULT=PASS`.
- `tests/m33_tiki_compatibility_probe.gd`: `M33_TIKI_COMPAT_RESULT=PASS`; the real production physics trial now plays the preserved M32 Tiki L1/global 101 objective (L5×1), then verifies WIN, results, retry, and save/reload.
- Detailed collision map and owner-facing Tiki L1/L50/L100 samples are in `continuity_probe_report.json` and `tiki_owner_samples.json`.

## Supersession and limits

This V02 follow-up supersedes only the Tiki continuity/count claims and Tiki sample rows in the original M33-001/M33-004 evidence. Those original files and the published M33 master log remain unchanged as historical builder records. The prior implementation commit is superseded by the follow-up package commit recorded in `CODEX_LOG_M33_TIKI_CONTINUITY_V02.md`.

Only Tiki L1 received a bounded physical trial. The other 899 campaign levels remain unverified for physical reachability and human playability; static uniqueness and theoretical T are not solvability proofs. The four inherited M32 screening findings remain open.
