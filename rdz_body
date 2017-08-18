// This script calculates a Maneuver Node to intercept a target body. It is assumed both target and ship are in near circular orbits
declare parameter target_periapsis is 100000.

clearscreen.
for node in allnodes {remove node.}

set R1 to ship:orbit:semimajoraxis.
set R2 to target:orbit:semimajoraxis.
if R1 < R2 {
	set Warp_P_or_A to "Apoapsis".
} else {
	set Warp_P_or_A to "Periapsis".
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

set Delta_V to sqrt(ship:body:mu*(2/R1 - 1/a_trans))-sqrt(ship:body:mu/ship:orbit:semimajoraxis).

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

lock Target_angvel to VCRS(target:velocity:orbit,(target:position-Kerbin:position)):normalized.

set PlaneAngDiff to VANG(Ship_angvel,Target_angvel).
if PlaneAngDiff < 0.01 {
	set mynode to NODE(TIME:seconds + T_burn, 0, 0, Delta_V).
	ADD mynode.
	//clearscreen.
	print "Maneuver Node Added".
	print "Moving to Periapsis Solver".
	wait 3.
} else {
	clearscreen.
	print "WARNING: Inclination Difference greater than 0.01 degrees!".
	wait 3.
}
lock orbit_check to nextnode:orbit:nextpatch.
set good_man to false.
if nextnode:orbit:hasnextpatch AND orbit_check:body = target {
	set test_periapsis to orbit_check:periapsis.
	set good_man to true.
}
set i to 1.
set delta to 2.
set delta_dir to -1.
set tollerance to .1.

until 	i >= 100 {
	
	set diff1 to abs(test_periapsis - target_periapsis).
	set Delta_V to Delta_V + delta*delta_dir.
	set nextnode:prograde to Delta_V.
	set test_periapsis to orbit_check:periapsis.
	set diff2 to abs(test_periapsis - target_periapsis).
	
	if diff2 > diff1 {
		set delta to delta/2.
		set delta_dir to -1*delta_dir.
	}
	
	if diff2 < tollerance {
		set bad_intercept to false.
		break.
		}
	
	set i to i+1.
	if i = 100 {
		if diff2 > 10*tollerance {
			set bad_intercept to true.
		} else {
			set bad_intercept to false.
		}
	}
	print "Iteration = " + i at(0,3).
	print "delta = " + delta at (0,4).
	print "delta_dir = " + delta_dir at (0,5).
	print "test_periapsis = " + round(test_periapsis,2) at (0,6).
	print "target_periapsis = " + target_periapsis at (0,7).
	
}
clearscreen. print "Solver finished".
if bad_intercept {
	print "Bad Intercept".
} else {
	print "Successful Intercept".
	print "Iterations " + i.
	print "Periapsis within " + round(diff2,4) + " meters".
	}
wait 3.
