// Function used to determine the first point of impact of a rocket on a ballistic/suborbital trajectory
local drawvec_check to true.
local Body_Ang_speed to 360/ship:body:rotationperiod.

function Height_At_Position {
	parameter test_position.
	local body_pos to ship:body:position.
	local body_R to ship:body:radius.
	local body_test_position to test_position - body_pos.
	local H to body_test_position:mag - body_R.
	return H.
}
function Impact_locator {
	local Ttest_ltln is LATLNG(0,0).
	if periapsis > 0 {
		clearscreen.
		print "No impact detected".
	} else {
	
		local T0 is time:seconds.
		
		local Tp is eta:periapsis.
		
		local Ttest is Tp/2.
		
		local T1 is 0.
		local T2 is Tp.
		
		if drawvec_check {
			set Ttest_vec_Draw to vecdraw().
			set Ttest_vec_Draw:startupdater to { return V(0,0,0). }.
			set Ttest_vec_Draw:vecupdater to { return positionat(ship,T0 + Ttest). }.
			set Ttest_vec_Draw:show to true.
			set Ttest_vec_Draw:color to RGB(255,0,0).
		}
		clearscreen.
		set impact_found to false.
		local count to 0.
		local iprint to 3.
		until impact_found {
			local time_offset to time:seconds - T0.
			local eta_impact to Ttest - time_offset.
			local long_offset to eta_impact*Body_Ang_speed. // For the future this needs to be checked for prograde or retrograde
			local Ttest_vec to positionat(ship,T0 + Ttest).
			set Ttest_ltln to ship:body:geopositionof(Ttest_vec).
			set Ttest_ltln to LATLNG(Ttest_ltln:LAT,Ttest_ltln:LNG - long_offset).
			
			local Ttest_H to Height_At_Position(Ttest_vec).
			local error to Ttest_H - Ttest_ltln:terrainheight.
			
			set iprint to 3.
			print "Error            " + round(error,2) + "      " at(0,iprint).
			set iprint to iprint + 1.
			print "Ttest_ltln:LAT   " + round(Ttest_ltln:LAT,3) + "      " at(0,iprint).
			set iprint to iprint + 1.
			print "Ttest_ltln:LNG   " + round(Ttest_ltln:LNG,3) + "      " at(0,iprint).
			set iprint to iprint + 1.
			print "count            " + count + "      " at(0,iprint).
			set iprint to iprint + 1.
			print "eta_impact       " + round(eta_impact,2) + "      " at(0,iprint).
			
			// wait 1.
			set count to count + 1.
			
			if abs(error) < 0.1 {
				set impact_found to true.
			}
			
			if error > 0 {
				set T1 to Ttest.
				set Ttest to (T1 + T2)/2.
			} else {
				set T2 to Ttest.
				set Ttest to (T1 + T2)/2.
			}
		}
		//until false {
		//	local time_offset to time:seconds - T0.
		//	local eta_impact to Ttest - time_offset.
		//	print "eta_impact       " + round(eta_impact,2) + "      " at(0,iprint).
		//}
	}
	
	return Ttest_ltln.
}

