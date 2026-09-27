# BCM-M15 VIP, Boosters, Rewards & Economy — Audit Criteria V01

Status: **LOCKED BEFORE EXECUTION**  
Auditor: ChatGPT  
Builder: Codex  
Branch: `main`

## Milestone objective

Implement the bounded campaign economy layer:
- compact VIP gameplay state;
- optional VIP reward dispatch;
- booster inventory;
- +Time booster contract;
- milestone rewards;
- coin/reward ledger hooks;
- persistence and duplicate prevention.

Preserve M14 campaign/session behavior and accepted core gameplay.

## Locked authorities

- `TASKS.md`
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- accepted M10-M14 audits
- current `scripts/campaign/game_economy.gd`
- `scripts/campaign/save_manager.gd`
- `scripts/campaign/campaign_manager.gd`
- `scripts/campaign/gameplay_session_bridge.gd`
- `scripts/campaign/campaign_navigation_controller.gd`
- accepted R11 gameplay/table physics
- accepted To-Go/HUD behavior

## Scope boundaries

Allowed:
- evolve GameEconomy into the canonical booster/coin/reward ledger;
- persist economy state through SaveManager/campaign app flow;
- deterministic reward IDs and duplicate prevention;
- VIP reward dispatch;
- compact VIP badge/state integrated into existing To-Go UI;
- +Time booster consumption during timed campaign sessions;
- milestone reward claim integration;
- coin reward hooks;
- deterministic M15 fixtures/tests;
- minimal session/navigation/save wiring needed for real persistence.

Not allowed:
- purchases;
- real-money shop;
- rewarded-ad continuation;
- ad SDKs;
- online/backend economy;
- paywall/progression gates;
- customer-character scenes;
- new animation-heavy VIP scenes;
- M16 canonical Sunny Cove L1-100 content;
- physics/merge/table/collider retuning;
- accepted visual asset regeneration.

## Gate A — Canonical economy authority

PASS requires one GameEconomy authority per campaign runtime.

It must own:
- non-negative coin balance;
- non-negative booster counts;
- deterministic granted-reward ledger;
- reward grant idempotency;
- booster consumption.

No duplicate economy authority in gameplay/map scenes.

Economy APIs must fail closed on:
- empty/invalid reward IDs;
- negative rewards;
- unknown/invalid booster quantities;
- insufficient booster inventory.

## Gate B — Save/persistence integration

Economy state must persist across a real save/reload:
- coins;
- booster inventory;
- reward grant IDs/ledger needed for duplicate prevention.

Existing M11 progression data must be preserved.

Older valid saves that predate M15 economy-ledger metadata must load safely with empty/default ledger state and no loss of progression/stars/best score.

Production campaign boot must initialize campaign/economy state from SaveManager rather than resetting economy inventory on every app launch.

Persistence writes must continue to use M11 atomic/backup behavior.

## Gate C — VIP presentation

When a level has enabled VIP data, gameplay must expose a compact VIP badge/state in or adjacent to the existing To-Go Orders UI.

It must communicate at minimum:
- VIP active;
- target cocktail level/quantity;
- pending/completed state.

Requirements:
- no customer character;
- no new animated scene;
- normal To-Go objective remains primary and readable;
- accepted HUD/table geometry remains unchanged;
- VIP absent/disabled => no misleading VIP state.

Visible M15 UI requires runtime screenshot/evidence and final owner visual acceptance before unconditional M15 closure.

## Gate D — VIP reward dispatch

VIP completion remains optional and never gates normal WIN.

Reward dispatch:
- occurs only when the level result is a normal WIN and VIP is complete;
- uses the configured VIP reward data;
- grants at most once per deterministic VIP reward ID;
- replay without new eligibility cannot duplicate reward;
- LOSE/timeout never grants VIP reward;
- VIP incomplete normal WIN never grants VIP reward;
- no M15 reward affects whether the level is considered complete.

Support the documented reward shape:
`{"type":"booster","id":"...","quantity":N}`
and bounded coin reward form where used by fixtures/data.

## Gate E — Booster inventory

PASS requires:
- read current count;
- grant positive quantities;
- consume positive quantities;
- reject insufficient inventory without partial mutation;
- persistence across save/reload;
- deterministic state export/import.

No purchase/ads acquisition path.

## Gate F — +Time booster

Implement a campaign-session +Time contract.

PASS requires:
- only valid during a non-terminal timed campaign session;
- consumes booster inventory atomically;
- adds an explicit positive amount to **remaining session time only**;
- does not mutate immutable LevelDatabase definition;
- does not mutate configured base `time_limit_sec`;
- insufficient inventory => no time added;
- invalid/nonpositive extension => no booster consumed;
- terminal/idle session => no booster consumed/time change;
- repeated uses follow inventory count exactly.

