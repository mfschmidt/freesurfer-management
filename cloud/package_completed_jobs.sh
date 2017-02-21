#!/bin/bash

# The pbs_script can run its job as scripted, but the job itself
# leaves log files that are only complete upon the job being over.
# So, as a separate entity from the pbs job, we need to package
# up those files and move them where they can be easily retrieved.

T=/ptmp/$USER

# Check FreeSurfer variable, supplying a default if it's not set
if [ "$SUBJECTS_DIR" == "" ]; then
	SUBJECTS_DIR="/home/ums/r1774/subjects"
fi

for f in $(2>/dev/null ls -1f $T/outbox/*.complete);
do
	# We use 7 character ID numbers for each subject; this extracts it from the filename.
	# We then use it as the main identifier for everything.
	filename="${f##*/}"
	SID="${filename%%-*}"
	echo "${SID}: (${f})"

	# Move all logs related to this subject to its FreeSurfer log directory
	mkdir ${SUBJECTS_DIR}/${SID}/logs
	find $T/outbox -noleaf -type f -name "${SID}*" -exec mv {} ${SUBJECTS_DIR}/${SID}/logs/ \;

	# Zip it all up into a single file
	cd ${SUBJECTS_DIR}
	tar -czvpf $T/outbox/${SID}.fs6.tgz ${SID}
	cd ${T}/outbox

	# Hash it and flag it for pickup by the liaison machine
	sha256sum ${SID}.fs6.tgz >> ${SID}.fs6.hash
	touch "${SID}.pickup"

	# Then cover our tracks to keep things tidy and space-efficient
	#rm -rf "${SUBJECTS_DIR}/${SID}"
done
