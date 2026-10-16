[CmdletBinding()]
param([string]$EvidenceRoot = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Import-Module (Join-Path $PSScriptRoot 'm34_r17_pilot_integrity.psm1') -Force
if ([string]::IsNullOrWhiteSpace($EvidenceRoot)) { $EvidenceRoot = Join-Path $repoRoot 'coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R20' }
$EvidenceRoot = [IO.Path]::GetFullPath($EvidenceRoot)
[IO.Directory]::CreateDirectory($EvidenceRoot) | Out-Null
$manifestPath = Join-Path $EvidenceRoot 'attempt_manifest.jsonl'
$attemptId = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '_' + [guid]::NewGuid().ToString('N')
$trialId = [guid]::NewGuid().ToString('N')
$attemptPath = Join-Path (Join-Path $EvidenceRoot 'attempts') $attemptId
$trialPath = Join-Path $attemptPath "trial_$trialId"
if ([IO.Directory]::Exists($attemptPath) -or [IO.File]::Exists($attemptPath)) { throw 'Attempt collision refused.' }
[IO.Directory]::CreateDirectory($trialPath) | Out-Null
$trialName = 'sunny_cove_l25_objective_lookahead_single'
$case = [ordered]@{name=$trialName;island_id='sunny_cove';level_id=25;global_level_id=25;seed=34117025;policy='R20_OBJECTIVE_LOOKAHEAD_V01';physics_mode='standard_fps_production_physics';fixed_fps=$false;time_scale=1.0;normal_4t_cap_source='canonical theoretical_shots_to_go * 4; optional VIP excluded'}
$relative = { param([string]$Path) if ([string]::IsNullOrWhiteSpace($Path)) { return $null }; $full=[IO.Path]::GetFullPath($Path); if (-not ([IO.File]::Exists($full) -or [IO.Directory]::Exists($full))) { return $null }; return [IO.Path]::GetRelativePath($EvidenceRoot,$full).Replace('\','/') }
$sha = { param([string]$Path) if ([IO.File]::Exists($Path)) { return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant() }; return $null }
$roaming = Join-Path $attemptPath 'isolated_appdata_roaming'; $local = Join-Path $attemptPath 'isolated_appdata_local'
[IO.Directory]::CreateDirectory($roaming) | Out-Null; [IO.Directory]::CreateDirectory($local) | Out-Null
$oldAppData=$env:APPDATA; $oldLocal=$env:LOCALAPPDATA; $env:APPDATA=$roaming; $env:LOCALAPPDATA=$local
$tasksBefore=(git -C $repoRoot hash-object TASKS.md).Trim()
$trialStarted=[DateTime]::UtcNow.ToString('o')
$watchdog = Join-Path $PSScriptRoot 'm34_r14_process_watchdog.ps1'
$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$probe = Join-Path $PSScriptRoot 'm34_r19_autonomous_trial.gd'
$outputPath=Join-Path $trialPath 'trial_result_live.json'; $progressPath=Join-Path $trialPath 'progress_live.json'; $watchdogPath=Join-Path $trialPath 'watchdog_result.json'; $tracePath=Join-Path $trialPath 'final_trace.json'; $recordPath=Join-Path $trialPath 'case_record.json'
try {
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='ATTEMPT_STARTED';attempt_id=$attemptId;attempt_path=&$relative $attemptPath;role='R20_SINGLE_CHALLENGE';started_utc=$trialStarted})
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='TRIAL_STARTED';attempt_id=$attemptId;trial_attempt_id=$trialId;trial_name=$trialName;role='R20_SINGLE_CHALLENGE';provenance='One bounded real-physics Sunny Cove L25 challenge using objective-aware depth-three lane lookahead; no batch expansion.';case=$case;trial_path=&$relative $trialPath;started_utc=$trialStarted})
	$arguments=@('--headless','--path',$repoRoot,'--script',$probe,'--',"--r19-output=$outputPath","--r19-progress=$progressPath",'--r19-island=sunny_cove','--r19-level=25','--r19-seed=34117025','--r19-policy=R20_OBJECTIVE_LOOKAHEAD_V01','--r19-wall-limit=105')
	& $watchdog -FilePath $godot -ArgumentList $arguments -TimeoutSeconds 120 -ResultPath $watchdogPath -ProgressPath $progressPath -TaskName "BCM-M34-R20-$trialId"
	$watchdogExit=$LASTEXITCODE
	$watch=if([IO.File]::Exists($watchdogPath)){Get-Content -Raw -LiteralPath $watchdogPath|ConvertFrom-Json -ErrorAction Stop}else{$null}
	$probeData=if([IO.File]::Exists($outputPath)){try{Get-Content -Raw -LiteralPath $outputPath|ConvertFrom-Json -ErrorAction Stop}catch{$null}}else{$null}
	if($null -eq $watch){$watch=[pscustomobject]@{status='ERROR';reason='WATCHDOG_RESULT_MISSING';exit_code=$null;root_identity_verified=$false;terminated_processes=@();stderr='';stdout='';partial_progress=$null;wall_elapsed_ms=0}}
	$outcome=Get-R17WatchdogClassification -Watchdog $watch -ProbeResult $probeData
	$traceSource=if($probeData){$outputPath}elseif([IO.File]::Exists($progressPath)){$progressPath}else{$null}
	$trace=if($traceSource){try{Get-Content -Raw -LiteralPath $traceSource|ConvertFrom-Json -ErrorAction Stop}catch{$null}}else{$null}
	if($trace){[void](Publish-R17UniqueJson -Path $tracePath -Value $trace)}
	$digest=if([IO.File]::Exists($tracePath)){Get-R17ActionProgressDigest -TracePath $tracePath}else{$null}
	$objectiveProgress=if($trace){Get-R17ObjectiveProgress -Trace $trace}elseif($watch.partial_progress){Get-R17ObjectiveProgress -Trace $watch.partial_progress}else{0}
	$record=[ordered]@{schema_version=1;work_item='BCM-M34-R20';attempt_id=$attemptId;trial_attempt_id=$trialId;trial_name=$trialName;role='R20_SINGLE_CHALLENGE';provenance='One bounded real-physics Sunny Cove L25 challenge using objective-aware depth-three lane lookahead; no batch expansion.';case=$case;classification=[string]$outcome.classification;failure_kind=[string]$outcome.failure_kind;reason=[string]$outcome.reason;watchdog_status=[string]$outcome.watchdog_status;watchdog_exit_code=$outcome.exit_code;process_identity_verified=[bool]$outcome.process_identity_verified;watchdog_terminated_count=[int]$outcome.watchdog_terminated_count;stderr_length=[int]$outcome.stderr_length;wall_elapsed_ms=[int]$watch.wall_elapsed_ms;shot_count=if($trace){[int]$trace.shots_used}else{0};normal_theoretical_shots_T=if($trace){[int]$trace.normal_theoretical_shots_T}else{0};normal_4t_shot_cap=if($trace){[int]$trace.normal_4t_shot_cap}else{0};normal_4t_cap_verified=([bool]$trace -and [int]$trace.normal_4t_shot_cap -eq 4*[int]$trace.normal_theoretical_shots_T -and [bool]$trace.normal_4t_cap_verified);normal_objective_progress=$objectiveProgress;action_count=if($digest){[int]$digest.action_count}else{0};action_progress_sha256=if($digest){[string]$digest.action_progress_sha256}else{$null};trace_path=&$relative $tracePath;trace_file_sha256=&$sha $tracePath;watchdog_path=&$relative $watchdogPath;watchdog_file_sha256=&$sha $watchdogPath;probe_result_path=&$relative $outputPath;probe_result_sha256=&$sha $outputPath;started_utc=$trialStarted;finished_utc=[DateTime]::UtcNow.ToString('o')}
	[void](Publish-R17UniqueJson -Path $recordPath -Value $record)
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id="r20-trial-finished-$trialId";event_type='TRIAL_FINISHED';attempt_id=$attemptId;trial_attempt_id=$trialId;trial_name=$trialName;role='R20_SINGLE_CHALLENGE';case=$case;classification=$record.classification;failure_kind=$record.failure_kind;reason=$record.reason;normal_objective_progress=$objectiveProgress;normal_theoretical_shots_T=$record.normal_theoretical_shots_T;normal_4t_shot_cap=$record.normal_4t_shot_cap;normal_4t_cap_verified=$record.normal_4t_cap_verified;case_record_path=&$relative $recordPath;case_record_sha256=&$sha $recordPath;trace_path=$record.trace_path;trace_file_sha256=$record.trace_file_sha256;watchdog_path=$record.watchdog_path;watchdog_file_sha256=$record.watchdog_file_sha256;finished_utc=$record.finished_utc})
	$taskAfter=(git -C $repoRoot hash-object TASKS.md).Trim()
	$tasksUnchanged = $tasksBefore -ceq $taskAfter
	$summary=[ordered]@{schema_version=1;work_item='BCM-M34-R20';attempt_id=$attemptId;status=if($record.classification -eq 'ERROR'){'CHALLENGE_ERROR'}else{'SINGLE_CHALLENGE_COMPLETE'};planned_trials=1;completed_trials=1;classification=$record.classification;normal_objective_progress=$objectiveProgress;win_beyond_sunny_cove_l1=($record.classification -eq 'WIN_OBSERVED');broader_batch_gate=if($record.classification -eq 'WIN_OBSERVED'){'ELIGIBLE_FOR_SEPARATE_BOUNDED_DECISION'}else{'NOT_MET'};no_batch_expansion_performed=$true;tasks_unchanged=$tasksUnchanged;tasks_blob_before=$tasksBefore;tasks_blob_after=$taskAfter;trial_record_path=&$relative $recordPath;trial_record_sha256=&$sha $recordPath;created_utc=[DateTime]::UtcNow.ToString('o')}
	$summaryPath=Publish-R17UniqueJson -Path (Join-Path $attemptPath 'attempt_summary.json') -Value $summary
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='ATTEMPT_FINISHED';attempt_id=$attemptId;status=$summary.status;classification=$record.classification;tasks_unchanged=$tasksUnchanged;tasks_blob_before=$tasksBefore;tasks_blob_after=$taskAfter;summary_path=&$relative $summaryPath;summary_sha256=&$sha $summaryPath;finished_utc=$summary.created_utc})
	if (-not $tasksUnchanged) { Write-Warning 'TASKS.md Git blob changed during R20 challenge; final artifacts and ATTEMPT_FINISHED were preserved for audit.' }
	Write-Output "R20_SINGLE_CHALLENGE attempt=$attemptId trial=$trialId classification=$($record.classification) progress=$objectiveProgress shots=$($record.shot_count)/$($record.normal_4t_shot_cap) wall_ms=$($record.wall_elapsed_ms) watchdog_exit=$watchdogExit"
} finally { $env:APPDATA=$oldAppData; $env:LOCALAPPDATA=$oldLocal }
