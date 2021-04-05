@lazyGlobal OFF.

global manNodeLib to ({
	local function ExecuteNode {
		clearscreen.
		lock throttle to 0.
		SAS off.
		local Delta_V to nextnode:deltav:mag.
		local BurnTime to Delta_V*mass/availablethrust.
		lock steering to lookdirup(nextnode:burnvector,ship:facing:upvector).
		print "Aligning with Maneuver Node".
		until VANG(ship:facing:vector,nextnode:burnvector) < 1 {
			print "Direction Angle Error = " + round(VANG(ship:facing:vector,nextnode:burnvector),1) + "   "at(0,1).
		}
		clearscreen.
		print "Alignment Complete".
		print "Warping to Burn Point".
		print "Burn Starts at T-minus " + round(BurnTime,2) + "secs   ".
		warpto(time:seconds + nextnode:eta - BurnTime/2 - 10).
		wait until warp <= 0.

		clearscreen.
		local prev_dv to Delta_V.
		local diff_dv to -1.
		local stop_burn to false.
		local thr_var to 0.
		lock throttle to thr_var.

		until Delta_V <= .05  {
			set Delta_V to nextnode:deltav:mag.
			if nextnode:eta > BurnTime/2 {
				print "Burn Starts at T-minus " + round(nextnode:eta - BurnTime/2,2) + "secs   " at(0,1).
			} else {
				set thr_var to 1*Delta_V*mass/availablethrust.
				print "Initiate Burn                            " at(0,1).		    
			}
			print "Delta V = " + round(Delta_V,2) + "      " at(0,2).
			print "Throttle = " + MIN(100,round(throttle*100)) + "%      " at(0,3).
			print "diff_dv  = " + round(diff_dv,2) + "      " at(0,4).
			wait 0.
			set diff_dv to Delta_V - prev_dv.
			if diff_dv > 0 {
				set stop_burn to true.
			} else {
				set prev_dv to Delta_V.
			}
		}
		lock throttle to 0.
		unlock all.
		remove nextnode.
		clearscreen.
		print "Node Executed".
		print "Delta V Error: " + round(Delta_V,3) + "m/s".
		wait 2.
	}

	return lexicon(
		"ExecuteNode", ExecuteNode@
	).

}):call().