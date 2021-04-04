// This script is for matching inclination of a target around the same body

clearscreen.

set DV_tol to 0.1.
set DA_tol to .01.
if hasnode {
	for node in allnodes {remove node.}
}
lock Ship_angvel to VCRS(ship:velocity:orbit,(ship:position-ship:body:position)).
lock Target_angvel to VCRS(target:velocity:orbit,(target:position-ship:body:position)).
set asc_node_vec to VCRS(Ship_angvel,Target_angvel).
lock Ship_ecc to ship:orbit:eccentricity.
lock Ship_TA to ship:orbit:trueanomaly.
set vec1 to VCRS((-1*ship:body:position),asc_node_vec):normalized+Ship_angvel:normalized.
set ang to VANG(asc_node_vec,(-1*ship:body:position)).
if vec1:mag > 1 {
    set asc_node_TA to Ship_TA - ang.
    if asc_node_TA < 0 {
        set asc_node_TA to 360 + asc_node_TA.
        }
    if asc_node_TA > 360 {
        set asc_node_TA to asc_node_TA - 360.
        }
    } else {
    set asc_node_TA to Ship_TA + ang.
    if asc_node_TA < 0 {
        set asc_node_TA to 360 + asc_node_TA.
        }
    if asc_node_TA > 360 {
        set asc_node_TA to asc_node_TA - 360.
        }
    }


set Ship_EA to 2*ARCTAN((TAN(Ship_TA/2))/sqrt((1+Ship_ecc)/(1-Ship_ecc))).
set Ship_MA to Ship_EA*constant:pi/180 - Ship_ecc*SIN(Ship_EA).
set asc_node_EA to 2*ARCTAN((TAN(asc_node_TA/2))/sqrt((1+Ship_ecc)/(1-Ship_ecc))).
set asc_node_MA to asc_node_EA*constant:pi/180 - Ship_ecc*SIN(asc_node_EA).
set n to sqrt(ship:body:mu/(ship:orbit:semimajoraxis)^3).
set asc_node_eta to (asc_node_MA-Ship_MA)/n.

if asc_node_eta < 0 {
	set asc_node_eta to ship:orbit:period + asc_node_eta.
	}
	
set mynode to NODE(TIME:seconds + asc_node_eta, 0, 0, 0).
ADD mynode.

lock delta_ang to VANG(Ship_angvel,Target_angvel).
set delta_v_check to 2*(VELOCITYAT(ship,time:seconds + asc_node_eta):orbit:mag)*sin(delta_ang/2).
lock Burn_dir to (-1*Ship_angvel):direction.
lock steering to Burn_dir.
print "Aligning to Burn Vector".
until VANG(ship:facing:vector,Burn_dir:vector) < 1 {
	print "Direction Alignment Error = " + round(VANG(ship:facing:vector,Burn_dir:vector),1) + "   "at(0,1).
}
lock acc to maxthrust/mass.
lock Burn_time to delta_v_check/acc.
warpto(time:seconds + mynode:eta - Burn_time/2 - 15).

print "True Anomaly of Ascending Node = " + round(asc_node_TA).
print "ETA to Ascending Node = " + round(asc_node_eta).
print "EA of Ascending Node = " + round(asc_node_EA).
print "MA of Ascending Node = " + round(asc_node_MA).
print "EA of Ship = " + round(Ship_EA).
print "MA of Ship = " + round(Ship_MA).
print " ".
print "Delta V = " + round(delta_v_check).
print "Burn Time = " + round(Burn_time/2).
print "Warp to Time = T-" + round(Burn_time/2 + 15).
lock delta_v_check to 2*(ship:velocity:orbit:mag)*sin(delta_ang/2).
set delta_ang_der to -1.
set delta_ang_der_check to 0.
until delta_v_check < DV_tol {
	
	if delta_ang_der_check > 0 {
		break.
		}
	if mynode:eta > Burn_time/2 {
		lock throttle to 0.
		}
	else {
		if delta_v_check*mass/maxthrust > 1 {
			lock throttle to 1.
			}
		else {
			lock throttle to delta_v_check*mass/maxthrust.
			}
		set delta_ang_1 to delta_ang.
		wait .1.
		set delta_ang_2 to delta_ang.
		set delta_ang_der to delta_ang_2-delta_ang_1.
		if delta_ang_der > 0 {
			set delta_ang_der_check to 1.
			lock throttle to 0.
			}
		}
	print "Delta V Left = " + round(delta_v_check,1) + "   " at(0,10).
	print "Throttle = " + round(throttle*100) + "%   " at(0,11).
	print "Delta Angle = " + round(delta_ang,2) + "   " at(0,12).
	print "Angle Derivative = " + round(delta_ang_der_check) at(0,13).
	set Arrow1 to VECDRAW(ship:position,(Ship_angvel:normalized)*20,RGB(1,0,0),"Ship AngVel",1,TRUE,.5).
	set Arrow2 to VECDRAW(ship:position,(Target_angvel:normalized)*20,RGB(0,1,0),"Target AngVel",1,TRUE,.5).
	}
lock throttle to 0.
	
if delta_v_check < DV_tol {
	print "Delta V less than " + round(DV_tol,2) + "m/s" at(0,20).
	} else if delta_ang_der > 0 {
	print "Broke because of increasing angle" at(0,20).
	}
clearvecdraws().
for node in allnodes{remove node.}
wait 3.