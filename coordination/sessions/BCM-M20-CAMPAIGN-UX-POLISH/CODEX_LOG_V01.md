# CODEX Execution Log — BCM-M20 V01

Status: `PUBLISHED_BUILDER_EVIDENCE / AWAITING_M20_AUDIT_V01`

## Authority and boundary

- Execution prompt: `CHATGPT_EXECUTION_PROMPT_V01.md`.
- Audit criteria: `CHATGPT_AUDIT_CRITERIA_V01.md`.
- Canonical branch: `main`.
- Canonical remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Start HEAD after mandatory sync-first preflight: `d6d5e969ee7526cb9bc51bc4536ff162fd0a6153`.
- Initial preflight was clean and behind-only (`HEAD...origin/main = 0 23`); canonical checkout was fast-forwarded before implementation.
- Root `TASKS.md` was never edited.
- M21 was not started.

## Ordered publication chain

Each child was committed and pushed in order, and local HEAD, `origin/main`, and remote `refs/heads/main` were equal before the next child began.

| Child | Implementation commit | Publication/equality commit |
|---|---|---|
| BCM-M20-001 | `62adc9cfcdbf17a261fe31f491bee2949857ee31` | `192a93221893ba8547f8f60eef3df4500394f752` |
| BCM-M20-002 | `da81a5ff5e1487805e0d254aed5aaa7db8f8e7ee` | `de6458fdafe0e258d9ddc89195e36b21f7775126` |
| BCM-M20-003 | `6e05a8c5451e5e187f3bea557a8a42c81b5c3bd7` | `82fd1e92df32a315d26d793b6cd4e42f85b22ee1` |
| BCM-M20-004 | `902627a9014108fcaa01232d3fe2f377d95d4faf` | `5c0c1e39cbfc7e92a1fefa9e21666a6001e84675` |
| BCM-M20-005 | `e1c2ab0d54fc28dc9cf93a85b5c59ad5ac6cadeb` | `917bc8c3b28983f18d109c6cac18824ae1e2f7af` |
| BCM-M20-006 | `9c9005bd3b47aec9aa6346a9a387bc7be6858589` | `27601ecbcd73f2a9f1483924e72faaa7774a51b9` |

## Delivered scope

- Application shell and Main Menu boundary with existing campaign navigation authority preserved.
- Five-page first-run onboarding with separate skip/complete persistence.
- Settings surface with independent audio, haptics, reduced-motion, and high-contrast preferences.
- Pause/resume/lifecycle handling with terminal-state guard and Island Map return.
- Locked island/level feedback and one centralized result overlay for lose/win actions.
- Migration/backward-compatibility probe covering current round-trip, v1, M15/M18 fields, legacy best score, backup recovery, unsupported future schema, and settings/onboarding isolation.

No root tracker, gameplay physics constants, campaign data, reward authority, or save schema was retuned for M20.

## M20 focused evidence

All focused probes returned exit 0 and their result markers passed:

```text
M20_CHILD_01_RESULT=PASS
M20_CHILD_02_RESULT=PASS
M20_CHILD_03_RESULT=PASS
M20_CHILD_04_RESULT=PASS
M20_CHILD_05_RESULT=PASS
M20_CHILD_06_RESULT=PASS
```

Child 05 production captures are committed under:

`coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/evidence/captures/`

The seven captures are onboarding, Main Menu, Settings, locked feedback, pause, lose result, and win result. Each is verified as `720x1280` and was visually inspected during builder verification.

## Regression and protected evidence

Passing campaign/protected results include M10, M11, M12, M13, M14, M15, M16, M17 analytical/difficulty/VIP optionality, M18 completion/reward/replay/integration contracts, M19 scalability, all six M19 R01 selectors, and protected M01/M02/M03/M07-R06/M08/M09.

The required GUI-only M18 replay capture was rerun with `godot.exe` and returned `M18_REPLAY_CAPTURE_RESULT=PASS`.

One pre-existing cross-milestone finding remains visible in `tests/m17_canonical_screening_probe.gd`: both headless and GUI runs return `M17_CANONICAL_SCREENING_RESULT=FAIL` for the same L4/L60/L100 production VIP-second fixture assertions. The M20 diff does not modify that gameplay routing path, so no unrelated tuning or test bypass was introduced. This remains explicitly available for independent ChatGPT audit.

Godot import/editor parse returned exit 0. `git diff --check` returned exit 0. Deliberate malformed JSON fixtures emit parser diagnostics while their recovery/default assertions pass. Reproducible Godot CSV translation sidecars generated during import were removed and were not staged.

## Final handoff

After Child 06 publication, equality was verified as:

```text
LOCAL  = 27601ecbcd73f2a9f1483924e72faaa7774a51b9
ORIGIN = 27601ecbcd73f2a9f1483924e72faaa7774a51b9
REMOTE = 27601ecbcd73f2a9f1483924e72faaa7774a51b9
```

This is builder evidence only. Independent ChatGPT audit and owner-native acceptance remain pending.

Successful marker:

`AWAITING_M20_AUDIT_V01`
