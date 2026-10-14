# R04-002 — AdMob v7.0 source and compatibility review

Result: **PIN VERIFIED; source review complete; integration deferred.**

GitHub release metadata and tag ref identify v7.0 commit `4b4ddceab0be81f0dcb12a6313038dba6cf9eacf`. The 265,845-byte Android ZIP was downloaded outside the repository and SHA-256 verified against the release API digest `ce38b75aeb4bb870fda8b74e1513d807696d8485d237c263b7b7a9613493aee8`. The release states Godot 4.7 support. The Android package includes GDScript wrappers and debug/release AARs; the ZIP contains no license file. The v7.0 source tag has MIT terms.

Issue #124 is still open/reported/not investigated. One reporter describes an Android AAR discovery failure and a manual copy workaround. This is a single report, not proof of a general defect. The package does not expose a reproducible Google Mobile Ads SDK Maven version in the inspected export metadata. No Android build was available to test dependency resolution.
