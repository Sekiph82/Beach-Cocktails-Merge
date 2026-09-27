# BCM-M15 VIP, Boosters, Rewards & Economy — Remediation Prompt V02

Execute against:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_V01.md`
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V02.md`

Before implementation, obey `AGENTS.md` and synchronize the canonical Desktop checkout:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`
to current `origin/main`.

## Goal

Close the real gameplay VIP-order gap without rewriting the accepted gameplay.

Current defect:
- GameManager only captures `_target_level`, the mandatory normal To-Go target;
- `record_vip_delivery()` is called only after that normal delivery;
- a distinct VIP target has no production capture route;
- VIP quantity >1 does not accumulate;
- the current completed screenshot uses direct `set_vip_completed(true)`.

## 1. Implement real VIP order fulfillment

Add the smallest production path that lets a pending VIP target consume/capture a qualifying drink independently from the normal To-Go target.

Requirements:
- normal objective remains mandatory and primary;
- VIP remains optional;
- no customer character/new animated scene;
- do not change accepted table/HUD geometry;
- reuse restrained existing delivery visual language where practical;
- actual drink must leave the board when delivered to VIP;
- newly merged and already-stored qualifying drinks must be eligible;
- do not double-free/double-score/double-deliver a drink.

Document deterministic behavior when normal and VIP levels are the same. Prefer mandatory normal-order safety over VIP convenience.

## 2. Fix VIP quantity state

Replace boolean-only delivery semantics with cumulative runtime quantity tracking.

`get_vip_state()` must expose required/delivered/remaining/completed.

Each real one-drink VIP delivery increments by one until required quantity is reached.

Extra deliveries after completion must not duplicate state or rewards.

Retry/new session must reset VIP quantity state from immutable level definition.

## 3. Preserve reward timing

Do NOT grant the VIP reward at VIP delivery time.

Grant it only at normal WIN when VIP is complete, using the existing deterministic ledger ID.

Preserve:
- incomplete VIP normal WIN;
- LOSE no reward;
- replay/reload idempotency.

## 4. Strengthen the focused probe

Use a fixture where:
- normal target is L6;
- VIP target is L12;
- VIP quantity is 2.

Prove through GameManager production behavior:
- pending state initially;
- first actual L12 delivery => 1/2, still pending;
- second actual L12 delivery => 2/2 completed;
- normal L6 objective remains separately completable;
- VIP reward grants once only after normal WIN;
- stored L12 can satisfy VIP;
- no direct `set_vip_completed(true)` is used for the functional completion proof.

Keep all existing economy/save/+Time/milestone tests.

## 5. Visual evidence

Capture actual Windows/OpenGL screenshots from the real production path and commit evidence copies under:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v02/`

Required:
- `vip_pending.png`
- `vip_completed.png`
- `non_vip.png`

If practical, also include `vip_partial.png` for quantity 1/2.

These are audit evidence only, not replacement production assets.

## 6. Regression

Run normal Godot 4.7 bootstrap, then:
- M15 twice;
- M14;
- M13;
- M12;
- M11;
- M10;
- M08;
- M03;
- M02.

## Hard boundaries

Do not:
- edit `TASKS.md`;
- start M16;
- add purchases/ads/backend;
- retune physics/table/colliders;
- regenerate accepted visual assets;
- create a GitHub branch;
- create any additional Desktop project/worktree folder.

## Completion

Write:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V02.md`

Push `main`, then obey the canonical post-task Desktop sync rule.

Return:
- implementation SHA;
- final main/canonical Desktop SHA;
- real distinct VIP delivery PASS/FAIL;
- VIP quantity accumulation PASS/FAIL;
- VIP reward idempotency PASS/FAIL;
- screenshot evidence paths;
- M15x2 and regression results;
- log URL;
- `AWAITING_M15_AUDIT_V02`.

Then STOP.