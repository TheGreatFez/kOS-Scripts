// Script to do a spot landing on equatorial trajectory.
//set landing_pos to LATLNG(2,140).
//set landing_pos to LATLNG(-0.09720767,-74.557677).

SAS OFF.
run executenode.
wait 3.
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
	declare parameter buffer_terrain is 0, TouchDownSpeed is 5.
	local true_alt to altitude - ship:geoposition:terrainheight.
	local V to ship:velocity:orbit.
	local R to ship:body:position.
	local Vper to VDOT(VCRS(R,VCRS(V,R)):normalized,V).
	local AccelCent to (Vper^2)/R:mag.
	local MaxThrustAccUp to availablethrust/mass.
	local GravUp to (-1)*(ship:body:mu)/((R:mag)^2).
	local MaxAccUp to MaxThrustAccUp + GravUp + AccelCent.
	local FPAsurf to 90 - VANG(UP:vector,ship:velocity:surface).
	local Vmax to sqrt(MAX(0,2*(true_alt - buffer_terrain)*MaxAccUp - TouchDownSpeed^2)).
	return Vmax.
}

declare function Vmax_h {
	declare parameter  buffer_dist is 0.
	local R to ship:body:position.
	local V to ship:velocity:orbit.
	local MaxThrustAccHor to availablethrust/mass.
	local angle_diff_h to VANG(-R, landing_pos:position - R).
	local dist_diff_h to (angle_diff_h/360)*2*(constant:pi)*R:mag.
	local Vmax to sqrt(MAX(0.001,2*(dist_diff_h - buffer_dist)*MaxThrustAccHor)).
	
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
declare function Follow_throttle_func {
	local R to ship:body:position.
	local V to ship:velocity:surface.
	local V_ref to (V:mag)*(landing_pos:position:normalized).
	local h to altitude - landing_pos:terrainheight. // used to adjust the V_ref later
	local V_diff to V_ref - V.
	local throttle_sel to (V_diff*mass)/availablethrust.
	
	return throttle_sel.
}

declare function S_throttle_func {
	declare parameter t_0 is 1.
	local R to ship:body:position.
	local V to ship:velocity:surface.
	local S to V:mag.
	local V_side to VCRS(V,R):normalized.
	local V_per to VCRS(R,V_side):normalized.
	local T_vec to VCRS(R,VCRS(landing_pos:position,R)):normalized.
	local delta_v to -1*VDOT(V_side,(T_vec*S - V_per*S)).
	
	return delta_v.
}

lock R to ship:body:position.
lock V_surf to ship:velocity:surface.
lock g to ship:body:mu/(R:mag^2).
lock Velocity_h_norm to VCRS(VCRS(R,landing_pos:position),R):normalized.
lock Speed_h to VDOT(Velocity_h_norm,ship:velocity:surface).
lock speed_diff_h to Speed_h-landing_pos:altitudevelocity(altitude):orbit:mag.
lock true_alt to altitude - ship:geoposition:terrainheight.

lock V_vec to UP:vector.
lock H_vec to VCRS(R,VCRS(V_surf,R)):normalized.
lock S_vec to -1*VCRS(V_surf,R):normalized.

set KP_V to .01.
set KD_V to 0.005.
set V_throttle_PID to PIDLOOP(KP_V,0,KD_V,0,1).
set V_throttle_PID:setpoint to Vmax_v().

set KP_H to .01.
set KD_H to 0.002.//0.02.
set H_throttle_PID to PIDLOOP(KP_H,0,KD_H,-1,1).
set H_throttle_PID:setpoint to Vmax_h().

set KS to 1/5. // Time constant
set S_throttle to S_throttle_func(2).

set throttle_vec to V_vec*V_throttle_PID:update(time:seconds,-1*verticalspeed) + H_vec*H_throttle_PID:update(time:seconds,Speed_h) + S_vec*S_throttle.

lock steering to throttle_vec:direction.

lock land_surf to VANG(landing_pos:position,ship:velocity:surface).

clearscreen.

set touchdown_speed to -5.
set alt_cutoff to 100.

set throttle_hyst to false.
set throttle_hyst_UL to 75.
set throttle_hyst_LL to 1.

set ang_hyst to false.
set ang_hyst_UL to 50.
set ang_hyst_LL to 10.

set left_over_flag to false.
set Follow_Mode to false.
set TouchDown_Mode to false.

set LandingVector to VECDRAW((alt:radar)*(landing_pos:position - R):normalized,landing_pos:position,GREEN,"Landing Position",1.0,TRUE,.5).
set LandingVector:vectorupdater to { return (altitude-landing_pos:terrainheight)*(landing_pos:position - R):normalized.}.
set LandingVector:startupdater to { return landing_pos:position.}.

set LandingPositionVector to VECDRAW(V(0,0,0),landing_pos:position,RED,"Landing Vector",1.0,TRUE,.5).
set LandingPositionVector:vectorupdater to { return landing_pos:position.}.
set LandingPositionVector:startupdater to { return V(0,0,0).}.

set SurfaceVelocity to VECDRAW(V(0,0,0),ship:velocity:surface,BLUE,"Surface Velocity",1.0,TRUE,.5).
set SurfaceVelocity:vectorupdater to { return ship:velocity:surface.}.
set SurfaceVelocity:startupdater to { return V(0,0,0).}.

until ship:status = "LANDED" {
	
	
	set V_throttle_PID:setpoint to Vmax_v().
	set H_throttle_PID:setpoint to Vmax_h().
	if verticalspeed > touchdown_speed AND true_alt < alt_cutoff AND not(TouchDown_Mode){
		set TouchDown_Mode to True.
	}
	
	if TouchDown_Mode{
		set V_throttle to (1-(touchdown_speed-verticalspeed)/touchdown_speed)*mass*g/availablethrust.
		GEAR ON.
	} else {
		set V_throttle to MIN(1,1-V_throttle_PID:update(time:seconds,-1*verticalspeed)).
		GEAR OFF.
	}
	
	set H_throttle_test to MIN(1,1-H_throttle_PID:update(time:seconds,Speed_h)).
	//set H_throttle_test to H_throttle_func().
	
	set S_deltaV to S_throttle_func().
	if throttle_hyst {
		set S_throttle_enable to true.
		set S_throttle_test to (S_deltaV*mass)/(availablethrust*1).
	} else {
		set S_throttle_enable to false.
		set S_throttle_test to 0.
	}
	
	if (V_throttle^2 + H_throttle_test^2 + S_throttle_test^2) > 1 {
		set left_over_flag to True.
		set left_over to 1- V_throttle^2.
		if H_throttle_test > sqrt(left_over) {
			set H_throttle to MAX(0,MIN(H_throttle_test,sqrt(left_over))).
			set S_throttle to 0.
		} else {
			set H_throttle to H_throttle_test.
			set S_throttle to MAX(0,MIN(S_throttle_test,sqrt(left_over - H_throttle_test^2))).
		}
	} else {
		set left_over_flag to False.
		set S_throttle to S_throttle_test.
		set H_throttle to H_throttle_test.
	}
	set Follow_Mode_Ang to VANG(landing_pos:altitudeposition(altitude),landing_pos:position).
	if Follow_Mode_Ang >70 {
		set Follow_Mode to True.
	}
	if groundspeed < 10 AND not(Follow_Mode) {
		set Follow_Mode to True.
	}
	
	if Follow_Mode {
		set throttle_vec to V_vec*V_throttle + Follow_throttle_func().
	} else {
		set throttle_vec to V_vec*V_throttle - H_vec*H_throttle + S_vec*S_throttle.
	}
	
	set throttle_hyst_test to sqrt(V_throttle^2 + H_throttle^2).
	set ang_diff to VANG(throttle_vec,ship:facing:vector).
	set throttle_hyst to Hysteresis(100*throttle_hyst_test,throttle_hyst, throttle_hyst_UL, throttle_hyst_LL).
	set ang_hyst to Hysteresis(ang_diff,ang_hyst,ang_hyst_UL,ang_hyst_LL,False).
	
	if throttle_hyst {
		if ang_hyst {
			lock throttle to throttle_vec:mag.			lock steering to LOOKDIRUP(throttle_vec,facing:topvector).
		} else {
			lock throttle to 0.
			lock steering to LOOKDIRUP(throttle_vec,facing:topvector).
		}
	} else {
		lock throttle to 0.
		lock steering to LOOKDIRUP(srfretrograde:vector,facing:topvector).
	}
	
	print "V_throttle = " + round(100*(VDOT(V_vec,throttle_vec)),0) + "%   "at(0,0).
	print "H_throttle = " +round(100*(VDOT(H_vec,throttle_vec)),0) + "%   " at(0,1).
	print "S_throttle = " +round(100*(VDOT(S_vec,throttle_vec)),0) + "%   " at(0,2).
	print "Vmax_v = " +round(Vmax_v,2) at(0,3).
	print "Vspeed = " +round(verticalspeed,2) at(0,4).
	print "Vmax_h = " +round(Vmax_h,2) at(0,5).
	print "Vspeed_h = " +round(Speed_h,2) at(0,6).
	print "Longitude = " +round(ship:geoposition:lng,2) at(0,7).
	print "Throttle = " + round(100*throttle_vec:mag,0) + "%   " at(0,8).
	print "throttle_hyst = " + throttle_hyst + "   " at(0,9).
	print "left_over_flag = " + left_over_flag + "   " at(0,10).
	print "ang_diff = " + round(ang_diff,1) + "   " at(0,11).
	print "ang_hyst = " + ang_hyst + "   " at(0,12).
	print "S_deltaV = " + round(S_deltaV,2) + "   " at(0,13).
	print "groundspeed = " + round(groundspeed,2) + "   " at(0,14).
	print "land_surf = " + round(land_surf,2) + "   " at(0,15).
	print "Follow_Mode = " + Follow_Mode + "   " at(0,16).
	print "TouchDown_Mode = " + TouchDown_Mode + "   " at(0,17).
	print "S_throttle_enable = " + S_throttle_enable + "   " at(0,18).
	print "S_throttle_test = " + round(S_throttle_test,2) + "   " at(0,19).
	
	
	wait 0.
}
lock throttle to 0.
SAS ON.
wait 5.