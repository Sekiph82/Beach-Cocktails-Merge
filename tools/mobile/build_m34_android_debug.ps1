[CmdletBinding()]
param(
    [string]$AndroidSdkPath = (Join-Path $env:LOCALAPPDATA 'Android\Sdk')
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$godotCommand = Get-Command godot -ErrorAction Stop
$godot = $godotCommand.Source
$jdkVersion = '17.0.20.1+1'
$jdkArchiveName = 'OpenJDK17U-jdk_x64_windows_hotspot_17.0.20.1_1.zip'
$jdkSha256 = 'e53a79c3c3d86865bd7e787903884331068e71321714ffd44f145785affc7cb0'
$jdkRoot = Join-Path $root '.godot\toolchains\temurin17'
$jdkHome = Join-Path $jdkRoot "jdk-$jdkVersion"
$jdkArchive = Join-Path $jdkRoot $jdkArchiveName
$profile = Join-Path $root '.godot\godot-profile'
$godotProfileRoot = Join-Path $profile 'Godot'
$gradleHome = Join-Path $root '.godot\gradle-home'
$buildRoot = Join-Path $root '.godot\m34_android'
$presetPath = Join-Path $root 'export_presets.cfg'
$projectPath = Join-Path $root 'project.godot'
$generatedPreset = $false
$originalPresetBytes = $null
$originalProjectBytes = [System.IO.File]::ReadAllBytes($projectPath)

if (Test-Path -LiteralPath $presetPath) {
    $originalPresetBytes = [System.IO.File]::ReadAllBytes($presetPath)
    $existingPresetText = [System.Text.Encoding]::UTF8.GetString($originalPresetBytes)
}
if (-not (Test-Path -LiteralPath (Join-Path $AndroidSdkPath 'platform-tools\adb.exe'))) {
    throw "Android SDK not found at $AndroidSdkPath (expected platform-tools/adb.exe)."
}
if (-not (Test-Path -LiteralPath (Join-Path $jdkHome 'bin\java.exe'))) {
    New-Item -ItemType Directory -Force -Path $jdkRoot | Out-Null
    if (-not (Test-Path -LiteralPath $jdkArchive)) {
        $uri = 'https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.20.1%2B1/' + $jdkArchiveName
        Invoke-WebRequest -Uri $uri -OutFile $jdkArchive
    }
    $actual = (Get-FileHash -LiteralPath $jdkArchive -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $jdkSha256) { throw "Temurin archive checksum mismatch: $actual" }
    Expand-Archive -LiteralPath $jdkArchive -DestinationPath $jdkRoot -Force
}
if (-not (Test-Path -LiteralPath (Join-Path $jdkHome 'bin\java.exe'))) {
    throw "Verified Temurin $jdkVersion archive did not contain the expected JDK."
}
New-Item -ItemType Directory -Force -Path $godotProfileRoot,$gradleHome,$buildRoot | Out-Null
$env:APPDATA = $profile
$env:ANDROID_HOME = $AndroidSdkPath
$env:ANDROID_SDK_ROOT = $AndroidSdkPath
$env:JAVA_HOME = $jdkHome
$env:GRADLE_USER_HOME = $gradleHome
$settingsPath = Join-Path $godotProfileRoot 'editor_settings-4.7.tres'
if (-not (Test-Path -LiteralPath $settingsPath)) {
    & $godot --headless --editor --path $root --quit
    if ($LASTEXITCODE -ne 0) { throw "Godot isolated profile initialization failed: $LASTEXITCODE" }
}
$debugKeystore = (Join-Path $godotProfileRoot 'keystores\debug.keystore').Replace('\','/')
$settings = @"
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "$($AndroidSdkPath.Replace('\','/'))"
export/android/java_sdk_path = "$($jdkHome.Replace('\','/'))"
export/android/debug_keystore = "$debugKeystore"
export/android/debug_keystore_pass = "android"
"@
Set-Content -LiteralPath $settingsPath -Value $settings -Encoding utf8

function Invoke-GodotProcess([string[]]$Arguments, [string]$LogPath) {
    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $godot
    $start.WorkingDirectory = $root
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($argument in $Arguments) { [void]$start.ArgumentList.Add($argument) }
    $process = [System.Diagnostics.Process]::Start($start)
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    $text = $stdoutTask.Result + $stderrTask.Result
    Set-Content -LiteralPath $LogPath -Value $text -Encoding utf8
    return $process.ExitCode
}

# Keep the exact Godot version's installed source template within the project-local profile.
$templates = Join-Path $godotProfileRoot 'export_templates\4.7.2.stable'
$templateZip = Join-Path $templates 'android_source.zip'
$installedTemplate = Join-Path $env:APPDATA 'Godot\export_templates\4.7.2.stable\android_source.zip'
if (-not (Test-Path -LiteralPath $templateZip)) {
    # APPDATA now points into the isolated profile, so resolve the original installed template explicitly.
    $installedTemplate = Join-Path $env:USERPROFILE 'AppData\Roaming\Godot\export_templates\4.7.2.stable\android_source.zip'
    if (-not (Test-Path -LiteralPath $installedTemplate)) {
        throw 'Godot 4.7.2 android_source.zip is not installed; no alternate template will be substituted.'
    }
    New-Item -ItemType Directory -Force -Path $templates | Out-Null
    Copy-Item -LiteralPath $installedTemplate -Destination $templateZip
}

$preset = @'
[preset.0]
name="M34 Android Debug Nonshipping"
platform="Android"
runnable=true
dedicated_server=false
custom_features="m34_nonshipping"
export_filter="all_resources"
include_filter=""
exclude_filter="coordination/*, docs/*, tests/*, tools/*, assets/ui_assets/source/*, assets/ui_assets/v04_masters/*, assets/ui_assets/v05_sources/*, *.md, .github/*"
export_path=".godot/m34_android/BeachCocktails-M34-debug.apk"

[preset.0.options]
custom_template/debug=""
custom_template/release=""
gradle_build/use_gradle_build=true
gradle_build/export_format=0
gradle_build/min_sdk=24
gradle_build/target_sdk=36
architectures/arm64-v8a=true
architectures/armeabi-v7a=false
architectures/x86=false
architectures/x86_64=false
version/code=1
version/name="0.0.0-m34-debug"
package/unique_name="com.sekiph82.beachcocktails.m34debug"
package/name="Beach Cocktails Merge M34 Debug"
package/signed=true
launcher_icons/main_192x192="res://assets/ui_assets/brand/app_icon.png"
'@

try {
    Set-Content -LiteralPath $presetPath -Value $preset -Encoding utf8
    $generatedPreset = $true
    Get-Content -LiteralPath $presetPath | Set-Content -LiteralPath (Join-Path $buildRoot 'generated-preset-preview.txt') -Encoding utf8
    $projectText = [System.Text.Encoding]::UTF8.GetString($originalProjectBytes)
    if ($projectText -match '(?m)^textures/vram_compression/import_etc2_astc=') {
        $projectText = [regex]::Replace($projectText, '(?m)^textures/vram_compression/import_etc2_astc=.*$', 'textures/vram_compression/import_etc2_astc=true')
    } else {
        $projectText = [regex]::Replace($projectText, '(?m)^\[rendering\]\r?$', "[rendering]`r`ntextures/vram_compression/import_etc2_astc=true", 1)
    }
    [System.IO.File]::WriteAllText($projectPath, $projectText, [System.Text.UTF8Encoding]::new($false))
    $apk = Join-Path $buildRoot 'BeachCocktails-M34-debug.apk'
    $log = Join-Path $buildRoot 'godot-export.log'
    $exportExitCode = Invoke-GodotProcess @('--headless','--path',$root,'--export-debug','M34 Android Debug Nonshipping',$apk,'--install-android-build-template') $log
    if ($exportExitCode -ne 0) { throw "Godot Gradle debug APK export failed: $exportExitCode (see $log)" }
    if (-not (Test-Path -LiteralPath $apk)) { throw 'Godot returned success but APK is missing.' }
    $sha = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash
    $buildTools = Get-ChildItem -LiteralPath (Join-Path $AndroidSdkPath 'build-tools') -Directory | Sort-Object Name -Descending | Select-Object -First 1
    $aapt2 = Join-Path $buildTools.FullName 'aapt2.exe'
    $apksigner = Join-Path $buildTools.FullName 'apksigner.bat'
    $apkanalyzer = Join-Path $AndroidSdkPath 'cmdline-tools\latest\bin\apkanalyzer.bat'
    "APK_PATH=$apk"
    "APK_SHA256=$sha"
    "APK_BYTES=$((Get-Item -LiteralPath $apk).Length)"
    & $aapt2 dump badging $apk
    if (Test-Path -LiteralPath $apksigner) { & $apksigner verify --print-certs $apk }
    if (Test-Path -LiteralPath $apkanalyzer) {
        $dexReport = Join-Path $buildRoot 'dex-packages.txt'
        & $apkanalyzer dex packages $apk | Set-Content -LiteralPath $dexReport -Encoding utf8
        Select-String -Path $dexReport -Pattern 'com\.google\.android\.gms\.ads\.MobileAds|com\.android\.billingclient' |
            Select-Object -First 12 | ForEach-Object Line
    }
} finally {
    if (Test-Path -LiteralPath $presetPath) {
        if ($null -ne $originalPresetBytes) {
            [System.IO.File]::WriteAllBytes($presetPath, $originalPresetBytes)
        } else {
            Remove-Item -LiteralPath $presetPath
        }
    }
    [System.IO.File]::WriteAllBytes($projectPath, $originalProjectBytes)
}
