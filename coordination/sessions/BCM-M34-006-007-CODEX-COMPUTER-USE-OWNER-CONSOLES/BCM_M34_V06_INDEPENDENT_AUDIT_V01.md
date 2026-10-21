# BCM-M34-006/007 V06 Independent Audit V01
Date: 2026-10-21. Audited builder main 994acd542096aaaeee118a62378d63dae4b584de; product commit 4f278c4c09eea73d859477fb5e127b6e35689794. This is an immutable audit, not a tracker; only root TASKS.md records active status.

VERDICT: CONDITIONAL PASS. The V05 Android sparse index limitation is resolved at source and submitted evidence level. The preview AAB is builder-validated, but Godot command exited abnormally and physical APK/AAB bytes were not independently accessible to reviewer. Both public stores remain NO-GO; M34-006/007 BLOCKED; 146/148 unchanged.

Source review: tools/release/inspect_sparse_android_apk.py reads version-pinned Godot PCK v4 sparse flags 6, normalizes indexed external paths, validates ZIP asset length, MD5/SHA-256 and forbidden file classes, rejects unknown flags/traversal/duplicates, enumerates unindexed ZIP assets and does not modify APK. 9 synthetic focused negative/positive cases in tests/test_sparse_android_apk.py; builder reports 9/9 pass. Version-pinned original Godot source was checked; its PACK_SPARSE_BUNDLE branch opens external referenced files, matching the parser strategy.

Builder V05 APK SHA256 126e30713ab1c9687277899ab3c8eed44f1f53b988f583ce1d8a1b537e9bd92b, size 198927159 bytes. Reported sparse directory references: 1054 all mapped to 117390634 actual APK asset bytes; 0 missing/MD5 mismatch/forbidden, exactly 1 unindexed legitimate Godot command flags file assets/_cl_ 94 bytes. Indexed plus extra equals 117390728 expanded asset bytes. The claims are coherent with submitted JSON but not independently rehashed on owner PC.

New local nonshipping Android AAB size 147028717 bytes, SHA256 b22ba20b3ff1bf5b3b77f9077f7a67b9783b1e3e8d44581fcbca90bab3985c15. Codex reports bundletool 1.16.0 validate PASS, base+install-time asset pack, same indexed payload manifest, preview package com.sekiph82.beachcocktails.m34preview, target SDK36/min24, INTERNET only, ARM64 16KiB ELF align, debuggable, no production upload key. Future AdMob source preserved; ad placements and in-app purchases OFF. Not Play production approved.

MAJOR CAVEAT: Gradle logged BUILD SUCCESSFUL but the owner-local Godot export process did not close and the task-owned PID was terminated; wrapper exit -1. This is not a clean reproducible export. Codex restored project.godot, reports no owner file touch, no emulator, GitHub Actions, SDK license action, store operation or root TASKS modification. Preserve this exact negative result and investigate narrowly, without claiming AAB export fully PASS.

Next: one bounded investigation of Godot hanging export process and reproducibility, plus genuine store marketing polish and Apple/Google publication prerequisites. No further PCK cleanup cycles without fresh evidence. No source deletion, owner real save access, Play/Apple account changes, ads/purchases or publication.

FINAL: V06 source/manifest technical acceptance CONDITIONAL PASS; real store release NO-GO, canonical 146/148 unchanged.
