param(
	[string]$EvidenceRoot = '',
	[int]$TrialTimeoutSeconds = 35,
	[int]$GlobalBudgetSeconds = 600,
	[string]$WatchdogTaskToken = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Import-Module (Join-Path $PSScriptRoot 'm34_r17_pilot_integrity.psm1') -Force
if ([string]::IsNullOrWhiteSpace($EvidenceRoot)) {
	$EvidenceRoot = Join-Path $repoRoot 'coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R17'
}
$EvidenceRoot = [IO.Path]::GetFullPath($EvidenceRoot)
$manifestPath = Join-Path $EvidenceRoot 'attempt_manifest.jsonl'
$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$watchdog = Join-Path $repoRoot 'tools/campaign/m34_r14_process_watchdog.ps1'
$probe = Join-Path $repoRoot 'tools/campaign/m34_r16_outcome_pilot.gd'
$attemptId = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '_' + [guid]::NewGuid().ToString('N')
$clock = [Diagnostics.Stopwatch]::StartNew()
$tasksBefore = (git -C $repoRoot hash-object TASKS.md).Trim()
$drive = [IO.Path]::GetPathRoot($env:TEMP).Substring(0,1)
$freeBefore = [long](Get-Volume -DriveLetter $drive).SizeRemaining

$samplePlan = @(
	[pscustomobject]@{name='early_tiki_l10';island='tiki_island';level=10;seed=34116110;band='early';policy='MERGE_AWARE_V01'},
	[pscustomobject]@{name='middle_sunny_l40';island='sunny_cove';level=40;seed=34116040;band='middle';policy='MERGE_AWARE_V01'},
	[pscustomobject]@{name='late_coconut_l70';island='coconut_beach';level=70;seed=34116270;band='late';policy='MERGE_AWARE_V01'}
)

$attemptPath = New-R17AttemptDirectory -EvidenceRoot $EvidenceRoot -AttemptId $attemptId -ManifestPath $manifestPath -Role 'R17_DIAGNOSTIC_AND_ADAPTIVE_SAMPLE'
$appDataRoaming = Join-Path $attemptPath 'appdata_roaming'
$appDataLocal = Join-Path $attemptPath 'appdata_local'
[IO.Directory]::CreateDirectory($appDataRoaming) | Out-Null
[IO.Directory]::CreateDirectory($appDataLocal) | Out-Null
$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
$env:APPDATA = $appDataRoaming
$env:LOCALAPPDATA = $appDataLocal
$planEvent = [ordered]@{
	event_id=[guid]::NewGuid().ToString('N');event_type='PILOT_PLAN';attempt_id=$attemptId
	policy='MERGE_AWARE_V01';seed_policy='fixed per level';physics_mode='standard_fps_production_physics';fixed_fps=$false;time_scale=1.0
	normal_4t_cap_source='canonical theoretical_shots_to_go * 4; optional VIP excluded'
	trial_timeout_seconds=$TrialTimeoutSeconds;global_budget_seconds=$GlobalBudgetSeconds
	time_budget_basis='R16 observed successful L1 process walls 9.942-10.101s; planned-sample max 20.131s including watchdog termination under a 15s limit. R17 35s per-case watchdog provides a bounded longer observation window while retaining a 12-minute global ceiling.'
	source_path='coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R16/pilot_attempt03/outcome_qualification_report.json'
	source_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $repoRoot 'coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R16/pilot_attempt03/outcome_qualification_report.json')).Hash.ToLower()
	calibration_attempts=0;calibration_policy='No calibration trials; prior R16 timing evidence used for budget selection.'
	selected_sample=@($samplePlan | ForEach-Object {@{name=$_.name;island=$_.island;level=$_.level;seed=$_.seed;band=$_.band;policy=$_.policy}})
	stop_rule='After the first qualification sample with zero normal objective progress, stop all additional qualification samples.'
}
Add-R17ManifestEvent -ManifestPath $manifestPath -Event $planEvent

