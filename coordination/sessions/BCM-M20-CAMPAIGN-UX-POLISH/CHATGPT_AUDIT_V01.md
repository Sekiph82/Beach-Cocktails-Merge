# BCM-M20 V01 — Independent Audit

Verdict: **AUDITED_PASS / M20 CLOSED**

Auditor: ChatGPT  
Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`  
Audited handoff HEAD: `55ddf42269724ae7bc3db4d6b5c7af8ab5f52633`

## 1. Locked authority

Audit authority:
- `CHATGPT_AUDIT_CRITERIA_V01.md`
- six locked child criteria
- M19 accepted architecture
- `coordination/AUDIT_POLICY.md`
- actual repository history/source/capture evidence.

## 2. Ordered publication integrity

The repository history independently confirms the required sequence.

Each child has:
1. an implementation commit;
2. a following child-log publication commit;
3. the next child's implementation commit only after that publication commit.

Exact chain:
- M20-001 implementation `62adc9c...` → publication `192a932...`
- M20-002 implementation `da81a5f...` → publication `de6458f...`
- M20-003 implementation `6e05a8c...` → publication `82fd1e9...`
- M20-004 implementation `902627a...` → publication `5c0c1e3...`
- M20-005 implementation `e1c2ab0...` → publication `917bc8c...`
- M20-006 implementation `9c9005b...` → publication `27601ec...`
- master handoff `55ddf42269724ae7bc3db4d6b5c7af8ab5f52633`.

No child-order or publication-gate violation is present.

## 3. BCM-M20-001 — App Shell / Main Menu

PASS.

- `project.godot` boots through `ApplicationShellScene`.
- Main Menu exposes PLAY / CONTINUE and SETTINGS.
- one CampaignNavigationController instance is owned by the shell;
- campaign/save/economy/session authorities remain inside the accepted campaign architecture;
- World Map return emits an application-level main-menu request rather than creating another navigation authority;
- focused probe covers boot/menu/campaign transitions, instance count, and progression preservation.

## 4. BCM-M20-002 — First-run onboarding

PASS.

- exactly five concise onboarding pages cover:
  1. World Map;
  2. Island Map;
  3. timed normal To-Go;
  4. optional VIP;
  5. wins/stars/replay.
- skip and completion persist to independent `user://onboarding_state.json`;
- returning users are not forced through the flow;
- reset is explicitly onboarding-only for QA;
- campaign state is not mutated by onboarding.

## 5. BCM-M20-003 — Settings / accessibility boundary

PASS.

A dedicated `UserSettings` store exists independently from campaign save.

Implemented/persisted:
- master volume + mute;
- music volume + mute;
- SFX volume + mute;
- haptics;
- reduced motion;
- high contrast.

Independent source/test inspection confirms:
- missing/corrupt settings safely default;
- absent AudioServer buses fail safely;
- haptic feedback is setting-gated;
- reduced-motion/high-contrast/haptic values are exposed through the presentation-state boundary and applied to active gameplay without changing gameplay math;
- settings changes do not alter campaign progression/save schema.

## 6. BCM-M20-004 — Pause / lifecycle

PASS.

The existing GameplaySessionBridge remains the timer authority.

Focused production-path evidence proves:
- visible pause control;
- Resume + Island Map overlay;
- manual pause freezes timer;
- background pause freezes timer;
- manually paused session does not auto-resume after background/resume;
- background-paused session does resume correctly;
- terminal sessions cannot resume;
- pause-to-map grants no completion/reward;
- no gameplay/map/session duplication.

## 7. BCM-M20-005 — Campaign UX

PASS.

A single reusable `CampaignFeedbackOverlay` handles:
- locked island;
- locked level;
- milestone/reward;
- WIN;
- LOSE.

WIN actions:
- NEXT LEVEL only when available;
- ISLAND MAP.

LOSE actions:
- RETRY;
- ISLAND MAP.

No ad/purchase continuation or VIP completion gate was introduced.

### Independent visual inspection

Seven committed production captures were independently inspected. PNG headers confirm every image is exactly **720×1280**:

1. onboarding;
2. Main Menu;
3. Settings;
4. locked feedback;
5. pause;
6. LOSE result;
7. WIN result.

The captures are readable, unclipped at the canonical viewport, and correspond to the requested runtime states.

The capture harness uses the production App Shell, World Map, Island Map, gameplay scene, GameplaySessionBridge, and real delivery/session result path. The WIN capture is not a mock result injection.

Observation only:
the terminal overlay is authoritative, while the obscured gameplay HUD beneath it can still show pre-terminal values. This is not a locked M20 failure because the overlay owns terminal interaction/state and blocks gameplay. Carry this as a visual-polish observation into M21 mobile QA.

## 8. BCM-M20-006 — Migration / backward compatibility

PASS.

The migration probe materially verifies:
- current save round trip;
- v1→current migration;
- M15/M18 stars/best score/reward fields;
- legacy best-score migration;
- corrupt-primary / valid-backup recovery;
- unsupported future schema non-destructive handling;
- onboarding/settings storage isolation;
- corrupt settings do not alter campaign bytes.

No campaign schema bump was introduced merely for user preferences.

## 9. M17 historical-probe note

Builder evidence reports `tests/m17_canonical_screening_probe.gd` failing old VIP-second fixture assertions.

This is **not a new M20 regression**.

The M17 V05 locked contract explicitly marks V04 physical screening as:

`PRE_OPTIONALITY_FIX / HISTORICAL FOR PHYSICAL CLASSIFICATION`

V05 intentionally changed VIP capture semantics so mandatory reserve is protected and VIP is only captured from surplus material.

The current accepted M17 boundaries are represented by post-V05 optionality and analytical probes, which remain PASS in the M20 regression evidence.

Therefore the old V04-style canonical-screening fixture is obsolete for current VIP routing and does not block M20 acceptance.

## 10. Scope / tracker integrity

Compare from M20 start `d6d5e969...` to handoff `55ddf422...`:
- contains only M20 shell/settings/pause/UX/test/evidence changes plus the required project main-scene change and bounded updates to existing campaign/gameplay presentation wiring;
- no campaign level data retune;
- no M21 files;
- no ads/purchases/backend/character/meta system;
- root `TASKS.md` is byte-identical:
  `b886f9922c0280513dbb9692e1fc55efa9eefd60`.

## 11. Regression interpretation

Builder evidence records PASS for:
- all M20 focused probes;
- M10-M16;
- accepted post-V05 M17 boundaries;
- M18 reward/replay/integration;
- M19 scalability and ordered selectors;
- M01/M02/M03/M07-R06/M08/M09;
- GUI M18 replay capture;
- Godot import/parse;
- `git diff --check`.

The documented M07-R04 limitation remains historical and M07-R06 remains PASS.

## 12. Final verdict

**AUDITED_PASS.**

BCM-M20-001 through BCM-M20-006 are accepted. **M20 is closed.**

M21 may begin only from the newly issued ChatGPT release-closure package.

M21 must explicitly carry:
- mobile/touch/device QA;
- performance profiling;
- fresh-save L1→L100 progression;
- full accepted legacy gameplay regression;
- export/release persistence checks;
- owner-native final acceptance before v1 release-ready closure.
