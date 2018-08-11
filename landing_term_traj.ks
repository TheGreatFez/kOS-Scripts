clearscreen.
clearvecdraws().
for n in allnodes { remove n.}

parameter target_ltln is LATLNG(5,120).

if true {
	set Target_Vecdraw to vecdraw().
	set Target_Vecdraw:startupdater to { return target_ltln:position. }.
	set Target_Vecdraw:vecupdater to { return 50000*((target_ltln:position-ship:body:position):normalized). }.
	set Target_Vecdraw:show to true.
	set Target_Vecdraw:color to RGB(255,255,255).
}


function Height_At_Position {
	parameter test_position.
	local body_pos to ship:body:position.
	local body_R to ship:body:radius.
	local body_test_position to test_position - body_pos.
	local H to body_test_position:mag - body_R.
	return H.
}

function ETA_to_theta {

	parameter theta_test.
	
	local orbit_test to ship:orbit.
	local mnv_time to 0.
	
	if HASNODE {
		set orbit_test to nextnode:orbit.
		set mnv_time to nextnode:eta.
	}
	
	local T_orbit to orbit_test:period.
	local theta_ship to orbit_test:trueanomaly.
	local e to orbit_test:eccentricity.
	local GM to ship:body:mu.
	local a to orbit_test:semimajoraxis.
	//clearscreen.
	
	local EA_ship to 2*ARCTAN((TAN(theta_ship/2))/sqrt((1+e)/(1-e))).
	local MA_ship to EA_ship*constant:pi/180 - e*SIN(EA_ship).
	local EA_test to 2*ARCTAN((TAN(theta_test/2))/sqrt((1+e)/(1-e))).
	local MA_test to EA_test*constant:pi/180 - e*SIN(EA_test).
	local n to sqrt(GM/(a)^3).
	local eta_to_testpoint to (MA_test - MA_ship)/n.
	if eta_to_testpoint < 0 {
		set eta_to_testpoint to T_orbit + eta_to_testpoint.
	}
	
//	print "ETA to " + round(theta_test,2) + " degrees True Anomaly is " + round(eta_to_testpoint,2) + " seconds".
//	wait 2.
	return eta_to_testpoint.
}

