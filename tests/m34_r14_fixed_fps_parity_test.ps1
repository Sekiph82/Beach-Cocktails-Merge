$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$watchdog = Join-Path $repoRoot "tools/campaign/m34_r14_process_watchdog.ps1"
$probe = Join-Path $repoRoot "tests/m34_r12_fixed_fps_parity_probe.gd"
$evidenceDir = Join-Path $repoRoot "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R14"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$cases = @(
	[pscustomobject]@{name="azure_l1_seed_34112001"; island="azure_bay"; level=1; seed=34112001; shots=6; policy="CHEAP_MERGE_CENTER_V01"; high_density=$false},
	[pscustomobject]@{name="azure_l1_seed_34112002"; island="azure_bay"; level=1; seed=34112002; shots=6; policy="CHEAP_MERGE_CENTER_V01"; high_density=$false},
	[pscustomobject]@{name="azure_l1_seed_34112003"; island="azure_bay"; level=1; seed=34112003; shots=6; policy="CHEAP_MERGE_CENTER_V01"; high_density=$false},
	[pscustomobject]@{name="final_l100_high_density_seed_34112100"; island="final_island"; level=100; seed=34112100; shots=20; policy="WEAK_V02"; high_density=$true}
)
$telemetryKeys = @("outcome", "terminal_reason", "shot_count", "merge_count", "contact_count", "rail_contact_count", "elapsed_sec", "normal_objective_complete", "vip_complete", "action_log", "progress_curve", "normal_orders_completed", "normal_orders_remaining", "vip_state", "moves_used", "move_limit", "moves_remaining", "physics_trace", "peak_live_drinks", "peak_board_occupancy")
$caseResults = [System.Collections.Generic.List[object]]::new()

function Get-TraceDivergence($NormalProbe, $FixedProbe) {
	if ($null -eq $NormalProbe -or $null -eq $FixedProbe) { return $null }
	$normalTrace = $NormalProbe.telemetry.physics_trace
	$fixedTrace = $FixedProbe.telemetry.physics_trace
	for ($sample = 0; $sample -lt [Math]::Min($normalTrace.Count, $fixedTrace.Count); $sample++) {
		if ($normalTrace[$sample].sha256 -ceq $fixedTrace[$sample].sha256) { continue }
		$normalState = $normalTrace[$sample].state
		$fixedState = $fixedTrace[$sample].state
		$positionDiffs = [System.Collections.Generic.List[object]]::new()
		$maxDelta = 0.0
		$differenceCount = 0
		for ($body = 0; $body -lt [Math]::Min($normalState.bodies.Count, $fixedState.bodies.Count); $body++) {
			for ($axis = 0; $axis -lt 2; $axis++) {
				$delta = [math]::Abs([double]$normalState.bodies[$body].position[$axis] - [double]$fixedState.bodies[$body].position[$axis])
				if ($delta -le 0.0) { continue }
				$differenceCount++
				if ($delta -gt $maxDelta) { $maxDelta = $delta }
				if ($positionDiffs.Count -lt 12) {
					$positionDiffs.Add([pscustomobject]@{body_index=$body;level=$normalState.bodies[$body].level;axis=if($axis -eq 0){"x"}else{"y"};normal_position=$normalState.bodies[$body].position[$axis];fixed_position=$fixedState.bodies[$body].position[$axis];absolute_delta_px=$delta})
				}
			}
		}
		return [pscustomobject]@{first_sample_index=$sample;frame=$normalTrace[$sample].frame;normal_state_sha256=$normalTrace[$sample].sha256;fixed_state_sha256=$fixedTrace[$sample].sha256;max_absolute_position_delta_px=$maxDelta;different_position_components=$differenceCount;sample_position_differences=@($positionDiffs)}
	}
	return $null
}

