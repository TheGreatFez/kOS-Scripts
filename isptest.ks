function ispcheck {

	LIST ENGINES IN myVariable.
	FOR eng IN myVariable {
    set val to eng:ISP.
	}.
	return val.
}

lock throttle to .75.
lock pressure to ship:sensors:pres.
log 1 to ispdata.csv.
delete ispdata.csv.
log "Altitude,Pressure,ISP" to ispdata.csv.

SAS on.
stage.
clearscreen.
print "Pressure =" at (0,0).
print "ISP =" at (0,2).
wait .1.

until altitude > 70000 {
	set ispval to ispcheck().
	log altitude +","+ pressure +","+ ispval to ispdata.csv.
	print round(pressure,2) at (15,0).
	print round(ispval,2) at (15,2).
	wait .1.		
	}
	