#!/bin/bash

INBOXDIR=/ptmp/$USER/inbox

##-------------------------------------------------------------------------
## Check for open slots in the queue and fill them if possible
## Anything found in $INBOXDIR with a *.pbs extension
## will be queued and run.

# First, determine state of things
MAX_QUEUED=40
num_queued=$(/opt/pbs/default/bin/qstat | grep $USER | wc -l)
empty_slots=$(( MAX_QUEUED - num_queued - 1 ))

msg1="$num_queued, of $MAX_QUEUED slots full, leaving us $empty_slots"
msg2=""

# Second, run through possible jobs and queue some
jobs_to_go=0
freshly_queued=0
cursor=0
for job in $(2>/dev/null ls -1f $INBOXDIR/*.pbs);
do
	(( cursor += 1 ))
	if [ $empty_slots -gt 0 ];
	then
		INFILE="${job##*/}"
		INFILE="${INFILE%%.*}"
		msg2="${msg2}$cursor. ${INFILE}\n"
		qsub $job
		mv $job $job.queued
		(( freshly_queued += 1 ))
	else
		(( jobs_to_go += 1 ))
	fi
	(( empty_slots -= 1 ))
done

msg3="$jobs_to_go jobs left to go.\n"

if [[ "$jobs_to_go" == "0" && "$freshly_queued" == "0" ]]; then
	printf "$(date) : no work\n"
else
	printf "$(date) : ${msg1}, ${msg3}${msg2}"
fi
