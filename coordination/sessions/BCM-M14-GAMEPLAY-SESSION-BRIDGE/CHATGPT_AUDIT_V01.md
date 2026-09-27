# BCM-M14 Gameplay Session Bridge — Independent Audit V01

Verdict: **CHANGES_REQUIRED**

Auditor: ChatGPT  
Builder: Codex  
Branch: `main`  
Audited start HEAD: `1f5dbddcef78593e7870d5c83330ebfa9bb59b1c`  
Implementation SHA: `9aaba7ffed0bc0b9f48252432a0d492985607c38`  
Audited builder final HEAD: `a098205ee2c3183e53b7abbbd12ec42c0e78e3a7`

Locked criteria:
`coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CHATGPT_EXECUTION_PROMPT_V01.md`

Builder log:
`coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CODEX_LOG_V01.md`

## 1. Verdict

**CHANGES_REQUIRED.**

The M14 bridge/session core is substantially implemented and the focused probe is strong, but three locked production-contract gaps remain:

1. the executable app still boots directly into gameplay rather than the campaign navigation/session flow;
2. the implemented 3-star rule contradicts the locked campaign technical design;
3. pause/background timer behavior is tested only through direct bridge calls and is not connected to production gameplay/application lifecycle events.

M15 must not begin.

## 2. Diff / scope audit

Independent compare `1f5dbdd...` -> `a098205...` contains exactly two commits.

Changed product/test files:
- `scripts/campaign/gameplay_session_bridge.gd`
- `scripts/campaign/campaign_navigation_controller.gd`
- `scripts/game_manager.gd`
- `tests/m14_gameplay_session_bridge_probe.gd`
- builder log

No M15 implementation, M16 production content, accepted visual assets, or root `TASKS.md` were modified by Codex.

Physics-critical constants and the accepted R11 table geometry constants remain unchanged.

Scope discipline: **PASS**.

## 3. Acceptance matrix

| Gate | Result | Independent finding |
| --- | --- | --- |
| A. Real level launch boundary | **FAIL** | CampaignNavigationScene can launch gameplay when manually instantiated, but the executable still boots `res://scenes/main.tscn` directly. |
| B. Immutable session configuration | **PASS** | Exact level definition and session fields are deep read-only snapshots detached from LevelDatabase definitions. |
| C. Authoritative countdown timer | **PARTIAL / FAIL** | Bridge state machine is deterministic, but real app/gameplay pause/background lifecycle does not call it. |
| D. Normal To-Go objectives | **PASS** | Quantities, idempotent delivery IDs, deterministic remaining/completed state and stored matching delivery path are present. |
| E. Optional VIP semantics | **PASS for optionality boundary** | VIP does not gate normal win and no M15 reward/economy behavior is introduced. |
| F. Win/lose result model | **FAIL on stars contract** | Result is deterministic/immutable, but 3-star derivation violates locked design by allowing score-only 3 stars without VIP. |
| G. Progression handoff | **PASS** | WIN submits once through CampaignManager; LOSE does not advance; replay remains monotonic. |
| H. Result navigation | **PASS inside CampaignNavigationScene** | Retry, Next and Island Map boundaries are implemented without duplicate gameplay instances. |
| I. Core gameplay preservation | **PASS** | GameManager changes are additive; accepted physics/table constants are unchanged; M02/M03/M08 builder regressions pass. |
| J. M16 boundary | **PASS** | Only deterministic fixture level data added in tests. |
| K. Focused M14 probe | **PARTIAL** | Probe covers most locked behavior but currently encodes the wrong 3-star expectation and bypasses actual app lifecycle/entry composition. |
| L. Regression suite | **PASS with historical-probe caveat** | M10/M11/M12/M13/M02/M03/M08 reported PASS. Failed R10-era probes are historical/superseded artifacts, not current R11 authority. |
| M. Governance | **PASS** | TASKS untouched by Codex; no M15/M16/assets scope expansion. |

## 4. Blocking finding A — executable entry point bypasses campaign flow

Current `project.godot` still declares:

`run/main_scene="res://scenes/main.tscn"`

And `scenes/main.tscn` is still the direct GameManager gameplay scene.

Therefore a normal application launch:
- does not enter CampaignNavigationScene;
- does not show the M12 World Map;
- cannot naturally traverse M12 -> M13 -> M14;
- bypasses the production campaign/session router entirely.

The focused M14 probe proves the router works only after the test manually instantiates:
`res://scenes/campaign/CampaignNavigationScene.tscn`.

