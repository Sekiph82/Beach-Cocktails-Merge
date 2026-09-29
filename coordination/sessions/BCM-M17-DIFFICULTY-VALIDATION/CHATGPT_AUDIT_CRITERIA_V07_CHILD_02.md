# V07 Child 02 - Locked Audit Criteria

- The direct V07 runner validates the audited V06-R02 source before using it: PASS required.
- Exactly 42 derived candidates receive one carried-forward trial plus exactly four new trials, for 168 new trials and 210 candidate aggregate trials: PASS required.
- Every trial uses `MERGE_AWARE_V01`, time scale `1.0`, unique valid seeds, valid flat telemetry, and a legal action log: PASS required.
- Reports contain exactly 100 levels and 45 classes, with complete per-class evidence and no five-trial candidate left pending confirmation: PASS required.
- Post-V05 VIP semantics are exactly forced `0/25`, surplus `25/25`, and no VIP cost in normal timers: PASS required.
- Any failed or unverified item blocks Child 03 and the batch: CHANGES_REQUIRED.
