Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = (Get-Command godot_console.exe -ErrorAction Stop).Source
$watchdog = Join-Path $repoRoot "tools/campaign/m34_r14_process_watchdog.ps1"
$probe = Join-Path $repoRoot "tools/campaign/m34_r14_bounded_path_probe.gd"
$evidenceDir = Join-Path $repoRoot "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R15"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$name = "final_island_l100_standard_fps_4t_seed_34113100"
$outputPath = Join-Path $evidenceDir "$name.json"
$progressPath = Join-Path $evidenceDir "$name.progress.json"
$watchdogPath = Join-Path $evidenceDir "$name.watchdog.json"
$arguments = @(
	"--headless", "--path", $repoRoot,
	"--script", $probe, "--",
	"--r14-output=$outputPath",
	"--r14-progress=$progressPath",
	"--r14-island=final_island",
	"--r14-level=100",
	"--r14-seed=34113100"
)
& $watchdog -FilePath $godot -ArgumentList $arguments -TimeoutSeconds 12 -ResultPath $watchdogPath -ProgressPath $progressPath -TaskName "BCM-M34-R15-STANDARD-FPS-4T-$name"
$watchdogExit = $LASTEXITCODE
$watchdogResult = Get-Content -Raw -LiteralPath $watchdogPath | ConvertFrom-Json
$probeResult = $null
if (Test-Path -LiteralPath $outputPath -PathType Leaf) {
	try { $probeResult = Get-Content -Raw -LiteralPath $outputPath | ConvertFrom-Json } catch {}
}
$classification = if ($watchdogResult.status -eq "TIMEOUT_TERMINATED") { "UNKNOWN_TIMEOUT" } elseif ($watchdogResult.status -eq "EXITED" -and $watchdogExit -eq 0 -and $probeResult) { [string]$probeResult.classification } else { "ERROR" }
$summary = [ordered]@{
	schema_version=1
	work_item="BCM-M34-R15"
	mode="standard_fps_production_physics"
	case_count=1
	case=$name
	external_wall_deadline_seconds=12
	internal_wall_budget_seconds=8
	fast_authoritative_mode_authorized=$false
	watchdog_status=$watchdogResult.status
	watchdog_exit=$watchdogExit
	classification=$classification
	reason=if ($probeResult) { $probeResult.terminal_reason } else { $watchdogResult.reason }
	progress=$watchdogResult.partial_progress
	probe_file=[IO.Path]::GetFileName($outputPath)
	watchdog_file=[IO.Path]::GetFileName($watchdogPath)
}
$summaryPath = Join-Path $evidenceDir "standard_fps_authoritative_4t_summary.json"
$summaryJson = ($summary | ConvertTo-Json -Depth 20).Replace("`r`n", "`n")
[IO.File]::WriteAllText($summaryPath, $summaryJson + "`n", [Text.UTF8Encoding]::new($false))
Write-Output "R15_STANDARD_FPS_4T=$classification watchdog=$($watchdogResult.status) reason=$($summary.reason)"
if ($classification -eq "ERROR") { exit 1 }
exit 0
