# BCM-M11-SAVE-MIGRATION-PROGRESSION — ChatGPT Independent Audit V01

Verdict: **AUDITED_PASS**

Audited implementation:
`ddc51a9e4e92abd78bc7a67cc16e5503e5d8b52c`

Builder log:
`coordination/sessions/BCM-M11-SAVE-MIGRATION-PROGRESSION/CODEX_LOG_V01.md`

Locked criteria:
`coordination/sessions/BCM-M11-SAVE-MIGRATION-PROGRESSION/CHATGPT_AUDIT_CRITERIA_V01.md`

## 1. Verdict

**PASS.**

M11 implements the required save, recovery, migration and progression core without modifying the accepted gameplay baseline.

No owner visual/runtime acceptance is required because this milestone has no visual deliverable.

## 2. Scope containment

The implementation changes only campaign persistence/progression source, focused tests and documentation.

No core gameplay, physics, R11 table-edge behavior, M08/M09 feedback, scoring/reward tables, HUD, canonical assets, project.godot, World Map, Island Map, gameplay timer, VIP runtime, booster gameplay or full Sunny Cove content is changed.

**PASS.**

## 3. SaveManager persistence

The new schema is explicit at version 2.

Production paths are clearly defined:
- `user://campaign_save.json`
- `user://campaign_save.json.bak`
- `user://campaign_save.json.tmp`
- legacy read-only source `user://save.cfg`

`write_state()`:
- validates before serialization;
- writes the new state to a temporary file;
- flushes/closes it before replacement;
- copies only a recoverable existing primary to backup;
- does not overwrite a good backup from a malformed primary;
- removes the temporary file on write/finalization failure;
- returns structured status/reason output.

The focused probe demonstrates first and second writes, last-known-good backup creation and preservation across invalid writes.

**PASS.**

## 4. Recovery behavior

`load_state()` distinguishes:
- missing;
- valid;
- migrated;
- recovered;
- fallback;
- unsupported.

Malformed primary with valid backup selects backup and attempts guarded primary repair.

Malformed primary plus invalid/missing backup falls back to a safe default while surfacing the reason.

Future schema without a valid backup is surfaced as unsupported rather than silently accepted.

**PASS.**

## 5. Schema migration

The migration entry point:
- accepts current schema without rewriting;
- migrates schema v1 to v2;
- adds `legacy_best_score` and missing collections/defaults;
- validates the migrated result;
- rejects unsupported schema versions.

Migrated states flow back through the guarded write path.

**PASS.**

## 6. Legacy best-score preservation

The existing gameplay legacy file remains owned by the old gameplay system.

M11 only reads `records/best` and never rewrites/deletes `user://save.cfg`.

Migration behavior is monotonic:
- higher legacy value is copied into `legacy_best_score`;
- repeated loads do not inflate it;
- a higher campaign-side migrated score remains higher.

The focused probe covers first migration, repeat migration and preservation of a larger campaign value.

**PASS.**

## 7. Campaign progression

CampaignManager now provides:
- island unlock queries;
- level unlock queries;
- completion;
- replay best-score/star preservation;
- sequential next-level unlock;
- island-completion detection;
- next-level resolution;
- next-island resolution;
- canonical unlock-rule evaluation;
- one-time milestone claim state.

State transitions are derived from LevelDatabase definitions rather than hardcoded campaign UI behavior.

**PASS.**

## 8. Idempotency

Replay behavior uses max(existing, incoming) for stars and score.

Worse replay:
- does not lower score;
- does not lower stars;
- reports no material state change.

Duplicate milestone claim:
- does not duplicate claim state;
- reports duplicate/no change.

Island unlock collections are deduplicated.

Progression signals are emitted only when completion/unlock/claim state materially changes.

**PASS.**

## 9. Persistence integration

The implementation provides the required orchestration path:

1. SaveManager load;
2. CampaignManager configure;
3. progression mutation;
4. SaveManager write;
5. SaveManager reload;
6. CampaignManager reconfigure.

The focused probe persists progressed state, reloads it and verifies equivalent unlocked island and milestone state.

**PASS.**

## 10. Test isolation

The M11 probe explicitly uses paths under:

`user://m11_save_probe/`

The production campaign/backup/legacy paths are not used by the focused M11 probe.

The broader regression run was also isolated through temporary APPDATA/LOCALAPPDATA according to builder evidence.

This satisfies the owner-save protection requirement.

**PASS.**

## 11. Regression evidence

Builder reports PASS for:
- M01
- M02
- M03
- M04
- M05
- M07
- M08
- M09
- M10
- M11 focused probe
- Godot import/reimport
- git diff --check

The old M06 environment probe still has a pre-existing Godot 4.7.2 type-inference parse defect and was not modified to manufacture a pass. That historical harness issue is outside M11.

No gameplay regression is visible in the audited diff.

**PASS.**

## 12. Non-blocking notes

### Canonical seed and Tiki unlock

The current canonical Sunny Cove seed intentionally contains only two levels while declaring 100. Therefore canonical Tiki unlock is not expected to become achievable until the full Sunny Cove content milestone. M11's unlock logic is verified with a complete two-level test database and is structurally ready for the full dataset.

### Save replacement behavior

The focused probe exercises repeated writes and recovery successfully on the target Godot/runtime environment. This is sufficient for M11 closure. Device/platform persistence QA remains appropriate for the later mobile/release milestone.

## 13. Final verdict

**AUDITED_PASS**

M11 save, migration and progression core is closed.

The project may proceed to M12 World Map.
