The core piece of the cloud system is the ability to trigger execution of code without being there in person to type it, click it, or manage it manually. This happens with a cron job. All it needs is one line, and it will differ based upon your environment and needs.
Create a cron job by editing your cron table, as follows on most modern linux systems:

    $ crontab -e

then enter the following:

    40 * * * * /home/YOURNAME/bin/regularly.sh

This tells the system's cron daemon to run your "regularly.sh" script on the 40th minute of every hour, every day, every month, every day of the week. If you'd like a different schedule, just search for cron entries and modify this line to your liking.
Everything else stems from this. Use the "regularly.sh" script to manage anything you want on the cloud server without every having to log in.

