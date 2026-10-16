[CmdletBinding()]
param(
	[Parameter(Mandatory)][string]$EvidenceRoot,
	[Parameter(Mandatory)][string]$AttemptId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$EvidenceRoot = [IO.Path]::GetFullPath($EvidenceRoot)
$manifestPath = Join-Path $EvidenceRoot 'attempt_manifest.jsonl'
if (-not [IO.File]::Exists($manifestPath)) { throw 'R23 append-only manifest is missing.' }
$events = @(Get-Content -LiteralPath $manifestPath | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop })
$eventIds = @($events | ForEach-Object { [string]$_.event_id })
if (@($eventIds | Sort-Object -Unique).Count -ne $eventIds.Count) { throw 'Manifest contains duplicate event IDs.' }

function Get-R22ScopedPath([string]$RelativePath) {
	if ([string]::IsNullOrWhiteSpace($RelativePath)) { throw 'Required evidence path is empty.' }
	$full = [IO.Path]::GetFullPath((Join-Path $EvidenceRoot $RelativePath.Replace('/','\')))
	$prefix = $EvidenceRoot.TrimEnd('\') + '\'
	if (-not $full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw "Evidence path escaped root: $RelativePath" }
	if (-not [IO.File]::Exists($full)) { throw "Evidence file is missing: $RelativePath" }
	return $full
}

function Get-R22Sha256([string]$Path) { return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant() }

$starts = @($events | Where-Object { $_.event_type -eq 'ATTEMPT_STARTED' -and $_.attempt_id -ceq $AttemptId })
$ends = @($events | Where-Object { $_.event_type -eq 'ATTEMPT_FINISHED' -and $_.attempt_id -ceq $AttemptId })
if ($starts.Count -ne 1 -or $ends.Count -ne 1) { throw "R23 attempt must have exactly one start and finish; found $($starts.Count)/$($ends.Count)." }
$attemptEvents = @($events | Where-Object { $_.PSObject.Properties.Name -contains 'attempt_id' -and $_.attempt_id -ceq $AttemptId })
$trialStarts = @($attemptEvents | Where-Object event_type -eq 'TRIAL_STARTED')
$trialFinishes = @($attemptEvents | Where-Object event_type -eq 'TRIAL_FINISHED')
if ($trialStarts.Count -ne $trialFinishes.Count -or $trialStarts.Count -eq 0) { throw 'R23 trial starts and finishes do not pair.' }
$finishedById = @{}
foreach ($finish in $trialFinishes) {
	$id = [string]$finish.trial_attempt_id
	if ($finishedById.ContainsKey($id)) { throw "Duplicate trial finish: $id" }
	$finishedById[$id] = $finish
}
$trials = [System.Collections.Generic.List[object]]::new()
$allLevelKeys = [System.Collections.Generic.List[string]]::new()
$allSeeds = [System.Collections.Generic.List[int]]::new()
$previousFinishIndex = -1
foreach ($start in $trialStarts) {
	$id = [string]$start.trial_attempt_id
	if (-not $finishedById.ContainsKey($id)) { throw "Trial has no finish event: $id" }
	$finish = $finishedById[$id]
	$finishIndex = [Array]::IndexOf($events, $finish)
	$startIndex = [Array]::IndexOf($events, $start)
	if ($startIndex -le $previousFinishIndex) { throw 'Trials were not run sequentially.' }
	if ($finishIndex -le $startIndex) { throw "Trial finish precedes start: $id" }
	$previousFinishIndex = $finishIndex
	$case = $start.case
	$levelKey = '{0}/{1}' -f [string]$case.island_id, [int]$case.level_id
	$allLevelKeys.Add($levelKey)
	$allSeeds.Add([int]$case.seed)
	if (@('WIN_OBSERVED','LOSS_OBSERVED','BUDGET_UNKNOWN','ERROR') -cnotcontains [string]$finish.classification) { throw "Invalid trial outcome classification: $($finish.classification)" }
	$recordPath = Get-R22ScopedPath ([string]$finish.case_record_path)
	$tracePath = Get-R22ScopedPath ([string]$finish.trace_path)
	if ((Get-R22Sha256 $recordPath) -cne [string]$finish.case_record_sha256) { throw "Case record hash mismatch: $id" }
	if ((Get-R22Sha256 $tracePath) -cne [string]$finish.trace_file_sha256) { throw "Immutable trace hash mismatch: $id" }
	$record = Get-Content -Raw -LiteralPath $recordPath | ConvertFrom-Json -ErrorAction Stop
	$trace = Get-Content -Raw -LiteralPath $tracePath | ConvertFrom-Json -ErrorAction Stop
	if ([string]$record.trial_attempt_id -cne $id -or [string]$trace.case.island_id -cne [string]$case.island_id -or [int]$trace.case.level_id -ne [int]$case.level_id -or [int]$trace.case.seed -ne [int]$case.seed) { throw "Case/trace identity mismatch: $id" }
	if (-not ($case.PSObject.Properties.Name -contains 'canonical_vip_enabled') -or -not ($case.PSObject.Properties.Name -contains 'optional_vip_enabled') -or -not ($record.PSObject.Properties.Name -contains 'runner_case_vip_enabled')) { throw "VIP provenance fields are incomplete: $id" }
	$canonicalVip = [bool]$case.canonical_vip_enabled
	$runnerVip = [bool]$case.optional_vip_enabled
	if ($canonicalVip -ne $runnerVip -or $runnerVip -ne [bool]$record.runner_case_vip_enabled -or $runnerVip -ne [bool]$trace.optional_vip_enabled -or [string]$case.vip_requirement -cne 'NOT_REQUIRED') { throw "VIP_PROVENANCE_MISMATCH: canonical, runner case, immutable trace, or normal objective requirement disagrees: $id" }
	if ([string]$trace.physics.mode -cne 'standard_fps_production_physics' -or [bool]$trace.physics.fixed_fps -or [double]$trace.physics.time_scale -ne 1.0 -or [int]$trace.physics.physics_ticks_per_second -ne 60) { throw "Production physics profile mismatch: $id" }
	if ([int]$record.normal_4t_shot_cap -ne 4 * [int]$record.normal_theoretical_shots_T -or -not [bool]$record.normal_4t_cap_verified) { throw "4T shot cap mismatch: $id" }
	if ([int]$record.selected_requested_fired_parity_mismatches -ne 0) { throw "Selected/requested/fired parity error: $id" }
	$selected = [System.Collections.Generic.List[double]]::new()
	$requested = [System.Collections.Generic.List[double]]::new()
	$fired = [System.Collections.Generic.List[double]]::new()
	foreach ($action in @($trace.action_log)) {
		$selectedX = [double]$action.selected_candidate_evaluation.candidate_x
		$requestedX = [double]$action.requested_viewport_x
		$firedX = [double]$action.fired_position[0]
		if ([Math]::Abs($selectedX - $requestedX) -gt 0.01 -or [Math]::Abs($requestedX - $firedX) -gt 0.01) { throw "Lane coordinate parity failure in trace $id" }
		$selected.Add($selectedX); $requested.Add($requestedX); $fired.Add($firedX)
	}
	if ($selected.Count -ne [int]$record.shot_count -or $selected.Count -ne [int]$record.action_count) { throw "Action count does not match trace shot count: $id" }
	$trial = [ordered]@{
		trial_attempt_id=$id;name=[string]$start.trial_name;island_id=[string]$case.island_id;level_id=[int]$case.level_id;global_level_id=[int]$case.global_level_id;band=[string]$case.difficulty_band;seed=[int]$case.seed
		classification=[string]$finish.classification;reason=[string]$finish.reason;shots=[int]$record.shot_count;normal_T=[int]$record.normal_theoretical_shots_T;shot_cap_4T=[int]$record.normal_4t_shot_cap;objective_progress=[int]$record.normal_objective_progress
		contacts=[int]$record.contact_count;merges=[int]$record.merge_count;wall_elapsed_ms=[int]$record.wall_elapsed_ms;optional_vip_enabled_actual=[bool]$trace.optional_vip_enabled;vip_requirement='NOT_REQUIRED';canonical_vip_enabled=$canonicalVip;runner_case_vip_enabled_claim=$runnerVip;selected_lanes=@($selected | Sort-Object -Unique);requested_lanes=@($requested | Sort-Object -Unique);fired_lanes=@($fired | Sort-Object -Unique);selected_requested_fired_parity_mismatches=0;relevant_errors=@($record.relevant_errors)
		trace_path=[string]$finish.trace_path;trace_sha256=[string]$finish.trace_file_sha256;case_record_path=[string]$finish.case_record_path;case_record_sha256=[string]$finish.case_record_sha256
	}
	$trials.Add($trial)
}

$newEvidenceBytes = [long]((Get-ChildItem -LiteralPath $EvidenceRoot -File -Recurse | Measure-Object -Property Length -Sum).Sum)
if ($newEvidenceBytes -gt 250MB) { throw "R23 retained evidence exceeded hard 250MB ceiling: $newEvidenceBytes bytes; no files deleted." }

if (@($allLevelKeys | Sort-Object -Unique).Count -ne $allLevelKeys.Count) { throw 'R23 contains duplicate island/level trials; distinct-level denominator is invalid.' }
if (@($allSeeds | Sort-Object -Unique).Count -ne $allSeeds.Count) { throw 'R23 case seeds are not unique.' }
$attemptSummary = Get-R22ScopedPath ([string]$ends[0].summary_path)
if ((Get-R22Sha256 $attemptSummary) -cne [string]$ends[0].summary_sha256) { throw 'R23 attempt summary hash mismatch.' }
$summaryData = Get-Content -Raw -LiteralPath $attemptSummary | ConvertFrom-Json -ErrorAction Stop
if ([int]$summaryData.actual_elapsed_ms -gt 2100000 -or [int]$summaryData.trial_timeout_seconds -gt 120) { throw 'R23 wall budget was exceeded.' }
$manifestStartUtc = [DateTimeOffset]::Parse([string]$starts[0].started_utc).ToUniversalTime()
$manifestFinishUtc = [DateTimeOffset]::Parse([string]$ends[0].finished_utc).ToUniversalTime()
$manifestElapsedMs = [long]($manifestFinishUtc - $manifestStartUtc).TotalMilliseconds
$manifestBudgetOverrunMs = [Math]::Max(0L,$manifestElapsedMs - 2100000L)
$islandIds = @($trials | ForEach-Object island_id | Sort-Object -Unique)
$bands = @($trials | ForEach-Object band | Sort-Object -Unique)
$earlyIslands = @($trials | Where-Object band -eq 'early' | ForEach-Object island_id | Sort-Object -Unique)
if ($islandIds.Count -ne 10 -or $earlyIslands.Count -ne 10 -or $trials.Count -gt 30) { throw 'R23 did not preserve first-round coverage across all 10 islands or exceeded 30 distinct trials.' }
$wins = @($trials | Where-Object classification -eq 'WIN_OBSERVED')
$winIslands = @($wins | ForEach-Object island_id | Sort-Object -Unique)
$vipMetadataClarifications = @($trials | Where-Object { $_.runner_case_vip_enabled_claim -ne $_.optional_vip_enabled_actual } | ForEach-Object { @{trial_attempt_id=$_.trial_attempt_id;level="$($_.island_id)/$($_.level_id)";runner_case_claim=$_.runner_case_vip_enabled_claim;trace_actual=$_.optional_vip_enabled_actual;vip_requirement='NOT_REQUIRED';source_trace_sha256=$_.trace_sha256;source_case_record_sha256=$_.case_record_sha256} })
$manifestShaBeforeAuditEvent = Get-R22Sha256 $manifestPath
$audit = [ordered]@{
	 schema_version=1;work_item='BCM-M34-R23';attempt_id=$AttemptId;status=if($manifestBudgetOverrunMs -gt 0){'TRACE_INTEGRITY_PASS_WITH_GLOBAL_WALL_BUDGET_OVERRUN'}elseif($vipMetadataClarifications.Count){'TRACE_AND_MANIFEST_INTEGRITY_PASS_WITH_METADATA_CLARIFICATION'}else{'TRACE_AND_MANIFEST_INTEGRITY_PASS'};created_utc=[DateTime]::UtcNow.ToString('o')
	manifest_sha256_before_audit_event=$manifestShaBeforeAuditEvent;attempt_summary_sha256=(Get-R22Sha256 $attemptSummary);attempt_started_count=$starts.Count;attempt_finished_count=$ends.Count;trial_started_count=$trialStarts.Count;trial_finished_count=$trialFinishes.Count;incomplete_trials=@()
	global_elapsed_ms=$manifestElapsedMs;runner_reported_elapsed_ms=[int]$summaryData.actual_elapsed_ms;manifest_attempt_started_utc=$manifestStartUtc.ToString('o');manifest_attempt_finished_utc=$manifestFinishUtc.ToString('o');global_budget_ms=2100000;global_budget_overrun_ms=$manifestBudgetOverrunMs;maximum_per_trial_timeout_seconds=120;distinct_level_count=$allLevelKeys.Count;distinct_level_keys=@($allLevelKeys);islands=$islandIds;difficulty_bands=$bands;early_band_island_coverage=$earlyIslands.Count
	outcome_counts=@{WIN_OBSERVED=@($trials|Where-Object classification -eq 'WIN_OBSERVED').Count;LOSS_OBSERVED=@($trials|Where-Object classification -eq 'LOSS_OBSERVED').Count;BUDGET_UNKNOWN=@($trials|Where-Object classification -eq 'BUDGET_UNKNOWN').Count;ERROR=@($trials|Where-Object classification -eq 'ERROR').Count}
	distinct_wins=@($wins|ForEach-Object { '{0}/{1}' -f $_.island_id,$_.level_id }|Sort-Object -Unique);distinct_win_islands=$winIslands;parity_mismatches=0;sample_success_rate=[double]$summaryData.sample_success_rate;zero_progress_count=[int]$summaryData.zero_progress_count;runtime_estimate_1000_levels=$summaryData.runtime_estimate_1000_levels;evidence_storage_estimate_1000_levels_bytes=[long]$summaryData.evidence_storage_estimate_1000_levels_bytes;staged_1000_level_plan=$summaryData.staged_1000_level_plan;vip_requirement='NOT_REQUIRED; normal objective T progress and 4T cap are authoritative';vip_metadata_clarifications=$vipMetadataClarifications;trials=@($trials)
}
$qualificationDir = Join-Path $EvidenceRoot 'qualification'
[IO.Directory]::CreateDirectory($qualificationDir) | Out-Null
$auditPath = Join-Path $qualificationDir 'r23_trace_integrity_audit_v01.json'
if ([IO.File]::Exists($auditPath)) { throw 'R23 audit evidence path already exists; refusing to overwrite.' }
$json = $audit | ConvertTo-Json -Depth 80
[IO.File]::WriteAllText($auditPath, $json + "`n", [Text.UTF8Encoding]::new($false))
$auditSha = Get-R22Sha256 $auditPath
Import-Module (Join-Path $PSScriptRoot 'm34_r17_pilot_integrity.psm1') -Force
$relativeAudit = [IO.Path]::GetRelativePath($EvidenceRoot,$auditPath).Replace('\','/')
Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='PILOT_TRACE_INTEGRITY_AUDIT';attempt_id=$AttemptId;audit_path=$relativeAudit;audit_sha256=$auditSha;source_manifest_sha256=$manifestShaBeforeAuditEvent;status=$audit.status;distinct_level_count=$allLevelKeys.Count;trial_started_count=$trialStarts.Count;trial_finished_count=$trialFinishes.Count;created_utc=$audit.created_utc})
Write-Output "R23_TRACE_INTEGRITY=$($audit.status) trials=$($trialStarts.Count)/$($trialFinishes.Count) distinct_levels=$($allLevelKeys.Count) wins=$($wins.Count) islands=$($islandIds.Count) parity=0 vip_mismatches=0 retained_bytes=$newEvidenceBytes audit_sha256=$auditSha"
