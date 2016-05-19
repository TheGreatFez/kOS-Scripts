clearscreen.
lock Vper to VCRS(UP:vector,velocity:orbit/velocity:orbit:mag).
set u to ship:body:MU.
set e to ship:orbit:eccentricity.
set a to ship:orbit:semimajoraxis.
set Rp to ship:body:radius + periapsis.

if e >= 1 {
	set Vperp to sqrt(u*((2/(Rp))-(1/a))).
	}
if e < 1 {
	set Vperp to sqrt(((1+e)*u)/((1-e)*a)).
	}
lock Vcir to sqrt(u/ship:body:position:mag)*VCRS(Vper,UP:vector).
set Vcir_pe to sqrt(u/(Rp)).
lock DeltaV to Vcir - velocity:orbit.
set DeltaV_time to abs(Vcir_pe - Vperp).
lock BurnTime to .5*DeltaV:mag*(mass/max(.0001,availablethrust)).
set BurnTimeWarp to .5*DeltaV_time/(availablethrust/mass).
lock steering to DeltaV:direction.
print "Aligning with Circularization Burn Vector".
print Vperp.
print Vcir_pe.
print DeltaV_time.

wait 5.
print "Warping to Periapsis in " + round(BurnTimeWarp,2) + " sec".
print "Burn Starts at T-minus " + round(BurnTime,2) + "secs   ".
set flightmode to 0.
warpto(time:seconds + eta:periapsis - BurnTimeWarp - 15).

until DeltaV:mag < .1 AND flightmode = 1 {
	if flightmode = 0 AND BurnTime*.5 >= eta:apoapsis {
        lock throttle to DeltaV:mag*(mass/max(.0001,availablethrust)).
        set flightmode to 1.
    }
 }