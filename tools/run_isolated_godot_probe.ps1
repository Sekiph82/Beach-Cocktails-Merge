[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$Probe,
	[ValidateRange(10, 3600)][int]$TimeoutSeconds = 240
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$testsRoot = (Resolve-Path (Join-Path $projectRoot 'tests')).Path.TrimEnd('\') + '\'
$probePath = [IO.Path]::GetFullPath((Join-Path $projectRoot $Probe))
if (-not $probePath.StartsWith($testsRoot, [StringComparison]::OrdinalIgnoreCase) -or
	-not $probePath.EndsWith('.gd', [StringComparison]::OrdinalIgnoreCase) -or
	-not (Test-Path -LiteralPath $probePath -PathType Leaf)) {
	throw 'Probe must be an existing .gd script inside the project tests directory.'
}

$godotCommand = Get-Command godot_console.exe -ErrorAction SilentlyContinue
if ($null -eq $godotCommand) { $godotCommand = Get-Command godot.exe -ErrorAction SilentlyContinue }
if ($null -eq $godotCommand) { throw 'Godot console executable was not found; no probe was started.' }
$godot = $godotCommand.Source
$sandboxRoot = Join-Path $projectRoot '.godot\bcm_sandboxes'
New-Item -ItemType Directory -Force -Path $sandboxRoot | Out-Null
$sandbox = Join-Path $sandboxRoot ('manual_' + [Guid]::NewGuid().ToString('N'))
if (Test-Path -LiteralPath $sandbox) { throw 'Generated sandbox already exists; refusing to reuse it.' }
$appData = Join-Path $sandbox 'r'
$localAppData = Join-Path $sandbox 'l'
New-Item -ItemType Directory -Path $appData,$localAppData | Out-Null
$userData = Join-Path $appData 'Godot\app_userdata\CocktailMerge'
New-Item -ItemType Directory -Force -Path $userData | Out-Null
'{"schema_version":1,"current_step":6,"completed":true}' | Set-Content -LiteralPath (Join-Path $userData 'gameplay_tutorial_state.json') -Encoding utf8

$resolvedSandboxRoot = [IO.Path]::GetFullPath($sandboxRoot).TrimEnd('\') + '\'
if (-not ([IO.Path]::GetFullPath($sandbox).StartsWith($resolvedSandboxRoot, [StringComparison]::OrdinalIgnoreCase))) {
	throw 'Resolved test profile is not inside the canonical project sandbox.'
}

$envNames = @('APPDATA','LOCALAPPDATA','BCM_TEST_MODE','BCM_TEST_SANDBOX_ROOT','BCM_TEST_BUILD_MARKER')
$oldEnvironment = @{}
foreach ($name in $envNames) { $oldEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }
$relativeProbe = [IO.Path]::GetRelativePath($projectRoot, $probePath).Replace('\','/')
$exitCode = 1
try {
	$env:APPDATA = $appData
	$env:LOCALAPPDATA = $localAppData
	$env:BCM_TEST_MODE = '1'
	$env:BCM_TEST_SANDBOX_ROOT = $sandbox
	$env:BCM_TEST_BUILD_MARKER = 'NONSHIPPING_LOCAL_TEST'
	$start = [Diagnostics.ProcessStartInfo]::new()
	$start.FileName = $godot
	$start.WorkingDirectory = $projectRoot
	$start.UseShellExecute = $false
	$start.RedirectStandardOutput = $true
	$start.RedirectStandardError = $true
	foreach ($argument in @('--headless','--path',$projectRoot,'--script',"res://$relativeProbe")) { [void]$start.ArgumentList.Add($argument) }
	$process = [Diagnostics.Process]::Start($start)
	$stdoutTask = $process.StandardOutput.ReadToEndAsync()
	$stderrTask = $process.StandardError.ReadToEndAsync()
	if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
		$process.Kill($true)
		$process.WaitForExit()
		Write-Output $stdoutTask.Result
		Write-Output $stderrTask.Result
		$exitCode = 124
	}
	else {
		Write-Output $stdoutTask.Result
		Write-Output $stderrTask.Result
		$exitCode = $process.ExitCode
	}
}
finally {
	foreach ($name in $envNames) {
		if ($null -eq $oldEnvironment[$name]) { [Environment]::SetEnvironmentVariable($name, $null, 'Process') }
		else { [Environment]::SetEnvironmentVariable($name, $oldEnvironment[$name], 'Process') }
	}
}

function Get-Sha256OrAbsent([string]$Path) {
	if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return 'ABSENT' }
	return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}
Write-Output "PROBE_EXIT_CODE=$exitCode"
Write-Output "TEST_SANDBOX=$sandbox"
Write-Output "ISOLATED_USER_DATA=$userData"
Write-Output "CAMPAIGN_SAVE_SHA256=$(Get-Sha256OrAbsent (Join-Path $userData 'campaign_save.json'))"
Write-Output "CAMPAIGN_SAVE_BACKUP_SHA256=$(Get-Sha256OrAbsent (Join-Path $userData 'campaign_save.json.bak'))"
if ($exitCode -ne 0) { exit $exitCode }
