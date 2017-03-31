#!/bin/bash

# Secure copy a file from the supercomputer,
# then rest for a few seconds to avoid hammering
# the supercomputer's main processor.
# Log bandwidth all the while.

echo "Starting file $1"
date >> scp_history.txt
script -q -c "scp r1774@hpcwoods.olemiss.edu:/ptmp/r1774/outbox/$1.fs_out.tgz ./" >> scp_history.txt
script -q -c "scp r1774@hpcwoods.olemiss.edu:/ptmp/r1774/outbox/$1.logs.tar.gz ./" >> scp_history.txt
echo "Got $1 files"
sleep 1
echo "Slept, moving on."
