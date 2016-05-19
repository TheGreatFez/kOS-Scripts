lock V to ship:velocity:orbit.
lock R to ship:body:position.
lock Vper to VDOT(VCRS(R,VCRS(V,R)):direction:vector,V).
print V:mag.
print R.
print Vper.