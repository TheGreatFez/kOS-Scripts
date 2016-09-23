clearscreen.
lock throttle to .5.
SAS on.
log 1 to air.csv.
delete air.csv.
log "Altitude,Pressure,Airspeed,Q,Cd,Thrust,Accel,Mass,G" to air.csv.
lock pressure to ship:sensors:pres.
lock g to vdot(UP:vector,ship:sensors:grav).
lock accel to vdot(UP:vector,ship:sensors:acc).
set p0 to pressure.
set tval to 1.
set RefSurf to 10.76.
lock drag to throttle*ship:maxthrust - accel*mass - g*mass.
lock Cd to drag/(RefSurf*ship:dynamicpressure).

stage.
wait 1.

until altitude > 70000 {

	log altitude +","+ pressure +","+ airspeed +","+ ship:dynamicpressure +","+ Cd +","+ throttle*ship:maxthrust +","+ accel +","+ mass +","+ g  to air.csv.
	
	print "Cd     = " + round(Cd,3)+ "     " at (0,0).
	print "Drag   = " + round(drag,3)+ "     " at (0,2).
	print "Thrust = " + round(throttle*ship:maxthrust,3)+ "     " at (0,4).
	print "Mass   = " + round(mass,3)+ "     " at (0,6).
	print "Weight = " + round(mass*g,2)+ "     " at (0,8).
	print "Accel  = " + round(accel,2)+ "     " at (0,10).
	print "W+A    = " + round(-accel*mass - g*mass,2)+ "     " at (0,12).
	print "Q      = " + round(ship:dynamicpressure,2) + "     " at (0,14).
	
	wait .1.

}

