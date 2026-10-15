$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$watchdog = Join-Path $repoRoot "tools/campaign/m34_r14_process_watchdog.ps1"
$evidenceDir = Join-Path $repoRoot "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R15"
$testAppData = Join-Path $env:TEMP ("BCM-M34-R15-userdata-" + [guid]::NewGuid().ToString("N"))
$oldAppData = $env:APPDATA
$tasksBefore = (git -C $repoRoot hash-object TASKS.md).Trim()
$tests = @(
	[pscustomobject]@{name="economy_35";args=@("--headless","--path",$repoRoot,"--script",(Join-Path $repoRoot "tests/m34_economy_closure_probe.gd"))},
	[pscustomobject]@{name="daily_38";args=@("--headless","--path",$repoRoot,"--script",(Join-Path $repoRoot "tests/m34_daily_rewards_probe.gd"))},
	[pscustomobject]@{name="navigation_17";args=@("--headless","--path",$repoRoot,"--script",(Join-Path $repoRoot "tests/m33_campaign_navigation_probe.gd"))},
	[pscustomobject]@{name="m14_bridge";args=@("--headless","--path",$repoRoot,"--script",(Join-Path $repoRoot "tests/m14_gameplay_session_bridge_probe.gd"))},
	[pscustomobject]@{name="m15_vip_economy";args=@("--headless","--path",$repoRoot,"--script",(Join-Path $repoRoot "tests/m15_vip_boosters_economy_probe.gd"))},
	[pscustomobject]@{name="scene_uid";args=@("--headless","--path",$repoRoot,"--script",(Join-Path $repoRoot "tests/m34_r10_scene_uid_probe.gd"))},
	[pscustomobject]@{name="production_routes";args=@("--headless","--path",$repoRoot,"--script",(Join-Path $repoRoot "tests/m34_production_routes_probe.gd"))},
	[pscustomobject]@{name="slim_content";args=@("--headless","--path",$repoRoot,"--script",(Join-Path $repoRoot "tests/m34_r09_slim_export_content_probe.gd"))},
	[pscustomobject]@{name="vip_optional";args=@("--headless","--path",$repoRoot,"--script",(Join-Path $repoRoot "tests/m34_r10_vip_optional_rule_probe.gd"))},
	[pscustomobject]@{name="startup_smoke";args=@("--headless","--path",$repoRoot,"--quit-after","3")}
)
$results = [System.Collections.Generic.List[object]]::new()
$drive = [IO.Path]::GetPathRoot($env:TEMP).Substring(0,1)
$freeBefore = (Get-Volume -DriveLetter $drive).SizeRemaining
New-Item -ItemType Directory -Path $testAppData | Out-Null
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$env:APPDATA = $testAppData
try {
	foreach ($test in $tests) {
		$resultPath = Join-Path $evidenceDir "$($test.name).watchdog.json"
		$timeout = if ($test.name -eq "navigation_17") { 180 } else { 60 }
		& $watchdog -FilePath $godot -ArgumentList $test.args -TimeoutSeconds $timeout -ResultPath $resultPath -TaskName "BCM-M34-R15-REGRESSION-$($test.name)"
		$watchdogExit = $LASTEXITCODE
		$watchdogResult = Get-Content -Raw -LiteralPath $resultPath | ConvertFrom-Json
		$stdoutPath = Join-Path $evidenceDir "$($test.name).stdout.txt"
		$stderrPath = Join-Path $evidenceDir "$($test.name).stderr.txt"
		[IO.File]::WriteAllText($stdoutPath, ([string]$watchdogResult.stdout -replace "`r`n", "`n"), [Text.UTF8Encoding]::new($false))
		[IO.File]::WriteAllText($stderrPath, ([string]$watchdogResult.stderr -replace "`r`n", "`n"), [Text.UTF8Encoding]::new($false))
		$results.Add([pscustomobject]@{test=$test.name;timeout_seconds=$timeout;status=$watchdogResult.status;exit=$watchdogExit;reason=$watchdogResult.reason;stdout_file=[IO.Path]::GetFileName($stdoutPath);stderr_file=[IO.Path]::GetFileName($stderrPath);pass=($watchdogResult.status -eq "EXITED" -and $watchdogExit -eq 0)})
		$summary=[ordered]@{schema_version=1;work_item="BCM-M34-R15";user_data_isolated=$true;isolated_appdata_path=$testAppData;tests=@($results);status="RUNNING"}
		$summaryJson = ($summary | ConvertTo-Json -Depth 10).Replace("`r`n", "`n")
		[IO.File]::WriteAllText((Join-Path $evidenceDir "regression_summary.json"), $summaryJson + "`n", [Text.UTF8Encoding]::new($false))
		Write-Output "R15_REGRESSION=$($test.name) status=$($watchdogResult.status) exit=$watchdogExit wall_ms=$($watchdogResult.wall_elapsed_ms)"
		if ($watchdogResult.status -ne "EXITED") { break }
	}
} finally {
	$env:APPDATA = $oldAppData
}

$tasksAfter = (git -C $repoRoot hash-object TASKS.md).Trim()
$cleanupStatus = "NOT_ATTEMPTED"
$isolatedBytes = if (Test-Path -LiteralPath $testAppData) { (Get-ChildItem -LiteralPath $testAppData -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum } else { 0 }
$absoluteTemp = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\')
$absoluteTarget = [IO.Path]::GetFullPath($testAppData).TrimEnd('\')
if ((Split-Path -Parent $absoluteTarget) -ieq $absoluteTemp -and (Split-Path -Leaf $absoluteTarget) -like "BCM-M34-R15-userdata-*") {
	try { Remove-Item -LiteralPath $absoluteTarget -Recurse -Force; $cleanupStatus = "REMOVED_EXACT_TASK_TEMP" } catch { $cleanupStatus = "DELETE_BLOCKED: $($_.Exception.Message)" }
} else { $cleanupStatus = "REFUSED_TARGET_OUTSIDE_EXACT_TEMP_SCOPE" }
$freeAfter = (Get-Volume -DriveLetter $drive).SizeRemaining
$allPass = @($results | Where-Object {-not $_.pass}).Count -eq 0
$summary=[ordered]@{
	schema_version=1;work_item="BCM-M34-R15";status=if($allPass){"ALL_REQUESTED_REGRESSIONS_PASS"}else{"REGRESSION_FAILURE_OR_INCOMPLETE"}
	user_data_isolated=$true;isolated_appdata_bytes_before_cleanup=$isolatedBytes;isolated_appdata_cleanup=$cleanupStatus
	free_bytes_before=$freeBefore;free_bytes_after=$freeAfter;free_bytes_reclaimed=($freeAfter-$freeBefore)
	tasks_md_hash_before=$tasksBefore;tasks_md_hash_after=$tasksAfter;tasks_md_unchanged=($tasksBefore -ceq $tasksAfter)
	tests=@($results)
}
$summaryJson = ($summary | ConvertTo-Json -Depth 10).Replace("`r`n", "`n")
[IO.File]::WriteAllText((Join-Path $evidenceDir "regression_summary.json"), $summaryJson + "`n", [Text.UTF8Encoding]::new($false))
Write-Output "M34_R15_REGRESSIONS=$($summary.status) passed=$(@($results|Where-Object{$_.pass}).Count)/$($tests.Count) cleanup=$cleanupStatus reclaimed=$($freeAfter-$freeBefore)"
if (-not $allPass -or $tasksBefore -cne $tasksAfter) { exit 1 }
