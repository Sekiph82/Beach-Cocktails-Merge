param(
    [Parameter(Mandatory = $true)][string]$GodotPath,
    [Parameter(Mandatory = $true)][string]$ProjectPath,
    [Parameter(Mandatory = $true)][string[]]$GodotArguments,
    [Parameter(Mandatory = $true)][string]$OutputPrefix,
    [Parameter(Mandatory = $true)][string]$PreflightManifest,
    [Parameter(Mandatory = $true)][string]$StageLogBackup,
    [switch]$ExpectExistingSandboxUserData,
    [switch]$AllowEditorAfterIsolationGate,
    [ValidateRange(1, 3600)][int]$TimeoutSeconds = 180
)

$ErrorActionPreference = 'Stop'
$sandboxName = 'BCM-M27-MASTER-V01-20261010-Sandbox'
$resolvedProject = [IO.Path]::GetFullPath($ProjectPath).TrimEnd('\')
$manifestPath = (Resolve-Path -LiteralPath $PreflightManifest).Path
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$sandboxAppData = [Environment]::GetFolderPath([Environment+SpecialFolder]::ApplicationData)
$ownerRoot = Join-Path $sandboxAppData 'Godot\app_userdata\CocktailMerge'
$expectedRoot = Join-Path (Join-Path $sandboxAppData 'Godot\app_userdata') $sandboxName
$expectedLog = Join-Path $expectedRoot 'logs\godot.log'
$runnerPath = Join-Path $resolvedProject 'tests\m26_001_r01_godot_runner.ps1'
$resolvedBackup = [IO.Path]::GetFullPath($StageLogBackup).TrimEnd('\')

function Get-OwnerTreeSnapshot {
    $directories = @(Get-ChildItem -LiteralPath $ownerRoot -Recurse -Directory | ForEach-Object { $_.FullName.Substring($ownerRoot.Length).TrimStart('\') } | Sort-Object)
    $files = @(Get-ChildItem -LiteralPath $ownerRoot -Recurse -File | ForEach-Object {
        $hash = Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256
        [ordered]@{ relative_path = $_.FullName.Substring($ownerRoot.Length).TrimStart('\'); length = $_.Length; sha256 = $hash.Hash }
    } | Sort-Object { $_.relative_path })
    return @{ directories = $directories; files = $files }
}

function Assert-OwnerTreeUnchanged([string]$phase) {
    $current = Get-OwnerTreeSnapshot
    $expectedDirs = @($manifest.owner_userdata_directories | Sort-Object)
    $expectedFiles = @($manifest.owner_userdata_files | Sort-Object { $_.relative_path })
    $currentDirs = @($current.directories | Sort-Object)
    $expectedRows = @($expectedFiles | ForEach-Object { '{0}`t{1}`t{2}' -f $_.relative_path, $_.length, $_.sha256 })
    $currentRows = @($current.files | ForEach-Object { '{0}`t{1}`t{2}' -f $_.relative_path, $_.length, $_.sha256 })
    $dirsMatch = $expectedDirs.Count -eq $currentDirs.Count
    if ($dirsMatch) {
        for ($i = 0; $i -lt $expectedDirs.Count; $i++) {
            if ($expectedDirs[$i] -cne $currentDirs[$i]) { $dirsMatch = $false; break }
        }
    }
    $filesMatch = $expectedRows.Count -eq $currentRows.Count
    if ($filesMatch) {
        for ($i = 0; $i -lt $expectedRows.Count; $i++) {
            if ($expectedRows[$i] -cne $currentRows[$i]) { $filesMatch = $false; break }
        }
    }
    if (-not $dirsMatch -or -not $filesMatch) {
        throw "Owner user-data tree changed or could not be proven byte-identical at phase '$phase'."
    }
}

if ($manifest.result -and $manifest.result -ne 'OWNER_USERDATA_INTEGRITY_BLOCKER') { throw 'Unexpected incident manifest result.' }
if ($manifest.sandbox_name -and $manifest.sandbox_name -ne $sandboxName) { throw 'Preflight sandbox identity does not match runner identity.' }
if ($manifest.sandbox_userdata_root -and [IO.Path]::GetFullPath($manifest.sandbox_userdata_root).TrimEnd('\') -ine [IO.Path]::GetFullPath($expectedRoot).TrimEnd('\')) { throw 'Preflight and resolved Windows user-data paths disagree.' }
if ([IO.Path]::GetFullPath($ownerRoot).TrimEnd('\') -ieq [IO.Path]::GetFullPath($expectedRoot).TrimEnd('\')) { throw 'Sandbox user-data path resolves to owner data.' }
if ([IO.Path]::GetFullPath($expectedRoot).StartsWith([IO.Path]::GetFullPath($ownerRoot).TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Sandbox user-data path is nested under owner data.' }
if ($resolvedProject -ine [IO.Path]::GetFullPath($manifest.sandbox_project).TrimEnd('\')) { throw 'Project path differs from the verified M27 sandbox path.' }
$projectFile = Join-Path $resolvedProject 'project.godot'
$nameMatches = @(Select-String -LiteralPath $projectFile -Pattern '^config/name="([^"]+)"$')
if ($nameMatches.Count -ne 1 -or $nameMatches[0].Matches[0].Groups[1].Value -cne $sandboxName) { throw 'Sandbox config/name is missing, duplicated, or not the unique M27 identity.' }
if (-not (Test-Path -LiteralPath $runnerPath -PathType Leaf)) { throw 'Verified M26 PID-tracking runner is missing.' }
if (-not (Test-Path -LiteralPath $StageLogBackup -PathType Container)) { throw 'Per-stage owner-log backup is missing.' }
if (-not (Test-Path -LiteralPath (Join-Path $resolvedBackup 'logs') -PathType Container)) { throw 'Per-stage backup has no logs directory.' }
if ($GodotArguments -notcontains '--path') { throw 'Refusing Godot launch without an explicit sandbox --path.' }
$pathIndex = [Array]::IndexOf($GodotArguments, '--path')
if ($pathIndex -lt 0 -or $pathIndex + 1 -ge $GodotArguments.Count -or [IO.Path]::GetFullPath($GodotArguments[$pathIndex + 1]).TrimEnd('\') -ine $resolvedProject) { throw 'Godot arguments do not point to the verified sandbox.' }
if ($GodotArguments -contains '--editor') {
    $gatePath = Join-Path (Split-Path -Parent $OutputPrefix) 'isolation_probe_20261010.guard.json'
    if (-not $AllowEditorAfterIsolationGate -or -not (Test-Path -LiteralPath $gatePath -PathType Leaf)) { throw 'The isolation gate permits no editor launch before the minimal identity probe passes.' }
    $gate = Get-Content -LiteralPath $gatePath -Raw | ConvertFrom-Json
    if ($gate.result -ne 'PASS' -or [IO.Path]::GetFullPath($gate.expected_user_data_dir).TrimEnd('\') -ine [IO.Path]::GetFullPath($expectedRoot).TrimEnd('\') -or -not $gate.owner_userdata_byte_hash_and_directory_parity) { throw 'Editor launch gate proof is missing, mismatched, or failed.' }
}
if (Test-Path -LiteralPath $ownerRoot) { Assert-OwnerTreeUnchanged 'pre-launch' }
$sandboxExists = Test-Path -LiteralPath $expectedRoot
if ($ExpectExistingSandboxUserData -and -not $sandboxExists) { throw 'Expected existing sandbox user-data directory is missing.' }
if (-not $ExpectExistingSandboxUserData -and $sandboxExists) { throw 'Expected pristine sandbox user-data directory already exists.' }
$ownerLogs = @(Get-ChildItem -LiteralPath (Join-Path $ownerRoot 'logs') -Recurse -File | ForEach-Object { $_.FullName.Substring((Join-Path $ownerRoot 'logs').Length).TrimStart('\') } | Sort-Object)
$backupLogs = @(Get-ChildItem -LiteralPath (Join-Path $resolvedBackup 'logs') -Recurse -File | ForEach-Object { $_.FullName.Substring((Join-Path $resolvedBackup 'logs').Length).TrimStart('\') } | Sort-Object)
if ((ConvertTo-Json -InputObject $ownerLogs -Compress) -cne (ConvertTo-Json -InputObject $backupLogs -Compress)) { throw 'Per-stage backup log file list differs from the current owner log directory.' }
foreach ($relative in $ownerLogs) {
    $source = Join-Path (Join-Path $ownerRoot 'logs') $relative
    $backup = Join-Path (Join-Path $resolvedBackup 'logs') $relative
    if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -cne (Get-FileHash -LiteralPath $backup -Algorithm SHA256).Hash) { throw "Per-stage backup is not byte-identical: $relative" }
}

$oldExpected = $env:BCM_M27_EXPECTED_USER_DATA_DIR
$env:BCM_M27_EXPECTED_USER_DATA_DIR = [IO.Path]::GetFullPath($expectedRoot)
$innerPrefix = "$OutputPrefix.runner"
try {
    & $runnerPath -GodotPath $GodotPath -ProjectPath $resolvedProject -GodotArguments $GodotArguments -OutputPrefix $innerPrefix -TimeoutSeconds $TimeoutSeconds | Out-Null
} finally {
    if ($null -eq $oldExpected) { Remove-Item Env:BCM_M27_EXPECTED_USER_DATA_DIR -ErrorAction SilentlyContinue } else { $env:BCM_M27_EXPECTED_USER_DATA_DIR = $oldExpected }
}
$runnerRecordPath = "$innerPrefix.result.json"
if (-not (Test-Path -LiteralPath $runnerRecordPath -PathType Leaf)) { throw 'PID-tracking runner produced no result record.' }
$runnerRecord = Get-Content -LiteralPath $runnerRecordPath -Raw | ConvertFrom-Json
if ($runnerRecord.exit_code -ne 0 -or -not $runnerRecord.cleanup_verified -or @($runnerRecord.matching_godot_pids_after_cleanup).Count -ne 0) { throw 'PID-tracking runner failed or did not verify sandbox process cleanup.' }
Assert-OwnerTreeUnchanged 'post-launch'
if (-not (Test-Path -LiteralPath $expectedRoot -PathType Container)) { throw 'Godot did not create the resolved sandbox user-data directory.' }
$logFiles = @(Get-ChildItem -LiteralPath (Join-Path $expectedRoot 'logs') -File -ErrorAction Stop | ForEach-Object { [ordered]@{ path = $_.FullName; length = $_.Length; sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash } })
if ($logFiles.Count -eq 0 -or -not ($logFiles.path -contains $expectedLog)) { throw "Godot did not write to the verified expected rotating log target: $expectedLog" }
$stdout = Get-Content -LiteralPath "$innerPrefix.stdout.txt" -Raw
if ($GodotArguments -contains 'res://tests/m27_user_data_isolation_probe.gd') {
    $trimChars = [char[]]@([char]13, [char]10, [char]92, [char]47)
    $actualUserData = [regex]::Match($stdout, '(?m)^M27_ISOLATION_USER_DATA=(.+)$').Groups[1].Value.TrimEnd($trimChars).Replace('/', '\')
    $actualOsData = [regex]::Match($stdout, '(?m)^M27_ISOLATION_OS_USER_DATA=(.+)$').Groups[1].Value.TrimEnd($trimChars).Replace('/', '\')
    if ([IO.Path]::GetFullPath($actualUserData).TrimEnd('\') -ine [IO.Path]::GetFullPath($expectedRoot).TrimEnd('\') -or [IO.Path]::GetFullPath($actualOsData).TrimEnd('\') -ine [IO.Path]::GetFullPath($expectedRoot).TrimEnd('\') -or $stdout -notmatch 'M27_ISOLATION_PROBE=PASS') { throw 'Minimal Godot probe did not independently confirm the actual OS user-data path.' }
}
$finalTree = Get-OwnerTreeSnapshot
$summary = [ordered]@{
    result = 'PASS'
    captured_utc = [DateTime]::UtcNow.ToString('o')
    project_path = $resolvedProject
    project_name = $sandboxName
    expected_user_data_dir = [IO.Path]::GetFullPath($expectedRoot)
    expected_log_target = [IO.Path]::GetFullPath($expectedLog)
    sandbox_log_files = $logFiles
    owner_userdata_file_count_before_after = @($manifest.owner_userdata_files).Count
    owner_userdata_files_after = @($finalTree.files).Count
    owner_userdata_directories_after = @($finalTree.directories).Count
    owner_userdata_byte_hash_and_directory_parity = $true
    owner_stage_log_backup = $resolvedBackup
    owner_stage_log_backup_verified = $true
    runner_result = $runnerRecordPath
    runner_exit_code = $runnerRecord.exit_code
    task_owned_process_cleanup_verified = $runnerRecord.cleanup_verified
    task_owned_processes_remaining = @($runnerRecord.matching_godot_pids_after_cleanup)
}
$summary | ConvertTo-Json -Depth 7 | Set-Content -LiteralPath "$OutputPrefix.guard.json" -Encoding utf8
Get-Content -LiteralPath "$OutputPrefix.guard.json" -Raw
