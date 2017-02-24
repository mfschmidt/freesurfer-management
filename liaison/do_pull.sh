#!/bin/bash

# Download completed work from the supercomputer, then put it away where it goes.

# The path where jobs are queued up on the supercomputer
INITIAL_PWD=$(pwd)
REM_OUTBOX=/ptmp/r1774/outbox
LOC_INBOX=/mri/test.fs600

# First, count how many waiting images are finished on the supercomputer.
# Using "cluster" depends on an entry in /home/$USER/.ssh/config defining it.
REM_LIST=$(ssh cluster "2>/dev/null cd $REM_OUTBOX; ls -1 *.pickup")
REM_ACTUAL=0
for item in $REM_LIST; do
	(( REM_ACTUAL += 1 ))
done
echo "Found ${REM_ACTUAL} pickups on the cluster."

# Loop through completed packages on the server
COUNTER=0
cd ${LOC_INBOX}
for item in $REM_LIST; do
	(( COUNTER += 1 ))
	# The subject's ID is everything left of the . in the empty SID.pickup filename
	SID=${item%%.*}
	echo "${COUNTER}. ${SID}:"
	# First, download results
	if [ -e ${LOC_INBOX}/${SID}.fs6.tgz ]; then
		echo "${LOC_INBOX/${SID}.fs6.tgz already exists locally. Aborting download and continuing to next subject."
		echo "Please rename or delete existing ${SID} data to enable future download."
		continue
	fi
	scp cluster:${REM_OUTBOX}/${SID}.fs6.* ${LOC_INBOX}/
	# Then, clean up cloud and report each file removed
	if (($? == 0)); then
		echo "  removing cloud files: \"rm -rfv ${REM_OUTBOX}/${SID}.*.tgz\""
		RMVD=$(ssh cluster "rm -rfv ${REM_OUTBOX}/${SID}.*")
		SAVEIFS=$IFS
		IFS=$'\n'
		for RMF in $RMVD; do
			echo "    $RMF"
		done
		IFS=$SAVEIFS
	else
		echo "  ERROR: secure copy failed. NOT deleting cloud files. Please check manually."
	fi
	
	# Second, check for consistency
	SHA_OK=$(sha256sum -c ${SID}.hash 2>&1 | grep OK | wc -l)
	if [ "$SHA_OK" == "1" ]; then
		echo "ERROR: ${item} appears to have been corrupted. NOT unpackaging it."
		echo "ERROR: Please manually double check file contents on cluster and liaison computers."
		# continue skips the rest of this $item, and moves on to the next in the list
		continue
	else
		echo "Downloaded file hash checks out"
	fi
	
	# Third, unpackage them into their new homes
	if [ -e ${SID} ]; then
		echo "${SID} already exists in $(pwd) and I will not overwrite it."
		echo "Please rename or move existing ${SID} data, then manually \"tar -xzf ${SID}.fs6.tgz\" from $(pwd)"
		continue
	fi
	tar -xzf ${SID}.fs6.tgz
	if (($? == 0)); then
		rm ${SID}.fs6.tgz
		rm ${SID}.fs6.hash
	else
		echo "ERROR: unpacking failed. try manually \"tar -xzf ${SID}.fs6.tgz\" from $(pwd)"
	fi

	echo "${SID} is complete!"
done

cd ${INITIAL_PWD}
