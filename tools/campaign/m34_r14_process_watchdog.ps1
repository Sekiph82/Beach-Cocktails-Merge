param(
	[Parameter(Mandatory = $true)][string]$FilePath,
	[string[]]$ArgumentList = @(),
	[ValidateRange(1, 600)][int]$TimeoutSeconds = 15,
	[Parameter(Mandatory = $true)][string]$ResultPath,
	[string]$ProgressPath = "",
	[string]$TaskName = "BCM-M34-R14"
)

$ErrorActionPreference = "Stop"
$token = [guid]::NewGuid().ToString("N")
$ArgumentList += $token
$startedUtc = [DateTime]::UtcNow
$startedTicks = [Diagnostics.Stopwatch]::GetTimestamp()
$process = $null
$stdoutTask = $null
$stderrTask = $null
$owned = @{}
$descendantEdges = @{}
$killRecords = [System.Collections.Generic.List[object]]::new()
$status = "ERROR"
$reason = "WATCHDOG_NOT_COMPLETED"
$exitCode = $null

function Get-ProcessSnapshot {
	@(Get-CimInstance -ClassName Win32_Process -ErrorAction Stop | ForEach-Object {
		[pscustomobject]@{
			pid = [int]$_.ProcessId
			parent_pid = [int]$_.ParentProcessId
			path = [string]$_.ExecutablePath
			command_line = [string]$_.CommandLine
			creation_date = $_.CreationDate
		}
	})
}

function Get-CreationUtc([object]$Value) {
	if ($null -eq $Value) { return $null }
	if ($Value -is [DateTime]) { return $Value.ToUniversalTime() }
	if ([string]::IsNullOrWhiteSpace([string]$Value)) { return $null }
	try { return [System.Management.ManagementDateTimeConverter]::ToDateTime([string]$Value).ToUniversalTime() }
	catch { return $null }
}

function Test-SameIdentity($Expected, $Actual) {
	if ($null -eq $Actual -or $null -eq $Expected) { return $false }
	$created = Get-CreationUtc $Actual.creation_date
	return ($Actual.pid -eq $Expected.pid -and
		$Actual.path -ieq $Expected.path -and
		$Actual.command_line -ceq $Expected.command_line -and
		$null -ne $created -and
		[math]::Abs(($created - $Expected.created_utc).TotalSeconds) -lt 1.0)
}

function Write-DurableResult {
	$partial = $null
	if (-not [string]::IsNullOrWhiteSpace($ProgressPath) -and (Test-Path -LiteralPath $ProgressPath -PathType Leaf)) {
		try { $partial = Get-Content -Raw -LiteralPath $ProgressPath | ConvertFrom-Json }
		catch { $partial = @{ read_error = $_.Exception.Message } }
	}
	$result = [ordered]@{
		schema_version = 1
		task = $TaskName
		status = $status
		reason = $reason
		started_utc = $startedUtc.ToString("o")
		finished_utc = [DateTime]::UtcNow.ToString("o")
		wall_elapsed_ms = [int]([Diagnostics.Stopwatch]::GetElapsedTime($startedTicks).TotalMilliseconds)
		timeout_seconds = $TimeoutSeconds
		file_path = [IO.Path]::GetFullPath($FilePath)
		root_pid = if ($process) { $process.Id } else { $null }
		root_identity_verified = [bool]($owned.Count -gt 0 -and $owned.ContainsKey($process.Id))
		task_token = $token
		exit_code = $exitCode
		terminated_processes = @($killRecords)
		stdout = if ($stdoutTask -and $stdoutTask.IsCompleted) { $stdoutTask.Result } else { "" }
		stderr = if ($stderrTask -and $stderrTask.IsCompleted) { $stderrTask.Result } else { "" }
		partial_progress = $partial
	}
	$directory = Split-Path -Parent $ResultPath
	if (-not [string]::IsNullOrWhiteSpace($directory)) { New-Item -ItemType Directory -Force -Path $directory | Out-Null }
	$tempPath = "$ResultPath.$token.tmp"
	$json = ($result | ConvertTo-Json -Depth 20).Replace("`r`n", "`n")
	[IO.File]::WriteAllText($tempPath, $json + "`n", [Text.UTF8Encoding]::new($false))
	Move-Item -LiteralPath $tempPath -Destination $ResultPath -Force
}

