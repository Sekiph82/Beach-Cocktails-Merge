param(
    [Parameter(Mandatory = $true)][string]$GodotPath,
    [Parameter(Mandatory = $true)][string]$ProjectPath,
    [Parameter(Mandatory = $true)][string[]]$GodotArguments,
    [Parameter(Mandatory = $true)][string]$OutputPrefix,
    [ValidateRange(1, 3600)][int]$TimeoutSeconds = 180
)

$ErrorActionPreference = 'Stop'
$resolvedProject = [System.IO.Path]::GetFullPath($ProjectPath).TrimEnd('\')
$resolvedGodot = (Resolve-Path -LiteralPath $GodotPath).Path
$stdoutPath = "$OutputPrefix.stdout.txt"
$stderrPath = "$OutputPrefix.stderr.txt"
$resultPath = "$OutputPrefix.result.json"
$taskPids = [System.Collections.Generic.HashSet[int]]::new()
$startUtc = [DateTime]::UtcNow
$exitCode = $null
$timedOut = $false
$failure = $null

function Get-TaskProcessInventory {
    $all = @(Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -and [IO.Path]::GetFileName($_.ExecutablePath) -match '^godot(_console)?\.exe$' })
    $matches = @($all | Where-Object { $_.CommandLine -and $_.CommandLine.IndexOf($resolvedProject, [StringComparison]::OrdinalIgnoreCase) -ge 0 })
    return @{ All = $all; Matches = $matches }
}

function Add-TaskProcessTree {
    $inventory = @(Get-CimInstance Win32_Process)
    $known = [System.Collections.Generic.HashSet[int]]::new($taskPids)
    $changed = $true
    while ($changed) {
        $changed = $false
        foreach ($process in $inventory) {
            $pidValue = [int]$process.ProcessId
            $parentValue = [int]$process.ParentProcessId
            if ($known.Contains($parentValue) -and $known.Add($pidValue)) {
                [void]$taskPids.Add($pidValue)
                $changed = $true
            }
        }
    }
}

function Stop-TrackedProcesses {
    Add-TaskProcessTree
    foreach ($pidValue in @($taskPids)) {
        try {
            $proc = Get-Process -Id $pidValue -ErrorAction Stop
            if (-not $proc.HasExited) { [void]$proc.CloseMainWindow() }
        } catch { }
    }
    $graceDeadline = [DateTime]::UtcNow.AddSeconds(5)
    do {
        Add-TaskProcessTree
        $alive = @($taskPids | Where-Object { Get-Process -Id $_ -ErrorAction SilentlyContinue })
        if ($alive.Count -eq 0) { break }
        Start-Sleep -Milliseconds 200
    } while ([DateTime]::UtcNow -lt $graceDeadline)

    Add-TaskProcessTree
    foreach ($pidValue in @($taskPids)) {
        try {
            $proc = Get-Process -Id $pidValue -ErrorAction Stop
            if (-not $proc.HasExited) {
                $cim = Get-CimInstance Win32_Process -Filter "ProcessId = $pidValue" -ErrorAction Stop
                $isTaskGodot = $cim.ExecutablePath -and [IO.Path]::GetFileName($cim.ExecutablePath) -match '^godot(_console)?\.exe$' -and $cim.CommandLine.IndexOf($resolvedProject, [StringComparison]::OrdinalIgnoreCase) -ge 0
                $isTrackedChild = $pidValue -ne $process.Id -and [int]$cim.ParentProcessId -in @($taskPids)
                if ($isTaskGodot -or $isTrackedChild) { Stop-Process -Id $pidValue -Force -ErrorAction Stop }
            }
        } catch { }
    }
}

try {
    if (-not (Test-Path -LiteralPath $resolvedProject -PathType Container)) { throw "Project path missing: $resolvedProject" }
    $before = Get-TaskProcessInventory
    if ($before.Matches.Count -ne 0) { throw "Refusing launch: $($before.Matches.Count) Godot process(es) already match this exact project path." }
    $argumentList = @($GodotArguments | ForEach-Object { if ($_ -match '\s') { '"' + $_.Replace('"', '\"') + '"' } else { $_ } })
    $process = Start-Process -FilePath $resolvedGodot -ArgumentList $argumentList -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
    [void]$taskPids.Add([int]$process.Id)
    $rootCim = $null
    for ($attempt = 0; $attempt -lt 30 -and -not $rootCim; $attempt++) {
        $rootCim = Get-CimInstance Win32_Process -Filter "ProcessId = $($process.Id)" -ErrorAction SilentlyContinue
        if (-not $rootCim) { Start-Sleep -Milliseconds 100 }
    }
    if (-not $rootCim -or -not $rootCim.CommandLine -or $rootCim.CommandLine.IndexOf($resolvedProject, [StringComparison]::OrdinalIgnoreCase) -lt 0) {
        throw "Launched PID $($process.Id) could not be verified against the exact sandbox command line."
    }
    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    while (-not $process.HasExited -and [DateTime]::UtcNow -lt $deadline) {
        Add-TaskProcessTree
        Start-Sleep -Milliseconds 200
        $process.Refresh()
    }
    if (-not $process.HasExited) {
        $timedOut = $true
        throw "Godot timed out after $TimeoutSeconds seconds."
    }
    $process.Refresh()
    $exitCode = $process.ExitCode
} catch {
    $failure = $_.Exception.Message
} finally {
    if ($taskPids.Count -gt 0) { Stop-TrackedProcesses }
    $after = Get-TaskProcessInventory
    $matchingAfter = @($after.Matches | ForEach-Object { [int]$_.ProcessId })
    $record = [ordered]@{
        started_utc = $startUtc.ToString('o')
        finished_utc = [DateTime]::UtcNow.ToString('o')
        project_path = $resolvedProject
        executable = $resolvedGodot
        arguments = $GodotArguments
        spawned_pids = @($taskPids | Sort-Object)
        exit_code = $exitCode
        timed_out = $timedOut
        failure = $failure
        matching_godot_pids_after_cleanup = $matchingAfter
        cleanup_verified = ($matchingAfter.Count -eq 0)
        stdout_path = [IO.Path]::GetFullPath($stdoutPath)
        stderr_path = [IO.Path]::GetFullPath($stderrPath)
    }
    $record | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $resultPath -Encoding utf8
}

if ($failure) { Write-Error $failure }
if (-not $record.cleanup_verified) { throw "Cleanup exit gate failed: matching Godot PIDs remain: $($record.matching_godot_pids_after_cleanup -join ',')" }
if ($exitCode -ne 0) { throw "Godot exited with code $exitCode." }
Get-Content -LiteralPath $resultPath -Raw
