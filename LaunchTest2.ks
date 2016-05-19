clearscreen.

set ship:control:pilotmainthrottle to 0.

set MUKerbin to ship:body:MU.
set RKerbin to ship:body:Radius.

set DesiredAlt to 75000.
lock AltVar to altitude/DesiredAlt.
//set a to -884.6.
//set b to .02317.
//set c to 885.
//lock DesiredFPA to 90-(a*AltVar^(b) + c).

set a to 90/((1000/DesiredAlt - 1)^2).

lock DesiredFPA to 90 - a*(AltVar-1)^2.

set speed1 to velocity:orbit:mag.
set speed2 to sqrt(MUKerbin/(RKerbin + DesiredAlt)).
set speed3 to speed2-speed1.
set a1 to speed3/(.5^2).
lock DesiredSpeed to a1*(AltVar - .5)^3 + speed1 + .5*speed3.

lock orbitalspeed to velocity:orbit:mag.
lock ErrorSpeed to DesiredSpeed - orbitalspeed.

lock FPA to VANG(UP:vector,velocity:surface).
lock ErrorFPA to DesiredFPA - FPA.

set errFPA to 2.
set errSpeed to .5.

lock Pitch to DesiredFPA + errFPA*ErrorFPA.
lock thrust to 1 + errSpeed*ErrorSpeed.

lock steering to heading(90,90).
lock throttle to thrust.

stage.
wait until Pitch > 0.
lock steering to heading(90,90-Pitch).

until Periapsis > 70000 {
		
	print "DesiredFPA   = " + round(DesiredFPA,2) at (0,0).
	print "FPA          = " + round(FPA,2) at (0,1).
	print "DesiredSpeed = " + round(DesiredSpeed,2) at (0,2).
	print "OrbitalSpeed = " + round(orbitalspeed,2) at (0,3).
	
	print round(Pitch,2) at (0,5).
	
	if stage:liquidfuel = 0 {
		stage.
		wait .0001.
	}
}