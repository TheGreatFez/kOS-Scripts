declare parameter OrbitAlt.
set ship:control:pilotmainthrottle to 0.
clearscreen.
set circstage to 3.
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

declare function Circularize_apo{
	set Vapo_cir to sqrt(ship:body:mu/(ship:body:radius + apoapsis)).
	set DeltaV to  Vapo_cir - VELOCITYAT(ship,time:seconds + eta:apoapsis):orbit:mag.
	set CirPer to NODE(TIME:seconds + eta:apoapsis, 0, 0, DeltaV).
	ADD CirPer.
	ExecuteNode().
	}

declare function pitch{
	declare parameter flightmode,starting_alt is 0.
	if flightmode = 0 {
		set pitch_ang to sqrt((90^2)*max(0,(altitude-starting_alt)/70000)).
	} else if flightmode = 1 {
		set pitch_ang to VANG(UP:vector,velocity:orbit).
	} else {
		set pitch_ang to 90.
	}
	return pitch_ang.
	}
	
set flightmode to 0.
set compass to 90.
set starting_alt to altitude.
//set OrbitAlt to 100000.

//lock pitch to sqrt((90^2)*altitude/70000).

lock steering to heading(compass,90-pitch(flightmode,starting_alt)).

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
//lock FPAorbit to VANG(UP:vector,velocity:orbit).

until flightmode = 3 {

	if MaxQ <= Q {
		set MaxQ to Q.
	}
	
	if flightmode = 0 {
		set FPAorbit to VANG(UP:vector,velocity:orbit).
	}
		
	if flightmode = 0 and AeroSwitch < .1 or FPAorbit < pitch(flightmode,starting_alt){
		//lock pitch to FPAorbit.
		set flightmode to 1.
	}
	
	if flightmode = 1 AND apoapsis >= .9*OrbitAlt {
		lock throttle to max(0,(OrbitAlt - apoapsis)/(.05*OrbitAlt)).
		wait .5.
		set flightmode to 2.
	}
	
	if flightmode <= 2 AND apoapsis >= OrbitAlt {
		//lock throttle to 0.
		lock steering to srfprograde.
		wait .5.
		set flightmode to 3.
	}
	
	print "Flight Mode      " + flightmode at (0,1).
	print "MaxQ             " + round(MaxQ,2) at (0,2).
	print "Q                " + round(Q,2) at (0,3).
	print "Pitch            " + round(pitch(flightmode,starting_alt),2) at (0,4).
	print "Ship Pitch       " + round(VANG(UP:vector,ship:facing:vector),2) at (0,5).
	print "Apoapsis         " + round(apoapsis,2) at (0,6).
	print "Target Apoapsis  " + round(OrbitAlt,2) at (0,7).
	print "Time to Apoapsis " + round(eta:apoapsis,2) at (0,8).
	print "BurnTime         " + round(BurnTime,2) at (0,9).
	print "Throttle         " + round(throttle,2) at (0,10).
}
clearscreen. 
print "Coasting until out of Atmosphere".
wait until altitude > 70000.
Circularize_apo().

set finishtime to time:seconds.
set totaltime to finishtime - starttime.
print "Time to Ascent       " + round(totaltime,2) at (0,20).