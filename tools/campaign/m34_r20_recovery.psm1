Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'm34_r17_pilot_integrity.psm1') -Force

function Get-R20Sha256([string]$Path) {
	if (-not [IO.File]::Exists($Path)) { return $null }
	return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-R20RelativePath([string]$Root, [string]$Path) {
	$fullPath = [IO.Path]::GetFullPath($Path)
	$fullRoot = [IO.Path]::GetFullPath($Root)
	if (-not $fullPath.StartsWith($fullRoot.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "Evidence path escaped root: $fullPath" }
	if (-not ([IO.File]::Exists($fullPath) -or [IO.Directory]::Exists($fullPath))) { return $null }
	return [IO.Path]::GetRelativePath($fullRoot, $fullPath).Replace('\','/')
}

function Read-R20Manifest([string]$ManifestPath) {
	if (-not [IO.File]::Exists($ManifestPath)) { throw "R19 manifest is missing: $ManifestPath" }
	$bytes = [IO.File]::ReadAllBytes($ManifestPath)
	if ($bytes.Length -gt 0 -and $bytes[$bytes.Length - 1] -ne 10) { throw 'Manifest has a partial final line; recovery refuses to append.' }
	$events = [System.Collections.Generic.List[object]]::new()
	foreach ($line in [IO.File]::ReadAllLines($ManifestPath)) {
		if ([string]::IsNullOrWhiteSpace($line)) { throw 'Manifest contains a blank line; recovery refuses to append.' }
		$events.Add(($line | ConvertFrom-Json -ErrorAction Stop))
	}
	return $events
}

function Get-R20TrialTrace([string]$TrialPath) {
	$tracePath = Join-Path $TrialPath 'final_trace.json'
	if ([IO.File]::Exists($tracePath)) {
		$data = Get-Content -Raw -LiteralPath $tracePath | ConvertFrom-Json -ErrorAction Stop
		return [pscustomobject]@{Path=$tracePath;Data=$data;Complete=([string]$data.status -eq 'CASE_COMPLETE')}
	}
	foreach ($name in @('trial_result_live.json','progress_live.json')) {
		$candidate = Join-Path $TrialPath $name
		if ([IO.File]::Exists($candidate)) {
			$data = Get-Content -Raw -LiteralPath $candidate | ConvertFrom-Json -ErrorAction Stop
			if ($name -eq 'trial_result_live.json' -and [string]$data.status -eq 'CASE_COMPLETE') {
				$published = Publish-R17UniqueJson -Path $tracePath -Value $data
				return [pscustomobject]@{Path=$published;Data=$data;Complete=$true}
			}
			return [pscustomobject]@{Path=$candidate;Data=$data;Complete=([string]$data.status -eq 'CASE_COMPLETE')}
		}
	}
	return $null
}

function Test-R20SameCase([object]$StartedCase, [object]$TraceCase) {
	if (-not $StartedCase -or -not $TraceCase) { return $false }
	foreach ($field in @('island_id','level_id','seed')) {
		if ($StartedCase.PSObject.Properties.Name -notcontains $field -or $TraceCase.PSObject.Properties.Name -notcontains $field) { return $false }
		if ([string]$StartedCase.$field -cne [string]$TraceCase.$field) { return $false }
	}
	return $true
}

function Get-R20RecoveredCaseRecord([string]$EvidenceRoot, [object]$Start, [string]$TrialPath) {
	$caseRecordPath = Join-Path $TrialPath 'case_record.json'
	$watchdogPath = Join-Path $TrialPath 'watchdog_result.json'
	if (-not [IO.File]::Exists($watchdogPath)) { throw "Cannot recover $($Start.trial_attempt_id): watchdog evidence is missing." }
	$watchdog = Get-Content -Raw -LiteralPath $watchdogPath | ConvertFrom-Json -ErrorAction Stop
	$traceInfo = Get-R20TrialTrace $TrialPath
	if (-not $traceInfo) { throw "Cannot recover $($Start.trial_attempt_id): no valid result or progress trace exists." }
	$trace = $traceInfo.Data
	if (-not (Test-R20SameCase $Start.case $trace.case)) { throw "Cannot recover $($Start.trial_attempt_id): case identity differs from immutable TRIAL_STARTED." }
	$cleanExit = [string]$watchdog.status -eq 'EXITED' -and $null -ne $watchdog.exit_code -and [int]$watchdog.exit_code -eq 0
	$classification = if ($cleanExit -and $traceInfo.Complete) { [string]$trace.classification } elseif ([string]$watchdog.status -eq 'TIMEOUT_TERMINATED' -and $traceInfo.Complete) { 'BUDGET_UNKNOWN' } else { 'ERROR' }
	if ($classification -notin @('WIN_OBSERVED','LOSS_OBSERVED','BUDGET_UNKNOWN','ERROR')) { $classification = 'ERROR' }
	$theoreticalT = [int]$trace.normal_theoretical_shots_T
	$shotCap = [int]$trace.normal_4t_shot_cap
	$shotsUsed = if ($trace.PSObject.Properties.Name -contains 'shots_used') { [int]$trace.shots_used } elseif ($trace.PSObject.Properties.Name -contains 'shot_count') { [int]$trace.shot_count } else { -1 }
	$capField = $trace.PSObject.Properties.Name -contains 'normal_4t_cap_verified' -and [bool]$trace.normal_4t_cap_verified
	$capVerified = $theoreticalT -gt 0 -and $shotCap -eq 4 * $theoreticalT -and $capField -and $shotsUsed -ge 0 -and $shotsUsed -le $shotCap
	if ($classification -ne 'ERROR' -and -not $capVerified) { $classification = 'ERROR' }
	if ($classification -eq 'ERROR' -and -not $traceInfo.Complete) {
		$partial = $trace | ConvertTo-Json -Depth 80 | ConvertFrom-Json -AsHashtable
		$partial['status'] = 'RECOVERED_PARTIAL_ERROR'
		$partial['classification'] = 'ERROR'
		$partial['terminal_reason'] = if ([string]$watchdog.status -eq 'TIMEOUT_TERMINATED') { 'EXTERNAL_WATCHDOG_TIMEOUT_PARTIAL_TRACE' } else { 'SUBPROCESS_OR_POSTPROCESSOR_EXIT_WITHOUT_COMPLETE_RESULT' }
		$partial['recovery_source'] = 'partial progress checkpoint plus watchdog; completion not inferred'
		if (-not [IO.File]::Exists((Join-Path $TrialPath 'final_trace.json'))) { [void](Publish-R17UniqueJson -Path (Join-Path $TrialPath 'final_trace.json') -Value $partial) }
		$traceInfo = Get-R20TrialTrace $TrialPath
		$trace = $traceInfo.Data
		$traceRelative = Get-R20RelativePath $EvidenceRoot $traceInfo.Path
		$capVerified = $false
	} else {
		$traceRelative = Get-R20RelativePath $EvidenceRoot $traceInfo.Path
	}
	$digest = Get-R17ActionProgressDigest -TracePath $traceInfo.Path
	if (-not $digest) { throw "Cannot recover $($Start.trial_attempt_id): action/progress digest could not be computed." }
	$objectiveProgress = Get-R17ObjectiveProgress -Trace $trace
	$traceRelative = Get-R20RelativePath $EvidenceRoot $traceInfo.Path
	$watchdogRelative = Get-R20RelativePath $EvidenceRoot $watchdogPath
	$existingRecord = if ([IO.File]::Exists($caseRecordPath)) { Get-Content -Raw -LiteralPath $caseRecordPath | ConvertFrom-Json -ErrorAction Stop } else { $null }
	if ($existingRecord) {
		if ([string]$existingRecord.trial_attempt_id -cne [string]$Start.trial_attempt_id -or [string]$existingRecord.trace_file_sha256 -cne (Get-R20Sha256 $traceInfo.Path) -or [string]$existingRecord.watchdog_file_sha256 -cne (Get-R20Sha256 $watchdogPath)) { throw "Existing case record for $($Start.trial_attempt_id) conflicts with source artifact hashes." }
		return [pscustomobject]@{Path=$caseRecordPath;Data=$existingRecord;RecoveredExisting=$true;TracePath=$traceInfo.Path;WatchdogPath=$watchdogPath}
	}
	$record = [ordered]@{
		schema_version=1;work_item='BCM-M34-R20';attempt_id=[string]$Start.attempt_id;trial_attempt_id=[string]$Start.trial_attempt_id;trial_name=[string]$Start.trial_name
		role=[string]$Start.role;parent_trial_attempt_id=$Start.parent_trial_attempt_id;provenance=[string]$Start.provenance;case=$Start.case
		classification=$classification;failure_kind=if($classification -eq 'ERROR'){'RECOVERED_SUBPROCESS_OR_TRACE_ERROR'}else{'NONE'};reason=if($classification -eq 'ERROR'){'RECOVERED_WITHOUT_FALSE_SUCCESS_CLAIM'}elseif([string]$watchdog.status -eq 'TIMEOUT_TERMINATED'){'EXTERNAL_TRIAL_WATCHDOG_TIMEOUT'}else{[string]$trace.terminal_reason}
		watchdog_status=[string]$watchdog.status;watchdog_exit_code=$watchdog.exit_code;watchdog_exit_code_hex=if($null -ne $watchdog.exit_code){'0x{0:X8}' -f ([uint32]([int64]$watchdog.exit_code -band 0xffffffffL))}else{$null}
		process_identity_verified=[bool]$watchdog.root_identity_verified;watchdog_terminated_count=@($watchdog.terminated_processes).Count;stderr_length=([string]$watchdog.stderr).Length;wall_elapsed_ms=[int]$watchdog.wall_elapsed_ms
		shot_count=$shotsUsed;normal_theoretical_shots_T=$theoreticalT;normal_4t_shot_cap=$shotCap;normal_4t_cap_verified=$capVerified
		normal_objective_progress=$objectiveProgress;action_count=[int]$digest.action_count;progress_point_count=[int]$digest.progress_count;action_progress_sha256=[string]$digest.action_progress_sha256
		trace_path=$traceRelative;trace_file_sha256=Get-R20Sha256 $traceInfo.Path;watchdog_path=$watchdogRelative;watchdog_file_sha256=Get-R20Sha256 $watchdogPath
		probe_result_path=Get-R20RelativePath $EvidenceRoot (Join-Path $TrialPath 'trial_result_live.json');probe_result_sha256=Get-R20Sha256 (Join-Path $TrialPath 'trial_result_live.json')
		started_utc=[string]$Start.started_utc;finished_utc=[DateTime]::UtcNow.ToString('o');recovered_by='BCM-M34-R20';recovery_source='immutable TRIAL_STARTED plus hash-bound final trace and watchdog result'
	}
	$published = Publish-R17UniqueJson -Path $caseRecordPath -Value $record
	return [pscustomobject]@{Path=$published;Data=[pscustomobject]$record;RecoveredExisting=$false;TracePath=$traceInfo.Path;WatchdogPath=$watchdogPath}
}

function Repair-R19IncompleteTrials([Parameter(Mandatory)][string]$EvidenceRoot, [Parameter(Mandatory)][string]$AttemptId) {
	$root = [IO.Path]::GetFullPath($EvidenceRoot)
	$manifestPath = Join-Path $root 'attempt_manifest.jsonl'
	$attemptPath = Join-Path (Join-Path $root 'attempts') $AttemptId
	if ($AttemptId -notmatch '^\d{8}T\d{9}Z_[a-f0-9]{32}$' -or -not [IO.Directory]::Exists($attemptPath)) { throw 'Recovery attempt id or evidence path is invalid.' }
	$events = Read-R20Manifest $manifestPath
	$attemptEvents = @($events | Where-Object { $_.PSObject.Properties.Name -contains 'attempt_id' -and $_.attempt_id -ceq $AttemptId })
	if (-not @($attemptEvents | Where-Object event_type -eq 'ATTEMPT_STARTED').Count) { throw "Attempt is not registered in the manifest: $AttemptId" }
	$starts = @($attemptEvents | Where-Object event_type -eq 'TRIAL_STARTED')
	$finishes = @($attemptEvents | Where-Object event_type -eq 'TRIAL_FINISHED')
	$finishIds = @{}; foreach ($event in $finishes) { $finishIds[[string]$event.trial_attempt_id] = $true }
	$recoveredIds = [System.Collections.Generic.List[string]]::new()
	foreach ($start in $starts) {
		$id = [string]$start.trial_attempt_id
		if ($id -notmatch '^[a-f0-9]{32}$') { throw "Invalid trial id in immutable manifest: $id" }
		if ($finishIds.ContainsKey($id)) { continue }
		$trialPath = Join-Path $attemptPath "trial_$id"
		$caseRecord = Get-R20RecoveredCaseRecord $root $start $trialPath
		$record = $caseRecord.Data
		$finishEvent = [ordered]@{
			event_id="r20-trial-finished-$id";event_type='TRIAL_FINISHED';attempt_id=$AttemptId;trial_attempt_id=$id;trial_name=[string]$start.trial_name
			role=[string]$start.role;parent_trial_attempt_id=$start.parent_trial_attempt_id;provenance=[string]$start.provenance;case=$start.case
			classification=[string]$record.classification;failure_kind=[string]$record.failure_kind;reason=[string]$record.reason;normal_objective_progress=[int]$record.normal_objective_progress
			normal_theoretical_shots_T=[int]$record.normal_theoretical_shots_T;normal_4t_shot_cap=[int]$record.normal_4t_shot_cap;normal_4t_cap_verified=[bool]$record.normal_4t_cap_verified
			case_record_path=Get-R20RelativePath $root $caseRecord.Path;case_record_sha256=Get-R20Sha256 $caseRecord.Path;trace_path=[string]$record.trace_path;trace_file_sha256=[string]$record.trace_file_sha256
			action_progress_sha256=[string]$record.action_progress_sha256;watchdog_path=[string]$record.watchdog_path;watchdog_file_sha256=[string]$record.watchdog_file_sha256
			finished_utc=[string]$record.finished_utc;recovered_by='BCM-M34-R20';recovery_reason='ORPHANED_TRIAL_START_RECOVERED_APPEND_ONLY'
		}
		Add-R17ManifestEvent -ManifestPath $manifestPath -Event $finishEvent
		$finishIds[$id] = $true
		$recoveredIds.Add($id)
	}
	$events = Read-R20Manifest $manifestPath
	$attemptEvents = @($events | Where-Object { $_.PSObject.Properties.Name -contains 'attempt_id' -and $_.attempt_id -ceq $AttemptId })
	$alreadySummarized = @{}; foreach ($event in @($attemptEvents | Where-Object event_type -eq 'ATTEMPT_RECOVERY_FINISHED')) { foreach ($id in @($event.recovered_trial_attempt_ids)) { $alreadySummarized[[string]$id] = $true } }
	$recoveryEvents = @($attemptEvents | Where-Object { $_.event_type -eq 'TRIAL_FINISHED' -and $_.PSObject.Properties.Name -contains 'recovered_by' -and $_.recovered_by -eq 'BCM-M34-R20' -and -not $alreadySummarized.ContainsKey([string]$_.trial_attempt_id) })
	if (-not $recoveryEvents.Count) { return [pscustomobject]@{status='NOOP_ALREADY_REPAIRED';attempt_id=$AttemptId;recovered_trial_attempt_ids=@();manifest_event_count=$attemptEvents.Count} }
	$ids = @($recoveryEvents | ForEach-Object { [string]$_.trial_attempt_id } | Sort-Object -Unique)
	$batchText = $ids -join "`n"
	$batchHash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.UTF8Encoding]::new($false).GetBytes($batchText))).ToLowerInvariant().Substring(0,16)
	$summaryPath = Join-Path $attemptPath "recovery_summary_r20_$batchHash.json"
	$counts = @{WIN_OBSERVED=@($recoveryEvents | Where-Object classification -eq 'WIN_OBSERVED').Count;LOSS_OBSERVED=@($recoveryEvents | Where-Object classification -eq 'LOSS_OBSERVED').Count;BUDGET_UNKNOWN=@($recoveryEvents | Where-Object classification -eq 'BUDGET_UNKNOWN').Count;ERROR=@($recoveryEvents | Where-Object classification -eq 'ERROR').Count}
	$summary = [ordered]@{schema_version=1;work_item='BCM-M34-R20';attempt_id=$AttemptId;recovery_batch_id=$batchHash;recovered_trial_attempt_ids=$ids;recovered_trial_count=$ids.Count;outcome_counts=$counts;unrecovered_trial_count=0;manifest_integrity='PASS_FOR_RECOVERED_ARTIFACTS';recovery_method='append-only case record and TRIAL_FINISHED event; original files and prior summary preserved'}
	if ([IO.File]::Exists($summaryPath)) {
		$existing = Get-Content -Raw -LiteralPath $summaryPath | ConvertFrom-Json -ErrorAction Stop
		if (($existing.recovered_trial_attempt_ids -join ',') -cne ($ids -join ',') -or [int]$existing.recovered_trial_count -ne $ids.Count) { throw 'Existing recovery summary conflicts with the current recovered trial set.' }
	} else { [void](Publish-R17UniqueJson -Path $summaryPath -Value $summary) }
	$summaryEventId = "r20-recovery-summary-$batchHash"
	if (-not @($attemptEvents | Where-Object event_id -ceq $summaryEventId).Count) {
		Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=$summaryEventId;event_type='ATTEMPT_RECOVERY_FINISHED';attempt_id=$AttemptId;recovered_trial_attempt_ids=$ids;summary_path=Get-R20RelativePath $root $summaryPath;summary_sha256=Get-R20Sha256 $summaryPath;created_utc=[DateTime]::UtcNow.ToString('o');recovered_by='BCM-M34-R20'})
	}
	return [pscustomobject]@{status='RECOVERED';attempt_id=$AttemptId;recovered_trial_attempt_ids=$ids;summary_path=Get-R20RelativePath $root $summaryPath;outcome_counts=$counts;manifest_event_count=(Read-R20Manifest $manifestPath).Count}
}

Export-ModuleMember -Function Repair-R19IncompleteTrials
