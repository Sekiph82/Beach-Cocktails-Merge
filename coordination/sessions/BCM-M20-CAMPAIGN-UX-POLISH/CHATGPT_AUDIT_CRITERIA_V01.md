# BCM-M20 V01 — Locked Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- root `TASKS.md`;
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`;
- M19 closure `coordination/sessions/BCM-M19-MULTI-ISLAND-SCALABILITY/CHATGPT_AUDIT_V01_R01.md`.

## A — governance

- Work only on clean synchronized `main`.
- Execute Children 01→06 strictly in order.
- Each child must publish its own implementation/evidence commit and prove clean local/origin/remote equality before the next child begins.
- CODEX must not edit root `TASKS.md`.
- Preserve M19 and all accepted M01-M19 gameplay/campaign contracts.
- Do not start M21.
- No character system, renovation meta, heavy animation meta-game, ads, purchases, analytics, account/backend, or unrelated economy work.

## B — M20-001 app shell / main menu

Create one reusable application shell above the existing campaign navigation.

Required:
- project boot enters a Main Menu shell, not directly gameplay/map;
- Main Menu offers at minimum PLAY/CONTINUE and SETTINGS;
- PLAY/CONTINUE enters the existing campaign flow without resetting progress;
- returning from World Map can return to Main Menu without destroying campaign/save authority;
- only one live CampaignNavigation instance exists;
- no duplicated CampaignManager/SaveManager/GameEconomy authority;
- 720×1280 portrait layout remains the reference;
- existing campaign save is loaded exactly as before.

## C — M20-002 first-run onboarding

Add a minimal first-run onboarding flow covering:
1. World Map / choose unlocked island;
2. Island Map / choose unlocked level;
3. timed normal To-Go objective;
4. VIP is optional;
5. completion/stars/replay basics.

Required:
- shown on true first run only;
- skippable;
- completion/skip persists;
- returning users are not forced through it;
- onboarding never mutates campaign progression;
- no tutorial character system or animation-heavy scene tree.

## D — M20-003 settings / accessibility

Add a separate user-settings persistence boundary, independent from campaign progression.

Minimum settings:
- master audio level/mute;
- music level/mute;
- SFX level/mute;
- haptics enabled;
- reduced motion;
- high-contrast/readability mode.

Requirements:
- safe defaults;
- settings persist across restart;
- corrupt/missing settings fall back safely without touching campaign save;
- audio controls use existing AudioServer buses where available and degrade safely if a named bus is absent;
- haptic calls must be gated by the setting;
- reduced-motion/high-contrast values are exposed to UI/gameplay presentation boundaries without changing core gameplay math;
- no campaign-save schema bump solely for preferences.

## E — M20-004 pause / lifecycle

Use the existing GameplaySessionBridge timer authority.

Required:
- visible in-game pause control;
- pause overlay with Resume and Island Map actions;
- manual pause freezes timer;
- backgrounding freezes timer;
- resume after background only auto-resumes a session paused specifically by backgrounding;
- a manually paused session remains manually paused after background/resume;
- pause cannot duplicate gameplay/session/map instances;
- leaving to Island Map does not advance progression or grant win rewards;
- terminal session cannot be resumed.

## F — M20-005 concise campaign UX

Provide concise reusable UI for:
- locked-island feedback;
- locked-level feedback where applicable;
- milestone/reward feedback;
- win result;
- lose result.

Result UI must expose only relevant existing actions:
- WIN: Next Level when available, Island Map;
- LOSE: Retry, Island Map.

Requirements:
- stars/best score/reward feedback use authoritative state;
- no new progression gate;
- no VIP requirement for normal win;
- no ad/purchase continuation in M20;
- no character/renovation/meta systems;
- no duplicate result overlays.

Runtime capture evidence is required at 720×1280 for at least:
1. Main Menu;
2. first-run onboarding;
3. Settings;
4. Pause overlay;
5. locked feedback;
6. WIN result;
7. LOSE result.

## G — M20-006 migration/backward compatibility

Prove existing players can update without losing campaign progress.

Required:
- current schema save loads unchanged;
- v1→current migration remains valid;
- M15/M18 fields survive load/write/reload;
- legacy best score migration remains valid;
- corrupt primary + valid backup recovery remains valid;
- unsupported future schema remains non-destructive;
- missing/corrupt settings never reset campaign state;
- onboarding/settings persistence is independent from campaign save;
- no developer/test-only progression bypass is introduced.

## H — final regression

After Child 06 publication equality, run:
- all M20 focused probes;
- M10-M19 relevant campaign probes;
- M18 reward/replay/integration probes;
- protected M01/M02/M03/M07-R06/M08/M09;
- Godot import/parse;
- `git diff --check`;
- root `TASKS.md` freeze proof.

M07-R04 may retain its already documented pre-existing headless capture limitation; M07-R06 must remain PASS.

Master successful marker:

`AWAITING_M20_AUDIT_V01`

Any failed ordered-publication gate, material visual/capture omission, progression regression, save loss, product-scope violation, or unverified material criterion is `CHANGES_REQUIRED`.
