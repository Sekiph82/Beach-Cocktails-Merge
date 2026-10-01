# CODEX Execution Log — BCM-M21-004

Status: `COMPLETE_BUILDER_EVIDENCE_AWAITING_AUDIT`

## Work item and locked scope

- Work item: `BCM-M21-004` — full accepted M01–M20 regression.
- Prompt: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_EXECUTION_PROMPT_V01_CHILD_04.md`.
- Criteria: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01_CHILD_04.md`.
- Active branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Start HEAD after Child 03 equality: `5e484d281801329a150af0cbaea35dda4d883c5b`.
- Implementation/evidence commit: `0feca0fd3caa86f4a88c910375ef9f6229575b9c`.

## Sync-first preflight

- Canonical checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- `git status --short --branch`: clean `main...origin/main` before Child 04.
- `git remote -v`: canonical GitHub remote above.
- `git fetch origin main`: completed before Child 04.
- `git rev-list --left-right --count HEAD...origin/main`: `0 0` after Child 03 publication.
- No reset, rebase, force-push, stash, destructive checkout, or branch creation used.

## Implementation and evidence

- Added bounded runner: `tools/m21_child04_regression_runner.ps1`.
- Added machine-readable report: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/regression/M21-004_FULL_ACCEPTED_REGRESSION.json`.
- Added Markdown report with exact commands, exits, required markers, and captured output: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/regression/M21-004_FULL_ACCEPTED_REGRESSION.md`.
- No production gameplay, campaign data, asset, or tracker change was made.
- Root `TASKS.md` was not modified. Pre-run SHA-256: `10f8ebf6269a7323d8c8e89d596b777a4334fcdf1d836ac2b2220b8ab2bae9b3`.

## Regression execution

Runner command:

```text
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\m21_child04_regression_runner.ps1
```

Godot: `4.7.2.stable.official.ed1daf0bf`.

Final builder result:

```text
M21_CHILD_04_RESULT=PASS checks=33 passed=33 failed=0
```

The 33 checks were:

- M01, M02, M03.
- M07-R06 owner-layout boundary.
- M08 and M09.
- M10 through M16.
- M17 post-V05 VIP optionality, V06 analytical boundary, difficulty validation, and read-only V07-R03 report integrity.
- M18 star contract, completion progression, cumulative rewards, reward-claim remediation, replay persistence, integration, island-map replay, and V02-R01 replay capture.
- M19 scalability plus ordered verification selectors `--child=1` through `--child=6`.
- M20 runtime capture probe.

Every required check returned native exit code `0` and its required PASS marker. M07-R06 was required and passed.

## Historical and non-rerun boundaries

- `tests/m17_canonical_screening_probe.gd` was not run. Its pre-V05 VIP-second assertions are explicitly historical and superseded by the post-V05 optionality boundary.
- `tools/campaign/m17_canonical_confirmation_v07_r03.gd` was not invoked because it writes the historical V07-R03 JSON/Markdown reports. The accepted V07-R03 report and Markdown were validated read-only for version, PASS status, zero validation errors, 100 levels, 42 confirmation candidates, and SHA-256 values.
- M07-R04 remains a documented historical limitation; M07-R06 was run as the current owner-layout acceptance probe.
- No product tuning or test weakening was performed to obtain green output.
- The two capture probes regenerated their own historical PNG targets during execution; those six pre-existing tracked PNGs were verified against and restored byte-for-byte to their `HEAD` blobs before publication. They are not included in the Child 04 diff.

## Verification and limitations

- `git diff --check`: PASS.
- Focused full regression report: PASS, 33/33.
- Physical-device/mobile-native acceptance was not performed by this desktop runner and remains outside this builder claim.
- Signed store export/release acceptance was not performed in Child 04.
- This is builder evidence only; independent ChatGPT audit owns acceptance and any tracker transition.

## Publication gate

- Implementation/evidence commit pushed: `0feca0fd3caa86f4a88c910375ef9f6229575b9c`.
- Publication commit for this log: to be recorded by the versioned publication log.
- Required equality after implementation publication:
  - local `HEAD`: `0feca0fd3caa86f4a88c910375ef9f6229575b9c`
  - `origin/main`: `0feca0fd3caa86f4a88c910375ef9f6229575b9c`
  - `git ls-remote origin refs/heads/main`: `0feca0fd3caa86f4a88c910375ef9f6229575b9c`
- Worktree clean at implementation publication.

Child 04 handoff remains builder evidence only. Continue to Child 05 only after this log publication is pushed and its equality is independently recorded.