function Get-RelativeEvidencePath([string]$Path) {
	if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
	return [IO.Path]::GetRelativePath($EvidenceRoot, [IO.Path]::GetFullPath($Path)).Replace('\','/')
}

function Invoke-R17Trial {
	param([Parameter(Mandatory)][object]$Case, [Parameter(Mandatory)][string]$Role, [string]$ParentTrialAttemptId = '', [string]$Provenance = '')
	if ($clock.Elapsed.TotalSeconds -ge $GlobalBudgetSeconds -or ($GlobalBudgetSeconds - $clock.Elapsed.TotalSeconds) -lt ($TrialTimeoutSeconds + 10)) { return $null }
	$trialAttemptId = [guid]::NewGuid().ToString('N')
	$trialDir = Join-Path $attemptPath "trial_$trialAttemptId"
	if (Test-Path -LiteralPath $trialDir) { throw "Trial directory collision refused: $trialDir" }
	[IO.Directory]::CreateDirectory($trialDir) | Out-Null
	$trialKey = [string]$Case.name
	$outputPath = Join-Path $trialDir 'probe_result.json'
	$progressPath = Join-Path $trialDir 'progress_trace.json'
	$watchdogPath = Join-Path $trialDir 'watchdog_result.json'
	$caseRecordPath = Join-Path $trialDir 'case_record.json'
	foreach ($reserved in @($outputPath,$progressPath,$watchdogPath,$caseRecordPath)) { if (Test-Path -LiteralPath $reserved) { throw "Trial output collision refused: $reserved" } }
	$caseData = [ordered]@{name=$Case.name;island_id=$Case.island;level_id=[int]$Case.level;seed=[int]$Case.seed;difficulty_band=$Case.band;policy=$Case.policy;physics_mode='standard_fps_production_physics';fixed_fps=$false;time_scale=1.0;normal_4t_cap_source='theoretical_shots_to_go * 4; optional VIP excluded'}
	$started = [DateTime]::UtcNow.ToString('o')
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{
		event_id=[guid]::NewGuid().ToString('N');event_type='TRIAL_STARTED';attempt_id=$attemptId;trial_attempt_id=$trialAttemptId
		trial_name=$trialKey;role=$Role;parent_trial_attempt_id=$ParentTrialAttemptId;provenance=$Provenance;case=$caseData
		trial_path=[IO.Path]::GetRelativePath($EvidenceRoot,$trialDir).Replace('\','/');started_utc=$started
	})
	$arguments = @('--headless','--path',$repoRoot,'--script',$probe,'--',
		"--r16-output=$outputPath","--r16-progress=$progressPath",
		"--r16-island=$($Case.island)","--r16-level=$($Case.level)","--r16-seed=$($Case.seed)","--r16-policy=$($Case.policy)")
	& $watchdog -FilePath $godot -ArgumentList $arguments -TimeoutSeconds $TrialTimeoutSeconds -ResultPath $watchdogPath -ProgressPath $progressPath -TaskName "BCM-M34-R17-$trialAttemptId"
	$watchdogExit = $LASTEXITCODE
	$watchdogData = if (Test-Path -LiteralPath $watchdogPath -PathType Leaf) { Get-Content -Raw -LiteralPath $watchdogPath | ConvertFrom-Json } else { $null }
	$probeData = if (Test-Path -LiteralPath $outputPath -PathType Leaf) { try { Get-Content -Raw -LiteralPath $outputPath | ConvertFrom-Json } catch { $null } } else { $null }
	if ($null -eq $watchdogData) {
		$watchdogData = [pscustomobject]@{status='ERROR';reason='WATCHDOG_RESULT_MISSING';exit_code=$null;root_identity_verified=$false;terminated_processes=@();stderr='';stdout='';partial_progress=$null}
	}
	$outcome = Get-R17WatchdogClassification -Watchdog $watchdogData -ProbeResult $probeData
	$tracePath = if (Test-Path -LiteralPath $progressPath -PathType Leaf) { $progressPath } elseif (Test-Path -LiteralPath $outputPath -PathType Leaf) { $outputPath } else { $null }
	$trace = if ($tracePath) { try { Get-Content -Raw -LiteralPath $tracePath | ConvertFrom-Json } catch { $null } } else { $null }
	$digest = if ($tracePath -and $trace) { Get-R17ActionProgressDigest -TracePath $tracePath } else { $null }
	$objectiveProgress = if ($trace) { Get-R17ObjectiveProgress -Trace $trace } elseif ($watchdogData.partial_progress) { Get-R17ObjectiveProgress -Trace $watchdogData.partial_progress } else { 0 }
	$theoreticalT = if ($trace) { [int]$trace.normal_theoretical_shots_T } elseif ($watchdogData.partial_progress) { [int]$watchdogData.partial_progress.normal_theoretical_shots_T } else { 0 }
	$normal4tCap = if ($trace) { [int]$trace.normal_4t_shot_cap } elseif ($watchdogData.partial_progress) { [int]$watchdogData.partial_progress.normal_4t_shot_cap } else { 0 }
	$record = [ordered]@{
		schema_version=1;work_item='BCM-M34-R17';attempt_id=$attemptId;trial_attempt_id=$trialAttemptId;trial_name=$trialKey;role=$Role
		parent_trial_attempt_id=$ParentTrialAttemptId;provenance=$Provenance;case=$caseData;classification=$outcome.classification;failure_kind=$outcome.failure_kind
		reason=$outcome.reason;watchdog_status=$outcome.watchdog_status;watchdog_exit_code=$outcome.exit_code;watchdog_exit_code_hex=$outcome.exit_code_hex
		normal_theoretical_shots_T=$theoreticalT;normal_4t_shot_cap=$normal4tCap;normal_4t_cap_verified=($theoreticalT -gt 0 -and $normal4tCap -eq (4 * $theoreticalT))
		watchdog_exit=$watchdogExit;process_identity_verified=$outcome.process_identity_verified;watchdog_terminated_count=$outcome.watchdog_terminated_count
		stderr_length=$outcome.stderr_length;wall_elapsed_ms=[int]$watchdogData.wall_elapsed_ms;normal_objective_progress=$objectiveProgress
		action_count=if($digest){$digest.action_count}else{0};progress_point_count=if($digest){$digest.progress_count}else{0}
		action_progress_sha256=if($digest){$digest.action_progress_sha256}else{$null}
		trace_path=Get-RelativeEvidencePath $tracePath;trace_file_sha256=if($tracePath){(Get-FileHash -Algorithm SHA256 -LiteralPath $tracePath).Hash.ToLower()}else{$null}
		watchdog_path=Get-RelativeEvidencePath $watchdogPath;watchdog_file_sha256=if(Test-Path -LiteralPath $watchdogPath){(Get-FileHash -Algorithm SHA256 -LiteralPath $watchdogPath).Hash.ToLower()}else{$null}
		probe_result_path=Get-RelativeEvidencePath $outputPath;probe_result_sha256=if(Test-Path -LiteralPath $outputPath){(Get-FileHash -Algorithm SHA256 -LiteralPath $outputPath).Hash.ToLower()}else{$null}
		started_utc=$started;finished_utc=[DateTime]::UtcNow.ToString('o')
	}
	[void](Publish-R17UniqueJson -Path $caseRecordPath -Value $record)
	$caseRecordHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $caseRecordPath).Hash.ToLower()
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{
		event_id=[guid]::NewGuid().ToString('N');event_type='TRIAL_FINISHED';attempt_id=$attemptId;trial_attempt_id=$trialAttemptId
		trial_name=$trialKey;role=$Role;parent_trial_attempt_id=$ParentTrialAttemptId;provenance=$Provenance;case=$caseData
		classification=$outcome.classification;failure_kind=$outcome.failure_kind;reason=$outcome.reason;normal_objective_progress=$objectiveProgress
		normal_theoretical_shots_T=$theoreticalT;normal_4t_shot_cap=$normal4tCap;normal_4t_cap_verified=($theoreticalT -gt 0 -and $normal4tCap -eq (4 * $theoreticalT))
		case_record_path=[IO.Path]::GetRelativePath($EvidenceRoot,$caseRecordPath).Replace('\','/');case_record_sha256=$caseRecordHash
		trace_path=$record.trace_path;trace_file_sha256=$record.trace_file_sha256;action_progress_sha256=$record.action_progress_sha256
		watchdog_path=$record.watchdog_path;watchdog_file_sha256=$record.watchdog_file_sha256;finished_utc=$record.finished_utc
	})
	Write-Host "R17_TRIAL role=$Role case=$trialKey outcome=$($outcome.classification) failure=$($outcome.failure_kind) wall_ms=$($record.wall_elapsed_ms) actions=$($record.action_count) objective_progress=$objectiveProgress"
	return [pscustomobject]$record
}

