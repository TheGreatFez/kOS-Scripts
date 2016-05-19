declare parameter R_new.
set e to ship:orbit:eccentricity.
set a to ship:orbit:semimajoraxis.
set u to ship:body:MU.
set R to ship:body:radius.

set Vper to sqrt(((1 + e)*u)/((1 - e)*a)).

set a_new to (R_new + periapsis)/2 + R.

if R_new > periapsis {
	set e_new to (R_new - periapsis)/(R_new + periapsis + 2*R).
	set Vper_new to sqrt(((1 + e_new)*u)/((1 - e_new)*a_new)).
}

if R_new < periapsis {
	set e_new to (R_new - periapsis)/(R_new + periapsis + 2*R).
	set Vper_new to sqrt(((1 - e_new)*u)/((1 + e_new)*a_new)).
}

set DeltaV to Vper_new - Vper.

add node(time:seconds + eta:periapsis, 0, 0, DeltaV).
run executenode.
run CircularizeAP.