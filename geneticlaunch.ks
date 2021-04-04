clearscreen.
set ship:control:pilotmainthrottle to 0.
print "First Phase".

set a1 to  9.743. 
set b1 to  -233.1.
set c1 to  1292.  
set a2 to  132.3. 
set b2 to -30060.
set c2 to  32720.
set a3 to  50.25.
set b3 to  19350.
set c3 to  22290.
set a4 to  31.61.
set b4 to  39210.
set c4 to  14840.

set thrust to 0.422652479755061.
set alt1 to 29516.50.
set qswitch to 0.301224691747042.
set etaSSing to 255.057279755142.
// lock pitch to a1*(constant:e)^(-((altitude-b1)/c1)^2) + a2*(constant:e)^(-((altitude-b2)/c2)^2) +  a3*(constant:e)^(-((altitude-b3)/c3)^2) + a4*(constant:e)^(-((altitude-b4)/c4)^2).
//lock pitch to a1*(constant:e)^(-((altitude-b1)/c1)^2) + a2*(constant:e)^(-((altitude-b2)/c2)^2) +  a3*(constant:e)^(-((altitude-b3)/c3)^2) + a4*(constant:e)^(-((altitude-b4)/c4)^2).
lock steering to heading(90,min(90,max(0,pitch))).
lock throttle to thrust.
stage.
WHEN (ship:maxthrust < 1) AND (eta:apoapsis < etaSSing) THEN {
    stage.
    wait .1.
    lock throttle to 1.
    preserve.
}
wait until altitude >= alt1.

set a1 to 44.41.
set b1 to 2.5040.
set c1 to 8820.
set a2 to 35.4.
set b2 to 36760.
set c2 to 9304.
set a3 to -255.8.
set b3 to 51720.
set c3 to 9093.
set a4 to -0.252.
set b4 to 39150.
set c4 to 503.9.
set a5 to 279.8.
set b5 to 51630.
set c5 to 9372.

lock pitch to a1*(constant:e)^(-((altitude-b1)/c1)^2) + a2*(constant:e)^(-((altitude-b2)/c2)^2) +  a3*(constant:e)^(-((altitude-b3)/c3)^2) + a4*(constant:e)^(-((altitude-b4)/c4)^2) + a5*(constant:e)^(-((altitude-b5)/c5)^2).

print "surface prograde".
set qper to 1.
set MaxQ to 0.
until qper < qswitch {
    if ship:q > MaxQ { set MaxQ to ship:q. }
    set qper to ship:q/MaxQ.
}
print "switch to orbital prograde".
wait until apoapsis > 100000.
lock throttle to 0.
unlock all.
