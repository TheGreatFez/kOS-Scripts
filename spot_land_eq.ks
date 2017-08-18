// Script to do a spot landing on equatorial trajectory.
set landing_pos to LATLNG(0,140).
SAS OFF.
run executenode.
warpto(time:seconds + eta:periapsis).
declare function Hysteresis {
	declare parameter input,prev_output, right_hand_limit, left_hand_limit,right_hand_output is true.
	set output to prev_output.
	if prev_output = right_hand_output {
		if input <= left_hand_limit {
			set output to not(right_hand_output).
		}
	} else {
		if input >= right_hand_limit {
			set output to right_hand_output.
		}
	}
	return output.
}

declare function Vmax_v {
	declare parameter buffer_terrain is 10, TouchDownSpeed is 5.
	local true_alt to altitude - ship:geoposition:terrainheight.
	local V to ship:velocity:orbit.
	local R to ship:body:position.
	local Vper to VDOT(VCRS(R,VCRS(V,R)):normalized,V).
	local AccelCent to (Vper^2)/R:mag.
	local MaxThrustAccUp to availablethrust/mass.
	local GravUp to (-1)*(ship:body:mu)/((R:mag)^2).
	local MaxAccUp to MaxThrustAccUp + GravUp + AccelCent.
	local FPAsurf to 90 - VANG(UP:vector,ship:velocity:surface).
	local Vmax to sqrt(MAX(0,2*(true_alt - buffer_terrain)*MaxAccUp + TouchDownSpeed^2)).
	return Vmax.
}

declare function Vmax_h {
	declare parameter buffer_dist is 10.
	local R to ship:body:position.
	local V to ship:velocity:orbit.
	local MaxThrustAccHor to availablethrust/mass.
	local angle_diff_h to VANG(-R, landing_pos:position - R).
	local dist_diff_h to (angle_diff_h/360)*2*(constant:pi)*R:mag.
	local Vmax to sqrt(MAX(0,2*(dist_diff_h - buffer_dist)*MaxThrustAccHor)).
	
	local dir_check_vel to VCRS(V,R).
	local dir_check_pos to VCRS(-R,landing_pos:position-R).
	local dir_check to 1.
	if VDOT(dir_check_vel,dir_check_pos) > 0 {
		set dir_check to 1.
	} else {
		set dir_check to -1.
	}
	
	return dir_check*Vmax.
}

declare function delta_v_side {
	local R to ship:body:position.
	local V to ship:velocity:surface.
	local S to V:mag.
	local V_side to VCRS(V,R):normalized.
	local V_per to VCRS(R,V_side):normalized.
	local T_vec to VCRS(R,VCRS(landing_pos:position,R)):normalized.
	local delta_v to VDOT(V_side,(T_vec*S - V_per*S)).
	//local delta_v to (T_vec*S - V_per*S):mag.
	//local ang to VANG(V_per,T_vec).
	//local delta_v to 2*S*sin(ang/2).
	return delta_v.
}

lock R to ship:body:position.
lock V_surf to ship:velocity:surface.
lock Velocity_h_norm to VCRS(VCRS(R,ship:velocity:orbit),R):normalized.
lock Speed_h to VDOT(Velocity_h_norm,ship:velocity:orbit).
lock speed_diff_h to Speed_h-landing_pos:altitudevelocity(altitude):orbit:mag.

lock V_vec to UP:vector.
lock H_vec to VCRS(R,VCRS(V_surf,R)):normalized.
lock S_vec to VCRS(V_surf,R):normalized.

set KP_V to .01.
set KD_V to 0.04.
set V_throttle_PID to PIDLOOP(KP_V,0,KD_V,0,1).
set V_throttle_PID:setpoint to Vmax_v().

set KP_H to .01.
set KD_H to 0.02.
set H_throttle_PID to PIDLOOP(KP_H,0,KD_H,0,1).
set H_throttle_PID:setpoint to Vmax_h().

set KS to 1/5. // Time constant
set S_throttle to ((delta_v_side()*KS)*mass)/availablethrust.

set throttle_vec to V_vec*V_throttle_PID:update(time:seconds,-1*verticalspeed) + H_vec*H_throttle_PID:update(time:seconds,speed_diff_h) + S_vec*S_throttle.

lock steering to throttle_vec:direction.

clearscreen.

set throttle_hyst to false.
set throttle_hyst_UL to 10.
set throttle_hyst_LL to 5.

set LandingVector to VECDRAW(R:mag*(landing_pos:position - R):normalized,R,GREEN,"Landing Position",1.0,TRUE,.5).
set LandingVector:vectorupdater to { return R:mag*(landing_pos:position - R):normalized.}.
set LandingVector:startupdater to { return R.}.
until false {
	
	set S_throttle to ((delta_v_side()*KS)*mass)/availablethrust.
	set V_throttle_PID:setpoint to Vmax_v().
	set H_throttle_PID:setpoint to Vmax_h().
		
	set throttle_vec to V_vec*(1-V_throttle_PID:update(time:seconds,-1*verticalspeed)) - H_vec*(1-H_throttle_PID:update(time:seconds,speed_diff_h)) + S_vec*S_throttle.
	set throttle_hyst to Hysteresis(100*throttle_vec:mag,throttle_hyst, throttle_hyst_UL, throttle_hyst_LL).
	
	if throttle_hyst {
		lock throttle to throttle_vec:mag.
		lock steering to LOOKDIRUP(throttle_vec,UP:vector).
	} else {
		lock throttle to 0.
		lock steering to LOOKDIRUP(retrograde:vector,UP:vector).
	}
	
	print "V_throttle = " + round(100*(1-V_throttle_PID:output),0) + "%   "at(0,0).
	print "H_throttle = " +round(100*(1-H_throttle_PID:output),0) + "%   " at(0,1).
	print "S_throttle = " +round(100*S_throttle,0) + "%   " at(0,2).
	print "Vmax_v = " +round(Vmax_v,2) at(0,3).
	print "Vspeed = " +round(verticalspeed,2) at(0,4).
	print "Vmax_h = " +round(Vmax_h,2) at(0,5).
	print "Vspeed_h = " +round(speed_diff_h,2) at(0,6).
	print "Longitude = " +round(ship:geoposition:lng,2) at(0,7).
	print "Throttle = " + round(100*throttle_vec:mag,0) at(0,8).
	print "throttle_hyst = " + throttle_hyst + "   " at(0,9).
	
	wait 0.
}