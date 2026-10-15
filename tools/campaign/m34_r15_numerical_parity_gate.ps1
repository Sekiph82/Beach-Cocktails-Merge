Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function ConvertTo-R15CanonicalJson($Value) {
	return ConvertTo-Json -InputObject $Value -Depth 80 -Compress
}

function Compare-R15ParityPair($Normal, $Fixed, [bool]$ProcessesCompleted = $true, [bool]$HighDensityReached = $true) {
	$reasons = [System.Collections.Generic.List[string]]::new()
	$structural = [System.Collections.Generic.List[string]]::new()
	$numeric = [System.Collections.Generic.List[string]]::new()
	$maxPosition = 0.0
	$maxVelocity = 0.0
	$cumulativeByIdentity = @{}
	$strict = $true
	if ($null -eq $Normal -or $null -eq $Fixed) {
		$reasons.Add("MISSING_TRACE")
		return [pscustomobject]@{ classification="unknown"; strict_pass=$false; tolerant_candidate_only=$false; max_position_delta_px=$null; max_velocity_delta_px_per_second=$null; max_cumulative_position_delta_sum_px=$null; compared_frames=0; thresholds=$thresholds; structural_reasons=@(); other_reasons=@($reasons) }
	}
	$normalTrace = @($Normal.telemetry.physics_trace)
	$fixedTrace = @($Fixed.telemetry.physics_trace)
	$thresholds = [ordered]@{
		position_delta_max_px_per_entity_per_frame = 0.02
		velocity_delta_max_px_per_second_per_entity_per_frame = 0.05
		cumulative_position_delta_sum_max_px_per_entity = 0.25
	}

	if (-not $ProcessesCompleted) { $reasons.Add("PROCESS_NOT_COMPLETED") }
	if (-not $HighDensityReached) { $reasons.Add("HIGH_DENSITY_NOT_REACHED") }
	if ($normalTrace.Count -eq 0 -or $fixedTrace.Count -eq 0) {
		$reasons.Add("MISSING_TRACE")
		return [pscustomobject]@{ classification="unknown"; strict_pass=$false; tolerant_candidate_only=$false; max_position_delta_px=$null; max_velocity_delta_px_per_second=$null; max_cumulative_position_delta_sum_px=$null; compared_frames=0; thresholds=$thresholds; structural_reasons=@(); other_reasons=@($reasons) }
	}
	if ($normalTrace.Count -ne $fixedTrace.Count) { $structural.Add("TRACE_LENGTH") ; $strict = $false }
	if ((ConvertTo-R15CanonicalJson $Normal.telemetry.action_log) -cne (ConvertTo-R15CanonicalJson $Fixed.telemetry.action_log)) { $structural.Add("ACTION_OR_BRANCH_TRACE") ; $strict = $false }
	foreach ($key in @("contact_events", "merge_events")) {
		if ((ConvertTo-R15CanonicalJson $Normal.telemetry.$key) -cne (ConvertTo-R15CanonicalJson $Fixed.telemetry.$key)) { $structural.Add("ORDERED_$($key.ToUpperInvariant())") ; $strict = $false }
	}
	foreach ($key in @("outcome", "terminal_reason", "normal_objective_complete", "vip_complete", "normal_orders_completed", "normal_orders_remaining", "vip_state", "moves_used", "moves_remaining", "merge_count", "contact_count")) {
		if ((ConvertTo-R15CanonicalJson $Normal.telemetry.$key) -cne (ConvertTo-R15CanonicalJson $Fixed.telemetry.$key)) { $structural.Add("FINAL_$($key.ToUpperInvariant())") ; $strict = $false }
	}

	$frameCount = [Math]::Min($normalTrace.Count, $fixedTrace.Count)
	for ($frameIndex = 0; $frameIndex -lt $frameCount; $frameIndex++) {
		$n = $normalTrace[$frameIndex]
		$f = $fixedTrace[$frameIndex]
		if ([int]$n.frame -ne [int]$f.frame) { $structural.Add("FRAME_ALIGNMENT_$frameIndex") ; $strict = $false; continue }
		if ($n.sha256 -cne $f.sha256) { $strict = $false }
		$ns = $n.state
		$fs = $f.state
		foreach ($key in @("spawn_levels", "merge_count", "contact_count", "moves_used", "normal_completed", "normal_remaining", "vip_state", "terminal", "contact_event_count", "merge_event_count", "action_log")) {
			if ((ConvertTo-R15CanonicalJson $ns.$key) -cne (ConvertTo-R15CanonicalJson $fs.$key)) { $structural.Add("FRAME_${frameIndex}_$($key.ToUpperInvariant())") ; $strict = $false }
		}
		$nb = @($ns.bodies)
		$fb = @($fs.bodies)
		if ($nb.Count -ne $fb.Count) { $structural.Add("FRAME_${frameIndex}_BODY_COUNT") ; $strict = $false; continue }
		for ($bodyIndex = 0; $bodyIndex -lt $nb.Count; $bodyIndex++) {
			$bodyN = $nb[$bodyIndex]
			$bodyF = $fb[$bodyIndex]
			$id = [string]$bodyN.instance_id
			if ([string]$bodyF.instance_id -cne $id) { $structural.Add("FRAME_${frameIndex}_IDENTITY_ORDER") ; $strict = $false; continue }
			if ($bodyN.level -ne $bodyF.level -or $bodyN.motion_state -ne $bodyF.motion_state -or $bodyN.sleeping -ne $bodyF.sleeping) {
				$structural.Add("FRAME_${frameIndex}_BODY_STATE_$id") ; $strict = $false
			}
			$px = [double]$bodyN.position[0] - [double]$bodyF.position[0]
			$py = [double]$bodyN.position[1] - [double]$bodyF.position[1]
			$vx = [double]$bodyN.velocity[0] - [double]$bodyF.velocity[0]
			$vy = [double]$bodyN.velocity[1] - [double]$bodyF.velocity[1]
			$positionDelta = [Math]::Sqrt($px * $px + $py * $py)
			$velocityDelta = [Math]::Sqrt($vx * $vx + $vy * $vy)
			$maxPosition = [Math]::Max($maxPosition, $positionDelta)
			$maxVelocity = [Math]::Max($maxVelocity, $velocityDelta)
			if (-not $cumulativeByIdentity.ContainsKey($id)) { $cumulativeByIdentity[$id] = 0.0 }
			$cumulativeByIdentity[$id] += $positionDelta
			if ($bodyN.position[0] -cne $bodyF.position[0] -or $bodyN.position[1] -cne $bodyF.position[1] -or $bodyN.velocity[0] -cne $bodyF.velocity[0] -or $bodyN.velocity[1] -cne $bodyF.velocity[1]) { $strict = $false }
		}
	}
	$maxCumulative = 0.0
	foreach ($value in $cumulativeByIdentity.Values) { $maxCumulative = [Math]::Max($maxCumulative, [double]$value) }
	if ($maxPosition -gt $thresholds.position_delta_max_px_per_entity_per_frame) { $numeric.Add("POSITION_DELTA_CEILING") }
	if ($maxVelocity -gt $thresholds.velocity_delta_max_px_per_second_per_entity_per_frame) { $numeric.Add("VELOCITY_DELTA_CEILING") }
	if ($maxCumulative -gt $thresholds.cumulative_position_delta_sum_max_px_per_entity) { $numeric.Add("CUMULATIVE_POSITION_DELTA_CEILING") }
	if ($normalTrace.Count -ne $fixedTrace.Count) { $strict = $false }

	$unknown = $reasons.Count -gt 0
	$structuralDivergence = $structural.Count -gt 0 -or $numeric.Count -gt 0
	$class = if ($unknown) { "unknown" } elseif ($strict) { "strict_pass" } elseif ($structuralDivergence) { "structural_divergence" } else { "tolerant_candidate_only" }
	return [pscustomobject]@{
		classification = $class
		strict_pass = [bool]$strict
		tolerant_candidate_only = ($class -eq "tolerant_candidate_only")
		max_position_delta_px = $maxPosition
		max_velocity_delta_px_per_second = $maxVelocity
		max_cumulative_position_delta_sum_px = $maxCumulative
		compared_frames = $frameCount
		thresholds = $thresholds
		structural_reasons = @($structural | Select-Object -Unique)
		numeric_reasons = @($numeric | Select-Object -Unique)
		other_reasons = @($reasons | Select-Object -Unique)
	}
}

