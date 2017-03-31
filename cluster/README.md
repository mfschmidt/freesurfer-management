## 1. Cron

The core piece of the cloud system is the ability to trigger execution of code without being there in person to type it, click it, or manage it manually. This happens with a cron job. All it needs is one line, and it will differ based upon your environment and needs.
Create a cron job by editing your cron table, as follows on most modern linux systems:

    $ crontab -e

then enter the following:

    40 * * * * /home/YOURNAME/bin/regularly.sh

This tells the system's cron daemon to run your "regularly.sh" script on the 40th minute of every hour, every day, every month, every day of the week. If you'd like a different schedule, just search for cron entries and modify this line to your liking.
Everything else stems from this. Use the "regularly.sh" script to manage anything you want on the cloud server without every having to log in.

## 2. Regularly

The regularly.sh script first ensures the queue is full so we remain efficient users of computing resources. It then checks for any completed jobs. The completed jobs must be packaged up and moved from the supercomputer. Its job, remember, is to process files not to store them. While reading the script, note that we redirect all output to log files from here. This makes the pre- and post- scripts below cleaner because they don't have to worry about logging. And it makes them more versatile so you can call them from the command line any time and get their output right at the console, without clogging your logs. You can always do both while troubleshooting as follows:

    top_off_queue.sh | tee -a ~/log/logfile.log
    
The "tee" command causes the output from top_off_queue.sh to both be sent to the screen and be (-a) appended to the file specified.

### 2a. Top off

Topping off the queue is simply checking to see if the computer has capacity to do more than it's currently doing, then checking to see if there's any additional work to do. If so, fill its capacity with remaining work. This is done with the top_off_queue.sh script.

### 2b. Clean up

Cleaning up has a few complexities to deal with. First, we try to ensure that everything that needs to be done for each subject is handled in the pbs script, created on the liaison side. But the pbs job generates two log files that are not complete until the job is done. Cleaning up the job's log files cannot be done by the job itself. The package_completed_jobs.sh script takes care of those log files as well as getting the output off of the supercomputer and onto a machine designed more for long term file storage.

## 3. Aliases

Aliases are not strictly necessary, but they can help you to login and get rapid snapshots of what's going on with a minimum of keystrokes. I have put the following lines into my /home/$USER/.bashrc file. The .bashrc file gets sourced every time you log in to a linux system, so by putting lines here, it's like typing them into your shell automatically every time you login.

    alias q_waiting='echo "$(ls -1 /ptmp/r1774/inbox | grep pbs | wc -l) to finish"'
    alias q_complete='echo "$(ls -1 /ptmp/r1774/outbox | grep pickup | wc -l) complete, to download"'
    alias q_running='echo "$(qstat | grep r1774 | wc -l) running:"'
    alias q='q_waiting; q_complete; q_running; qstat | grep r1774'

Now, I can just type the following at the command prompt and see how many subjects are queued up, how many have been finished but not downloaded to the liaison machine yet, and how many are currently running. And that's followed by a list of all jobs running under my user account.

    $ q

Quite easy!
