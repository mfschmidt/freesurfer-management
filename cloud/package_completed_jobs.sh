#!/bin/bash

# The pbs_script can run its job as scripted, but the job itself
# leaves log files that are only complete upon the job being over.
# So, as a separate entity from the pbs job, we need to package
# up those files and move them where they can be easily retrieved.

T=/ptmp/$USER
buf=$T/tarbuffer/

for f in $(2>/dev/null ls -1f $T/outbox/batched.*);
do
	sid=${f:27:7}
	echo "${sid}: (${f})"
	mkdir ${buf}
	cd ${buf}
	find ~/ $T/inbox/ -noleaf -type f -name "${sid}*" -exec mv {} ${buf} \;
	tar -czvpf $T/outbox/${sid}.logs.tgz ${sid}*
	cd ${T}/outbox
	md5sum ${sid}.logs.tgz >> $f
	mv ${f} ${f/batched/pickup}
	rm -rf $buf
done
