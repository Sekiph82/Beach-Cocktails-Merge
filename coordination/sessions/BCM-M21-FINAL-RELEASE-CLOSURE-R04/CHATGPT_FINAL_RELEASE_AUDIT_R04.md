# BCM-M21-006-R04 — Independent Final Release Audit

Date: 2026-10-08

## VERDICT

**AUDITED_PASS / BCM-M21 COMPLETE**

The R04 evidence-only closure satisfies the locked final release-evidence gate. BCM-M21 technical and owner-runtime closure is complete.

This verdict does **not** claim a signed/native distributable exists. The repository truthfully records that no `export_presets.cfg` is present, so no release package was generated. Physical-device performance, native installation, and signing remain unverified release-environment limitations rather than hidden PASS claims.

## Audited range

R04 authority baseline:
`663e68c5ed89a7325e8f16800acc57b386a59730`

R04 evidence publication commit:
`6c76741ea49ac2c084d05546b968871eba5f6498`

R04 builder log handoff / audited main:
`4dff38f3b7e8b7db5ecdf52f00d681cc8e370c49`

Current GitHub `main` matches the builder handoff SHA.

## Scope integrity

**PASS**

The R04 diff contains evidence and documentation only.

No files under product/runtime/test/asset authority were modified:
- no `scripts/`;
- no `scenes/`;
- no `tests/`;
- no `data/`;
- no `assets/`;
- no `project.godot`;
- no root `TASKS.md` edit by Codex.

M22 was not started.

## Evidence publication integrity

**PASS**

R04 publishes **31** previously ignored R03 command logs as commit-eligible `.txt` files.

`source_log_sha256.json` records, for every source/copy pair:
- source SHA-256;
- committed-copy SHA-256;
- `identical=true`;
- explicit `EXIT_CODE=0`.

All 31 source/copy digest pairs match.

`COMMAND_INDEX.txt` maps each committed evidence file to the exact command that produced it.

Only the missing historical `git diff --check` output was rerun in R04, as permitted by the locked criteria.

## M07 HUD authority

**PASS**

Published final evidence exists for:
- R04 focused HUD;
- R05 HUD adaptation;
- current HUD composition;
- R06 owner layout.

The earlier stale score-recess coordinate defect was corrected by scaling source-panel recess geometry to actual runtime panel dimensions.

The important constraints remain intact:
- center bound remains **1.5 px**;
- containment bound remains **4 px**;
- no tolerance inflation was used to manufacture PASS;
- retired production APIs were not reintroduced.

## M08 process / teardown closure

**PASS**

Two consecutive normal-renderer runs are now independently inspectable:

- `m08_normal_run_3.txt`
- `m08_normal_run_4.txt`

Both contain:
- `M08_TO_GO_DELIVERY_RESULT=PASS`;
- `EXIT_CODE=0`;
- successful merge/delivery/cleanup assertions;
- no access-violation marker;
- no `SCRIPT ERROR`;
- no teardown `ERROR`.

The prior PASS-marker/nonzero-process defect is therefore closed.

## R09 / V05 real-input navigation

**PASS**

Two consecutive published runs contain:

`M21_WORLD_MAP_PRODUCTION_V05_RESULT=PASS captures=7 mouse=PASS touch=PASS`

with `EXIT_CODE=0`.

The evidence covers:
- Home → World Map;
- Sunny Cove mouse entry;
- Island Map Back → World Map;
- Sunny Cove touch entry;
- touch Back → World Map;
- map-instance reuse;
- World Map Back → Home.

This matches the owner's later manual confirmation of the Sunny Cove Back fix.

## R08 Home frontier

**PASS**

Published R08 evidence confirms the accepted Home frontier authority:
- Home top LEVEL;
- PLAY plaque;
- Home PLAY action

all resolve to the same campaign frontier while old-level replay remains available from Island Map.

## R07 Island Map / stars / background

**PASS**

Published evidence covers:
- ten-level automatic frontier-page focus;
- readable LV/star node presentation;
- Sunny Cove full 720×1280 background;
- current star/mastery behavior.

