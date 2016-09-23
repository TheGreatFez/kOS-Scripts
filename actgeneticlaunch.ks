clearscreen.
set ship:control:pilotmainthrottle to 0.
print "Flightmode: 1" at (0,0).

set pitchalt to 969.
set pitchangle to 20.6.
set thrval to .4.
set Qperswitch to .1.
set etaSSing to 240.93.

lock pitch to pitchangle*(altitude/pitchalt).
lock FPA_air to vang(UP:vector,srfprograde:vector).
lock FPA_orbit to vang(UP:vector,prograde:vector).
lock steering to heading(90,90-pitch).
set flightmode to 1.
set MaxQ to ship:Q.
lock Qper to min(1,max(0,ship:Q/MaxQ)).
lock throttle to thrval + (1-thrval)*(1-Qper).

stage.
wait .5.



WHEN (ship:maxthrust < 1) AND (eta:apoapsis < etaSSing) THEN {
    stage.
    wait .1.
    lock throttle to 1.
    preserve.
}

until altitude > 70000 {
	
	if MaxQ < ship:Q {
		set MaxQ to ship:Q.
		}
	
	if (flightmode = 1) AND altitude >= pitchalt {
		
		lock steering to heading(90,90-FPA_air).
		set flightmode to 2.
		print "Flightmode: 2" at (0,0).
		}
	
	if (flightmode =2) AND Qper <= Qperswitch {
	
		lock steering to heading(90,90-FPA_orbit).
		set flightmode to 3.
		print "Flightmode: 3" at (0,0).
		}
	
	}
	