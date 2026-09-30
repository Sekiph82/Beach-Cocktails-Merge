# BCM-M19 V01 — Locked Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- root `TASKS.md`;
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`;
- M18 closure `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_AUDIT_V02_R01.md`.

## A — governance and preservation

- Work only on clean synchronized `main`.
- Execute Children 01→06 strictly in order.
- CODEX must not edit root `TASKS.md`.
- Preserve M18 behavior and evidence.
- Do not start M20.
- Do not create production Tiki level content, invent the final island name, retune Sunny Cove, alter accepted physics/rails/HUD/economy, or regenerate/modify canonical island artwork.
- Existing files under `assets/ui_assets/campaign/islands/<island_id>/` are immutable asset inputs.

## B — M19-001 multi-island loader and shared runtime

- LevelDatabase must support loading level definitions for more than one island into one database instance.
- Existing single-level-root API remains backward compatible.
- Duplicate island/level ids and cross-island mismatches remain rejected.
- FULL validation checks each loaded content-bearing island against its declared level_count while allowing canonical zero-level placeholders.
- A focused two-island fixture proves one LevelDatabase, one CampaignManager, one SaveManager authority, one reusable WorldMap/IslandMap pair, and one GameplaySessionBridge can navigate/run both islands without duplicated engine classes/scenes.
- No bespoke island manager, island map scene, gameplay fork, timer, or save authority is introduced.

## C — M19-002 Tiki placeholder / unlock boundary

Canonical Tiki Island:
- remains a zero-level placeholder in M19;
- is locked on fresh save and through Sunny Cove L99;
- unlocks only after Sunny Cove L100 completion;
- does not require perfect stars;
- does not expose playable Tiki levels while level_count is zero;
- uses the existing World Map / progression chain and no bypass flag.

Focused tests must prove fresh, L99, L100, reload, and duplicate/idempotent unlock behavior.

## D — M19-003 cocktail-level policy

- Sunny Cove target policy remains exactly L5-L8.
- No Sunny Cove normal/VIP objective may use L9.
- Tiki Island becomes the first island whose declarative target policy permits L9.
- M19 creates no actual Tiki level using L9 and does not invent the exact Tiki introduction level.
- A repository document defines later-island policy: each content-bearing island explicitly declares target eligibility; introduction of a new cocktail level occurs through island level data; global technical support remains bounded by the existing L1-L12 guard unless a later audited milestone changes it.
- The L9 reservation is data/document policy, not hard-coded island-name branching in gameplay.

## E — M19-004 canonical island sequence

Canonical order remains exactly:
1. Sunny Cove
2. Tiki Island
3. Azure Bay
4. Coconut Beach
5. Sunset Island
6. Party Beach
7. Frozen Paradise
8. Volcano Bay
9. Billionaire Island
10. final island slot

Requirements:
- order_index 1..10 unique and contiguous;
- next_island_id chain matches that order;
- final slot remains `final_island`;
- final public name remains explicitly TBD/placeholder; no new name is invented;
- a focused data-validation probe covers sequence integrity.

## F — M19-005 per-island theme hooks

Use the existing approved asset roots:
`assets/ui_assets/campaign/islands/<island_id>/`

For all ten canonical islands, define a data-driven theme/asset hook using existing files only. At minimum expose paths for:
- gameplay background;
- gameplay table;
- gameplay table shadow;
- table edge overlay;
- launch zone;
- island map background.

The hook must:
- resolve from island data, not island-name conditionals;
- validate referenced paths;
- flow through the existing LevelDatabase / GameplaySessionBridge configuration boundary;
- preserve current gameplay geometry and physics authority;
- provide backward-compatible fallback when optional theme metadata is absent.

M19 does not require subjective visual acceptance or asset regeneration. Any live renderer consumption added in M19 must be texture/theme assignment only and must not change rail coordinates, table-boundary math, drink physics, HUD geometry, timer, objectives, or scoring.

## G — M19-006 data-first scalability regression

A focused scalability probe must demonstrate that a new fixture island can be added primarily through:
- island definition;
- level definition;
- existing map/theme asset references;

and can then use the same database, campaign, map, session, gameplay and save authorities without duplicated code/scenes.

The probe must fail if implementation depends on a hard-coded island-specific runtime branch.

## H — regression / handoff

After all six children pass, run:
- M19 focused probes;
- M10 campaign architecture;
- M11 save migration/progression;
- M12 World Map;
- M13 Island Map;
- M14 GameplaySessionBridge;
- M15 VIP/economy;
- M16 Sunny Cove content;
- M18 focused/integration probes;
- protected M01/M02/M03/M07/M08/M09 boundaries;
- `git diff --check`;
- root `TASKS.md` freeze proof.

Master handoff must end exactly:

`AWAITING_M19_AUDIT_V01`

Any failed, out-of-order, speculative, asset-mutating, or unverified material criterion is `CHANGES_REQUIRED`.
