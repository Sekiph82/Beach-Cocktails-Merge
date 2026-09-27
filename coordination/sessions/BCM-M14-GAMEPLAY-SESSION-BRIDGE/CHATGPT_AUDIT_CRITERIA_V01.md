# BCM-M14 Gameplay Session Bridge — Audit Criteria V01

Status: **LOCKED BEFORE EXECUTION**  
Auditor: ChatGPT  
Builder: Codex  
Branch: `main`

## Milestone objective

Implement the level-launch and timed gameplay-session bridge defined by M14 while preserving the accepted core merge/table physics and keeping M15 economy/VIP-reward extensions and M16 canonical Sunny Cove L1-100 content out of scope.

## Locked authorities

- `TASKS.md`
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- accepted M10 campaign/data architecture
- accepted M11 save/progression architecture
- accepted M12 World Map
- accepted M13 Island Map + CampaignNavigationScene
- accepted R11 gameplay physics/table-edge behavior
- accepted HUD/To-Go behavior
- current `scripts/campaign/gameplay_session_bridge.gd`
- existing gameplay scene `scenes/main.tscn` and `scripts/game_manager.gd`

## Scope boundaries

Allowed:
- evolve GameplaySessionBridge into the production campaign/gameplay boundary;
- wire M13 `level_selected(island_id, level_id)` into session launch;
- launch/reuse the existing gameplay implementation with immutable selected level configuration;
- campaign session timer;
- normal To-Go objective configuration;
- optional VIP objective state sufficient to determine optional completion;
- win/lose result model;
- Retry / Next Level / Island Map return boundaries;
- deterministic tests/fixtures;
- minimal GameManager hooks required to receive campaign session config and report order completion/result state.

Not allowed:
- retuning launch, merge, collider, R11 rail, table-edge or drink physics;
- redesigning accepted HUD/assets;
- M15 booster inventory, +Time purchase/reward flow, milestone economy, ad flow, coin economy;
- M16 canonical Sunny Cove L1-100 content authoring;
- creating separate gameplay scenes per level;
- changing difficulty by board size/color-count proxies.

## Gate A — Real level launch boundary

PASS requires:
- M13 `CampaignNavigationController.level_selected(island_id, level_id)` is consumed by a production session-launch path;
- GameplaySessionBridge fetches the exact immutable level definition from LevelDatabase;
- locked/nonexistent levels cannot launch;
- selected island/level identity remains exact through launch;
- one existing gameplay implementation is reused;
- no per-level gameplay-scene duplication.

## Gate B — Immutable session configuration

Gameplay receives one immutable session snapshot containing at minimum:
- island_id;
- level_id;
- time_limit_sec;
- normal `orders`;
- optional `vip` definition/state;
- rewards definition as passive data only;
- score/star threshold data;
- feature flags.

Mutating gameplay runtime state must not mutate LevelDatabase definitions.

## Gate C — Authoritative countdown timer

PASS requires one canonical session timer with deterministic state:
- starts only after gameplay/session ready;
- decrements while active;
- pauses on legitimate game pause;
- does not drain while app/session is legitimately background-paused;
- resumes correctly;
- stops on terminal win/lose;
- timeout resolves exactly once;
- no negative-time repeated terminal events;
- retry starts a fresh timer from the original immutable level definition.

Use one authoritative time source. Wall-clock display formatting must not become gameplay truth.

## Gate D — Normal To-Go objective semantics

PASS requires:
- normal campaign win requires every configured normal order to be satisfied before timeout;
- quantities >1 are handled correctly;
- order satisfaction is deterministic and idempotent;
- existing To-Go behavior remains compatible with stored qualifying L6-L12 drinks satisfying later matching orders;
- campaign mode must not discard/forbid that accepted stored-drink rule.

Do not implement alternate merge physics to satisfy campaign objectives.

## Gate E — Optional VIP semantics

PASS requires:
- VIP may be absent/null/disabled;
- incomplete or failed VIP never blocks normal level win;
- VIP completion can be represented in result data;
- no M15 reward/inventory grant is required in this milestone;
- VIP state cannot convert a normal loss into a win.

## Gate F — Win/lose result model

Terminal result must be immutable/deterministic and include enough data for M11 progression:
- island_id;
- level_id;
- outcome WIN/LOSE;
- score;
- remaining time;
- normal orders completed;
- VIP completed boolean/state;
- stars/mastery result if deterministically derivable from current level thresholds;
- retry/next/island-map navigation availability.

Terminal result may be committed only once per session.

## Gate G — Progression handoff

On WIN:
- submit completion through CampaignManager/M11 canonical progression APIs;
- unlock/update next level exactly once;
- replay cannot lower stored best score/stars;
- no M15 one-time economy reward implementation is introduced.

On LOSE:
- do not advance campaign progression.

## Gate H — Result navigation

PASS requires bounded production flows:
- Retry: restart same island/level with clean session/timer/objective state;
- Next Level: only when CampaignManager resolves an unlocked next level;
- Island Map: return to the M13 Island Map preserving the campaign navigation boundary.

No duplicate gameplay/session instances after repeated Retry/Next/Map cycles.

## Gate I — Core gameplay regression preservation

Campaign session work must not change accepted:
- drink launch physics;
- merge rules;
- collider radii;
- R11 playable table footprint/edge behavior;
- score/combo core;
- accepted HUD placement;
- existing stored L6-L12 To-Go qualification semantics.

Any required GameManager hook must be additive/bounded.

## Gate J — M16 boundary

M14 tests may use deterministic level fixtures or existing seed campaign records.

Do not author canonical Sunny Cove L1-L100 production content.
Do not change the M16 baseline/timing/content rules.

## Gate K — Focused M14 probe

Create:
`tests/m14_gameplay_session_bridge_probe.gd`

It must prove at minimum:
- actual M13 level-selection signal enters the session bridge;
- exact level definition snapshot;
- nonexistent/locked selection rejection;
- timer ready/start/pause/resume/background-pause/timeout;
- timer stops on WIN and LOSE;
- normal order quantities;
- stored qualifying later-order behavior for L6-L12;
- optional VIP does not gate normal win;
- timeout loss does not advance progression;
- win advances exactly once;
- replay does not lower best score/stars;
- Retry reset;
- Next Level resolution;
- Island Map return;
- repeated flow creates no duplicate active session;
- immutable LevelDatabase definition remains unchanged.

Run the M14 probe twice after normal Godot 4.7 import/bootstrap with no intervening file changes. Both must PASS exit 0.

## Gate L — Regression suite

Required:
- M10 PASS;
- M11 PASS;
- M12 PASS;
- M13 PASS;
- relevant R11/core gameplay regression probes PASS;
- any modified GameManager-focused regression PASS.

No accepted physics constants may change.

## Gate M — Governance

- Codex must not edit root `TASKS.md`;
- no M15 implementation;
- no M16 production content;
- no accepted visual asset regeneration;
- builder log committed/pushed;
- worktree clean;
- local HEAD / origin/main / remote main synchronized.

## Required builder log

Write:
`coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CODEX_LOG_V01.md`

Include:
- start HEAD;
- implementation SHA;
- final main HEAD;
- exact changed files;
- session architecture;
- timer state machine;
- objective/VIP semantics;
- result/progression flow;
- Retry/Next/IslandMap flow;
- M14 run 1/run 2;
- M10/M11/M12/M13 and core gameplay regressions;
- warnings/limitations;
- explicit `TASKS.md` untouched confirmation;
- clean/sync proof.

## Acceptance

Any material FAIL or UNVERIFIED = `CHANGES_REQUIRED`.
