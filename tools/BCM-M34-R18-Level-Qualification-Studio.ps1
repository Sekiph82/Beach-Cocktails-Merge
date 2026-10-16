[CmdletBinding()]
param(
    [switch]$ValidateOnly,
    [switch]$HeadlessCheck
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$projectFile = Join-Path $projectRoot 'project.godot'
if (-not (Test-Path -LiteralPath $projectFile -PathType Leaf)) {
    throw "Project entry point not found: $projectFile"
}

$godotCommand = Get-Command godot_console.exe -ErrorAction SilentlyContinue
if ($null -eq $godotCommand) { $godotCommand = Get-Command godot.exe -ErrorAction SilentlyContinue }
if ($null -eq $godotCommand) {
    $knownPaths = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\godot_console.exe'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\godot.exe'),
        (Join-Path $env:ProgramFiles 'Godot\Godot_v4.7.2-stable_win64_console.exe')
    )
    $knownExe = $knownPaths | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if ($knownExe) { $godotCommand = Get-Item -LiteralPath $knownExe }
}
if ($null -eq $godotCommand) {
    throw 'Godot 4.7.2 was not found. Install the project-required Godot 4.7.2 application.'
}
$godotExe = if ($godotCommand -is [System.IO.FileInfo]) { $godotCommand.FullName } else { $godotCommand.Source }
$versionText = (& $godotExe --version 2>&1 | Out-String).Trim()
if ($versionText -notmatch '^4\.7\.2(?:\.|$)') {
    throw "This Studio requires Godot 4.7.2; found '$versionText' at '$godotExe'."
}
if ($ValidateOnly) {
    Write-Host "LAUNCHER_VALIDATION=PASS Godot=$versionText Project=$projectRoot"
    exit 0
}

$profileRoot = Join-Path $env:LOCALAPPDATA 'BeachCocktailsMerge\M34-R18-LevelQualificationStudio'
$testAppData = Join-Path $profileRoot 'appdata'
$normalUserData = Join-Path (Join-Path $env:APPDATA 'Godot\app_userdata') 'CocktailMerge'
New-Item -ItemType Directory -Force -Path $testAppData | Out-Null
$oldValues = @{
    APPDATA = $env:APPDATA
    BCM_M33_OWNER_PLAYTEST = $env:BCM_M33_OWNER_PLAYTEST
    BCM_M34_R18_STUDIO = $env:BCM_M34_R18_STUDIO
    BCM_M34_R18_PROFILE_ROOT = $env:BCM_M34_R18_PROFILE_ROOT
    BCM_M34_R18_NORMAL_USER_DATA = $env:BCM_M34_R18_NORMAL_USER_DATA
}
try {
    $env:APPDATA = $testAppData
    $env:BCM_M33_OWNER_PLAYTEST = '1'
    $env:BCM_M34_R18_STUDIO = '1'
    $env:BCM_M34_R18_PROFILE_ROOT = $profileRoot
    $env:BCM_M34_R18_NORMAL_USER_DATA = $normalUserData
    if ($HeadlessCheck) {
        Write-Host "RUN=Godot R18 focused headless contract probe; profile=$profileRoot"
        & $godotExe --path $projectRoot --headless --script (Join-Path $projectRoot 'tests\m34_r18_level_qualification_studio_probe.gd')
        $resultCode = $LASTEXITCODE
        if ($resultCode -ne 0) { throw "R18 headless probe failed with exit code $resultCode" }
        Write-Host 'R18_HEADLESS_PROBE=PASS'
    } else {
        Write-Host "Starting the development-only Level Qualification Studio with Godot $versionText"
        Write-Host "Project: $projectRoot"
        Write-Host "Isolated user profile: $profileRoot"
        Write-Host 'Normal campaign save and economy persistence are disabled in this Studio.'
        & $godotExe --path $projectRoot --scene 'res://scenes/debug/LevelQualificationStudio.tscn' --windowed
        $resultCode = $LASTEXITCODE
        if ($resultCode -ne 0) { throw "Godot exited with code $resultCode" }
    }
}
finally {
    $env:APPDATA = $oldValues.APPDATA
    $env:BCM_M33_OWNER_PLAYTEST = $oldValues.BCM_M33_OWNER_PLAYTEST
    $env:BCM_M34_R18_STUDIO = $oldValues.BCM_M34_R18_STUDIO
    $env:BCM_M34_R18_PROFILE_ROOT = $oldValues.BCM_M34_R18_PROFILE_ROOT
    $env:BCM_M34_R18_NORMAL_USER_DATA = $oldValues.BCM_M34_R18_NORMAL_USER_DATA
}
