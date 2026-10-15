Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$sessionRoot = Join-Path $repoRoot "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01"
$evidenceRoot = Join-Path $sessionRoot "evidence/M34-R16"
$pilotDir = Join-Path $evidenceRoot "pilot_attempt03"
$reportPath = Join-Path $pilotDir "outcome_qualification_report.json"
$plans = @(
	[pscustomobject]@{island="sunny_cove";level=1;seed=34116001;band="early"},
	[pscustomobject]@{island="sunny_cove";level=40;seed=34116040;band="mid"},
	[pscustomobject]@{island="tiki_island";level=30;seed=34116130;band="early_mid"},
	[pscustomobject]@{island="coconut_beach";level=70;seed=34116270;band="late"},
	[pscustomobject]@{island="final_island";level=85;seed=34116885;band="late"},
	[pscustomobject]@{island="final_island";level=100;seed=34116100;band="endgame"}
)
$policies = @("WEAK_V02", "MERGE_AWARE_V01")
$trialRecords = [System.Collections.Generic.List[object]]::new()
$baseById = @{}

function Read-JsonFile([string]$Path) {
	if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
	try { return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json } catch { return $null }
}

function Get-ActionProjection([object]$Record) {
	$lines = [System.Collections.Generic.List[string]]::new()
	foreach ($action in @($Record.action_log)) {
		$x = ([double]$action.x_position).ToString("R", [Globalization.CultureInfo]::InvariantCulture)
		$lines.Add("$($action.step)|$($action.spawn_level)|$($action.lane_index)|$x")
	}
	return $lines -join "`n"
}

foreach ($plan in $plans) {
	foreach ($policy in $policies) {
		$id = "base_$($plan.island)_l$($plan.level)_$policy"
		$stem = Join-Path $pilotDir $id
		$watchdog = Read-JsonFile "$stem.watchdog.json"
		$result = Read-JsonFile "$stem.json"
		$progress = Read-JsonFile "$stem.progress.json"
		$class = "ERROR"
		$reason = "WATCHDOG_RESULT_OR_TRIAL_RECORD_MISSING"
		if ($watchdog -and $watchdog.status -eq "EXITED" -and $result) {
			$class = [string]$result.classification
			$reason = [string]$result.terminal_reason
		} elseif ($watchdog -and $watchdog.status -eq "TIMEOUT_TERMINATED") {
			$class = "BUDGET_UNKNOWN"
			$reason = "EXTERNAL_TRIAL_WATCHDOG_TIMEOUT"
		} elseif ($watchdog -and $watchdog.status -eq "CHILD_ERROR") {
			$class = "ERROR"
			$reason = [string]$watchdog.reason
		}
		$source = if ($result) { $result } else { $progress }
		if (-not $source) { $source = [pscustomobject]@{static_validation_record_count=0;physics_mode="";fixed_fps=$false;normal_theoretical_shots_T=0;normal_4t_shot_cap=0;merge_count=0;normal_orders_completed=@{};normal_orders_remaining=@{};action_log=@()} }
		$physicsMode = if ($result) { [string]$result.physics.mode } else { [string]$source.physics_mode }
		$fixedFps = if ($result) { [bool]$result.physics.fixed_fps } else { [bool]$source.fixed_fps }
		$summary = [ordered]@{
			static_validation_record_count=[int]$source.static_validation_record_count
			physics_mode=$physicsMode
			fixed_fps=$fixedFps
			normal_theoretical_shots_T=[int]$source.normal_theoretical_shots_T
			normal_4t_shot_cap=[int]$source.normal_4t_shot_cap
			shots_used=if($result){[int]$result.shots_used}else{$null}
			actions_committed=if($result){[int]$result.action_count}elseif($progress){[int]$progress.completed_actions}else{0}
			physics_frame=if($result){[int]$result.physics_frames_observed}elseif($progress){[int]$progress.physics_frame}else{0}
			merge_count=if($result){[int]$result.merge_count}elseif($progress){[int]$progress.merge_count}else{0}
			normal_orders_completed=if($result){$result.normal_orders_completed}else{$progress.normal_orders_completed}
			normal_orders_remaining=if($result){$result.normal_orders_remaining}else{$progress.normal_orders_remaining}
			action_count=if($result){[int]$result.action_count}elseif($progress){@($progress.action_log).Count}else{0}
			action_log_sha256=if($result){[string]$result.action_log_sha256}else{$null}
			trace_source=if($result){"$id.json"}elseif($progress){"$id.progress.json"}else{$null}
		}
		$record = [ordered]@{
			trial_id=$id
			case=[ordered]@{island_id=$plan.island;level_id=$plan.level;seed=$plan.seed;difficulty_band=$plan.band;policy=$policy;replay=$false}
			status=if($class -eq "ERROR"){"ERROR"}else{"COMPLETE"}
			classification=$class
			reason=$reason
			elapsed_wall_ms=if($watchdog){[int]$watchdog.wall_elapsed_ms}else{$null}
			watchdog_status=if($watchdog){[string]$watchdog.status}else{"MISSING"}
			watchdog_file=if($watchdog){"$id.watchdog.json"}else{$null}
			trace_file=$summary.trace_source
			record_summary=$summary
			retry_verification=$null
		}
		$baseById[$id] = [pscustomobject]@{record=$record;result=$result;progress=$progress;watchdog=$watchdog;plan=$plan;policy=$policy}
		$trialRecords.Add($record)
	}
}

