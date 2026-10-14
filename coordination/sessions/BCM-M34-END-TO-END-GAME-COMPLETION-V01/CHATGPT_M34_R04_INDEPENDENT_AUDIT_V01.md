# BCM-M34-R04 Independent Audit V01

**Verdict: PASS for the R04 investigation and evidence, BLOCKED for native implementation/device qualification.** This does not close M34-006 or M34-007.

Read directly on GitHub: `docs/codex-logs/CODEX_LOG_M34_R04_ANDROID_REWARDED_ADS_MASTER_V01.md`, `evidence/M34-R04/desktop_readonly_merge_proposal.md`, and current `TASKS.md`. The builder reports Godot 4.7.2 Daily/Economy/M33 navigation tests PASS. No Android toolchain, export template, app build, device ad playback or SDK integration was performed; no native rewards can be claimed. Verified published AdMob v7.0 binary hash is provenance only. Core integration issue: provider reward callback lacks the server-verifiable receipt demanded by the existing abstraction. A native SDK earned callback is not itself a signed receipt; the next phase must decide an honest auditable verification architecture rather than fabricate one. Native IAP receipts are separately high-trust and must never be conflated with ad reward events.

**Improved sync finding:** R04 read-only 3-way comparison shows 7 owner-dirty tracked paths (6 JSON, project.godot), with identical old HEAD and remote blobs at each path. Thus no incoming path-content collisions for those 7 tracked files at the tested remote revision; previous claim of exactly two overlaps is superseded for that revision. This is not proof of zero collision with untracked files or later remote updates. A careful hash-verified, tracked-only preservation/sync could be possible, but no canonical checkout was modified. Owner untracked files and Godot user data must remain untouched.

23 cleanup assets are KEEP for documented provenance; no deleted source bytes or measured release-size reduction. Two old scene UID warnings still present and text-path fallback works.

**Next:** narrowly scoped setup readiness and callback trust-design master; do not require expensive toolchain downloads until reviewed. No source changes to ads/payment beyond bounded verified steps, no store release, no unsafe Desktop sync. Independent audit source/evidence only, no Windows Godot execution performed here.
