clearscreen.
until 1 < 0 {

set mass1 to mass.
set t1 to time:seconds.
wait .1.
set mass2 to mass.
set t2 to time:seconds.

set dt to t2-t1.
set mout to (mass1-mass2)/dt.

print round(mout,3) + "     " at (0,0).

}