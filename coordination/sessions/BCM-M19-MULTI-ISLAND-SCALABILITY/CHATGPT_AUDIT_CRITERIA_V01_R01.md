# BCM-M19 V01-R01 — Locked Ordered-Verification Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `CHATGPT_AUDIT_V01.md`
- original M19 V01 master/child prompts and criteria
- M19 product implementation at audited handoff `4b04958ba3bcb7fcf5d02b4aa6b4ddefcf42796a`.

## A — remediation type

This is an **evidence/provenance remediation only**.

- Product implementation in `scripts/campaign/`, `data/campaign/`, and M19 policy docs is frozen.
- Canonical assets are frozen.
- Root `TASKS.md` is frozen for CODEX.
- Historical V01 logs/prompts/criteria/audit are immutable.
- M20 remains blocked.
- If any verification exposes a product defect, stop and report it. Do not repair product code inside V01-R01.

A test-only verification harness may be added if necessary to isolate child checks.

## B — setup gate

Before Child 01:
- sync clean `main`;
- record starting HEAD;
- if a new ordered verification harness is needed, create it in `tests/`, commit/push it first, verify local/origin/remote equality, then freeze its bytes for the child sequence;
- the harness must support executing exactly one requested child without executing later children.

No child result may be claimed from the old monolithic run alone.

## C — Child 01 gate

Run only BCM-M19-001 verification.

Verify:
- multi-root LevelDatabase loading;
- single-root backward compatibility;
- duplicate root/cross-island/count mismatch rejection;
- zero-level placeholder support;
- shared LevelDatabase/CampaignManager/SaveManager/WorldMap/IslandMap/GameplaySessionBridge/gameplay architecture.

Then:
- write `CODEX_LOG_V01_R01_CHILD_01.md`;
- commit/push that evidence;
- prove clean local/origin/remote equality.

Only after this publication gate may Child 02 execute.

## D — Child 02 gate

Run only BCM-M19-002 verification after Child 01 publication equality.

Verify:
- Tiki level_count 0;
- fresh and L99 locked;
- L100 one-star completion unlock;
- reload/idempotency;
- no Tiki gameplay session.

Publish `CODEX_LOG_V01_R01_CHILD_02.md` in its own later commit and prove equality before Child 03.

## E — Child 03 gate

Run only BCM-M19-003 verification after Child 02 publication equality.

Verify:
- Sunny L5-L8 and no L9 content;
- Tiki first declarative L9 island;
- no Tiki level content or exact L9 introduction level;
- data-first L1-L12 policy;
- no Tiki-specific gameplay/runtime branch.

Publish `CODEX_LOG_V01_R01_CHILD_03.md` in its own later commit and prove equality before Child 04.

## F — Child 04 gate

Run only BCM-M19-004 verification after Child 03 publication equality.

Verify exact ten-island order, unique contiguous indices, exact next chain, terminal `final_island`, and explicit TBD placeholder naming.

Publish `CODEX_LOG_V01_R01_CHILD_04.md` in its own later commit and prove equality before Child 05.

## G — Child 05 gate

Run only BCM-M19-005 verification after Child 04 publication equality.

Verify:
- all ten canonical islands expose the six required theme keys;
- every path exists and belongs to the matching approved island family;
- resolved theme is immutable;
- session bridge exposes theme;
- theme-less legacy fixture remains backward compatible;
- no canonical asset bytes changed.

Publish `CODEX_LOG_V01_R01_CHILD_05.md` in its own later commit and prove equality before Child 06.

## H — Child 06 gate

Run only BCM-M19-006 verification after Child 05 publication equality.

Verify:
- a third/new fixture island works through data + level data + existing asset reference(s);
- same database/campaign/save/map/session/gameplay architecture is reused;
- no island-specific runtime branch is required;
- no product code change was needed for this R01 verification.

Publish `CODEX_LOG_V01_R01_CHILD_06.md` in its own later commit and prove equality.

## I — final closure regression

Only after Child 06 publication equality:
- run the original full `m19_multi_island_scalability_probe.gd`;
- M10, M11, M12, M13, M14, M15, M16;
- M18 focused/integration probes;
- protected M01/M02/M03/M07-R06/M08/M09;
- M07-R04 may retain its documented pre-existing headless capture limitation and must not be treated as a new M19 regression if M07-R06 remains PASS;
- Godot import/parse;
- `git diff --check`;
- root `TASKS.md` freeze proof;
- product implementation hash/diff freeze proof from R01 start.

Create `CODEX_LOG_V01_R01.md` and publish it after all six child evidence commits.

Final successful marker:

`AWAITING_M19_AUDIT_V01_R01`

Any out-of-order execution/publication, product mutation, failed child, missing equality proof, or speculative evidence is `CHANGES_REQUIRED`.
