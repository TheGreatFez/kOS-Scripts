declare parameter OrbitAltKM.

set OrbitAlt to OrbitAltKM*1000.
set TargetSMA to ship:body:radius + OrbitAlt.
set ship:control:pilotmainthrottle to 0.
clearscreen.
set circstage to 3.

set flightmode to 0.
set compass to 90.
//set OrbitAlt to 100000.
set starting_alt to altitude.

lock pitch to sqrt((90^2)*MAX(0,(altitude-2*starting_alt))/50000).

lock steering to heading(compass,90-pitch).
set thrustset to 1.
lock throttle to thrustset.
	
stage.
set starttime to time:seconds.
set startlong to ship:longitude.
wait 1.
set MAX to maxthrust.
set BurnTime to 0.
set DeltaV to 0.

lock e to ship:orbit:eccentricity.
lock a to ship:orbit:semimajoraxis.
lock u to ship:body:mu.

when maxthrust < MAX OR availablethrust = 0 then {
	stage.
	set MAX to maxthrust.
	preserve.
}

lock Q to 1000*ship:dynamicpressure.
set MaxQ to Q.
lock AeroSwitch to Q/MaxQ.

until e <= .001 OR a >= TargetSMA {

	if MaxQ <= Q {
		set MaxQ to Q.
	}
	
	if flightmode = 0 and AeroSwitch < .1 {
		lock FPAorbit to VANG(UP:vector,velocity:orbit).
		lock pitch to FPAorbit.
		set flightmode to 1.
	}
	
	if flightmode = 1 AND pitch >= 80 {
		set thrustset to 1.
		set flightmode to 2.
	}
	
	if flightmode = 2 AND apoapsis >= .9*OrbitAlt {
		lock throttle to MIN(1,((OrbitAlt - apoapsis)^(1/2))/((.1*OrbitAlt)^(1/2))).
		wait .5.
		set flightmode to 3.
	}
	
	if flightmode <= 3 AND apoapsis >= OrbitAlt AND altitude > 70000 {
		lock throttle to 0.
		wait .5.
		set flightmode to 4.
	}
	
	if flightmode = 4 {
		lock Vapo to sqrt(((1-e)*u)/((1+e)*a)).
		lock Vcir to sqrt(u/(apoapsis + ship:body:radius)).
		lock DeltaV to Vcir - Vapo.
		lock BurnTime to .5*DeltaV*(mass/max(.0001,availablethrust)).
		lock steering to srfprograde.		
		set flightmode to 5.
	}
	
	if flightmode = 5 AND altitude >= 70000 {
		lock steering to prograde.
		wait 5.
		warpto(time:seconds + eta:apoapsis - BurnTime - 15).
		set flightmode to 6.
	}
	
	if flightmode = 6 {
		if .9*BurnTime >= eta:apoapsis OR ship:orbit:trueanomaly >= 180	{
			lock throttle to DeltaV*(mass/max(.0001,availablethrust)).
			}
		if BurnTime < eta:apoapsis AND ship:orbit:trueanomaly < 180 {
			lock throttle to 0.
			}
	}
	
	
		
	print "Flight Mode      " + flightmode at (0,1).
	print "MaxQ             " + round(MaxQ,2) at (0,2).
	print "Q                " + round(Q,2) at (0,3).
	print "Pitch            " + round(pitch,2) at (0,4).
	print "Ship Pitch       " + round(VANG(UP:vector,ship:facing:vector),2) at (0,5).
	print "Apoapsis         " + round(apoapsis,2) at (0,6).
	print "Target Apoapsis  " + round(OrbitAlt,2) at (0,7).
	print "SMA              " + round(a,2) at (0,8).
	print "Target SMA       " + round(TargetSMA,2) at (0,9).
	print "Time to Apoapsis " + round(eta:apoapsis,2) at (0,10).
	print "BurnTime         " + round(BurnTime,2) at (0,11).
	print "Throttle         " + round(throttle,2) at (0,12).
}

lock throttle to 0.
unlock all.
set finishtime to time:seconds.
set totaltime to finishtime - starttime.
set finishlong to ship:longitude.
print "Time to Ascent       " + round(totaltime,2) at (0,20).
print "Final Longitude      " + round(finishlong,2) at (0,21).