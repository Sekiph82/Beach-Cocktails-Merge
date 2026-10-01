$ErrorActionPreference = 'Stop'

$godotCommand = Get-Command godot_console.exe -ErrorAction Stop
$godotPath = $godotCommand.Source
$rootPath = (Get-Location).Path
$evidenceDir = Join-Path $rootPath 'coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/regression'
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null

$results = [System.Collections.Generic.List[object]]::new()

function Invoke-Probe {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Script,
        [Parameter(Mandatory = $true)][string]$Marker,
        [string[]]$UserArgs = @(),
        [switch]$RealRenderer
    )

    $godotArgs = [System.Collections.Generic.List[string]]::new()
    if (-not $RealRenderer) {
        $godotArgs.Add('--headless')
    }
    $godotArgs.Add('--path')
    $godotArgs.Add('.')
    $godotArgs.Add('--script')
    $godotArgs.Add($Script)
    if ($RealRenderer) {
        $godotArgs.Add('--rendering-method')
        $godotArgs.Add('gl_compatibility')
        $godotArgs.Add('--display-driver')
        $godotArgs.Add('windows')
    }
    if ($UserArgs.Count -gt 0) {
        $godotArgs.Add('--')
        foreach ($userArg in $UserArgs) {
            $godotArgs.Add($userArg)
        }
    }

    $commandText = 'godot_console.exe ' + (($godotArgs | ForEach-Object {
        if ($_ -match '\s') { '"' + $_ + '"' } else { $_ }
    }) -join ' ')
    Write-Output "RUN $Id :: $commandText"
    $started = Get-Date
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $captured = @(& $godotPath @godotArgs 2>&1)
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
    $finished = Get-Date
    $output = [string]::Join([Environment]::NewLine, [string[]]$captured)
    $markerFound = $output.Contains($Marker)
    $passed = ($exitCode -eq 0 -and $markerFound)
    $record = [ordered]@{
        id = $Id
        script = $Script
        mode = if ($RealRenderer) { 'real_renderer' } else { 'headless' }
        command = $commandText
        exit_code = $exitCode
        required_marker = $Marker
        marker_found = $markerFound
        status = if ($passed) { 'PASS' } else { 'FAIL' }
        started_local = $started.ToString('o')
        finished_local = $finished.ToString('o')
        output = $output
    }
    $results.Add([pscustomobject]$record)
    Write-Output "RESULT $Id :: status=$($record.status) exit=$exitCode marker=$markerFound"
}

function Add-ReadOnlyM17ReportCheck {
    $jsonPath = Join-Path $rootPath 'coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07_R03.json'
    $markdownPath = Join-Path $rootPath 'coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07_R03.md'
    $report = Get-Content -LiteralPath $jsonPath -Raw | ConvertFrom-Json
    $reportSha = (Get-FileHash -Algorithm SHA256 -LiteralPath $jsonPath).Hash
    $markdownSha = (Get-FileHash -Algorithm SHA256 -LiteralPath $markdownPath).Hash
    $errors = @($report.validation_errors)
    $passed = ($report.report_version -eq 'V07-R03' -and $report.status -eq 'PASS' -and $errors.Count -eq 0 -and $report.levels.Count -eq 100 -and $report.confirmation_candidate_count -eq 42)
    $results.Add([pscustomobject][ordered]@{
        id = 'M17-V07-R03-read-only-report-integrity'
        script = 'read-only PowerShell JSON/Markdown inspection; no Godot runner invoked'
        mode = 'read_only'
        command = 'Get-Content M17_CANONICAL_CONFIRMATION_V07_R03.json | ConvertFrom-Json; Get-FileHash JSON/Markdown'
        exit_code = 0
        required_marker = 'report_version=V07-R03 status=PASS validation_errors=0 levels=100 confirmation_candidate_count=42'
        marker_found = $passed
        status = if ($passed) { 'PASS' } else { 'FAIL' }
        report_sha256 = $reportSha
        markdown_sha256 = $markdownSha
        output = "version=$($report.report_version); status=$($report.status); validation_errors=$($errors.Count); levels=$($report.levels.Count); confirmation_candidate_count=$($report.confirmation_candidate_count); json_sha256=$reportSha; markdown_sha256=$markdownSha"
    })
    Write-Output "RESULT M17-V07-R03-read-only-report-integrity :: status=$(if ($passed) { 'PASS' } else { 'FAIL' })"
}

