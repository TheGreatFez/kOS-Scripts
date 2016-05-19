clearscreen.

set ship:control:pilotmainthrottle to 0.

set MUKerbin to ship:body:MU.
set RKerbin to ship:body:Radius.

set DesiredAlt to 75000.
lock AltVar to altitude/DesiredAlt.
set speed1 to velocity:orbit:mag.
set speed2 to sqrt(MUKerbin/(RKerbin + DesiredAlt)).
set speed3 to speed2-speed1.
set a1 to speed3/(.5^2).
lock DesiredSpeed to a1*(AltVar - .5)^3 + speed1 + .5*speed3.

set p1 to -8.676*10^04.
set p2 to 4.212*10^05. 
set p3 to -8.703*10^05.
set p4 to 9.983*10^05. 
set p5 to -6.952*10^05.
set p6 to 3.022*10^05. 
set p7 to -8.155*10^04.
set p8 to 1.332*10^04. 
set p9 to -1269.
set p10 to 90.

lock DesiredFPA to p1*AltVar^9 + p2*AltVar^8 + p3*AltVar^7 + p4*AltVar^6 + p5*AltVar^5 + p6*AltVar^4 + p7*AltVar^3 + p8*AltVar^2 + p9*AltVar + p10.

lock orbitalspeed to velocity:orbit:mag.
lock ErrorSpeed to DesiredSpeed - orbitalspeed.

lock FPA to 90-VANG(UP:vector,velocity:surface).
lock ErrorFPA to DesiredFPA - FPA.

set errFPA to 3.
set errSpeed to .5.

lock Pitch to DesiredFPA + errFPA*ErrorFPA.
lock thrust to 1 + errSpeed*ErrorSpeed.

lock steering to heading(90,90).
lock throttle to thrust.

stage.
wait 3.
lock steering to heading(90,Pitch).

until periapsis > 70000 {

	print "DesiredFPA   = " + round(DesiredFPA,2) at (0,0).
	print "FPA          = " + round(FPA,2) at (0,1).
	print "DesiredSpeed = " + round(DesiredSpeed,2) at (0,2).
	print "OrbitalSpeed = " + round(orbitalspeed,2) at (0,3).
	
	print round(Pitch,2) at (0,5).
	
	if stage:liquidfuel = 0 {
		stage.
		wait .0001.
	}
	
	wait .0001.
}