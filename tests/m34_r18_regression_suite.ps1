param([string]$EvidenceRoot = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($EvidenceRoot)) {
	$EvidenceRoot = Join-Path $repoRoot 'coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R18'
}
$EvidenceRoot = [IO.Path]::GetFullPath($EvidenceRoot)
[IO.Directory]::CreateDirectory($EvidenceRoot) | Out-Null
$runId = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '_' + [guid]::NewGuid().ToString('N')
$runDir = Join-Path $EvidenceRoot "regressions_$runId"
if (Test-Path -LiteralPath $runDir) { throw 'Regression evidence collision refused.' }
[IO.Directory]::CreateDirectory($runDir) | Out-Null
$profileRoot = Join-Path $env:LOCALAPPDATA 'BeachCocktailsMerge\M34-R18-Regression'
$roaming = Join-Path $profileRoot 'appdata'
$local = Join-Path $profileRoot 'localappdata'
[IO.Directory]::CreateDirectory($roaming) | Out-Null
[IO.Directory]::CreateDirectory($local) | Out-Null
$watchdog = Join-Path $repoRoot 'tools/campaign/m34_r14_process_watchdog.ps1'
$godotCommand = Get-Command godot_console.exe -ErrorAction SilentlyContinue
if ($null -eq $godotCommand) { $godotCommand = Get-Command godot.exe -ErrorAction Stop }
$godot = $godotCommand.Source
$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
$env:APPDATA = $roaming
$env:LOCALAPPDATA = $local
$tasksBefore = (git -C $repoRoot hash-object TASKS.md).Trim()
$results = [System.Collections.Generic.List[object]]::new()
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
try {
	$importPath = Join-Path $runDir 'fresh_editor_import.watchdog.json'
	& $watchdog -FilePath $godot -ArgumentList @('--headless','--editor','--path',$repoRoot,'--quit') -TimeoutSeconds 120 -ResultPath $importPath -TaskName "BCM-M34-R18-IMPORT-$runId"
	$importExit = $LASTEXITCODE
	$importData = Get-Content -Raw -LiteralPath $importPath | ConvertFrom-Json
	$importPass = $importData.status -eq 'EXITED' -and $importExit -eq 0
	if ($importPass) {
		foreach ($spec in $testSpecs) {
			$resultPath = Join-Path $runDir "$($spec.name).watchdog.json"
			& $watchdog -FilePath $godot -ArgumentList $spec.args -TimeoutSeconds $spec.timeout -ResultPath $resultPath -TaskName "BCM-M34-R18-$runId-$($spec.name)"
			$watchdogExit = $LASTEXITCODE
			$data = Get-Content -Raw -LiteralPath $resultPath | ConvertFrom-Json
			$pass = $data.status -eq 'EXITED' -and $watchdogExit -eq 0
			$results.Add([ordered]@{name=$spec.name;status=[string]$data.status;watchdog_exit=$watchdogExit;child_exit=$data.exit_code;reason=[string]$data.reason;wall_elapsed_ms=[int]$data.wall_elapsed_ms;pass=$pass;artifact=(Split-Path -Leaf $resultPath)})
			Write-Output "R18_REGRESSION name=$($spec.name) status=$($data.status) exit=$watchdogExit pass=$pass"
		}
	}
} finally {
	$env:APPDATA = $oldAppData
	$env:LOCALAPPDATA = $oldLocalAppData
}
$tasksAfter = (git -C $repoRoot hash-object TASKS.md).Trim()
$passed = @($results | Where-Object pass).Count
$allPass = $importPass -and $passed -eq 10
$summary = [ordered]@{schema_version=1;work_item='BCM-M34-R18';run_id=$runId;status=if($allPass){'ALL_REQUESTED_REGRESSIONS_PASS'}else{'REGRESSION_FAILURE_OR_INCOMPLETE'};appdata_isolated=$true;isolated_profile_path=$profileRoot;tasks_blob_before=$tasksBefore;tasks_blob_after=$tasksAfter;tasks_unchanged=($tasksBefore -ceq $tasksAfter);import=$importData;tests=@($results);passed_tests=$passed;total_tests=10}
$summaryPath = Join-Path $runDir 'regression_summary.json'
$summaryJson = ($summary | ConvertTo-Json -Depth 20).Replace("`r`n", "`n")
[IO.File]::WriteAllText($summaryPath, ($summaryJson + "`n"), [Text.UTF8Encoding]::new($false))
$summaryHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $summaryPath).Hash.ToLowerInvariant()
Write-Output "R18_REGRESSION_SUMMARY=$($summary.status) passed=$passed/10 import=$($importData.status) summary_sha256=$summaryHash tasks_unchanged=$($summary.tasks_unchanged)"
if (-not $summary.tasks_unchanged -or -not $allPass) { exit 1 }
