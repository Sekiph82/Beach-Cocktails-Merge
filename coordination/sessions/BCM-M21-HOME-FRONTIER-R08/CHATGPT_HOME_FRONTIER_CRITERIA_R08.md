# BCM-M21-001-R08 — Locked Criteria: Home Frontier Authority Closure

Status: **LOCKED BEFORE EXECUTION**

Authority:
`CHATGPT_R07_FULL_BACKGROUND_AUDIT.md`

## Scope

Fix only the Home/frontier inconsistency found by independent audit.

Freeze:
- all Home art/layout geometry;
- Sunny Cove full 720×1280 Island Map background;
- all R07 level landmark positions;
- Sunny Cove title position;
- LV labels;
- star visuals;
- threshold data/generator;
- star semantics;
- World Map;
- gameplay;
- economy draft.

Root `TASKS.md` remains read-only to Codex.

## Required behavior

For a campaign with frontier level F:

1. Home top LEVEL field displays F.
2. Home PLAY plaque displays exactly `LEVEL F`.
3. Pressing Home PLAY launches level F.
4. `selected_level_id` from an old replay must not change those Home semantics.
5. Clicking an old level node from Island Map may still launch that old replay directly.
6. After that replay returns to Home, Home top LEVEL/plaque/PLAY all resolve to frontier F.
7. Completing frontier F advances to F+1 and all three Home behaviors immediately use F+1.
8. Replay cannot lower frontier.

## Canonical resolver

Use `CampaignManager.get_frontier_level_id()` as the canonical Home frontier resolver.

Do not introduce a second progression counter.

## Tests

Update/add a focused production-path probe that explicitly proves:

- configure frontier 11;
- select old level 4;
- Home top LEVEL == `11`;
- Home plaque == `LEVEL 11`;
- real Home PLAY pointer input launches active gameplay level 11, not 4;
- Island Map direct click/select of level 4 still launches replay level 4;
- return Home;
- Home remains LEVEL 11 and PLAY launches 11;
- complete level 11;
- frontier becomes 12;
- Home top LEVEL == 12;
- plaque == `LEVEL 12`;
- Home PLAY launches 12.

Also rerun:
- R07 Home label probe;
- R07 page-focus probe;
- R07 node visual probe;
- M18 star contract/replay persistence;
- M20 ApplicationShell;
- M21 V05 World Map input;
- full-background follow-up probe;
- asset validator;
- Godot import/parse/boot;
- `git diff --check`.

## Publication

Create:
`docs/codex-logs/CODEX_LOG_M21_HOME_FRONTIER_R08.md`

Create evidence under:
`coordination/sessions/BCM-M21-HOME-FRONTIER-R08/evidence/`

Do not edit root `TASKS.md`.

Final marker exactly:

`AWAITING_GPT_M21_HOME_FRONTIER_AUDIT_R08`
