[CmdletBinding()]
param(
	[Parameter(Mandatory)][string]$EvidenceRoot,
	[Parameter(Mandatory)][string]$AttemptId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$modulePath = Join-Path $PSScriptRoot 'm34_r20_recovery.psm1'
Import-Module $modulePath -Force
$result = Repair-R19IncompleteTrials -EvidenceRoot $EvidenceRoot -AttemptId $AttemptId
Write-Output (($result | ConvertTo-Json -Depth 20 -Compress) + "`n")
