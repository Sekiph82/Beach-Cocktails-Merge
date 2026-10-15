param(
	[Parameter(Mandatory)][string]$EvidenceRoot,
	[string]$ManifestPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Import-Module (Join-Path $PSScriptRoot 'm34_r17_pilot_integrity.psm1') -Force
$root = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $EvidenceRoot).Path)
if ([string]::IsNullOrWhiteSpace($ManifestPath)) { $ManifestPath = Join-Path $root 'attempt_manifest.jsonl' }
$manifest = [IO.Path]::GetFullPath($ManifestPath)
if (-not [IO.File]::Exists($manifest)) { throw "Append-only manifest not found: $manifest" }
$rootPrefix = $root.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
$repoPrefix = $repoRoot.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
function Resolve-EvidenceFile([string]$RelativePath) {
	if ([string]::IsNullOrWhiteSpace($RelativePath)) { return $null }
	$full = [IO.Path]::GetFullPath((Join-Path $root ($RelativePath.Replace('/',[IO.Path]::DirectorySeparatorChar))))
	if (-not $full.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw "Manifest path escapes evidence root: $RelativePath" }
	return $full
}
function Resolve-RepoEvidenceFile([string]$RelativePath) {
	if ([string]::IsNullOrWhiteSpace($RelativePath)) { return $null }
	$full = [IO.Path]::GetFullPath((Join-Path $repoRoot ($RelativePath.Replace('/',[IO.Path]::DirectorySeparatorChar))))
	if (-not $full.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw "Manifest source path escapes repository root: $RelativePath" }
	return $full
}

