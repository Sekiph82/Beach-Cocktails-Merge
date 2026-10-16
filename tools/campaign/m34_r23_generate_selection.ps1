[CmdletBinding()]
param(
	[Parameter(Mandatory)][string]$OutputPath,
	[int]$Seed = 20261016
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$outputPath = [IO.Path]::GetFullPath($OutputPath)
if ([IO.File]::Exists($outputPath)) { throw "Immutable selection manifest already exists: $outputPath" }
$campaign = Get-Content -Raw (Join-Path $repoRoot 'data/campaign/islands.json') | ConvertFrom-Json -ErrorAction Stop
$sha = [Security.Cryptography.SHA256]::Create()
$counter = 0
function Get-DeterministicBelow([int]$MaxExclusive,[string]$Stream,[int]$FixedSeed,[ref]$Counter,[Security.Cryptography.SHA256]$Hasher) {
	if ($MaxExclusive -le 0) { throw 'Invalid deterministic RNG bound.' }
	$range = [uint64]4294967296
	$limit = [uint64]([Math]::Floor($range / [double]$MaxExclusive) * $MaxExclusive)
	while ($true) {
		$bytes = [Text.Encoding]::UTF8.GetBytes("$FixedSeed|$Stream|$($Counter.Value)")
		$Counter.Value = [int]$Counter.Value + 1
		$digest = $Hasher.ComputeHash($bytes)
		$value = [uint64][BitConverter]::ToUInt32($digest, 0)
		if ($value -lt $limit) { return [int]($value % [uint64]$MaxExclusive) }
	}
}

try {
	$selected = [System.Collections.Generic.List[object]]::new()
	$selectedByIsland = @{}
	foreach ($island in @($campaign.islands | Sort-Object { [int]$_.order_index })) {
		$levelFile = if ([string]$island.id -eq 'tiki_island') { 'tiki_island_full.json' } else { "{0}.json" -f [string]$island.id }
		$levelData = Get-Content -Raw (Join-Path $repoRoot "data/campaign/levels/$levelFile") | ConvertFrom-Json -ErrorAction Stop
		$levels = [System.Collections.Generic.List[int]]::new()
		foreach ($level in $levelData.levels) { $levels.Add([int]$level.level_id) }
		if ($levels.Count -ne 100 -or @($levels | Sort-Object -Unique).Count -ne 100) { throw "Expected exactly 100 unique canonical levels in $($island.id)." }
		for ($i = $levels.Count - 1; $i -gt 0; $i--) {
			$j = Get-DeterministicBelow -MaxExclusive ($i + 1) -Stream ([string]$island.id) -FixedSeed $Seed -Counter ([ref]$counter) -Hasher $sha
			$tmp = $levels[$i]; $levels[$i] = $levels[$j]; $levels[$j] = $tmp
		}
		$selectedByIsland[[string]$island.id] = @($levels | Select-Object -First 10)
	}
	for ($round = 0; $round -lt 10; $round++) {
		foreach ($island in @($campaign.islands | Sort-Object { [int]$_.order_index })) {
			$levelId = [int]$selectedByIsland[[string]$island.id][$round]
			$levelFile = if ([string]$island.id -eq 'tiki_island') { 'tiki_island_full.json' } else { "{0}.json" -f [string]$island.id }
			$levelData = Get-Content -Raw (Join-Path $repoRoot "data/campaign/levels/$levelFile") | ConvertFrom-Json -ErrorAction Stop
			$level = @($levelData.levels | Where-Object { [int]$_.level_id -eq $levelId } | Select-Object -First 1)[0]
			if ($null -eq $level) { throw "Selected level not found: $($island.id)/$levelId" }
			$vip = $false; if ($null -ne $level.vip -and $level.vip.PSObject.Properties.Name -contains 'enabled') { $vip = [bool]$level.vip.enabled }
			$globalId = (([int]$island.order_index - 1) * 100) + $levelId
			$selected.Add([ordered]@{round=$round+1;island_id=[string]$island.id;level_id=$levelId;global_level_id=$globalId;case_seed=(34230000+$globalId);runner_case_vip_enabled=$vip;vip_requirement='NOT_REQUIRED'})
		}
	}
	$value = [ordered]@{schema_version=1;work_item='BCM-M34-R23';sampling_rule='10 unique random levels per island, without replacement; reproducible interleaved rounds';algorithm='SHA-256(seed|island|counter) deterministic uint32 rejection sampling + Fisher-Yates';seed=$Seed;island_count=10;levels_per_island=100;sampled_per_island=10;total_selected=$selected.Count;created_before_any_new_trial_utc=[DateTime]::UtcNow.ToString('o');selection=@($selected)}
	[IO.Directory]::CreateDirectory((Split-Path -Parent $outputPath)) | Out-Null
	$json = ($value | ConvertTo-Json -Depth 8).Replace("`r`n", "`n")
	[IO.File]::WriteAllText($outputPath, $json + "`n", [Text.UTF8Encoding]::new($false))
	Write-Output "R23_SELECTION_CREATED path=$outputPath seed=$Seed levels=$($selected.Count) islands=$(@($campaign.islands).Count) sha256=$((Get-FileHash -Algorithm SHA256 $outputPath).Hash.ToLower())"
} finally { $sha.Dispose() }
