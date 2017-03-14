#!/bin/bash

# Package up an image and script, then upload them to the supercomputer.

# The most images we want to store on the supercomputer before processing
REM_LIMIT=50
# The path where jobs are queued up on the supercomputer
REM_INBOX=/ptmp/r1774/inbox
LOC_INBOX=/mri/queue

# First, count how many waiting images are already on the supercomputer.
# Using "cluster" depends on an entry in /home/$USER/.ssh/config defining it.
REMOTES=$(ssh cluster "2>/dev/null ls -1 $REM_INBOX/*.tgz")
if [ "$REMOTES" == "" ] ; then
	REM_ACTUAL=0
else
	REM_ACTUAL=$(echo $REMOTES | wc -l)
fi
# Next, count how many waiting images are yet to be uploaded.
LOCALS=$(2>/dev/null ls -1 $LOC_INBOX/*.tgz)
if [ "$LOCALS" == "" ] ; then
	LOC_ACTUAL=0
else
	LOC_ACTUAL=$(echo $LOCALS | wc -l)
fi

echo "============-- $(date) --============"
echo "Found ${REM_ACTUAL} on the cluster and ${LOC_ACTUAL} locally."

if [[ "$LOC_ACTUAL" -gt "0" ]] && [[ "$REM_ACTUAL" -lt "$REM_LIMIT" ]]
then
	# Update the state of the queues, but we JUST did this above.
	#REM_ACTUAL=$(ssh cluster "2>/dev/null ls -1 $REM_INBOX/*.tgz | wc -l")
	#LOC_ACTUAL=$(2>/dev/null ls -1 $LOC_INBOX/*.tgz | wc -l)
	COUNTER=1
	# Upload the appropriate number of subjects	
	NEED=$(($REM_LIMIT-$REM_ACTUAL))
	for f in $(echo "${LOCALS}" | head -${NEED})
	do
		g="${f##*/}"
		SID=${g%%.*}
		if grep -q "${SID}" <<< "${REMOTES}"; then
			echo "${SID} already exists on cloud. Passing on it to avoid overwriting."
			continue
		fi
		cd ${LOC_INBOX}
		echo "upload #${COUNTER}. $g"

		# The whole purpose of this script!! Upload the package and the pbs script.
		scp ${f} cluster:${REM_INBOX}/
		scp ${SID}-freesurfer.pbs cluster:${REM_INBOX}/

		ssh cluster "mkdir ${REM_INBOX}/${SID}; cd ${REM_INBOX}/${SID}; tar -xzf ../${g}; rm ../${g}"
		#Everything in the queue is a copy, not an original!! Move them to ./QUEUED for manual deletion.
		if [ ! -e ./QUEUED ]; then
			mkdir ./QUEUED
		fi
		h=$g
		if [ -e ./QUEUED/${g} ]; then
			APPENDER="0"
			h="${SID}.${APPENDER}.tgz"
			while [ -e ./QUEUED/${h} ]; do
				((APPENDER += 1))
				h="${SID}.${APPENDER}.tgz"
			done
		fi
		mv ${g} ./QUEUED/${h}
		mv ${SID}-freesurfer.pbs ./QUEUED/${SID}.${APPENDER}-freesurfer.pbs
		cd -
		COUNTER=$(($COUNTER+1))
	done
fi


