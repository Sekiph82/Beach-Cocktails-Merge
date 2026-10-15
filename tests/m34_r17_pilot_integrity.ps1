param(
	[Parameter(Mandatory)][string]$EvidenceRoot,
	[Parameter(Mandatory)][string]$R16WatchdogPath,
	[Parameter(Mandatory)][string]$SummarizerPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$modulePath = Join-Path $repoRoot 'tools/campaign/m34_r17_pilot_integrity.psm1'
Import-Module $modulePath -Force
$EvidenceRoot = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $EvidenceRoot).Path)
$runId = [guid]::NewGuid().ToString('N')
$fixtureRoot = Join-Path $EvidenceRoot "integrity_selftest_$runId"
[IO.Directory]::CreateDirectory($fixtureRoot) | Out-Null
$manifestPath = Join-Path $fixtureRoot 'manifest.jsonl'
$attemptId = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '_' + $runId
$attemptPath = New-R17AttemptDirectory -EvidenceRoot $fixtureRoot -AttemptId $attemptId -ManifestPath $manifestPath -Role 'ADVERSARIAL_SELF_TEST'
$manifestBeforeDuplicate = (Get-FileHash -Algorithm SHA256 -LiteralPath $manifestPath).Hash.ToLower()

$duplicateRejected = $false
try { [void](New-R17AttemptDirectory -EvidenceRoot $fixtureRoot -AttemptId $attemptId -ManifestPath $manifestPath -Role 'RERUN_MUST_BE_REFUSED') } catch { $duplicateRejected = $true }
if (-not $duplicateRejected) { throw 'Attempt-ID collision was not refused.' }
$manifestAfterDuplicate = (Get-FileHash -Algorithm SHA256 -LiteralPath $manifestPath).Hash.ToLower()
if ($manifestAfterDuplicate -cne $manifestBeforeDuplicate) { throw 'Rejected attempt-ID collision changed the append-only manifest.' }

$tracePath = Join-Path $attemptPath 'immutable_trace.json'
[void](Publish-R17UniqueJson -Path $tracePath -Value ([ordered]@{action_log=@(@{step=0;spawn_level=1});progress_curve=@(@{action_count=1;normal_T_progressed=0})}))
$traceBefore = (Get-FileHash -Algorithm SHA256 -LiteralPath $tracePath).Hash.ToLower()
$outputCollisionRejected = $false
try { [void](Publish-R17UniqueJson -Path $tracePath -Value @{replacement=$true}) } catch { $outputCollisionRejected = $true }
if (-not $outputCollisionRejected) { throw 'Immutable trace path collision was not refused.' }
$traceAfter = (Get-FileHash -Algorithm SHA256 -LiteralPath $tracePath).Hash.ToLower()
if ($traceAfter -cne $traceBefore) { throw 'Rejected output collision changed the earlier trace.' }

$duplicateEventRejected = $false
$startEvent = [ordered]@{event_id='duplicate-event-test';event_type='TRIAL_STARTED';attempt_id=$attemptId;trial_attempt_id='fixed-trial-id';trial_name='adversarial';role='TEST';case=@{};started_utc=[DateTime]::UtcNow.ToString('o')}
Add-R17ManifestEvent -ManifestPath $manifestPath -Event $startEvent
$manifestBeforeTrialCollision = (Get-FileHash -Algorithm SHA256 -LiteralPath $manifestPath).Hash.ToLower()
try { $copy=$startEvent.Clone(); $copy.event_id=[guid]::NewGuid().ToString('N'); Add-R17ManifestEvent -ManifestPath $manifestPath -Event $copy } catch { $duplicateEventRejected = $true }
if (-not $duplicateEventRejected) { throw 'Duplicate trial_attempt_id was not refused.' }
$manifestAfterTrialCollision = (Get-FileHash -Algorithm SHA256 -LiteralPath $manifestPath).Hash.ToLower()
if ($manifestAfterTrialCollision -cne $manifestBeforeTrialCollision) { throw 'Rejected duplicate trial ID changed the manifest.' }

$r16 = Get-Content -Raw -LiteralPath $R16WatchdogPath | ConvertFrom-Json
$r16Class = Get-R17WatchdogClassification -Watchdog $r16 -ProbeResult $null
if ($r16Class.classification -ne 'ERROR' -or $r16Class.failure_kind -ne 'UNATTRIBUTED_NEGATIVE_CHILD_EXIT' -or $r16Class.exit_code_hex -ne '0xFFFFFFFF' -or $r16Class.watchdog_terminated_count -ne 0) {
	throw "R16 child-error classifier failed: $($r16Class | ConvertTo-Json -Compress)"
}

$mainManifest = Join-Path $EvidenceRoot 'attempt_manifest.jsonl'
if (-not (Test-Path -LiteralPath $mainManifest -PathType Leaf)) { throw 'Pilot manifest is required before summarizer idempotence check.' }
function Get-EvidenceFingerprint([string]$Root) {
	$entries = foreach ($file in (Get-ChildItem -LiteralPath $Root -File -Recurse | Sort-Object FullName)) {
		$relative = [IO.Path]::GetRelativePath($Root,$file.FullName).Replace('\','/')
		$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash.ToLower()
		"$relative=$hash"
	}
	return [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.UTF8Encoding]::new($false).GetBytes(($entries -join "`n")))).ToLower()
}
$beforeSummaries = Get-EvidenceFingerprint $EvidenceRoot
$firstOutput = (& $SummarizerPath -EvidenceRoot $EvidenceRoot -ManifestPath $mainManifest | Out-String).Trim()
$betweenSummaries = Get-EvidenceFingerprint $EvidenceRoot
$secondOutput = (& $SummarizerPath -EvidenceRoot $EvidenceRoot -ManifestPath $mainManifest | Out-String).Trim()
$afterSummaries = Get-EvidenceFingerprint $EvidenceRoot
if ($firstOutput -cne $secondOutput) { throw 'Read-only report output is not idempotent.' }
if ($beforeSummaries -cne $betweenSummaries -or $beforeSummaries -cne $afterSummaries) { throw 'Read-only report generator modified evidence inputs.' }
$report = $firstOutput | ConvertFrom-Json
if ($report.integrity_status -ne 'PASS') { throw "Evidence integrity report failed: $($report.integrity_problems -join ',')" }

Write-Output "R17_INTEGRITY_TESTS=PASS attempt_collision=refused trace_overwrite=refused duplicate_trial=refused r16_negative_exit=ERROR_NOT_UNKNOWN report_idempotent=true report_read_only=true"
