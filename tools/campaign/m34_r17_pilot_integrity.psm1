Set-StrictMode -Version Latest

function ConvertTo-R17JsonLine([object]$Value) {
	return ($Value | ConvertTo-Json -Depth 80 -Compress)
}

function Add-R17ManifestEvent {
	param([Parameter(Mandatory)][string]$ManifestPath, [Parameter(Mandatory)][System.Collections.IDictionary]$Event)
	$fullPath = [IO.Path]::GetFullPath($ManifestPath)
	$parent = Split-Path -Parent $fullPath
	[IO.Directory]::CreateDirectory($parent) | Out-Null
	$eventId = [string]$Event.event_id
	if ([string]::IsNullOrWhiteSpace($eventId)) { throw 'Manifest event requires a unique event_id.' }
	$existing = @()
	if ([IO.File]::Exists($fullPath)) {
		$bytes = [IO.File]::ReadAllBytes($fullPath)
		if ($bytes.Length -gt 0 -and $bytes[$bytes.Length - 1] -ne 10) { throw 'Manifest has a partial final line; refusing append.' }
		foreach ($line in [IO.File]::ReadAllLines($fullPath)) {
			if ([string]::IsNullOrWhiteSpace($line)) { throw 'Manifest contains a blank line; refusing append.' }
			try { $existing += ($line | ConvertFrom-Json -ErrorAction Stop) } catch { throw 'Manifest contains invalid JSON; refusing append.' }
		}
	}
	if (@($existing | Where-Object { $_.event_id -ceq $eventId }).Count) { throw "Duplicate manifest event_id refused: $eventId" }
	if ([string]$Event.event_type -eq 'ATTEMPT_STARTED' -and @($existing | Where-Object { $_.event_type -eq 'ATTEMPT_STARTED' -and $_.attempt_id -ceq [string]$Event.attempt_id }).Count) { throw 'Duplicate attempt_id refused.' }
	if ([string]$Event.event_type -eq 'TRIAL_STARTED' -and @($existing | Where-Object { $_.event_type -eq 'TRIAL_STARTED' -and $_.trial_attempt_id -ceq [string]$Event.trial_attempt_id }).Count) { throw 'Duplicate trial_attempt_id refused.' }
	$line = (ConvertTo-R17JsonLine $Event) + "`n"
	$payload = [Text.UTF8Encoding]::new($false).GetBytes($line)
	$mode = if ([IO.File]::Exists($fullPath)) { [IO.FileMode]::Append } else { [IO.FileMode]::CreateNew }
	$stream = [IO.File]::Open($fullPath, $mode, [IO.FileAccess]::Write, [IO.FileShare]::None)
	try { $stream.Write($payload, 0, $payload.Length); $stream.Flush($true) } finally { $stream.Dispose() }
}

function New-R17AttemptDirectory {
	param([Parameter(Mandatory)][string]$EvidenceRoot, [Parameter(Mandatory)][string]$AttemptId, [Parameter(Mandatory)][string]$ManifestPath, [Parameter(Mandatory)][string]$Role, [string]$ParentAttemptId = '')
	if ($AttemptId -notmatch '^\d{8}T\d{9}Z_[a-f0-9]{32}$') { throw 'Attempt ID format is invalid.' }
	$root = [IO.Path]::GetFullPath($EvidenceRoot)
	$attemptsRoot = Join-Path $root 'attempts'
	[IO.Directory]::CreateDirectory($attemptsRoot) | Out-Null
	$claimPath = Join-Path $attemptsRoot "$AttemptId.claim"
	$claim = [IO.File]::Open($claimPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
	try { $bytes = [Text.UTF8Encoding]::new($false).GetBytes("$AttemptId`n$Role`n"); $claim.Write($bytes, 0, $bytes.Length); $claim.Flush($true) } finally { $claim.Dispose() }
	$attemptPath = Join-Path $attemptsRoot $AttemptId
	if ([IO.Directory]::Exists($attemptPath) -or [IO.File]::Exists($attemptPath)) { throw "Attempt directory collision refused: $attemptPath" }
	[IO.Directory]::CreateDirectory($attemptPath) | Out-Null
	Add-R17ManifestEvent -ManifestPath $ManifestPath -Event ([ordered]@{
		event_id = [guid]::NewGuid().ToString('N'); event_type = 'ATTEMPT_STARTED'; attempt_id = $AttemptId
		role = $Role; parent_attempt_id = $ParentAttemptId; attempt_path = (Resolve-Path $attemptPath).Path
		started_utc = [DateTime]::UtcNow.ToString('o')
	})
	return $attemptPath
}

function Publish-R17UniqueJson {
	param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][object]$Value)
	$fullPath = [IO.Path]::GetFullPath($Path)
	if ([IO.File]::Exists($fullPath) -or [IO.Directory]::Exists($fullPath)) { throw "Immutable output collision refused: $fullPath" }
	[IO.Directory]::CreateDirectory((Split-Path -Parent $fullPath)) | Out-Null
	$tempPath = "$fullPath.tmp.$([guid]::NewGuid().ToString('N'))"
	$payload = [Text.UTF8Encoding]::new($false).GetBytes(((ConvertTo-R17JsonLine $Value) + "`n"))
	$stream = [IO.File]::Open($tempPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
	try { $stream.Write($payload, 0, $payload.Length); $stream.Flush($true) } finally { $stream.Dispose() }
	[IO.File]::Move($tempPath, $fullPath)
	return $fullPath
}