foreach ($case in $cases) {
	$modes = @{}
	foreach ($mode in @("normal", "fixed_fps_60")) {
		$outputPath = Join-Path $evidenceDir "$($case.name)_$mode.json"
		$watchdogPath = Join-Path $evidenceDir "$($case.name)_$mode.watchdog.json"
		$progressPath = Join-Path $evidenceDir "$($case.name)_$mode.progress.json"
		$args = @("--headless", "--path", $repoRoot)
		if ($mode -eq "fixed_fps_60") { $args += @("--fixed-fps", "60") }
		$args += @("--script", $probe, "--", "--r12-output=$outputPath", "--r12-mode=$mode", "--r14-island=$($case.island)", "--r14-level=$($case.level)", "--r14-seed=$($case.seed)", "--r14-action-cap=$($case.shots)", "--r14-policy=$($case.policy)")
		$timeout = if ($case.high_density -and $mode -eq "normal") { 40 } elseif ($mode -eq "normal") { 15 } else { 15 }
		& $watchdog -FilePath $godot -ArgumentList $args -TimeoutSeconds $timeout -ResultPath $watchdogPath -ProgressPath $progressPath -TaskName "BCM-M34-R14-PARITY-$($case.name)-$mode"
		$watchdogExit = $LASTEXITCODE
		$watchdogResult = Get-Content -Raw -LiteralPath $watchdogPath | ConvertFrom-Json
		$probeResult = $null
		if (Test-Path -LiteralPath $outputPath -PathType Leaf) {
			try { $probeResult = Get-Content -Raw -LiteralPath $outputPath | ConvertFrom-Json } catch {}
		}
		$modes[$mode] = [pscustomobject]@{exit=$watchdogExit;watchdog=$watchdogResult;probe=$probeResult;output_path=$outputPath}
	}
	$normal = $modes["normal"].probe
	$fixed = $modes["fixed_fps_60"].probe
	$mismatches = [System.Collections.Generic.List[string]]::new()
	if ($null -eq $normal -or $null -eq $fixed) { $mismatches.Add("MISSING_MODE_RESULT") }
	else {
		foreach ($key in @("island_id", "level_id", "seed", "policy", "action_cap", "physics_frame_ceiling", "physics_ticks_per_second")) {
			if ((ConvertTo-Json -InputObject $normal.$key -Compress -Depth 20) -cne (ConvertTo-Json -InputObject $fixed.$key -Compress -Depth 20)) { $mismatches.Add("FIELD:$key") }
		}
		foreach ($key in $telemetryKeys) {
			if ((ConvertTo-Json -InputObject $normal.telemetry.$key -Compress -Depth 30) -cne (ConvertTo-Json -InputObject $fixed.telemetry.$key -Compress -Depth 30)) { $mismatches.Add("TELEMETRY:$key") }
		}
	}
	$normalOk = $modes["normal"].watchdog.status -eq "EXITED" -and $modes["normal"].exit -eq 0
	$fixedOk = $modes["fixed_fps_60"].watchdog.status -eq "EXITED" -and $modes["fixed_fps_60"].exit -eq 0
	$highDensityReached = $case.high_density -and $null -ne $normal -and $null -ne $fixed -and [int]$normal.telemetry.peak_live_drinks -ge 8 -and [int]$fixed.telemetry.peak_live_drinks -ge 8
	$traceDivergence = Get-TraceDivergence $normal $fixed
	if (-not $normalOk) { $mismatches.Add("NORMAL_PROCESS_NOT_COMPLETED") }
	if (-not $fixedOk) { $mismatches.Add("FIXED_PROCESS_NOT_COMPLETED") }
	if ($case.high_density -and -not $highDensityReached) { $mismatches.Add("HIGH_DENSITY_THRESHOLD_NOT_REACHED") }
	$caseResults.Add([pscustomobject]@{
		case=$case.name; island_id=$case.island; level_id=$case.level; seed=$case.seed; policy=$case.policy
		action_cap=$case.shots; high_density_required=$case.high_density; high_density_reached=$highDensityReached
		normal_status=$modes["normal"].watchdog.status; normal_wall_ms=$modes["normal"].watchdog.wall_elapsed_ms
		fixed_status=$modes["fixed_fps_60"].watchdog.status; fixed_wall_ms=$modes["fixed_fps_60"].watchdog.wall_elapsed_ms
		normal_peak_live_drinks=if ($normal) {$normal.telemetry.peak_live_drinks} else {$null}
		fixed_peak_live_drinks=if ($fixed) {$fixed.telemetry.peak_live_drinks} else {$null}
		normal_merges=if ($normal) {$normal.telemetry.merge_count} else {$null}
		fixed_merges=if ($fixed) {$fixed.telemetry.merge_count} else {$null}
		normal_contacts=if ($normal) {$normal.telemetry.contact_count} else {$null}
		fixed_contacts=if ($fixed) {$fixed.telemetry.contact_count} else {$null}
		parity_pass=($mismatches.Count -eq 0); mismatches=@($mismatches); trace_divergence=$traceDivergence
		normal_probe=[IO.Path]::GetFileName($modes["normal"].output_path); fixed_probe=[IO.Path]::GetFileName($modes["fixed_fps_60"].output_path)
	})
}
$allPass = @($caseResults | Where-Object { -not $_.parity_pass }).Count -eq 0
$report = [ordered]@{
	schema_version=1
	work_item="BCM-M34-R14-002"
	gate=if ($allPass) {"FIXED_FPS_PARITY_PROVEN_FOR_LISTED_COHORTS"} else {"REFUSE_FAST_SOLVER_MODE_PARITY_NOT_PROVEN"}
	comparison="same production ShotController and full Godot physics; compare action log, every 15-frame state trace, merge/contact counts, objective and terminal state"
	compared_telemetry_keys=$telemetryKeys
	thresholds=@{high_density_minimum_peak_live_drinks=8;normal_wall_timeout_sec=40;fixed_wall_timeout_sec=15}
	cases=@($caseResults)
	parity_pass=$allPass
}
$reportPath = Join-Path $evidenceDir "fixed_fps_parity.json"
$reportJson = ($report | ConvertTo-Json -Depth 30).Replace("`r`n", "`n")
[IO.File]::WriteAllText($reportPath, $reportJson + "`n", [Text.UTF8Encoding]::new($false))
Write-Output "M34_R14_FIXED_FPS_PARITY=$($report.gate) cases=$($caseResults.Count)"
if (-not $allPass) { exit 1 }
