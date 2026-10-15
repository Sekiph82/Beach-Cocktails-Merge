Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$watchdog = Join-Path $repoRoot "tools/campaign/m34_r14_process_watchdog.ps1"
$probe = Join-Path $repoRoot "tools/campaign/m34_r16_outcome_pilot.gd"
$evidenceDir = Join-Path $repoRoot "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R16/pilot_attempt03"
$reportPath = Join-Path $evidenceDir "outcome_qualification_report.json"
$trialTimeoutSeconds = 15
$controllerBudgetSeconds = 540
$started = [Diagnostics.Stopwatch]::StartNew()
$trialSpecs = @(
	[pscustomobject]@{island="sunny_cove";level=1;seed=34116001;band="early"},
	[pscustomobject]@{island="sunny_cove";level=40;seed=34116040;band="mid"},
	[pscustomobject]@{island="tiki_island";level=30;seed=34116130;band="early_mid"},
	[pscustomobject]@{island="coconut_beach";level=70;seed=34116270;band="late"},
	[pscustomobject]@{island="final_island";level=85;seed=34116885;band="late"},
	[pscustomobject]@{island="final_island";level=100;seed=34116100;band="endgame"}
)
$policies = @("WEAK_V02", "MERGE_AWARE_V01")
$trials = [System.Collections.Generic.List[object]]::new()
foreach ($spec in $trialSpecs) {
	foreach ($policy in $policies) {
		$trials.Add([ordered]@{
			trial_id="base_$($spec.island)_l$($spec.level)_$policy"
			case=[ordered]@{island_id=$spec.island;level_id=$spec.level;seed=$spec.seed;difficulty_band=$spec.band;policy=$policy;replay=$false}
			status="NOT_STARTED";classification="BUDGET_UNKNOWN";reason="NOT_RUN_WITHIN_GLOBAL_BUDGET"
			result_file=$null;progress_file=$null;watchdog_file=$null;elapsed_wall_ms=$null;retry_verification=$null
		})
	}
}
$report = [ordered]@{
	schema_version=1;work_item="BCM-M34-R16";status="RUNNING";started_utc=[DateTime]::UtcNow.ToString("o")
	physics_mode="standard_fps_production_physics";fixed_fps=$false;time_scale=1.0
	controller_global_budget_seconds=$controllerBudgetSeconds;external_global_watchdog_seconds=600;per_trial_external_watchdog_seconds=$trialTimeoutSeconds
	trial_level_count=$trialSpecs.Count;island_count=@($trialSpecs.island | Sort-Object -Unique).Count;policy_count=$policies.Count
	planned_base_trials=$trials.Count;normal_4t_cap_source="canonical theoretical_shots_to_go * 4; optional VIP excluded"
	static_validation=[ordered]@{status="PENDING";validated_level_records=0;expected_level_records=1000}
	classification_policy="WIN_OBSERVED and LOSS_OBSERVED are observed terminal outcomes; BUDGET_UNKNOWN is not an impossibility finding; ERROR denotes invalid harness/evidence. Each observed WIN receives a standard-FPS action-log replay when global budget permits."
	human_fairness_ux="NOT_ASSESSED";owner_native_device_tests="DEFERRED"
	trials=@($trials);global_elapsed_ms=0;global_budget_exhausted=$false
}
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
function Write-Report {
	$report.global_elapsed_ms = [int]$started.Elapsed.TotalMilliseconds
	$temp = "$reportPath.tmp"
	$json = ($report | ConvertTo-Json -Depth 30).Replace("`r`n", "`n")
	[IO.File]::WriteAllText($temp, $json + "`n", [Text.UTF8Encoding]::new($false))
	Move-Item -LiteralPath $temp -Destination $reportPath -Force
}
function Invoke-PilotTrial([object]$entry, [string]$replayInput) {
	$trialId = [string]$entry.trial_id
	$safeId = $trialId -replace '[^A-Za-z0-9_-]', '_'
	$resultPath = Join-Path $evidenceDir "$safeId.json"
	$progressPath = Join-Path $evidenceDir "$safeId.progress.json"
	$watchdogPath = Join-Path $evidenceDir "$safeId.watchdog.json"
	$entry.status = "RUNNING"
	$entry.result_file = [IO.Path]::GetFileName($resultPath)
	$entry.progress_file = [IO.Path]::GetFileName($progressPath)
	$entry.watchdog_file = [IO.Path]::GetFileName($watchdogPath)
	$report.status = "RUNNING"
	Write-Report
	$case = $entry.case
	$arguments = @("--headless", "--path", $repoRoot, "--script", $probe, "--",
		"--r16-output=$resultPath", "--r16-progress=$progressPath",
		"--r16-island=$($case.island_id)", "--r16-level=$($case.level_id)", "--r16-seed=$($case.seed)", "--r16-policy=$($case.policy)")
	if (-not [string]::IsNullOrWhiteSpace($replayInput)) { $arguments += "--r16-replay-input=$replayInput" }
	$reuseExisting = (Test-Path -LiteralPath $watchdogPath -PathType Leaf) -and (Test-Path -LiteralPath $resultPath -PathType Leaf)
	if (-not $reuseExisting) {
		& $watchdog -FilePath $godot -ArgumentList $arguments -TimeoutSeconds $trialTimeoutSeconds -ResultPath $watchdogPath -ProgressPath $progressPath -TaskName "BCM-M34-R16-$safeId"
		$watchdogExit = $LASTEXITCODE
	}
	$wd = if (Test-Path -LiteralPath $watchdogPath -PathType Leaf) { Get-Content -Raw -LiteralPath $watchdogPath | ConvertFrom-Json } else { $null }
	if ($reuseExisting) { $watchdogExit = if ($wd.status -eq "EXITED") { 0 } elseif ($wd.status -eq "TIMEOUT_TERMINATED") { 124 } else { 1 } }
	$probeResult = $null
	if (Test-Path -LiteralPath $resultPath -PathType Leaf) {
		try { $probeResult = Get-Content -Raw -LiteralPath $resultPath | ConvertFrom-Json } catch {}
	}
	$classification = "ERROR"
	$reason = if ($wd) { [string]$wd.reason } else { "WATCHDOG_RESULT_MISSING" }
	if ($wd -and $wd.status -eq "TIMEOUT_TERMINATED") { $classification = "BUDGET_UNKNOWN"; $reason = "EXTERNAL_TRIAL_WATCHDOG_TIMEOUT" }
	elseif ($wd -and $wd.status -eq "EXITED" -and $watchdogExit -eq 0 -and $probeResult) {
		$classification = [string]$probeResult.classification
		$reason = [string]$probeResult.terminal_reason
	} elseif ($wd -and $wd.status -eq "CHILD_ERROR" -and $probeResult -and [string]$probeResult.classification -eq "BUDGET_UNKNOWN") {
		$classification = "BUDGET_UNKNOWN"; $reason = [string]$probeResult.terminal_reason
	}
	$entry.status = if ($classification -eq "ERROR") { "ERROR" } else { "COMPLETE" }
	$entry.classification = $classification
	$entry.reason = $reason
	$entry.elapsed_wall_ms = if ($wd) { [int]$wd.wall_elapsed_ms } else { $null }
	$entry.watchdog_status = if ($wd) { [string]$wd.status } else { "MISSING" }
	$entry.watchdog_exit = $watchdogExit
	$entry.record_summary = if ($probeResult) {
		[ordered]@{static_validation_record_count=[int]$probeResult.static_validation_record_count;shots_used=[int]$probeResult.shots_used;normal_4t_shot_cap=[int]$probeResult.normal_4t_shot_cap;normal_objective_complete=[bool]$probeResult.normal_objective_complete;merge_count=[int]$probeResult.merge_count;normal_orders_completed=$probeResult.normal_orders_completed;normal_orders_remaining=$probeResult.normal_orders_remaining;action_count=[int]$probeResult.action_count;action_log_sha256=[string]$probeResult.action_log_sha256;physics_frames_observed=[int]$probeResult.physics_frames_observed;simulated_seconds=[double]$probeResult.simulated_seconds;stars=[int]$probeResult.star_cap_outcome}
	} elseif ($wd -and $wd.partial_progress) {
		[ordered]@{static_validation_record_count=[int]$wd.partial_progress.static_validation_record_count;partial_phase=[string]$wd.partial_progress.phase;actions_committed=[int]$wd.partial_progress.completed_actions;physics_frame=[int]$wd.partial_progress.physics_frame;merge_count=[int]$wd.partial_progress.merge_count;normal_orders_completed=$wd.partial_progress.normal_orders_completed;normal_orders_remaining=$wd.partial_progress.normal_orders_remaining}
	} else { $null }
	Write-Report
	Write-Host "R16_TRIAL id=$trialId classification=$classification watchdog=$(if($wd){$wd.status}else{'MISSING'}) wall_ms=$($entry.elapsed_wall_ms)"
	return $probeResult
}

