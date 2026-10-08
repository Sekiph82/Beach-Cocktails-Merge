# BCM-M23-R02 Independent Audit V01

**CHANGES_REQUIRED / OWNER_VISUAL_REJECTED.**

Read current R02 visibility diagnostic report, builder log, installed GFF color target and current PresentationFeedbackBridge. Owner tested a real Godot run and reported that current effects are too strong and some color changes persist. Previous M23 visual pass was also withheld because effects were imperceptible. The accepted target is **midpoint between prior M23 and R02**, not either extreme.

Source finding: R02 boosted Spark sizes to 5–8 px and added bright cyan/yellow particle colors and strong tint settings. GFFColorTarget.apply_params now sets target_color per call, and apply_value alters CanvasItem.modulate. Code review establishes credible residual color/overlap risk but does NOT prove root cause of sticky colors. Require lifecycle/restore instrumentation and overlap tests. R02 report says layer A/B did not demonstrate occlusion, and most issue was size/contrast/very short windows; do not move canvas layers without evidence. Reported M23/M22/M02/M09/M15/M21 progression checks PASS, but **M21 mobile QA failed** (720x1440 World Map check plus 0 headless captures), so full master regression cannot be marked PASS; preserve this as separate open finding, do not falsely claim M21 visual QA closure.

Owner screenshot is a static frame not a temporal proof of color restoration. Real native owner feedback overrides builder impression. M24 blocked. Root TASKS.md modified only by ChatGPT.
