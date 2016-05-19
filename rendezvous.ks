clearscreen.
lock protarget to target:velocity:orbit - ship:velocity:orbit.
lock steering to protarget:direction.
lock DeltaV to protarget:mag.
until DeltaV <= .1 {
    set Dist1 to target:distance.
    wait .0001.
    set Dist2 to target:distance.
    set diff to Dist2-Dist1.
    if diff >= 0 {
        lock throttle to DeltaV*mass/availablethrust.
    }
}