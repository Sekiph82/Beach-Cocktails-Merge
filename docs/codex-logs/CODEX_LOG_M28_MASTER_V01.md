# CODEX MASTER LOG — BCM-M28-RELEASE-READINESS-V01 — V01

Status: `BUILDER_SEQUENCE_COMPLETE; AWAITING_GPT_M28_MILESTONE_AUDIT`.

## Authority and scope

- Master prompt: V04 at `coordination/sessions/BCM-M28-RELEASE-READINESS-V01/CHATGPT_M28_MASTER_PROMPT_V01.md` (existing repository filename is unchanged).
- Locked criteria: `coordination/sessions/BCM-M28-RELEASE-READINESS-V01/BCM-M28_MASTER_AUDIT_CRITERIA_V01.md`.
- M27 owner acceptance: `coordination/sessions/BCM-M28-RELEASE-READINESS-V01/OWNER_M27_ACCEPTANCE_V01.md`.
- Start HEAD after mandatory sync: `41609fc289e3df6bac25632b67186b675005aef4`; branch `main`; remote `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Sync preflight: initial `9667a1c`; fetched `origin main`; 0/26 ahead/behind; seven tracked dirty paths inventoried; 507 incoming paths had no overlap. Created/reapplied retained tracked-only stash `owner-local-safe-sync-9667a1c`; did not stash untracked files; fast-forwarded to `41609fc`; final initial-sync equality `HEAD = origin/main`, 0/0.
- Executed M28-001, M28-002, and M28-003 as one continuous evidence-only builder sequence. No app code, visual assets, Actions workflow, export setting, or `TASKS.md` changed. No Godot command, rebuild, artifact download, TestFlight, or store upload was performed.

## Sync and owner-work preservation

- Preflight began at `9667a1c`; `origin/main` was fetched. Local history was behind-only (0 ahead / 26 behind); incoming changes touched none of the seven modified tracked owner paths. A named tracked-only stash, `owner-local-safe-sync-9667a1c`, was created with explicit paths, left retained, and reapplied after fast-forward to `41609fc`.
- All untracked M21/M23 owner evidence stayed in place. All seven tracked diffs (six M21/M22 evidence JSON files and `project.godot`) were restored and left unstaged/uncommitted. No conflicts occurred.
- Final repository publication is documentation-only. The final push/equality check is recorded by the Git commit containing this log and the handoff verification. The owner-local paths above remain outside the commit.

## Child sequence

### BCM-M28-001 — iOS workflow and release artifact provenance

Evidence and limits: `CODEX_LOG_M28_001_IOS_WORKFLOW_PROVENANCE_V01.md`. Existing Android run `38078255160` and iOS run `38063815860` each report success; their artifacts and metadata remain available. Android is debug-signed APK with run-number version; iOS is an unsigned Xcode Release app packaged as IPA with placeholder team ID. Both workflow files at the run SHAs match current review versions. The owner reports using the iPhone build and accepts graphics/effects/gameplay through the separate owner-managed WSL/xtool path. No App Store signed package is claimed.

### BCM-M28-002 — device-release safety, persistence, lifecycle, privacy

Evidence and limits: `CODEX_LOG_M28_002_DEVICE_RELEASE_PRIVACY_QA_V01.md`. Source review found local persistence, backup/atomic save behavior, pause/resume hooks, portrait orientation and icon references; M27 regression evidence includes 100-level progression/restart checks. Android device acceptance, package-generated permission/version metadata, broad interruption/recovery/offline device behavior, and a final transitive privacy manifest/data-flow audit remain unverified. The owner iPhone acceptance is limited to the one reported device and named visual/gameplay scope.

### BCM-M28-003 — candidate manifest, decisions, checklist, caveats

Evidence and release package: `CODEX_LOG_M28_003_RELEASE_CANDIDATE_EVIDENCE_V01.md`. It includes the artifact provenance table, current private testing and future store gates, minimal family-test checklist, and prioritized store-publication backlog.

## Release decisions for independent audit

- Current family/device testing: `GO WITH SCOPE LIMITS`. iPhone is owner-accepted only for the owner-tested phone and graphics/effects/gameplay; Android is a controlled debug-APK test candidate, not an Android device acceptance pass.
- Future public Google Play and Apple App Store: `NO-GO`. Current Android artifact is not a release-signed AAB; current iOS artifact is unsigned. Public signing/provisioning, package and privacy audits, store disclosures/listing, broader device QA, and review remain future work.
- These are builder recommendations for audit, not platform approvals or a tracker transition.

## Files changed

- `docs/codex-logs/CODEX_LOG_M28_001_IOS_WORKFLOW_PROVENANCE_V01.md`
- `docs/codex-logs/CODEX_LOG_M28_002_DEVICE_RELEASE_PRIVACY_QA_V01.md`
- `docs/codex-logs/CODEX_LOG_M28_003_RELEASE_CANDIDATE_EVIDENCE_V01.md`
- `docs/codex-logs/CODEX_LOG_M28_MASTER_V01.md`

## Validation, limitations, and ownership

- GitHub Actions run/job/artifact metadata was read from the GitHub API; no artifact content or signing data was fetched.
- Workflow source at each recorded run commit was compared to the synchronized `main` version; no differences were present.
- Existing M27 logs and owner ruling were reviewed. Their detailed test evidence remains builder/owner evidence and was not rerun or upgraded by this M28 work.
- No Godot run was needed because there were no product changes and the prompt prohibits redundant build work.
- `TASKS.md` remained byte-for-byte unchanged; ChatGPT alone owns tracker transitions and independent audit.
- Local owner changes remain dirty but unstaged and uncommitted; the tracked-only safety stash remains retained. The canonical checkout was not cleaned or used as disposable state.
- Validation command: `git diff --cached --check` must pass before commit. Final publication must verify `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` are identical, with 0/0 ahead/behind. Those exact final SHAs are emitted in the handoff after push.

Required stop marker: `AWAITING_GPT_M28_MILESTONE_AUDIT`.
