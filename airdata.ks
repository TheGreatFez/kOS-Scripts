clearscreen.
lock throttle to 1.
log 1 to air.csv.
delete air.csv.
log "Altitude,Temperature,Pressure,Gravity,Thrust,Acceleration,Airspeed,Drag" to air.csv.
lock temperature to ship:sensors:temp.
lock pressure to ship:sensors:pres.
lock g to ship:sensors:grav:mag.
lock accel to ship:sensors:acc:mag.
set p0 to pressure.
set N to 5.
set DeltaT to N*(1500-1379.032).
set tval to 1.
lock Thrust to maxthrust-DeltaT*pressure/p0.
lock drag to Thrust - accel*mass - g*mass.


log altitude +","+ temperature +","+ pressure +","+ g +","+ Thrust +","+ accel +","+ airspeed +","+ drag to air.csv.
SAS on.
lock error to 345-verticalspeed.
set Kp to .1.

stage.

until altitude > 25000 {

set tval to Kp*error*(mass*10/Thrust).

if tval > 1 {

set tval to 1.

}

//lock throttle to tval.

log altitude +","+ temperature +","+ pressure +","+ g +","+ Thrust +","+ accel +","+ airspeed +","+ drag to air.csv.

print "Drag = " + round(drag,2) at (0,0).
wait .1.

}

