#/bin/bash

# Every hour, as specified in the crontab,

# Check the queue and fill any open slots with available work
/home/ums/r1774/bin/top_off_queue.sh >> /home/ums/r1774/topoff.log

# Scan for completed jobs and package them for retrieval
/home/ums/r1774/bin/package_completed_jobs.sh >> /home/ums/r1774/completions.log