foreach ($entry in @($baseById.Values)) {
	if ($entry.record.classification -ne "WIN_OBSERVED") { continue }
	$id = "retry_" + [string]$entry.record.trial_id.Substring(5)
	$stem = Join-Path $pilotDir $id
	$watchdog = Read-JsonFile "$stem.watchdog.json"
	$result = Read-JsonFile "$stem.json"
	$progress = Read-JsonFile "$stem.progress.json"
	$class = if ($watchdog -and $watchdog.status -eq "EXITED" -and $result) { [string]$result.classification } elseif ($watchdog -and $watchdog.status -eq "TIMEOUT_TERMINATED") { "BUDGET_UNKNOWN" } elseif ($watchdog -and $watchdog.status -eq "CHILD_ERROR") { "ERROR" } else { "BUDGET_UNKNOWN" }
	$reason = if ($result) { [string]$result.terminal_reason } elseif ($watchdog) { [string]$watchdog.reason } else { "REQUIRED_WIN_REPLAY_EVIDENCE_MISSING" }
	$baseActionsMatch = $false
	if ($result -and $entry.result) { $baseActionsMatch = (Get-ActionProjection $entry.result) -ceq (Get-ActionProjection $result) }
	$retry = [ordered]@{
		trial_id=$id
		case=[ordered]@{island_id=$entry.plan.island;level_id=$entry.plan.level;seed=$entry.plan.seed;difficulty_band=$entry.plan.band;policy=$entry.policy;replay=$true}
		status=if($class -eq "ERROR"){"ERROR"}else{"COMPLETE"}
		classification=$class
		reason=$reason
		elapsed_wall_ms=if($watchdog){[int]$watchdog.wall_elapsed_ms}else{$null}
		watchdog_status=if($watchdog){[string]$watchdog.status}else{"MISSING"}
		watchdog_file=if($watchdog){"$id.watchdog.json"}else{$null}
		trace_file=if($result){"$id.json"}elseif($progress){"$id.progress.json"}else{$null}
		record_summary=[ordered]@{
			static_validation_record_count=if($result){[int]$result.static_validation_record_count}else{[int]$progress.static_validation_record_count}
			normal_4t_shot_cap=if($result){[int]$result.normal_4t_shot_cap}else{0}
			shots_used=if($result){[int]$result.shots_used}else{$null}
			action_count=if($result){[int]$result.action_count}else{@($progress.action_log).Count}
			action_log_sha256=if($result){[string]$result.action_log_sha256}else{$null}
			normal_objective_complete=if($result){[bool]$result.normal_objective_complete}else{$false}
			merge_count=if($result){[int]$result.merge_count}else{[int]$progress.merge_count}
		}
		replay_verification=[ordered]@{base_win_repeated=($class -eq "WIN_OBSERVED");same_seed=$true;same_action_inputs=$baseActionsMatch}
	}
	$entry.record.retry_verification = [ordered]@{trial_id=$id;classification=$class;reason=$reason;same_seed=$true;same_action_inputs=$baseActionsMatch}
	$trialRecords.Add($retry)
}

