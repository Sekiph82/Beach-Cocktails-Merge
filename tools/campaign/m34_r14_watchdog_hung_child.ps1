param([Parameter(Mandatory = $true)][string]$TaskMarker)

Write-Output "SYNTHETIC_HUNG_CHILD_STARTED marker=$TaskMarker pid=$PID"
while ($true) { Start-Sleep -Seconds 1 }
