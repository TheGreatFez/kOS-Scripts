lock throttle to 1.
log "Time,Altitude" to tempalt.cvs.
SAS on.
AG1 on.
stage.

lock time1 to time:seconds.

until altitude >135000 {

log time1 +","+ altitude to tempalt.csv.
wait .5.

}

AG1 off.