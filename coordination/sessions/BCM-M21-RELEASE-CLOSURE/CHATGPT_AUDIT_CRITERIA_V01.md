# BCM-M21 V01 — Locked Release-Closure Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- root `TASKS.md`;
- M20 closure `coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/CHATGPT_AUDIT_V01.md`;
- accepted M01-M20 milestone contracts.

## A — governance and ordered publication

- Work only on clean synchronized `main`.
- Execute Children 01→06 strictly in order.
- Every child must have a separate implementation/evidence publication and clean local/origin/remote equality before the next child begins.
- CODEX must not edit root `TASKS.md`.
- No new gameplay/content feature scope is authorized in M21.
- No timer/objective/VIP/reward/economy/physics/table/HUD redesign, new island content, ads, purchases, analytics, account/backend, or meta systems.
- Defects discovered by QA may be fixed only if they are within the currently executing child and the fix is narrowly necessary for that child; any larger design/content change must stop for a new ChatGPT remediation contract.

## B — M21-001 mobile layout / touch QA

Validate the production App Shell, World Map, Island Map, gameplay, pause, result, locked feedback, Settings, and onboarding surfaces under the canonical mobile viewport and representative tall-phone presentation.

Required automated/proxy evidence:
- canonical 720×1280 production captures for all major surfaces;
- at least one representative taller phone/window presentation proving no crop/interaction loss under the project's stretch/aspect configuration;
- touch-path tests for Main Menu PLAY, World Map island selection, Island Map level selection/scroll, pause/resume, result actions, and settings toggles using production controls;
- no horizontal clipping or unreachable required control;
- Island Map remains vertically scrollable across 100 levels;
- no duplicate map/gameplay/result instances after repeated navigation.

This child is a desktop/mobile-layout proxy. Physical-device touch/visual acceptance remains a separate owner gate in M21-006 and must not be fabricated.

## C — M21-002 performance / stability profile

Create immutable profiling evidence for:
- World Map node count;
- 100-level Island Map node/button count;
- repeated Island Map open/close and scroll cycles;
- repeated gameplay launch/return cycles;
- campaign save write/read timing;
- settings/onboarding IO timing;
- memory/object-count trend before and after repeated navigation;
- gameplay frame-time sample where available.

Required:
- no unbounded node/instance growth;
- no duplicate gameplay/map/result overlays;
- no progressively increasing save payload;
- no obvious memory leak trend in the bounded run;
- report exact environment and measured values rather than inventing a target-device result.

Physical target-device performance remains an owner-native closure gate.

## D — M21-003 full campaign progression

From a fresh campaign state, exercise the production campaign/session/progression path through Sunny Cove Level 1→100.

Required:
- all 100 levels complete normally without requiring VIP;
- per-level completion persists;
- checkpoints include save/reload at minimum after L1, L25, L50, L75, and L100;
- stars/best score remain bounded/monotonic;
- cumulative-star rewards remain duplicate-safe;
- Tiki remains locked through L99;
- Tiki unlocks after L100;
- Tiki remains zero-level/unplayable in this release;
- final state survives restart;
- no debug/developer progression bypass is used.

A deterministic harness may satisfy orders through the existing GameplaySessionBridge/runtime APIs; direct mutation of completion dictionaries is not acceptable as the primary proof.

## E — M21-004 accepted legacy regression

Run the complete accepted gameplay/campaign regression set.

At minimum:
- M01/M02/M03;
- M07-R06 owner-layout boundary;
- M08/M09;
- M10-M16;
- current accepted M17 boundaries:
  - V05 VIP optionality;
  - V06 analytical post-V05 screening;
  - latest accepted M17 confirmation/evidence checks that are runnable without rewriting historical reports;
- M18 reward/star/replay/integration;
- M19 scalability + ordered verification selectors;
- M20 focused probes + runtime capture probe.

Do **not** treat the historical pre-V05 `m17_canonical_screening_probe.gd` VIP-second assertions as a current acceptance test; they are explicitly historical after V05.

M07-R04 may retain its documented historical limitation; M07-R06 must PASS.

No required accepted regression may be skipped silently.

## F — M21-005 export / persistence / release configuration

Create or validate release/export configuration without committing secrets.

Required:
- project main scene is the production App Shell;
- release build excludes/does not expose test-only progression bypasses;
- persistent campaign/settings/onboarding paths remain `user://` and survive application restart in release-mode smoke testing;
- no hard-coded developer save reset on boot;
- production artifact/preset validation is attempted with the toolchains actually available;
- if Android/mobile export templates or SDKs are unavailable, record exact limitation rather than fabricating PASS;
- never commit keystores, signing passwords, provisioning profiles, certificates, API secrets, or local SDK paths;
- produce a release candidate manifest containing Git SHA, Godot version, export/preset status, artifact hashes for any generated distributable, save schema, known limitations, and reproducible commands.

Unavailable platform signing/toolchains do not by themselves invalidate the codebase, but they remain explicit release-gate items for owner-native closure.

## G — M21-006 release closure package

After Children 01-05 publication equality:
- rerun final smoke/regression subset;
- verify clean worktree and local/origin/remote equality;
- verify root `TASKS.md` unchanged by CODEX;
- verify no test-only progression bypass is reachable in production UI;
- assemble one release-readiness report summarizing technical PASS/FAIL/UNVERIFIED items;
- include links/paths to mobile-layout captures, performance report, full-progression report, regression log, export manifest, and known limitations.

### Owner-native gate

CODEX must **not** claim final v1 release acceptance.

The release-readiness report must contain an owner-native checklist for a real target mobile device covering:
1. launch to onboarding/Main Menu;
2. PLAY → World Map → Island Map → gameplay;
3. touch/scroll/button usability;
4. pause/background/resume;
5. Settings persistence;
6. WIN/LOSE flow;
7. app restart persistence;
8. visual clipping/readability;
9. obvious performance/stutter;
10. installation/export artifact where available.

Final v1 release-ready closure requires independent ChatGPT audit plus explicit owner-native acceptance. Until then the technical handoff remains pending final acceptance.

## H — required final checks

After Child 06:
- Godot import/parse;
- `git diff --check`;
- release candidate manifest integrity;
- root `TASKS.md` freeze proof;
- no M22/future feature work.

Successful builder marker:

`AWAITING_M21_AUDIT_V01`

Any out-of-order publication, hidden required regression failure, product-scope drift, fabricated device/export claim, save-loss risk, missing release evidence, or missing equality proof is `CHANGES_REQUIRED`.
