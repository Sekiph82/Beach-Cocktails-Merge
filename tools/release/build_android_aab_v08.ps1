param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Preflight', 'Export')]
    [string]$Mode,
    [int]$TimeoutSeconds = 600,
    [switch]$SimulateSdkMismatch
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$outputDirectory = Join-Path $repoRoot '.godot\bcm_release_preflight'
$aabPath = Join-Path $outputDirectory 'android_preview_v08.aab'
$logPath = Join-Path $outputDirectory 'android_preview_v08_export.log'
$resultPath = Join-Path $outputDirectory 'android_preview_v08_export_result.json'
$attemptMarkerPath = Join-Path $outputDirectory 'android_preview_v08.attempted'
$projectPath = Join-Path $repoRoot 'project.godot'
$presetPath = Join-Path $repoRoot 'export_presets.cfg'
$godotPath = (Get-Command godot -ErrorAction Stop).Source
$jdkPath = 'C:\Users\sekip\AppData\Local\BCM-M34-Android-4.7.2\jdk17\jdk-17.0.20.1+1'
$javaPath = Join-Path $jdkPath 'bin\java.exe'
$sdkSettingsPath = Join-Path $env:APPDATA 'Godot\editor_settings-4.7.tres'
$bundletoolPath = Join-Path $repoRoot '.godot\gradle-home\caches\modules-2\files-2.1\com.android.tools.build\bundletool\1.16.0\88e6c67d315e7d2a860bb00b1bd93914f2c4fd33\bundletool-1.16.0.jar'
$androidNdkPath = 'ndk\28.1.13356709'
$androidCmakePath = 'cmake\3.10.2.4988404'
$androidPlatformPath = 'platforms\android-36'

