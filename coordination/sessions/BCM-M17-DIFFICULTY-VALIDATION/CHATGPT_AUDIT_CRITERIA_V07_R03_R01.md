# BCM-M17 V07-R03-R01 - Locked Evidence-Handoff Remediation Audit Criteria

Status: **LOCKED BEFORE REMEDIATION**

Authority: `CHATGPT_AUDIT_V07_R03.md` and the V07-R03 locked criteria.

## Master gates

### A - governance and freeze

The canonical checkout is clean synchronized `main`; `HEAD == origin/main == remote main`; root `TASKS.md`, canonical Sunny Cove data, the R03 runner/report, and all V07-R02/V07-R01/V06-R02/V05 evidence retain their baseline bytes.

### B - exactly one ordered child

Child 01 is the only child. No direct R03 rerun, report repair, canonical tuning, later child, or M18 work is accepted.

### C - exact regression recapture

The locked R03 regression sequence is executed after confirming the existing committed R03 direct PASS. Every command records exact stdout, required PASS marker, and exit code. Both M17 difficulty-validation runs must show `M17_DIFFICULTY_VALIDATION_RESULT=PASS` and exit `0`.

### D - preserved R03 evidence

The R03 runner SHA-256 `0250AD26D995C8101F17E4834785746142CE00F511F5DA1929E80A7803A1ADBC`, JSON SHA-256 `4B07CE2778F9CD001756BE26259B169288D002F385484F94A85A120BF7101C9A`, and Markdown SHA-256 `82EA191C7333BEED7DAAFA4639EAE47EAF904B2C3ADE0A9A9390C6ECC1165276` remain unchanged.

### E - final synchronization proof

The child and master logs record exact final values for `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main`, all equal, plus a clean working tree and `git diff --check`.

### F - truthful handoff

The child and master logs explicitly preserve the R03 direct PASS as prior evidence, state that no direct rerun or report repair occurred, list all regression results and limitations, confirm `TASKS.md` was not modified, and end with `AWAITING_M17_AUDIT_V07_R03_R01`.

Any failed or unverified item is `CHANGES_REQUIRED`; M17 tuning and M18 remain blocked.
