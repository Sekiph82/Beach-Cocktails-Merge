param(
    [switch]$CaptureOnly
)

$ErrorActionPreference = 'Stop'

$projectSource = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$godotCommand = Get-Command 'godot.exe' -ErrorAction Stop
$godotPath = $godotCommand.Source
$godotVersion = (& $godotPath --version | Select-Object -First 1).Trim()
if ($godotVersion -notmatch '^4\.7\.2(?:\.|$)') {
    throw "Godot 4.7.2 is required. Found '$godotVersion' at '$godotPath'."
}

$reviewRoot = Join-Path $env:LOCALAPPDATA 'BeachCocktails\BCM-M32-Tutorial-Owner-Review'
$applicationIdentity = if ($CaptureOnly) { 'BCM32TutorialOwnerReviewCapture' } else { 'BCM32TutorialOwnerReview' }
$projectFolder = if ($CaptureOnly) { 'capture-project' } else { 'project' }
$reviewProject = Join-Path $reviewRoot $projectFolder
$archivePath = Join-Path $reviewRoot 'canonical-source.tar'
New-Item -ItemType Directory -Path $reviewProject -Force | Out-Null

# Export only committed source from this review worktree. This excludes the
# owner's dirty checkout, Git metadata, editor cache and any local save files.
$git = Get-Command 'git.exe' -ErrorAction Stop
& $git.Source -C $projectSource archive --format=tar --output=$archivePath HEAD
if ($LASTEXITCODE -ne 0) {
    throw 'Could not archive the committed review source.'
}
try {
    & tar.exe -xf $archivePath -C $reviewProject
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not extract the isolated review project.'
    }
}
finally {
    Remove-Item -LiteralPath $archivePath -Force -ErrorAction SilentlyContinue
}

$projectSettings = Join-Path $reviewProject 'project.godot'
$settingsText = Get-Content -LiteralPath $projectSettings -Raw
$settingsText = [regex]::Replace($settingsText, 'config/name="[^"]*"', "config/name=`"$applicationIdentity`"", 1)
$settingsText = [regex]::Replace($settingsText, 'run/main_scene="[^"]*"', 'run/main_scene="res://tools/owner-review/tutorial_review_bootstrap.tscn"', 1)
$settingsText = [regex]::Replace($settingsText, 'window/size/window_width_override=\d+', 'window/size/window_width_override=432', 1)
$settingsText = [regex]::Replace($settingsText, 'window/size/window_height_override=\d+', 'window/size/window_height_override=960', 1)
Set-Content -LiteralPath $projectSettings -Value $settingsText -Encoding utf8NoBOM

# Reuse only generated import artifacts from the canonical Desktop checkout
# when both checkouts have the same source HEAD and no local asset/code diffs.
# This avoids a full cold import while leaving the owner's project untouched.
$classCache = Join-Path $reviewProject '.godot\global_script_class_cache.cfg'
$importedTarget = Join-Path $reviewProject '.godot\imported'
$importMetadataCount = (Get-ChildItem -Path $reviewProject -Filter '*.import' -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
$needsCache = -not (Test-Path -LiteralPath $classCache) -or $importMetadataCount -eq 0 -or (Get-ChildItem $importedTarget -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0
if ($needsCache) {
    $cacheSource = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Beach Cocktails - Merge'
    if (-not (Test-Path -LiteralPath (Join-Path $cacheSource '.godot\global_script_class_cache.cfg'))) {
        throw "A matching Godot import cache was not found in '$cacheSource'."
    }
    $reviewHead = (& $git.Source -C $projectSource rev-parse HEAD).Trim()
    $cacheHead = (& $git.Source -C $cacheSource rev-parse HEAD).Trim()
    $criticalDiffs = @(& $git.Source -C $cacheSource diff --name-only HEAD -- assets addons scenes scripts data)
    $criticalUntracked = @(& $git.Source -C $cacheSource ls-files --others --exclude-standard -- assets addons scenes scripts data)
    $reviewCriticalChanges = @(& $git.Source -C $projectSource diff --name-only "$cacheHead..$reviewHead" -- assets addons scenes scripts data)
    if ($criticalDiffs.Count -gt 0 -or $criticalUntracked.Count -gt 0 -or $reviewCriticalChanges.Count -gt 0) {
        throw 'The canonical checkout cache does not match the review source; refusing to reuse it.'
    }
    $importedSource = Join-Path $cacheSource '.godot\imported'
    New-Item -ItemType Directory -Path $importedTarget -Force | Out-Null
    & robocopy.exe $importedSource $importedTarget /E /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -gt 7) {
        throw "Could not copy the matching Godot imported cache (robocopy exit $LASTEXITCODE)."
    }
    & robocopy.exe $cacheSource $reviewProject '*.import' '*.gd.uid' /S /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -gt 7) {
        throw "Could not copy the matching Godot import metadata (robocopy exit $LASTEXITCODE)."
    }
    Copy-Item -LiteralPath (Join-Path $cacheSource '.godot\global_script_class_cache.cfg') -Destination $classCache -Force
    if (-not (Test-Path -LiteralPath $classCache) -or (Get-ChildItem $importedTarget -Recurse -File | Measure-Object).Count -eq 0) {
        throw 'The canonical Godot import cache copy was incomplete.'
    }
}

# The process is intentionally left running for owner interaction. Do not add
# --headless, --quit, or automatic process cleanup to this graphical launch.
$gameArgs = @('--path', $reviewProject, '--rendering-method', 'gl_compatibility')
if ($CaptureOnly) {
    $gameArgs += @('--', '--capture-only')
    $game = Start-Process -FilePath $godotPath -ArgumentList $gameArgs -PassThru -Wait
    if ($game.ExitCode -ne 0) {
        throw "Graphical screenshot capture exited with code $($game.ExitCode)."
    }
    $capturePath = Join-Path $env:APPDATA "Godot\app_userdata\$applicationIdentity\tutorial_owner_review_capture.png"
    if (-not (Test-Path -LiteralPath $capturePath)) {
        throw "Graphical tutorial screenshot was not produced at '$capturePath'."
    }
    $evidenceDirectory = Join-Path $projectSource 'coordination\sessions\BCM-M32-TUTORIAL-OWNER-GODOT-REVIEW-V01\evidence'
    New-Item -ItemType Directory -Path $evidenceDirectory -Force | Out-Null
    $evidencePath = Join-Path $evidenceDirectory 'godot_tutorial_owner_review.png'
    Copy-Item -LiteralPath $capturePath -Destination $evidencePath -Force
    Write-Output "Graphical tutorial screenshot: $evidencePath"
    Write-Output "Capture process exit: $($game.ExitCode)"
}
else {
    $game = Start-Process -FilePath $godotPath -ArgumentList $gameArgs -PassThru
    Write-Output "Tutorial review window started (PID $($game.Id))."
    Write-Output "Isolated project: $reviewProject"
    Write-Output "Isolated Godot user data: %APPDATA%\Godot\app_userdata\$applicationIdentity"
}
