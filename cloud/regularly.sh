#/bin/bash

BIN=/home/$USER/bin
LOG=/home/$USER/log

# Every hour, as specified in the crontab,

# Check the queue and fill any open slots with available work
$BIN/top_off_queue.sh >> $LOG/topoff.log

# Scan for completed jobs and package them for retrieval
$BIN/package_completed_jobs.sh >> $LOG/completions.log

