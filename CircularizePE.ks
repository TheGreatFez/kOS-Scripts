clearscreen.
for node in allnodes {remove node.}
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

set Vcir_pe to sqrt(u/(Rp)).
set DeltaV to Vcir_pe- Vperp.
set circ_pe_node to NODE(time:seconds + eta:periapsis,0,0,DeltaV).
add circ_pe_node.
run executenode.