$manifestBytes = [IO.File]::ReadAllBytes($manifest)
if ($manifestBytes.Length -gt 0 -and $manifestBytes[$manifestBytes.Length - 1] -ne 10) { throw 'Manifest ends with an incomplete line.' }
$events = [System.Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadAllLines($manifest)) {
	if ([string]::IsNullOrWhiteSpace($line)) { throw 'Manifest contains a blank line.' }
	$events.Add(($line | ConvertFrom-Json -ErrorAction Stop))
}
$problems = [System.Collections.Generic.List[string]]::new()
$eventIds = @{}
$attemptStarts = @{}
$trialStarts = @{}
foreach ($event in $events) {
	if ([string]::IsNullOrWhiteSpace([string]$event.event_id)) { $problems.Add('EVENT_ID_MISSING'); continue }
	if ($eventIds.ContainsKey([string]$event.event_id)) { $problems.Add("DUPLICATE_EVENT_ID:$($event.event_id)") }
	$eventIds[[string]$event.event_id] = $true
	if ($event.event_type -eq 'ATTEMPT_STARTED') {
		if ($attemptStarts.ContainsKey([string]$event.attempt_id)) { $problems.Add("DUPLICATE_ATTEMPT_ID:$($event.attempt_id)") }
		$attemptStarts[[string]$event.attempt_id] = $event
	}
	if ($event.event_type -eq 'TRIAL_STARTED') {
		if ($trialStarts.ContainsKey([string]$event.trial_attempt_id)) { $problems.Add("DUPLICATE_TRIAL_ATTEMPT_ID:$($event.trial_attempt_id)") }
		$trialStarts[[string]$event.trial_attempt_id] = $event
	}
	if ($event.PSObject.Properties.Name -contains 'artifact_path' -and -not [string]::IsNullOrWhiteSpace([string]$event.artifact_path)) {
		$artifact = Resolve-EvidenceFile ([string]$event.artifact_path)
		if (-not $artifact -or -not [IO.File]::Exists($artifact)) { $problems.Add("MANIFEST_ARTIFACT_MISSING:$($event.event_id)") }
		elseif ((Get-FileHash -Algorithm SHA256 -LiteralPath $artifact).Hash.ToLower() -cne [string]$event.artifact_sha256) { $problems.Add("MANIFEST_ARTIFACT_HASH_MISMATCH:$($event.event_id)") }
	}
	if ($event.PSObject.Properties.Name -contains 'source_path' -and -not [string]::IsNullOrWhiteSpace([string]$event.source_path)) {
		$source = Resolve-RepoEvidenceFile ([string]$event.source_path)
		if (-not $source -or -not [IO.File]::Exists($source)) { $problems.Add("MANIFEST_SOURCE_MISSING:$($event.event_id)") }
		elseif ((Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash.ToLower() -cne [string]$event.source_sha256) { $problems.Add("MANIFEST_SOURCE_HASH_MISMATCH:$($event.event_id)") }
	}
	if ($event.event_type -eq 'ATTEMPT_FINISHED') {
		$summaryFile = Resolve-EvidenceFile ([string]$event.summary_path)
		if (-not $summaryFile -or -not [IO.File]::Exists($summaryFile)) { $problems.Add("ATTEMPT_SUMMARY_MISSING:$($event.attempt_id)") }
		elseif ((Get-FileHash -Algorithm SHA256 -LiteralPath $summaryFile).Hash.ToLower() -cne [string]$event.summary_sha256) { $problems.Add("ATTEMPT_SUMMARY_HASH_MISMATCH:$($event.attempt_id)") }
	}
	if ($event.event_type -eq 'REGRESSION_FINISHED') {
		$regressionSummary = Resolve-EvidenceFile ([string]$event.summary_path)
		if (-not $regressionSummary -or -not [IO.File]::Exists($regressionSummary)) { $problems.Add("REGRESSION_SUMMARY_MISSING:$($event.validation_id)") }
		elseif ((Get-FileHash -Algorithm SHA256 -LiteralPath $regressionSummary).Hash.ToLower() -cne [string]$event.summary_sha256) { $problems.Add("REGRESSION_SUMMARY_HASH_MISMATCH:$($event.validation_id)") }
	}
}

$finished = @($events | Where-Object { $_.event_type -eq 'TRIAL_FINISHED' })
$trialSummaries = [System.Collections.Generic.List[object]]::new()
$finishedIds = @{}
foreach ($event in $finished) {
	if (-not $trialStarts.ContainsKey([string]$event.trial_attempt_id)) { $problems.Add("TRIAL_FINISH_WITHOUT_START:$($event.trial_attempt_id)") }
	if ($finishedIds.ContainsKey([string]$event.trial_attempt_id)) { $problems.Add("DUPLICATE_TRIAL_FINISH:$($event.trial_attempt_id)") }
	$finishedIds[[string]$event.trial_attempt_id] = $true
	$recordPath = Resolve-EvidenceFile ([string]$event.case_record_path)
	$recordExists = $recordPath -and [IO.File]::Exists($recordPath)
	$recordHash = if ($recordExists) { (Get-FileHash -Algorithm SHA256 -LiteralPath $recordPath).Hash.ToLower() } else { $null }
	if (-not $recordExists) { $problems.Add("CASE_RECORD_MISSING:$($event.trial_attempt_id)") }
	elseif ($recordHash -cne [string]$event.case_record_sha256) { $problems.Add("CASE_RECORD_HASH_MISMATCH:$($event.trial_attempt_id)") }
	if ($recordExists) {
		$caseRecord = Get-Content -Raw -LiteralPath $recordPath | ConvertFrom-Json -ErrorAction Stop
		if ([string]$caseRecord.trial_attempt_id -cne [string]$event.trial_attempt_id -or [string]$caseRecord.classification -cne [string]$event.classification) { $problems.Add("CASE_RECORD_MANIFEST_MISMATCH:$($event.trial_attempt_id)") }
		if ([string]$caseRecord.action_progress_sha256 -cne [string]$event.action_progress_sha256) { $problems.Add("CASE_RECORD_ACTION_HASH_MISMATCH:$($event.trial_attempt_id)") }
	}
	$tracePath = Resolve-EvidenceFile ([string]$event.trace_path)
	$traceExists = $tracePath -and [IO.File]::Exists($tracePath)
	$traceHash = if ($traceExists) { (Get-FileHash -Algorithm SHA256 -LiteralPath $tracePath).Hash.ToLower() } else { $null }
	if ([string]$event.trace_path -and -not $traceExists) { $problems.Add("TRACE_MISSING:$($event.trial_attempt_id)") }
	elseif ($traceExists -and $traceHash -cne [string]$event.trace_file_sha256) { $problems.Add("TRACE_HASH_MISMATCH:$($event.trial_attempt_id)") }
	$actionDigest = if ($traceExists) { Get-R17ActionProgressDigest -TracePath $tracePath } else { $null }
	if ($actionDigest -and $actionDigest.action_progress_sha256 -cne [string]$event.action_progress_sha256) { $problems.Add("ACTION_PROGRESS_HASH_MISMATCH:$($event.trial_attempt_id)") }
	if (-not [bool]$event.normal_4t_cap_verified) { $problems.Add("NORMAL_4T_CAP_INVALID:$($event.trial_attempt_id)") }
	$watchdogPath = Resolve-EvidenceFile ([string]$event.watchdog_path)
	$watchdogExists = $watchdogPath -and [IO.File]::Exists($watchdogPath)
	$watchdogHash = if ($watchdogExists) { (Get-FileHash -Algorithm SHA256 -LiteralPath $watchdogPath).Hash.ToLower() } else { $null }
	if ([string]$event.watchdog_path -and -not $watchdogExists) { $problems.Add("WATCHDOG_MISSING:$($event.trial_attempt_id)") }
	elseif ($watchdogExists -and $watchdogHash -cne [string]$event.watchdog_file_sha256) { $problems.Add("WATCHDOG_HASH_MISMATCH:$($event.trial_attempt_id)") }
	$trialSummaries.Add([ordered]@{
		attempt_id=[string]$event.attempt_id;trial_attempt_id=[string]$event.trial_attempt_id;trial_name=[string]$event.trial_name
		role=[string]$event.role;parent_trial_attempt_id=[string]$event.parent_trial_attempt_id;provenance=[string]$event.provenance
		case=$event.case;classification=[string]$event.classification;failure_kind=[string]$event.failure_kind;reason=[string]$event.reason
		normal_objective_progress=[int]$event.normal_objective_progress;normal_theoretical_shots_T=[int]$event.normal_theoretical_shots_T
		normal_4t_shot_cap=[int]$event.normal_4t_shot_cap;normal_4t_cap_verified=[bool]$event.normal_4t_cap_verified
		action_progress_sha256=[string]$event.action_progress_sha256
		trace_integrity=if($traceExists -and $traceHash -ceq [string]$event.trace_file_sha256 -and $actionDigest.action_progress_sha256 -ceq [string]$event.action_progress_sha256){'PASS'}else{'UNVERIFIED_OR_FAIL'}
		case_record_path=[string]$event.case_record_path;watchdog_path=[string]$event.watchdog_path
	})
}
foreach ($start in @($events | Where-Object { $_.event_type -eq 'TRIAL_STARTED' -and -not $finishedIds.ContainsKey([string]$_.trial_attempt_id) })) {
	$trialSummaries.Add([ordered]@{attempt_id=[string]$start.attempt_id;trial_attempt_id=[string]$start.trial_attempt_id;trial_name=[string]$start.trial_name;role=[string]$start.role;parent_trial_attempt_id=[string]$start.parent_trial_attempt_id;provenance=[string]$start.provenance;case=$start.case;classification='INCOMPLETE';failure_kind='NO_FINISHED_EVENT';reason='ATTEMPT_STARTED_WITHOUT_FINISHED_EVENT';normal_objective_progress=0;normal_theoretical_shots_T=0;normal_4t_shot_cap=0;normal_4t_cap_verified=$false;action_progress_sha256=$null;trace_integrity='UNVERIFIED';case_record_path=$null;watchdog_path=$null})
}

$counts = [ordered]@{}
foreach ($name in @('WIN_OBSERVED','LOSS_OBSERVED','BUDGET_UNKNOWN','ERROR')) { $counts[$name] = @($trialSummaries | Where-Object classification -eq $name).Count }
$uniqueWins = @($trialSummaries | Where-Object { $_.classification -eq 'WIN_OBSERVED' } | ForEach-Object { "$($_.case.island_id)/$($_.case.level_id)" } | Sort-Object -Unique)
$attempts = [System.Collections.Generic.List[object]]::new()
foreach ($start in @($events | Where-Object event_type -eq 'ATTEMPT_STARTED')) {
	$end = @($events | Where-Object { $_.event_type -eq 'ATTEMPT_FINISHED' -and $_.attempt_id -ceq $start.attempt_id } | Select-Object -Last 1)
	$attempts.Add([ordered]@{attempt_id=[string]$start.attempt_id;role=[string]$start.role;parent_attempt_id=[string]$start.parent_attempt_id;started_utc=[string]$start.started_utc;status=if($end.Count){[string]$end[0].status}else{'INCOMPLETE'};stop_reason=if($end.Count){[string]$end[0].stop_reason}else{'NO_ATTEMPT_FINISHED_EVENT'}})
}
$validations = @($events | Where-Object { $_.event_type -eq 'REGRESSION_FINISHED' } | ForEach-Object {@{validation_id=[string]$_.validation_id;status=[string]$_.status;summary_path=[string]$_.summary_path;summary_sha256=[string]$_.summary_sha256;finished_utc=[string]$_.finished_utc}})
$report = [ordered]@{
	schema_version=1;work_item='BCM-M34-R17';read_only=$true;idempotent=$true
	manifest_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $manifest).Hash.ToLower();manifest_event_count=$events.Count
	attempts=@($attempts);validations=$validations;trial_count=$trialSummaries.Count;classification_counts=$counts;distinct_observed_win_levels=@($uniqueWins)
	trials=@($trialSummaries);integrity_status=if($problems.Count -eq 0){'PASS'}else{'FAIL'};integrity_problems=@($problems)
}
Write-Output (($report | ConvertTo-Json -Depth 80 -Compress) + "`n")
