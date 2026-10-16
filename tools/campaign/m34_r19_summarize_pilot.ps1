[CmdletBinding()]
param(
	[Parameter(Mandatory)][string]$EvidenceRoot,
	[string]$AttemptId = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$EvidenceRoot = [IO.Path]::GetFullPath($EvidenceRoot)
$manifestPath = Join-Path $EvidenceRoot 'attempt_manifest.jsonl'
if (-not [IO.File]::Exists($manifestPath)) { throw "R19 manifest not found: $manifestPath" }
$events = @(Get-Content -LiteralPath $manifestPath | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop })
$problems = [System.Collections.Generic.List[string]]::new()
$seenEvents = @{}
foreach ($event in $events) {
	if ($seenEvents.ContainsKey([string]$event.event_id)) { $problems.Add("DUPLICATE_EVENT_ID:$($event.event_id)") }
	$seenEvents[[string]$event.event_id] = $true
}
if ([string]::IsNullOrWhiteSpace($AttemptId)) {
	$AttemptId = [string](@($events | Where-Object event_type -eq 'ATTEMPT_STARTED' | Select-Object -Last 1)[0].attempt_id)
}
$attemptEvents = @($events | Where-Object { $_.PSObject.Properties.Name -contains 'attempt_id' -and $_.attempt_id -ceq $AttemptId })
if (-not $attemptEvents.Count) { throw "Attempt is not present in manifest: $AttemptId" }
$canonicalIslandOrder = @('sunny_cove','tiki_island','azure_bay','coconut_beach','sunset_island','party_beach','frozen_paradise','volcano_bay','billionaire_island','final_island')
function Get-R19GlobalLevelId([string]$IslandId, [int]$LevelId) {
	$index = [Array]::IndexOf($canonicalIslandOrder, $IslandId)
	if ($index -lt 0 -or $LevelId -lt 1 -or $LevelId -gt 100) { return 0 }
	return ($index * 100) + $LevelId
}
function Resolve-R19EvidencePath([string]$RelativePath) {
	if ([string]::IsNullOrWhiteSpace($RelativePath)) { return $null }
	return [IO.Path]::GetFullPath((Join-Path $EvidenceRoot $RelativePath.Replace('/', '\')))
}
function Test-R19ArtifactHash([string]$RelativePath, [string]$ExpectedHash, [string]$Label) {
	$path = Resolve-R19EvidencePath $RelativePath
	if (-not $path -or -not [IO.File]::Exists($path)) { $problems.Add("ARTIFACT_MISSING:$Label"); return }
	$actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLower()
	if ($actual -cne $ExpectedHash) { $problems.Add("ARTIFACT_HASH_MISMATCH:$Label") }
}

$trialStarts = @($attemptEvents | Where-Object event_type -eq 'TRIAL_STARTED')
$trialFinishes = @($attemptEvents | Where-Object event_type -eq 'TRIAL_FINISHED')
$finishedIds = @{}
$trials = [System.Collections.Generic.List[object]]::new()
foreach ($event in $trialFinishes) {
	if ($finishedIds.ContainsKey([string]$event.trial_attempt_id)) { $problems.Add("DUPLICATE_TRIAL_FINISH:$($event.trial_attempt_id)") }
	$finishedIds[[string]$event.trial_attempt_id] = $true
	Test-R19ArtifactHash ([string]$event.case_record_path) ([string]$event.case_record_sha256) "case:$($event.trial_attempt_id)"
	if ($event.trace_path) { Test-R19ArtifactHash ([string]$event.trace_path) ([string]$event.trace_file_sha256) "trace:$($event.trial_attempt_id)" }
	Test-R19ArtifactHash ([string]$event.watchdog_path) ([string]$event.watchdog_file_sha256) "watchdog:$($event.trial_attempt_id)"
	$casePath = Resolve-R19EvidencePath ([string]$event.case_record_path)
	$case = if ($casePath -and [IO.File]::Exists($casePath)) { Get-Content -Raw -LiteralPath $casePath | ConvertFrom-Json -ErrorAction Stop } else { $null }
	if ($case -and (-not [bool]$case.normal_4t_cap_verified -or [int]$case.normal_4t_shot_cap -ne 4 * [int]$case.normal_theoretical_shots_T)) { $problems.Add("NORMAL_4T_CAP_INVALID:$($event.trial_attempt_id)") }
	$globalLevelId = if ($event.case.PSObject.Properties.Name -contains 'global_level_id') { [int]$event.case.global_level_id } else { Get-R19GlobalLevelId ([string]$event.case.island_id) ([int]$event.case.level_id) }
	$trials.Add([ordered]@{trial_attempt_id=[string]$event.trial_attempt_id;trial_name=[string]$event.trial_name;island_id=[string]$event.case.island_id;level_id=[int]$event.case.level_id;global_level_id=$globalLevelId;classification=[string]$event.classification;failure_kind=[string]$event.failure_kind;objective_progress=[int]$event.normal_objective_progress;action_count=if($case){[int]$case.action_count}else{0};trace_integrity=if($case -and $case.trace_file_sha256 -ceq [string]$event.trace_file_sha256){'PASS'}else{'UNVERIFIED_OR_FAIL'}})
}
$incomplete = @($trialStarts | Where-Object { -not $finishedIds.ContainsKey([string]$_.trial_attempt_id) } | ForEach-Object { [string]$_.trial_attempt_id })
$incomplete | ForEach-Object { $problems.Add("INCOMPLETE_TRIAL_START:$($_)") }
$attemptFinishedEvent = @($attemptEvents | Where-Object event_type -eq 'ATTEMPT_FINISHED' | Select-Object -Last 1)
if ($attemptFinishedEvent.Count) {
	Test-R19ArtifactHash ([string]$attemptFinishedEvent[0].summary_path) ([string]$attemptFinishedEvent[0].summary_sha256) "attempt_summary:$AttemptId"
	$attemptSummaryPath = Resolve-R19EvidencePath ([string]$attemptFinishedEvent[0].summary_path)
	$attemptSummary = if ($attemptSummaryPath -and [IO.File]::Exists($attemptSummaryPath)) { Get-Content -Raw -LiteralPath $attemptSummaryPath | ConvertFrom-Json -ErrorAction Stop } else { $null }
	if ($incomplete.Count -and $attemptSummary -and [string]$attemptSummary.status -eq 'PILOT_COMPLETE') { $problems.Add('SUMMARY_CLAIMS_COMPLETE_WITH_INCOMPLETE_TRIALS') }
}
$checkpointEvents = @($attemptEvents | Where-Object event_type -eq 'BATCH_CHECKPOINT')
$latestPerLevelState = @()
foreach ($checkpointEvent in $checkpointEvents) {
	Test-R19ArtifactHash ([string]$checkpointEvent.checkpoint_path) ([string]$checkpointEvent.checkpoint_sha256) "checkpoint:$($checkpointEvent.checkpoint_id)"
	$checkpointPath = Resolve-R19EvidencePath ([string]$checkpointEvent.checkpoint_path)
	if ($checkpointPath -and [IO.File]::Exists($checkpointPath)) {
		$checkpoint = Get-Content -Raw -LiteralPath $checkpointPath | ConvertFrom-Json -ErrorAction Stop
		if ($checkpoint.PSObject.Properties.Name -contains 'per_level_state') { $latestPerLevelState = @($checkpoint.per_level_state) }
	}
}
$perLevelStatusCounts = @{}
foreach ($row in $latestPerLevelState) { $key = [string]$row.status; $perLevelStatusCounts[$key] = [int]$perLevelStatusCounts[$key] + 1 }
$uniqueWins = @($trials | Where-Object classification -eq 'WIN_OBSERVED' | ForEach-Object { "$($_.island_id)/$($_.level_id)" } | Sort-Object -Unique)
$beyondEasiest = @($trials | Where-Object { $_.classification -eq 'WIN_OBSERVED' -and $_.global_level_id -gt 1 } | ForEach-Object { "$($_.island_id)/$($_.level_id)" } | Sort-Object -Unique)
$summary = [ordered]@{
	schema_version=1;work_item='BCM-M34-R19';read_only=$true;idempotent=$true;attempt_id=$AttemptId
	manifest_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $manifestPath).Hash.ToLower();manifest_event_count=$attemptEvents.Count
	trial_started_count=$trialStarts.Count;trial_finished_count=$trialFinishes.Count;incomplete_trial_attempt_ids=$incomplete
	checkpoint_count=$checkpointEvents.Count;per_level_state_count=$latestPerLevelState.Count;per_level_status_counts=$perLevelStatusCounts
	outcome_counts=@{WIN_OBSERVED=@($trials | Where-Object classification -eq 'WIN_OBSERVED').Count;LOSS_OBSERVED=@($trials | Where-Object classification -eq 'LOSS_OBSERVED').Count;BUDGET_UNKNOWN=@($trials | Where-Object classification -eq 'BUDGET_UNKNOWN').Count;ERROR=@($trials | Where-Object classification -eq 'ERROR').Count}
	distinct_observed_win_levels=$uniqueWins;distinct_wins_beyond_easiest=$beyondEasiest
	broader_batch_gate=if($beyondEasiest.Count -gt 0){'ELIGIBLE_FOR_SEPARATE_BOUNDED_BATCH'}else{'NOT_MET'}
	trials=@($trials);integrity_status=if($problems.Count -eq 0){'PASS'}else{'FAIL'};integrity_problems=@($problems)
}
Write-Output (($summary | ConvertTo-Json -Depth 80 -Compress) + "`n")
