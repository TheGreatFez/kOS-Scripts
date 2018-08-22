clearscreen.

lock Ship_angvel to VCRS(ship:velocity:orbit,(ship:position-ship:body:position)).
lock Target_angvel to VCRS(target:velocity:orbit,(target:position-ship:body:position)).

lock PlaneAngDiff to VANG(Ship_angvel,Target_angvel).
set i to 1.
set max_iter to 5.
until PlaneAngDiff < 0.01 OR i >= max_iter{
	clearscreen.
	print "Matching Inclination".
	print "Inclination Match Iteration: " + i.
	wait 3.
	run inclinationmatch.
	set i to i+1.
	}

clearscreen.
print "Inclination Match Complete".
wait 3.
if target:istype("Body") {
	run rdz_body.
} else {
	run rdz_circular.
}
//run rdz_man.