# BCM-M17 V07-R03-R02 - Locked Complete-Stdout Evidence-Handoff Remediation Audit Criteria

Status: **LOCKED BEFORE REMEDIATION**

Authority: `CHATGPT_AUDIT_V07_R03_R01.md` and the V07-R03-R01 locked criteria.

## Master gates

### A — governance and freeze

The canonical checkout is clean synchronized `main`; `HEAD == origin/main == remote main`; root `TASKS.md`, canonical Sunny Cove data, the V07-R03 runner/report, and all prior evidence retain their baseline bytes.

### B — exactly one ordered child

Child 01 is the only child. No direct V07-R03 rerun, report repair, canonical tuning, later child, or M18 work is accepted.

### C — verbatim regression recapture

The locked regression sequence is executed in order after read-only confirmation of the existing V07-R03 direct PASS. For every command, the child and master logs contain the exact command, a verbatim complete captured stdout/stderr transcript without ellipses or summary substitution, the required PASS marker, and the exact process exit code. Both M17 difficulty-validation runs show `M17_DIFFICULTY_VALIDATION_RESULT=PASS` and exit `0`.

### D — preserved V07-R03 evidence

The V07-R03 runner SHA-256 `0250AD26D995C8101F17E4834785746142CE00F511F5DA1929E80A7803A1ADBC`, JSON SHA-256 `4B07CE2778F9CD001756BE26259B169288D002F385484F94A85A120BF7101C9A`, and Markdown SHA-256 `82EA191C7333BEED7DAAFA4639EAE47EAF904B2C3ADE0A9A9390C6ECC1165276` remain unchanged.

### E — equality and publication proof

The child and master logs record exact execution-time `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` values, all equal, plus clean-tree and `git diff --check` proof. A terminal publication record records the final pushed SHA in all three equality commands and a clean tree.

### F — truthful handoff

The child and master logs explicitly preserve the prior V07-R03 direct PASS, state that no direct runner rerun or report repair occurred, include every verbatim regression transcript and limitation, confirm `TASKS.md` immutability, and end with `AWAITING_M17_AUDIT_V07_R03_R02`. Any failed or unverified item is `CHANGES_REQUIRED`; M17 tuning and M18 remain blocked.
