clearscreen.
lock Vper to VCRS(UP:vector,velocity:orbit/velocity:orbit:mag).
set u to ship:body:MU.
set e to ship:orbit:eccentricity.
set a to ship:orbit:semimajoraxis.
set Ra to ship:body:radius + apoapsis.

lock Vcir to sqrt(ship:body:MU/ship:body:position:mag)*VCRS(Vper,UP:vector).
set Vperp to sqrt(((1-e)*u)/((1+e)*a)).
set Vcir_pe to sqrt(u/(Ra)).
lock DeltaV to Vcir - velocity:orbit.
set DeltaV_time to abs(Vcir_pe - Vperp).
lock BurnTime to .5*DeltaV:mag*(mass/max(.0001,availablethrust)).
set BurnTimeWarp to .5*DeltaV_time/(availablethrust/mass).
lock steering to DeltaV:direction.
print "Aligning with Circularization Burn Vector".
wait 5.
print "Warping to Apoapsis".
print "Burn Starts at T-minus " + round(BurnTime,2) + "secs   ".
set flightmode to 0.
warpto(time:seconds + eta:apoapsis - BurnTimeWarp - 10).

until DeltaV:mag < .1 AND flightmode = 1 {
	print "Burn Time = " + round(BurnTime,2) + "secs   " at(0,2).
    if flightmode = 0 AND BurnTime*.5 >= eta:apoapsis {
        lock throttle to DeltaV:mag*(mass/max(.0001,availablethrust)).
        set flightmode to 1.
    }
}
clearscreen.
print "Finished Circularization".
wait 1.