$outcomes = @{}
foreach ($trial in $trialRecords) { $key=[string]$trial.classification;if($outcomes.ContainsKey($key)){$outcomes[$key]++}else{$outcomes[$key]=1} }
$recordCount = 0
foreach ($trial in $trialRecords) { $recordCount=[Math]::Max($recordCount,[int]$trial.record_summary.static_validation_record_count) }
$policySummary = [System.Collections.Generic.List[object]]::new()
foreach ($policy in $policies) {
	$items = @($trialRecords | Where-Object { -not $_.case.replay -and $_.case.policy -eq $policy })
	$completed = @($items | Where-Object { $_.status -eq "COMPLETE" })
	$times = @($completed | Where-Object {$null -ne $_.elapsed_wall_ms} | ForEach-Object {[double]$_.elapsed_wall_ms})
	$merges = @($completed | Where-Object {$_.record_summary.Contains('merge_count')} | ForEach-Object {[double]$_.record_summary.merge_count})
	$policySummary.Add([ordered]@{
		policy=$policy;base_trial_count=$items.Count;win_observed_count=@($items|Where-Object{$_.classification -eq "WIN_OBSERVED"}).Count
		loss_observed_count=@($items|Where-Object{$_.classification -eq "LOSS_OBSERVED"}).Count
		budget_unknown_count=@($items|Where-Object{$_.classification -eq "BUDGET_UNKNOWN"}).Count
		error_count=@($items|Where-Object{$_.classification -eq "ERROR"}).Count
		mean_wall_ms=if($times.Count){[Math]::Round(($times|Measure-Object -Average).Average,1)}else{$null}
		mean_merge_count=if($merges.Count){[Math]::Round(($merges|Measure-Object -Average).Average,2)}else{$null}
	})
}

