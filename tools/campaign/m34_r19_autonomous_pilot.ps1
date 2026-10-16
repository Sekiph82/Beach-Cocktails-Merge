[CmdletBinding()]
param(
	[string]$EvidenceRoot = '',
	[ValidateRange(5, 30)][int]$TrialTimeoutSeconds = 30,
	[ValidateRange(60, 900)][int]$GlobalBudgetSeconds = 900,
	[string]$ResumeAttemptId = '',
	[string]$RetryCaseName = '',
	[string]$ParentAttemptId = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Import-Module (Join-Path $PSScriptRoot 'm34_r17_pilot_integrity.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'm34_r20_recovery.psm1') -Force
if ([string]::IsNullOrWhiteSpace($EvidenceRoot)) {
	$EvidenceRoot = Join-Path $repoRoot 'coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R19'
}
$EvidenceRoot = [IO.Path]::GetFullPath($EvidenceRoot)
[IO.Directory]::CreateDirectory($EvidenceRoot) | Out-Null
$manifestPath = Join-Path $EvidenceRoot 'attempt_manifest.jsonl'
$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$watchdog = Join-Path $repoRoot 'tools/campaign/m34_r14_process_watchdog.ps1'
$probe = Join-Path $repoRoot 'tools/campaign/m34_r19_autonomous_trial.gd'
$attemptId = if ([string]::IsNullOrWhiteSpace($ResumeAttemptId)) { [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '_' + [guid]::NewGuid().ToString('N') } else { $ResumeAttemptId }
$attemptsRoot = Join-Path $EvidenceRoot 'attempts'
$attemptPath = Join-Path $attemptsRoot $attemptId
$clock = [Diagnostics.Stopwatch]::StartNew()
$tasksBefore = (git -C $repoRoot hash-object TASKS.md).Trim()
$drive = [IO.Path]::GetPathRoot($env:TEMP).Substring(0,1)
$freeBefore = [long](Get-Volume -DriveLetter $drive).SizeRemaining

$samplePlan = @(
	[pscustomobject]@{name='sunny_early_l1';island='sunny_cove';level=1;seed=34116001;band='easiest-baseline'},
	[pscustomobject]@{name='sunny_early_l25';island='sunny_cove';level=25;seed=34116025;band='early'},
	[pscustomobject]@{name='sunny_late_l60';island='sunny_cove';level=60;seed=34116060;band='late'},
	[pscustomobject]@{name='tiki_early_l10';island='tiki_island';level=10;seed=34116110;band='early'},
	[pscustomobject]@{name='tiki_middle_l40';island='tiki_island';level=40;seed=34116140;band='middle'},
	[pscustomobject]@{name='tiki_late_l90';island='tiki_island';level=90;seed=34116190;band='late'},
	[pscustomobject]@{name='azure_early_l1';island='azure_bay';level=1;seed=34116201;band='early'},
	[pscustomobject]@{name='azure_middle_l45';island='azure_bay';level=45;seed=34116245;band='middle'},
	[pscustomobject]@{name='azure_late_l85';island='azure_bay';level=85;seed=34116285;band='late'},
	[pscustomobject]@{name='coconut_early_l10';island='coconut_beach';level=10;seed=34116310;band='early'},
	[pscustomobject]@{name='coconut_middle_l50';island='coconut_beach';level=50;seed=34116350;band='middle'},
	[pscustomobject]@{name='coconut_late_l100';island='coconut_beach';level=100;seed=34116400;band='late'}
)
$attemptRole = 'R19_AUTONOMOUS_12_CASE_PILOT'
$parentTrialAttemptId = ''
$parentObjectiveProgress = 0
$provenance = 'Preselected differentiated 12-case pilot; fixed per-case seeds; online R19 feedback policy; 30-second watchdog.'
$inheritedFeedbackPath = ''
if (-not [string]::IsNullOrWhiteSpace($RetryCaseName)) {
	if ([string]::IsNullOrWhiteSpace($ParentAttemptId)) { throw 'Adaptive retry requires ParentAttemptId.' }
	$parentPath = Join-Path (Join-Path $EvidenceRoot 'attempts') $ParentAttemptId
	$parentSummaryPath = Join-Path $parentPath 'attempt_summary.json'
	if (-not [IO.File]::Exists($parentSummaryPath)) { throw 'Adaptive retry parent summary is missing.' }
	$parentSummary = Get-Content -Raw -LiteralPath $parentSummaryPath | ConvertFrom-Json -ErrorAction Stop
	$parentCase = @($parentSummary.completed_trials | Where-Object trial_name -ceq $RetryCaseName | Select-Object -Last 1)
	if (-not $parentCase.Count -or [string]$parentCase[0].classification -eq 'WIN_OBSERVED' -or [string]::IsNullOrWhiteSpace([string]$parentCase[0].trace_path)) { throw 'Retry source must be a non-winning pilot trace with a completed record.' }
	$parentTrialAttemptId = [string]$parentCase[0].trial_attempt_id
	$parentObjectiveProgress = [int]$parentCase[0].objective_progress
	$parentTracePath = Join-Path $EvidenceRoot ([string]$parentCase[0].trace_path).Replace('/','\')
	if (-not [IO.File]::Exists($parentTracePath) -or (Get-FileHash -Algorithm SHA256 -LiteralPath $parentTracePath).Hash.ToLower() -cne [string]$parentCase[0].trace_file_sha256) { throw 'Parent immutable trace is missing or its hash does not match the pilot summary.' }
	$parentTrace = Get-Content -Raw -LiteralPath $parentTracePath | ConvertFrom-Json -ErrorAction Stop
	$feedback = $parentTrace.lane_feedback
	if ($null -eq $feedback -or @($feedback.PSObject.Properties).Count -eq 0) { throw 'Parent trace has no observed lane feedback to adapt from.' }
	$retrySeed = [int]$parentTrace.case.seed + 1
	$samplePlan = @([pscustomobject]@{name="$RetryCaseName`_adaptive_retry";island=[string]$parentTrace.case.island_id;level=[int]$parentTrace.case.level_id;seed=$retrySeed;band='adaptive-retry'})
	$inheritedFeedbackPath = Join-Path (Join-Path $EvidenceRoot 'attempts') "r19_feedback_$([guid]::NewGuid().ToString('N')).json"
	[void](Publish-R17UniqueJson -Path $inheritedFeedbackPath -Value $feedback)
	$attemptRole = 'R19_ADAPTIVE_RETRY'
	$provenance = "Retry of $RetryCaseName from attempt $ParentAttemptId / trial $parentTrialAttemptId; seed advanced by one; lane outcome history inherited from the hash-verified immutable parent trace."
}

if ([string]::IsNullOrWhiteSpace($ResumeAttemptId)) {
	$attemptPath = New-R17AttemptDirectory -EvidenceRoot $EvidenceRoot -AttemptId $attemptId -ManifestPath $manifestPath -Role $attemptRole -ParentAttemptId $ParentAttemptId
} else {
	if ($attemptId -notmatch '^\d{8}T\d{9}Z_[a-f0-9]{32}$' -or -not [IO.Directory]::Exists($attemptPath) -or -not [IO.File]::Exists($manifestPath)) { throw 'Resume attempt id/path/manifest is invalid.' }
	$manifestEvents = @(Get-Content -LiteralPath $manifestPath | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop })
	if (-not @($manifestEvents | Where-Object { $_.event_type -eq 'ATTEMPT_STARTED' -and $_.attempt_id -ceq $attemptId }).Count) { throw 'Resume attempt is absent from the append-only manifest.' }
	if (@($manifestEvents | Where-Object { $_.event_type -eq 'ATTEMPT_FINISHED' -and $_.attempt_id -ceq $attemptId }).Count) { throw 'Finished attempts are immutable and cannot be resumed.' }
}

$appDataRoaming = Join-Path $attemptPath 'isolated_appdata_roaming'
$appDataLocal = Join-Path $attemptPath 'isolated_appdata_local'
[IO.Directory]::CreateDirectory($appDataRoaming) | Out-Null
[IO.Directory]::CreateDirectory($appDataLocal) | Out-Null
$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
$env:APPDATA = $appDataRoaming
$env:LOCALAPPDATA = $appDataLocal
$completed = [System.Collections.Generic.List[object]]::new()
$startIndex = 0
$stopReason = 'SAMPLE_PLAN_COMPLETE'

function Get-RelativePath([string]$Path) {
	if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
	$fullPath = [IO.Path]::GetFullPath($Path)
	if (-not ([IO.File]::Exists($fullPath) -or [IO.Directory]::Exists($fullPath))) { return $null }
	return [IO.Path]::GetRelativePath($EvidenceRoot, $fullPath).Replace('\','/')
}

function Get-Sha256([string]$Path) {
	if (-not [IO.File]::Exists($Path)) { return $null }
	return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLower()
}

function Save-R19Checkpoint([int]$NextIndex, [string]$Reason) {
	$checkpointId = '{0:D2}_{1}' -f $NextIndex, ([guid]::NewGuid().ToString('N'))
	$checkpointPath = Join-Path $attemptPath "checkpoint_$checkpointId.json"
	foreach ($row in $preflightRows) {
		$levelTrials = @($completed | Where-Object { $_.case.island_id -ceq $row.island_id -and [int]$_.case.level_id -eq [int]$row.level_id })
		$isInheritedRetry = $attemptRole -eq 'R19_ADAPTIVE_RETRY' -and $levelTrials.Count -gt 0 -and $row.island_id -ceq $samplePlan[0].island -and [int]$row.level_id -eq [int]$samplePlan[0].level
		$row.trial_count = $levelTrials.Count + [int][bool]$isInheritedRetry
		$row.retry_count = [Math]::Max(0, $levelTrials.Count - 1) + [int][bool]$isInheritedRetry
		if ($levelTrials.Count) {
			$observedWin = @($levelTrials | Where-Object classification -eq 'WIN_OBSERVED' | Select-Object -Last 1)
			$latest = $levelTrials[-1]
			$row.status = if ($observedWin.Count) { 'WIN_OBSERVED' } else { [string]$latest.classification }
			$row.latest_shot_count = [int]$latest.shot_count
			$row.latest_action_count = [int]$latest.action_count
			$row.best_objective_progress = [Math]::Max([int]$row.best_objective_progress, [int]($levelTrials | Measure-Object -Property normal_objective_progress -Maximum).Maximum)
			if ($isInheritedRetry) { $row.best_objective_progress = [Math]::Max([int]$row.best_objective_progress, $parentObjectiveProgress) }
			if ($observedWin.Count) { $row.winning_trace_path = [string]$observedWin[0].trace_path }
			if ($isInheritedRetry) { $row.parent_trial_attempt_id = $parentTrialAttemptId }
		}
	}
	$checkpoint = [ordered]@{
		schema_version=1;work_item='BCM-M34-R19';attempt_id=$attemptId;checkpoint_id=$checkpointId
		next_case_index=$NextIndex;stop_reason=$Reason;created_utc=[DateTime]::UtcNow.ToString('o')
		completed_trials=@($completed)
		per_level_state=@($preflightRows)
		outcome_counts=@{WIN_OBSERVED=@($completed | Where-Object classification -eq 'WIN_OBSERVED').Count;LOSS_OBSERVED=@($completed | Where-Object classification -eq 'LOSS_OBSERVED').Count;BUDGET_UNKNOWN=@($completed | Where-Object classification -eq 'BUDGET_UNKNOWN').Count;ERROR=@($completed | Where-Object classification -eq 'ERROR').Count}
	}
	$published = Publish-R17UniqueJson -Path $checkpointPath -Value $checkpoint
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{
		event_id=[guid]::NewGuid().ToString('N');event_type='BATCH_CHECKPOINT';attempt_id=$attemptId;checkpoint_id=$checkpointId
		checkpoint_path=Get-RelativePath $published;checkpoint_sha256=Get-Sha256 $published;next_case_index=$NextIndex;stop_reason=$Reason
	})
}

try {
	$campaignData = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'data/campaign/islands.json') | ConvertFrom-Json
	$preflightRows = [System.Collections.Generic.List[object]]::new()
	foreach ($island in $campaignData.islands) {
		$levelFile = if ([string]$island.id -eq 'tiki_island') { 'tiki_island_full.json' } else { "{0}.json" -f [string]$island.id }
		$levelPath = Join-Path $repoRoot ("data/campaign/levels/{0}" -f $levelFile)
		$levelData = Get-Content -Raw -LiteralPath $levelPath | ConvertFrom-Json
		foreach ($level in $levelData.levels) {
			$globalLevelId = (([int]$island.order_index - 1) * 100) + [int]$level.level_id
		$preflightRows.Add(@{island_id=[string]$island.id;level_id=[int]$level.level_id;global_level_id=$globalLevelId;status='PENDING_PHYSICAL_QUALIFICATION';static_record_present=$true;retry_count=0;winning_trace_path=$null;trial_count=0;shot_count=0;latest_action_count=0;best_objective_progress=0;parent_trial_attempt_id=$null})
		}
	}
	if ($preflightRows.Count -ne 1000) { throw "Static plan enumerated $($preflightRows.Count) records, expected 1000." }
	$preflightPath = Join-Path $attemptPath 'campaign_static_preflight.json'
	if (-not [IO.File]::Exists($preflightPath)) {
		$preflight = [ordered]@{schema_version=1;work_item='BCM-M34-R19';status='STATIC_RECORDS_ENUMERATED_PHYSICAL_OUTCOMES_PENDING';expected_record_count=1000;enumerated_record_count=$preflightRows.Count;island_count=10;levels_per_island=100;created_utc=[DateTime]::UtcNow.ToString('o');levels=@($preflightRows)}
		[void](Publish-R17UniqueJson -Path $preflightPath -Value $preflight)
	}
	if ($ResumeAttemptId) {
		$recoveryResult = Repair-R19IncompleteTrials -EvidenceRoot $EvidenceRoot -AttemptId $attemptId
		$manifestEvents = @(Get-Content -LiteralPath $manifestPath | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop })
		$latestCheckpointEvent = @($manifestEvents | Where-Object { $_.event_type -eq 'BATCH_CHECKPOINT' -and $_.attempt_id -ceq $attemptId } | Select-Object -Last 1)
		if ($latestCheckpointEvent.Count) {
			$existingCheckpointPath = Join-Path $EvidenceRoot ([string]$latestCheckpointEvent[0].checkpoint_path)
			$existingCheckpoint = Get-Content -Raw -LiteralPath $existingCheckpointPath | ConvertFrom-Json -ErrorAction Stop
			if ((Get-Sha256 $existingCheckpointPath) -cne [string]$latestCheckpointEvent[0].checkpoint_sha256) { throw 'Existing immutable checkpoint hash mismatch.' }
			$startIndex = [int]$existingCheckpoint.next_case_index
			foreach ($trial in @($existingCheckpoint.completed_trials)) { $completed.Add($trial) }
		}
		$knownCompletedIds = @{}; foreach ($trial in $completed) { $knownCompletedIds[[string]$trial.trial_attempt_id] = $true }
		$recoveredFinishes = @($manifestEvents | Where-Object { $_.attempt_id -ceq $attemptId -and $_.event_type -eq 'TRIAL_FINISHED' -and $_.recovered_by -eq 'BCM-M34-R20' })
		foreach ($event in $recoveredFinishes) {
			if (-not $knownCompletedIds.ContainsKey([string]$event.trial_attempt_id)) {
				$recordPath = Join-Path $EvidenceRoot ([string]$event.case_record_path)
				$completed.Add((Get-Content -Raw -LiteralPath $recordPath | ConvertFrom-Json -ErrorAction Stop))
				$knownCompletedIds[[string]$event.trial_attempt_id] = $true
			}
			$planIndex = -1
			for ($i=0; $i -lt $samplePlan.Count; $i++) { if ([string]$samplePlan[$i].name -ceq [string]$event.trial_name) { $planIndex=$i; break } }
			if ($planIndex -ge 0) { $startIndex = [Math]::Max($startIndex, $planIndex + 1) }
		}
		if ($recoveredFinishes.Count) { Save-R19Checkpoint -NextIndex $startIndex -Reason 'R20_RECOVERED_INTERRUPTED_TRIALS' }
	}
	$planEvent = [ordered]@{
		event_id=[guid]::NewGuid().ToString('N');event_type='PILOT_PLAN';attempt_id=$attemptId;role=$attemptRole;parent_attempt_id=$ParentAttemptId;parent_trial_attempt_id=$parentTrialAttemptId;provenance=$provenance;policy='R19_FEEDBACK_AWARE_V01'
		physics_mode='standard_fps_production_physics';fixed_fps=$false;time_scale=1.0;seed_policy='fixed, unique per case'
		trial_timeout_seconds=$TrialTimeoutSeconds;global_budget_seconds=$GlobalBudgetSeconds
		per_trial_internal_wall_limit_seconds=24;normal_4t_cap_source='canonical theoretical_shots_to_go * 4; optional VIP excluded'
		input_path='ShotController._unhandled_input mouse press/release -> footprint projection -> _launch -> Drink.launch_up -> Godot physics'
		inherited_feedback_path=if($inheritedFeedbackPath){[IO.Path]::GetRelativePath($EvidenceRoot,$inheritedFeedbackPath).Replace('\','/')}else{$null}
		inherited_feedback_sha256=if($inheritedFeedbackPath){Get-Sha256 $inheritedFeedbackPath}else{$null}
		static_preflight_path=Get-RelativePath $preflightPath;static_preflight_sha256=Get-Sha256 $preflightPath
		sample_cases=@($samplePlan | ForEach-Object {@{name=$_.name;island_id=$_.island;level_id=$_.level;seed=$_.seed;difficulty_band=$_.band}})
		stop_rule='Pilot only: 12 representative cases; adaptive retries require inherited hash-verified lane feedback. Broader batches require a WIN_OBSERVED outside global level 1. Errors stop the active attempt; budget unknown never implies impossible.'
	}
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event $planEvent

	for ($caseIndex = $startIndex; $caseIndex -lt $samplePlan.Count; $caseIndex++) {
		if ($clock.Elapsed.TotalSeconds -ge $GlobalBudgetSeconds -or ($GlobalBudgetSeconds - $clock.Elapsed.TotalSeconds) -lt ($TrialTimeoutSeconds + 10)) { $stopReason = 'GLOBAL_BUDGET_RESERVE_REACHED'; break }
		$case = $samplePlan[$caseIndex]
		$canonicalRow = @($preflightRows | Where-Object { $_.island_id -ceq $case.island -and [int]$_.level_id -eq [int]$case.level } | Select-Object -First 1)[0]
		if ($null -eq $canonicalRow) { throw "Pilot case is not present in the 1,000-level static preflight: $($case.name)" }
		$trialAttemptId = [guid]::NewGuid().ToString('N')
		$trialPath = Join-Path $attemptPath "trial_$trialAttemptId"
		if ([IO.Directory]::Exists($trialPath) -or [IO.File]::Exists($trialPath)) { throw "Trial path collision refused: $trialPath" }
		[IO.Directory]::CreateDirectory($trialPath) | Out-Null
		$outputPath = Join-Path $trialPath 'trial_result_live.json'
		$progressPath = Join-Path $trialPath 'progress_live.json'
		$watchdogPath = Join-Path $trialPath 'watchdog_result.json'
		$tracePath = Join-Path $trialPath 'final_trace.json'
		$caseRecordPath = Join-Path $trialPath 'case_record.json'
		$caseData = [ordered]@{name=$case.name;island_id=$case.island;level_id=[int]$case.level;global_level_id=[int]$canonicalRow.global_level_id;seed=[int]$case.seed;difficulty_band=$case.band;policy='R19_FEEDBACK_AWARE_V01';physics_mode='standard_fps_production_physics';fixed_fps=$false;time_scale=1.0;normal_4t_cap_source='canonical theoretical_shots_to_go * 4; optional VIP excluded'}
		$startedUtc = [DateTime]::UtcNow.ToString('o')
		Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='TRIAL_STARTED';attempt_id=$attemptId;trial_attempt_id=$trialAttemptId;trial_name=$case.name;role=if($attemptRole -eq 'R19_ADAPTIVE_RETRY'){'ADAPTIVE_RETRY'}else{'QUALIFICATION_PILOT'};parent_trial_attempt_id=$parentTrialAttemptId;provenance=$provenance;case=$caseData;trial_path=Get-RelativePath $trialPath;started_utc=$startedUtc})
		$arguments = @('--headless','--path',$repoRoot,'--script',$probe,'--',"--r19-output=$outputPath","--r19-progress=$progressPath","--r19-island=$($case.island)","--r19-level=$($case.level)","--r19-seed=$($case.seed)","--r19-wall-limit=24")
		if ($inheritedFeedbackPath) { $arguments += "--r19-feedback=$inheritedFeedbackPath" }
		& $watchdog -FilePath $godot -ArgumentList $arguments -TimeoutSeconds $TrialTimeoutSeconds -ResultPath $watchdogPath -ProgressPath $progressPath -TaskName "BCM-M34-R19-$trialAttemptId"
		$watchdogExit = $LASTEXITCODE
		$watchdogData = if ([IO.File]::Exists($watchdogPath)) { Get-Content -Raw -LiteralPath $watchdogPath | ConvertFrom-Json } else { $null }
		$probeData = if ([IO.File]::Exists($outputPath)) { try { Get-Content -Raw -LiteralPath $outputPath | ConvertFrom-Json } catch { $null } } else { $null }
		if ($null -eq $watchdogData) { $watchdogData = [pscustomobject]@{status='ERROR';reason='WATCHDOG_RESULT_MISSING';exit_code=$null;root_identity_verified=$false;terminated_processes=@();stderr='';stdout='';partial_progress=$null} }
		$outcome = Get-R17WatchdogClassification -Watchdog $watchdogData -ProbeResult $probeData
		$traceSource = if ($probeData) { $outputPath } elseif ([IO.File]::Exists($progressPath)) { $progressPath } else { $null }
		$trace = if ($traceSource) { try { Get-Content -Raw -LiteralPath $traceSource | ConvertFrom-Json } catch { $null } } else { $null }
		if ($trace) { [void](Publish-R17UniqueJson -Path $tracePath -Value $trace) }
		$digest = if ([IO.File]::Exists($tracePath)) { Get-R17ActionProgressDigest -TracePath $tracePath } else { $null }
		$objectiveProgress = if ($trace) { Get-R17ObjectiveProgress -Trace $trace } elseif ($watchdogData.partial_progress) { Get-R17ObjectiveProgress -Trace $watchdogData.partial_progress } else { 0 }
		$record = [ordered]@{
			schema_version=1;work_item='BCM-M34-R19';attempt_id=$attemptId;trial_attempt_id=$trialAttemptId;trial_name=$case.name;role=if($attemptRole -eq 'R19_ADAPTIVE_RETRY'){'ADAPTIVE_RETRY'}else{'QUALIFICATION_PILOT'};parent_trial_attempt_id=$parentTrialAttemptId;provenance=$provenance;case=$caseData
			classification=[string]$outcome.classification;failure_kind=[string]$outcome.failure_kind;reason=[string]$outcome.reason;watchdog_status=[string]$outcome.watchdog_status
			watchdog_exit_code=$outcome.exit_code;watchdog_exit_code_hex=$outcome.exit_code_hex;process_identity_verified=[bool]$outcome.process_identity_verified
			watchdog_terminated_count=[int]$outcome.watchdog_terminated_count;stderr_length=[int]$outcome.stderr_length;wall_elapsed_ms=[int]$watchdogData.wall_elapsed_ms
			shot_count=if($trace){[int]$trace.shots_used}else{0}
			normal_theoretical_shots_T=if($trace){[int]$trace.normal_theoretical_shots_T}else{0};normal_4t_shot_cap=if($trace){[int]$trace.normal_4t_shot_cap}else{0}
			normal_4t_cap_verified=([bool]$trace -and [int]$trace.normal_4t_shot_cap -eq 4 * [int]$trace.normal_theoretical_shots_T -and [bool]$trace.normal_4t_cap_verified)
			normal_objective_progress=$objectiveProgress;action_count=if($digest){[int]$digest.action_count}else{0};progress_point_count=if($digest){[int]$digest.progress_count}else{0}
			action_progress_sha256=if($digest){[string]$digest.action_progress_sha256}else{$null}
			trace_path=Get-RelativePath $tracePath;trace_file_sha256=Get-Sha256 $tracePath
			watchdog_path=Get-RelativePath $watchdogPath;watchdog_file_sha256=Get-Sha256 $watchdogPath
			probe_result_path=Get-RelativePath $outputPath;probe_result_sha256=Get-Sha256 $outputPath
			started_utc=$startedUtc;finished_utc=[DateTime]::UtcNow.ToString('o')
		}
		[void](Publish-R17UniqueJson -Path $caseRecordPath -Value $record)
		$caseHash = Get-Sha256 $caseRecordPath
		Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{
			event_id=[guid]::NewGuid().ToString('N');event_type='TRIAL_FINISHED';attempt_id=$attemptId;trial_attempt_id=$trialAttemptId;trial_name=$case.name;role=if($attemptRole -eq 'R19_ADAPTIVE_RETRY'){'ADAPTIVE_RETRY'}else{'QUALIFICATION_PILOT'};parent_trial_attempt_id=$parentTrialAttemptId;provenance=$provenance;case=$caseData
			classification=$record.classification;failure_kind=$record.failure_kind;reason=$record.reason;normal_objective_progress=$objectiveProgress
			normal_theoretical_shots_T=$record.normal_theoretical_shots_T;normal_4t_shot_cap=$record.normal_4t_shot_cap;normal_4t_cap_verified=$record.normal_4t_cap_verified
			case_record_path=Get-RelativePath $caseRecordPath;case_record_sha256=$caseHash;trace_path=$record.trace_path;trace_file_sha256=$record.trace_file_sha256
			action_progress_sha256=$record.action_progress_sha256;watchdog_path=$record.watchdog_path;watchdog_file_sha256=$record.watchdog_file_sha256;finished_utc=$record.finished_utc
		})
		$completed.Add([pscustomobject]$record)
		Save-R19Checkpoint -NextIndex ($caseIndex + 1) -Reason 'CASE_COMPLETED'
		Write-Host "R19_TRIAL case=$($case.name) outcome=$($record.classification) failure=$($record.failure_kind) objective_progress=$objectiveProgress actions=$($record.action_count) wall_ms=$($record.wall_elapsed_ms)"
		if ($record.classification -eq 'ERROR') { $stopReason = 'ERROR_REQUIRES_DIAGNOSIS'; break }
	}

	$distinctWins = @($completed | Where-Object classification -eq 'WIN_OBSERVED' | ForEach-Object { "$($_.case.island_id)/$($_.case.level_id)" } | Sort-Object -Unique)
	$winsBeyondEasiest = @($completed | Where-Object { $_.classification -eq 'WIN_OBSERVED' -and [int]$_.case.global_level_id -gt 1 } | ForEach-Object { "$($_.case.island_id)/$($_.case.level_id)" } | Sort-Object -Unique)
	$attemptManifestEvents = @(Get-Content -LiteralPath $manifestPath | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop } | Where-Object { $_.PSObject.Properties.Name -contains 'attempt_id' -and $_.attempt_id -ceq $attemptId })
	$finishedTrialIds = @($attemptManifestEvents | Where-Object event_type -eq 'TRIAL_FINISHED' | ForEach-Object { [string]$_.trial_attempt_id })
	$incompleteTrialIds = @($attemptManifestEvents | Where-Object { $_.event_type -eq 'TRIAL_STARTED' -and $finishedTrialIds -notcontains [string]$_.trial_attempt_id } | ForEach-Object { [string]$_.trial_attempt_id })
	$tasksAfter = (git -C $repoRoot hash-object TASKS.md).Trim()
	$freeAfter = [long](Get-Volume -DriveLetter $drive).SizeRemaining
	$summary = [ordered]@{
		schema_version=1;work_item='BCM-M34-R19';attempt_id=$attemptId;status=if($stopReason -eq 'SAMPLE_PLAN_COMPLETE' -and $completed.Count -eq $samplePlan.Count -and $incompleteTrialIds.Count -eq 0 -and @($completed | Where-Object classification -eq 'ERROR').Count -eq 0){'PILOT_COMPLETE'}else{'PILOT_PARTIAL'}
		stop_reason=if($incompleteTrialIds.Count){'UNFINALIZED_TRIALS_RECORDED'}else{$stopReason};planned_sample_count=$samplePlan.Count;completed_sample_count=$completed.Count;incomplete_trial_attempt_ids=$incompleteTrialIds;distinct_observed_win_levels=$distinctWins;distinct_wins_beyond_easiest=$winsBeyondEasiest
		broader_batch_gate=if($winsBeyondEasiest.Count -gt 0){'ELIGIBLE_FOR_SEPARATE_BOUNDED_BATCH'}else{'NOT_MET'}
		trial_timeout_seconds=$TrialTimeoutSeconds;global_budget_seconds=$GlobalBudgetSeconds;actual_elapsed_ms=[int]$clock.Elapsed.TotalMilliseconds;actual_disk_free_delta_bytes=($freeAfter-$freeBefore)
		static_preflight_path=Get-RelativePath $preflightPath;static_preflight_sha256=Get-Sha256 $preflightPath
		outcome_counts=@{WIN_OBSERVED=@($completed | Where-Object classification -eq 'WIN_OBSERVED').Count;LOSS_OBSERVED=@($completed | Where-Object classification -eq 'LOSS_OBSERVED').Count;BUDGET_UNKNOWN=@($completed | Where-Object classification -eq 'BUDGET_UNKNOWN').Count;ERROR=@($completed | Where-Object classification -eq 'ERROR').Count}
		appdata_roaming_path=$appDataRoaming;appdata_local_path=$appDataLocal;tasks_blob_before=$tasksBefore;tasks_blob_after=$tasksAfter;tasks_unchanged=($tasksBefore -ceq $tasksAfter)
		completed_trials=@($completed | ForEach-Object {@{trial_attempt_id=$_.trial_attempt_id;trial_name=$_.trial_name;classification=$_.classification;failure_kind=$_.failure_kind;objective_progress=$_.normal_objective_progress;action_count=$_.action_count;trace_path=$_.trace_path;trace_file_sha256=$_.trace_file_sha256;action_progress_sha256=$_.action_progress_sha256}})
	}
	if (-not [IO.File]::Exists((Join-Path $attemptPath 'attempt_summary.json'))) {
		$summaryPath = Publish-R17UniqueJson -Path (Join-Path $attemptPath 'attempt_summary.json') -Value $summary
		Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='ATTEMPT_FINISHED';attempt_id=$attemptId;status=$summary.status;stop_reason=$stopReason;summary_path=Get-RelativePath $summaryPath;summary_sha256=Get-Sha256 $summaryPath;finished_utc=[DateTime]::UtcNow.ToString('o')})
	}
	Write-Output "R19_ATTEMPT=$attemptId status=$($summary.status) stop=$stopReason trials=$($completed.Count)/$($samplePlan.Count) wins_beyond_easiest=$($winsBeyondEasiest.Count) elapsed_ms=$($summary.actual_elapsed_ms) tasks_unchanged=$($summary.tasks_unchanged)"
} finally {
	$env:APPDATA = $oldAppData
	$env:LOCALAPPDATA = $oldLocalAppData
}

if ($tasksBefore -cne $tasksAfter) { throw 'TASKS.md Git blob changed during R19 pilot.' }
