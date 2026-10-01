# BCM-M19-001..006 — V01-R01 Ordered Verification Remediation

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `CHATGPT_AUDIT_V01.md`
5. `CHATGPT_AUDIT_CRITERIA_V01_R01.md`
6. original M19 V01 master/child prompts and criteria
7. historical V01 child/master logs.

## Purpose

The M19 product implementation is frozen and is **not to be reimplemented**.

The only blocker is that V01 published all six child logs and implementation together, while the locked contract required each child to publish clean PASS evidence before the next child proceeded.

Repair only that evidence/provenance gap.

## Required sequence

### Setup

If needed, add one test-only verification harness that can run **exactly one child at a time**. Commit/push the harness first and prove local/origin/remote equality. After that, freeze it.

Do not edit:
- `scripts/campaign/`
- `data/campaign/`
- canonical assets
- M19 policy docs
- historical V01 evidence
- root `TASKS.md`.

If a child reveals a product defect, stop. Do not fix it in this remediation.

### Child 01

Run only the BCM-M19-001 verification.  
Populate `CODEX_LOG_V01_R01_CHILD_01.md`.  
Commit/push. Verify clean local/origin/remote equality.  
Only then continue.

### Child 02

Run only BCM-M19-002 after Child 01 publication equality.  
Populate/publish `CODEX_LOG_V01_R01_CHILD_02.md`.  
Verify equality before Child 03.

### Child 03

Run only BCM-M19-003 after Child 02 publication equality.  
Populate/publish `CODEX_LOG_V01_R01_CHILD_03.md`.  
Verify equality before Child 04.

### Child 04

Run only BCM-M19-004 after Child 03 publication equality.  
Populate/publish `CODEX_LOG_V01_R01_CHILD_04.md`.  
Verify equality before Child 05.

### Child 05

Run only BCM-M19-005 after Child 04 publication equality.  
Populate/publish `CODEX_LOG_V01_R01_CHILD_05.md`.  
Verify equality before Child 06.

### Child 06

Run only BCM-M19-006 after Child 05 publication equality.  
Populate/publish `CODEX_LOG_V01_R01_CHILD_06.md`.  
Verify equality.

### Closure

Only now run the full regression set in `CHATGPT_AUDIT_CRITERIA_V01_R01.md`.

Populate and publish:
`CODEX_LOG_V01_R01.md`

The final log must show the monotonically increasing child evidence commit chain and the equality proof after every child.

On complete success, finish exactly:

`AWAITING_M19_AUDIT_V01_R01`

Then stop. Do not start M20.