function Impact_locator {
	local Ttest_ltln is LATLNG(0,0).
	local per_test to periapsis.
	local Body_Ang_speed to 360/ship:body:rotationperiod.
	
	local drawvec_check is true.
	local T0 is time:seconds.
	
	local Tp is nextnode:eta + ETA_to_theta(0).
	
	local Ttest is Tp/2.
	
	if HASNODE {
		set per_test to nextnode:orbit:periapsis.
	}
	if per_test > 0 {
		clearscreen.
		print "No impact detected".
	} else {		
		local T1 is 0.
		local T2 is Tp.
		
		if drawvec_check {
			set Ttest_vec_Draw to vecdraw().
			set Ttest_vec_Draw:startupdater to { return V(0,0,0). }.
			set Ttest_vec_Draw:vecupdater to { return positionat(ship,T0 + Ttest). }.
			set Ttest_vec_Draw:show to true.
			set Ttest_vec_Draw:color to RGB(255,0,0).
		}
		local impact_found to false.
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
			
			wait 0.001.
			set count to count + 1.
			if count > 50 {
				break.
			}
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
	
	return LIST(Ttest_ltln,T0 + Ttest).
}

function Impact_score {
	parameter term_traj_node, IMP_output, target_ltln.
	local drawvec_check is false.
	local term_traj_ltln is IMP_output[0].
	// GPS Score is based on the angular difference between the Lattitudes and Longitudes of the
	// target landing spot and the current impact location
	local LAT_diff is abs(target_ltln:LAT - term_traj_ltln:LAT).
	if LAT_diff > 180 {
		set LAT_diff to 360 - LAT_diff.
	}
	
	local LNG_diff is abs(target_ltln:LNG - term_traj_ltln:LNG).
	if LNG_diff > 180 {
		set LNG_diff to 360 - LNG_diff.
	}
	
	local GPS_score is 1 - (LAT_diff/360) - (LNG_diff /360).
	
	// DeltaV Score is the percentage of the starting speed at the node.
	local speed_at_node is velocityat(ship,time:seconds + nextnode:eta - 0.1):orbit:mag.
	local Dv is nextnode:deltav:mag.
	local DeltaV_score is 1 - Dv/speed_at_node.
	
	// Verticality Score is how close to 90 degrees is the final impact velocity.
	local vel_at_imp is velocityat(ship,IMP_output[1]):surface.
	local pos_at_imp is positionat(ship,IMP_output[1]).
	local body_vec is ship:body:position.
	local UP_at_imp is (pos_at_imp - body_vec):normalized.
	local Vert_diff is VANG(vel_at_imp,UP_at_imp) - 90.
	local Vert_score is Vert_diff/90.
	
	if drawvec_check {
		set Ttest_vec_Draw to vecdraw().
		set Ttest_vec_Draw:startupdater to { return V(0,0,0). }.
		set Ttest_vec_Draw:vecupdater to { return vel_at_imp. }.
		set Ttest_vec_Draw:show to true.
		set Ttest_vec_Draw:color to RGB(255,0,0).
		wait 2.
		print round(LAT_diff,3).
		print round(LNG_diff,3).
		print round(Vert_diff,2).
		print round(GPS_score,3).
		print round(DeltaV_score,3).
		print round(Vert_score,3).
	}
	
	local Total_score to 4*GPS_score + 0.25*DeltaV_score + 2*Vert_score.
	
	return Total_score.
}

function Impact_Score_Func {
	parameter Inputs.
	for n in allnodes { remove n.}
	//local term_traj_node to NODE(Inputs[0],Inputs[1],Inputs[2],Inputs[3]).
	local term_traj_node to NODE(Inputs[0],0,0,Inputs[1]).
	add term_traj_node.
	
	local IMP_output is Impact_locator().
	local term_traj_ltln is IMP_output[0].
	
	local Score is Impact_score(term_traj_node, IMP_output, target_ltln).
	
	return Score.
}

function Slope {
	parameter p1, p2, p3, delta.
	
	local der1 is (p2 - p1)/delta.
	local der2 is (p3 - p1)/(-1*delta).
	local der is (der1 + der2)/2.
	
	return der.
}

function Optimize_Score {
	parameter Inputs, Score_Func.
	
	local method is 2.
	
	local Inputs_inc to Inputs.
	local Inputs_base to Inputs.
	local iCount to 0.
	local Score_0 to Score_Func(Inputs_inc).
	local delta is 10.
	local gamma is 0.001.
	clearscreen.
	until iCount > 50 {
		local iInput to -1.
		for Input in Inputs {
			
			
			set iInput to iInput + 1.
			set Inputs_base[iInput] to Inputs_inc[iInput].
			set Inputs_inc[iInput] to Inputs_base[iInput] + delta.
			local Score_p to Score_Func(Inputs_inc).
			wait 1.
			set Inputs_inc[iInput] to Inputs_base[iInput] - delta.
			local Score_n to Score_Func(Inputs_inc).
			wait 1.
			if method = 1 {
				local der is Slope(Score_0, Score_p, Score_n, delta).
				print der.
				local Input_delta is gamma*Score_0/der.
				print Input_delta.
				set Inputs_inc[iInput] to Inputs_base[iInput] + Input_delta.
				set Score_0 to Score_Func(Inputs_inc).
			}
			if method = 2 {
				if Score_p > Score_0 AND Score_p > Score_n {
					set Inputs_inc[iInput] to Inputs[iInput] + delta.
					set Score_0 to Score_p.
				} else if Score_n > Score_0 AND Score_n > Score_p {
					set Inputs_inc[iInput] to Inputs[iInput] - delta.
					set Score_0 to Score_n.
				} else {
					set Inputs_inc[iInput] to Inputs[iInput].
					//set delta to 0.5*delta.
				}
			}
				
		}
		set iCount to iCount + 1.
		print iCount at(0,0).
	}
	return Inputs.
}

local T0 is time:seconds. // Time that the script started
local Tf is time:seconds + eta:periapsis.

local Ttest is (eta:periapsis)/2.
local term_traj_time to time:seconds + Ttest.
local radi_init to 0.
local norm_init to 0.
local prog_init to -0.5*velocityat(ship,term_traj_time):orbit:mag.

//local Inputs to LIST(term_traj_time,radi_init,norm_init,prog_init).
local Inputs to LIST(term_traj_time,prog_init).

print Impact_Score_Func(Inputs).

Optimize_Score(Inputs,Impact_Score_Func@).