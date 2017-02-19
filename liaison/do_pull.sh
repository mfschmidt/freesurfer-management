#!/bin/bash

# Download completed work from the supercomputer, then put it away where it goes.

# The path where jobs are queued up on the supercomputer
REM_OUTBOX=/ptmp/r1774/outbox
LOC_INBOX=/mri/test.fs600

# First, count how many waiting images are finished on the supercomputer.
# Using "cluster" depends on an entry in /home/$USER/.ssh/config defining it.
REM_LIST=$(ssh cluster "2>/dev/null cd $REM_OUTBOX; ls -1 *.pickup")
REM_ACTUAL=0
for item in $REM_LIST; do
	(( REM_ACTUAL += 1 ))
done
echo "Found ${REM_ACTUAL} on the cluster."

COUNTER=0
for item in $REM_LIST; do
	(( COUNTER += 1 ))
	echo "${COUNTER}. ${item%%-*}:"
	scp cluster:$REM_OUTBOX/${item%%-*}.*.tgz $LOC_INBOX/
	if (($? == 0)); then
		echo "  issuing cloud command, \"rm -rf ${REM_OUTBOX}/${item%%-*}.*.tgz\""
		ssh cluster "rm -rf ${REM_OUTBOX}/${item%%-*}.*.tgz"
	else
		echo "  secure copy failed. NOT deleting cloud files."
	fi
done
