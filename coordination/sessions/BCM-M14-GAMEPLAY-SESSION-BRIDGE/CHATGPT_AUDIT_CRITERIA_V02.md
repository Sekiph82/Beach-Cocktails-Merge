# BCM-M14 Gameplay Session Bridge — Remediation Audit Criteria V02

Status: **LOCKED BEFORE EXECUTION**  
Auditor: ChatGPT  
Builder: Codex  
Branch: `main`

Remediate only the blockers in:
`coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CHATGPT_AUDIT_V01.md`

## Frozen accepted M14 work

Preserve:
- GameplaySessionBridge as single session authority;
- deep read-only level snapshot;
- exact island/level identity;
- one reused gameplay scene;
- normal To-Go quantity/idempotency behavior;
- timeout single-resolution semantics;
- optional VIP not gating normal win;
- WIN-only progression;
- Retry / Next / Island Map routing;
- stored qualifying L6-L12 delivery behavior;
- accepted R11 physics/table/HUD/assets;
- M15/M16 boundaries.

## Gate A — Real executable campaign entry

PASS requires the actual Godot application entry flow to compose the campaign router.

A normal project launch must:
- enter the production CampaignNavigationScene/app-shell flow;
- expose M12 World Map -> M13 Island Map -> M14 gameplay traversal;
- reuse `scenes/main.tscn` as the gameplay implementation only when a level is selected;
- not boot directly into gameplay.

The focused test must validate the configured project/main entry composition, not only instantiate CampaignNavigationScene manually.

## Gate B — Correct star contract

Locked rules:
- 1 star = normal completion;
- 2 stars = normal completion + VIP OR configured 2-star mastery condition;
- 3 stars = normal completion + VIP AND configured 3-star score mastery.

PASS requires:
- VIP incomplete + score above 3-star threshold => maximum 2 stars;
- VIP complete + score below 3-star threshold => maximum 2 stars;
- VIP complete + score at/above 3-star threshold => 3 stars;
- normal completion with neither VIP nor mastery => 1 star;
- replay remains monotonic and cannot lower prior best stars/score.

Do not introduce star progression gates.

## Gate C — Production gameplay pause lifecycle

Provide a production-facing gameplay pause/resume hook that updates the active GameplaySessionBridge timer state.

PASS requires:
- gameplay pause freezes timer;
- gameplay resume resumes only when appropriate;
- terminal/idle sessions cannot be incorrectly resumed.

The test must invoke the production-facing hook rather than directly calling bridge pause methods only.

## Gate D — Production application background lifecycle

Wire actual Godot application/background lifecycle to the active session.

PASS requires:
- application background/pause event freezes active timer;
- application resume restores timer only if the background transition itself paused it;
- a pre-existing gameplay/user pause remains paused after application resume;
- terminal sessions remain terminal.

The test must exercise the production handler/path, not merely call `GameplaySessionBridge.set_background_paused()` directly.

## Gate E — Real M13 -> M14 selection

After production entry composition:
- unlocked M13 level selection launches exactly one existing gameplay scene;
- locked/nonexistent selections cannot launch;
- exact island/level identity survives into GameplaySessionBridge;
- repeated Retry/Next/IslandMap cycles do not duplicate gameplay/session instances.

## Gate F — Existing M14 core remains green

Preserve existing focused assertions for:
- immutable definition snapshot;
- timer ready/start/timeout;
- normal order quantities;
- idempotent deliveries;
- stored matching L6-L12 behavior;
- VIP optionality;
- LOSE no progression;
- WIN exactly-once progression;
- Retry reset;
- Next Level;
- Island Map;
- canonical LevelDatabase immutability.

## Gate G — Regression and R11 authority

Required PASS:
- M10;
- M11;
- M12;
- M13;
- M14 twice;
- M02;
- M03;
- M08;
- any newly added app-entry/pause lifecycle focused probe.

Do not rewrite superseded historical R10 full-silhouette probes to manufacture PASS.
Do not alter accepted R11 physics/table constants.

## Gate H — Governance

- no root `TASKS.md` edit by Codex;
- no M15 implementation;
- no M16 production content;
- no accepted visual asset regeneration;
- no physics/HUD retuning;
- builder log committed/pushed;
- clean worktree;
- local HEAD / origin/main / remote main synchronized.

## Builder log

Write:
`coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CODEX_LOG_V02.md`

Include:
- start HEAD;
- implementation SHA;
- final main HEAD;
- exact changed files;
- app-entry composition;
- gameplay pause integration;
- application background lifecycle integration;
- corrected star matrix evidence;
- M14 run1/run2;
- M10/M11/M12/M13/M02/M03/M08 results;
- confirmation historical superseded probes were not rewritten to fake green;
- confirmation TASKS untouched;
- sync/clean proof.

Any material FAIL/UNVERIFIED = `CHANGES_REQUIRED`.
