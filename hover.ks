set kp to .001.
set ki to .0001.
set kd to 0.

set ship:control:pilotmainthrottle to 0.
stage. 
SAS on.
clearscreen.

set PID to PIDloop(kp,ki,kd).
lock g to ship:body:mu/(ship:body:position:mag)^2.
lock TWR to (availablethrust/mass)/g.
set thrust to 0.
lock throttle to thrust.
set PID:setpoint to 100.
until false {

set thrust to  g*mass/availablethrust + PID:update(time:seconds,altitude).

print round(PID:error,2) at (0,1).
print round(PID:output,2) at (0,2).
print round(g,2) at (0,3).
print round(PID:Pterm,2) at (0,4).
print round(PID:Iterm,2) at (0,5).
print round(PID:Dterm,2) at (0,6).

}