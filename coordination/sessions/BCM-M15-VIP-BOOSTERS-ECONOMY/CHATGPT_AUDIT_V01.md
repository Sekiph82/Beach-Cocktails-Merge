# BCM-M15 VIP, Boosters, Rewards & Economy — Independent Audit V01

Verdict: **CHANGES_REQUIRED**

Auditor: ChatGPT
Builder: Codex
Branch: `main`
Audited implementation SHA: `e371163404dfacda4e5e5d3bc12ee7a074632614`
Audited builder final HEAD: `0b686f3eb1ee58eb5e166631a5d8bfbbd51092c9`

Locked criteria:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V01.md`

Builder log:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V01.md`

## 1. VERDICT

**CHANGES_REQUIRED.**

The economy/persistence/+Time/milestone core is materially strong, but the production VIP objective is not actually independently completable in normal gameplay when the VIP target differs from the mandatory To-Go target. VIP quantity > 1 is also not accumulated across deliveries.

The focused probe masks this by directly mutating the bridge VIP state for the completed screenshot.

M16 must not begin.

## 2. DIFF / SCOPE

Independent compare from `7161cdb...` to `0b686f3...` contains exactly two commits.

Changed implementation paths are bounded to campaign economy/session/save/navigation, GameManager VIP UI/runtime hook, focused M15 probe, and builder log.

No M16 canonical level content, purchase/ad/backend system, accepted asset regeneration, or root `TASKS.md` edit was introduced.

Scope discipline: **PASS**.

## 3. ACCEPTANCE MATRIX

| Gate | Result | Independent finding |
| --- | --- | --- |
| A. Canonical economy authority | **PASS** | One shared GameEconomy is wired through CampaignManager, navigation and GameplaySessionBridge; reward ledger and fail-closed APIs exist. |
| B. Save/persistence | **PASS** | coins/boosters/reward_ledger persist through SaveManager; pre-M15 schema-v2 saves normalize with empty ledger. |
| C. VIP presentation | **PARTIAL** | Compact badge implementation exists, but completed state is not proven through a real independently completable VIP gameplay path. |
| D. VIP reward dispatch | **FAIL** | Reward dispatch logic is idempotent, but production gameplay cannot generally complete a distinct VIP target; quantity >1 is not cumulative. |
| E. Booster inventory | **PASS** | Grant/consume/insufficient/export/import behavior exists and focused probe covers it. |
| F. +Time | **PASS** | Remaining time only, atomic booster consume, immutable base time, invalid/terminal protection. |
| G. Milestone rewards | **PASS** | Eligibility, one-time claim and deterministic reward ID are implemented. |
| H. Coins / reward ledger | **PASS** | Nonnegative grants and deterministic idempotent ledger persistence implemented. |
| I. Real runtime integration | **FAIL on VIP objective path** | Same economy authority is reused, but distinct VIP order fulfillment is not available through real GameManager delivery flow. |
| J. Result/economy separation | **PASS** | M14 WIN/LOSE/progression remains authoritative; reward result is post-result data. |
| K. Focused M15 probe | **FAIL as production proof** | Probe directly calls `set_vip_completed(true)` for runtime completed screenshot and direct bridge APIs for VIP completion; it does not prove real gameplay fulfillment. |
| L. Visual evidence | **UNVERIFIED** | Screenshots are only local `user://` files and were not supplied/committed for independent inspection. Owner visual acceptance is also pending. |
| M. Regression preservation | **PASS by builder evidence/source scope** | M02/M03/M08/M10-M14 and M15x2 reported PASS; no physics constants/assets changed. |
| N. Governance | **PASS** | TASKS unchanged; canonical task-start sync followed; no M16/ads/purchases. |

## 4. BLOCKER — VIP target is not independently deliverable

Current production GameManager has one active collection target: `_target_level`, sourced from `GameplaySessionBridge.get_next_required_order_level()`.

