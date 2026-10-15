# BCM-M34-R16 Independent Audit V01

Reviewed on GitHub: V01 builder log, superseding V04 hash correction, final pilot_attempt03 report. Evidence audit, not rerun locally.

**Verdict: ACCEPT R16 limited six-level pilot and regression evidence; M33-004 remains OPEN.**
- Twelve base attempts (six levels across four islands, two policies): two WIN_OBSERVED both Sunny Cove L1 (nine shots each versus 16-shot 4T cap), nine BUDGET_UNKNOWN, one ERROR (Tiki Island L30 MERGE_AWARE exit -1); no observed losses. Two same-seed replay wins additionally succeeded. Total four observed successful trials, **only one distinct level** physically won in final pilot.
- All 1000 canonical records passed static database validation, which is not proof of 1000 physically winnable levels. 10/10 regression groups passed per Codex, fresh import exit 0. GPT did not rerun.
- Partial snapshots of four earlier trial attempts were overwritten during report-rebuild recovery; they cannot be independently reconstructed from final trace files. Keep the evidence limitation and ensure append-only per-attempt traces in next round.
- Two policies have no reliable efficacy comparison from two wins on the easiest level; short 15-second watchdogs censor harder levels, cannot infer impossibility. One child exit -1 needs root-cause triage before scaling.
- V04 corrects TASKS.md blob ID versus raw SHA-256 confusion, and confirms Codex left TASKS unchanged. Eight tracked / 15 untracked owner Desktop paths preserved per builder, Desktop not post-publication synced; r15_parse_probe.json remains and must not cause new cleanup gate. No GB cleanup proven.
- Performance extrapolation ~8.9–17.8 hours or more is rough and not a guarantee. R16 provides no human-play difficulty proof; M33-004 OPEN.

**Next R17 recommendation:** Root-cause Tiki L30 exit -1; eliminate overwriting earlier pilot traces, add append-only indexed attempt IDs and safe restore; tune diagnostic throughput/coverage with 3–6 carefully chosen levels and sensible budgets or focus an instrumented manual Godot test studio plan. Preserve physics, 4T/no timer/energy and owner files. Avoid another expensive 1000-level blind brute-force campaign.