Do not invent a permanent production balance value. The extension amount may be data/config/API-driven and deterministic in tests.

## Gate G — Milestone rewards

Milestone eligibility remains CampaignManager authority.

Reward claim must:
- require the configured milestone to be reached;
- claim once;
- dispatch configured reward once;
- prevent duplicate reward across repeated claim calls and save/reload;
- preserve claimed_milestones state;
- fail without partial reward when milestone is not eligible.

Use deterministic milestone reward IDs.

Do not make milestone claims a progression gate.

## Gate H — Coins / reward ledger

Coin rewards:
- only add non-negative configured amounts;
- are ledgered/idempotent through deterministic reward IDs;
- persist across save/reload;
- cannot become negative through reward APIs.

M15 does not implement spending/shop pricing unless minimally required by an already-locked booster consumption contract. Campaign completion remains independent of coins.

## Gate I — Real runtime integration

Production campaign shell must carry one coherent:
- CampaignManager;
- SaveManager-backed state;
- GameEconomy;
- GameplaySessionBridge.

VIP reward and +Time usage must operate on that same economy authority.

Returning Retry/Next/IslandMap must not create a fresh economy object that loses inventory/ledger state.

## Gate J — Result/economy separation

M14 terminal result remains gameplay truth.

Economy dispatch is a post-result bounded concern:
- normal WIN/LOSE semantics unchanged;
- stars unchanged from M14;
- progression unlock unchanged from M14;
- VIP reward failure must not rewrite WIN into LOSE;
- economy errors must be explicit and must not duplicate grants.

## Gate K — Focused M15 probe

Create:
`tests/m15_vip_boosters_economy_probe.gd`

It must prove at minimum:
- GameEconomy initial state;
- valid/invalid reward grants;
- deterministic duplicate prevention;
- booster grant/consume/insufficient cases;
- real save/reload persistence for coins/boosters/reward ledger;
- older pre-M15 valid save compatibility;
- VIP absent/disabled UI/state;
- VIP enabled pending/completed state;
- VIP incomplete WIN gives no VIP reward;
- VIP complete WIN grants exactly once;
- LOSE gives no VIP reward;
- VIP replay cannot duplicate;
- +Time adds exact requested amount without altering base definition;
- invalid/terminal/insufficient +Time does not consume;
- milestone ineligible claim no grant;
- milestone eligible claim exactly once;
- milestone duplicate after reload no grant;
- real campaign runtime reuses same economy across Retry/Next/IslandMap;
- M14 win/lose/stars/progression semantics remain unchanged.

Run twice after normal Godot 4.7 import/bootstrap with no intervening source changes. Both PASS exit 0.

## Gate L — visual evidence

Because M15 changes visible VIP UI, builder must provide deterministic runtime screenshot evidence showing:
1. VIP enabled/pending;
2. VIP completed;
3. no VIP state for a non-VIP level.

No asset regeneration is required.

Final owner visual acceptance is required after technical audit.

## Gate M — regression preservation

Required PASS:
- M10;
- M11;
- M12;
- M13;
- M14;
- M15 twice;
- M02;
- M03;
- M08;
- relevant save/progression probes.

Do not rewrite superseded historical R10 probes to fake green.
Do not alter accepted R11 physics constants.

## Gate N — governance

- Codex must not edit root `TASKS.md`;
- no M16 canonical level content;
- no purchase/ad/backend integration;
- no accepted asset regeneration;
- no physics/HUD geometry retuning;
- builder log committed/pushed;
- clean worktree;
- local HEAD / origin/main / remote main synchronized.

## Required builder log

Write:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V01.md`

Include:
- start HEAD;
- implementation SHA;
- final main HEAD;
- exact changed files;
- economy authority architecture;
- persisted state shape and backward compatibility;
- VIP reward IDs and dispatch rules;
- milestone reward IDs and dispatch rules;
- +Time contract;
- screenshot evidence paths;
- M15 run1/run2;
- M10-M14/M02/M03/M08 regression results;
- confirmation TASKS untouched;
- sync/clean proof.

## Acceptance

Any technical material FAIL/UNVERIFIED = `CHANGES_REQUIRED`.

If technical gates pass but owner has not yet accepted the new visible VIP UI, verdict is:
`TECHNICAL_AUDIT_PASS / OWNER_VISUAL_ACCEPTANCE_REQUIRED`.
