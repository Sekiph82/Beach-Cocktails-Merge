$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$watchdog = Join-Path $repoRoot "tools/campaign/m34_r14_process_watchdog.ps1"
$probe = Join-Path $repoRoot "tools/campaign/m34_r14_bounded_path_probe.gd"
$evidenceDir = Join-Path $repoRoot "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R14"
$parityPath = Join-Path $evidenceDir "fixed_fps_parity.json"
$summaryPath = Join-Path $evidenceDir "exact_4t_solver_summary.json"
$parity = Get-Content -Raw -LiteralPath $parityPath | ConvertFrom-Json
$cases = @(
	[pscustomobject]@{name="azure_bay_l1_early";island="azure_bay";level=1;seed=34113001},
	[pscustomobject]@{name="sunny_cove_l50_middle";island="sunny_cove";level=50;seed=34113050},
	[pscustomobject]@{name="final_island_l100_late";island="final_island";level=100;seed=34113100}
)
$records = [System.Collections.Generic.List[object]]::new()
$base = [ordered]@{
	schema_version=1
	work_item="BCM-M34-R14-003"
	gate=@{parity_pass=[bool]$parity.parity_pass;source=$parityPath;fast_solver_mode_allowed=[bool]$parity.parity_pass}
	per_case_wall_watchdog_seconds=12
	internal_wall_budget_seconds=8
	physics_frame_budget="exact_4T legal_shot_ceiling * 60 plus at most 90 settle frames"
	backtracking_attempt_cap=0
	classification_categories=@("WIN_PROVEN", "LEGAL_PATH_NOT_FOUND_WITHIN_BUDGET", "UNKNOWN_TIMEOUT", "ERROR")
	cases=@()
}
if (-not $parity.parity_pass) {
	foreach ($case in $cases) {
		$records.Add([pscustomobject]@{case=$case.name;island_id=$case.island;level_id=$case.level;seed=$case.seed;classification="SKIPPED_GATE_NOT_PROVEN";reason="HIGH_DENSITY_FIXED_FPS_PARITY_FAILED; fast solver mode is prohibited"})
	}
	$base.status = "SKIPPED_PARITY_GATE_FAILED"
	$base.stop_reason = "REFUSE_FAST_SOLVER_MODE_PARITY_NOT_PROVEN"
	$base.cases = @($records)
	$summaryJson = ($base | ConvertTo-Json -Depth 12).Replace("`r`n", "`n")
	[IO.File]::WriteAllText($summaryPath, $summaryJson + "`n", [Text.UTF8Encoding]::new($false))
	Write-Output "M34_R14_EXACT_4T_SOLVER=SKIPPED_PARITY_GATE_FAILED"
	exit 0
}

$base.status = "RUNNING"
$base.stop_reason = "IN_PROGRESS"
$base.cases = @()
$summaryJson = ($base | ConvertTo-Json -Depth 12).Replace("`r`n", "`n")
[IO.File]::WriteAllText($summaryPath, $summaryJson + "`n", [Text.UTF8Encoding]::new($false))
foreach ($case in $cases) {
	$outputPath = Join-Path $evidenceDir "$($case.name).json"
	$progressPath = Join-Path $evidenceDir "$($case.name).progress.json"
	$watchdogPath = Join-Path $evidenceDir "$($case.name).watchdog.json"
	$args = @("--headless", "--fixed-fps", "60", "--path", $repoRoot, "--script", $probe, "--", "--r14-output=$outputPath", "--r14-progress=$progressPath", "--r14-island=$($case.island)", "--r14-level=$($case.level)", "--r14-seed=$($case.seed)")
	& $watchdog -FilePath $godot -ArgumentList $args -TimeoutSeconds 12 -ResultPath $watchdogPath -ProgressPath $progressPath -TaskName "BCM-M34-R14-SOLVER-$($case.name)"
	$watchdogExit = $LASTEXITCODE
	$watchdogResult = Get-Content -Raw -LiteralPath $watchdogPath | ConvertFrom-Json
	$probeResult = $null
	if (Test-Path -LiteralPath $outputPath -PathType Leaf) { try { $probeResult = Get-Content -Raw -LiteralPath $outputPath | ConvertFrom-Json } catch {} }
	if ($watchdogResult.status -eq "TIMEOUT_TERMINATED") { $classification = "UNKNOWN_TIMEOUT"; $reason = "PROCESS_WALL_TIMEOUT" }
	elseif ($watchdogResult.status -eq "EXITED" -and $watchdogExit -eq 0 -and $probeResult) { $classification = [string]$probeResult.classification; $reason = [string]$probeResult.terminal_reason }
	else { $classification = "ERROR"; $reason = [string]$watchdogResult.reason }
	$records.Add([pscustomobject]@{case=$case.name;island_id=$case.island;level_id=$case.level;seed=$case.seed;classification=$classification;reason=$reason;watchdog_status=$watchdogResult.status;probe_file=[IO.Path]::GetFileName($outputPath);progress_file=[IO.Path]::GetFileName($progressPath);partial_progress=$watchdogResult.partial_progress})
	$base.cases = @($records)
	$base.status = "RUNNING"
	$base.stop_reason = "IN_PROGRESS"
	$summaryJson = ($base | ConvertTo-Json -Depth 20).Replace("`r`n", "`n")
	[IO.File]::WriteAllText($summaryPath, $summaryJson + "`n", [Text.UTF8Encoding]::new($false))
	if ($classification -in @("UNKNOWN_TIMEOUT", "ERROR")) { break }
}
$base.status = if (@($records | Where-Object {$_.classification -in @("UNKNOWN_TIMEOUT", "ERROR")}).Count -gt 0) { "STOPPED_WITH_UNKNOWN_OR_ERROR" } else { "BOUNDED_CASES_COMPLETE" }
$base.stop_reason = if ($base.status -eq "STOPPED_WITH_UNKNOWN_OR_ERROR") { "FIRST_UNKNOWN_OR_ERROR_STOP" } else { "ALL_SELECTED_CASES_CLASSIFIED" }
$base.cases = @($records)
$summaryJson = ($base | ConvertTo-Json -Depth 20).Replace("`r`n", "`n")
[IO.File]::WriteAllText($summaryPath, $summaryJson + "`n", [Text.UTF8Encoding]::new($false))
Write-Output "M34_R14_EXACT_4T_SOLVER=$($base.status) cases=$($records.Count)"
