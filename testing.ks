clearvecdraws().
clearscreen.
set scale to 200.
for n in ALLNODES { remove n.}
parameter t_mnv is 300.
function ETA_to_theta {

	parameter theta_test.
	
	if HASNODE {
		set orbit_test to nextnode:orbit.
	} else {
		set orbit_test to ship:orbit.
	}
	
	local T_orbit to orbit_test:period.
	local theta_ship to orbit_test:trueanomaly.
	local e to orbit_test:eccentricity.
	local GM to ship:body:mu.
	local a to orbit_test:semimajoraxis.
	//clearscreen.
	
	local EA_ship to 2*ARCTAN((TAN(theta_ship/2))/sqrt((1+e)/(1-e))).
	local MA_ship to EA_ship*constant:pi/180 - e*SIN(EA_ship).
	local EA_test to 2*ARCTAN((TAN(theta_test/2))/sqrt((1+e)/(1-e))).
	local MA_test to EA_test*constant:pi/180 - e*SIN(EA_test).
	local n to sqrt(GM/(a)^3).
	local eta_to_testpoint to (MA_test - MA_ship)/n.
	if eta_to_testpoint < 0 {
		set eta_to_testpoint to T_orbit + eta_to_testpoint.
	}
	
//	print "ETA to " + round(theta_test,2) + " degrees True Anomaly is " + round(eta_to_testpoint,2) + " seconds".
//	wait 2.
	return eta_to_testpoint.
}

set target_ltlng to LATLNG(10,120).

set inc_des to target_ltlng:LAT.
set norm_vec to vcrs(ship:body:position,ship:velocity:orbit):normalized.
set vel_vec to velocityat(ship,time:seconds + t_mnv):orbit.
set prog_vec to vel_vec:normalized.
set radi_vec to VCRS(norm_vec,prog_vec).
set pos_vec to positionat(ship,time:seconds + t_mnv).
set body_vec to pos_vec - ship:body:position.

//
set pos_vec_draw to vecdraw().
set pos_vec_draw:startupdater to { return pos_vec. }.
set pos_vec_draw:vecupdater to { return -body_vec. }.
set pos_vec_draw:show to true.
set pos_vec_draw:color to RGB(255,0,0).
//
set vel_vec_draw to vecdraw().
set vel_vec_draw:startupdater to { return pos_vec. }.
set vel_vec_draw:vecupdater to { return scale*vel_vec. }.
set vel_vec_draw:show to true.
set vel_vec_draw:color to RGB(0,255,0).
//

set angle_rotate to ANGLEAXIS(inc_des,-body_vec).
set new_vel_vec to vel_vec*angle_rotate.

//
set new_vel_vec_draw to vecdraw().
set new_vel_vec_draw:startupdater to { return pos_vec. }.
set new_vel_vec_draw:vecupdater to { return scale*new_vel_vec. }.
set new_vel_vec_draw:show to true.
set new_vel_vec_draw:color to RGB(0,0,255).
//

set burn_vec to new_vel_vec - vel_vec.

//
set burn_vec_draw to vecdraw().
set burn_vec_draw:startupdater to { return pos_vec. }.
set burn_vec_draw:vecupdater to { return scale*burn_vec. }.
set burn_vec_draw:show to true.
set burn_vec_draw:color to RGB(0,255,255).
//

set norm_comp to VDOT(norm_vec,burn_vec).
set prog_comp to VDOT(prog_vec,burn_vec).
set radi_comp to VDOT(radi_vec,burn_vec).
print norm_comp.
print prog_comp.
set mynode to NODE(time:seconds + t_mnv,radi_comp-10,norm_comp,prog_comp).
add mynode.

set test_time to time:seconds + mynode:eta + ETA_to_theta(0).
set pos_test to positionat(ship,test_time).

//
set pos_test_draw to vecdraw().
set pos_test_draw:startupdater to { return ship:position. }.
set pos_test_draw:vecupdater to { return pos_test. }.
set pos_test_draw:show to true.
set pos_test_draw:color to RGB(0,0,255).
//
set long_offset to 360*(test_time-time:seconds)/ship:body:rotationperiod.
print "Offset " + long_offset.
set peri_ltlng_pre to ship:body:GEOPOSITIONOF(pos_test).
set peri_ltlng to LATLNG(peri_ltlng_pre:LAT, peri_ltlng_pre:LNG - long_offset).
print peri_ltlng_pre.
print peri_ltlng.


//
set peri_ltlg_draw to vecdraw().
set peri_ltlg_draw:startupdater to { return peri_ltlng:position. }.
set peri_ltlg_draw:vecupdater to { return peri_ltlng:position - ship:body:position. }.
set peri_ltlg_draw:show to true.
set peri_ltlg_draw:color to RGB(0,255,255).
//

//
set target_ltlng_draw to vecdraw().
set target_ltlng_draw:startupdater to { return target_ltlng:position. }.
set target_ltlng_draw:vecupdater to { return target_ltlng:position - ship:body:position. }.
set target_ltlng_draw:show to true.
set target_ltlng_draw:color to RGB(255,255,255).
//

wait until false.