$headless = @(
    @{ id = 'M01-contract'; script = 'res://tests/m01_contract_probe.gd'; marker = 'M01_PROBE_RESULT=PASS' },
    @{ id = 'M02-physics'; script = 'res://tests/m02_physics_regression.gd'; marker = 'M02_PROBE_RESULT=PASS' },
    @{ id = 'M03-economy'; script = 'res://tests/m03_economy_regression.gd'; marker = 'M03_PROBE_RESULT=PASS' },
    @{ id = 'M07-R06-owner-layout'; script = 'res://tests/m07_r06_owner_layout_probe.gd'; marker = 'M07_R06_PROBE_RESULT=PASS' },
    @{ id = 'M08-to-go'; script = 'res://tests/m08_to_go_delivery_probe.gd'; marker = 'M08_TO_GO_DELIVERY_RESULT=PASS' },
    @{ id = 'M09-audio-haptics'; script = 'res://tests/m09_audio_haptics_probe.gd'; marker = 'M09_AUDIO_HAPTICS_RESULT=PASS' },
    @{ id = 'M10-campaign-architecture'; script = 'res://tests/m10_campaign_architecture_probe.gd'; marker = 'M10_CAMPAIGN_ARCHITECTURE_RESULT=PASS' },
    @{ id = 'M11-save-migration-progression'; script = 'res://tests/m11_save_migration_progression_probe.gd'; marker = 'M11_SAVE_MIGRATION_PROGRESSION_RESULT=PASS' },
    @{ id = 'M12-world-map'; script = 'res://tests/m12_world_map_probe.gd'; marker = 'M12_WORLD_MAP_RESULT=PASS' },
    @{ id = 'M13-island-map'; script = 'res://tests/m13_island_map_probe.gd'; marker = 'M13_ISLAND_MAP_RESULT=PASS' },
    @{ id = 'M14-gameplay-session-bridge'; script = 'res://tests/m14_gameplay_session_bridge_probe.gd'; marker = 'M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS' },
    @{ id = 'M15-vip-boosters-economy'; script = 'res://tests/m15_vip_boosters_economy_probe.gd'; marker = 'M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS' },
    @{ id = 'M16-sunny-cove-content'; script = 'res://tests/m16_sunny_cove_content_probe.gd'; marker = 'M16_SUNNY_COVE_CONTENT_RESULT=PASS' },
    @{ id = 'M17-vip-optionality'; script = 'res://tests/m17_vip_optionality_probe.gd'; marker = 'M17_VIP_OPTIONALITY_RESULT=PASS' },
    @{ id = 'M17-V06-analytical'; script = 'res://tests/m17_canonical_screening_v06_analytical_probe.gd'; marker = 'M17_V06_ANALYTICAL_RESULT=PASS' },
    @{ id = 'M17-difficulty-validation'; script = 'res://tests/m17_difficulty_validation_probe.gd'; marker = 'M17_DIFFICULTY_VALIDATION_RESULT=PASS' },
    @{ id = 'M18-star-contract'; script = 'res://tests/m18_star_contract_probe.gd'; marker = 'M18_STAR_CONTRACT_RESULT=PASS' },
    @{ id = 'M18-completion-progression'; script = 'res://tests/m18_completion_progression_probe.gd'; marker = 'M18_COMPLETION_PROGRESSION_RESULT=PASS' },
    @{ id = 'M18-cumulative-star-rewards'; script = 'res://tests/m18_cumulative_star_rewards_probe.gd'; marker = 'M18_CUMULATIVE_STAR_REWARDS_RESULT=PASS' },
    @{ id = 'M18-reward-claim-remediation'; script = 'res://tests/m18_cumulative_reward_claim_remediation_probe.gd'; marker = 'M18_CUMULATIVE_REWARD_REMEDIATION_RESULT=PASS' },
    @{ id = 'M18-replay-persistence'; script = 'res://tests/m18_replay_persistence_probe.gd'; marker = 'M18_REPLAY_PERSISTENCE_RESULT=PASS' },
    @{ id = 'M18-integration'; script = 'res://tests/m18_integration_probe.gd'; marker = 'M18_INTEGRATION_RESULT=PASS' },
    @{ id = 'M18-island-map-replay'; script = 'res://tests/m18_island_map_replay_probe.gd'; marker = 'M18_ISLAND_MAP_REPLAY_RESULT=PASS' },
    @{ id = 'M19-scalability'; script = 'res://tests/m19_multi_island_scalability_probe.gd'; marker = 'M19_SCALABILITY_RESULT=PASS' }
)

foreach ($item in $headless) {
    Invoke-Probe -Id $item.id -Script $item.script -Marker $item.marker
}

for ($child = 1; $child -le 6; $child++) {
    $childText = '{0:D2}' -f $child
    Invoke-Probe -Id "M19-R01-child-$childText" -Script 'res://tests/m19_r01_ordered_verification_probe.gd' -Marker "M19_R01_CHILD_${childText}_RESULT=PASS" -UserArgs @("--child=$child")
}

