lock steering to up.

declare function Hysteresis {
	declare parameter input,prev_output, right_hand_limit, left_hand_limit,right_hand_output is true.
	set output to prev_output.
	if prev_output = right_hand_output {
		if input <= left_hand_limit {
			set output to not(right_hand_output).
		}
	} else {
		if input >= right_hand_limit {
			set output to right_hand_output.
		}
	}
	return output.
}
//Hyst Test
//set test_out to Hysteresis(75,false,100,50,true).
//print test_out.
//set test_out to Hysteresis(101,test_out,100,50,true).
//print test_out.
//set test_out to Hysteresis(75,test_out,100,50,true).
//print test_out.
//set test_out to Hysteresis(25,test_out,100,50,true).
//print test_out.

lock default_throttle to mass*9.81/availablethrust. 
set throttle_check to true.
set right_hand_limit to 100.
set left_hand_limit to 90.
clearscreen.
until false {
	
	set throttle_check to Hysteresis(altitude,throttle_check,right_hand_limit,left_hand_limit,false).
	if throttle_check {
		lock throttle to default_throttle*1.1.
	} else {
		lock throttle to default_throttle*0.9.
		}
	
	print throttle_check at(0,0).
	print round(altitude,0) at(0,1).
	print round(100*throttle,0) at(0,2).
}
	
	