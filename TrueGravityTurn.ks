clearscreen.
set pitchoveralt to 2000.
set pitchangle to 25.
set OrbitAlt to 100000.

lock g to ship:sensors:grav:mag.
lock a to ship:sensors:acc.
lock p to ship:sensors:pres.
lock VelAccO to VDOT(velocity:orbit:direction:vector,a).
lock VelAccS to VDOT(velocity:orbit:direction:vector,a).
set SwitchAlt to 0.
set SwitchAng to 0.
lock FPAsurf to VANG(UP:vector,velocity:surface).
lock FPAorbit to VANG(UP:vector,velocity:orbit).
lock FPAdesired to 0 + pitchangle*altitude/pitchoveralt.
lock steering to Heading(90,90).

lock error to FPAdesired - FPAsurf.
set Eavg to 0.
set Eint to 0.
set Eder to 0.
set Eder1 to 0.
set Eder2 to 0.
set calcdps to 0.
set calcdps1 to 0.
set calcdps2 to 0.
set Damp to 5.
set Kp to .75.
set Ki to .9.
set Kd to .3.

set slope to (90-pitchangle)/(OrbitAlt-pitchoveralt).
lock dps to (slope*verticalspeed).
lock realdps to (180/3.1415)*((g*sin(FPAsurf))/velocity:surface:mag).

wait 5.
set ship:control:pilotmainthrottle to 0.
set p0 to p.
lock throttle to 1.
stage.
print "Launch". 
wait 1.
set MAX to maxthrust.
set x to 0.
lock ThrstAcc to availablethrust/mass.
set DeltaV to 0.
set TDeltaV to 0.

lock steering to Heading(90,90-(FPAdesired + x*(Kp*Eavg + Ki*Eint - Kd*Eder))).

until apoapsis >= OrbitAlt OR periapsis > 75000 {

    if MAX > maxthrust {
		stage.
		wait .00001.
		set MAX to maxthrust.
		}

	if x = 0 AND altitude >= pitchoveralt {
	
		lock steering to Heading(90,90-FPAsurf).
		set x to 1.
		
		}
		
	if x = 1 AND p/p0 <= .025 {
		
		lock steering to Heading(90,90-FPAorbit).
		set x to 2.
		}
	
	set t1 to time:seconds.
	set E1 to error.
	set FPA1 to FPAsurf.
	set TAcc1 to ThrstAcc.
	set Acc1 to VelAcc.
	wait .00001.
	set t2 to time:seconds.
	set E2 to error.
	set FPA2 to FPAsurf.
	set Acc2 to VelAcc.
	set TAcc2 to ThrstAcc.
	
	set Eavg to (E1+E2)/2.
	set Accavg to (Acc1+Acc2)/2.
	set TAccavg to (TAcc1+TAcc2)/2.
	set dt to t2-t1.
	set Eint to Eint + x*Eavg*dt.
	set Eder1 to (E2-E1)/dt.	
	set Eder to (Eder1 + Eder2*Damp)/(Damp+1).
	set Eder2 to Eder.
	set calcdps1 to (FPA2-FPA1)/dt.
	set calcdps to (calcdps1 + calcdps2*Damp)/(Damp+1).
	set calcdps2 to calcdps.
	set DeltaV to DeltaV +Accavg*dt.
	set TDeltaV to TDeltaV + TAccavg*dt.
	set Loss to TDeltaV - DeltaV.
	
	
	print "Desired   " + round(FPAdesired,2) at (0,3).
	print "Ship      " + round(FPAsurf,2) at (0,4).
	print "Error     " + round(error,2) + "   " at (0,5).
	print "SwitchAlt " + round(SwitchAlt,2) at (0,6).
	print "SwitchAng " + round(SwitchAng,2) at (0,7).
	print "Dps       " + round(dps,2) + "   " at (0,8).
	print "RealDps   " + round(realdps,2) + "   " at (0,9).
	print "CalcDps   " + round(calcdps,2) + "   " at (0,10).
	print "VelAcc    " + round(VelAcc,2) + "   " at (0,11).
	print "ThrstAcc  " + round(ThrstAcc,2) + "   " at (0,12).
	print "DeltaV    " + round(DeltaV,2) + "   " at (0,13).
	print "TDeltaV   " + round(TDeltaV,2) + "   " at (0,14).
	print "Loss      " + round(Loss,2) + "   " at (0,15).
	}

set Vcir to sqrt(ship:body:MU/(OrbitAlt+ship:body:radius)).
set Vap to sqrt(((1-orbit:eccentricity)*body:MU)/((1+orbit:eccentricity)*orbit:semimajoraxis)).
print Vcir - Vap at (0,16).
print TDeltaV + Vcir - Vap at (0,17).