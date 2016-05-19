lock steering to srfretrograde.
delete tempalt.csv.
log "Time,Altitude" to tempalt.csv.
AG1 on.

clearscreen.

lock time1 to time:seconds.

wait until altitude < 130000.

print "gathering data".

until 1 > 2 {

log time1 +","+ altitude to tempalt.csv.
wait 1.

}

AG1 off.