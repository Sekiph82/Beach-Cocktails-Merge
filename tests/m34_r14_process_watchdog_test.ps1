$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$watchdog = Join-Path $repoRoot "tools/campaign/m34_r14_process_watchdog.ps1"
$hungChild = Join-Path $repoRoot "tools/campaign/m34_r14_watchdog_hung_child.ps1"
$evidenceDir = Join-Path $repoRoot "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R14"
$resultPath = Join-Path $evidenceDir "watchdog_synthetic_test.json"
$watchdogRunPath = Join-Path $evidenceDir "watchdog_synthetic_run.json"
$progressPath = Join-Path $evidenceDir "watchdog_synthetic_partial.json"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$pwshPath = (Get-Process -Id $PID).Path
$sentinel = $null
$sentinelStart = $null
$sentinelPath = $null

try {
	$sentinel = Start-Process -FilePath $pwshPath -ArgumentList @("-NoProfile", "-Command", "Start-Sleep -Seconds 45") -PassThru -WindowStyle Hidden
	$sentinelStart = $sentinel.StartTime.ToUniversalTime()
	$sentinelPath = $sentinel.MainModule.FileName
	$progressJson = (@{status="CASE_RUNNING";classification="UNKNOWN_TIMEOUT";case="SYNTHETIC_HUNG_CHILD";completed_records=0;partial_reason="test marker written before child launch"} | ConvertTo-Json).Replace("`r`n", "`n")
	[IO.File]::WriteAllText($progressPath, $progressJson + "`n", [Text.UTF8Encoding]::new($false))
	$watchdogExit = 0
	& $watchdog -FilePath $pwshPath -ArgumentList @("-NoProfile", "-File", $hungChild) -TimeoutSeconds 2 -ResultPath $watchdogRunPath -ProgressPath $progressPath -TaskName "BCM-M34-R14-SYNTHETIC-WATCHDOG-TEST"
	$watchdogExit = $LASTEXITCODE
	$watchdogResult = Get-Content -Raw -LiteralPath $watchdogRunPath | ConvertFrom-Json
	$targetPid = [int]$watchdogResult.root_pid
	$targetStillAlive = $false
	try { $null = Get-Process -Id $targetPid -ErrorAction Stop; $targetStillAlive = $true } catch {}
	$sentinelStillAlive = $false
	try {
		$currentSentinel = Get-Process -Id $sentinel.Id -ErrorAction Stop
		$sentinelStillAlive = ($currentSentinel.Path -ieq $sentinelPath -and [math]::Abs(($currentSentinel.StartTime.ToUniversalTime() - $sentinelStart).TotalSeconds) -lt 1.0)
	} catch {}
	$terminatedAllVerified = @($watchdogResult.terminated_processes | Where-Object { -not $_.verified -or -not $_.terminated }).Count -eq 0
	$partialPreserved = ($watchdogResult.partial_progress.status -eq "CASE_RUNNING" -and $watchdogResult.partial_progress.classification -eq "UNKNOWN_TIMEOUT" -and $watchdogResult.partial_progress.case -eq "SYNTHETIC_HUNG_CHILD")
	$pass = ($watchdogExit -eq 124 -and $watchdogResult.status -eq "TIMEOUT_TERMINATED" -and $watchdogResult.reason -eq "PROCESS_WALL_TIMEOUT" -and $watchdogResult.root_identity_verified -and -not $targetStillAlive -and $sentinelStillAlive -and $terminatedAllVerified -and $partialPreserved)
	$summary = [ordered]@{
		schema_version = 1
		test = "M34-R14 process-level watchdog synthetic hung child"
		watchdog_exit = $watchdogExit
		watchdog_status = $watchdogResult.status
		watchdog_reason = $watchdogResult.reason
		root_pid = $targetPid
		root_identity_verified = $watchdogResult.root_identity_verified
		terminated_processes = $watchdogResult.terminated_processes
		hung_child_still_alive = $targetStillAlive
		unrelated_sentinel_pid = $sentinel.Id
		unrelated_sentinel_still_alive = $sentinelStillAlive
		all_termination_targets_verified = $terminatedAllVerified
		partial_progress_preserved = $partialPreserved
		watchdog_report = $watchdogResult
		result = if ($pass) { "PASS" } else { "FAIL" }
	}
	$summaryJson = ($summary | ConvertTo-Json -Depth 12).Replace("`r`n", "`n")
	[IO.File]::WriteAllText($resultPath, $summaryJson + "`n", [Text.UTF8Encoding]::new($false))
	if (-not $pass) { throw "Watchdog synthetic test failed; see $resultPath" }
	Write-Output "M34_R14_WATCHDOG_SYNTHETIC_TEST=PASS root_pid=$targetPid sentinel_pid=$($sentinel.Id)"
} finally {
	if ($sentinel) {
		try {
			$current = Get-Process -Id $sentinel.Id -ErrorAction Stop
			if ($current.Path -ieq $sentinelPath -and [math]::Abs(($current.StartTime.ToUniversalTime() - $sentinelStart).TotalSeconds) -lt 1.0) { $current.Kill() }
		} catch {}
	}
}
