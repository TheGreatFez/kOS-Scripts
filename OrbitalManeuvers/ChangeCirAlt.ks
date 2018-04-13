declare parameter R_new.

declare function vis_via_speed {
	parameter R, a is ship:orbit:semimajoraxis.
	local R_val to ship:body:radius + R.
	return sqrt(ship:body:mu*(2/R_val - 1/a)).
}

declare function circ_speed {
	parameter R.
	local R_val to ship:body:radius + R.
	return sqrt(ship:body:mu/R_val).
}

declare function ExecuteNode {
	clearscreen.
	lock throttle to 0.
	SAS off.
	lock Delta_V to nextnode:deltav:mag.
	local BurnTime to .5*Delta_V*mass/availablethrust.
	lock steering to nextnode.
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
	lock throttle to Delta_V*mass/availablethrust.
	print "Executing Node".
	
	until Delta_V <= .1 {
		print "Delta V = " + round(Delta_V,1) + "   " at(0,1).
		print "Throttle = " + MIN(100,round(throttle*100)) + "%   " at(0,2).
	}
	lock throttle to 0.
	unlock all.
	remove nextnode.
	clearscreen.
	print "Node Executed".
}

declare function Circularize_apo_Node{
	local Vapo_cir to circ_speed(apoapsis).
	local Delta_V to  Vapo_cir - vis_via_speed(apoapsis).
	local CirPer to NODE(TIME:seconds + eta:apoapsis, 0, 0, Delta_V).
	ADD CirPer.
	ExecuteNode().
}

declare function Circularize_per_Node{
	local Vper_cir to circ_speed(periapsis).
	local Delta_V to  Vper_cir - vis_via_speed(periapsis).
	local CirPer to NODE(TIME:seconds + eta:periapsis, 0, 0, Delta_V).
	ADD CirPer.
	ExecuteNode().
}

declare function HohmannTransfer {
	parameter R.
	local R_planet to ship:body:radius.
	local R_val to  R_planet + R.
	local R_p to periapsis + R_planet.
	local R_a to apoapsis + R_planet.
	local a to ship:orbit:semimajoraxis.
	
	local a_new to (R_p + R_val)/2.
	local V_trans to vis_via_speed(periapsis,a_new).
	print round(V_trans,2).
	local V_per to vis_via_speed(periapsis).
	print round(V_per,2).
	set Delta_V to V_trans - V_per.
	set HomTran to NODE(TIME:seconds + eta:periapsis, 0, 0, Delta_V).
	ADD HomTran.
	ExecuteNode().
}


// Main Body
set No_Nodes to false.
until No_Nodes {
	if hasnode {
		remove nextnode.
		wait 0.
	} else {
		set No_Nodes to true.
	}
}

if ship:body:atm:exists {
	
	set a to ship:orbit:semimajoraxis.
	
	if R_new < ship:body:atm:height {
		clearscreen.
		print "Cannot Reach Altitude, Atmosphere Present At Desired Height. Must be above " + round(ship:body:atm:height,0) + " meters".
	} else {
		clearscreen.
		print "Creating New Circular Orbit at " + round(R_new,0) + " meters".
		wait 2.
		HohmannTransfer(R_new).
		clearscreen.
		print "Circularizing at new altitude " + round(R_new,0) + " meters".
		wait 2.
		if altitude > a {
			Circularize_per_Node.
		} else {
			Circularize_apo_Node.
		}		
	}
} else {
	clearscreen.
	print "Creating New Circular Orbit at " + round(R_new,0) + " meters".
	HohmannTransfer(R_new).	
}