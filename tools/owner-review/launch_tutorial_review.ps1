param()

$ErrorActionPreference = 'Stop'

$projectSource = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$godotCommand = Get-Command 'godot.exe' -ErrorAction Stop
$godotPath = $godotCommand.Source
$godotVersion = (& $godotPath --version | Select-Object -First 1).Trim()
if ($godotVersion -notmatch '^4\.7\.2(?:\.|$)') {
    throw "Godot 4.7.2 is required. Found '$godotVersion' at '$godotPath'."
}

$reviewRoot = Join-Path $env:LOCALAPPDATA 'BeachCocktails\BCM-M32-Tutorial-Owner-Review'
$reviewProject = Join-Path $reviewRoot 'project'
$archivePath = Join-Path $reviewRoot 'canonical-source.tar'
$desktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Beach Cocktails Tutorial Owner Review.lnk'
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
$settingsText = [regex]::Replace($settingsText, 'config/name="[^"]*"', 'config/name="BCM32TutorialOwnerReview"', 1)
$settingsText = [regex]::Replace($settingsText, 'run/main_scene="[^"]*"', 'run/main_scene="res://tools/owner-review/tutorial_review_bootstrap.tscn"', 1)
$settingsText = [regex]::Replace($settingsText, 'window/size/window_width_override=\d+', 'window/size/window_width_override=432', 1)
$settingsText = [regex]::Replace($settingsText, 'window/size/window_height_override=\d+', 'window/size/window_height_override=960', 1)
Set-Content -LiteralPath $projectSettings -Value $settingsText -Encoding utf8NoBOM

# Keep a one-click shortcut available on the owner's Desktop. It points to
# this versioned launcher in the detached review worktree.
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($desktopShortcut)
$shortcut.TargetPath = (Get-Command 'powershell.exe').Source
$shortcut.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $PSScriptRoot 'launch_tutorial_review.ps1') + '"'
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.IconLocation = "$godotPath,0"
$shortcut.Description = 'Open the isolated interactive Beach Cocktails gameplay tutorial for owner review.'
$shortcut.Save()

# The process is intentionally left running for owner interaction. Do not add
# --headless, --quit, or automatic process cleanup to this graphical launch.
$game = Start-Process -FilePath $godotPath -ArgumentList @('--path', $reviewProject, '--rendering-method', 'gl_compatibility') -PassThru
Write-Output "Tutorial review window started (PID $($game.Id))."
Write-Output "Desktop shortcut: $desktopShortcut"
Write-Output "Isolated project: $reviewProject"
Write-Output 'Isolated Godot user data: %APPDATA%\Godot\app_userdata\BCM32TutorialOwnerReview'