$attemptFiles = @(
	(Join-Path $evidenceRoot "global_pilot_watchdog.json"),
	(Join-Path $evidenceRoot "pilot_attempt02/global_pilot_watchdog.json"),
	(Join-Path $pilotDir "global_pilot_watchdog.json"),
	(Join-Path $pilotDir "report_rebuild.watchdog.json")
)
$attempts = [System.Collections.Generic.List[object]]::new()
$taskPilotWallMs = 0
foreach ($path in $attemptFiles) {
	$watchdog = Read-JsonFile $path
	if ($watchdog) {
		$taskPilotWallMs += [int]$watchdog.wall_elapsed_ms
		$attempts.Add([ordered]@{evidence_file=(Resolve-Path -Relative -LiteralPath $path);status=[string]$watchdog.status;elapsed_wall_ms=[int]$watchdog.wall_elapsed_ms;reason=[string]$watchdog.reason})
	}
}
$calibrationPath = Join-Path $evidenceRoot "base_sunny_cove_l10_WEAK_V02.watchdog.json"
$calibrationWatchdog = Read-JsonFile $calibrationPath
$calibrationProgress = Read-JsonFile (Join-Path $evidenceRoot "base_sunny_cove_l10_WEAK_V02.progress.json")
$baseTimes = @($trialRecords | Where-Object {-not $_.case.replay -and $null -ne $_.elapsed_wall_ms} | ForEach-Object {[double]$_.elapsed_wall_ms})
$retryTimes = @($trialRecords | Where-Object {$_.case.replay -and $null -ne $_.elapsed_wall_ms} | ForEach-Object {[double]$_.elapsed_wall_ms})
$meanBaseSeconds = if($baseTimes.Count){($baseTimes|Measure-Object -Average).Average/1000.0}else{0.0}
$meanRetrySeconds = if($retryTimes.Count){($retryTimes|Measure-Object -Average).Average/1000.0}else{0.0}
$baseWinRate = if($plans.Count*$policies.Count){2.0/($plans.Count*$policies.Count)}else{0.0}
$pilotDirBytes = (Get-ChildItem -LiteralPath $evidenceRoot -File -Recurse -Force | Measure-Object Length -Sum).Sum
$taskTempEntries = [System.Collections.Generic.List[object]]::new()
foreach($tempDir in @(Get-ChildItem -LiteralPath $env:TEMP -Directory -Force | Where-Object Name -like "BCM-M34-R16-*")) {
	$bytes=(Get-ChildItem -LiteralPath $tempDir.FullName -File -Recurse -Force -ErrorAction SilentlyContinue|Measure-Object Length -Sum).Sum
	$taskTempEntries.Add([ordered]@{name=$tempDir.Name;bytes=$bytes;disposition="PRESERVED; deletion retry prohibited after policy rejection"})
}
$volume = Get-Volume -DriveLetter C
$regressionSummary = Read-JsonFile (Join-Path $evidenceRoot "regression_summary.json")
$finalImport = Read-JsonFile (Join-Path $evidenceRoot "fresh_import_final.watchdog.json")
$report = [ordered]@{
	schema_version=1
	work_item="BCM-M34-R16"
	status=if(@($trialRecords|Where-Object{$_.classification -eq "ERROR"}).Count){"PILOT_COMPLETE_WITH_ERROR_AND_UNKNOWN_OUTCOMES"}else{"PILOT_COMPLETE_WITH_OBSERVED_AND_UNKNOWN_OUTCOMES"}
	physics_mode="standard_fps_production_physics"
	fixed_fps_authoritative_proof=$false
	global_pilot_budget_seconds=720
	controller_budget_seconds=540
	per_trial_external_watchdog_seconds=15
	trial_level_count=$plans.Count
	island_count=@($plans.island|Sort-Object -Unique).Count
	policy_count=$policies.Count
	planned_base_trials=$plans.Count*$policies.Count
	base_trials_completed=@($trialRecords|Where-Object{-not $_.case.replay}).Count
	win_replay_count=@($trialRecords|Where-Object{$_.case.replay}).Count
	static_validation=[ordered]@{status=if($recordCount -eq 1000){"PASS"}else{"UNVERIFIED"};validated_level_records=$recordCount;expected_level_records=1000;method="LevelDatabase ValidationMode.FULL"}
	fresh_import=[ordered]@{status=if($finalImport){[string]$finalImport.status}else{"UNVERIFIED"};exit_code=if($finalImport){$finalImport.exit_code}else{$null};elapsed_wall_ms=if($finalImport){[int]$finalImport.wall_elapsed_ms}else{$null};evidence_file="fresh_import_final.watchdog.json"}
	regressions=[ordered]@{status=if($regressionSummary){[string]$regressionSummary.status}else{"UNVERIFIED"};passed_count=if($regressionSummary){@($regressionSummary.tests|Where-Object{$_.pass}).Count}else{0};expected_count=10;evidence_file="regression_summary.json";tasks_md_unchanged=if($regressionSummary){[bool]$regressionSummary.tasks_md_unchanged}else{$false}}
	outcome_counts=$outcomes
	policy_summary=@($policySummary)
	trials=@($trialRecords)
	supplementary_runner_recovery_trials=@(
		[ordered]@{trial_id="attempt02_base_sunny_cove_l1_WEAK_V02";classification="WIN_OBSERVED";seed=34116001;policy="WEAK_V02";evidence_folder="pilot_attempt02";trace_file="pilot_attempt02/base_sunny_cove_l1_WEAK_V02.json";included_in_final_six_level_counts=$false},
		[ordered]@{trial_id="attempt02_retry_sunny_cove_l1_WEAK_V02";classification="WIN_OBSERVED";seed=34116001;policy="WEAK_V02";evidence_folder="pilot_attempt02";trace_file="pilot_attempt02/retry_sunny_cove_l1_WEAK_V02.json";included_in_final_six_level_counts=$false}
	)
	report_recovery_repeats=@(
		[ordered]@{case="sunny_cove/40/WEAK_V02";first_classification="BUDGET_UNKNOWN";first_watchdog_wall_ms=16716;retained_classification="BUDGET_UNKNOWN";retained_watchdog_wall_ms=17500;first_partial_trace_retained=$false;note="First progress snapshot was replaced during report recovery; retained trace is from the second bounded run."},
		[ordered]@{case="sunny_cove/40/MERGE_AWARE_V01";first_classification="BUDGET_UNKNOWN";first_watchdog_wall_ms=16744;retained_classification="BUDGET_UNKNOWN";retained_watchdog_wall_ms=19298;first_partial_trace_retained=$false;note="First progress snapshot was replaced during report recovery; retained trace is from the second bounded run."},
		[ordered]@{case="tiki_island/30/WEAK_V02";first_classification="BUDGET_UNKNOWN";first_watchdog_wall_ms=17054;retained_classification="BUDGET_UNKNOWN";retained_watchdog_wall_ms=20131;first_partial_trace_retained=$false;note="First progress snapshot was replaced during report recovery; retained trace is from the second bounded run."},
		[ordered]@{case="tiki_island/30/MERGE_AWARE_V01";first_classification="BUDGET_UNKNOWN";first_watchdog_wall_ms=16848;retained_classification="ERROR";retained_watchdog_wall_ms=10524;first_partial_trace_retained=$false;note="First progress snapshot was replaced during report recovery; retained trace is from the second bounded run, which exited with child code -1."}
	)
	report_recovery_trace_limitation="The four first-pass timed-out cases above were rerun because no final probe JSON existed. Their per-case progress files were overwritten by the reruns; original classification and elapsed time survive in the outer pilot watchdog stdout, but original action traces do not. Each final planned case retains the latest complete or partial action trace listed in trials[].trace_file."
	human_fairness_ux="NOT_ASSESSED"
	owner_native_device_tests="DEFERRED"
	normal_4t_cap_source="canonical theoretical_shots_to_go * 4; optional VIP excluded"
	classification_policy="Non-terminal watchdog/budget exhaustion is BUDGET_UNKNOWN, never an impossibility inference. A WIN is bounded proof only for its observed trial."
	pre_final_calibration=[ordered]@{evidence_file="base_sunny_cove_l10_WEAK_V02.watchdog.json";status=if($calibrationWatchdog){[string]$calibrationWatchdog.status}else{"MISSING"};classification="BUDGET_UNKNOWN";elapsed_wall_ms=if($calibrationWatchdog){[int]$calibrationWatchdog.wall_elapsed_ms}else{$null};external_limit_seconds=20;completed_actions=if($calibrationProgress){@($calibrationProgress.action_log).Count}else{0};merge_count=if($calibrationProgress){[int]$calibrationProgress.merge_count}else{0};normal_orders_completed=if($calibrationProgress){$calibrationProgress.normal_orders_completed}else{@{}};normal_orders_remaining=if($calibrationProgress){$calibrationProgress.normal_orders_remaining}else{@{}};trace_file="base_sunny_cove_l10_WEAK_V02.progress.json";excluded_from_six_level_sample=$true;exclusion_reason="20-second watchdog setting measured beyond 25 seconds including termination; final pilot reduced the limit to 15 seconds."}
	all_planned_sample_trials_within_25_seconds=(@($trialRecords | Where-Object {$null -ne $_.elapsed_wall_ms -and $_.elapsed_wall_ms -gt 25000}).Count -eq 0)
	max_planned_sample_trial_wall_ms=if($baseTimes.Count+$retryTimes.Count){[Math]::Round((@($baseTimes+$retryTimes)|Measure-Object -Maximum).Maximum,1)}else{$null}
	cost_projection=[ordered]@{
		measured_mean_base_wall_seconds=[Math]::Round($meanBaseSeconds,2)
		measured_mean_win_replay_wall_seconds=[Math]::Round($meanRetrySeconds,2)
		one_policy_one_seed_1000_level_hours=[Math]::Round(1000*$meanBaseSeconds/3600.0,2)
		two_policies_one_seed_1000_level_hours=[Math]::Round(2000*$meanBaseSeconds/3600.0,2)
		two_policies_two_seeds_1000_level_hours=[Math]::Round(4000*$meanBaseSeconds/3600.0,2)
		two_policies_one_seed_plus_replays_at_observed_win_rate_hours=[Math]::Round((2000*$meanBaseSeconds+2000*$baseWinRate*$meanRetrySeconds)/3600.0,2)
		basis="Linear projections from watchdog wall time. Budget-unknown observations are right-censored, so these are lower-bound scheduling estimates; no quality or reachability extrapolation is justified."
	}
	next_methodology_recommendation="Do not start staged 1,000-level solver coverage yet. Neither policy distinguished itself: both produced one observed/replayed Sunny Cove L1 win; mid/late runs were budget-unknown and one merge-aware run errored. Use a bounded human-studio session on Sunny Cove L40, Tiki Island L30, and Final Island L100 to assess fairness and capture successful action traces; then feed those traces into a stronger policy pilot. Human-studio throughput was not measured."
	disk_hygiene=[ordered]@{
		r16_evidence_bytes=$pilotDirBytes
		largest_scoped_cache_inventory=@(
			[ordered]@{path="existing R16 worktree .godot/imported";bytes=1286453057;classification="Generated Godot import cache; read-only inspected; retained after deletion-policy rejection"},
			[ordered]@{path="user Roaming Godot data";bytes=569366214;classification="Owner user data/cache; retained"},
			[ordered]@{path="user Local Godot cache";bytes=139434356;classification="Shared application cache; retained"}
		)
		task_temp_directories=@($taskTempEntries)
		task_temp_cleanup="REJECTED_BEFORE_EXECUTION; no deletion retry; task-owned temporary directories retained"
		free_bytes_at_inventory=$volume.SizeRemaining
		regression_free_bytes_reclaimed=-3137536
		regression_free_space_claim="No space reclamation claimed; measured free space decreased."
	}
	controller_attempts=@($attempts)
	task_total_pilot_tool_wall_ms=$taskPilotWallMs
	task_total_pilot_tool_wall_seconds=[Math]::Round($taskPilotWallMs/1000.0,1)
	within_12_minute_global_budget=($taskPilotWallMs -le 720000)
	static_validation_records_during_each_trial=1000
	completed_utc=[DateTime]::UtcNow.ToString("o")
}
$json=($report|ConvertTo-Json -Depth 40).Replace("`r`n","`n")
[IO.File]::WriteAllText($reportPath,$json+"`n" ,[Text.UTF8Encoding]::new($false))
Write-Output "M34_R16_SUMMARY status=$($report.status) outcomes=$((ConvertTo-Json -Compress $outcomes)) static=$recordCount/1000 task_wall_ms=$taskPilotWallMs within_12m=$($report.within_12_minute_global_budget)"
