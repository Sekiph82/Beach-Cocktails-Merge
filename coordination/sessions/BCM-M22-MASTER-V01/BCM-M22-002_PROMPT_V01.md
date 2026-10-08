# BCM-M22-002 — FeedbackService Semantic Bus + Sole Plugin Bridge

Execute after M22-001 is committed/pushed and local/origin/remote are equal.

Read matching criteria and current source.

## Job
Turn FeedbackService into the structured semantic presentation bus and add one sole plugin-calling bridge.

### Preserve existing behavior
Do not break:
- current feedback_emitted/audio/haptic behavior;
- merge dedupe;
- order token dedupe;
- success/fail one-shot;
- Reduced Motion/high-contrast/haptics settings;
- any gameplay/campaign/save values.

### Structured semantic API
Add a backwards-compatible structured semantic request path for the complete M22 catalog.

Do not force existing one-argument `feedback_emitted(kind)` consumers to change unless required. Prefer adding a dedicated structured signal/API while preserving legacy feedback.

Deep-copy payloads before emission so downstream presentation cannot mutate authority-owned dictionaries.

Non-MICRO one-shots require stable event/token IDs and duplicate suppression.

### Sole bridge
Add `PresentationFeedbackBridge` or equivalent.

Only this class may invoke:
- GameFeelFlow APIs;
- Spark APIs.

Use M22-001 dynamic capability resolution.

If plugin/preset/API is missing or fails, no-op.

The bridge is presentation-only and must not write score, velocity, collision, orders, VIP state, stars, economy, progression, save, result outcome, or level data.

### Wiring
Connect authoritative existing seams after their truth is finalized.

Do not invent alternate gameplay calculations merely to generate events.

Architecture must support all catalog kinds even if later M23-M26 tasks enrich specific producer payloads.

### Important M22 constraint
Do not turn on visible production effects yet. Bridge execution may be exercised only on isolated test targets/fixtures.

Run locked tests/evidence. Commit/push child log and evidence. Verify clean parity. Continue automatically to M22-003.

Do not edit TASKS.md.

End child with:
`M22_002_READY_FOR_MASTER_CONTINUATION`
