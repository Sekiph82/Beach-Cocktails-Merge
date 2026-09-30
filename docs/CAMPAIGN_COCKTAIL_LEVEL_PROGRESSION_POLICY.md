# Campaign Cocktail-Level Progression Policy

This is the M19 data contract for introducing higher cocktail targets while
keeping the existing campaign engine and gameplay scene shared.

- Every content-bearing island declares `target_policy` in
  `data/campaign/islands.json`.
- Level and VIP objectives are validated against the target policy of their
  own island; gameplay code does not branch on island names.
- Sunny Cove remains limited to L5-L8.
- Tiki Island is the first planned island whose policy permits L9. M19 keeps
  Tiki at `level_count: 0`, so it defines no L9 level and does not choose an
  exact introduction level.
- Later islands may declare higher targets in their island data as content is
  authored. The current technical guard remains L1-L12 in `LevelDatabase`.
- Introducing a new cocktail target is therefore a data/content milestone:
  add the island-level definition, validate it against that island's policy,
  and reuse the existing LevelDatabase, CampaignManager, SaveManager,
  navigation, session bridge, and gameplay authorities.

This policy does not change the accepted Sunny Cove content, timer, objective,
physics, table rails, HUD, scoring, VIP, or economy contracts.
