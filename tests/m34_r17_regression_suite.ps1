param([Parameter(Mandatory)][string]$EvidenceRoot,[string]$WatchdogTaskToken='')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Import-Module (Join-Path $repoRoot 'tools/campaign/m34_r17_pilot_integrity.psm1') -Force
$EvidenceRoot = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $EvidenceRoot).Path)
$manifestPath = Join-Path $EvidenceRoot 'attempt_manifest.jsonl'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'R17 append-only pilot manifest is required.' }
$runId = [guid]::NewGuid().ToString('N')
$validationId = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '_' + $runId
$validationDir = Join-Path $EvidenceRoot "regressions_$validationId"
if (Test-Path -LiteralPath $validationDir) { throw 'Regression output collision refused.' }
[IO.Directory]::CreateDirectory($validationDir) | Out-Null
$appDataRoot = Join-Path $validationDir 'isolated_userdata'
$roamingPath = Join-Path $appDataRoot 'Roaming'
$localPath = Join-Path $appDataRoot 'Local'
[IO.Directory]::CreateDirectory($roamingPath) | Out-Null
[IO.Directory]::CreateDirectory($localPath) | Out-Null
$watchdog = Join-Path $repoRoot 'tools/campaign/m34_r14_process_watchdog.ps1'
$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$clock = [Diagnostics.Stopwatch]::StartNew()
$drive = [IO.Path]::GetPathRoot($env:TEMP).Substring(0,1)
$freeBefore = [long](Get-Volume -DriveLetter $drive).SizeRemaining
$tasksBefore = (git -C $repoRoot hash-object TASKS.md).Trim()
$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
$env:APPDATA = $roamingPath
$env:LOCALAPPDATA = $localPath
$results = [System.Collections.Generic.List[object]]::new()

function Get-RelativePath([string]$Path) { return [IO.Path]::GetRelativePath($EvidenceRoot,[IO.Path]::GetFullPath($Path)).Replace('\','/') }
function Invoke-R17WatchedProcess {
	param([string]$Name,[string[]]$Arguments,[int]$TimeoutSeconds)
	$resultPath = Join-Path $validationDir "$Name.watchdog.json"
	if (Test-Path -LiteralPath $resultPath) { throw "Regression evidence collision refused: $resultPath" }
	& $watchdog -FilePath $godot -ArgumentList $Arguments -TimeoutSeconds $TimeoutSeconds -ResultPath $resultPath -TaskName "BCM-M34-R17-REGRESSION-$validationId-$Name"
	$wdExit = $LASTEXITCODE
	if (-not (Test-Path -LiteralPath $resultPath -PathType Leaf)) { throw "Watchdog did not publish a result for $Name." }
	$watchdogData = Get-Content -Raw -LiteralPath $resultPath | ConvertFrom-Json
	$passed = $watchdogData.status -eq 'EXITED' -and $wdExit -eq 0
	$record = [ordered]@{name=$Name;status=[string]$watchdogData.status;exit_code=$wdExit;child_exit_code=$watchdogData.exit_code;reason=[string]$watchdogData.reason;wall_elapsed_ms=[int]$watchdogData.wall_elapsed_ms;timeout_seconds=$TimeoutSeconds;pass=$passed;watchdog_path=(Get-RelativePath $resultPath);watchdog_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $resultPath).Hash.ToLower()}
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='REGRESSION_RESULT';validation_id=$validationId;name=$Name;status=$record.status;pass=$passed;artifact_path=$record.watchdog_path;artifact_sha256=$record.watchdog_sha256})
	$results.Add($record)
	Write-Host "R17_REGRESSION name=$Name status=$($record.status) exit=$wdExit wall_ms=$($record.wall_elapsed_ms) pass=$passed"
	return $record
}