`on_merged()` only auto-collects a newly created drink when:
`new_level == _target_level`.

`_try_collect_stocked_target()` likewise searches only for `_target_level`.

`_collect_merge_target()` rejects any drink whose level is not `_target_level`.

Only after that **normal To-Go** collection finishes does GameManager call:
`campaign_session_bridge.record_vip_delivery(completed_level, 1, score)`.

Therefore a VIP target different from the current normal target has no production delivery route.

Example from the M15 fixture:
- normal objective = L6;
- VIP objective = L12.

A real L12 drink will not be captured for VIP while L6 is the active normal target. The bridge can represent VIP state, but gameplay cannot fulfill it.

This directly blocks the M15 'VIP orders' contract and Gate I real-runtime integration.

## 5. BLOCKER — VIP quantities are not cumulative

`GameplaySessionBridge.record_vip_delivery()` currently checks:
`quantity < configured VIP quantity`

and then sets `_vip_completed = true` only when one call supplies the entire configured quantity.

Normal gameplay delivers one drink at a time.

For a configured VIP quantity of 2 or more, two separate one-unit deliveries never accumulate and therefore can never complete the VIP order.

Required runtime state must track delivered/remaining VIP quantity across deliveries.

## 6. PROBE WEAKNESS

The focused probe does not expose the production defect.

For the screenshot flow it does:
`navigation.get_session_bridge().set_vip_completed(true)`

rather than completing VIP through GameManager's real drink-delivery path.

Earlier functional VIP tests also call bridge methods directly.

These are valid bridge-unit checks but not sufficient evidence for Gate I.

The remediation probe must fail if the production VIP capture/delivery route is removed.

## 7. VISUAL EVIDENCE STATUS

Builder reports three Windows/OpenGL screenshots under local Godot `user://m15_screenshots/`.

They are not committed to the repository and were not attached in this conversation, so the auditor cannot independently inspect their pixels.

Per audit policy, visual evidence is therefore **UNVERIFIED**.

After technical remediation, the three evidence screenshots must be made independently inspectable, and the owner must still visually accept the new VIP UI before unconditional M15 closure.

## 8. WHAT PASSES AND MUST BE PRESERVED

Preserve without regression:
- GameEconomy single authority;
- deterministic level/VIP/milestone reward IDs;
- reward ledger persistence;
- pre-M15 save compatibility;
- booster grant/consume fail-closed behavior;
- +Time remaining-time-only semantics;
- milestone eligibility/one-time claims;
- level reward dispatch;
- VIP reward only on normal WIN + VIP completion;
- no VIP requirement for normal WIN;
- M14 stars/progression semantics;
- one shared economy across Retry/Next/IslandMap;
- no purchases/ads/backend;
- accepted R11 physics/HUD/table geometry.

## 9. REQUIRED REMEDIATION

1. Add a real production VIP fulfillment path in GameManager that works when VIP target differs from the current normal To-Go target.
2. VIP delivery must consume/capture an actual qualifying drink, not merely toggle state.
3. Accumulate VIP delivered quantity across multiple one-drink deliveries until configured quantity is reached.
4. Keep normal mandatory To-Go objective readable and authoritative; VIP remains optional and never blocks normal WIN.
5. Preserve stored-drink behavior and do not retune merge/physics/table logic.
6. Strengthen M15 probe so a fixture with normal L6 and VIP L12 completes VIP through real GameManager gameplay/capture flow without `set_vip_completed(true)` or direct fake completion.
7. Add quantity>1 VIP proof through multiple one-unit deliveries.
8. Make pending/completed/non-VIP screenshots independently inspectable by committing bounded audit evidence copies under the M15 session evidence folder.
9. Re-run M15 twice plus M02/M03/M08/M10-M14 regressions.
10. Keep root `TASKS.md` untouched by Codex.

## 10. FINAL VERDICT

**CHANGES_REQUIRED**

M15 remains open.