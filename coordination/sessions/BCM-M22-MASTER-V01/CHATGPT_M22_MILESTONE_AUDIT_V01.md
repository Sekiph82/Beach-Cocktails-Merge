# CHATGPT M22 Independent Milestone Audit V01

Verdict: **CHANGES_REQUIRED (policy-language consistency); OWNER_MATRIX_APPROVAL_PENDING**.
Reviewed against published main implementation/evidence and locked child criteria. This is a source/evidence review, not an independently rerun local Godot GUI session.

## Evidence reviewed
- Root TASKS.md, M22 master prompt, M22-001/002/003 locked audit criteria, master and M22-002 Codex logs.
- scripts/presentation_plugin_contract.gd, scripts/presentation_feedback_bridge.gd, scripts/presentation_effect_policy.gd.
- M22-003 commands_and_results.txt and owner-review M22_EFFECT_LANGUAGE_MATRIX.md.

## Findings
1. **M22-001: evidence-supported, no blocking finding in inspected contract.** Plugin capability is cached per bridge configuration, no optional hard preload, guarded method availability. Builder reports plugin-present/missing/failure checks, Godot boot and parity. Full independently rerun test not claimed.
2. **M22-002: evidence-supported, no blocking finding in inspected bridge.** Sole plugin-effect call boundary, production dispatch false, fixture-only calls, listener disconnection/cancellation. Builder reports 27 checks PASS and M02/M09/M15/M21 regressions. Headless World Map mouse/touch assertions PASS but captures=0, therefore GUI pixels are NOT independently visually accepted.
3. **M22-003: POLICY LANGUAGE INCONSISTENCY, blocking owner matrix approval.** Executable reduced-mode styles claim **no particles** for `merge`, `vip_delivery`, and `vip_complete`; the corresponding REDUCED Spark dust budgets allow up to 4, 6 and 6 particles respectively. This discrepancy is propagated into the generated owner-review matrix. Because that matrix is the required signed-off contract for future M23+ visuals, its descriptions must agree with executable allowances. The numerical budgets appear within the locked <=25% limits, so either explicitly authorize restrained dust in the prose or make those budgets zero, consistently. Do not unilaterally turn on effects.
4. **Owner gate:** Matrix remains a builder proposal. Owner approval has not been supplied. M23 must remain blocked.
5. **Scope/evidence limitation:** Reported 89 policy checks, state hash 891736178 and regressions are Codex test evidence, not independent test execution. No visually rendered screenshots were produced (captures=0); this is not by itself a M22 architecture failure because M22 intentionally enables no production visuals.

## Required remediation
- Reconcile the three conflicting REDUCED style sentences and their numeric Spark permissions.
- Add automated assertions that any policy line claiming zero particles has zero allowed Spark amount for all applicable chain bands. Regenerate matrix from executable policy.
- Preserve 16 kinds/32 rows; plugin no-op / no production effects; source parity; no gameplay changes, no owner-local PNG changes.
- Publish focused tests/log, request independent re-audit. Do not start M23; do not edit root TASKS.md (ChatGPT-only).
- Owner approval remains a separate gate after technical re-audit.

**Audit result: CHANGES_REQUIRED / AWAITING_CODEX_M22_R01 / OWNER_MATRIX_APPROVAL_PENDING.**
