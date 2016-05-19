clearscreen.
lock Q to ship:dynamicpressure.
set MaxQ to 0.
until false {

    if MaxQ <= Q {
        set MaxQ to Q.
        }

    print "MaxQ    " + round(MaxQ,2) + "     " at (0,1).
    print "Q       " + round(Q,2) + "     " at (0,2).
    print "Q/MaxQ  " + round(100*Q/MaxQ,2) + "%    " at (0,3).

}