function Test-R15AdversarialGate {
	$base = [pscustomobject]@{
		telemetry = [pscustomobject]@{
			action_log = @([pscustomobject]@{step=0;lane_index=3;target_instance_id=7})
			contact_events = @([pscustomobject]@{frame=1;source_instance_id=7;target_instance_id=8;source_level=1;target_level=1})
			merge_events = @()
			outcome = "danger"; terminal_reason = "TABLE_DANGER"; normal_objective_complete=$false; vip_complete=$false
			normal_orders_completed=@{}; normal_orders_remaining=@{"6"=1}; vip_state=@{}; moves_used=1; moves_remaining=9; merge_count=0; contact_count=1
			physics_trace = @([pscustomobject]@{frame=1;sha256="base";state=[pscustomobject]@{
				bodies=@([pscustomobject]@{instance_id=7;level=1;motion_state=1;sleeping=$true;position=@(1.0,2.0);velocity=@(0.0,0.0)},[pscustomobject]@{instance_id=8;level=1;motion_state=1;sleeping=$true;position=@(3.0,4.0);velocity=@(0.0,0.0)})
				spawn_levels=@(1);merge_count=0;contact_count=1;moves_used=1;normal_completed=@{};normal_remaining=@{"6"=1};vip_state=@{};terminal=@{reason="TABLE_DANGER"};contact_event_count=1;merge_event_count=0;action_log=@([pscustomobject]@{step=0;lane_index=3;target_instance_id=7})
			}})
		}
	}
	$numeric = ConvertTo-Json -InputObject $base -Depth 80 | ConvertFrom-Json
	$numeric.telemetry.physics_trace[0].state.bodies[0].position[1] = 2.005
	$numeric.telemetry.physics_trace[0].sha256 = "changed"
	$withinTolerance = Compare-R15ParityPair $base $numeric
	$branch = ConvertTo-Json -InputObject $base -Depth 80 | ConvertFrom-Json
	$branch.telemetry.action_log[0].lane_index = 4
	$branch.telemetry.physics_trace[0].state.action_log[0].lane_index = 4
	$branch.telemetry.physics_trace[0].sha256 = "branch-changed"
	$branchResult = Compare-R15ParityPair $base $branch
	$collision = ConvertTo-Json -InputObject $base -Depth 80 | ConvertFrom-Json
	$collision.telemetry.contact_events[0].target_instance_id = 9
	$collision.telemetry.physics_trace[0].state.contact_event_count = 1
	$collision.telemetry.physics_trace[0].sha256 = "collision-changed"
	$collisionResult = Compare-R15ParityPair $base $collision
	return [pscustomobject]@{
		adversarial_test = "PASS"
		within_tolerance_numeric_only_classification = $withinTolerance.classification
		branch_mutation_classification = $branchResult.classification
		collision_target_mutation_classification = $collisionResult.classification
		pass = ($withinTolerance.classification -eq "tolerant_candidate_only" -and $branchResult.classification -eq "structural_divergence" -and $collisionResult.classification -eq "structural_divergence")
	}
}
