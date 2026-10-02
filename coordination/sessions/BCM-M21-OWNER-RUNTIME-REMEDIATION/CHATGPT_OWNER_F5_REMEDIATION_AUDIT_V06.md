# BCM-M21 Owner F5 Remediation V06 — Independent Audit

Verdict: **TECHNICAL_AUDITED_PASS / OWNER_F5_ACCEPTANCE_REQUIRED**

Auditor: ChatGPT
Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `main`
Audited product HEAD: `82166db6bed433535707623131936daad9820133`

## 1. Scope

Active tasks:
- BCM-M21-001
- BCM-M21-006

BCM-M21-004 remains closed.

Authority:
- `OWNER_F5_RULING_V06.md`
- `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V06.md`
- current source, runtime reports, calibration/provenance data and builder logs.

## 2. Sunny Cove composite migration — PASS

Committed production file:
`assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface.png`

Provenance records:
- exact 720×1280 output;
- deterministic builder;
- source SHA-256 values;
- exact layer order;
- exact transforms;
- final output SHA-256 `b8c4fdbeb43e34f823eb56e3d35fb6b769090efcb5749ec2bc020cace9891af0`.

Runtime source inspection confirms:
- Sunny Cove selects `gameplay_surface` + `playable_geometry`;
- `table_y_offset_canonical` is forced to 0;
- the composite branch configures geometry and returns before legacy layered rendering;
- legacy table/shadow/edge rendering remains only as fallback for non-migrated islands.

Runtime texture inventory contains one static Sunny Cove scene node:
- `GameplaySurface` at z=-100.

No active `CampaignTable`, `CampaignTableShadow`, or `CampaignTableEdgeOverlay` appears in the Sunny Cove runtime inventory.

## 3. Image-locked playable geometry — PASS technically

Sunny Cove geometry is stored in canonical 720×1280 pixels and contains:
- 12-point `playable_polygon`;
- `launch_y = 950`;
- `spawn_y = 968`;
- `death_y = 1008`.

Current GameManager derives profile walls, bounds queries, projection/clamping, spawn placement, launch and death behavior from the active geometry when present.

Runtime report confirms:
- active geometry equals island `playable_geometry`;
- profile boundary edges match polygon vertices;
- held launch glass aligns to image-locked spawn_y;
- launch line uses the profile;
- legacy Y offset is inactive.

The stress calibration includes L1-L12 representative footprints. Runtime probe reports 12 real stress drinks instantiated inside the profile.

Final subjective image/physics alignment remains an owner visual gate.

## 4. World Map calibration — PASS technically / OWNER VISUAL GATE

A committed calibration report contains all ten islands with:
- final canonical pixel center;
- normalized center;
- per-island visual asset reference and SHA-256;
- documented calibration method;
- estimated manual-anchor uncertainty <= 12 canonical px;
- marker/entry/art/lock sharing one `map_position`.

The builder documents why pixel-identical RGB template matching is not applicable: per-island assets are identity portraits, not baked-map crops. Manual anchors are therefore used against the canonical baked map.

Runtime report resolves all ten centers from current `islands.json`.

No duplicate island thumbnail or runtime route line is required by the active contract.

Because the GitHub connector did not expose the committed PNG bytes for direct independent visual inspection in this audit session, marker visual centering is **not owner-accepted by this audit**. Manual F5 inspection remains mandatory.

## 5. Sunny Cove Island Map preservation — PASS

V06 did not alter the accepted Sunny Cove landmark layout contract.

Runtime evidence confirms:
- repeated landmark mapping through L100;
- selected page behavior remains valid;
- connector lines remain absent.

## 6. Input / timer / result preservation — PASS

Gameplay probe:
- mouse 10/10;
- touch 10/10;
- direct ShotController launch calls = 0;
- no timer;
- one-hour untimed survival PASS;
- pause/resume PASS;
- terminal WIN hides all active drinks;
- visible transient effects = 0;
- result surface appears once and blocks gameplay input.

GUI probe:
- 15 real viewport GUI clicks;
- Main Menu PLAY PASS;
- SETTINGS PASS;
- BACK TO MENU PASS;
- World Map / Sunny Cove / Level 1 navigation PASS;
- Next Level PASS;
- result Island Map PASS;
- post-result PLAY/SETTINGS PASS.

Runtime logs contain:
- `ERROR:` = 0;
- `SCRIPT ERROR:` = 0.

Persistence/import and `git diff --check` are reported PASS.

## 7. Repository integrity — PASS

Builder handoff reports:
- implementation/evidence commit `1315ed60b332a8115562f53412dec082fe2265d5`;
- closeout commit `82166db6bed433535707623131936daad9820133`;
- local HEAD = origin/main = remote main;
- root `TASKS.md` unchanged by CODEX;
- existing preservation stash retained;
- 14 generated translation sidecars untouched.

## 8. Independent-audit limitation

The current GitHub connector exposed PNG identities/hashes but not decodable image payloads for the V06 screenshots in this audit session.

Therefore this audit validates source, configuration, runtime reports, tests, geometry/calibration artifacts and repository integrity, but does not replace owner visual inspection of:
- World Map marker centering;
- composite table appearance;
- crowded/12-glass visual containment.

## 9. Final verdict

**TECHNICAL_AUDITED_PASS.**

No further CODEX remediation is authorized unless owner F5 V06 identifies a defect.

- BCM-M21-001 remains pending owner manual visual/runtime acceptance.
- BCM-M21-006 remains pending owner acceptance and final release closure.
- BCM-M21-004 remains CLOSED.

Next actor: **OWNER**.
