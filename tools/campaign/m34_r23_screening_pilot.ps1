[CmdletBinding()]
param(
	[string]$EvidenceRoot = '',
	[ValidateRange(30, 120)][int]$TrialTimeoutSeconds = 120,
	[ValidateRange(120, 2100)][int]$GlobalBudgetSeconds = 2100,
	[int]$SamplingSeed = 20261016,
	[string]$SelectionManifestPath = '',
	[string[]]$PriorSessionRoots = @(),
	[string]$SharedAppDataRoot = '',
	[switch]$PlanOnly,
	[string]$ResumeAttemptId = '',
	[string]$RetryCaseName = '',
	[string]$ParentAttemptId = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Import-Module (Join-Path $PSScriptRoot 'm34_r20_recovery.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'm34_r17_pilot_integrity.psm1') -Force
if (-not [string]::IsNullOrWhiteSpace($RetryCaseName) -or -not [string]::IsNullOrWhiteSpace($ParentAttemptId)) { throw 'R23 does not support adaptive retry; use a resume of the same unfinished manifest attempt only.' }
if ([string]::IsNullOrWhiteSpace($EvidenceRoot)) {
	$EvidenceRoot = Join-Path $repoRoot 'coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R23'
}
$EvidenceRoot = [IO.Path]::GetFullPath($EvidenceRoot)
[IO.Directory]::CreateDirectory($EvidenceRoot) | Out-Null
$manifestPath = Join-Path $EvidenceRoot 'attempt_manifest.jsonl'
$maxRetainedBytes = 250MB
$perTrialReserveBytes = 15MB
$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$watchdog = Join-Path $repoRoot 'tools/campaign/m34_r14_process_watchdog.ps1'
$probe = Join-Path $repoRoot 'tools/campaign/m34_r23_autonomous_trial.gd'
$attemptId = if ([string]::IsNullOrWhiteSpace($ResumeAttemptId)) { [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '_' + [guid]::NewGuid().ToString('N') } else { $ResumeAttemptId }
$attemptsRoot = Join-Path $EvidenceRoot 'attempts'
$attemptPath = Join-Path $attemptsRoot $attemptId
$clock = [Diagnostics.Stopwatch]::StartNew()
$tasksBefore = (git -C $repoRoot hash-object TASKS.md).Trim()
$drive = [IO.Path]::GetPathRoot($env:TEMP).Substring(0,1)
$freeBefore = [long](Get-Volume -DriveLetter $drive).SizeRemaining

$samplePlan = @()
$selectionManifest = $null
$selectionManifestSha256 = ''
$attemptRole = 'R23_10PCT_RANDOM_SAMPLE_SESSION'
$parentTrialAttemptId = ''
$parentObjectiveProgress = 0
$provenance = 'Owner-updated 100-level random sample; SHA-256 seeded selection without replacement, 10 interleaved rounds; R21 spatial lane policy; production ShotController and Godot physics; maximum 120-second watchdog and 35-minute wall per session.'
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
	$provenance = "R23 sampled screening provenance for $RetryCaseName; seed advanced by one; lane outcome history inherited from hash-verified immutable parent trace."
}

if ([string]::IsNullOrWhiteSpace($ResumeAttemptId)) {
	$attemptPath = New-R17AttemptDirectory -EvidenceRoot $EvidenceRoot -AttemptId $attemptId -ManifestPath $manifestPath -Role $attemptRole -ParentAttemptId $ParentAttemptId
} else {
	if ($attemptId -notmatch '^\d{8}T\d{9}Z_[a-f0-9]{32}$' -or -not [IO.Directory]::Exists($attemptPath) -or -not [IO.File]::Exists($manifestPath)) { throw 'Resume attempt id/path/manifest is invalid.' }
	$manifestEvents = @(Get-Content -LiteralPath $manifestPath | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop })
	if (-not @($manifestEvents | Where-Object { $_.event_type -eq 'ATTEMPT_STARTED' -and $_.attempt_id -ceq $attemptId }).Count) { throw 'Resume attempt is absent from the append-only manifest.' }
	if (@($manifestEvents | Where-Object { $_.event_type -eq 'ATTEMPT_FINISHED' -and $_.attempt_id -ceq $attemptId }).Count) { throw 'Finished attempts are immutable and cannot be resumed.' }
}

$appDataRoot = if ([string]::IsNullOrWhiteSpace($SharedAppDataRoot)) { $attemptPath } else { [IO.Path]::GetFullPath($SharedAppDataRoot) }
$appDataRoaming = Join-Path $appDataRoot $(if ([string]::IsNullOrWhiteSpace($SharedAppDataRoot) -or [IO.Directory]::Exists((Join-Path $appDataRoot 'isolated_appdata_roaming'))) { 'isolated_appdata_roaming' } else { 'Roaming' })
$appDataLocal = Join-Path $appDataRoot $(if ([string]::IsNullOrWhiteSpace($SharedAppDataRoot) -or [IO.Directory]::Exists((Join-Path $appDataRoot 'isolated_appdata_local'))) { 'isolated_appdata_local' } else { 'Local' })
[IO.Directory]::CreateDirectory($appDataRoaming) | Out-Null
[IO.Directory]::CreateDirectory($appDataLocal) | Out-Null
$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
$env:APPDATA = $appDataRoaming
$env:LOCALAPPDATA = $appDataLocal
$completed = [System.Collections.Generic.List[object]]::new()
$startIndex = 0
$stopReason = 'SAMPLE_PLAN_COMPLETE'
$pilotWins = @()
$distinctWins = @()
$winsBeyondEasiest = @()
$crossIslandWins = @()
$winIslandIds = @()
$crossIslandWinIslandCount = 0
$parityErrors = [long]0

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

function Confirm-R21Anchor {
	$sessionRoot = Join-Path $repoRoot 'coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01'
	$summaryPath = Join-Path $sessionRoot 'evidence/M34-R21/qualification/r21_outcome_summary.json'
	$expectedTracePath = Join-Path $sessionRoot 'evidence/M34-R21/attempts/20261016T080445818Z_387e370f136143ed97fa52d4f92720c6/trial_a2f46bbb2d454ebcaca1fbed7d94c3f5/final_trace.json'
	$manifestPathR21 = Join-Path $sessionRoot 'evidence/M34-R21/attempt_manifest.jsonl'
	$integrityPath = Join-Path $sessionRoot 'evidence/M34-R21/qualification/r21_attempt_integrity_final_20261016T080957960Z.json'
	$summary = Get-Content -Raw -LiteralPath $summaryPath | ConvertFrom-Json -ErrorAction Stop
	$win = @($summary.trials | Where-Object { $_.trial_attempt_id -ceq 'a2f46bbb2d454ebcaca1fbed7d94c3f5' -and $_.classification -ceq 'WIN_OBSERVED' })
	$traceHash = Get-Sha256 $expectedTracePath
	$trace = Get-Content -Raw -LiteralPath $expectedTracePath | ConvertFrom-Json -ErrorAction Stop
	$manifestEventsR21 = @(Get-Content -LiteralPath $manifestPathR21 | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop })
	$integrity = Get-Content -Raw -LiteralPath $integrityPath | ConvertFrom-Json -ErrorAction Stop
	if ($win.Count -ne 1 -or $traceHash -cne 'ea2a86a53fad3c35524ffd895ee8d619a2336b2b56543d4c96897dfffe0ec48f' -or $traceHash -cne [string]$win[0].trace_sha256) { throw 'R21 immutable winning trace does not match the locked summary hash.' }
	if ([string]$trace.status -cne 'CASE_COMPLETE' -or [string]$trace.classification -cne 'WIN_OBSERVED' -or [int]$trace.normal_4t_shot_cap -ne 80 -or [int]$trace.normal_theoretical_shots_T -ne 20 -or [int]$trace.shots_used -ne 55 -or -not [bool]$trace.normal_objective_complete -or [string]$trace.terminal_reason -cne 'NORMAL_OBJECTIVES_COMPLETE') { throw 'R21 winning trace does not show the audited 4T/20-progress result.' }
	if ([int]$integrity.trial_started_count -ne 4 -or [int]$integrity.trial_finished_count -ne 4 -or -not [bool]$integrity.all_integrity_pass -or -not [bool]$integrity.all_attempts_closed) { throw 'R21 attempt integrity evidence is not closed and passing.' }
	$closedAttemptIds = @($manifestEventsR21 | Where-Object event_type -eq 'ATTEMPT_STARTED' | ForEach-Object { [string]$_.attempt_id } | Sort-Object -Unique)
	$finishedAttemptIds = @($manifestEventsR21 | Where-Object event_type -eq 'ATTEMPT_FINISHED' | ForEach-Object { [string]$_.attempt_id } | Sort-Object -Unique)
	if ($closedAttemptIds.Count -ne 4 -or $finishedAttemptIds.Count -ne 4 -or @($closedAttemptIds | Where-Object { $finishedAttemptIds -notcontains $_ }).Count -gt 0) { throw 'R21 manifest does not contain four unique closed attempts.' }
	return [ordered]@{work_item='BCM-M34-R23';status='R21_WIN_ANCHOR_VERIFIED';source_summary_path=[IO.Path]::GetRelativePath($repoRoot,$summaryPath).Replace('\','/');source_summary_sha256=(Get-Sha256 $summaryPath);source_trace_path=[IO.Path]::GetRelativePath($repoRoot,$expectedTracePath).Replace('\','/');source_trace_sha256=$traceHash;trial_attempt_id=[string]$win[0].trial_attempt_id;level='sunny_cove/25';classification='WIN_OBSERVED';normal_T=20;normal_4t_shot_cap=80;shots_used=55;attempt_started_count=[int]$integrity.trial_started_count;attempt_finished_count=[int]$integrity.trial_finished_count;attempt_integrity_pass=[bool]$integrity.all_integrity_pass;attempts_closed=[bool]$integrity.all_attempts_closed;verified_utc=[DateTime]::UtcNow.ToString('o')}
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
		schema_version=1;work_item='BCM-M34-R23';attempt_id=$attemptId;checkpoint_id=$checkpointId
		next_case_index=$NextIndex;stop_reason=$Reason;created_utc=[DateTime]::UtcNow.ToString('o')
		completed_trials=@($completed)
		per_level_state=@($preflightRows)
		outcome_counts=@{WIN_OBSERVED=@($completed | Where-Object classification -eq 'WIN_OBSERVED').Count;LOSS_OBSERVED=@($completed | Where-Object classification -eq 'LOSS_OBSERVED').Count;BUDGET_UNKNOWN=@($completed | Where-Object classification -eq 'BUDGET_UNKNOWN').Count;ERROR=@($completed | Where-Object classification -eq 'ERROR').Count}
		vip_provenance_status=if($stopReason -eq 'VIP_PROVENANCE_MISMATCH' -or @($completed|Where-Object{[bool]$_.runner_case_vip_enabled -ne [bool]$_.optional_vip_enabled}).Count){'FAIL_CLOSED_MISMATCH'}else{'PASS_ALL_RECORDED_TRIALS'}
		third_island_win_gate='NOT_A_STOP_CONDITION_IN_OWNER_UPDATED_R23'
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
			$vipEnabled = $false
			if ($null -ne $level.vip -and $level.vip.PSObject.Properties.Name -contains 'enabled') { $vipEnabled = [bool]$level.vip.enabled }
			$preflightRows.Add(@{island_id=[string]$island.id;level_id=[int]$level.level_id;global_level_id=$globalLevelId;canonical_vip_enabled=$vipEnabled;status='PENDING_PHYSICAL_QUALIFICATION';retry_count=0;winning_trace_path=$null;trial_count=0;shot_count=0;latest_action_count=0;best_objective_progress=0;parent_trial_attempt_id=$null})
		}
	}
	if ($preflightRows.Count -ne 1000) { throw "Static plan enumerated $($preflightRows.Count) records, expected 1000." }
	if ([string]::IsNullOrWhiteSpace($SelectionManifestPath)) { $SelectionManifestPath = Join-Path (Join-Path $EvidenceRoot 'qualification') ("r23_random_selection_seed_{0}_v01.json" -f $SamplingSeed) }
	$SelectionManifestPath = [IO.Path]::GetFullPath($SelectionManifestPath)
	[IO.Directory]::CreateDirectory((Split-Path -Parent $SelectionManifestPath)) | Out-Null
	if (-not [IO.File]::Exists($SelectionManifestPath)) {
		$sha = [Security.Cryptography.SHA256]::Create()
		$counter = 0
		$bounded = { param([int]$MaxExclusive,[string]$Stream) if($MaxExclusive -le 0){throw 'Invalid deterministic RNG bound.'}; $range=[uint64]4294967296; $limit=[uint64]([Math]::Floor($range/[double]$MaxExclusive)*$MaxExclusive); while($true){$bytes=[Text.Encoding]::UTF8.GetBytes("$SamplingSeed|$Stream|$counter");$counter++;$digest=$sha.ComputeHash($bytes);$value=[uint64][BitConverter]::ToUInt32($digest,0);if($value -lt $limit){return [int]($value % [uint64]$MaxExclusive)}} }
		$selectionByIsland = @{}
		foreach ($island in @($campaignData.islands | Sort-Object {[int]$_.order_index})) {
			$levels = [System.Collections.Generic.List[int]]::new(); for($n=1;$n -le 100;$n++){$levels.Add($n)}
			for($i=$levels.Count-1;$i -gt 0;$i--){$j=&$bounded ($i+1) ([string]$island.id);$tmp=$levels[$i];$levels[$i]=$levels[$j];$levels[$j]=$tmp}
			$selectionByIsland[[string]$island.id] = @($levels | Select-Object -First 10)
		}
		$selected = [System.Collections.Generic.List[object]]::new()
		for($round=0;$round -lt 10;$round++) { foreach($island in @($campaignData.islands | Sort-Object {[int]$_.order_index})) { $levelId=[int]$selectionByIsland[[string]$island.id][$round]; $row=@($preflightRows|Where-Object{$_.island_id -ceq [string]$island.id -and [int]$_.level_id -eq $levelId}|Select-Object -First 1);if(-not $row.Count){throw "Selected level absent from canonical records: $($island.id)/$levelId"};$selected.Add([ordered]@{round=$round+1;island_id=[string]$island.id;level_id=$levelId;global_level_id=[int]$row[0].global_level_id;case_seed=(34230000+[int]$row[0].global_level_id);runner_case_vip_enabled=[bool]$row[0].canonical_vip_enabled;vip_requirement='NOT_REQUIRED'}) } }
		$manifestValue=[ordered]@{schema_version=1;work_item='BCM-M34-R23';sampling_rule='10 unique random levels per island, without replacement; reproducible interleaved rounds';algorithm='SHA-256(seed|island|counter) deterministic uint32 rejection sampling + Fisher-Yates';seed=$SamplingSeed;island_count=10;levels_per_island=100;sampled_per_island=10;total_selected=100;created_before_any_new_trial_utc=[DateTime]::UtcNow.ToString('o');selection=@($selected)}
		$null=$sha.Dispose();[void](Publish-R17UniqueJson -Path $SelectionManifestPath -Value $manifestValue)
	}
	$selectionManifest=Get-Content -Raw -LiteralPath $SelectionManifestPath|ConvertFrom-Json -ErrorAction Stop
	if([int]$selectionManifest.seed -ne $SamplingSeed -or [int]$selectionManifest.total_selected -ne 100 -or @($selectionManifest.selection).Count -ne 100){throw 'Selection manifest schema/seed/count mismatch.'}
	$selectedKeys = @{}; foreach($selectedItem in $selectionManifest.selection){$selectedKeys[('{0}/{1}' -f [string]$selectedItem.island_id,[int]$selectedItem.level_id)]=$true}
	foreach($island in @($campaignData.islands|Sort-Object {[int]$_.order_index})) { $expectedIslandId=[string]$island.id; $islandCases=@($selectionManifest.selection|Where-Object { $_.island_id -ceq $expectedIslandId }); if($islandCases.Count -ne 10 -or @($islandCases.level_id|Sort-Object -Unique).Count -ne 10){throw "Selection manifest does not have 10 unique levels for $expectedIslandId."} }
	foreach($item in $selectionManifest.selection){$row=@($preflightRows|Where-Object{$_.island_id -ceq [string]$item.island_id -and [int]$_.level_id -eq [int]$item.level_id -and [int]$_.global_level_id -eq [int]$item.global_level_id}|Select-Object -First 1);if(-not $row.Count -or [int]$item.case_seed -ne (34230000+[int]$item.global_level_id) -or [bool]$item.runner_case_vip_enabled -ne [bool]$row[0].canonical_vip_enabled){throw 'Selection manifest record does not match canonical campaign data.'};$samplePlan+= [pscustomobject]@{name=("{0}_random_l{1:D2}" -f [string]$item.island_id,[int]$item.level_id);island=[string]$item.island_id;level=[int]$item.level_id;global_level_id=[int]$item.global_level_id;seed=[int]$item.case_seed;band=('round_{0:D2}' -f [int]$item.round);optional_vip_enabled=[bool]$item.runner_case_vip_enabled} }
	$selectionManifestSha256=Get-Sha256 $SelectionManifestPath
	if ($samplePlan.Count -ne 100) { throw "R23 sampled $($samplePlan.Count) cases, expected 100." }
	$fullSamplePlan = @($samplePlan)
	$priorCompletedKeys = @{}
	foreach ($priorRoot in $PriorSessionRoots) {
		$priorRoot = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $priorRoot).Path)
		$priorManifest = Join-Path $priorRoot 'attempt_manifest.jsonl'
		if (-not [IO.File]::Exists($priorManifest)) { throw "Prior R23 session manifest is missing: $priorRoot" }
		$priorEvents = @(Get-Content -LiteralPath $priorManifest | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop })
		$priorIds = @($priorEvents | ForEach-Object { [string]$_.event_id })
		if (@($priorIds | Sort-Object -Unique).Count -ne $priorIds.Count) { throw "Prior R23 session has duplicate manifest event IDs: $priorRoot" }
		$priorAttemptIds = @($priorEvents | Where-Object event_type -eq 'ATTEMPT_STARTED' | ForEach-Object { [string]$_.attempt_id } | Sort-Object -Unique)
		foreach ($priorId in $priorAttemptIds) {
			$priorStart = @($priorEvents | Where-Object { $_.event_type -eq 'ATTEMPT_STARTED' -and $_.attempt_id -ceq $priorId })
			$priorEnd = @($priorEvents | Where-Object { $_.event_type -eq 'ATTEMPT_FINISHED' -and $_.attempt_id -ceq $priorId })
			if ($priorStart.Count -ne 1 -or $priorEnd.Count -ne 1) { throw "Prior R23 attempt is not fully closed: $priorId" }
			$priorStarts = @($priorEvents | Where-Object { $_.event_type -eq 'TRIAL_STARTED' -and $_.attempt_id -ceq $priorId })
			$priorFinishes = @($priorEvents | Where-Object { $_.event_type -eq 'TRIAL_FINISHED' -and $_.attempt_id -ceq $priorId })
			$priorPlan = @($priorEvents | Where-Object { $_.event_type -eq 'PILOT_PLAN' -and $_.attempt_id -ceq $priorId })
			if ($priorPlan.Count -eq 0 -and $priorStarts.Count -eq 0 -and $priorFinishes.Count -eq 0 -and [string]$priorEnd[0].status -eq 'PREFLIGHT_ERROR') { continue }
			if ($priorPlan.Count -ne 1 -or [string]$priorPlan[0].selection_manifest_sha256 -cne $selectionManifestSha256) { throw "Prior attempt did not use the same frozen selection manifest: $priorId" }
			if ($priorStarts.Count -ne $priorFinishes.Count) { throw "Prior R23 attempt contains an incomplete trial: $priorId" }
			foreach ($priorFinish in $priorFinishes) {
				$key = '{0}/{1}' -f [string]$priorFinish.case.island_id,[int]$priorFinish.case.level_id
				if (-not $selectedKeys.ContainsKey($key) -or $priorCompletedKeys.ContainsKey($key)) { throw "Prior R23 attempts contain an unselected or duplicate trial: $key" }
				$priorRecordPath = Join-Path $priorRoot ([string]$priorFinish.case_record_path).Replace('/','\')
				$priorTracePath = Join-Path $priorRoot ([string]$priorFinish.trace_path).Replace('/','\')
				if (-not [IO.File]::Exists($priorRecordPath) -or -not [IO.File]::Exists($priorTracePath) -or (Get-Sha256 $priorRecordPath) -cne [string]$priorFinish.case_record_sha256 -or (Get-Sha256 $priorTracePath) -cne [string]$priorFinish.trace_file_sha256) { throw "Prior R23 trial evidence hash/path mismatch: $key" }
				$priorCompletedKeys[$key] = $true
			}
		}
	}
	if ($priorCompletedKeys.Count) { $samplePlan = @($fullSamplePlan | Where-Object { -not $priorCompletedKeys.ContainsKey(('{0}/{1}' -f $_.island,$_.level)) }) }
	if ($samplePlan.Count -ne (100 - $priorCompletedKeys.Count)) { throw 'R23 remaining queue count does not reconcile with prior closed session evidence.' }
	$preflightPath = Join-Path $attemptPath 'campaign_static_preflight.json'
	if (-not [IO.File]::Exists($preflightPath)) {
		$preflight = [ordered]@{schema_version=1;work_item='BCM-M34-R23';status='STATIC_RECORDS_ENUMERATED_PHYSICAL_OUTCOMES_PENDING';expected_record_count=1000;enumerated_record_count=$preflightRows.Count;island_count=10;levels_per_island=100;created_utc=[DateTime]::UtcNow.ToString('o');levels=@($preflightRows)}
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
		$recoveredFinishes = @($manifestEvents | Where-Object { $_.attempt_id -ceq $attemptId -and $_.event_type -eq 'TRIAL_FINISHED' })
		foreach ($event in $recoveredFinishes) {
			if (-not $knownCompletedIds.ContainsKey([string]$event.trial_attempt_id)) {
				$recordPath = Join-Path $EvidenceRoot ([string]$event.case_record_path)
				if (-not [IO.File]::Exists($recordPath) -or (Get-Sha256 $recordPath) -cne [string]$event.case_record_sha256) { throw "Finished trial record missing or hash mismatch during R23 resume: $($event.trial_attempt_id)" }
				$completed.Add((Get-Content -Raw -LiteralPath $recordPath | ConvertFrom-Json -ErrorAction Stop))
				$knownCompletedIds[[string]$event.trial_attempt_id] = $true
			}
			$planIndex = -1
			for ($i=0; $i -lt $samplePlan.Count; $i++) { if ([string]$samplePlan[$i].name -ceq [string]$event.trial_name) { $planIndex=$i; break } }
			if ($planIndex -ge 0) { $startIndex = [Math]::Max($startIndex, $planIndex + 1) }
		}
		if ($recoveredFinishes.Count) { Save-R19Checkpoint -NextIndex $startIndex -Reason 'R23_RESUMED_CLOSED_TRIALS' }
	}
	$planEvent = [ordered]@{
		event_id=[guid]::NewGuid().ToString('N');event_type='PILOT_PLAN';attempt_id=$attemptId;role=$attemptRole;parent_attempt_id=$ParentAttemptId;parent_trial_attempt_id=$parentTrialAttemptId;provenance=$provenance;policy='R21_SPATIAL_LANE_V01'
		physics_mode='standard_fps_production_physics';fixed_fps=$false;time_scale=1.0;seed_policy='fixed, unique per case'
		trial_timeout_seconds=$TrialTimeoutSeconds;global_budget_seconds=$GlobalBudgetSeconds;retained_file_ceiling_bytes=$maxRetainedBytes;per_trial_reserve_bytes=$perTrialReserveBytes
		per_trial_internal_wall_limit_seconds=105;normal_4t_cap_source='canonical theoretical_shots_to_go * 4; optional VIP excluded'
		input_path='ShotController._unhandled_input mouse press/release -> footprint projection -> _launch -> Drink.launch_up -> Godot physics'
		inherited_feedback_path=if($inheritedFeedbackPath){[IO.Path]::GetRelativePath($EvidenceRoot,$inheritedFeedbackPath).Replace('\','/')}else{$null}
		inherited_feedback_sha256=if($inheritedFeedbackPath){Get-Sha256 $inheritedFeedbackPath}else{$null}
		static_preflight_path=Get-RelativePath $preflightPath;static_preflight_sha256=Get-Sha256 $preflightPath
		sampling_seed=[int]$selectionManifest.seed;selection_manifest_path=[IO.Path]::GetRelativePath($EvidenceRoot,$SelectionManifestPath).Replace('\','/');selection_manifest_sha256=$selectionManifestSha256;prior_session_roots=@($PriorSessionRoots);prior_completed_level_keys=@($priorCompletedKeys.Keys|Sort-Object);remaining_sample_count=$samplePlan.Count;sample_cases=@($samplePlan | ForEach-Object {@{name=$_.name;island_id=$_.island;level_id=$_.level;global_level_id=$_.global_level_id;seed=$_.seed;round=$_.band;runner_case_vip_enabled=$_.optional_vip_enabled;vip_requirement='NOT_REQUIRED'}})
		stop_rule='R23 owner-updated rule: exactly 10 unique seeded random levels per island, 100 total, interleaved 10 rounds. Each execution is limited to 2100 seconds and 250MB retained evidence. Maximum 120 seconds per trial. No execution of remaining 900 levels.'
	}
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event $planEvent
	$anchorVerification = Confirm-R21Anchor
	$anchorPath = Join-Path $attemptPath 'r21_anchor_verification.json'
	if ([IO.File]::Exists($anchorPath)) {
		$existingAnchor = Get-Content -Raw -LiteralPath $anchorPath | ConvertFrom-Json -ErrorAction Stop
		if ([string]$existingAnchor.source_trace_sha256 -cne [string]$anchorVerification.source_trace_sha256 -or [string]$existingAnchor.source_summary_sha256 -cne [string]$anchorVerification.source_summary_sha256) { throw 'Existing immutable R21 anchor no longer matches current source evidence.' }
		$anchorVerifiedUtc = [string]$existingAnchor.verified_utc
	} else { $anchorPath = Publish-R17UniqueJson -Path $anchorPath -Value $anchorVerification; $anchorVerifiedUtc = [string]$anchorVerification.verified_utc }
	$manifestNow = @(Get-Content -LiteralPath $manifestPath | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop })
	if (-not @($manifestNow | Where-Object { $_.event_type -eq 'R21_ANCHOR_VERIFIED' -and $_.attempt_id -ceq $attemptId }).Count) { Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='R21_ANCHOR_VERIFIED';attempt_id=$attemptId;artifact_path=Get-RelativePath $anchorPath;artifact_sha256=Get-Sha256 $anchorPath;source_trace_sha256=$anchorVerification.source_trace_sha256;verified_utc=$anchorVerifiedUtc}) }
	if ($PlanOnly) { $stopReason='RESUME_PREFLIGHT_PLAN_ONLY'; $startIndex=$samplePlan.Count }

	for ($caseIndex = $startIndex; $caseIndex -lt $samplePlan.Count; $caseIndex++) {
		if ($clock.Elapsed.TotalSeconds -ge $GlobalBudgetSeconds -or ($GlobalBudgetSeconds - $clock.Elapsed.TotalSeconds) -lt ($TrialTimeoutSeconds + 10)) { $stopReason = 'GLOBAL_BUDGET_RESERVE_REACHED'; break }
		if ((Get-ChildItem -LiteralPath $EvidenceRoot -File -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum -ge ($maxRetainedBytes - $perTrialReserveBytes)) { $stopReason = 'RETAINED_FILE_CEILING_RESERVE_REACHED'; break }
		$case = $samplePlan[$caseIndex]
		$canonicalRow = @($preflightRows | Where-Object { $_.island_id -ceq $case.island -and [int]$_.level_id -eq [int]$case.level } | Select-Object -First 1)[0]
		if ($null -eq $canonicalRow) { throw "Pilot case is not present in the 1,000-level static preflight: $($case.name)" }
		$trialAttemptId = [guid]::NewGuid().ToString('N')
		$trialPath = Join-Path $attemptPath "trial_$trialAttemptId"
		if ([IO.Directory]::Exists($trialPath) -or [IO.File]::Exists($trialPath)) { throw "Trial path collision refused: $trialPath" }
		[IO.Directory]::CreateDirectory($trialPath) | Out-Null
		$outputPath = Join-Path $trialPath 'final_trace.json'
		$progressPath = $outputPath
		$watchdogPath = Join-Path $trialPath 'watchdog_result.json'
		$tracePath = Join-Path $trialPath 'final_trace.json'
		$caseRecordPath = Join-Path $trialPath 'case_record.json'
		$runnerVipEnabled = [bool]$case.optional_vip_enabled
		if ($runnerVipEnabled -ne [bool]$canonicalRow.canonical_vip_enabled) { throw "VIP_PROVENANCE_MISMATCH before trial: runner case flag disagrees with canonical level for $($case.island)/$($case.level)" }
		$caseData = [ordered]@{name=$case.name;island_id=$case.island;level_id=[int]$case.level;global_level_id=[int]$canonicalRow.global_level_id;seed=[int]$case.seed;difficulty_band=$case.band;policy='R21_SPATIAL_LANE_V01';physics_mode='standard_fps_production_physics';fixed_fps=$false;time_scale=1.0;canonical_vip_enabled=[bool]$canonicalRow.canonical_vip_enabled;optional_vip_enabled=$runnerVipEnabled;vip_requirement='NOT_REQUIRED';normal_4t_cap_source='canonical theoretical_shots_to_go * 4; optional VIP excluded'}
		$startedUtc = [DateTime]::UtcNow.ToString('o')
		Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='TRIAL_STARTED';attempt_id=$attemptId;trial_attempt_id=$trialAttemptId;trial_name=$case.name;role=if($attemptRole -eq 'R19_ADAPTIVE_RETRY'){'ADAPTIVE_RETRY'}else{'QUALIFICATION_PILOT'};parent_trial_attempt_id=$parentTrialAttemptId;provenance=$provenance;case=$caseData;trial_path=Get-RelativePath $trialPath;started_utc=$startedUtc})
		$arguments = @('--headless','--path',$repoRoot,'--script',$probe,'--',"--r19-output=$outputPath","--r19-progress=$progressPath","--r19-island=$($case.island)","--r19-level=$($case.level)","--r19-seed=$($case.seed)","--r19-expected-vip=$($runnerVipEnabled.ToString().ToLowerInvariant())",'--r19-policy=R21_SPATIAL_LANE_V01','--r19-wall-limit=105')
		if ($inheritedFeedbackPath) { $arguments += "--r19-feedback=$inheritedFeedbackPath" }
		& $watchdog -FilePath $godot -ArgumentList $arguments -TimeoutSeconds $TrialTimeoutSeconds -ResultPath $watchdogPath -ProgressPath $progressPath -TaskName "BCM-M34-R23-$trialAttemptId"
		$watchdogExit = $LASTEXITCODE
		$watchdogData = if ([IO.File]::Exists($watchdogPath)) { Get-Content -Raw -LiteralPath $watchdogPath | ConvertFrom-Json } else { $null }
		$probeData = if ([IO.File]::Exists($outputPath)) { try { Get-Content -Raw -LiteralPath $outputPath | ConvertFrom-Json } catch { $null } } else { $null }
		if ($null -eq $watchdogData) { $watchdogData = [pscustomobject]@{status='ERROR';reason='WATCHDOG_RESULT_MISSING';exit_code=$null;root_identity_verified=$false;terminated_processes=@();stderr='';stdout='';partial_progress=$null} }
		$outcome = Get-R17WatchdogClassification -Watchdog $watchdogData -ProbeResult $probeData
		$traceSource = if ($probeData) { $outputPath } elseif ([IO.File]::Exists($progressPath)) { $progressPath } else { $null }
		$trace = if ($traceSource) { try { Get-Content -Raw -LiteralPath $traceSource | ConvertFrom-Json } catch { $null } } else { $null }
		if ($trace -and ([bool]$trace.optional_vip_enabled -ne $runnerVipEnabled -or [bool]$trace.runner_case_vip_enabled -ne $runnerVipEnabled -or [bool]$trace.optional_vip_enabled -ne [bool]$caseData.canonical_vip_enabled)) { $stopReason = 'VIP_PROVENANCE_MISMATCH'; $outcome = [pscustomobject]@{classification='ERROR';failure_kind='VIP_PROVENANCE_MISMATCH';reason='Canonical, runner case, and immutable trace VIP flags disagree';watchdog_status=[string]$watchdogData.status;exit_code=$watchdogExit;exit_code_hex=('{0:X8}' -f [uint32]$watchdogExit);process_identity_verified=[bool]$watchdogData.root_identity_verified;watchdog_terminated_count=@($watchdogData.terminated_processes).Count;stderr_length=([string]$watchdogData.stderr).Length} }
		$digest = if ([IO.File]::Exists($tracePath)) { Get-R17ActionProgressDigest -TracePath $tracePath } else { $null }
		$objectiveProgress = if ($trace) { Get-R17ObjectiveProgress -Trace $trace } elseif ($watchdogData.partial_progress) { Get-R17ObjectiveProgress -Trace $watchdogData.partial_progress } else { 0 }
		$parityMismatchCount = 0
		if ($trace -and $trace.action_log) {
			foreach ($action in $trace.action_log) {
				$selectedX = [double]$action.selected_candidate_evaluation.candidate_x
				$requestedX = [double]$action.requested_viewport_x
				$firedX = [double]$action.fired_position[0]
				if ([Math]::Abs($selectedX - $requestedX) -gt 0.01 -or [Math]::Abs($requestedX - $firedX) -gt 0.01) { $parityMismatchCount++ }
			}
		}
		$record = [ordered]@{
			schema_version=1;work_item='BCM-M34-R23';attempt_id=$attemptId;trial_attempt_id=$trialAttemptId;trial_name=$case.name;role='R23_TEN_ISLAND_SCREENING';provenance=$provenance;case=$caseData
			classification=[string]$outcome.classification;failure_kind=[string]$outcome.failure_kind;reason=[string]$outcome.reason;watchdog_status=[string]$outcome.watchdog_status
			watchdog_exit_code=$outcome.exit_code;watchdog_exit_code_hex=$outcome.exit_code_hex;process_identity_verified=[bool]$outcome.process_identity_verified
			watchdog_terminated_count=[int]$outcome.watchdog_terminated_count;stderr_length=[int]$outcome.stderr_length;wall_elapsed_ms=[int]$watchdogData.wall_elapsed_ms
			shot_count=if($trace){[int]$trace.shots_used}else{0}
			normal_theoretical_shots_T=if($trace){[int]$trace.normal_theoretical_shots_T}else{0};normal_4t_shot_cap=if($trace){[int]$trace.normal_4t_shot_cap}else{0}
			normal_4t_cap_verified=([bool]$trace -and [int]$trace.normal_4t_shot_cap -eq 4 * [int]$trace.normal_theoretical_shots_T -and [bool]$trace.normal_4t_cap_verified)
			normal_objective_progress=$objectiveProgress;optional_vip_enabled=if($trace){[bool]$trace.optional_vip_enabled}else{$null};runner_case_vip_enabled=$runnerVipEnabled;canonical_vip_enabled=[bool]$canonicalRow.canonical_vip_enabled;vip_requirement='NOT_REQUIRED';action_count=if($digest){[int]$digest.action_count}else{0};contact_count=if($trace){[int]$trace.contact_count}else{0};merge_count=if($trace){[int]$trace.merge_count}else{0};progress_point_count=if($digest){[int]$digest.progress_count}else{0};selected_requested_fired_parity_mismatches=$parityMismatchCount;relevant_errors=@($watchdogData.stderr -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 20)
			action_progress_sha256=if($digest){[string]$digest.action_progress_sha256}else{$null}
			trace_path=Get-RelativePath $tracePath;trace_file_sha256=Get-Sha256 $tracePath
			watchdog_path=Get-RelativePath $watchdogPath;watchdog_file_sha256=Get-Sha256 $watchdogPath
			probe_result_path=Get-RelativePath $outputPath;probe_result_sha256=Get-Sha256 $outputPath
			started_utc=$startedUtc;finished_utc=[DateTime]::UtcNow.ToString('o')
		}
		[void](Publish-R17UniqueJson -Path $caseRecordPath -Value $record)
		$caseHash = Get-Sha256 $caseRecordPath
		Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{
			event_id=[guid]::NewGuid().ToString('N');event_type='TRIAL_FINISHED';attempt_id=$attemptId;trial_attempt_id=$trialAttemptId;trial_name=$case.name;role='R23_TEN_ISLAND_SCREENING';provenance=$provenance;case=$caseData
			classification=$record.classification;failure_kind=$record.failure_kind;reason=$record.reason;normal_objective_progress=$objectiveProgress
			normal_theoretical_shots_T=$record.normal_theoretical_shots_T;normal_4t_shot_cap=$record.normal_4t_shot_cap;normal_4t_cap_verified=$record.normal_4t_cap_verified
			case_record_path=Get-RelativePath $caseRecordPath;case_record_sha256=$caseHash;trace_path=$record.trace_path;trace_file_sha256=$record.trace_file_sha256;selected_requested_fired_parity_mismatches=$parityMismatchCount
			action_progress_sha256=$record.action_progress_sha256;watchdog_path=$record.watchdog_path;watchdog_file_sha256=$record.watchdog_file_sha256;finished_utc=$record.finished_utc
		})
		$completed.Add([pscustomobject]$record)
		Save-R19Checkpoint -NextIndex ($caseIndex + 1) -Reason 'CASE_COMPLETED'
		Write-Host "R23_TRIAL case=$($case.name) outcome=$($record.classification) failure=$($record.failure_kind) objective_progress=$objectiveProgress vip=$runnerVipEnabled actions=$($record.action_count) parity_mismatches=$parityMismatchCount wall_ms=$($record.wall_elapsed_ms)"
		if ($parityMismatchCount -gt 0) { $stopReason = 'GEOMETRY_INPUT_PARITY_ERROR'; break }
		if ($record.classification -eq 'ERROR') { $stopReason = if ($record.failure_kind -eq 'VIP_PROVENANCE_MISMATCH') {'VIP_PROVENANCE_MISMATCH'} else {'ERROR_REQUIRES_DIAGNOSIS'}; break }
	}

	$distinctWins = @($completed | Where-Object classification -eq 'WIN_OBSERVED' | ForEach-Object { "$($_.case.island_id)/$($_.case.level_id)" } | Sort-Object -Unique)
	$winsBeyondEasiest = @($completed | Where-Object { $_.classification -eq 'WIN_OBSERVED' -and -not ($_.case.island_id -ceq 'sunny_cove' -and [int]$_.case.level_id -in @(1,25)) } | ForEach-Object { "$($_.case.island_id)/$($_.case.level_id)" } | Sort-Object -Unique)
	$attemptManifestEvents = @(Get-Content -LiteralPath $manifestPath | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop } | Where-Object { $_.PSObject.Properties.Name -contains 'attempt_id' -and $_.attempt_id -ceq $attemptId })
	$finishedTrialIds = @($attemptManifestEvents | Where-Object event_type -eq 'TRIAL_FINISHED' | ForEach-Object { [string]$_.trial_attempt_id })
	$incompleteTrialIds = @($attemptManifestEvents | Where-Object { $_.event_type -eq 'TRIAL_STARTED' -and $finishedTrialIds -notcontains [string]$_.trial_attempt_id } | ForEach-Object { [string]$_.trial_attempt_id })
	$tasksAfter = (git -C $repoRoot hash-object TASKS.md).Trim()
	$freeAfter = [long](Get-Volume -DriveLetter $drive).SizeRemaining
	$pilotWins = @($completed | Where-Object classification -eq 'WIN_OBSERVED')
	$distinctCompletedLevels = @($completed | ForEach-Object { "$($_.case.island_id)/$($_.case.level_id)" } | Sort-Object -Unique)
	$zeroProgressCount = @($completed | Where-Object { [int]$_.normal_objective_progress -eq 0 }).Count
	$successfulRate = if($distinctCompletedLevels.Count){[Math]::Round($pilotWins.Count/$distinctCompletedLevels.Count,4)}else{0.0}
	$measuredWallSeconds = @($completed | ForEach-Object { [double]$_.wall_elapsed_ms / 1000.0 })
	$meanWallSeconds = if($measuredWallSeconds.Count){($measuredWallSeconds | Measure-Object -Average).Average}else{0.0}
	$minWallSeconds = if($measuredWallSeconds.Count){($measuredWallSeconds | Measure-Object -Minimum).Minimum}else{0.0}
	$maxWallSeconds = if($measuredWallSeconds.Count){($measuredWallSeconds | Measure-Object -Maximum).Maximum}else{0.0}
	$projectedBytes = [long]0
	$pilotBytes = [long]0
	$trialDirs = @(Get-ChildItem -LiteralPath $attemptPath -Directory | Where-Object Name -like 'trial_*')
	if ($trialDirs.Count) { $pilotBytes = [long]((Get-ChildItem -LiteralPath $attemptPath -File -Recurse | Measure-Object -Property Length -Sum).Sum); $projectedBytes = [long][Math]::Ceiling($pilotBytes / [double]$trialDirs.Count * 1000.0) }
	$crossIslandWins = @($pilotWins | Where-Object { [string]$_.case.island_id -ne 'sunny_cove' } | ForEach-Object { "$($_.case.island_id)/$($_.case.level_id)" } | Sort-Object -Unique)
	$winIslandIds = @($pilotWins | ForEach-Object { [string]$_.case.island_id } | Sort-Object -Unique)
	$crossIslandWinIslandCount = $winIslandIds.Count
	$parityErrors = if ($completed.Count) { [long](@($completed | Measure-Object -Property selected_requested_fired_parity_mismatches -Sum).Sum) } else { [long]0 }
	$poorProgressGate = $completed.Count -gt 0 -and $zeroProgressCount -ge [Math]::Ceiling($completed.Count / 2.0)
	$perIslandCounts = @{}
	foreach ($islandId in @($preflightRows | ForEach-Object island_id | Sort-Object -Unique)) {
		$islandTrials = @($completed | Where-Object {$_.case.island_id -ceq $islandId})
		$perIslandCounts[$islandId] = @{attempts=$islandTrials.Count;WIN_OBSERVED=@($islandTrials|Where-Object classification -eq 'WIN_OBSERVED').Count;LOSS_OBSERVED=@($islandTrials|Where-Object classification -eq 'LOSS_OBSERVED').Count;BUDGET_UNKNOWN=@($islandTrials|Where-Object classification -eq 'BUDGET_UNKNOWN').Count;ERROR=@($islandTrials|Where-Object classification -eq 'ERROR').Count}
	}
	$remainingAfterSession = [System.Collections.Generic.List[string]]::new()
	foreach ($plannedCase in $fullSamplePlan) {
		$plannedKey = '{0}/{1}' -f $plannedCase.island,$plannedCase.level
		if ($priorCompletedKeys.ContainsKey($plannedKey)) { continue }
		$alreadyCompleted = @($completed | Where-Object { $_.case.island_id -ceq $plannedCase.island -and [int]$_.case.level_id -eq [int]$plannedCase.level }).Count -gt 0
		if (-not $alreadyCompleted) { $remainingAfterSession.Add($plannedKey) }
	}
	$summary = [ordered]@{
		schema_version=1;work_item='BCM-M34-R23';attempt_id=$attemptId;status=if($stopReason -eq 'SAMPLE_PLAN_COMPLETE' -and $completed.Count -eq $samplePlan.Count -and $incompleteTrialIds.Count -eq 0 -and @($completed | Where-Object classification -eq 'ERROR').Count -eq 0){'PILOT_COMPLETE'}else{'PILOT_PARTIAL'}
		stop_reason=if($incompleteTrialIds.Count){'UNFINALIZED_TRIALS_RECORDED'}else{$stopReason};planned_sample_count=$samplePlan.Count;total_selected_sample_count=100;cumulative_completed_before_session=$priorCompletedKeys.Count;completed_sample_count=$completed.Count;remaining_selected_level_keys=@($remainingAfterSession);incomplete_trial_attempt_ids=$incompleteTrialIds;distinct_observed_win_levels=$distinctWins;distinct_wins_beyond_easiest=$winsBeyondEasiest
		broader_batch_gate='NO_REMAINING_900_LEVEL_EXECUTION_AUTHORIZED'
		trial_timeout_seconds=$TrialTimeoutSeconds;global_budget_seconds=$GlobalBudgetSeconds;actual_elapsed_ms=[int]$clock.Elapsed.TotalMilliseconds;actual_disk_free_delta_bytes=($freeAfter-$freeBefore);retained_task_evidence_bytes=[long]((Get-ChildItem -LiteralPath $EvidenceRoot -File -Recurse | Measure-Object -Property Length -Sum).Sum);retained_file_ceiling_bytes=$maxRetainedBytes;per_island_counts=$perIslandCounts
		distinct_levels_completed=$distinctCompletedLevels.Count;distinct_level_keys=$distinctCompletedLevels;sample_success_rate=$successfulRate;zero_progress_count=$zeroProgressCount;poor_progress_defined_as_zero_progress_on_at_least_half_completed_trials=[bool]$poorProgressGate;distinct_win_islands=$winIslandIds;cross_island_distinct_wins=$crossIslandWins;selected_requested_fired_parity_mismatches=$parityErrors
		runtime_estimate_100_sample=@{mean_seconds=[Math]::Round($meanWallSeconds*100,1);observed_min_to_max_seconds=@([Math]::Round($minWallSeconds*100,1),[Math]::Round($maxWallSeconds*100,1));uncertainty='Naive extrapolation from this bounded session; observed min/max per-trial wall is not a statistical confidence interval.'}
		evidence_storage_estimate_100_sample_bytes=[long]([Math]::Ceiling($pilotBytes / [Math]::Max(1,$trialDirs.Count) * 100.0));storage_estimate_basis='Observed per-trial attempt bytes scaled to the selected 100-level sample; excludes shared editor/import/cache overhead.'
		remaining_900_plan=@{not_started=$true;authorized=$false;gate='R23 explicitly forbids execution of remaining 900 levels.'}
		static_preflight_path=Get-RelativePath $preflightPath;static_preflight_sha256=Get-Sha256 $preflightPath
		outcome_counts=@{WIN_OBSERVED=@($completed | Where-Object classification -eq 'WIN_OBSERVED').Count;LOSS_OBSERVED=@($completed | Where-Object classification -eq 'LOSS_OBSERVED').Count;BUDGET_UNKNOWN=@($completed | Where-Object classification -eq 'BUDGET_UNKNOWN').Count;ERROR=@($completed | Where-Object classification -eq 'ERROR').Count}
		appdata_roaming_path=$appDataRoaming;appdata_local_path=$appDataLocal;tasks_blob_before=$tasksBefore;tasks_blob_after=$tasksAfter;tasks_unchanged=($tasksBefore -ceq $tasksAfter)
		completed_trials=@($completed | ForEach-Object {@{trial_attempt_id=$_.trial_attempt_id;trial_name=$_.trial_name;classification=$_.classification;failure_kind=$_.failure_kind;objective_progress=$_.normal_objective_progress;action_count=$_.action_count;trace_path=$_.trace_path;trace_file_sha256=$_.trace_file_sha256;action_progress_sha256=$_.action_progress_sha256}})
	}
	if (-not [IO.File]::Exists((Join-Path $attemptPath 'attempt_summary.json'))) {
		$summaryPath = Publish-R17UniqueJson -Path (Join-Path $attemptPath 'attempt_summary.json') -Value $summary
		Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='ATTEMPT_FINISHED';attempt_id=$attemptId;status=$summary.status;stop_reason=$stopReason;summary_path=Get-RelativePath $summaryPath;summary_sha256=Get-Sha256 $summaryPath;finished_utc=[DateTime]::UtcNow.ToString('o')})
	}
	Write-Output "R23_ATTEMPT=$attemptId status=$($summary.status) stop=$stopReason trials=$($completed.Count)/$($samplePlan.Count) distinct_wins=$($distinctWins.Count) win_islands=$($winIslandIds.Count) parity_errors=$parityErrors elapsed_ms=$($summary.actual_elapsed_ms) retained_bytes=$($summary.retained_task_evidence_bytes) tasks_unchanged=$($summary.tasks_unchanged)"
} catch {
	$failureMessage = [string]$_.Exception.Message
	try {
		if ([IO.Directory]::Exists($attemptPath) -and [IO.File]::Exists($manifestPath)) {
			$failureEvents = @(Get-Content -LiteralPath $manifestPath | ForEach-Object { $_ | ConvertFrom-Json -ErrorAction Stop })
			$hasStart = @($failureEvents | Where-Object { $_.event_type -eq 'ATTEMPT_STARTED' -and $_.attempt_id -ceq $attemptId }).Count -eq 1
			$hasFinish = @($failureEvents | Where-Object { $_.event_type -eq 'ATTEMPT_FINISHED' -and $_.attempt_id -ceq $attemptId }).Count -gt 0
			if ($hasStart -and -not $hasFinish) {
				$failedSummaryPath = Join-Path $attemptPath 'attempt_summary.json'
				if (-not [IO.File]::Exists($failedSummaryPath)) {
					$failureTrialsStarted = @($failureEvents | Where-Object { $_.event_type -eq 'TRIAL_STARTED' -and $_.attempt_id -ceq $attemptId })
					$failureTrialsFinished = @($failureEvents | Where-Object { $_.event_type -eq 'TRIAL_FINISHED' -and $_.attempt_id -ceq $attemptId })
					$failureStatus = if ($failureTrialsStarted.Count -eq 0) { 'PREFLIGHT_ERROR' } else { 'PILOT_PARTIAL' }
					$failureSummary = [ordered]@{schema_version=1;work_item='BCM-M34-R23';attempt_id=$attemptId;status=$failureStatus;stop_reason='UNHANDLED_RUNNER_EXCEPTION';failure_detail=$failureMessage;planned_sample_count=@($samplePlan).Count;completed_sample_count=$failureTrialsFinished.Count;incomplete_trial_attempt_ids=@($failureTrialsStarted | Where-Object { $failureTrialsFinished.trial_attempt_id -notcontains $_.trial_attempt_id } | ForEach-Object { [string]$_.trial_attempt_id });tasks_blob_before=$tasksBefore;tasks_blob_after=(git -C $repoRoot hash-object TASKS.md).Trim();tasks_unchanged=($tasksBefore -ceq (git -C $repoRoot hash-object TASKS.md).Trim());created_utc=[DateTime]::UtcNow.ToString('o')}
					$failedSummaryPath = Publish-R17UniqueJson -Path $failedSummaryPath -Value $failureSummary
				}
				$closedSummary = Get-Content -Raw -LiteralPath $failedSummaryPath | ConvertFrom-Json -ErrorAction Stop
				Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='ATTEMPT_FINISHED';attempt_id=$attemptId;status=[string]$closedSummary.status;stop_reason='UNHANDLED_RUNNER_EXCEPTION';summary_path=Get-RelativePath $failedSummaryPath;summary_sha256=Get-Sha256 $failedSummaryPath;finished_utc=[DateTime]::UtcNow.ToString('o')})
			}
		}
	} catch { Write-Warning "Could not close failed R23 attempt manifest: $($_.Exception.Message)" }
	throw
} finally {
	$env:APPDATA = $oldAppData
	$env:LOCALAPPDATA = $oldLocalAppData
}

if ($tasksBefore -cne $tasksAfter) { throw 'TASKS.md Git blob changed during R22 pilot.' }
