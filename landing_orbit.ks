// ASSUME EQUATORIAL CIRCULAR ORBIT
parameter target_ltlng is LATLNG(5,120), landing_peri is 20000.
clearscreen.
for n in ALLNODES { remove n.}
clearvecdraws().
set show_vecdraws to true.

function ETA_to_theta {

	parameter theta_test.
	
	local orbit_test to ship:orbit.
	local mnv_time to 0.
	
	if HASNODE {
		set orbit_test to nextnode:orbit.
		set mnv_time to nextnode:eta.
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

function Vec_To_Node {
	parameter des_vec, mnv_time.
	
	local vel_vec to velocityat(ship,time:seconds + mnv_time):orbit.
	
	local norm_vec to vcrs(ship:body:position,ship:velocity:orbit):normalized.
	local prog_vec to vel_vec:normalized.
	local radi_vec to VCRS(norm_vec,prog_vec).
	
	local burn_vec to des_vec - vel_vec.
	
	local norm_comp to VDOT(norm_vec,burn_vec).
	local prog_comp to VDOT(prog_vec,burn_vec).
	local radi_comp to VDOT(radi_vec,burn_vec).
	
	local mynode to NODE(time:seconds + mnv_time,radi_comp,norm_comp,prog_comp).
	add mynode.
}

function Des_Peri_RadialBurn {
	parameter des_peri.
	
	local a to ship:orbit:Semimajoraxis.
	local u to ship:body:mu.
	local V0 to ship:velocity:orbit:mag.
	local R to ship:body:position:mag.
	local Rp to des_peri + ship:body:radius.
	local Ra to 2*a - Rp.
	local e to (Ra - Rp)/(Ra + Rp).
	local A to sqrt(a*u*(1-e^2)).
	local B to V0*R.
	local rad_des to ARCCOS(A/B).
	
	return rad_des.
}

function Set_Landing_Orbit_vec {
	parameter des_inc, des_peri, mnv_time.
	
	local vel_vec to velocityat(ship,time:seconds + mnv_time):orbit.
	local pos_vec to positionat(ship,time:seconds + mnv_time).
	local body_vec to pos_vec - ship:body:position.
	
	local angle_rotate_inc to ANGLEAXIS(des_inc,-body_vec).
	local new_vel_vec to vel_vec*angle_rotate_inc.
	local new_norm to VCRS(body_vec,new_vel_vec).
	local rad_des to Des_Peri_RadialBurn(landing_peri).
	
	local angle_rotate_rad to ANGLEAXIS(rad_des,new_norm). 
	local new_vel_vec to new_vel_vec*angle_rotate_rad.
	
	return new_vel_vec.
}

// Main
local time_test to 30.
local landing_vec to Set_Landing_Orbit_vec(target_ltlng:LAT,landing_peri,time_test).

Vec_To_Node(landing_vec,time_test).

local peri_time to ETA_to_theta(0).
local peri_pos to positionat(ship,time:seconds + peri_time).
local long_offset to 360*(peri_time)/ship:body:rotationperiod.
local peri_ltlng_pre to ship:body:GEOPOSITIONOF(peri_pos).
local peri_ltlng to LATLNG(peri_ltlng_pre:LAT, peri_ltlng_pre:LNG + long_offset).
local long_diff to target_ltlng:LNG - peri_ltlng:LNG.

local period_diff to 1/ship:orbit:period - 1/ship:body:rotationperiod.
print long_diff.

local long_fix to(long_diff/360)/period_diff.
print long_fix.
local time_test to time_test + long_fix.
remove nextnode.
local landing_vec to Set_Landing_Orbit_vec(target_ltlng:LAT,landing_peri,time_test).
Vec_To_Node(landing_vec,time_test).

if show_vecdraws {
	set target_ltlng_draw to vecdraw().
	set target_ltlng_draw:startupdater to { return target_ltlng:position. }.
	set target_ltlng_draw:vecupdater to { return target_ltlng:position - ship:body:position. }.
	set target_ltlng_draw:show to true.
	set target_ltlng_draw:color to RGB(255,255,255).
}

wait until false.
// Determine the angle ALPHA to rotate a circular orbit velocity vector in order to achieve a desired periapsis.
// 
// *************** Known ***************
// 
// mew = Gravitational Parameter of Body
// 
// h = Angular Momentum of Ship
// 
// p = h^2/mew
// 
// h = V_perpendicular*R
// 
// V0 = Circular Orbit Speed
// 
// V_perpendicular = V0*cos(ALPHA)
// 
// a = Semi Major Axis of Orbit (constant)
// 
// e = Eccentricty of Desired Orbit
// 
// Rc = Radius of Circular Orbit
// 
// Rp = Periapsis Radius (Input)
// 
// Ra = Apoapsis Radius
// 
// *************** Starting Equation ***************
// 
// a = P/(1 - e^2)
// 
// *************** Derivation ***************
// 
// Ra = 2*a - Rp
// 
// e = (Ra - Rp)/(Ra + Rp)
// 
// a*(1 - e^2) = P
// 
// a*(1 - e^2) = h^2/mew
// 
// flip sides
// 
// h^2 = (a*(1 - e^2))/mew
// 
// V_perpendicular*Rc = (V0*cos(ALPHA)*Rc)^2 = (a*(1 - e^2))/mew
// 
// cos(ALPHA) = sqrt((a*(1 - e^2))/mew)/(V0*Rc)
// 
// ALPHA = cos(sqrt((a*(1 - e^2))/mew)/(V0*Rc))^-1