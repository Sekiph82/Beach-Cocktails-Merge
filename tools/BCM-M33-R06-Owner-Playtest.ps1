[CmdletBinding()]
param([switch]$ValidateOnly)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$projectFile = Join-Path $projectRoot 'project.godot'
if (-not (Test-Path -LiteralPath $projectFile -PathType Leaf)) {
    throw "Project entry point not found: $projectFile"
}

$godotCommand = Get-Command godot_console.exe -ErrorAction SilentlyContinue
if ($null -eq $godotCommand) {
    $godotCommand = Get-Command godot.exe -ErrorAction SilentlyContinue
}
if ($null -eq $godotCommand) {
    $knownPaths = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\godot_console.exe'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\godot.exe'),
        (Join-Path $env:ProgramFiles 'Godot\Godot_v4.7.2-stable_win64_console.exe')
    )
    $knownExe = $knownPaths | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if ($knownExe) {
        $godotCommand = Get-Item -LiteralPath $knownExe
    }
}
if ($null -eq $godotCommand) {
    throw 'Godot 4.7.2 was not found. Install the project-required Godot 4.7.2 application, then double-click this launcher again.'
}
$godotExe = if ($godotCommand -is [System.IO.FileInfo]) { $godotCommand.FullName } else { $godotCommand.Source }
$versionText = (& $godotExe --version 2>&1 | Out-String).Trim()
if ($versionText -notmatch '^4\.7\.2(?:\.|$)') {
    throw "This playtest requires Godot 4.7.2; found '$versionText' at '$godotExe'. No project was launched."
}

if ($ValidateOnly) {
    Write-Host "LAUNCHER_VALIDATION=PASS Godot=$versionText Executable=$godotExe Project=$projectRoot"
    exit 0
}

$profileRoot = Join-Path (Join-Path $projectRoot '.godot\bcm_sandboxes') ('m33_r06_ownerplaytest_' + [Guid]::NewGuid().ToString('N'))
$testAppData = Join-Path $profileRoot 'r'
$testLocalAppData = Join-Path $profileRoot 'l'
$testUserData = Join-Path $testAppData 'Godot\app_userdata\CocktailMerge'
New-Item -ItemType Directory -Path $profileRoot,$testAppData,$testLocalAppData | Out-Null
New-Item -ItemType Directory -Force -Path $testUserData | Out-Null
$markerPath = Join-Path $profileRoot 'PROFILE_INFO.txt'
@("BCM-M33-R06 isolated owner playtest profile", "Godot: $versionText", "Project: $projectRoot", "Test APPDATA: $testAppData", "Test LOCALAPPDATA: $testLocalAppData", "Owner user data: not accessed", "Created/used: $(Get-Date -Format o)") | Set-Content -LiteralPath $markerPath -Encoding utf8

$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
$oldPlaytest = $env:BCM_M33_OWNER_PLAYTEST
$oldProfileRoot = $env:BCM_M33_TEST_PROFILE_ROOT
$oldNormalUserData = $env:BCM_M33_NORMAL_USER_DATA
$oldTestMode = $env:BCM_TEST_MODE
$oldSandboxRoot = $env:BCM_TEST_SANDBOX_ROOT
$oldBuildMarker = $env:BCM_TEST_BUILD_MARKER
try {
    $env:APPDATA = $testAppData
    $env:LOCALAPPDATA = $testLocalAppData
    $env:BCM_M33_OWNER_PLAYTEST = '1'
    $env:BCM_M33_TEST_PROFILE_ROOT = $testUserData
    $env:BCM_M33_NORMAL_USER_DATA = '__owner_user_data_not_accessed__'
    $env:BCM_TEST_MODE = '1'
    $env:BCM_TEST_SANDBOX_ROOT = $profileRoot
    $env:BCM_TEST_BUILD_MARKER = 'NONSHIPPING_LOCAL_TEST'
    Write-Host "Starting Beach Cocktails Merge owner playtest with Godot $versionText"
    Write-Host "Isolated profile: $profileRoot"
    Write-Host 'Campaign progression persistence is disabled in this mode.'
    & $godotExe --path $projectRoot --windowed
    if ($LASTEXITCODE -ne 0) {
        throw "Godot exited with code $LASTEXITCODE"
    }
}
finally {
    foreach ($entry in @(
        @{ name = 'APPDATA'; value = $oldAppData },
        @{ name = 'LOCALAPPDATA'; value = $oldLocalAppData },
        @{ name = 'BCM_M33_OWNER_PLAYTEST'; value = $oldPlaytest },
        @{ name = 'BCM_M33_TEST_PROFILE_ROOT'; value = $oldProfileRoot },
        @{ name = 'BCM_M33_NORMAL_USER_DATA'; value = $oldNormalUserData },
        @{ name = 'BCM_TEST_MODE'; value = $oldTestMode },
        @{ name = 'BCM_TEST_SANDBOX_ROOT'; value = $oldSandboxRoot },
        @{ name = 'BCM_TEST_BUILD_MARKER'; value = $oldBuildMarker }
    )) {
        if ($null -eq $entry.value) { [Environment]::SetEnvironmentVariable($entry.name, $null, 'Process') }
        else { [Environment]::SetEnvironmentVariable($entry.name, $entry.value, 'Process') }
    }
}