$tasksBefore = (git -C $repoRoot hash-object TASKS.md).Trim()
$drive = [IO.Path]::GetPathRoot($env:TEMP).Substring(0,1)
$freeBytesBefore = (Get-Volume -DriveLetter $drive).SizeRemaining
$oldAppData = $env:APPDATA
$appDataRoot = Join-Path $env:TEMP ("BCM-M34-R16-userdata-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $appDataRoot | Out-Null
$env:APPDATA = $appDataRoot
try {
	foreach ($entry in $report.trials) {
		$secondsRemaining = $controllerBudgetSeconds - $started.Elapsed.TotalSeconds
		if ($secondsRemaining -lt 52) { $report.global_budget_exhausted = $true; break }
		$baseResult = Invoke-PilotTrial $entry ""
		if ($entry.classification -eq "ERROR") { $report.status = "ERROR"; break }
		if ($entry.classification -eq "WIN_OBSERVED") {
			$replayId = "retry_" + [string]$entry.trial_id.Substring(5)
			$retry = [ordered]@{
				trial_id=$replayId
				case=[ordered]@{island_id=$entry.case.island_id;level_id=$entry.case.level_id;seed=$entry.case.seed;difficulty_band=$entry.case.difficulty_band;policy=$entry.case.policy;replay=$true}
				status="NOT_STARTED";classification="BUDGET_UNKNOWN";reason="RETRY_NOT_RUN_WITHIN_GLOBAL_BUDGET"
				result_file=$null;progress_file=$null;watchdog_file=$null;elapsed_wall_ms=$null;retry_verification=$null
			}
			$report.trials += $retry
			$retryResult = $null
			if (($controllerBudgetSeconds - $started.Elapsed.TotalSeconds) -ge 25) {
				$basePath = Join-Path $evidenceDir $entry.result_file
				$retryResult = Invoke-PilotTrial $retry $basePath
				$retryActionHash = ""
				if ($retry.record_summary) { $retryActionHash = [string]$retry.record_summary.action_log_sha256 }
				$entry.retry_verification = [ordered]@{trial_id=$replayId;classification=$retry.classification;reason=$retry.reason;action_log_sha256=$retryActionHash}
			} else {
				$retry.status = "NOT_RUN_GLOBAL_BUDGET"
				$retry.reason = "INSUFFICIENT_REMAINING_GLOBAL_BUDGET_FOR_REQUIRED_WIN_REPLAY"
				$entry.retry_verification = [ordered]@{trial_id=$replayId;classification="BUDGET_UNKNOWN";reason=$retry.reason}
			}
			Write-Report
		}
	}
} finally {
	$env:APPDATA = $oldAppData
}
$tasksAfter = (git -C $repoRoot hash-object TASKS.md).Trim()
$recordsValidated = 0
foreach ($trial in $report.trials) {
	if ($trial.record_summary -and $trial.record_summary.Contains('static_validation_record_count')) { $recordsValidated = [Math]::Max($recordsValidated, [int]$trial.record_summary.static_validation_record_count) }
}
$report.static_validation = [ordered]@{status=if($recordsValidated -eq 1000){"PASS"}else{"UNVERIFIED"};validated_level_records=$recordsValidated;expected_level_records=1000;method="each probe loads canonical level data in FULL mode"}
$report.tasks_md_hash_before = $tasksBefore
$report.tasks_md_hash_after = $tasksAfter
$report.tasks_md_unchanged = ($tasksBefore -ceq $tasksAfter)
$isolatedBytes = if (Test-Path -LiteralPath $appDataRoot) { (Get-ChildItem -LiteralPath $appDataRoot -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum } else { 0 }
$cleanupStatus = "PRESERVED_AFTER_POLICY_REJECTION; no deletion retry"
$freeBytesAfter = (Get-Volume -DriveLetter $drive).SizeRemaining
$report.isolated_appdata_bytes_before_cleanup = $isolatedBytes
$report.isolated_appdata_cleanup = $cleanupStatus
$report.isolated_appdata_path = $appDataRoot
$report.free_bytes_before = $freeBytesBefore
$report.free_bytes_after = $freeBytesAfter
$report.free_bytes_reclaimed = $freeBytesAfter - $freeBytesBefore
$report.human_fairness_ux = "NOT_ASSESSED"
$report.owner_native_device_tests = "DEFERRED"
$report.finished_utc = [DateTime]::UtcNow.ToString("o")
$currentRunnerElapsedMs = [int]$started.Elapsed.TotalMilliseconds
$priorAttemptWatchdogs = @(
	(Join-Path (Split-Path -Parent $evidenceDir) 'global_pilot_watchdog.json'),
	(Join-Path (Split-Path -Parent $evidenceDir) 'pilot_attempt02/global_pilot_watchdog.json'),
	(Join-Path $evidenceDir 'global_pilot_watchdog.json')
)
$priorAttemptElapsedMs = 0
foreach ($watchdogFile in $priorAttemptWatchdogs) {
	if (Test-Path -LiteralPath $watchdogFile) {
		try { $priorAttemptElapsedMs += [int](Get-Content -Raw -LiteralPath $watchdogFile | ConvertFrom-Json).wall_elapsed_ms } catch {}
	}
}
$report.current_runner_elapsed_ms = $currentRunnerElapsedMs
$report.completed_global_watchdog_elapsed_ms = $priorAttemptElapsedMs
$report.global_elapsed_ms = $priorAttemptElapsedMs + $currentRunnerElapsedMs
$report.task_global_budget_seconds = 720
$report.status = if ($report.status -eq "ERROR") { "PILOT_HAS_ERROR" } elseif ($report.global_budget_exhausted) { "PILOT_BUDGET_STOPPED_WITH_UNKNOWN_REMAINDER" } elseif (@($report.trials | Where-Object { $_.classification -eq "ERROR" }).Count -gt 0) { "PILOT_HAS_ERROR" } else { "PILOT_COMPLETE_WITH_OBSERVED_AND_UNKNOWN_OUTCOMES" }
$classificationCounts = @{}
foreach ($trial in $report.trials) {
	$key = [string]$trial.classification
	if ($classificationCounts.ContainsKey($key)) { $classificationCounts[$key] = [int]$classificationCounts[$key] + 1 } else { $classificationCounts[$key] = 1 }
}
$report.outcome_counts = $classificationCounts
$policySummary = [System.Collections.Generic.List[object]]::new()
foreach ($policy in $policies) {
	$items = @($report.trials | Where-Object { $_.case.policy -eq $policy -and -not $_.case.replay })
	$completed = @($items | Where-Object { $_.status -eq "COMPLETE" })
	$wins = @($items | Where-Object { $_.classification -eq "WIN_OBSERVED" }).Count
	$progressRatios = @($completed | Where-Object { $_.record_summary -and $_.record_summary.Contains('normal_orders_remaining') } | ForEach-Object {
		$remaining = $_.record_summary.normal_orders_remaining
		$total = 0; $left = 0
		foreach ($property in $remaining.PSObject.Properties) { $left += [int]$property.Value }
		$completedMap = $_.record_summary.normal_orders_completed
		foreach ($property in $completedMap.PSObject.Properties) { $total += [int]$property.Value }
		if(($left+$total) -gt 0){[Math]::Round($total/($left+$total),4)}else{0}
	})
	$policySummary.Add([ordered]@{policy=$policy;base_trial_count=$items.Count;completed_trial_count=$completed.Count;win_observed_count=$wins;loss_observed_count=@($items|Where-Object{$_.classification -eq 'LOSS_OBSERVED'}).Count;budget_unknown_count=@($items|Where-Object{$_.classification -eq 'BUDGET_UNKNOWN'}).Count;error_count=@($items|Where-Object{$_.classification -eq 'ERROR'}).Count;mean_wall_ms=if(@($completed.elapsed_wall_ms).Count){[Math]::Round(($completed|Measure-Object elapsed_wall_ms -Average).Average,1)}else{$null};mean_normal_order_completion_ratio=if($progressRatios.Count){[Math]::Round(($progressRatios|Measure-Object -Average).Average,4)}else{$null}})
}
$report.policy_summary = @($policySummary)
Write-Report
Write-Output "M34_R16_PILOT=$($report.status) base=$($report.planned_base_trials) trials=$($report.trials.Count) budget_ms=$($report.global_elapsed_ms) outcomes=$((ConvertTo-Json -Compress $report.outcome_counts)) tasks_unchanged=$($report.tasks_md_unchanged)"
if (-not $report.tasks_md_unchanged -or $report.status -eq "PILOT_HAS_ERROR") { exit 1 }
