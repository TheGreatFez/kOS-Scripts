// This script calculates a Maneuver Node to intercept a target vessel. It is assumed both target and ship are in near circular orbits
clearscreen.
for node in allnodes {remove node.}

declare function ExecuteNode {
	clearscreen.
	lock throttle to 0.
	SAS off.
	lock DeltaV to nextnode:deltav:mag.
	set BurnTime to .5*DeltaV*mass/availablethrust.
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
	lock throttle to DeltaV*mass/availablethrust.
	print "Executing Node".
	
	until DeltaV <= .1 {
		print "Delta V = " + round(DeltaV,1) + "   " at(0,1).
		print "Throttle = " + MIN(100,round(throttle*100)) + "%   " at(0,2).
	}
	lock throttle to 0.
	unlock all.
	remove nextnode.
	clearscreen.
	print "Node Executed".
}

declare function Circularize_per{
	set Vper_cir to sqrt(ship:body:mu/(ship:body:radius + periapsis)).
	set DeltaV to  Vper_cir - VELOCITYAT(ship,time:seconds + eta:periapsis):orbit:mag.
	set CirPer to NODE(TIME:seconds + eta:periapsis, 0, 0, DeltaV).
	ADD CirPer.
	wait 1.
	ExecuteNode().
	}
declare function Circularize_apo{
	set Vapo_cir to sqrt(ship:body:mu/(ship:body:radius + apoapsis)).
	set DeltaV to  Vapo_cir - VELOCITYAT(ship,time:seconds + eta:apoapsis):orbit:mag.
	set CirPer to NODE(TIME:seconds + eta:apoapsis, 0, 0, DeltaV).
	ADD CirPer.
	wait 1.
	ExecuteNode().
	}
set R1 to ship:orbit:semimajoraxis.
set R2 to target:orbit:semimajoraxis.
if R1 < R2 {
	set Warp_P_or_A to "Apoapsis".
	} else {
	set Warp_P_or_A to "Periapsis".
	}
if (min(R1,R2)/(max(R1,R2))) > 0.99 { // When the target and ship have very close orbits, we will go ahead and try and match the orbits as close as we can
	// Match as close as you can to the target's circular orbit height.
	print "Orbits are Close Enough To Phase without Transfer".
	print "Burning to match intercept altitude more closely".
	set R_planet to ship:body:radius.
	set Rp to periapsis + R_planet.
	if Rp < R2 { // Decide whether we need to increase or decrease the periapsis
		set ecc_fix to (R2 - Rp)/(Rp + R2).
		set SMA_fix to (R2 + Rp)/2.
		set V_per_fix to sqrt(((1+ecc_fix)*ship:body:mu)/((1-ecc_fix)*SMA_fix)).
		set Delta_V_fix to V_per_fix - VELOCITYAT(ship,time:seconds + eta:periapsis):orbit:mag.
		} else {
		set ecc_fix to (Rp - R2)/(Rp + R2).
		set SMA_fix to (R2 + Rp)/2.
		set V_apo_fix to sqrt(((1-ecc_fix)*ship:body:mu)/((1+ecc_fix)*SMA_fix)).
		set Delta_V_fix to V_apo_fix - VELOCITYAT(ship,time:seconds + eta:periapsis):orbit:mag.
		}
	if Delta_V_fix > 0.1 {
		set fixnode to NODE(TIME:seconds + eta:periapsis, 0, 0, Delta_V_fix).
		ADD fixnode.
		wait 5.
		ExecuteNode().
		if (R2-periapsis-R_planet) < (R2 - apoapsis - R_planet) {
			Circularize_per().
			} else {
			Circularize_apo().
			}
	}
	clearscreen.
	}
set a_trans to (R1+R2)/2.
set ecc_trans to abs(R2-R1)/(R1+R2).
lock T_ship to ship:orbit:period.
lock T_target to target:orbit:period.
set T_trans to 2*constant:pi*sqrt((a_trans^3)/ship:body:MU).
set Phase_burn to (T_trans/T_target)*180.
set Phase_ang_tol to 20.
lock Ship_TA to ship:orbit:trueanomaly.
lock Ship_ecc to ship:orbit:eccentricity.

lock Ship_angvel to VCRS(ship:velocity:orbit,(ship:position-ship:body:position)):normalized.
set Phase_ang to VANG(-1*ship:body:position,target:position-ship:body:position).
lock vec_check to VCRS(-1*ship:body:position,target:position-ship:body:position):normalized + Ship_angvel.

if vec_check:mag > 1 {
	set Phase_ang to 360-Phase_ang.
}

set Burn_TA to Ship_TA + (Phase_ang - (180-Phase_burn)).

if Burn_TA > 360 {
	set Burn_TA to Burn_TA - 360.
}
if Burn_TA < 0 {
	set Burn_TA to Burn_TA + 360.
}

