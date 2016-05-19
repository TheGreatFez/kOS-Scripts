// Throw this at the end of your script to have it print out the optimal Delta V.
if ship:status = "LANDED" {

	set M0 to 24.92998.
	set M1 to mass.
	set ISP to 350.
	set g0 to 9.80665.

	set DeltaV_used to g0*ISP*ln(M0/M1).

	set Rf to ship:body:radius + altitude.
	set Rcir to ship:body:radius + 100000.
	set u to ship:body:MU.
	set a to (Rf + Rcir)/2.
	set e to (Rcir - Rf)/(Rf + Rcir).
	set Vgrnd to 2*Rf*(constant():pi)/138984.38.
	set Vcir to sqrt(u/Rcir).
	set Vap to sqrt(((1 - e)*u)/((1 + e)*a)).
	set Vper to sqrt(((1 + e)*u)/((1 - e)*a)).
	set DeltaV_opt to (Vcir - Vap) + (Vper-Vgrnd).
	set Deviation to DeltaV_used - DeltaV_opt.
	
	print "You used " + round(Deviation,2) + "m/s more than the optimal" at(0,20).

}	