# BCM-M16 VIP Crown Marker Remediation — Audit Criteria V03

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_V02.md`
- `coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/OWNER_RULING_V02.md`
- current audited V02 data/replay/reward implementation

## Objective

Remediate only the Island Map VIP marker visual semantics. All V02 VIP data, reward, replay/persistence behavior and all normal Sunny Cove content are frozen.

## Gate A — Correct marker asset

Production `LevelButton` must use:

`res://assets/ui_assets/ui/gameplay/vip_badge.png`

This exact existing asset contains a visible gold crown and readable VIP lettering.

The old marker source:
`res://assets/ui_assets/screens/prelevel/vip_badge.png`
must no longer be the production Island Map marker.

No new art may be generated.

## Gate B — Legible marker size / placement

At 720×1280:
- marker must be visibly legible as VIP/crown;
- target marker size must be **36×36 display px**;
- preserve aspect ratio;
- place it adjacent to the level node near the upper-right edge;
- do not cover the level number, stars, state text or milestone marker;
- do not clip off the 720px map width for either left/right alternating node positions.

A small bounded coordinate adjustment is permitted only for marker placement.

## Gate C — Data-driven visibility remains unchanged

Marker visibility must still derive from canonical level definition:
- VIP payload enabled => marker visible;
- no VIP payload => hidden.

No second hard-coded production VIP level list.

## Gate D — All level states

Committed runtime evidence must prove marker visible on VIP:
- COMPLETE
- OPEN
- CURRENT
- LOCKED

and absent on a non-VIP control level.

## Gate E — No regression of V02 content

No changes to:
- 25 VIP cadence;
- any VIP target/quantity;
- any +Time/Upgrade reward;
- workload policy;
- replay-later behavior;
- reward idempotency;
- normal objectives/timers/rewards;
- M15 HUD;
- physics/table/colliders.

## Gate F — Evidence

Commit screenshots under:

`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/evidence/v03/`

Required:
- `vip_complete.png`
- `vip_open.png`
- `vip_current.png`
- `vip_locked.png`
- `non_vip_control.png`

Screenshots must show enough Island Map context to judge legibility and non-overlap.

## Gate G — Tests

Required PASS:
- M16 focused probe twice;
- M13 Island Map regression;
- M15 regression;
- `git diff --check`.

Update focused marker assertions to verify:
- exact gameplay VIP badge resource path;
- marker display size 36×36;
- data-driven state behavior remains intact.

## Governance

Codex must:
- sync canonical Desktop before/after;
- not edit root `TASKS.md`;
- not create branches;
- not create Desktop copies/worktrees;
- not start M17.

## Builder log

Write:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CODEX_LOG_V03.md`

Final M16 closure requires independent ChatGPT audit and owner visual acceptance of the V03 marker screenshots.
