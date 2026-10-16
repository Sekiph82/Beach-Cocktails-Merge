[CmdletBinding()]
param([string]$EvidenceRoot = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Import-Module (Join-Path $repoRoot 'tools/campaign/m34_r20_recovery.psm1') -Force
Import-Module (Join-Path $repoRoot 'tools/campaign/m34_r17_pilot_integrity.psm1') -Force
if ([string]::IsNullOrWhiteSpace($EvidenceRoot)) { $EvidenceRoot = Join-Path $repoRoot 'coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R20' }
$EvidenceRoot = [IO.Path]::GetFullPath($EvidenceRoot)
$testRoot = Join-Path $EvidenceRoot "recovery_test_$([guid]::NewGuid().ToString('N'))"
$attemptsRoot = Join-Path $testRoot 'attempts'
[IO.Directory]::CreateDirectory($attemptsRoot) | Out-Null
$manifest = Join-Path $testRoot 'attempt_manifest.jsonl'
$assertions = 0

function Assert-R20([bool]$Condition, [string]$Message) {
	if (-not $Condition) { throw "R20 recovery assertion failed: $Message" }
	$script:assertions++
}

function New-R20Fixture([string]$Name, [bool]$Complete, [bool]$PrewriteRecord = $false) {
	$attemptId = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '_' + [guid]::NewGuid().ToString('N')
	$trialId = [guid]::NewGuid().ToString('N')
	$attemptPath = Join-Path $attemptsRoot $attemptId
	$trialPath = Join-Path $attemptPath "trial_$trialId"
	[IO.Directory]::CreateDirectory($trialPath) | Out-Null
	Add-R17ManifestEvent -ManifestPath $manifest -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='ATTEMPT_STARTED';attempt_id=$attemptId;attempt_path=$attemptPath;role='R20_RECOVERY_TEST';started_utc=[DateTime]::UtcNow.ToString('o')})
	$case = [ordered]@{name=$Name;island_id='sunny_cove';level_id=25;global_level_id=25;seed=20261016;policy='R20_TEST';physics_mode='standard_fps_production_physics';fixed_fps=$false;time_scale=1.0;normal_4t_cap_source='T*4'}
	Add-R17ManifestEvent -ManifestPath $manifest -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='TRIAL_STARTED';attempt_id=$attemptId;trial_attempt_id=$trialId;trial_name=$Name;role='R20_RECOVERY_TEST';parent_trial_attempt_id=$null;provenance='synthetic crash-recovery fixture';case=$case;trial_path="attempts/$attemptId/trial_$trialId";started_utc=[DateTime]::UtcNow.ToString('o')})
	$trace = [ordered]@{schema_version=1;work_item='BCM-M34-R19';status=if($Complete){'CASE_COMPLETE'}else{'CASE_RUNNING'};classification='BUDGET_UNKNOWN';case=@{island_id='sunny_cove';level_id=25;seed=20261016};normal_theoretical_shots_T=2;normal_4t_shot_cap=8;normal_4t_cap_verified=$Complete;shots_used=2;terminal_reason=if($Complete){'PER_LEVEL_WALL_BUDGET'}else{'RUNNING'};normal_orders_completed=@{};normal_orders_remaining=@{};action_log=@(@{step=0;spawn_level=1;x_position=220;requested_viewport_x=220;fired_position=@(220,960)});progress_curve=@(@{normal_T_start=2;normal_T_remaining=2;normal_T_progressed=0});merge_events=@();contact_events=@();merge_count=0;contact_count=0;action_progress_sha256='fixture'}
	$tracePath = Join-Path $trialPath 'final_trace.json'
	if ($Complete) { [void](Publish-R17UniqueJson -Path $tracePath -Value $trace) }
	$watchdog = [ordered]@{schema_version=1;task='R20-test';status=if($Complete){'EXITED'}else{'CHILD_ERROR'};reason=if($Complete){'CHILD_EXITED_WITHIN_WALL_BUDGET'}else{'CHILD_PROCESS_NONZERO_EXIT'};wall_elapsed_ms=4;timeout_seconds=10;root_identity_verified=$true;exit_code=if($Complete){0}else{23};terminated_processes=@();stderr=''}
	$watchdogPath=Join-Path $trialPath 'watchdog_result.json'; [void](Publish-R17UniqueJson -Path $watchdogPath -Value $watchdog)
	if ($Complete) { [void](Publish-R17UniqueJson -Path (Join-Path $trialPath 'trial_result_live.json') -Value $trace) }
	if ($PrewriteRecord) {
		$digest=Get-R17ActionProgressDigest -TracePath $tracePath
		$record=[ordered]@{schema_version=1;work_item='BCM-M34-R20';attempt_id=$attemptId;trial_attempt_id=$trialId;trial_name=$Name;role='R20_RECOVERY_TEST';parent_trial_attempt_id=$null;provenance='prewritten before simulated manifest-append crash';case=$case;classification='BUDGET_UNKNOWN';failure_kind='NONE';reason='PER_LEVEL_WALL_BUDGET';watchdog_status='EXITED';watchdog_exit_code=0;process_identity_verified=$true;watchdog_terminated_count=0;stderr_length=0;wall_elapsed_ms=4;shot_count=2;normal_theoretical_shots_T=2;normal_4t_shot_cap=8;normal_4t_cap_verified=$true;normal_objective_progress=0;action_count=1;progress_point_count=1;action_progress_sha256=$digest.action_progress_sha256;trace_path="attempts/$attemptId/trial_$trialId/final_trace.json";trace_file_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $tracePath).Hash.ToLowerInvariant();watchdog_path="attempts/$attemptId/trial_$trialId/watchdog_result.json";watchdog_file_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $watchdogPath).Hash.ToLowerInvariant();probe_result_path="attempts/$attemptId/trial_$trialId/trial_result_live.json";probe_result_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $trialPath 'trial_result_live.json')).Hash.ToLowerInvariant();started_utc='2026-10-16T00:00:00Z';finished_utc='2026-10-16T00:00:01Z'}
		[void](Publish-R17UniqueJson -Path (Join-Path $trialPath 'case_record.json') -Value $record)
	}
	return [pscustomobject]@{attempt_id=$attemptId;trial_id=$trialId;trial_path=$trialPath;trace_path=$tracePath;watchdog_path=$watchdogPath}
}

