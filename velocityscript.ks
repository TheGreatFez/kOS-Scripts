SAS on.

lock throttle to 1.
delete velocitydata.csv.
log "Altitude,Airspeed,Orbitalspeed" to velocitydata.csv.

lock orbitalspeed to ship:velocity:orbit:mag.

stage.

until altitude > 70000 {

	log altitude +","+ airspeed +","+ orbitalspeed to velocitydata.csv.
	wait .1.
	
	if stage:liquidfuel = 0 {
		stage.
		wait .1.
		}
	
	}
	