$renderer = @(
    @{ id = 'M18-V02-R01-replay-capture'; script = 'res://tests/m18_v02_r01_replay_capture_probe.gd'; marker = 'M18_REPLAY_CAPTURE_RESULT=PASS' },
    @{ id = 'M20-runtime-capture'; script = 'res://tests/m20_runtime_capture_probe.gd'; marker = 'M20_RUNTIME_CAPTURE_RESULT=PASS' }
)
foreach ($item in $renderer) {
    Invoke-Probe -Id $item.id -Script $item.script -Marker $item.marker -RealRenderer
}

Add-ReadOnlyM17ReportCheck

$failed = @($results | Where-Object { $_.status -ne 'PASS' })
$report = [ordered]@{
    report = 'BCM-M21-004 full accepted regression'
    report_version = 'V01'
    generated_local = (Get-Date).ToString('o')
    godot_executable = $godotPath
    godot_version = (& $godotPath --version 2>&1 | Out-String).Trim()
    historical_exclusions = @(
        'tests/m17_canonical_screening_probe.gd was not run: explicitly historical pre-V05 VIP-second assertions are superseded by post-V05 acceptance.',
        'M07-R04 historical limitation remains excluded; M07-R06 owner-layout probe was run and required to pass.',
        'tools/campaign/m17_canonical_confirmation_v07_r03.gd was not invoked because it writes historical V07-R03 JSON/Markdown reports; the accepted V07-R03 report was validated read-only.'
    )
    results = $results
    summary = [ordered]@{
        total = $results.Count
        passed = $results.Count - $failed.Count
        failed = $failed.Count
        status = if ($failed.Count -eq 0) { 'PASS' } else { 'FAIL' }
    }
}

$jsonPath = Join-Path $evidenceDir 'M21-004_FULL_ACCEPTED_REGRESSION.json'
$mdPath = Join-Path $evidenceDir 'M21-004_FULL_ACCEPTED_REGRESSION.md'
$report | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $jsonPath -Encoding utf8

$markdown = [System.Text.StringBuilder]::new()
[void]$markdown.AppendLine('# BCM-M21-004 Full Accepted Regression')
[void]$markdown.AppendLine('')
[void]$markdown.AppendLine(('Status: `{0}`; total checks: `{1}`; passed: `{2}`; failed: `{3}`.' -f $report.summary.status, $report.summary.total, $report.summary.passed, $report.summary.failed))
[void]$markdown.AppendLine(('Godot: `{0}` at `{1}`.' -f $report.godot_version, $report.godot_executable))
[void]$markdown.AppendLine('')
[void]$markdown.AppendLine('## Regression matrix')
[void]$markdown.AppendLine('')
[void]$markdown.AppendLine('| ID | Mode | Exit | Marker | Status |')
[void]$markdown.AppendLine('|---|---|---:|---|---|')
foreach ($item in $results) {
    [void]$markdown.AppendLine(('| `{0}` | `{1}` | `{2}` | `{3}` | **{4}** |' -f $item.id, $item.mode, $item.exit_code, $item.marker_found, $item.status))
}
[void]$markdown.AppendLine('')
[void]$markdown.AppendLine('## Historical and non-rerun boundaries')
[void]$markdown.AppendLine('')
foreach ($boundary in $report.historical_exclusions) {
    [void]$markdown.AppendLine('- ' + $boundary)
}
[void]$markdown.AppendLine('')
[void]$markdown.AppendLine('## Exact output')
[void]$markdown.AppendLine('')
foreach ($item in $results) {
    [void]$markdown.AppendLine(('### `{0}`' -f $item.id))
    [void]$markdown.AppendLine('')
    [void]$markdown.AppendLine(('Command: `{0}`' -f $item.command))
    [void]$markdown.AppendLine(('Exit code: `{0}`; required marker: `{1}`; marker found: `{2}`.' -f $item.exit_code, $item.required_marker, $item.marker_found))
    [void]$markdown.AppendLine('')
    [void]$markdown.AppendLine('```text')
    [void]$markdown.AppendLine($item.output)
    [void]$markdown.AppendLine('```')
    [void]$markdown.AppendLine('')
}
$markdown.ToString() | Set-Content -LiteralPath $mdPath -Encoding utf8

Write-Output "M21_CHILD_04_RESULT=$($report.summary.status) checks=$($report.summary.total) passed=$($report.summary.passed) failed=$($report.summary.failed)"
if ($failed.Count -gt 0) {
    Write-Output ('FAILED_IDS=' + (($failed | ForEach-Object { $_.id }) -join ','))
    exit 1
}
exit 0
