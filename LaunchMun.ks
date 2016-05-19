lock pitch to min(90,90*altitude^(.5)/5000^(.5)).
lock steering to heading(90,90-pitch).
lock throttle to 1.
GEAR OFF.
set R to 100000.
clearscreen.
print "Ascending until apoapsis is " + R + " meters".
wait until apoapsis >= R.
lock throttle to 0.
run CircularizeAP.