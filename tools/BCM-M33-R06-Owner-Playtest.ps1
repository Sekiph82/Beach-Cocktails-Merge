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

$profileRoot = Join-Path $env:LOCALAPPDATA 'BeachCocktailsMerge\M33-R06-OwnerPlaytest'
$testAppData = Join-Path $profileRoot 'appdata'
$normalUserData = Join-Path (Join-Path $env:APPDATA 'Godot\app_userdata') 'CocktailMerge'
New-Item -ItemType Directory -Force -Path $testAppData | Out-Null
$markerPath = Join-Path $profileRoot 'PROFILE_INFO.txt'
@("BCM-M33-R06 isolated owner playtest profile", "Godot: $versionText", "Project: $projectRoot", "Test APPDATA: $testAppData", "Normal user://: $normalUserData", "Created/used: $(Get-Date -Format o)") | Set-Content -LiteralPath $markerPath -Encoding utf8

$oldAppData = $env:APPDATA
$oldPlaytest = $env:BCM_M33_OWNER_PLAYTEST
$oldProfileRoot = $env:BCM_M33_TEST_PROFILE_ROOT
$oldNormalUserData = $env:BCM_M33_NORMAL_USER_DATA
try {
    $env:APPDATA = $testAppData
    $env:BCM_M33_OWNER_PLAYTEST = '1'
    $env:BCM_M33_TEST_PROFILE_ROOT = $profileRoot
    $env:BCM_M33_NORMAL_USER_DATA = $normalUserData
    Write-Host "Starting Beach Cocktails Merge owner playtest with Godot $versionText"
    Write-Host "Isolated profile: $profileRoot"
    Write-Host 'Campaign progression persistence is disabled in this mode.'
    & $godotExe --path $projectRoot --windowed
    if ($LASTEXITCODE -ne 0) {
        throw "Godot exited with code $LASTEXITCODE"
    }
}
finally {
    $env:APPDATA = $oldAppData
    $env:BCM_M33_OWNER_PLAYTEST = $oldPlaytest
    $env:BCM_M33_TEST_PROFILE_ROOT = $oldProfileRoot
    $env:BCM_M33_NORMAL_USER_DATA = $oldNormalUserData
}