No R04 product changes disturbed those accepted surfaces.

## M18 / M20 / gameplay regressions

**PASS**

Committed R04 evidence includes the current final outputs for:
- M18 star contract;
- replay persistence;
- cumulative star rewards;
- reward claim;
- M20 ApplicationShell;
- M01 contract;
- M02 physics;
- M03 economy/scoring;
- M09 audio/haptics;
- M13 Island Map;
- M14 GameplaySessionBridge;
- M15 VIP/boosters/economy;
- ten-island R04 gameplay-surface authority.

Each copied source log is recorded as exact-byte identical with an exit-0 source record.

## Fresh progression

**PASS**

The machine-readable progression report records:
- fresh save;
- save schema 2;
- levels 1–100 completed;
- completed count 100;
- Tiki unlocked after Sunny Cove Level 100;
- no debug progression bypass;
- `checks_failed=[]`.

## Performance / stability

**PASS as host profile**

The published report records:
- 12 map cycles;
- 8 gameplay cycles;
- 20 I/O cycles;
- 21 object/orphan samples;
- 60 frame samples;
- zero orphan nodes;
- Windows desktop / Intel Iris Xe / GL Compatibility.

It explicitly marks physical-device performance as unverified. No mobile-performance claim is fabricated.

## Save / restart persistence

**PASS**

The final persistence command evidence is published and exit 0.

The closure did not reset owner progression or introduce a production debug bypass.

## Asset / Godot startup

**PASS**

Published evidence covers:
- asset validation;
- Godot editor import/parse;
- normal headless project boot;
- `git diff --check`.

## project.godot metadata correction

**PASS**

R04 correctly resolves the R03 metadata ambiguity:

Canonical file SHA-256:
`DE79FF257F4F4BE0DBE01BECB574A3E502F9BF36F07CF662B293A4B6242D0267`

Git blob SHA-1:
`15a168304d729108313be58563592d50da1f99bf`

The historical R03 note had mislabeled the Git blob ID as SHA-256. R04 corrects the metadata without mutating historical evidence.

The canonical GameFeelFlow autoload remains repository-relative:
`res://addons/game_feel_flow/core/game_feel_flow.gd`.

## Release manifest

**PASS**

`release_manifest_r04.json` correctly separates:
- product baseline SHA;
- R03 implementation/evidence SHA;
- R03 builder handoff SHA;
- R04 evidence-publication identity via the builder log.

It truthfully records:
- Godot 4.7.2;
- save schema 2;
- ApplicationShell main scene;
- 720×1280 canonical viewport;
- no export preset;
- empty distributable artifact list;
- no physical-device/native-install/signing verification.

## Repository/ref proof

**PASS**

The committed final-Git snapshot after the evidence publication records:
- HEAD = origin/main = remote main at the evidence commit;
- ahead/behind 0/0;
- no tracked `project.godot` diff;
- no root `TASKS.md` diff;
- only two owner critique PNGs untracked;
- historical preservation stashes retained;
- no stash required to reproduce the canonical current working tree.

The subsequent builder-log-only commit advances GitHub main to:
`4dff38f3b7e8b7db5ecdf52f00d681cc8e370c49`.

The user handoff reports local/origin/remote parity at that final SHA, and current GitHub main independently confirms the same remote SHA.

## Known limitations

These are release-environment limitations, not hidden audit failures:

1. No `export_presets.cfg` exists.
2. No distributable/signed package was generated.
3. Physical-device performance remains unverified.
4. Native install/signing remains unverified.
5. Two owner critique PNGs remain intentionally untracked and outside release inputs.
6. Historical preservation stashes remain present but are not required for the canonical working tree.

## Final result

**BCM-M21-001: COMPLETE**

**BCM-M21-006: COMPLETE**

**BCM-M21: COMPLETE**

The next canonical roadmap item is **BCM-M22-001 — Lock exact installed GameFeelFlow + Saltmire Spark APIs, packaging, and graceful no-plugin behavior.**

The inactive Economy Draft V01 remains saved but is not activated by this audit.
