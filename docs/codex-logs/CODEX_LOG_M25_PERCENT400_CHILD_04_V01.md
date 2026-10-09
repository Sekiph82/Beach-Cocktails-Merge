# BCM-M25-PERCENT400 Child 04 execution log

- Prompt: `coordination/sessions/BCM-M25-MASTER-V01/children/BCM-M25-PERCENT400-CHILD-04_PROMPT.md` (under master prompt `BCM-M25-PERCENT400_MASTER_PROMPT.md`).
- Start HEAD: `99e746e310b6584ef30ccef36723bec4b9b10410`; branch/remote: `main` / `origin`.
- Sync: no new remote commits at child start. Protected owner-local tracked/untracked paths and `TASKS.md` remained outside staging.
- Files: Child 04 prompt, all M25 PERCENT400 runtime, GL, M21 QA, regression, and integrity evidence under `coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-PERCENT400/`.
- Isolation: all Godot runs used disposable project `C:\Users\sekip\AppData\Local\Temp\BCM-M25-PERCENT400-20261009-182322`, project identity `BCM-M25-PERCENT400-SANDBOX`, and user data/logs under that sandbox's `isolated_appdata`. The actual sandbox Godot log files were observed inside that isolated root. `protected_hash_integrity_report.json` verifies 262 pre-existing protected files: 0 changed, 0 missing, 0 new files in real owner app_userdata.
- Commands/results: Godot 4.7.2 clean import exit 0; 120-frame boot exit 0; M21 GL QA run 01 exit 0 and run 02 exit 0 (each 16 captures); M02, M03, M09, M15–M18, M21–M25 probes passed after the documented M18 fixture migration; M14 and M20 final focused probes passed. FULL/REDUCED real-gameplay GL results and required 720x1280/720x1440 screenshots are included. Stdout and exit codes are committed; raw editor log files remain in the disposable sandbox and were not staged as project evidence.
- M20 note: an earlier run reported a post-Retry assertion failure. A read-only sandbox diagnostic showed the bridge at level 1 / ACTIVE / GAMEPLAY with one instance; the unmodified M20 probe then passed. No product change was needed. An earlier M14 fixture assertion correction is documented in Child 03's log.
- Manual checks: verified result metadata and screenshots for natural WIN/LOSE, Retry budget reset, and Island Map return. No physical-device run was performed; treat device-only acceptance as unverified.
- Limitations: builder evidence only, independent ChatGPT audit pending. Earlier CAL02 logs remain lost as disclosed in the remote CAL02 audit; this task's protected integrity check confirms no additional real owner files changed.
- Child evidence commit: `7eb35fc02a4c41b9012d00cd1b45d25fd294c750`, pushed to `origin/main`.
- At evidence publication, `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` all equaled `7eb35fc02a4c41b9012d00cd1b45d25fd294c750`; owner-local diffs remained unstaged.
- Root `TASKS.md` was not modified by Codex.
