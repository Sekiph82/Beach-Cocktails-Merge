# BCM-M17 V07-R03-R02-V05 - Locked Log-Embedded Equality Correction Criteria

Status: **LOCKED BEFORE CORRECTION**

Authority: `CHATGPT_AUDIT_V07_R03_R02_V04.md`. This version corrects only the missing post-publication equality inside the V04 child/master logs.

## Master gates

### A - governance and freeze

The checkout is clean synchronized `main`. V04 and all earlier evidence, V07-R03 runner/report, canonical Sunny Cove data, and `TASKS.md` remain unchanged. No process is rerun.

### B - exactly one ordered child

Child 01 is the only child. No later child, tuning, report repair, or M18 work is accepted.

### C - preserved evidence-only correction

The V05 child/master logs preserve the V04 smoke and eight-command transcripts, exact commands, complete stdout/stderr, required markers, exit codes, protected hashes, and no-rerun claim byte-for-byte as evidence content. The V04 logs and terminal record remain immutable.

### D - log-embedded equality

Both V05 logs contain the exact first-publication equality after the first V05 log commit: local `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main`, plus clean status and `git diff --check`. The values must be independently consistent with the first publication commit.

### E - final publication proof

The terminal record contains the exact second-publication equality after the equality block was added to both logs, clean status, `git diff --check`, `TASKS.md` freeze proof, and final marker. The second publication is the final V05 log state.

### F - truthful handoff

Both V05 logs end with `AWAITING_M17_AUDIT_V07_R03_R02`, state that no regression or R03 rerun occurred, and identify the terminal record. Any changed transcript, missing equality, failed proof, or unauthorized work is `CHANGES_REQUIRED`.
