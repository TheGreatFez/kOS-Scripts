SAS OFF.
RCS ON.
lock steering to (-1*target:facing:vector):direction.
until VANG(ship:facing:vector,(-1*target:facing:vector)) < 1 {
	print "Direction Angle Error = " + round(VANG(ship:facing:vector,(-1*target:facing:vector)),1) + "   "at(0,1).
}
list parts in p_list.
for part in p_list {
	if part:tag = "MainDockingPort" {
		set DP_part to part.
		}
	}

set Kp_star to 1.
set Ki_star to 0.
set Kd_star to 10.
clearscreen.
clearvecdraws().

set PID_star to PIDloop(Kp_star,Ki_star,Kd_star,-1.0,1.0).
set PID_top to PIDloop(Kp_star,Ki_star,Kd_star,-1.0,1.0).
set PID_fore to PIDloop(Kp_star,Ki_star,Kd_star,-1.0,1.0).

set PID_star:setpoint to 0.
set PID_top:setpoint to 0.
set PID_fore:setpoint to 0.

set fore_dist to 25.

lock star_error to -1*VDOT(DP_part:facing:starvector,vector5).
lock top_error to -1*VDOT(DP_part:facing:topvector,vector5).
lock fore_error to fore_dist - VDOT(DP_part:facing:vector,vector5).
	
set vec1 to VECDRAW(V(0,0,0),V(0,0,0),red,"FRONT",1.0,TRUE,0.2).
set vec2 to VECDRAW(V(0,0,0),V(0,0,0),green,"FRONT",1.0,FALSE,0.2).
set vec3 to VECDRAW(V(0,0,0),V(0,0,0),blue,"TOP",1.0,TRUE,0.2).
set vec4 to VECDRAW(V(0,0,0),V(0,0,0),green,"STAR",1.0,TRUE,0.2).
set vec5 to VECDRAW(V(0,0,0),V(0,0,0),white,"TARGET",1.0,TRUE,0.2).

set Phase to 1.
set dockingmode to 0.
until false {
	set vector1 to (target:position:mag)*DP_part:facing:vector.
	set vector2 to target:facing:vector.
	set vector3 to (target:position:mag)*DP_part:facing:topvector.
	set vector4 to (target:position:mag)*DP_part:facing:starvector.
	set vector5 to target:position - DP_part:position.
	
	set vec1:start to DP_part:position.
	set vec2:start to target:position.
	set vec3:start to DP_part:position.
	set vec4:start to DP_part:position.
	set vec5:start to DP_part:position.
	
	set vec1:vec to vector1.
	set vec2:vec to vector2.
	set vec3:vec to vector3.
	set vec4:vec to vector4.
	set vec5:vec to vector5.
	
	if target:istype("Part") {
		set relvelocity to ship:velocity:orbit - target:ship:velocity:orbit.
		} else {
		set relvelocity to ship:velocity:orbit - target:velocity:orbit.
		}
	
	set star_speed to VDOT(DP_part:facing:starvector,relvelocity).
	set top_speed to VDOT(DP_part:facing:topvector,relvelocity).
	set fore_speed to VDOT(DP_part:facing:vector,relvelocity).
	if Phase = 1 {
		set ship:control:top to 0.
		set ship:control:starboard to 0.
		set ship:control:fore to PID_fore:update(time:seconds,fore_error).
		if abs(fore_speed) < .1 AND abs(fore_error) < 1 {
			set Phase to 2.
			set dockingmode to 1.
			}
		}
	

	if Phase = 2 {
		if  dockingmode = 1 {
			set ship:control:starboard to PID_star:update(time:seconds,star_error).
			set ship:control:top to 0.
			set ship:control:fore to 0.
			
			if ABS(star_speed) < .1 AND ABS(star_error) < .1 {
				set dockingmode to 2.
				}
			}
			
		if dockingmode = 2 {
			set ship:control:top to PID_top:update(time:seconds,top_error).
			set ship:control:starboard to PID_star:update(time:seconds,star_error).
			set ship:control:fore to 0.
			
			if ABS(top_speed) < .1 AND ABS(top_error) < .1 {
				set dockingmode to 3.
				}
			}
			
		if dockingmode = 3 {
			set ship:control:top to PID_top:update(time:seconds,top_error).
			set ship:control:starboard to PID_star:update(time:seconds,star_error).
			set ship:control:fore to PID_fore:update(time:seconds,fore_error).
			if abs(fore_speed) < .1 AND abs(fore_error) < 1 {
				set dockingmode to 4.
				}		
			}
		if dockingmode = 4 {
			set ship:control:top to PID_top:update(time:seconds,top_error).
			set ship:control:starboard to PID_star:update(time:seconds,star_error).
			set ship:control:fore to PID_fore:update(time:seconds,fore_error).
			set fore_dist to .5*vector5:mag.
			}
		}
	print "Docking Mode " + dockingmode + " Phase " + Phase at (0,0).
	print "top_error = " + round(top_error,2) + "    "at (0,1).
	print "top_control = " + round(100*ship:control:top,2) + "%    " at (0,2).
	print "star_error = " + round(star_error,2) + "    "at (0,3).
	print "star_control = " + round(100*ship:control:starboard,2) + "%    " at (0,4).
	print "fore_error = " + round(fore_error,2) + "    "at (0,5).
	print "fore_control = " + round(100*ship:control:fore,2) + "%    " at (0,6).
	
	wait 0.
}