$afterResultCrash = New-R20Fixture 'after_result_before_record' $true
$first = Repair-R19IncompleteTrials -EvidenceRoot $testRoot -AttemptId $afterResultCrash.attempt_id
Assert-R20 ($first.status -eq 'RECOVERED') 'completed result survives postprocessor exit'
Assert-R20 ($first.recovered_trial_attempt_ids -contains $afterResultCrash.trial_id) 'recovery records the orphan trial id'
$firstManifestHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $manifest).Hash
$firstRecordHash=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $afterResultCrash.trial_path 'case_record.json')).Hash
$second=Repair-R19IncompleteTrials -EvidenceRoot $testRoot -AttemptId $afterResultCrash.attempt_id
Assert-R20 ($second.status -eq 'NOOP_ALREADY_REPAIRED') 'repeat recovery is idempotent'
Assert-R20 ((Get-FileHash -Algorithm SHA256 -LiteralPath $manifest).Hash -ceq $firstManifestHash) 'second recovery appends no duplicate event'
Assert-R20 ((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $afterResultCrash.trial_path 'case_record.json')).Hash -ceq $firstRecordHash) 'case record remains immutable'

$afterRecordCrash=New-R20Fixture 'after_record_before_finish' $true $true
$preexistingRecordHash=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $afterRecordCrash.trial_path 'case_record.json')).Hash
$resumed=Repair-R19IncompleteTrials -EvidenceRoot $testRoot -AttemptId $afterRecordCrash.attempt_id
Assert-R20 ($resumed.status -eq 'RECOVERED') 'existing case record is resumed'
Assert-R20 ((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $afterRecordCrash.trial_path 'case_record.json')).Hash -ceq $preexistingRecordHash) 'resume does not overwrite a case record'

$abrupt=New-R20Fixture 'abrupt_child_exit' $false
$childScript=Join-Path $abrupt.trial_path 'abrupt_child.ps1'
$partialPath=Join-Path $abrupt.trial_path 'progress_live.json'
[IO.File]::WriteAllText($childScript,"[IO.File]::WriteAllText('$partialPath', '{`"status`":`"CASE_RUNNING`",`"case`":{`"island_id`":`"sunny_cove`",`"level_id`":25,`"seed`":20261016},`"normal_theoretical_shots_T`":2,`"normal_4t_shot_cap`":8,`"normal_4t_cap_verified`":false,`"shots_used`":1,`"action_log`":[],`"progress_curve`":[]}'); exit 23`n",[Text.UTF8Encoding]::new($false))
$child=(Get-Command pwsh.exe -ErrorAction Stop).Source
$startInfo=[Diagnostics.ProcessStartInfo]::new($child);$startInfo.UseShellExecute=$false
$startInfo.ArgumentList.Add('-NoProfile');$startInfo.ArgumentList.Add('-File');$startInfo.ArgumentList.Add($childScript)
$process=[Diagnostics.Process]::Start($startInfo);$process.WaitForExit();$exitCode=$process.ExitCode
Assert-R20 ($exitCode -eq 23 -and [IO.File]::Exists($partialPath)) 'child exits abruptly after publishing partial state'
$failure=Repair-R19IncompleteTrials -EvidenceRoot $testRoot -AttemptId $abrupt.attempt_id
$errorEvent=Get-Content -LiteralPath $manifest | ForEach-Object {$_|ConvertFrom-Json} | Where-Object {$_.attempt_id -eq $abrupt.attempt_id -and $_.event_type -eq 'TRIAL_FINISHED'}
$errorRecord=Get-Content -Raw -LiteralPath (Join-Path $abrupt.trial_path 'case_record.json')|ConvertFrom-Json
Assert-R20 ($failure.status -eq 'RECOVERED' -and $errorEvent.classification -eq 'ERROR') 'abrupt child exit is recorded as ERROR, never as a win'
Assert-R20 ($errorRecord.normal_4t_cap_verified -eq $false -and $errorRecord.classification -eq 'ERROR') 'partial evidence cannot claim a completed 4T result'
$beforeNoopHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $manifest).Hash
$noop=Repair-R19IncompleteTrials -EvidenceRoot $testRoot -AttemptId $abrupt.attempt_id
Assert-R20 ($noop.status -eq 'NOOP_ALREADY_REPAIRED' -and (Get-FileHash -Algorithm SHA256 -LiteralPath $manifest).Hash -ceq $beforeNoopHash) 'abrupt-exit recovery resumes without duplicate events'

Write-Output "R20_RECOVERY_TEST_PASS assertions=$assertions fixture_root=$testRoot"
