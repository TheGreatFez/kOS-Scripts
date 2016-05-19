// WARNING: THIS WILL NOT WORK WITHOUT THE GRAVITY METER AND ACCELEROMETER.


clearscreen.
// This sets some pre launch parameters such as determining what the true altiude is of the base of the rocket.
set ship:control:pilotmainthrottle to 0.
set TouchDownSpeed to 5. // This is set by the user, I set it to 5 since the landing legs break at 6.
set TestAlt to 1000. // How high you want the 
set MaxCount to 3. // Used to average the derivative term since it can get pretty eratic 
set buffer_alt to 10. // Its not perfect, so a little wiggle room is good to retract the legs.
//set start_alt to alt:radar. // Determines where the control core is. The Radar Alt measures from there so if
							// the ship is on the ground it won't be 0. For this script, small errors matter.
lock true_alt to ship:geoposition:terrainheight.// - start_alt. // Again measured from the bottom of the craft.
// This script is meant to be used from a flat surface to launch and return. It can be adapted for landing from any situation.
//SAS on.
//lock throttle to 1.
//stage.
GEAR OFF.
wait until altitude > TestAlt.
lock throttle to 0.
lock steering to srfretrograde.
// After it goes up high the rocket will wait to fall back down.
// I manually select the retrograde selection on the SAS. I would do it with the cooked steering but its current
// iteration was not working well with the test ship.
lock AccelUP to VDOT(UP:vector,ship:sensors:acc).
lock MaxThrustAccUp to VDOT(UP:vector,availablethrust/mass*srfretrograde:vector).
// This assumes the ship is pointed exactly retrograde. Meaning this can be used as a gravity turn for landing as well.
lock GravUp to VDOT(UP:vector,ship:sensors:grav).
lock DragUp to AccelUP - GravUp - MaxThrustAccUp*throttle.

// WARNING: THIS WILL NOT WORK WITHOUT THE GRAVITY METER AND ACCELEROMETER.

lock MaxAccUp to MaxThrustAccUp + GravUp. // I opted out of adding drag since its finiky, this adds some safety margin though
log "1" to landingdata.csv.
delete landingdata.csv.
log "Time,Vmax,Vvert,Altitude,Error,ThrustSet,MaxAccUp" to landingdata.csv.
// Log various variables to view. This can be changed to your liking or commented out if you don't need it.
wait until verticalspeed < -20. // Just to make sure there are no weird transition errors.

clearscreen.
lock g to ship:sensors:grav:mag.
lock Vmax to sqrt(2*(alt:radar-buffer_alt)*abs(MaxAccUp) + TouchDownSpeed^2).
// The magic of the script. This equation is derived assuming an ascent starting at the touchdown speed and accelerating
// at full throttle. It auto adjusts based on the altitude and the Max Acceleration as it changes with mass loss.
// Basic PD loop. I want essentially no overshoot and very little error at the end. The Kp and Kd gains are tuned so at the finish
// of the script the error > 0 and absolutely no overshoot. Tune to your liking however (fair warning, you have VERY little margin
// when you are landing. The burn times I have seen are very short. That depends on the ship's TWR however.
lock error to verticalspeed + Vmax.
set errorP to 0.
set Kp to .02.
set errorD to 0.
set Kd to 0.01.
set ThrustSet to 0.
lock throttle to ThrustSet.
set time0 to time:seconds.
lock time1 to time:seconds - time0.
set count to 1.
lock steering to srfretrograde.

until verticalspeed > -1*TouchDownSpeed {

	set error1 to error.
	set t1 to time1.
	wait .00001.
	set error2 to error.
	set t2 to time1.
	set dt to t2-t1.
	// I like to take an average error so its not going crazy due to discrete calculations.
	set errorP to .5*(error1+error2).
	set errorD_test to (error2-error1)/dt.
	//This next part is used as a running average, the Derivative term was behaving eratically thus this damps out the spikes.
	if count < MaxCount {
		if count < 2 {
			set errorD to errorD_test.
			}
		if count >= 2 {
			set errorD to (errorD*(count-1)+errorD_test)/count.
			}
		set count to count + 1.		
		}
	if count >= MaxCount {
	
		set errorD to (errorD*(MaxCount-1)+errorD_test)/MaxCount.
		}
	
	set ThrustSet to 1 - Kp*errorP- Kd*errorD.
	
	if ThrustSet > 1 {
		set ThrustSet to 1.
		}
	if ThrustSet < 0 {
		set ThrustSet to 0.
		}
	if error < 0 {
		set ThrustSet to 1. // This is very important. If the error ever drops below 0, it means it might crash since the
							// equation is calculated based on full thrust. 
		}
		
	// Some data readouts. Pay attention to the Error term, make sure it doesn't drop below 0.
	
	print "Vmax      = " + round(Vmax,2) at(0,0).
	print "VertSpeed = " + round(verticalspeed,2) at (0,2).
	print "Radar Alt = " + round(alt:radar,2) at(0,4).
	print "Error     = " + round(error,2) at(0,6).
	print "ThrustSet = " + round(ThrustSet,2) at(0,8).
	print "GravUp    = " + round(GravUp,2) at(0,10).
	print "AccelUP   = " + round(AccelUP,2) at(0,12).
	print "DragUp    = " + round(DragUp,2) at(0,14).
	print "MaxThrustAccUp = " + round(MaxThrustAccUp,2) at(0,16).
	print "MaxAccUp  = " + round(MaxAccUp,2) at (0,18).
	
	log round(time1,3) +","+ round(Vmax,2) +","+ -1*round(verticalspeed,2) +","+ round(alt:radar,2) +","+ round(error,2) +","+ 100*round(ThrustSet,2) +","+ round(MaxAccUp,2) to landingdata.csv.
	
	}
	
// Lastly a very crude landing script. The reason for the .99 multiplication is because its not perfect. So the velocity will start to decrease even though there should be no acceleration.
// One could make a simple Proportional controller to assure touchdown speed is met buuut this works fine for low buffer_alt values.
GEAR ON.
until ship:status = "LANDED" {

	lock throttle to .99*mass*g/availablethrust.
	
	}