declare parameter OrbitAlt.
set ship:control:pilotmainthrottle to 0.
clearscreen.
set circstage to 3.

set flightmode to 0.
set compass to 90.
//set OrbitAlt to 100000.

lock pitch to sqrt((90^2)*altitude/70000).

lock steering to heading(compass,90-pitch).

lock throttle to 1.
stage.
set starttime to time:seconds.
wait 1.
set MAX to maxthrust.
set BurnTime to 0.
set DeltaV to 0.

when maxthrust < MAX OR availablethrust = 0 then {
	lock throttle to 0.
	stage.
	lock throttle to 1.
	set MAX to maxthrust.
	preserve.
}

lock Q to 1000*ship:dynamicpressure.
set MaxQ to Q.
lock AeroSwitch to Q/MaxQ.

until ship:orbit:eccentricity < .0001 {

	if MaxQ <= Q {
		set MaxQ to Q.
	}
	
	if flightmode = 0 and AeroSwitch < .1 {
		lock FPAorbit to VANG(UP:vector,velocity:orbit).
		lock pitch to FPAorbit.
		set flightmode to 1.
	}
	
	if flightmode = 1 AND apoapsis >= .9*OrbitAlt {
		lock throttle to .5.
		wait .5.
		set flightmode to 2.
	}
	
	if flightmode <= 2 AND apoapsis >= OrbitAlt {
		lock throttle to 0.
		wait .5.
		set flightmode to 3.
	}
	
	if flightmode = 3 {
		lock Vper to VCRS(UP:vector,velocity:orbit/velocity:orbit:mag).
		lock Vcir to sqrt(ship:body:MU/ship:body:position:mag)*VCRS(Vper,UP:vector).
		lock DeltaV to Vcir - velocity:orbit.
		lock BurnTime to .5*DeltaV:mag*(mass/max(.0001,availablethrust)).
		lock steering to srfprograde.		
		set flightmode to 4.
	}
	
	if flightmode = 4 AND altitude >= 70000 {
		lock steering to DeltaV.
		wait 5.
		warpto(time:seconds + eta:apoapsis - BurnTime - 5).
		set flightmode to 5.
	}
	
	if flightmode = 5 AND BurnTime >= eta:apoapsis {
		lock throttle to DeltaV:mag*(mass/max(.0001,availablethrust)).
		set flightmode to 6.
	}
		
	print "Flight Mode      " + flightmode at (0,1).
	print "MaxQ             " + round(MaxQ,2) at (0,2).
	print "Q                " + round(Q,2) at (0,3).
	print "Pitch            " + round(pitch,2) at (0,4).
	print "Ship Pitch       " + round(VANG(UP:vector,ship:facing:vector),2) at (0,5).
	print "Apoapsis         " + round(apoapsis,2) at (0,6).
	print "Target Apoapsis  " + round(OrbitAlt,2) at (0,7).
	print "Time to Apoapsis " + round(eta:apoapsis,2) at (0,8).
	print "BurnTime         " + round(BurnTime,2) at (0,9).
	print "Throttle         " + round(throttle,2) at (0,10).
}

lock throttle to 0.
unlock all.
set finishtime to time:seconds.
set totaltime to finishtime - starttime.
print "Time to Ascent       " + round(totaltime,2) at (0,20).