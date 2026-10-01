# BCM-M21 V01 — Independent Audit

Verdict: **CHANGES_REQUIRED / EVIDENCE-CLOSURE-INCOMPLETE**

Auditor: ChatGPT  
Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`  
Audited builder handoff HEAD: `8d8cf5453f484647b37dd59c374c5327855b9eda`

## 1. Locked authority

Audit authority:
- `CHATGPT_AUDIT_CRITERIA_V01.md`;
- six M21 child criteria;
- M20 accepted closure;
- `coordination/AUDIT_POLICY.md`;
- actual repository history, source, reports, manifests, and committed capture evidence.

M21 is a release-validation milestone. Final v1 release-ready closure additionally requires explicit owner-native acceptance on a real target device/release environment.

## 2. Ordered publication integrity — PASS

Repository history independently confirms the six-child publication order.

- M21-001 implementation `698eedaca007903ea6dca396037e33ee7bd5908f`
  → child evidence publication `2db11aeee3fc661602eccc8721b52c46031e1033`.
- M21-002 implementation `4effe66b58ea62261bea2f804a25da365804ea56`
  → publication `9e18b5627b1a3c81a7d988b7269541e677341a39`.
- M21-003 implementation `cff1024f29962b5293ce898a045c49011e41f07d`
  → publication `5e484d281801329a150af0cbaea35dda4d883c5b`.
- M21-004 evidence `0feca0fd3caa86f4a88c910375ef9f6229575b9c`
  → child log `ba37c661d2187da814859805930173496fa486cf`
  → publication record `9bcd96534fb5d6cb08b80864b3f4fb60d3cdb250`.
- M21-005 evidence `b1604a2c752712feba7eb113fbfedf4d3d1ec368`
  → child log `0316a4e0ff98f8209d96785f05f2907b917d953d`
  → publication record `25591f26c9fdd03ac4a2d3ab7e935b785a1e7e46`.
- M21-006 closure publication `741b2a21f121e7caa9e9798b9b53fd8fc5557472`.
- master handoff `8d8cf5453f484647b37dd59c374c5327855b9eda`.

No out-of-order publication gate failure is present.

## 3. Scope / tracker integrity — PASS

Compare from M21 start:
`2dee27501e692a21ae0cca9ebaf69b938bd8711c`

to builder handoff:
`8d8cf5453f484647b37dd59c374c5327855b9eda`

shows evidence/test/report additions plus one bounded production layout correction in:
`scripts/campaign/island_map_controller.gd`.

Independent before/after source inspection confirms the functional change is:
- `PanelContainer.new()` → `Panel.new()`;
- comments explaining preservation of explicitly positioned header controls.

No campaign data, progression, timer, reward, economy, physics, table, content, or future-feature work was added.

Root `TASKS.md` Git blob is byte-identical at M21 start and final handoff:
`c8dd960e6efb47fefd35539baa7067673e8d0aa3`.

## 4. BCM-M21-001 mobile layout / touch proxy — TECHNICAL PASS, VISUAL AUDIT INCOMPLETE

The production-path mobile QA probe is substantive and covers:
- first-run onboarding controls;
- Main Menu PLAY;
- Settings and toggle;
- World Map island controls and clipping report;
- locked-island feedback;
- 100-level Island Map with vertical scroll;
- level selection;
- gameplay;
- pause/resume;
- LOSE/RETRY;
- WIN/Island Map;
- repeated-instance bounds;
- tall 720×1440 World Map / Island Map / gameplay.

Structured evidence records:
- 11 canonical captures at 720×1280;
- 3 tall captures at 720×1440;
- no failed probe checks;
- real GL Compatibility renderer;
- physical device explicitly deferred.

Independent visual inspection succeeded for repository captures that the connector returned directly, including onboarding, Main Menu, and Settings. They are readable and unclipped.

However several larger committed PNGs are not returned as image bytes by the available GitHub connector due binary-size transport limits. Under the locked audit policy, visual acceptance may not be inferred solely from dimensions, builder prose, or probe assertions.

Therefore M21-001 cannot yet receive unconditional independent visual PASS.

Required R01 evidence:
- preserve all original production PNGs byte-for-byte;
- add connector-readable audit-review copies derived from those originals;
- same dimensions, no crop/re-layout/edit, only bounded image re-encoding/compression;
- add a provenance manifest mapping each original SHA-256 to its review copy SHA-256, dimensions, and source path.

## 5. BCM-M21-002 performance / stability profile — PASS

The profile probe materially measures:
- World Map entries/nodes;
- 100 Island Map buttons;
- 12 repeated map cycles;
- 8 repeated gameplay cycles;
- 20 campaign save IO cycles;
- 20 settings IO cycles;
- 20 onboarding IO cycles;
- object/orphan-node trends;
- 60 frame-time samples.

Evidence reports:
- map instance count remains 2;
- gameplay instance disposed after each cycle;
- 100 level buttons remain stable;
- zero orphan nodes in all samples;
- stable save payload at 301 bytes in the bounded IO loop;
- no unbounded object growth within the defined run;
- desktop GL Compatibility environment clearly identified;
- physical target-device performance explicitly left to owner-native gate.

This satisfies the locked technical proxy boundary.

## 6. BCM-M21-003 full fresh-save L1→L100 progression — PASS

Independent source inspection confirms `tests/m21_full_progression_probe.gd` does not directly mutate completion dictionaries as its primary proof.

For each level it:
1. opens Sunny Cove through the production router;
2. selects the production LevelButton;
3. starts the production GameplaySessionBridge session;
4. satisfies normal To-Go orders via `record_to_go_delivery()`;
5. receives a terminal WIN;
6. reads authoritative CampaignManager progression;
7. returns via the production result action.

Checkpoint save/reload occurs at L1/L25/L50/L75/L100 through SaveManager.

Structured evidence confirms:
- levels 1..100 completed;
- 100 persisted completion records;
- cumulative stars monotonic and bounded;
- reward claims unique;
- Tiki locked before L100 checkpoints and unlocked after L100;
- Tiki remains level_count 0 and unplayable;
- final state survives restart;
- save schema version 2;
- no debug progression bypass.

## 7. BCM-M21-004 accepted regression — PASS

The committed regression matrix contains **33 / 33 PASS** with native exit code 0 and required markers.

It covers:
- M01/M02/M03;
- M07-R06;
- M08/M09;
- M10-M16;
- accepted post-V05 M17 boundaries;
- current M18 reward/star/replay/integration;
- M19 scalability and all ordered R01 selectors;
- M20 production runtime capture path.

Historical exclusions are explicit and contract-compliant:
- pre-V05 `m17_canonical_screening_probe.gd` not treated as current acceptance;
- M07-R04 historical limitation excluded in favor of required M07-R06;
- historical V07-R03 report checked read-only rather than rewriting it.

No accepted regression was silently hidden by the runner evidence inspected.

## 8. BCM-M21-005 export / persistence — FUNCTIONAL PASS, RELEASE MANIFEST INCOMPLETE

PASS findings:
- production main scene is ApplicationShell;
- no reachable debug progression bypass in production shell controls;
- production-path persistence smoke passes across restart for onboarding/settings/campaign save;
- Godot 4.7.2 import/editor smoke passes;
- unavailable export/signing/mobile tooling is truthfully reported;
- no distributable or artifact hash is falsely claimed;
- no secrets/local SDK paths are evidenced.

The absence of `export_presets.cfg` is truthfully reported. The Child 05 locked criteria permit unavailable tooling/configuration to remain explicit rather than fabricated.

### Material evidence defect

The master locked criterion requires the release candidate manifest to contain:
- Git SHA;
- Godot version;
- export/preset status;
- artifact hashes for generated distributables;
- save schema;
- known limitations;
- reproducible commands.

The current V01 JSON/Markdown manifest includes Godot version, export/preset status, null artifact hash, limitations, and commands, but **does not explicitly contain the release candidate Git SHA or campaign save schema version**.

Those values exist elsewhere in the M21 evidence (`8d8cf545...` and schema `2`), but the locked contract explicitly requires them inside the release manifest.

This is an evidence-completeness failure, not a product-code defect.

## 9. BCM-M21-006 technical closure — PENDING

The technical closure package is well formed and:
- reports clean worktree/equality;
- preserves tracker;
- lists evidence paths;
- states export/signing/device limitations truthfully;
- includes an owner-native checklist;
- does not claim final v1 acceptance.

However M21-006 cannot close until:
1. the M21-001 visual evidence is independently inspectable;
2. the M21-005 manifest metadata is complete;
3. independent R01 audit passes;
4. explicit owner-native acceptance is received.

## 10. Final verdict

**CHANGES_REQUIRED / BOUNDED V01-R01 EVIDENCE REMEDIATION REQUIRED**

No M21 product/gameplay remediation is authorized.

R01 must do only:
1. publish a supplemental release manifest containing the missing Git SHA and save schema plus the already-required release metadata;
2. publish audit-readable review copies of all 14 existing M21 mobile captures, derived from the unchanged originals with provenance;
3. prove original M21 captures and all product/source files remain unchanged;
4. preserve all V01 logs/reports/manifests as historical evidence;
5. stop at `AWAITING_M21_AUDIT_V01_R01`.

After R01 independent PASS, the only remaining v1 closure gate should be explicit owner-native mobile/release acceptance.
