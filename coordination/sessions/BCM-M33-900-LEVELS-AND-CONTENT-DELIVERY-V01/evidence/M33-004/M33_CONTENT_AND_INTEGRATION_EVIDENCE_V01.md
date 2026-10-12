# BCM-M33 content and integration evidence V01

Status: `BUILDER_CANDIDATE_PENDING_INDEPENDENT_AUDIT`; automated coverage is not human play approval.

## Packaged content

- Nine new island files cover global levels 101–1000, with stable local IDs 1–100.
- Complete production database: ten islands × 100 levels = 1,000 records.
- Full challenge recipes are unique across the entire 900-record batch.
- No generated normal recipe matches Sunny Cove introductory levels 1–10.
- Sunny Cove SHA-256: `573B5CA14CA75BEC04F40A5B7D00AA441534A266569B200E36E78B28D3591128`.
- Generator: `BCM-M33-1.0.0`; batch seed: `330033`; content version: `BCM-M33.1`.

## Diversity, pacing, and bounded challenge estimates

| Island | Unique normal templates | Repeated-record rate | Max same-template count | VIP levels | Median theoretical T |
|---|---:|---:|---:|---:|---:|
| tiki_island | 76 | 24% | 3 | 31 | 104 |
| azure_bay | 84 | 16% | 2 | 38 | 208 |
| coconut_beach | 82 | 18% | 3 | 53 | 320 |
| sunset_island | 94 | 6% | 3 | 44 | 464 |
| party_beach | 93 | 7% | 2 | 51 | 528 |
| frozen_paradise | 92 | 8% | 3 | 52 | 608 |
| volcano_bay | 92 | 8% | 2 | 56 | 640 |
| billionaire_island | 91 | 9% | 3 | 47 | 768 |
| final_island | 97 | 3% | 2 | 66 | 816 |

Quantity is limited to 1–2 per objective; all generated records are untimed and use production `4T` move budgets. T increases across the island medians from 104 on Tiki to 816 on Final. These are objective-cost estimates, not solver or playability proofs.

## Runtime and compatibility checks

- Godot 4.7.2 strict `FULL` database load passed with all island themes and R04 geometry references.
- Production map navigation passed for all ten islands; each map exposed selectable levels 1, 50, and 100. In-memory progression reached Final Island local 100 / global 1000.
- Broken manifest safely prevented campaign save manager creation and disabled Play and World Map, with visible `CONTENT UNAVAILABLE` status.
- Schema-two campaign save roundtrip, v1-to-current migration, recovery, unsupported-future-save non-destructive behavior, and separate settings/onboarding storage probes passed.
- Bounded production physics trial passed on Tiki L1 (global 101), seed `32002001`, `MERGE_AWARE_V01`, completing its normal objectives through real GameManager, Drink physics, and merges.
- Default application boot passed in the isolated sandbox. Existing Android/iOS workflows were not changed or invoked.

## Unverified / limits

- Human playtesting and owner balance/visual approval remain pending for all 900 generated records.
- Physics trial coverage is one level only. The other 899 generated levels remain `UNVERIFIED` for physics reachability; static legality, move-budget arithmetic, uniqueness, and production loading do not certify solvability.
- M32’s inherited M17 screening report still contains four unresolved failures: V03A exact-signature reuse and the L4/L60/L100 VIP-second target fixtures. M33 does not claim those are resolved.
- No representative mobile screenshots were captured because M33 adds no art and the user/device visual-acceptance gate remains owner-owned.
- Existing M32 source files and probes were left unchanged. The M33 compatibility probe is a separate copy with the full Tiki count expectation.
