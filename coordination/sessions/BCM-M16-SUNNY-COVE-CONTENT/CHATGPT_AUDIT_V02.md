# BCM-M16 Sunny Cove VIP Content — Independent Audit V02

Verdict: **CHANGES_REQUIRED**

Auditor: ChatGPT  
Builder: CODEX  
Branch: `main`  
Implementation SHA: `d56ed91e89bfcbd76bb461dfa35b3a33794e2088`  
Final audited HEAD: `5d897089d2c8a24bf07285f3be9ead9e57f66dc7`

## 1. Summary

M16 V02 passes every data, reward, replay, persistence, and normal-content immutability gate.

One visual contract failure prevents closure:

> The Island Map marker uses `assets/ui_assets/screens/prelevel/vip_badge.png`, but the actual asset is an ornate turquoise frame with no visible "VIP" text and no crown. It does not communicate the owner-approved VIP/crown opportunity at a glance.

Therefore Gate G fails and M16 remains open.

## 2. Independent VIP data verification

ChatGPT independently compared final canonical Sunny Cove data against `OWNER_RULING_V02.md`.

Result:
- exactly 25 VIP levels;
- exact cadence: 4,8,12,...,100;
- exact target/quantity mismatches: 0;
- non-VIP payload mismatches: 0;
- qty1 = 15;
- qty2 = 10;
- +Time rewards = 20;
- Upgrade rewards = 5;
- Upgrade levels exactly 20/40/60/80/100;
- normal-content drift versus pre-V02 canonical dataset = 0.

## 3. Workload verification

Independent computation confirms:
- all VIP workload ratios match the owner table;
- only accepted out-of-band entries exist:
  - Level 4 = 50.00%;
  - Level 64 = 22.22%;
- all remaining VIP entries are within 25%-40%.

## 4. Reward / replay / persistence verification

Source and focused test inspection confirms the intended architecture:

- normal WIN remains independent of VIP completion;
- replay of already completed levels remains allowed;
- CampaignManager persists `vip_completed` monotonically using logical OR;
- first later VIP completion can upgrade persisted false → true;
- VIP reward IDs are deterministic: `vip:<island>:<level>`;
- GameEconomy reward ledger prevents duplicate grants;
- focused M16 probe explicitly exercises missed VIP → replay completion → another replay idempotency.

Builder runtime evidence reports PASS and no repository evidence contradicts it.

## 5. Normal-content immutability

Compared pre-V02 canonical data at `0c371623...` with final V02 data at `5d897089...`.

For all 100 levels:
- `orders`: unchanged;
- `time_limit_sec`: unchanged;
- normal `rewards`: unchanged;
- `score_star_thresholds`: unchanged.

Only the approved VIP payload / VIP feature flag changed on 25 rows.

## 6. LevelDatabase validation change

The bounded LevelDatabase change accepts JSON numeric values represented as TYPE_INT or integer-valued TYPE_FLOAT while still rejecting fractional values.

This is compatible with JSON parser numeric representation and does not broaden eligibility beyond integer campaign targets/quantities.

PASS.

## 7. Island Map marker data plumbing

PASS:
- VIP status is derived from canonical level data via `level_database.get_level(...).vip.enabled`;
- no duplicate hard-coded VIP list exists in production Island Map code;
- marker visibility is independent from LOCKED/OPEN/CURRENT/COMPLETE state;
- non-VIP levels keep marker hidden;
- level number, stars, milestone and level-state text remain intact.

## 8. Gate G visual semantic failure

Current production path:

`res://assets/ui_assets/screens/prelevel/vip_badge.png`

Independent inspection of the actual 128×128 PNG shows:
- tropical ornate frame;
- turquoise empty center;
- no "VIP" lettering;
- no crown.

This does not satisfy the explicit owner contract for a **visible VIP/crown marker**.

A suitable already-existing approved repo asset is:

`res://assets/ui_assets/ui/gameplay/vip_badge.png`

Independent inspection shows:
- clear gold crown;
- large visible "VIP";
- tropical decoration;
- no new art generation required.

At the current 24×24 marker size, legibility would also be marginal. Remediation should use a visibly legible size and commit actual Island Map screenshot evidence.

## 9. Test evidence

Builder reports PASS:
- M16 focused probe twice;
- M15;
- M14;
- M13;
- M11;
- M10;
- `git diff --check`.

ChatGPT did not execute Godot locally, but independently inspected:
- final GitHub HEAD;
- implementation diff;
- all 100 canonical data rows;
- all 25 VIP rows;
- reward/workload calculations;
- production marker plumbing;
- replay/persistence source;
- focused test source;
- actual marker assets.

## 10. Verdict matrix

| Gate | Result |
| --- | --- |
| A exact cadence | PASS |
| B exact target/quantity | PASS |
| C workload | PASS |
| D reward cadence | PASS |
| E flags/non-VIP rows | PASS |
| F normal-content immutability | PASS |
| G visible VIP/crown marker | **FAIL** |
| H replay/persistence | PASS |
| I M15 scoring semantics preserved | PASS |
| J tests/governance | PASS |

## 11. Required remediation

Change only the Island Map marker presentation:
- use the existing crown+VIP asset `assets/ui_assets/ui/gameplay/vip_badge.png`;
- make it visibly legible at 720×1280;
- keep it outside/adjacent to the level-node content so it does not replace number/stars/state/milestone;
- preserve canonical-data-driven visibility;
- capture committed visual evidence for VIP LOCKED / OPEN / CURRENT / COMPLETE and a non-VIP control.

No VIP data, reward, replay, economy, normal content, M15 HUD, or physics changes are authorized.

**BCM-M16-009 remains open.**
