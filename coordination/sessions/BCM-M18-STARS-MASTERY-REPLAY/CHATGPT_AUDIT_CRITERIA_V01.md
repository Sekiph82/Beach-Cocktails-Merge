# BCM-M18-BATCH-001 - Locked Master Audit Criteria

Status: LOCKED BEFORE CODEX EXECUTION

## Master gates

### A - governance and order

The complete six-child package exists before implementation. Children execute exactly in `M18-001` through `M18-006` order. A missing, skipped, reordered, failed, or unverified child is `CHANGES_REQUIRED` for the batch and blocks all later children.

### B - synchronization and scope

The canonical `main` checkout is safely synchronized before and after each child. CODEX does not edit `TASKS.md`, ChatGPT audit files, or frozen M17/M16/M15/gameplay/data paths outside the child scope. No destructive Git operation, secret, generated cache, or later-milestone implementation is accepted.

### C - child criteria

Each child must independently pass its matching locked child criteria and publish its immutable log. Child evidence is builder evidence; acceptance requires source, diff, tests, and runtime evidence to agree.

### D - architecture and behavior

M18 uses the existing campaign/save/economy/session/map architecture. Stars remain mastery, not a progression gate. Best score/stars are monotonic across replay. Milestone rewards are cumulative, data-driven, idempotent, and non-blocking. Existing VIP optionality, timers, physics, scoring, and island-map navigation remain intact.

### E - integration and regression

The final batch must prove fresh-save progression, normal completion, VIP/no-VIP star outcomes, score-threshold mastery, better and worse replay, save reload, milestone claim/duplicate protection, next-level progression without perfect stars, Island Map replay visibility/return state, Sunny Cove 100% completion, and Tiki Island unlock. Required legacy campaign and gameplay probes must pass or be explicitly marked unverified under a stop condition.

### F - handoff truth

The master log records all child paths/results, exact commands/exits, changed files, limitations, final equality, and ends with `AWAITING_M18_AUDIT_V01`. No builder log or passing test may update the tracker or establish independent acceptance.

## Required final child results

| Child | Required result |
|---|---|
| M18-001 | Star contract is explicit, data-aware, tested, and never gates unlock/progression. |
| M18-002 | Better replay upgrades stored score/stars; worse replay cannot lower them; persistence is safe. |
| M18-003 | Sunny Cove cumulative star/reward track is configured with approved reward schema, non-blocking progression, and idempotent claims. |
| M18-004 | Next-level/next-island progression depends on completion, not perfect stars or mandatory replay. |
| M18-005 | Island Map replay exposes prior state and returns without duplicate sessions or lost selection/scroll state. |
| M18-006 | Full focused and regression evidence covers the complete M18 contract and 100-level island completion. |

Any `OWNER_REQUIRED`, native-device, or unavailable bridge gate must remain explicit and stop the batch rather than being inferred as PASS.
