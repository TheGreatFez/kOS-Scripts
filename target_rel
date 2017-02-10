until false {
	lock relvelocity to target:velocity:orbit - ship:velocity:orbit.
	lock targetdirection to target:position:normalized.
	lock SideSlip to VCRS(VCRS(targetdirection,ship:velocity:orbit),targetdirection):normalized.
	lock SideSlipSpeed to VDOT(SideSlip,relvelocity).
	lock steering to (relvelocity+SideSlip*SideSlipSpeed):direction.
	lock DeltaV to relvelocity:mag.
	set TargetPos to VECDRAW(V(0,0,0),target:position,GREEN,"Target Position",1.0,TRUE,.5).
	set RelativeVel to VECDRAW(V(0,0,0),relvelocity,RED,"RelativeVel",1.0,TRUE,.5).
	set SideSlipVec to VECDRAW(relvelocity,SideSlip*SideSlipSpeed,Blue,"SideSlip",1.0,TRUE,.5).
	}