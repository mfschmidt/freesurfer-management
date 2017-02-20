#!/bin/bash

# Package up an image and script, then upload them to the supercomputer.

# The most images we want to store on the supercomputer before processing
REM_LIMIT=50
# The path where jobs are queued up on the supercomputer
REM_INBOX=/ptmp/r1774/inbox
LOC_INBOX=/mri/queue

# First, count how many waiting images are already on the supercomputer.
# Using "cluster" depends on an entry in /home/$USER/.ssh/config defining it.
REM_ACTUAL=$(ssh cluster "2>/dev/null ls -1 $REM_INBOX/*.tgz | wc -l")
echo "Found ${REM_ACTUAL} on the cluster."

# Next, count how many waiting images are yet to be uploaded.
LOC_ACTUAL=$(2>/dev/null ls -1 $LOC_INBOX/*.tgz | wc -l)
echo "Found ${LOC_ACTUAL} locally."

if [[ "$LOC_ACTUAL" -gt "0" ]] && [[ "$REM_ACTUAL" -lt "$REM_LIMIT" ]]
then
	# Update the state of the queues	
	REM_ACTUAL=$(ssh cluster "2>/dev/null ls -1 $REM_INBOX/*.tgz | wc -l")
	LOC_ACTUAL=$(2>/dev/null ls -1 $LOC_INBOX/*.tgz | wc -l)
	COUNTER=1
	# Upload the appropriate number of subjects	
	NEED=$(($REM_LIMIT-$REM_ACTUAL))
	for f in $(2>/dev/null ls -1 $LOC_INBOX/*.tgz | head -${NEED})
	do
		cd ${LOC_INBOX}
		echo "upload #${COUNTER}. $f"
		scp ${f} cluster:${REM_INBOX}/
		SID=${f%%.*}
		SID=${SID##*/}
		scp ${SID}-freesurfer.pbs cluster:${REM_INBOX}/
		ssh cluster "mkdir ${REM_INBOX}/${SID}; cd ${REM_INBOX}/${SID}; tar -xzf ../${f##*/}; rm ../${f##*/}"
		#Everything in the queue is a copy, not an original!! Move them to ./QUEUED for manual deletion.
		if [ ! -e ./QUEUED ]; then
			mkdir ./QUEUED
		fi
		mv ${f} ./QUEUED/
		mv ${SID}-freesurfer.pbs ./QUEUED/
		cd -
		COUNTER=$(($COUNTER+1))
	done
fi


