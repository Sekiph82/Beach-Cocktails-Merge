# BCM-M18-004 - Locked Audit Criteria

- A valid normal completion advances the next level with one star; 2/3 stars are not required.
- Lose/incomplete/timeout does not advance progression or unlock the next island.
- Next-level and next-island resolution remain deterministic, sequential, and idempotent.
- Sunny Cove Level 100 completion unlocks the configured next island without a perfect-star gate.
- Retry, Next Level, and Island Map flows preserve one active session and existing timer/lifecycle contracts.
- Focused tests prove the completion-based boundary and regression behavior.
- No timer/objective/VIP/physics/HUD tuning or unrelated data change is made.

Any failed or unverified item is `CHANGES_REQUIRED` and stops M18.