set Ship_EA to 2*ARCTAN((TAN(Ship_TA/2))/sqrt((1+Ship_ecc)/(1-Ship_ecc))).
set Ship_MA to Ship_EA*constant:pi/180 - Ship_ecc*SIN(Ship_EA).
set Burn_EA to 2*ARCTAN((TAN(Burn_TA/2))/sqrt((1+Ship_ecc)/(1-Ship_ecc))).
set Burn_MA to Burn_EA*constant:pi/180 - Ship_ecc*SIN(Burn_EA).
set n to sqrt(ship:body:mu/(ship:orbit:semimajoraxis)^3).
set Burn_eta_A to (Burn_MA-Ship_MA)/n.

if Burn_eta_A < 0 {
	set Burn_eta_A to ship:orbit:period + Burn_eta_A.
}

set Delta_V_trans to sqrt(ship:body:mu*(2/R1 - 1/a_trans))-sqrt(ship:body:mu/ship:orbit:semimajoraxis).

set Phase_burn_test to 180-Phase_burn.
set Phase_dot to -1*360/T_ship + 360/T_target.
set T_burn to (Phase_burn_test - Phase_ang)/Phase_dot.
if T_burn < 0{
	if Phase_dot < 0{
		set T_burn to T_burn + T_ship.
	}
	else {
		set T_burn to (Phase_burn_test - Phase_ang + 360)/Phase_dot.
	}
}

// Solution B is to increase the time period
// Solution C is to decrease the time period
if (min(R1,R2)/(max(R1,R2))) > 0.99 { //For when the ships are in almost the same exact orbit.
	// Match as close as you can to the target's circular orbit height.
	set Phase_Time_B to ((360-Phase_ang)/360)*T_target.
	set Phase_Time_C to (Phase_ang/360)*T_target.
	set N_B to 1.
	set N_C to 1.
	set solution_B to 0.
	set solution_C to 0.
	set solution to 0.
	until solution >= 2 {
		if solution_B <= 0 {
			set RdzTime_B to T_target + Phase_Time_B/N_C.
			set SMA_B to ((((RdzTime_B)/(2*(constant:pi)))^2)*ship:body:mu)^(1/3).
			set New_apo_B to SMA_B*2 - (periapsis + R_planet).
			set solution_B to 1.
			set WaitTime_B to RdzTime_B*N_B.
			}
		if solution_C <=0 {
			set RdzTime_C to T_target - Phase_Time_C/N_C.
			set SMA_C to ((((RdzTime_C)/(2*(constant:pi)))^2)*ship:body:mu)^(1/3).
			set New_per_C to SMA_C*2 - (periapsis + R_planet).
			set TEST to New_per_C - (R_planet + ship:body:atm:height).
			if New_per_C < 0 OR TEST < 0{
				set N_C to N_C + 1.
				} else {
				set solution_C to 1.
				}
			set WaitTime_C to RdzTime_C*N_C.
			}
		set solution to solution_B + solution_C.
	}
	if WaitTime_B < WaitTime_C {
		set ecc_B to ( New_apo_B - R1)/(New_apo_B + R1).
		set V_per to sqrt(((1+ecc_B)*ship:body:mu)/((1-ecc_B)*SMA_B)).
		set Delta_V_alt to V_per - sqrt(ship:body:mu/R1).
		set Warp_P_or_A to "Periapsis".
		} else {
		set ecc_C to (R1 - New_per_C)/(New_per_C + R1).
		set V_apo to sqrt(((1-ecc_C)*ship:body:mu)/((1+ecc_C)*SMA_C)).
		set Delta_V_alt to V_apo - sqrt(ship:body:mu/R1).
		set Warp_P_or_A to "Apoapsis".
		}
} else {
	set WaitTime_B to (T_burn+T_trans/2)*2.
	set WaitTime_C to (T_burn+T_trans/2)*2.
	}

if (T_burn+T_trans/2) < min(WaitTime_B,WaitTime_C) {
	set node_eta_sel to T_burn.
	set Delta_V to Delta_V_trans.
	} else {
	set node_eta_sel to eta:periapsis.
	set Delta_V to Delta_V_alt.
	}
//print "Phase_burn_test = " + round(Phase_burn_test).
lock Target_angvel to VCRS(target:velocity:orbit,(target:position-Kerbin:position)):normalized.

set PlaneAngDiff to VANG(Ship_angvel,Target_angvel).
if PlaneAngDiff < 0.01 {
	set mynode to NODE(TIME:seconds + node_eta_sel, 0, 0, Delta_V).
	ADD mynode.
	//clearscreen.
	print "Maneuver Node Added".
	print "Executing Burn".
	wait 3.
} else {
	clearscreen.
	print "WARNING: Inclination Difference greater than 0.01 degrees!".
	wait 3.
}
ExecuteNode().
clearscreen.
print "Setting Up Maneuver Node at Intercept Point".
wait 3.
if Warp_P_or_A = "Periapsis" {
	Circularize_per().
	} else {
	Circularize_apo().
	}
clearscreen.
print "Rendezvous Maneuver Complete".
wait 3.