This is not sufficient for locked Gate A's **production session-launch path**.

This exact composition gap was explicitly deferred by the M13 V02 audit:

> The current executable project still boots the existing gameplay `main.tscn`. Full campaign-to-gameplay app-flow composition belongs to the upcoming M14 session bridge work.

M14 must now close that debt.

## 5. Blocking finding B — 3-star derivation contradicts locked technical design

Locked authority:
`docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`

Star contract:
- 1 star: normal level completed;
- 2 stars: completion plus VIP **or** configured mastery condition;
- 3 stars: completion plus VIP **and** configured score mastery.

Current `GameplaySessionBridge._derive_stars()` grants 3 stars whenever score reaches `three_stars`, even when `vip_completed == false`.

The current focused probe reinforces the wrong rule:
- level has VIP enabled;
- VIP is intentionally incomplete;
- score = 300;
- resulting persisted stars are expected to be 3.

That contradicts the locked design.

Required behavior:
- normal completion = at least 1;
- VIP OR configured 2-star mastery can raise to 2;
- 3 stars requires both VIP completion and configured 3-star score mastery.

## 6. Blocking finding C — pause/background lifecycle is not production-wired

`GameplaySessionBridge` correctly exposes:
- `pause_session()`
- `resume_session()`
- `set_gameplay_paused()`
- `set_background_paused()`

But repository truth shows no production caller wiring:
- no GameManager application pause/resume notification handling;
- no production background lifecycle hook;
- no production gameplay-pause hook invoking the bridge.

The probe directly calls the bridge methods, so it proves the state machine API, not actual production lifecycle behavior.

Locked timer authority requires the real session timer to:
- pause on legitimate gameplay pause;
- not drain while the application is legitimately backgrounded;
- resume correctly.

The production flow must invoke the bridge lifecycle methods.

## 7. What passed and must be preserved

Preserve:
- one session authority;
- immutable deep session snapshot;
- exact island/level identity;
- locked/nonexistent level rejection;
- one existing gameplay scene per active session;
- normal objective quantity ledger;
- duplicate delivery idempotency;
- timeout single-resolution behavior;
- optional VIP not gating normal win;
- WIN-only progression;
- replay monotonicity;
- Retry / Next / Island Map routing;
- stored matching To-Go delivery behavior;
- unchanged R11 physics/table constants;
- no M15/M16 scope expansion.

## 8. Historical R11 probe note

Builder truthfully reported parser failures in several old R10/M06-era probes.

The accepted R11 audit explicitly marks rejected full-silhouette R10 contracts as superseded historical evidence and says they must not block the current table-footprint solution.

Therefore this audit does **not** require rewriting historical probes merely to manufacture green results.

Current physics preservation remains evidenced by:
- unchanged accepted physics constants;
- additive GameManager campaign hooks;
- passing M02/M03/M08 regressions;
- accepted R11 source authority remaining untouched.

## 9. Required remediation

1. Compose CampaignNavigationScene into the real executable app entry flow.
   - Normal application boot must enter the campaign navigation flow, not direct gameplay.
   - M13 level selection must reach M14 gameplay without a test manually instantiating the router.
   - Continue reusing the existing `scenes/main.tscn` as the gameplay implementation inside the session flow.

2. Correct star derivation to the locked contract.
   - High score without VIP must not yield 3 stars.
   - VIP alone or configured 2-star mastery may yield 2.
   - 3 requires VIP + configured 3-star score mastery.
   - Update replay/monotonic tests accordingly.

3. Wire production timer lifecycle.
   - Application background/pause/resume must notify the active bridge.
   - Legitimate gameplay pause/resume must have a production-facing hook into the bridge.
   - Preserve the user's pause if an app-background resume occurs; do not accidentally resume a separately paused session.

4. Strengthen M14 probe.
   - prove actual project/app entry composes CampaignNavigationScene;
   - prove real production navigation enters gameplay;
   - prove app background lifecycle freezes/resumes timer through production hook;
   - prove gameplay pause through production hook;
   - prove score-only + VIP-incomplete cannot produce 3 stars;
   - prove VIP + score mastery can produce 3 stars;
   - preserve all existing M14 assertions.

5. Re-run M14 twice after import and M10/M11/M12/M13/M02/M03/M08 regressions.

6. Do not modify historical superseded R10 probes merely to force them green.

7. Do not edit root `TASKS.md`.

## 10. Final verdict

**CHANGES_REQUIRED**

M14 remains open.
