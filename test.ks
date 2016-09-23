clearscreen.

until altitude > 70000 {
print "Airspeed = " + round(airspeed,2) at (0,0).
print "Thrust    = " + round(throttle*ship:maxthrust,2) at (0,2).
}