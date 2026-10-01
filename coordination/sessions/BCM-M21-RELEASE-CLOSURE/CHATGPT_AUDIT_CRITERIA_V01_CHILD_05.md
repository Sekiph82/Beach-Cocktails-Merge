# BCM-M21-005 — Locked Criteria

- Production main scene/export inputs are correct.
- No reachable debug progression bypass in production UI.
- release-mode persistence smoke is demonstrated.
- Available export tooling is detected truthfully.
- Any generated distributable is hashed and linked in the release manifest.
- Missing mobile/signing tooling is explicitly UNVERIFIED/OWNER-ENVIRONMENT, not falsely passed.
- No secrets or local SDK paths committed.
- Separate publication/equality required.
