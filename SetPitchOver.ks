clearscreen.
set thrust to 0.
lock throttle to 0.

lock Vcir_mag to sqrt(ship:body:MU/(altitude+ship:body:RADIUS)).
lock Vcir to Vcir*heading(90,0):vector.

lock DeltaV to Vcir-velocity:orbit.
lock DeltaV_dir to DeltaV:direction.
lock steering to DeltaV_dir.
lock thrust to DeltaV:mag*mass/maxthrust.
lock HalfBurnTime to .5*mass*(DeltaV:mag)/maxthrust.

until DeltaV:mag < 1 {
    
    
    print "DeltaV = " + round(DeltaV:mag,2) at (0,0).
    print "Apoapsis = " + round(apoapsis,2) at (0,2).
    print "HalfBurnTime = " + round(HalfBurnTime,2) at (0,4).    
    print "ETA to Apoapsis = " + round(eta:apoapsis,2) at (0,6).
    
    if flightmode = 2 AND HalfBurnTime > eta:apoapsis {
    
        lock throttle to thrust.
        set flightmode to 3.
    }
    
    wait .0001.

}