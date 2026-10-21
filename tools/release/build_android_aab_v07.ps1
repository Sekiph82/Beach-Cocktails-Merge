param(
    [int]$TimeoutSeconds = 600
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$outputDirectory = Join-Path $repoRoot '.godot\bcm_release_preflight'
$aabPath = Join-Path $outputDirectory 'android_preview_v07.aab'
$logPath = Join-Path $outputDirectory 'android_preview_v07_export.log'
$resultPath = Join-Path $outputDirectory 'android_preview_v07_export_result.json'
$projectPath = Join-Path $repoRoot 'project.godot'
$godotPath = (Get-Command godot).Source
$jdkPath = 'C:\Users\sekip\AppData\Local\BCM-M34-Android-4.7.2\jdk17\jdk-17.0.20.1+1'
$androidSdkPath = 'C:\Users\sekip\AppData\Local\BCM-M34-Android-4.7.2\sdk'
$bundletoolPath = Join-Path $repoRoot '.godot\gradle-home\caches\modules-2\files-2.1\com.android.tools.build\bundletool\1.16.0\88e6c67d315e7d2a860bb00b1bd93914f2c4fd33\bundletool-1.16.0.jar'

if (-not (Test-Path -LiteralPath $jdkPath -PathType Container)) { throw "Existing process-local JDK 17 missing: $jdkPath" }
if (-not (Test-Path -LiteralPath (Join-Path $androidSdkPath 'ndk\28.1.13356709') -PathType Container)) { throw "Existing NDK r28b missing: $androidSdkPath" }
if (-not (Test-Path -LiteralPath (Join-Path $androidSdkPath 'cmake\3.10.2.4988404') -PathType Container)) { throw "Existing CMake missing: $androidSdkPath" }
if (-not (Test-Path -LiteralPath (Join-Path $androidSdkPath 'platforms\android-36') -PathType Container)) { throw "Existing Android API 36 platform missing: $androidSdkPath" }
if (-not (Test-Path -LiteralPath $bundletoolPath -PathType Leaf)) { throw "Cached bundletool 1.16.0 missing: $bundletoolPath" }
if (Test-Path -LiteralPath $aabPath) { throw "Refusing to overwrite V07 output: $aabPath" }
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$originalBytes = [IO.File]::ReadAllBytes($projectPath)
$originalHash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($originalBytes)).ToLowerInvariant()
$godotResult = 'NOT_STARTED'
$gradleResult = 'NOT_OBSERVED'
$bundletoolResult = 'NOT_RUN'
$abnormalExit = $null
$exitCode = $null
$stdoutText = ''
$stderrText = ''
$startedAt = [DateTimeOffset]::UtcNow