try {
	$r16WatchdogPath = Join-Path $repoRoot 'coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R16/pilot_attempt03/base_tiki_island_l30_MERGE_AWARE_V01.watchdog.json'
	$r16ProgressPath = Join-Path $repoRoot 'coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R16/pilot_attempt03/base_tiki_island_l30_MERGE_AWARE_V01.progress.json'
	$r16Watchdog = Get-Content -Raw $r16WatchdogPath | ConvertFrom-Json
	$r16Outcome = Get-R17WatchdogClassification -Watchdog $r16Watchdog -ProbeResult $null
	$r16Triage = [ordered]@{
		schema_version=1;work_item='BCM-M34-R17';diagnostic_type='ARCHIVED_R16_CHILD_EXIT_TRIAGE';source='M34-R16/pilot_attempt03/base_tiki_island_l30_MERGE_AWARE_V01.watchdog.json'
		source_watchdog_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $r16WatchdogPath).Hash.ToLower()
		classification=$r16Outcome.classification;failure_kind=$r16Outcome.failure_kind;reason=$r16Outcome.reason;exit_code=$r16Outcome.exit_code;exit_code_hex=$r16Outcome.exit_code_hex
		elapsed_ms=$r16Watchdog.wall_elapsed_ms;timeout_seconds=$r16Watchdog.timeout_seconds;process_identity_verified=$r16Outcome.process_identity_verified
		watchdog_terminated_count=$r16Outcome.watchdog_terminated_count;stderr_length=$r16Outcome.stderr_length;stdout_tail=[string]$r16Watchdog.stdout
		partial_progress_path='M34-R16/pilot_attempt03/base_tiki_island_l30_MERGE_AWARE_V01.progress.json'
		partial_progress_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $r16ProgressPath).Hash.ToLower()
		partial_actions=[int]$r16Watchdog.partial_progress.completed_actions;partial_physics_frame=[int]$r16Watchdog.partial_progress.physics_frame
		partial_merges=[int]$r16Watchdog.partial_progress.merge_count;normal_objective_progress=(Get-R17ObjectiveProgress -Trace $r16Watchdog.partial_progress)
		windows_application_event_search='No matching Application Error, Windows Error Reporting, Godot, process-path, or PID 9868 events found in the bounded 5-minute interval around 2026-10-15T20:42:40Z.'
		conclusion='The watchdog verified the launched executable identity and observed a natural child exit before its 15-second limit; it did not terminate the process. Exit -1 with empty stderr and no matching retained Application/WER event is an unattributed negative subprocess exit. Evidence cannot distinguish a Godot/native runtime fault from external OS termination or another child-process failure.'
	}
	$triagePath = Publish-R17UniqueJson -Path (Join-Path $attemptPath 'r16_error_triage.json') -Value $r16Triage
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{
		event_id=[guid]::NewGuid().ToString('N');event_type='DIAGNOSTIC_REFERENCE';attempt_id=$attemptId
		artifact_path=[IO.Path]::GetRelativePath($EvidenceRoot,$triagePath).Replace('\','/')
		artifact_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $triagePath).Hash.ToLower()
		source_path='coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R16/pilot_attempt03/base_tiki_island_l30_MERGE_AWARE_V01.watchdog.json'
		source_sha256=$r16Triage.source_watchdog_sha256
	})
	$triageCase = [pscustomobject]@{name='r16_tiki_l30_merge_aware_reproduction';island='tiki_island';level=30;seed=34116130;band='early_mid';policy='MERGE_AWARE_V01'}
	$triage = Invoke-R17Trial -Case $triageCase -Role 'ERROR_REPRODUCTION' -Provenance 'Same island, level, seed, policy, and standard-FPS probe as R16 pilot_attempt03; classified separately from qualification sample.'
	$selected = [System.Collections.Generic.List[object]]::new()
	$stopReason = 'SAMPLE_PLAN_COMPLETE'
	foreach ($case in $samplePlan) {
		$trial = Invoke-R17Trial -Case $case -Role 'QUALIFICATION_SAMPLE' -ParentTrialAttemptId $triage.trial_attempt_id -Provenance 'Preselected differentiated stage/island sample; fixed seed; merge-aware policy.'
		if ($null -eq $trial) { $stopReason = 'GLOBAL_BUDGET_RESERVE_REACHED'; break }
		$selected.Add($trial)
		if ($trial.classification -eq 'ERROR') { $stopReason = 'ERROR_OUTCOME_REQUIRES_DIAGNOSIS'; break }
		if ($trial.normal_objective_progress -le 0) { $stopReason = 'STOPPED_NO_OBJECTIVE_PROGRESS'; break }
	}
	$tasksAfter = (git -C $repoRoot hash-object TASKS.md).Trim()
	$freeAfter = [long](Get-Volume -DriveLetter $drive).SizeRemaining
	$summary = [ordered]@{
		schema_version=1;work_item='BCM-M34-R17';attempt_id=$attemptId;status=if($stopReason -eq 'SAMPLE_PLAN_COMPLETE'){'SAMPLE_PLAN_COMPLETE'}else{'STOPPED_EARLY'}
		stop_reason=$stopReason;planned_sample_count=$samplePlan.Count;completed_sample_count=$selected.Count;triage_trial_attempt_id=if($triage){$triage.trial_attempt_id}else{$null}
		triage_classification=if($triage){$triage.classification}else{'ERROR'};trial_timeout_seconds=$TrialTimeoutSeconds;global_budget_seconds=$GlobalBudgetSeconds
		actual_controller_elapsed_ms=[int]$clock.Elapsed.TotalMilliseconds;actual_disk_free_delta_bytes=($freeAfter-$freeBefore)
		appdata_roaming_path=$appDataRoaming;appdata_local_path=$appDataLocal;tasks_blob_before=$tasksBefore;tasks_blob_after=$tasksAfter;tasks_unchanged=($tasksBefore -ceq $tasksAfter)
		selected_plan=@($samplePlan | ForEach-Object {@{name=$_.name;island=$_.island;level=$_.level;seed=$_.seed;band=$_.band;policy=$_.policy}})
		completed_trials=@($selected | ForEach-Object {@{trial_attempt_id=$_.trial_attempt_id;trial_name=$_.trial_name;classification=$_.classification;failure_kind=$_.failure_kind;objective_progress=$_.normal_objective_progress;action_count=$_.action_count;trace_path=$_.trace_path;trace_file_sha256=$_.trace_file_sha256;action_progress_sha256=$_.action_progress_sha256}})
	}
	$summaryPath = Publish-R17UniqueJson -Path (Join-Path $attemptPath 'attempt_summary.json') -Value $summary
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{
		event_id=[guid]::NewGuid().ToString('N');event_type='ATTEMPT_FINISHED';attempt_id=$attemptId;status=$summary.status;stop_reason=$stopReason
		summary_path=[IO.Path]::GetRelativePath($EvidenceRoot,$summaryPath).Replace('\','/')
		summary_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $summaryPath).Hash.ToLower()
		finished_utc=[DateTime]::UtcNow.ToString('o')
	})
	Write-Output "R17_ATTEMPT=$attemptId status=$($summary.status) stop=$stopReason sample=$($selected.Count)/$($samplePlan.Count) elapsed_ms=$($summary.actual_controller_elapsed_ms) disk_delta=$($summary.actual_disk_free_delta_bytes) tasks_unchanged=$($summary.tasks_unchanged)"
} finally {
	$env:APPDATA = $oldAppData
	$env:LOCALAPPDATA = $oldLocalAppData
}

if ($tasksBefore -cne $tasksAfter) { throw 'TASKS.md Git blob changed during R17 pilot.' }
