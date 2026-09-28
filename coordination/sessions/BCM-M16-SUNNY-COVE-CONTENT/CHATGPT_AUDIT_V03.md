# BCM-M16 VIP Crown Marker Remediation — Independent Audit V03

Verdict: **TECHNICAL_AUDIT_PASS / OWNER_VISUAL_ACCEPTANCE_REQUIRED**

Auditor: ChatGPT  
Builder: CODEX  
Branch: `main`  
V03 implementation SHA: `b5c48ae62cdad098ecb07d85070fa66572bfee67`  
Final audited HEAD: `4adc63ad4470a3a10c546dc73caae2a9e7a71212`

## 1. Summary

The bounded V03 remediation passes the locked technical criteria.

The prior V02 failure is corrected:
- production Island Map marker now uses the existing gameplay VIP badge containing crown + VIP lettering;
- display size is exactly 36×36;
- placement is adjacent to the upper-right of the level node;
- marker remains data-driven;
- VIP/non-VIP state behavior remains intact;
- no Sunny Cove content, reward, replay, economy, M15 HUD, or physics systems were modified.

M16 now requires only the owner's final visual acceptance of the committed V03 screenshots before BCM-M16-009 and M16 can close.

## 2. Diff scope

Compared V03 start HEAD `836ba3e...` to final audited HEAD `4adc63ad...`.

Product/runtime changes are bounded to:
- `scripts/campaign/level_button.gd`
- `tests/m16_sunny_cove_content_probe.gd`

Other changes are:
- required V03 runtime screenshot evidence;
- Codex execution logs.

No `data/campaign/levels/sunny_cove.json` change exists in V03.
No M15 HUD, campaign reward, replay, economy, physics, table, collider, or M17 product files changed.

## 3. Gate A — Correct marker asset

PASS.

Production path is now exactly:

`res://assets/ui_assets/ui/gameplay/vip_badge.png`

The previous incorrect prelevel frame asset is no longer the production marker.

Independent inspection of the replacement asset confirms:
- visible gold crown;
- visible VIP lettering;
- tropical styling;
- no new art generation.

## 4. Gate B — Size / placement

PASS.

Production constants / geometry:
- size: `36×36`
- position: `Vector2(118, 2)`
- LevelButton width: `116`
- aspect preserved with `STRETCH_KEEP_ASPECT_CENTERED`.

The marker sits adjacent to, rather than over, the level-node content.

The focused probe verifies marker bounds for both alternating map sides and confirms it remains within the 720px content width.

## 5. Gate C — Data-driven visibility

PASS.

Production Island Map continues to derive VIP state through canonical data:

`level_database.get_level(island_id, level_id).vip.enabled`

No second production VIP-level list was added.

## 6. Gate D / F — Runtime evidence

PASS technically.

Committed 720×1280 evidence:
- `evidence/v03/vip_complete.png`
- `evidence/v03/vip_open.png`
- `evidence/v03/vip_current.png`
- `evidence/v03/vip_locked.png`
- `evidence/v03/non_vip_control.png`

ChatGPT independently opened and reviewed all five final screenshots.

Observed:
- VIP badge appears on COMPLETE VIP state;
- VIP badge appears on OPEN VIP state;
- VIP badge appears on CURRENT VIP state;
- VIP badge appears on LOCKED VIP state;
- marker is absent on the non-VIP control;
- badge sits outside/adjacent to the level node rather than obscuring the level number, stars, state text, or milestone glyph;
- no visible map-edge clipping is present in the provided evidence.

The marker is intentionally compact, but materially clearer and more semantically correct than the rejected V02 turquoise-frame marker.

Final visual acceptance remains an owner gate.

## 7. Gate E — Frozen V02 contracts

PASS.

V03 changes do not touch canonical Sunny Cove data.

Therefore the independently audited V02 contracts remain intact:
- 25 VIP levels;
- exact every-four-level cadence;
- exact target/quantity table;
- 15 qty1 / 10 qty2;
- 20 +Time / 5 Upgrade;
- Upgrade at 20/40/60/80/100;
- workload ratios;
- replay-later VIP completion;
- reward idempotency;
- normal objective/timer immutability.

## 8. Gate G — Tests

Builder reports PASS:
- M16 focused probe twice;
- M13 Island Map regression;
- M15 regression;
- `git diff --check`;
- LevelButton parse check.

ChatGPT did not independently execute Godot in this environment, but independently inspected:
- live final GitHub HEAD;
- exact V03 diff;
- production marker source;
- focused assertions;
- five committed runtime screenshots.

No repository evidence contradicts the builder results.

## 9. Verdict matrix

| Gate | Result |
| --- | --- |
| A correct crown+VIP asset | PASS |
| B 36×36 / placement / bounds | PASS |
| C data-driven visibility | PASS |
| D all VIP states + non-VIP control | PASS |
| E frozen V02 content/contracts | PASS |
| F committed runtime evidence | PASS |
| G tests / governance | PASS |

## 10. Closure state

**Technical verdict: AUDITED_PASS.**

**Owner visual acceptance: PENDING.**

BCM-M16-009 remains open only for the owner visual gate.

If owner accepts the V03 screenshots:
- BCM-M16-009 may be marked complete;
- M16 may close;
- H!veAI may advance to M17.

If owner rejects only marker appearance/placement:
- reopen with a new visual-only remediation version;
- keep all V02/V03 data/reward/replay contracts frozen.
