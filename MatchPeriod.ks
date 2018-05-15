parameter TP_target is ship:orbit:period.

local R1 to ship:body:radius + periapsis.
local body_mu to ship:body:mu.
for n in allnodes { remove n.}

function vis_via_speed {
	parameter R, a is ship:orbit:semimajoraxis.
	local R_val to ship:body:radius + R.
	return sqrt(ship:body:mu*(2/R_val - 1/a)).
}

function OrbitalPeriodMatch {
	parameter target_period is ship:orbit:period.
	print target_period.
	local SMA_new to ((body_mu*(target_period^2))/(4*(constant:pi()^2)))^(1/3).
	print SMA_new.
	local R2 to 2*SMA_new - R1.
	print R2.
	local V_per_current to vis_via_speed(periapsis).
	print V_per_current.
	local V_per_new to vis_via_speed(periapsis,SMA_new).
	local Delta_V to V_per_new - V_per_current.
	local PER_node to node(time:seconds + eta:periapsis,0,0,Delta_V).
	add PER_node.
	ExecuteNode.
	clearscreen.
	print "Executed Orbital Period Match to within 0.01 m/s".
	print "Orbital Periods are different by " + round(abs(ship:orbit:period - target_period,3)) + " sec".
	wait 2.
	return.
}

function ExecuteNode {
	clearscreen.
	lock throttle to 0.
	SAS off.
	lock DeltaV to nextnode:deltav:mag.
	local BurnTime to .5*DeltaV*mass/availablethrust.
	lock steering to LOOKDIRUP(nextnode:burnvector,facing:topvector).
	print "Aligning with Maneuver Node".
	until VANG(ship:facing:vector,nextnode:burnvector) < 1 {
		print "Direction Angle Error = " + round(VANG(ship:facing:vector,nextnode:burnvector),1) + "   "at(0,1).
	}
	clearscreen.
	print "Warping to Node".
	print "Burn Starts at T-minus " + round(BurnTime,2) + "secs   ".
	warpto(time:seconds + nextnode:eta - BurnTime - 10).
	wait until BurnTime >= nextnode:eta.

	clearscreen.
	lock throttle to DeltaV*mass/availablethrust.
	print "Executing Node".
	local runmode is 1.

	until DeltaV <= .01 {
		print "Delta V = " + round(DeltaV,2) + "   " at(0,1).
		print "Throttle = " + MIN(100,round(throttle*100)) + "%   " at(0,2).
		if runmode = 1 AND DeltaV < 0.5 {
			lock throttle to DeltaV*mass/(2*availablethrust).
			set runmode to 2.
		}
		wait 0.
	}
	lock throttle to 0.
	unlock all.
	remove nextnode.
	clearscreen.
	print "Node Executed".
	return.
}

if TP_target:istype("Vessel") {
	// Match Target Vessel Orbital Period
	clearscreen.
	print "Matching Orbital Period to " + TP_target:name.
	wait 2.
	clearscreen.
	set target_period to TP_target:orbit:period.
	print target_period.
	OrbitalPeriodMatch(target_period).
} else if TP_target:istype("Scalar") {
	// Match ship's orbital period to the target orbital period
	print "Setting Orbital Period to " + TP_target + " sec".
	wait 2.
	set target_period to TP_target.
	OrbitalPeriodMatch(target_period).	
} else {
	
	clearscreen.
	print "Incorrect target format. Please enter a valid target (either a target ship or target period)".
}