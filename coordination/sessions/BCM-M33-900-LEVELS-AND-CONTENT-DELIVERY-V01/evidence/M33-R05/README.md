# BCM-M33 R05 Builder Evidence

Status: `AWAITING_GPT_M33_R05_INDEPENDENT_AUDIT_AND_OWNER_TABLETOP_REVIEW`

This package records builder evidence for the owner-approved controlled-repeat and initial-tabletop variation. It does not claim independent acceptance, human playability, or mobile-device QA.

## Findings

- **R05-001 — Runtime and schema:** optional per-level `initial_tabletop_drinks_version: 1` and `initial_tabletop_drinks: []` records are backward-compatible; legacy records without either field load as an empty inventory. Version 1 requires an array of real cocktail levels and normalized positions. Validation checks goal compatibility (direct normal target or one level below a normal target), bounds, quantity, collision spacing, and VIP exclusion. Runtime placement uses production `Drink` nodes and the accepted R04 playable-surface projection.
- **R05-002 — Content:** regenerated only 888 generated records. The 100 Sunny Cove records and original M32 Tiki seed file remained unchanged; Tiki L1-L12 gameplay payload is preserved in the packaged file. Ordinary objectives use L6-L8 and normal T is at most 56. Nine local-level-100 L9 capstones remain above T56. The existing 4T move limit, star formula, optional VIP, rewards, level identities, campaign size, and no-timer policy remain in place.
- **R05-003 — Starting inventory:** every generated record has explicit schema version 1; designated empty openings are empty. Populated entries match a normal target or provide one L3-L8 merge step toward a normal target. Inventory cannot satisfy all normal order quantity, cannot equal the optional VIP level, and starts in the central tabletop safe area above the danger/launch lane. Retry respawns the same placement; pause/resume retains the same in-session nodes.
- **R05-004 — Verification:** deterministic generator/static validator, Godot full-content probe, production-scene tabletop probe, navigation/save probe, and focused session bridge regression were run in the isolated Codex sandbox. A bounded production-physics merge of a real moving L6 with preplaced L6 created L7 and the To-Go flow delivered that result. A directly compatible preplaced L6 was delivered with zero moves used and without terminal completion.
- **R05-005 — Owner review:** visual review and independent audit are pending. No approval is claimed from builder screenshots or automated probes.

## Controlled-repeat counts

See `controlled_repetition_and_hash_report.json` for exact nine-island before/after difficulty and repetition counts, adjacent and nearby-window counts, and SHA-256 values. It compares the synchronized R04 package at base commit `c62be113dd93adf5fe7c9e96627036cf74411286` with the R05 generator output. `nine_island_before_after_difficulty_and_repetition.csv` provides the same island metrics in tabular form.

For the 888 generated records, R05 records 718 within-island repeated normal objectives and 603 within-island repeated full recipes. Cross-island duplicate occurrences are 145 for normal objectives and 209 for full recipes. There are 71 adjacent identical full recipes, while adjacent identical recipe-plus-tabletop layouts are 0. Across the previous 5/10 records there are 310/569 repeated full-recipe pairs and 0/25 repeated recipe-plus-layout pairs.

`sample_36_recipes_and_tabletop_layouts.csv` contains four generated samples per island (the entry opening, mid/late samples, and capstone) with objectives, normal T, VIP, unchanged 4T budget, schema version, and initial drink positions.

## Godot captures

`screenshots/` contains 38 active PNGs captured directly from the production gameplay scene running in Godot 4.7.2 on the Intel Iris Xe OpenGL compatibility renderer. Each of the nine generated islands has an empty opening and a populated opening at 390×844 and 432×960. Each size also has a two-drink Tiki contrast. The capture script saved the Godot viewport image directly; the PNGs were not composited or resized after capture. See `capture_manifest.json` for the active inventory and file hashes.

Nine PNGs from an earlier capture pass are also present and individually listed under `superseded_artifacts` in the manifest. Their positions predate the final safe-area correction, so they are excluded from the active review set. The app safety review rejected their removal; the files are retained and marked so they are not confused with the final captures.

Suggested owner review:

1. Compare each island's `*_empty.png` and `*_populated.png` pair at both resolutions. Confirm the drink is visible on the playable tabletop and clear of HUD, shelf, danger line, and launch lane.
2. Review `tiki_island_L027_contrast_two_drinks.png` at both resolutions for spacing and readability with two starters.
3. Review the corresponding row in `sample_36_recipes_and_tabletop_layouts.csv` and decide whether each shown starting stock is a suitable match or merge lead for its listed normal orders.
4. Return any per-island or per-level visual/gameplay corrections. Builder screenshots are review material, not owner acceptance.

## Hashes

Authoritative generated-file and manifest hashes are recorded in `controlled_repetition_and_hash_report.json`. Protected source checks remain:

- Sunny Cove level source: `573B5CA14CA75BEC04F40A5B7D00AA441534A266569B200E36E78B28D3591128`.
- Original M32 Tiki seed: `AD4AE20C26D482082E9FFD170CC5E66DDE895403FE5E6D260A5BEEC8CFFBFF53`.