try {
    $projectText = [Text.UTF8Encoding]::new($false).GetString($originalBytes)
    if ($projectText -notmatch '(?m)^textures/vram_compression/import_etc2_astc\s*=\s*true\s*$') {
        if ($projectText -match '(?m)^textures/vram_compression/import_etc2_astc\s*=') {
            $projectText = [regex]::Replace($projectText, '(?m)^textures/vram_compression/import_etc2_astc\s*=.*$', 'textures/vram_compression/import_etc2_astc=true', 1)
        } elseif ($projectText -match '(?m)^\[rendering\]\s*$') {
            $projectText = [regex]::Replace($projectText, '(?m)^\[rendering\]\s*$', "[rendering]`r`ntextures/vram_compression/import_etc2_astc=true", 1)
        } else {
            throw 'Could not safely locate [rendering] section for transient Android export setting.'
        }
        [IO.File]::WriteAllText($projectPath, $projectText, [Text.UTF8Encoding]::new($false))
    }

    $psi = [Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $godotPath
    $psi.WorkingDirectory = $repoRoot
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.ArgumentList.Add('--headless')
    $psi.ArgumentList.Add('--path')
    $psi.ArgumentList.Add($repoRoot)
    $psi.ArgumentList.Add('--export-debug')
    $psi.ArgumentList.Add('Android M34 Preview AAB (NOT SHIPPING)')
    $psi.ArgumentList.Add($aabPath)
    $psi.Environment['JAVA_HOME'] = $jdkPath
    $psi.Environment['PATH'] = (Join-Path $jdkPath 'bin') + ';' + $psi.Environment['PATH']
    $psi.Environment['GRADLE_USER_HOME'] = Join-Path $repoRoot '.godot\gradle-home'
    # Match Godot's persisted editor setting exactly; Gradle rejects two distinct SDK roots.
    $psi.Environment['GODOT_ANDROID_NDK_ROOT'] = Join-Path $androidSdkPath 'ndk\28.1.13356709'
    $psi.Environment['ANDROID_HOME'] = $androidSdkPath
    $psi.Environment['ANDROID_SDK_ROOT'] = $androidSdkPath

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $psi
    if (-not $process.Start()) { throw 'Godot process failed to start.' }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $finished = $process.WaitForExit($TimeoutSeconds * 1000)
    if (-not $finished) {
        $godotResult = 'TIMEOUT_ABNORMAL'
        $abnormalExit = "Godot exceeded ${TimeoutSeconds}s; terminating only this wrapper-owned process tree."
        try { $process.Kill($true); $process.WaitForExit(15000) } catch { $abnormalExit += " Kill error: $($_.Exception.Message)" }
    }
    if ($stdoutTask.IsCompleted) { $stdoutText = $stdoutTask.Result }
    if ($stderrTask.IsCompleted) { $stderrText = $stderrTask.Result }
    if ($finished) {
        $exitCode = $process.ExitCode
        $godotResult = if ($exitCode -eq 0) { 'EXIT_0' } else { "EXIT_$exitCode" }
        if ($exitCode -ne 0) { $abnormalExit = "Godot returned nonzero exit code $exitCode." }
    }

    $combinedOutput = $stdoutText + "`r`n--- STDERR ---`r`n" + $stderrText
    [IO.File]::WriteAllText($logPath, $combinedOutput, [Text.UTF8Encoding]::new($false))
    if ($combinedOutput -match '(?m)BUILD SUCCESSFUL') { $gradleResult = 'BUILD_SUCCESSFUL' }
    elseif ($combinedOutput -match '(?m)BUILD FAILED') { $gradleResult = 'BUILD_FAILED' }
    elseif ($combinedOutput -match '(?m)FAILURE: Build failed') { $gradleResult = 'BUILD_FAILED' }

    if (($godotResult -eq 'EXIT_0') -and (Test-Path -LiteralPath $aabPath -PathType Leaf)) {
        $bundletool = & java -jar $bundletoolPath validate --bundle $aabPath 2>&1
        $bundletoolExit = $LASTEXITCODE
        Add-Content -LiteralPath $logPath -Value ("`r`n--- BUNDLETOOL VALIDATE ---`r`n" + ($bundletool -join "`r`n"))
        $bundletoolResult = if ($bundletoolExit -eq 0) { 'PASS' } else { "FAIL_EXIT_$bundletoolExit" }
    } elseif (Test-Path -LiteralPath $aabPath -PathType Leaf) {
        $bundletoolResult = 'ARTIFACT_PRESENT_BUT_GODOT_ABNORMAL_EXIT_NOT_VALIDATED_AS_PASS'
    }
} catch {
    if ($godotResult -eq 'NOT_STARTED') { $godotResult = 'START_OR_WRAPPER_FAILURE' }
    $abnormalExit = $_.Exception.Message
} finally {
    [IO.File]::WriteAllBytes($projectPath, $originalBytes)
}

$restoredHash = (Get-FileHash -LiteralPath $projectPath -Algorithm SHA256).Hash.ToLowerInvariant()
$result = [ordered]@{
    work_item = 'BCM-M34-006/007 V07'
    output = $aabPath
    started_utc = $startedAt.ToString('o')
    completed_utc = [DateTimeOffset]::UtcNow.ToString('o')
    timeout_seconds = $TimeoutSeconds
    godot_path = $godotPath
    jdk_home = $jdkPath
    android_sdk = $androidSdkPath
    godot_exit = $godotResult
    godot_exit_code = $exitCode
    gradle_result = $gradleResult
    bundletool_validation = $bundletoolResult
    abnormal_exit = $abnormalExit
    aab_exists = (Test-Path -LiteralPath $aabPath -PathType Leaf)
    aab_bytes = if (Test-Path -LiteralPath $aabPath -PathType Leaf) { (Get-Item -LiteralPath $aabPath).Length } else { 0 }
    aab_sha256 = if (Test-Path -LiteralPath $aabPath -PathType Leaf) { (Get-FileHash -LiteralPath $aabPath -Algorithm SHA256).Hash.ToLowerInvariant() } else { $null }
    project_godot_original_sha256 = $originalHash
    project_godot_restored_sha256 = $restoredHash
    project_godot_byte_identical = ($originalHash -eq $restoredHash)
    log = $logPath
}
$result | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $resultPath -Encoding utf8
$result | ConvertTo-Json -Depth 6
if (($godotResult -ne 'EXIT_0') -or ($bundletoolResult -ne 'PASS')) { exit 2 }
exit 0
