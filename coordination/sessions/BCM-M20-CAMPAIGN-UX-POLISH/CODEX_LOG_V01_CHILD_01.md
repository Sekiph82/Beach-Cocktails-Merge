# CODEX Execution Log — BCM-M20-001

Status: `PUBLISHED_BUILDER_EVIDENCE / AWAITING_CHILD_01_AUDIT`

## Contract

- Work item: `BCM-M20-001` — App Shell / Main Menu Entry.
- Prompt/criteria: `CHATGPT_EXECUTION_PROMPT_V01_CHILD_01.md` and `CHATGPT_AUDIT_CRITERIA_V01_CHILD_01.md`.
- Ordered batch position: Child 01 of 06. Child 02 began only after this publication equality proof.

## Synchronization preflight

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Branch: `main`.
- Start HEAD: `d6d5e969ee7526cb9bc51bc4536ff162fd0a6153`.
- `git status --short --branch`: clean, `main...origin/main`.
- `git fetch origin main`: completed.
- `git rev-list --left-right --count HEAD...origin/main`: `0 23`.
- Fast-forward to synchronized `origin/main`: completed before implementation.

## Implementation

- Added `ApplicationShellScene` and `ApplicationShell` as the production boot/menu boundary.
- Main Menu exposes PLAY / CONTINUE and SETTINGS entry points at the 720x1280 reference layout.
- The shell owns exactly one existing `CampaignNavigationController`; it does not duplicate campaign, save, economy, or session authorities.
- Added an application-level `main_menu_requested` signal from the campaign router. World Map back emits that signal, while Island Map back remains the existing World Map boundary.
- Updated the project entry point and compatibility assertions to the new shell contract.
- Added `tests/m20_app_shell_probe.gd` covering boot, menu visibility, PLAY/CONTINUE, World Map return, progression preservation, and instance counts.
- `TASKS.md` was not modified.

## Builder checks

- `godot_console.exe --headless --path . --check-only --script res://tests/m20_app_shell_probe.gd`: exit 0.
- `godot_console.exe --headless --path . --script res://tests/m20_app_shell_probe.gd`: exit 0; `M20_CHILD_01_RESULT=PASS`.
- `godot.exe --headless --quiet --path . --editor --import --quit`: exit 0.
- `git diff --check`: passed before commit.
- Generated Godot translation sidecars were removed as reproducible import clutter and were not staged.
- Manual owner-native visual acceptance: not performed; Child 05 owns required production captures and independent visual audit.

## Changed files

- `project.godot`
- `scenes/campaign/ApplicationShellScene.tscn`
- `scripts/campaign/application_shell.gd`
- `scripts/campaign/campaign_navigation_controller.gd`
- `tests/m12_world_map_probe.gd`
- `tests/m14_gameplay_session_bridge_probe.gd`
- `tests/m20_app_shell_probe.gd`
- this Codex child log

## Publication

- Implementation commit: `62adc9cfcdbf17a261fe31f491bee2949857ee31` (`BCM-M20-001 add application shell and main menu`).
- Publication log commit: recorded separately after this log update.
- No M21 work was started. No gameplay physics, scoring, reward, VIP, or campaign save authority was retuned.
- Local, `origin/main`, and remote equality were verified after publication:
  - `git rev-parse HEAD`: recorded in the publication command output.
  - `git rev-parse origin/main`: matched local HEAD.
  - `git ls-remote origin refs/heads/main`: matched local HEAD.

## Limitations / handoff

- This is builder evidence only, not acceptance. Independent ChatGPT audit remains required.
- Child 02 is authorized only after the equality proof above; M21 remains out of scope.