try {
	$absoluteExe = (Resolve-Path -LiteralPath $FilePath).Path
	$startInfo = [Diagnostics.ProcessStartInfo]::new()
	$startInfo.FileName = $absoluteExe
	$startInfo.UseShellExecute = $false
	$startInfo.CreateNoWindow = $true
	$startInfo.RedirectStandardOutput = $true
	$startInfo.RedirectStandardError = $true
	foreach ($argument in $ArgumentList) { [void]$startInfo.ArgumentList.Add([string]$argument) }
	$process = [Diagnostics.Process]::new()
	$process.StartInfo = $startInfo
	if (-not $process.Start()) { throw "Process.Start returned false." }
	$stdoutTask = $process.StandardOutput.ReadToEndAsync()
	$stderrTask = $process.StandardError.ReadToEndAsync()
	if (-not $process.HasExited) {
		$rootPath = try { $process.MainModule.FileName } catch { $absoluteExe }
		$rootCreated = $process.StartTime.ToUniversalTime()
		$rootSnapshot = (Get-ProcessSnapshot | Where-Object { $_.pid -eq $process.Id } | Select-Object -First 1)
		if ($null -eq $rootSnapshot -and $process.HasExited) { $rootSnapshot = $null }
		elseif ($null -eq $rootSnapshot -or $rootSnapshot.pid -ne $process.Id -or [string]::IsNullOrWhiteSpace($rootSnapshot.path) -or [math]::Abs(((Get-CreationUtc $rootSnapshot.creation_date) - $rootCreated).TotalSeconds) -ge 1.0) {
			throw "Could not verify exact launched root PID, executable path, and task token."
		}
		if ($rootSnapshot) {
			$rootIdentity = [pscustomobject]@{
				pid = $process.Id
				path = $rootSnapshot.path
				command_line = $rootSnapshot.command_line
				created_utc = $rootCreated
				parent_pid = $rootSnapshot.parent_pid
				depth = 0
			}
			$owned[$process.Id] = $rootIdentity
		}
	}

	$deadline = [Diagnostics.Stopwatch]::StartNew()
	while (-not $process.HasExited -and $deadline.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
		$snapshot = Get-ProcessSnapshot
		$changed = $true
		while ($changed) {
			$changed = $false
			foreach ($candidate in $snapshot) {
				if ($owned.ContainsKey($candidate.pid) -or -not $owned.ContainsKey($candidate.parent_pid)) { continue }
				$created = Get-CreationUtc $candidate.creation_date
				$parent = $owned[$candidate.parent_pid]
				if ($null -eq $created -or $created -lt $parent.created_utc -or $created -gt [DateTime]::UtcNow.AddSeconds(1) -or [string]::IsNullOrWhiteSpace($candidate.path)) { continue }
				$owned[$candidate.pid] = [pscustomobject]@{
					pid = $candidate.pid
					path = $candidate.path
					command_line = $candidate.command_line
					created_utc = $created
					parent_pid = $candidate.parent_pid
					depth = $parent.depth + 1
				}
				$changed = $true
			}
		}
		[void]$process.WaitForExit(100)
	}
	if ($process.HasExited) {
		$process.WaitForExit()
		$exitCode = $process.ExitCode
		$status = if ($exitCode -eq 0) { "EXITED" } else { "CHILD_ERROR" }
		$reason = if ($exitCode -eq 0) { "CHILD_EXITED_WITHIN_WALL_BUDGET" } else { "CHILD_EXIT_CODE_$exitCode" }
	} else {
		$status = "TIMEOUT_TERMINATED"
		$reason = "PROCESS_WALL_TIMEOUT"
		$lastSnapshot = Get-ProcessSnapshot
		$changed = $true
		while ($changed) {
			$changed = $false
			foreach ($candidate in $lastSnapshot) {
				if ($owned.ContainsKey($candidate.pid) -or -not $owned.ContainsKey($candidate.parent_pid)) { continue }
				$created = Get-CreationUtc $candidate.creation_date
				$parent = $owned[$candidate.parent_pid]
				if ($null -ne $created -and $created -ge $parent.created_utc -and $created -le [DateTime]::UtcNow.AddSeconds(1) -and -not [string]::IsNullOrWhiteSpace($candidate.path)) {
					$owned[$candidate.pid] = [pscustomobject]@{
						pid = $candidate.pid; path = $candidate.path; command_line = $candidate.command_line
						created_utc = $created; parent_pid = $candidate.parent_pid; depth = $parent.depth + 1
					}
					$changed = $true
				}
			}
		}
		foreach ($identity in @($owned.Values | Sort-Object depth -Descending)) {
			$current = Get-ProcessSnapshot | Where-Object { $_.pid -eq $identity.pid } | Select-Object -First 1
			if (-not (Test-SameIdentity $identity $current)) {
				$killRecords.Add([pscustomobject]@{pid=$identity.pid;verified=$false;terminated=$false;reason="IDENTITY_CHANGED_OR_PROCESS_EXITED";expected_path=$identity.path;actual_path=if($current){$current.path}else{$null};expected_command_line=$identity.command_line;actual_command_line=if($current){$current.command_line}else{$null};expected_created_utc=$identity.created_utc.ToString("o");actual_created_utc=if($current -and (Get-CreationUtc $current.creation_date)){(Get-CreationUtc $current.creation_date).ToString("o")}else{$null}})
				continue
			}
			try {
				if ($identity.pid -eq $process.Id) { $process.Kill() }
				else {
					$child = [Diagnostics.Process]::GetProcessById($identity.pid)
					if ([math]::Abs(($child.StartTime.ToUniversalTime() - $identity.created_utc).TotalSeconds) -ge 1.0) { throw "Start time changed before termination." }
					$child.Kill()
				}
				$killRecords.Add([pscustomobject]@{pid=$identity.pid;verified=$true;terminated=$true;path=$identity.path;parent_pid=$identity.parent_pid;depth=$identity.depth})
			} catch {
				$killRecords.Add([pscustomobject]@{pid=$identity.pid;verified=$true;terminated=$false;path=$identity.path;reason=$_.Exception.Message})
			}
		}
		[void]$process.WaitForExit(3000)
		if (-not $process.HasExited -or @($killRecords | Where-Object { $_.verified -and -not $_.terminated }).Count -gt 0) {
			$status = "WATCHDOG_TERMINATION_INCOMPLETE"
			$reason = "ONE_OR_MORE_VERIFIED_TASK_PROCESSES_DID_NOT_TERMINATE"
		}
	}
} catch {
	$status = "ERROR"
	$reason = $_.Exception.Message
} finally {
	if ($stdoutTask -and $stdoutTask.IsCompleted) { try { $null = $stdoutTask.Result } catch {} }
	if ($stderrTask -and $stderrTask.IsCompleted) { try { $null = $stderrTask.Result } catch {} }
	try { Write-DurableResult } catch { Write-Error "Could not write durable watchdog result: $($_.Exception.Message)" }
	if ($process) { $process.Dispose() }
}

if ($status -eq "ERROR" -or $status -eq "WATCHDOG_TERMINATION_INCOMPLETE") { exit 2 }
if ($status -eq "CHILD_ERROR") { exit 1 }
if ($status -eq "TIMEOUT_TERMINATED") { exit 124 }
exit 0