function Get-R17ActionProgressDigest {
	param([Parameter(Mandatory)][string]$TracePath)
	if (-not [IO.File]::Exists($TracePath)) { return $null }
	$data = Get-Content -Raw -LiteralPath $TracePath | ConvertFrom-Json -ErrorAction Stop
	$actions = @($data.action_log)
	$progress = @($data.progress_curve)
	if ($data.PSObject.Properties.Name -contains 'partial_progress' -and $data.partial_progress) {
		if ($actions.Count -eq 0) { $actions = @($data.partial_progress.action_log) }
		if ($progress.Count -eq 0) { $progress = @($data.partial_progress.progress_curve) }
	}
	$canonical = [ordered]@{ action_log = $actions; progress_curve = $progress }
	$bytes = [Text.UTF8Encoding]::new($false).GetBytes((ConvertTo-R17JsonLine $canonical))
	$sha = [Security.Cryptography.SHA256]::HashData($bytes)
	return [pscustomobject]@{ action_count = $actions.Count; progress_count = $progress.Count; action_progress_sha256 = [Convert]::ToHexString($sha).ToLower() }
}

function Get-R17ObjectiveProgress {
	param([object]$Trace)
	$best = 0
	$progressCurve = if ($Trace.PSObject.Properties.Name -contains 'progress_curve') { @($Trace.progress_curve) } else { @() }
	foreach ($point in $progressCurve) {
		if ($null -ne $point.normal_T_progressed) { $best = [Math]::Max($best, [int]$point.normal_T_progressed) }
		elseif ($null -ne $point.normal_T_start -and $null -ne $point.normal_T_remaining) { $best = [Math]::Max($best, [int]$point.normal_T_start - [int]$point.normal_T_remaining) }
	}
	if ($Trace.PSObject.Properties.Name -contains 'normal_orders_completed' -and $Trace.normal_orders_completed) {
		$completed = 0
		foreach ($property in $Trace.normal_orders_completed.PSObject.Properties) { $completed += [int]$property.Value }
		if ($completed -gt 0) { $best = [Math]::Max($best, $completed) }
	}
	return $best
}

function Get-R17WatchdogClassification {
	param([Parameter(Mandatory)][object]$Watchdog, [object]$ProbeResult)
	$status = [string]$Watchdog.status
	$exitCode = $Watchdog.exit_code
	$classification = 'ERROR'
	$failureKind = 'HARNESS_OR_WATCHDOG_ERROR'
	$reason = [string]$Watchdog.reason
	if ($status -eq 'TIMEOUT_TERMINATED') {
		$classification = 'BUDGET_UNKNOWN'; $failureKind = 'EXTERNAL_WATCHDOG_TIMEOUT'; $reason = 'EXTERNAL_TRIAL_WATCHDOG_TIMEOUT'
	} elseif ($status -eq 'CHILD_ERROR') {
		$classification = 'ERROR'
		$failureKind = if ($null -ne $exitCode -and [long]$exitCode -lt 0) { 'UNATTRIBUTED_NEGATIVE_CHILD_EXIT' } else { 'CHILD_PROCESS_NONZERO_EXIT' }
	} elseif ($status -eq 'EXITED' -and [int]$exitCode -eq 0 -and $ProbeResult -and [string]$ProbeResult.classification -in @('WIN_OBSERVED','LOSS_OBSERVED','BUDGET_UNKNOWN')) {
		$classification = [string]$ProbeResult.classification; $failureKind = 'NONE'; $reason = [string]$ProbeResult.terminal_reason
	} elseif ($status -eq 'EXITED') {
		$failureKind = if ([int]$exitCode -eq 0) { 'PROBE_RESULT_MISSING_OR_INVALID' } else { 'CHILD_PROCESS_NONZERO_EXIT' }
	}
	return [pscustomobject]@{ classification = $classification; failure_kind = $failureKind; reason = $reason; exit_code = $exitCode; exit_code_hex = if ($null -ne $exitCode) { '0x{0:X8}' -f ([uint32]([int64]$exitCode -band 0xffffffffL)) } else { $null }; watchdog_status = $status; process_identity_verified = [bool]$Watchdog.root_identity_verified; watchdog_terminated_count = @($Watchdog.terminated_processes).Count; stderr_length = ([string]$Watchdog.stderr).Length }
}

Export-ModuleMember -Function Add-R17ManifestEvent, New-R17AttemptDirectory, Publish-R17UniqueJson, Get-R17ActionProgressDigest, Get-R17ObjectiveProgress, Get-R17WatchdogClassification
