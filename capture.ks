clearscreen.
set R2 to ship:body:radius + 100000.
lock R1 to ship:body:position:mag.
lock a_cap to (R1+R2)/2.
lock ecc_cap to abs(R1-R2)/(R1+R2).
lock Va_cap to sqrt(ship:body:MU*(2/R1 - 1/a_cap)).

lock vec1 to VCRS(ship:body:position,ship:body:body:position):normalized.
lock vec2 to VCRS(vec1,ship:body:position):normalized.
lock Delta_V to Va_cap*vec2 - ship:velocity:orbit.
set arrow to VECDRAW(ship:position,Delta_V:normalized*10,RGB(1,1,1),"Delta V",1,TRUE,.5).
lock steering to Delta_V:direction.
print "Aligning to Delta V vector".
until VANG(ship:facing:vector,Delta_V) < 1 {
	print "Direction Angle Error = " + round(VANG(ship:facing:vector,Delta_V),1) + "   "at(0,1).
}
clearscreen.
print "Burning for Capture".

until Delta_V:mag < 1 {
	lock throttle to Delta_V:mag*mass/maxthrust.
	print "Delta V = " + round(Delta_V:mag,1) at(0,2).
}
clearscreen.
print "Captured on " + ship:body:name.
clearvecdraws().