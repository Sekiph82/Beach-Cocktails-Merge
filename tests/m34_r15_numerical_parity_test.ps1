param(
	[switch]$SelfTestOnly,
	[switch]$RecompareExisting
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
. (Join-Path $repoRoot "tools/campaign/m34_r15_numerical_parity_gate.ps1")

$adversarial = Test-R15AdversarialGate
if (-not $adversarial.pass) {
	$adversarial | ConvertTo-Json -Depth 20
	exit 1
}
Write-Output "R15_ADVERSARIAL_GATE=PASS branch=$($adversarial.branch_mutation_classification) collision=$($adversarial.collision_target_mutation_classification) numeric=$($adversarial.within_tolerance_numeric_only_classification)"
if ($SelfTestOnly) { exit 0 }

$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$watchdog = Join-Path $repoRoot "tools/campaign/m34_r14_process_watchdog.ps1"
$probe = Join-Path $repoRoot "tests/m34_r12_fixed_fps_parity_probe.gd"
$evidenceDir = Join-Path $repoRoot "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R15"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$cases = @(
	[pscustomobject]@{name="final_l100_seed_34112100_normal_repeat_a"; seed=34112100; mode="normal"},
	[pscustomobject]@{name="final_l100_seed_34112100_normal_repeat_b"; seed=34112100; mode="normal"},
	[pscustomobject]@{name="final_l100_seed_34112100_fixed_fps_60"; seed=34112100; mode="fixed_fps_60"},
	[pscustomobject]@{name="final_l100_seed_34112101_normal"; seed=34112101; mode="normal"},
	[pscustomobject]@{name="final_l100_seed_34112101_fixed_fps_60"; seed=34112101; mode="fixed_fps_60"},
	[pscustomobject]@{name="final_l100_seed_34112102_normal"; seed=34112102; mode="normal"},
	[pscustomobject]@{name="final_l100_seed_34112102_fixed_fps_60"; seed=34112102; mode="fixed_fps_60"}
)
$runs = @{}
foreach ($case in $cases) {
	$outputPath = Join-Path $evidenceDir "$($case.name).json"
	$watchdogPath = Join-Path $evidenceDir "$($case.name).watchdog.json"
	$progressPath = Join-Path $evidenceDir "$($case.name).progress.json"
	if ($RecompareExisting) {
		if (-not (Test-Path -LiteralPath $outputPath -PathType Leaf) -or -not (Test-Path -LiteralPath $watchdogPath -PathType Leaf)) { throw "Missing existing R15 run evidence for $($case.name)" }
		$watchdogExit = 0
	} else {
		$args = @("--headless", "--path", $repoRoot)
		if ($case.mode -eq "fixed_fps_60") { $args += @("--fixed-fps", "60") }
		$args += @("--script", $probe, "--", "--r12-output=$outputPath", "--r12-mode=$($case.mode)", "--r14-island=final_island", "--r14-level=100", "--r14-seed=$($case.seed)", "--r14-action-cap=20", "--r14-policy=WEAK_V02", "--r15-trace-interval=1")
		$timeout = if ($case.mode -eq "normal") { 30 } else { 15 }
		& $watchdog -FilePath $godot -ArgumentList $args -TimeoutSeconds $timeout -ResultPath $watchdogPath -ProgressPath $progressPath -TaskName "BCM-M34-R15-$($case.name)"
		$watchdogExit = $LASTEXITCODE
	}
	$watchdogResult = Get-Content -Raw -LiteralPath $watchdogPath | ConvertFrom-Json
	$probeResult = $null
	if (Test-Path -LiteralPath $outputPath -PathType Leaf) {
		try { $probeResult = Get-Content -Raw -LiteralPath $outputPath | ConvertFrom-Json } catch {}
	}
	$runs[$case.name] = [pscustomobject]@{exit=$watchdogExit;watchdog=$watchdogResult;probe=$probeResult}
	Write-Output "R15_RUN=$($case.name) exit=$watchdogExit status=$($watchdogResult.status) wall_ms=$($watchdogResult.wall_elapsed_ms) peak=$($probeResult.telemetry.peak_live_drinks) reason=$($probeResult.telemetry.terminal_reason) frames=$($probeResult.telemetry.physics_trace.Count)"
}

$pairs = [System.Collections.Generic.List[object]]::new()
function Add-R15Pair([string]$Name, [string]$NormalName, [string]$FixedName) {
	$n = $runs[$NormalName]
	$f = $runs[$FixedName]
	$normalOk = $null -ne $n.probe -and $n.watchdog.status -eq "EXITED" -and $n.exit -eq 0
	$fixedOk = $null -ne $f.probe -and $f.watchdog.status -eq "EXITED" -and $f.exit -eq 0
	$highDensity = $normalOk -and $fixedOk -and [int]$n.probe.telemetry.peak_live_drinks -ge 8 -and [int]$f.probe.telemetry.peak_live_drinks -ge 8
	$terminalReached = $normalOk -and $fixedOk -and $n.probe.telemetry.terminal_reason -notin @("PHYSICS_FRAME_BUDGET", "PER_LEVEL_SHOT_BUDGET", "PER_LEVEL_WALL_BUDGET", "REPLAY_ACTION_LOG_EXHAUSTED") -and $f.probe.telemetry.terminal_reason -notin @("PHYSICS_FRAME_BUDGET", "PER_LEVEL_SHOT_BUDGET", "PER_LEVEL_WALL_BUDGET", "REPLAY_ACTION_LOG_EXHAUSTED")
	$result = Compare-R15ParityPair $n.probe $f.probe ($normalOk -and $fixedOk -and $terminalReached) $highDensity
	$pairs.Add([pscustomobject]@{case=$Name; normal=$NormalName; comparison=$FixedName; high_density_reached=$highDensity; terminal_reached=$terminalReached; result=$result})
	Write-Output "R15_PAIR=$Name classification=$($result.classification) strict=$($result.strict_pass) frames=$($result.compared_frames) max_pos=$($result.max_position_delta_px) max_vel=$($result.max_velocity_delta_px_per_second) cumulative=$($result.max_cumulative_position_delta_sum_px)"
}

Add-R15Pair "repeatability_normal_seed_34112100" "final_l100_seed_34112100_normal_repeat_a" "final_l100_seed_34112100_normal_repeat_b"
Add-R15Pair "fps_comparison_seed_34112100" "final_l100_seed_34112100_normal_repeat_a" "final_l100_seed_34112100_fixed_fps_60"
Add-R15Pair "fps_comparison_seed_34112101" "final_l100_seed_34112101_normal" "final_l100_seed_34112101_fixed_fps_60"
Add-R15Pair "fps_comparison_seed_34112102" "final_l100_seed_34112102_normal" "final_l100_seed_34112102_fixed_fps_60"

$completedRuns = @($runs.Values | Where-Object {$null -ne $_.probe -and $_.watchdog.status -eq "EXITED" -and $_.exit -eq 0}).Count
$summary = [ordered]@{
	schema_version=1
	work_item="BCM-M34-R15"
	strict_gate="strict_bitwise_physics_parity"
	exploratory_gate="tolerant_candidate_only"
	preregistration="NUMERICAL_PARITY_GATE_PREREGISTRATION_V01.json"
	completed_runs=$completedRuns
	expected_runs=$cases.Count
	cases=@($pairs)
	adversarial_test=$adversarial
	fast_authoritative_solver_authorized=$false
	classification=@($pairs | ForEach-Object {$_.result.classification})
}
$summaryPath = Join-Path $evidenceDir "controlled_parity_summary.json"
$json = ($summary | ConvertTo-Json -Depth 80).Replace("`r`n", "`n")
[IO.File]::WriteAllText($summaryPath, $json + "`n", [Text.UTF8Encoding]::new($false))
if ($completedRuns -ne $cases.Count -or @($pairs | Where-Object {$_.result.classification -eq "unknown"}).Count -gt 0) { exit 1 }
exit 0