function Resolve-ExistingDirectory([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { throw "$Label missing: $Path" }
    return (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\')
}

function Get-ConfiguredAndroidSdk([string]$SettingsPath) {
    if (-not (Test-Path -LiteralPath $SettingsPath -PathType Leaf)) { throw "Godot 4.7 editor settings missing: $SettingsPath" }
    $settingsText = [IO.File]::ReadAllText($SettingsPath)
    $settingMatches = [regex]::Matches($settingsText, '(?m)^export/android/android_sdk_path\s*=\s*"([^"]+)"\s*$')
    if ($settingMatches.Count -ne 1) { throw "Expected exactly one Godot Android SDK setting in $SettingsPath; found $($settingMatches.Count)." }
    return $settingMatches[0].Groups[1].Value.Replace('/', '\')
}

function Assert-SdkAlignment([string]$GodotSdk, [string]$AndroidHome, [string]$AndroidSdkRoot) {
    $configured = Resolve-ExistingDirectory $GodotSdk 'Godot configured Android SDK'
    $resolvedAndroidHome = Resolve-ExistingDirectory $AndroidHome 'ANDROID_HOME'
    $resolvedAndroidSdkRoot = Resolve-ExistingDirectory $AndroidSdkRoot 'ANDROID_SDK_ROOT'
    if (-not [string]::Equals($configured, $resolvedAndroidHome, [StringComparison]::OrdinalIgnoreCase)) {
        throw "SDK root mismatch: Godot=$configured; ANDROID_HOME=$resolvedAndroidHome"
    }
    if (-not [string]::Equals($configured, $resolvedAndroidSdkRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "SDK root mismatch: Godot=$configured; ANDROID_SDK_ROOT=$resolvedAndroidSdkRoot"
    }
    return $configured
}

function Invoke-BoundedJava([string]$Java, [string[]]$Arguments, [int]$LimitSeconds) {
    $psi = [Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $Java
    $psi.WorkingDirectory = $repoRoot
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $classpathRoot = Join-Path $repoRoot '.godot\gradle-home\caches\modules-2\files-2.1'
    $cachedJars = @(Get-ChildItem -LiteralPath $classpathRoot -Filter '*.jar' -File -Recurse | ForEach-Object { $_.FullName.Substring($repoRoot.Length + 1).Replace('\', '/') })
    $bundletoolRelative = $cachedJars | Where-Object { $_ -like '.godot/gradle-home/caches/modules-2/files-2.1/com.android.tools.build/bundletool/1.16.0/*/bundletool-1.16.0.jar' } | Select-Object -First 1
    $guavaRelative = $cachedJars | Where-Object { $_ -like '.godot/gradle-home/caches/modules-2/files-2.1/com.google.guava/guava/32.0.1-jre/*/guava-32.0.1-jre.jar' } | Select-Object -First 1
    if ([string]::IsNullOrWhiteSpace($bundletoolRelative) -or [string]::IsNullOrWhiteSpace($guavaRelative)) { throw 'Cached bundletool 1.16.0 runtime classpath is incomplete.' }
    $runtimeClasspath = @($guavaRelative, $bundletoolRelative) + @($cachedJars | Where-Object { $_ -ne $bundletoolRelative -and $_ -ne $guavaRelative -and $_ -notlike '.godot/gradle-home/caches/modules-2/files-2.1/com.google.guava/guava/*' })
    $argumentFile = Join-Path $outputDirectory 'bundletool_v08_runtime.args'
    $classpathArgument = '"' + ($runtimeClasspath -join ';') + '"'
    [IO.File]::WriteAllLines($argumentFile, [string[]]@('-cp', $classpathArgument, 'com.android.tools.build.bundletool.BundleToolMain'), [Text.UTF8Encoding]::new($false))
    $psi.ArgumentList.Add("@$argumentFile")
    foreach ($argument in $Arguments) { $psi.ArgumentList.Add($argument) }
    $psi.Environment['JAVA_HOME'] = $jdkPath
    $psi.Environment['PATH'] = (Join-Path $jdkPath 'bin') + ';' + $psi.Environment['PATH']

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $psi
    if (-not $process.Start()) { throw 'Java child process failed to start.' }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $completed = $process.WaitForExit($LimitSeconds * 1000)
    if (-not $completed) {
        try { $process.Kill($true); $process.WaitForExit(10000) } catch { }
        return [pscustomobject]@{ exit_code = $null; timed_out = $true; stdout = ''; stderr = "Timed out after ${LimitSeconds}s; only the wrapper-owned Java process tree was terminated." }
    }
    return [pscustomobject]@{ exit_code = $process.ExitCode; timed_out = $false; stdout = $stdoutTask.Result; stderr = $stderrTask.Result }
}

$runStarted = [DateTimeOffset]::UtcNow
$godotResult = 'NOT_STARTED'
$gradleResult = 'NOT_OBSERVED'
$bundletoolResult = 'NOT_RUN'
$abnormalExit = $null
$godotExitCode = $null
$sdkPath = $null
$aabExists = $false
$projectOriginalHash = $null
$projectRestoredHash = $null
$preflightResult = 'NOT_RUN'

try {
    if ($TimeoutSeconds -lt 30 -or $TimeoutSeconds -gt 600) { throw 'TimeoutSeconds must be between 30 and 600.' }
    if ($SimulateSdkMismatch -and $Mode -ne 'Preflight') { throw 'Synthetic SDK mismatch is allowed only in Preflight mode.' }
    if ($Mode -eq 'Preflight' -and $SimulateSdkMismatch) {
        New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
        $configured = Get-ConfiguredAndroidSdk $sdkSettingsPath
        $wrongSdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
        $mismatchRejected = $false
        $mismatchMessage = ''
        try { [void](Assert-SdkAlignment $configured $configured $wrongSdk) }
        catch { $mismatchRejected = $true; $mismatchMessage = $_.Exception.Message }
        if (-not $mismatchRejected) { throw 'Synthetic SDK mismatch unexpectedly passed; export was not started.' }
        $preflightResult = 'PASS_SYNTHETIC_MISMATCH_REJECTED_WITHOUT_EXPORT'
        [pscustomobject]@{
            work_item = 'BCM-M34-006/007 V08'
            mode = $Mode
            export_process_started = $false
            synthetic_mismatch_rejected = $true
            rejection = $mismatchMessage
            sdk_roots = @{ godot = $configured; android_home = $configured; android_sdk_root = $wrongSdk }
            result = $preflightResult
            timestamp_utc = [DateTimeOffset]::UtcNow.ToString('o')
        } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $outputDirectory 'android_preview_v08_synthetic_preflight.json') -Encoding utf8
        Write-Output $preflightResult
        return
    }

    $configuredSdk = Get-ConfiguredAndroidSdk $sdkSettingsPath
    $sdkPath = Resolve-ExistingDirectory $configuredSdk 'Godot configured Android SDK'
    if (-not (Test-Path -LiteralPath $javaPath -PathType Leaf)) { throw "Existing JDK 17 executable missing: $javaPath" }
    if (-not (Test-Path -LiteralPath (Join-Path $sdkPath $androidNdkPath) -PathType Container)) { throw "Existing NDK r28b missing: $sdkPath\$androidNdkPath" }
    if (-not (Test-Path -LiteralPath (Join-Path $sdkPath $androidCmakePath) -PathType Container)) { throw "Existing CMake missing: $sdkPath\$androidCmakePath" }
    if (-not (Test-Path -LiteralPath (Join-Path $sdkPath $androidPlatformPath) -PathType Container)) { throw "Existing Android API 36 missing: $sdkPath\$androidPlatformPath" }
    if (-not (Test-Path -LiteralPath (Join-Path $sdkPath 'build-tools\36.1.0\aapt2.exe') -PathType Leaf)) { throw 'Existing Android Build Tools 36.1.0/aapt2 missing.' }
    if (-not (Test-Path -LiteralPath $bundletoolPath -PathType Leaf)) { throw "Cached bundletool missing: $bundletoolPath" }
    $javaVersion = (& $javaPath -version 2>&1 | Out-String)
    if ($LASTEXITCODE -ne 0 -or $javaVersion -notmatch 'version "17\.') { throw "JDK preflight did not identify Java 17: $javaVersion" }
    $sdkPath = Assert-SdkAlignment $configuredSdk $sdkPath $sdkPath

    $presetText = [IO.File]::ReadAllText($presetPath)
    $previewPreset = [regex]::Match($presetText, '(?s)\[preset\.4\](.*?)(?=\r?\n\[preset\.|\z)').Value
    $previewOptions = [regex]::Match($presetText, '(?s)\[preset\.4\.options\](.*?)(?=\r?\n\[preset\.|\z)').Value
    if ($previewPreset -notmatch 'name="Android M34 Preview AAB \(NOT SHIPPING\)"' -or
        $previewOptions -notmatch 'package/unique_name="com\.sekiph82\.beachcocktails\.m34preview"' -or
        $previewOptions -notmatch 'export_format=1' -or
        $previewOptions -notmatch 'gradle_build/min_sdk=24' -or
        $previewOptions -notmatch 'gradle_build/target_sdk=36' -or
        $previewOptions -notmatch 'architectures/arm64-v8a=true' -or
        $previewOptions -notmatch 'keystore/release=""' -or
        $previewOptions -notmatch 'permissions/internet=true') {
        throw 'Preview AAB preset identity, format, SDKs, ABI, signing, or INTERNET permission failed preflight.'
    }
    $adsPolicy = Get-Content -LiteralPath (Join-Path $repoRoot 'data\campaign\ads_provider_policy.json') -Raw | ConvertFrom-Json
    $storeCatalog = Get-Content -LiteralPath (Join-Path $repoRoot 'data\campaign\store_catalog.json') -Raw | ConvertFrom-Json
    if ([bool]$adsPolicy.default_enabled -or @($adsPolicy.placements.PSObject.Properties | Where-Object { [bool]$_.Value.enabled }).Count -gt 0) {
        throw 'Ad policy is enabled; refusing V08 preview export.'
    }
    if (@($storeCatalog.products | Where-Object { [bool]$_.buyable }).Count -gt 0) { throw 'A store product is buyable; refusing V08 preview export.' }
    if (-not [string]::IsNullOrWhiteSpace((git diff -- project.godot)) -or
        -not [string]::IsNullOrWhiteSpace((git diff --cached -- project.godot))) {
        throw 'project.godot has tracked owner changes; refusing transient export-setting write.'
    }
    $preflightResult = 'PASS'

    if ($Mode -eq 'Preflight') {
        [pscustomobject]@{
            work_item = 'BCM-M34-006/007 V08'
            mode = $Mode
            export_process_started = $false
            result = $preflightResult
            godot_path = $godotPath
            godot_sdk_setting = $configuredSdk
            android_home_child = $sdkPath
            android_sdk_root_child = $sdkPath
            jdk17_executable = $javaPath
            java_version = ($javaVersion.Trim() -replace '\s+', ' ')
            ndk = (Join-Path $sdkPath $androidNdkPath)
            cmake = (Join-Path $sdkPath $androidCmakePath)
            api = (Join-Path $sdkPath $androidPlatformPath)
            bundletool = $bundletoolPath
            target = $aabPath
        } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $outputDirectory 'android_preview_v08_preflight.json') -Encoding utf8
        Write-Output 'PREFLIGHT_PASS_EXPORT_NOT_STARTED'
        return
    }

    if (Test-Path -LiteralPath $attemptMarkerPath) { throw "V08 single-attempt marker already exists: $attemptMarkerPath" }
    if (Test-Path -LiteralPath $aabPath) { throw "Refusing to overwrite V08 output: $aabPath" }
    $markerStream = [IO.File]::Open($attemptMarkerPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    $markerStream.Dispose()
    [IO.File]::WriteAllText($attemptMarkerPath, "V08 AAB export attempt reserved at $($runStarted.ToString('o'))`r`n", [Text.UTF8Encoding]::new($false))

    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    $originalBytes = [IO.File]::ReadAllBytes($projectPath)
    $projectOriginalHash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($originalBytes)).ToLowerInvariant()
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
    foreach ($arg in @('--headless','--path',$repoRoot,'--export-debug','Android M34 Preview AAB (NOT SHIPPING)',$aabPath)) { $psi.ArgumentList.Add($arg) }
    $psi.Environment['JAVA_HOME'] = $jdkPath
    $psi.Environment['PATH'] = (Join-Path $jdkPath 'bin') + ';' + $psi.Environment['PATH']
    $psi.Environment['GRADLE_USER_HOME'] = Join-Path $repoRoot '.godot\gradle-home'
    $psi.Environment['GRADLE_OPTS'] = '-Dorg.gradle.daemon=false'
    $psi.Environment['GODOT_ANDROID_NDK_ROOT'] = Join-Path $sdkPath $androidNdkPath
    $psi.Environment['ANDROID_HOME'] = $sdkPath
    $psi.Environment['ANDROID_SDK_ROOT'] = $sdkPath

    $godotProcess = [Diagnostics.Process]::new()
    $godotProcess.StartInfo = $psi
    if (-not $godotProcess.Start()) { throw 'Godot export process failed to start after the attempt marker was created.' }
    $stdoutTask = $godotProcess.StandardOutput.ReadToEndAsync()
    $stderrTask = $godotProcess.StandardError.ReadToEndAsync()
    $finished = $godotProcess.WaitForExit($TimeoutSeconds * 1000)
    if (-not $finished) {
        $godotResult = 'TIMEOUT_ABNORMAL'
        $abnormalExit = "Godot exceeded ${TimeoutSeconds}s; terminating only the wrapper-owned Godot process tree."
        try { $godotProcess.Kill($true); $godotProcess.WaitForExit(15000) } catch { $abnormalExit += " Process-tree termination error: $($_.Exception.Message)" }
        try { $null = [Threading.Tasks.Task]::WaitAll([Threading.Tasks.Task[]]@($stdoutTask,$stderrTask), 10000) } catch { }
    } else {
        $godotExitCode = $godotProcess.ExitCode
        $godotResult = if ($godotExitCode -eq 0) { 'EXIT_0' } else { "EXIT_$godotExitCode" }
        if ($godotExitCode -ne 0) { $abnormalExit = "Godot returned nonzero exit code $godotExitCode." }
    }
    $stdout = if ($stdoutTask.IsCompleted) { $stdoutTask.Result } else { '[stdout drain did not complete within process timeout]' }
    $stderr = if ($stderrTask.IsCompleted) { $stderrTask.Result } else { '[stderr drain did not complete within process timeout]' }
    $combinedOutput = $stdout + "`r`n--- STDERR ---`r`n" + $stderr
    [IO.File]::WriteAllText($logPath, $combinedOutput, [Text.UTF8Encoding]::new($false))
    $gradleLogEvidence = $null
    $daemonLogDirectory = Join-Path $repoRoot '.godot\gradle-home\daemon\8.11.1'
    if (Test-Path -LiteralPath $daemonLogDirectory -PathType Container) {
        $candidateLogs = Get-ChildItem -LiteralPath $daemonLogDirectory -Filter 'daemon-*.out.log' -File | Where-Object { $_.LastWriteTimeUtc -ge $runStarted.UtcDateTime.AddMinutes(-1) } | Sort-Object LastWriteTimeUtc -Descending
        foreach ($candidate in $candidateLogs) {
            $daemonText = [IO.File]::ReadAllText($candidate.FullName)
            if ($daemonText -match '(?m)BUILD SUCCESSFUL') { $gradleResult = 'BUILD_SUCCESSFUL'; $gradleLogEvidence = $candidate.FullName; break }
            if ($daemonText -match '(?m)BUILD FAILED|FAILURE: Build failed') { $gradleResult = 'BUILD_FAILED'; $gradleLogEvidence = $candidate.FullName; break }
        }
    }
    if ($gradleResult -eq 'NOT_OBSERVED' -and $combinedOutput -match '(?m)BUILD SUCCESSFUL') { $gradleResult = 'BUILD_SUCCESSFUL' }
    elseif ($gradleResult -eq 'NOT_OBSERVED' -and $combinedOutput -match '(?m)BUILD FAILED|FAILURE: Build failed') { $gradleResult = 'BUILD_FAILED' }

    $aabExists = Test-Path -LiteralPath $aabPath -PathType Leaf
    if ($aabExists) {
        $bundletoolRun = Invoke-BoundedJava $javaPath @('validate','--bundle',$aabPath) 120
        $bundletoolResult = if ($bundletoolRun.timed_out) { 'TIMEOUT' } elseif ($bundletoolRun.exit_code -eq 0) { 'PASS' } else { "FAIL_EXIT_$($bundletoolRun.exit_code)" }
        Add-Content -LiteralPath $logPath -Value ("`r`n--- BUNDLETOOL VALIDATE (EXPLICIT JDK 17) ---`r`n" + $bundletoolRun.stdout + $bundletoolRun.stderr)
    } else {
        $bundletoolResult = 'NOT_RUN_NO_AAB'
        if ([string]::IsNullOrWhiteSpace($abnormalExit)) { $abnormalExit = 'AAB_NOT_CREATED' } else { $abnormalExit += '; AAB_NOT_CREATED' }
    }
} catch {
    if ($godotResult -eq 'NOT_STARTED') { $godotResult = 'START_OR_WRAPPER_FAILURE' }
    $abnormalExit = $_.Exception.Message
    if ($Mode -eq 'Preflight') { throw }
} finally {
    if ($null -ne $originalBytes) { [IO.File]::WriteAllBytes($projectPath, $originalBytes) }
}

if (Test-Path -LiteralPath $projectPath -PathType Leaf) {
    $projectRestoredHash = (Get-FileHash -LiteralPath $projectPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
$aabExists = Test-Path -LiteralPath $aabPath -PathType Leaf
$result = [ordered]@{
    work_item = 'BCM-M34-006/007 V08'
    mode = $Mode
    export_attempt_count = if (Test-Path -LiteralPath $attemptMarkerPath) { 1 } else { 0 }
    timeout_seconds = $TimeoutSeconds
    started_utc = $runStarted.ToString('o')
    completed_utc = [DateTimeOffset]::UtcNow.ToString('o')
    godot_path = $godotPath
    jdk17_executable = $javaPath
    android_sdk = $sdkPath
    sdk_roots_aligned = ($null -ne $sdkPath)
    preflight = $preflightResult
    godot_exit = $godotResult
    godot_exit_code = $godotExitCode
    gradle_result = $gradleResult
    gradle_log_evidence = $gradleLogEvidence
    aab_path = $aabPath
    aab_exists = $aabExists
    aab_bytes = if ($aabExists) { (Get-Item -LiteralPath $aabPath).Length } else { 0 }
    aab_sha256 = if ($aabExists) { (Get-FileHash -LiteralPath $aabPath -Algorithm SHA256).Hash.ToLowerInvariant() } else { $null }
    bundletool_validation = $bundletoolResult
    abnormal_exit = $abnormalExit
    wrapper_exit_code = if (($godotResult -eq 'EXIT_0') -and ($gradleResult -eq 'BUILD_SUCCESSFUL') -and $aabExists -and ($bundletoolResult -eq 'PASS') -and ($projectOriginalHash -eq $projectRestoredHash)) { 0 } else { 2 }
    project_godot_original_sha256 = $projectOriginalHash
    project_godot_restored_sha256 = $projectRestoredHash
    project_godot_byte_identical = ($null -ne $projectOriginalHash -and $projectOriginalHash -eq $projectRestoredHash)
    log = $logPath
}

if ($Mode -eq 'Export') {
    $result | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $resultPath -Encoding utf8
    Write-Output ($result | ConvertTo-Json -Depth 6)
    $global:LASTEXITCODE = $result.wrapper_exit_code
    return
}

Write-Output $preflightResult
