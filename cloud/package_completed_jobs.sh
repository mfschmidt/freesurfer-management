#!/bin/bash

# The pbs_script can run its job as scripted, but the job itself
# leaves log files that are only complete upon the job being over.
# So, as a separate entity from the pbs job, we need to package
# up those files and move them where they can be easily retrieved.

T=/ptmp/$USER
buf=$T/tarbuffer

# Check FreeSurfer variable, supplying a default if it's not set
if [ "$SUBJECTS_DIR" == "" ]; then
	SUBJECTS_DIR="/home/ums/r1774/subjects"
fi

for f in $(2>/dev/null ls -1f $T/outbox/*.complete);
do
	# We use 7 character ID numbers for each subject; this extracts it from the filename.
	# We then use it as the main identifier for everything.
	filename="${f##*/}"
	sid="${filename%%-*}"
	echo "${sid}: (${f})"
	# Move everything related to this completed subject into a buffer directory
	# Tar it, hash it, and leave it for pickup
	mkdir ${buf}
	cd ${buf}
	find $T/outbox -noleaf -type f -name "${sid}*" -exec mv {} ${buf}/ \;
	tar -czvpf $T/outbox/${sid}.logs.tgz ${sid}*
	cd ${SUBJECTS_DIR}
	tar -czvpf $T/outbox/${sid}.fs6.tgz ${sid}
	cd ${T}/outbox
	sha256sum ${sid}.logs.tgz >> $f
	mv "${f}" "${f}.pickup"
	# Then cover our tracks to keep things tidy
	rm -rf --verbose $buf
done
