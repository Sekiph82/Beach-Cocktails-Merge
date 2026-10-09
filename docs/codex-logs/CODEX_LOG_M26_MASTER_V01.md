# Codex Execution Log — BCM-M26 Master V01

Status: `AWAITING_GPT_M26_MILESTONE_AUDIT_V01`.

- Work item: BCM-M26-MASTER-V01 — continuous builder sequence after the already-audited M26-001/R01, completing M26-002 and M26-003 and their full milestone checks.
- Master prompt: `coordination/sessions/BCM-M26-MASTER-V01/CHATGPT_M26_MASTER_PROMPT_V01.md`; audit criteria: `BCM-M26_MASTER_AUDIT_CRITERIA_V01.md`.
- Start HEAD after mandatory safe sync: `3e1e97153b3f2a0c0ea3fd49a81ed4cd350176ac`; branch `main`; remote `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- End of implementation and master evidence: `bf37b7378eef68e6f647a130e17a8974b1025328`. M26-002 implementation/evidence `645eb357ca6c9f1f01a57f8682188c74ebae1723`; M26-002 child log `30af408800f5632aa992c3fd60aa176aefd3df76`; M26-003 implementation/evidence `3b8958ca874913fada1565939f0b24ae20b84775`; M26-003 child log `12d131355bde97f7d4e50ced64d6d48f4692a4e8`. All published to `main` as separate child source/evidence and docs-only commits; this master log is also a separate docs-only commit.
- Safe-sync preflight: local `main` began behind-only `0/5` with inventoried tracked and untracked owner work. Incoming changes were path-disjoint. Created tracked-only stash `owner-local-safe-sync-8685f26`, fast-forwarded `8685f26..3e1e971`, then applied that exact stash without dropping it. Untracked owner paths were left untouched. No reset, clean, rebase, branch creation, or force push was used.
- Final publication verification before this log commit: `HEAD = origin/main = git ls-remote origin refs/heads/main = bf37b7378eef68e6f647a130e17a8974b1025328`; ahead/behind `0/0`.

## Work delivered

- M26-002 captures authoritative campaign completion and unlock transitions, routes first completion to the Island Map and newly unlocked islands to the World Map, targets existing visible island title/art, and serializes large effects within the M22 global live Spark cap. Its focused probe passed with `M26_002_CAMPAIGN_MAP_RESULT=PASS captures=3 failures=0 max_particles=48`.
- M26-003 adds deduplicated reward-ledger feedback and a strict PLAY/NEXT/RETRY CTA whitelist. FULL reward feedback is capped at five particles; REDUCED is particle-free; CTA color cues are brief and particle-free. Its focused probe passed with `M26_003_REWARD_CTA_RESULT=PASS captures=4 failures=0` on real GL Compatibility viewport captures. Repeat execution passed after normalizing the probe's starting reduced-motion setting.
- M26-002 and M26-003 each have separate source/evidence commits and separate execution logs. M26-001/R01 was not repeated; the supplied package identifies it as already independently audited.

## Verification and evidence

- Every Godot call ran through `tests/m26_001_r01_godot_runner.ps1` in disposable renamed-project sandbox `C:\Users\sekip\.codex\worktrees\bcm-m26-master-v01-sandbox`; actual sandbox `user://` data was under `C:\Users\sekip\AppData\Roaming\Godot\app_userdata\BCM-M26-003-20261009-Sandbox`.
- Godot: `4.7.2.stable.official.ed1daf0bf`. M26-003 editor import and 120-frame boot each exited `0`; stderr was empty; runner cleanup verified.
- SHA-256 checks covered 229 real user-data files and 31 owner-local files before and after the M26-003 focused renderer, editor import, boot, regression, and repeated-probe stages. No hash differences were found. Each M21 QA run and every regression runner also verified task-process cleanup. Unrelated Godot processes were left alone.
- Two separate M21 GL Compatibility QA runs each exited `0`, each captured 16 images, and each reported no failed checks. These are automated captures and do not claim physical-device or owner acceptance.
- M02-M25 regression source batch: 49 passed, 6 failed. The failed M26-003 repeat was caused by persisted REDUCED settings and was rerun successfully after probe normalization. Effective result: 50 passed, 5 failed. Failure IDs/findings and raw outputs are preserved in `evidence/M26-MASTER/master_regression_summary.json` and `evidence/M26-MASTER/regressions/runs/`:
  - M08 To-Go probe fails to parse from mixed indentation at `tests/m08_to_go_delivery_probe.gd:79`.
  - M17 V06 analytical probe fails its objective-reachability assertion; canonical Sunny Cove JSON remained byte-identical.
  - M17 difficulty validation fails its timeout fixture, TIMEOUT outcome, and different-seed action-sequence assertions; deterministic replay checks pass.
  - M20 pause lifecycle fails its retry-same-campaign-level assertion; other listed lifecycle checks pass.
  - M23 merge feedback fails the stress dispatch particle/GFF output-ceiling assertion.
- Two M21 QA output folders and run metadata are in `evidence/M26-MASTER/mobile_qa_run01/` and `mobile_qa_run02/`. M26-003 GL screenshots, probe reports, runner JSON, import/boot outputs, and safety manifests are in `evidence/M26-003/`. M26-002 evidence is in `evidence/M26-002/`.

## Preservation, limits, and handoff

- Root `TASKS.md` was read-only and is byte-for-byte unmodified. No M27 work started.
- Owner-local `project.godot`, M21/M22 evidence diffs, M23 R01 evidence/logs, and unrelated untracked owner images/evidence remain unstaged and uncommitted. The post-push canonical checkout remains dirty only at those inventoried owner-local paths; no M26 task files remain uncommitted.
- No human played a complete campaign, no physical device was used, and no final owner visual acceptance was performed. Fixture-based focused probes and renderer screenshots are builder evidence only. These items and five remaining regressions require independent audit disposition.
- This log records builder claims and evidence indexes. It does not assign an acceptance verdict or update the project tracker. Stop here at `AWAITING_GPT_M26_MILESTONE_AUDIT_V01` for the single independent milestone audit.
