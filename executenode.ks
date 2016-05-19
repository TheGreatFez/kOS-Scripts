clearscreen.
lock throttle to 0.
SAS off.
lock DeltaV to nextnode:deltav:mag.
set BurnTime to .5*DeltaV*mass/availablethrust.
lock steering to nextnode.
print "Aligning with Maneuver Node".
wait 5.
print "Warping to Node".
print "Burn Starts at T-minus " + round(BurnTime,2) + "secs   ".
warpto(time:seconds + nextnode:eta - BurnTime - 10).
wait until BurnTime >= nextnode:eta.
lock throttle to DeltaV*mass/availablethrust.
wait until DeltaV <= .1.
lock throttle to 0.
unlock all.
remove nextnode.