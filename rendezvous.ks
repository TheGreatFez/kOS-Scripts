clearscreen.
lock relvelocity to target:velocity:orbit - ship:velocity:orbit.
lock targetdirection to target:position:normalized.
lock SideSlip to VCRS(VCRS(targetdirection,ship:velocity:orbit),targetdirection):normalized.
lock SideSlipSpeed to VDOT(SideSlip,relvelocity).
lock steering to (relvelocity+SideSlip*SideSlipSpeed):direction.
lock DeltaV to relvelocity:mag.

until DeltaV <= .1 {
	set TargetPos to VECDRAW(V(0,0,0),target:position,GREEN,"Target Position",1.0,TRUE,.5).
	set RelativeVel to VECDRAW(V(0,0,0),relvelocity,RED,"RelativeVel",1.0,TRUE,.5).
	set SideSlipVec to VECDRAW(relvelocity,SideSlip*SideSlipSpeed,Blue,"SideSlip",1.0,TRUE,.5).
    set Alt_ship1 to altitude.
	set Alt_target1 to target:altitude.
	set Diff1 to abs(Alt_ship1 - Alt_target1).
    wait .0001.
    set Alt_ship2 to altitude.
	set Alt_target2 to target:altitude.
	set Diff2 to abs(Alt_ship2 - Alt_target2).
    set diff to Diff2-Diff1.
    if diff <= 0 {
        lock throttle to DeltaV*mass/availablethrust.
		break.
    }
}