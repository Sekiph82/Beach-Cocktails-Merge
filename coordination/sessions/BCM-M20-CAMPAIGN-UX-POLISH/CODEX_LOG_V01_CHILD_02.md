# CODEX Execution Log — BCM-M20-002

Status: `PUBLISHED_BUILDER_EVIDENCE / AWAITING_CHILD_02_AUDIT`

## Contract and ordered gate

- Work item: `BCM-M20-002` — First-Run Onboarding.
- Prompt/criteria: `CHATGPT_EXECUTION_PROMPT_V01_CHILD_02.md` and `CHATGPT_AUDIT_CRITERIA_V01_CHILD_02.md`.
- Child 01 publication gate was satisfied before work began: `192a93221893ba8547f8f60eef3df4500394f752` matched local HEAD, `origin/main`, and remote `main`.
- No Child 03 work was started.

## Synchronization preflight

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Branch: `main`.
- Start HEAD: `192a93221893ba8547f8f60eef3df4500394f752`.
- `git status --short --branch`: clean, `main...origin/main`.
- `git fetch origin main`: completed.
- `git rev-list --left-right --count HEAD...origin/main`: `0 0`.
- Child 01 equality proof was rechecked before implementation.

## Implementation

- Extended the production `ApplicationShell` with a minimal five-step onboarding overlay.
- Pages cover World Map island choice, Island Map level choice, timed normal To-Go objectives, optional VIP, and completion/stars/replay basics.
- Added explicit SKIP INTRO and FINISH paths. Both persist completion in `user://onboarding_state.json` using a small independent schema.
- Missing, unreadable, malformed, or unsupported onboarding data safely returns to first-run state without reading or mutating campaign save data.
- Added an explicit onboarding-only reset method for controlled QA runs; it does not reset campaign progression.
- Updated the Child 01 shell probe to pass through the new first-run boundary while retaining menu/router assertions.
- Added `tests/m20_onboarding_probe.gd` for first run, all concepts, skip, completion, restart persistence, and progression isolation.
- `TASKS.md` was not modified.

## Builder checks

- `godot_console.exe --headless --path . --check-only --script res://tests/m20_app_shell_probe.gd`: exit 0.
- `godot_console.exe --headless --path . --script res://tests/m20_app_shell_probe.gd`: exit 0; `M20_CHILD_01_RESULT=PASS`.
- `godot_console.exe --headless --path . --check-only --script res://tests/m20_onboarding_probe.gd`: exit 0.
- `godot_console.exe --headless --path . --script res://tests/m20_onboarding_probe.gd`: exit 0; `M20_CHILD_02_RESULT=PASS`.
- `git diff --check`: passed before commit.
- Manual owner-native visual acceptance: not performed; required production captures remain Child 05 evidence and audit scope.

## Changed files

- `scripts/campaign/application_shell.gd`
- `tests/m20_app_shell_probe.gd`
- `tests/m20_onboarding_probe.gd`
- this Codex child log

## Publication

- Implementation commit: `da81a5ff5e1487805e0d254aed5aaa7db8f8e7ee` (`BCM-M20-002 add first-run onboarding`).
- Publication log commit: recorded separately after this log update.
- No M21 work was started. No campaign progression, timer, gameplay physics, scoring, VIP, reward, or save authority was changed.
- Equality was verified after publication with `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main`; all matched.

## Limitations / handoff

- This is builder evidence only, not acceptance. Independent ChatGPT audit remains required.
- Child 03 is authorized only after the publication equality proof above.
