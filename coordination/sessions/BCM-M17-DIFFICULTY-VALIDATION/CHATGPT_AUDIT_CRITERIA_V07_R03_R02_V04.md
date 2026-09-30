# BCM-M17 V07-R03-R02-V04 - Locked Capture-Compatible Evidence Retry Criteria

Status: **LOCKED BEFORE RETRY**

Authority: `CHATGPT_AUDIT_V07_R03_R02_V03.md`. This version is a bounded capture-compatibility remediation; it preserves the V07-R03-R02 gates and adds a pre-sequence wrapper smoke check.

## Master gates

### A - governance and freeze

The canonical checkout is clean synchronized `main`; `HEAD == origin/main == remote main`; root `TASKS.md`, canonical Sunny Cove data, the V07-R03 runner/report, and all prior evidence retain baseline bytes. The Sunny Cove SHA-256 is `9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495`.

### B - exactly one ordered child

Child 01 is the only child. No direct V07-R03 rerun, report repair, canonical tuning, later child, or M18 work is accepted.

### C - capture compatibility and complete regression recapture

The wrapper compatibility smoke check passes before the locked sequence and changes no repository file. The locked sequence then runs exactly once in order: V06 analytical, V05 optionality, M17 twice, M16, M15, M14, M02, then proofs. Every command has the exact command line, complete verbatim stdout and stderr, required PASS marker, and exact native exit code in both logs. Both M17 runs show `M17_DIFFICULTY_VALIDATION_RESULT=PASS` and exit `0`. The wrapper must not depend on unavailable `ProcessStartInfo.ArgumentList`.

### D - preserved V07-R03 evidence

The V07-R03 runner SHA-256 `0250AD26D995C8101F17E4834785746142CE00F511F5DA1929E80A7803A1ADBC`, JSON SHA-256 `4B07CE2778F9CD001756BE26259B169288D002F385484F94A85A120BF7101C9A`, and Markdown SHA-256 `82EA191C7333BEED7DAAFA4639EAE47EAF904B2C3ADE0A9A9390C6ECC1165276` remain unchanged.

### E - equality and publication proof

The child and master logs record execution-time and final post-publication `HEAD`, `origin/main`, and remote-main equality, clean-tree proof, and `git diff --check`. A terminal publication record repeats the final equality and clean-tree proof.

### F - truthful handoff

The child and master logs preserve the prior V07-R03 direct PASS, state that no direct runner rerun or report repair occurred, include the compatibility smoke evidence and every complete transcript, confirm `TASKS.md` immutability, and end with `AWAITING_M17_AUDIT_V07_R03_R02`. Any failed or unverified item is `CHANGES_REQUIRED`; M17 tuning and M18 remain blocked.
