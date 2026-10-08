# BCM-M23-R02 Combined Visual Remediation Master

Repository: Sekiph82/Beach-Cocktails-Merge
Local: C:\Users\sekip\Desktop\Beach Cocktails - Merge
Branch: main

## First action: safe sync
Record HEAD, origin/main, live main, git status, stashes and owner-local paths. Fetch and fast-forward only when safe. Preserve both untracked owner PNGs and every owner-local modification. No reset --hard, git clean, forced checkout, automated rebase, force push or destructive stash. Stop on unresolved collisions.

## Required combined execution
Read and execute the **currently active** `coordination/sessions/BCM-M23-MASTER-V01/BCM-M23-R01_REMEDIATION_PROMPT.md` and its locked `BCM-M23-R01_AUDIT_CRITERIA_V01.md`, plus owner rejection, M22 owner-approved effect matrix, M23 source audit, AGENTS.md and root TASKS.md. This R02 is a *supplement to* R01, not a replacement: execute **both as one continuous remediation**, one coordinated implementation, tests, evidence and publication. Do not skip any R01 acceptance criterion. Root TASKS.md is read-only for Codex.

## Extra investigation mandatory BEFORE visual changes

### A. Canvas draw order and visibility
Inspect actual installed addons/saltmire_spark/spark.gd, scenes and all live CanvasLayers. Spark currently constructs a Node2D pool under its autoload, not a CanvasLayer; emitter z_index=100 does not automatically override higher CanvasLayers. Measure the effective canvas/layer of table background, cocktails, gameplay overlay, HUD, Spark pool and each emitter. Check parent visibility, clips, modulate/self_modulate alpha, coordinate spaces (global positions vs canvas transforms), viewport cropping, size/radius, and actual drawn pixels. Create real-renderer A/B evidence: unchanged scene versus *temporary test-only* emitter on a confirmed above-table presentation layer. Diagnose whether occlusion exists, do not assume it.

### B. FPS, frame duration, size and contrast
Instrument actual FPS/frame delta, dropped frames and per-burst rendered-frame count at observed laptop performance and controlled 15/30/60 FPS conditions. Current FULL durations: launch 0.14s, contact 0.16s, merge BASE 0.28s, SURGE 0.30s, PEAK 0.35s, score GFF 0.20s. Spark hit defaults to 3px particle radius shrinking to zero. Determine if particles are rendered but too small/low contrast or appear for too few frames. Make temporary test-only A/B comparisons using high-contrast color, enlarged radius and an instrumented rendering layer. Document frame counts, coordinates and visibility with genuine graphical screenshots/video, not dummy headless captures.

### C. Production event trace
For each owner-rejected category (launch, contact, merge, BASE, SURGE, PEAK, score), trace semantic emission -> bridge -> policy validation -> plugin call -> emitter creation -> actual canvas visibility, with event IDs, trigger timestamp, target, viewport position, effective CanvasLayer, accepted particle amount, duration and measured FPS. Classify each missing effect by root cause: not emitted, not dispatched, occluded, incorrect coordinates, too small/short/low contrast, or not verified.

## Fix and limits
Implement the smallest production presentation-only changes supported by actual APIs and observed evidence. Place Spark visibly over the table but do not cover HUD or affect input; keep distinct readable BASE/SURGE/PEAK intensities. Never use forbidden GFF camera, physics, velocity, impulse, freeze-frame, time-scale, or root/collider/rail transforms. No score/economy/save/gameplay changes. Honor owner-approved M22 hard limits: FULL launch <=4/0.14s, contact <=5/0.16s, BASE <=10/0.28s, SURGE <=10/0.30s, PEAK <=18/0.35s, max 48 gameplay live particles. REDUCED merge always zero particles. Do not lengthen beyond those limits without explicit owner approval; favor visibility via layering/size/contrast within valid API. Remove diagnostic-only alterations from shipping.

## Test, publish and stop
Run all R01 locked criteria plus new layer/FPS/real-renderer evidence. Full M23/M22 and critical M21/M15/M09/M02 suites, Godot import/boot, GFF cleanup regression, exact-once, plugin fallback, authority hash parity, caps, source call scan, git diff --check. Create trace and A/B evidence under coordination/sessions/BCM-M23-MASTER-V01/evidence/M23-R02/ and log docs/codex-logs/CODEX_LOG_M23_R02.md. If real-renderer proof unavailable, state SOURCE_VALIDATED_OWNER_VISUAL_PENDING and never claim visual PASS. Commit/push, verify local HEAD=origin/main=live main with 0/0 divergence, preserve owner PNGs, do not edit TASKS.md, do not begin M24.

STOP: AWAITING_GPT_M23_R02_REAUDIT