try {
	Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='REGRESSION_STARTED';validation_id=$validationId;validation_path=(Get-RelativePath $validationDir);started_utc=[DateTime]::UtcNow.ToString('o');appdata_isolated=$true})
	$import = Invoke-R17WatchedProcess -Name 'fresh_editor_import' -Arguments @('--headless','--editor','--path',$repoRoot,'--quit') -TimeoutSeconds 120
	if (-not $import.pass) { Write-Host 'R17 regression probes stopped because fresh editor import did not exit successfully.' }
	else {
		$testSpecs = @(
			[pscustomobject]@{name='economy_35';timeout=60;args=@('--headless','--path',$repoRoot,'--script',(Join-Path $repoRoot 'tests/m34_economy_closure_probe.gd'))},
			[pscustomobject]@{name='daily_38';timeout=60;args=@('--headless','--path',$repoRoot,'--script',(Join-Path $repoRoot 'tests/m34_daily_rewards_probe.gd'))},
			[pscustomobject]@{name='navigation_17';timeout=180;args=@('--headless','--path',$repoRoot,'--script',(Join-Path $repoRoot 'tests/m33_campaign_navigation_probe.gd'))},
			[pscustomobject]@{name='m14_bridge_66';timeout=60;args=@('--headless','--path',$repoRoot,'--script',(Join-Path $repoRoot 'tests/m14_gameplay_session_bridge_probe.gd'))},
			[pscustomobject]@{name='m15_vip_economy_63';timeout=60;args=@('--headless','--path',$repoRoot,'--script',(Join-Path $repoRoot 'tests/m15_vip_boosters_economy_probe.gd'))},
			[pscustomobject]@{name='production_routes';timeout=60;args=@('--headless','--path',$repoRoot,'--script',(Join-Path $repoRoot 'tests/m34_production_routes_probe.gd'))},
			[pscustomobject]@{name='scene_uid';timeout=60;args=@('--headless','--path',$repoRoot,'--script',(Join-Path $repoRoot 'tests/m34_r10_scene_uid_probe.gd'))},
			[pscustomobject]@{name='slim_content';timeout=60;args=@('--headless','--path',$repoRoot,'--script',(Join-Path $repoRoot 'tests/m34_r09_slim_export_content_probe.gd'))},
			[pscustomobject]@{name='vip_optional';timeout=60;args=@('--headless','--path',$repoRoot,'--script',(Join-Path $repoRoot 'tests/m34_r10_vip_optional_rule_probe.gd'))},
			[pscustomobject]@{name='startup_smoke';timeout=60;args=@('--headless','--path',$repoRoot,'--quit-after','3')}
		)
		foreach ($test in $testSpecs) {
			$null = Invoke-R17WatchedProcess -Name $test.name -Arguments $test.args -TimeoutSeconds $test.timeout
		}
	}
} finally {
	$env:APPDATA = $oldAppData
	$env:LOCALAPPDATA = $oldLocalAppData
}
$tasksAfter = (git -C $repoRoot hash-object TASKS.md).Trim()
$freeAfter = [long](Get-Volume -DriveLetter $drive).SizeRemaining
$testResults = @($results | Where-Object { $_.name -ne 'fresh_editor_import' })
$passedCount = @($testResults | Where-Object pass).Count
$allPass = $import.pass -and $passedCount -eq 10
$summary = [ordered]@{
	schema_version=1;work_item='BCM-M34-R17';validation_id=$validationId;status=if($allPass){'ALL_REQUESTED_REGRESSIONS_PASS'}else{'REGRESSION_FAILURE_OR_INCOMPLETE'}
	appdata_isolated=$true;isolated_appdata_path=(Get-RelativePath $appDataRoot);isolated_appdata_bytes=(Get-ChildItem -LiteralPath $appDataRoot -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
	disk_free_before=$freeBefore;disk_free_after=$freeAfter;disk_free_delta_bytes=($freeAfter-$freeBefore);actual_controller_elapsed_ms=[int]$clock.Elapsed.TotalMilliseconds
	tasks_blob_before=$tasksBefore;tasks_blob_after=$tasksAfter;tasks_unchanged=($tasksBefore -ceq $tasksAfter)
	import=$import;tests=$testResults;passed_tests=$passedCount;total_tests=10
}
$summaryPath = Publish-R17UniqueJson -Path (Join-Path $validationDir 'regression_summary.json') -Value $summary
$summarySha = (Get-FileHash -Algorithm SHA256 -LiteralPath $summaryPath).Hash.ToLower()
Add-R17ManifestEvent -ManifestPath $manifestPath -Event ([ordered]@{event_id=[guid]::NewGuid().ToString('N');event_type='REGRESSION_FINISHED';validation_id=$validationId;status=$summary.status;summary_path=(Get-RelativePath $summaryPath);summary_sha256=$summarySha;finished_utc=[DateTime]::UtcNow.ToString('o')})
Write-Output "R17_REGRESSION_SUMMARY=$($summary.status) passed=$passedCount/10 import=$($import.status) disk_delta=$($freeAfter-$freeBefore) tasks_unchanged=$($summary.tasks_unchanged)"
if (-not $summary.tasks_unchanged -or -not $allPass) { exit 1 }
