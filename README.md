# freesurfer-management
===============

This project contains many scripts to manage FreeSurfer processing and data. Due to the volume of participants in our data set, we house the data on a file server and run FreeSurfer on a separate supercomputer. Managing the data flow and processing burden can be a huge job, but is made pretty easy with these scripts. These scripts are written for the bash shell, even though the FreeSurfer devs seem to prefer tcsh. This has been successful for thousands of participants' data so far on Ubuntu, Debian, and CentOS. Any standard linux distribution with bash should work without issue. Code for the supercomputer is stored in the cluster folder. Everything else is in the root directory, making adding it to your path one step.

The basic idea is that each subject will take about a day to process, but I don't want to manually log in and queue up the next one each time one finishes. So this system allows me to queue up ALL subjects (as many as I can fit on a disk) for an entire project. The cloud system can check its queue and grab a new job whenever it has capacity, with no interaction from me. This way, I can make better use of my time over the months it can take to run many hundreds of subjects.

## cluster

The supercomputer is termed the "cluster" computer. It could be an institutional cluster, an extra laptop, an amazon compute instance, a home-built server, or anything else capable of running linux, FreeSurfer, and a job management system. These scripts are written to submit the jobs to a PBS job management system. They can be modified to run on SGE software or with a little more work, just as processes on the OS. In our circumstance, the supercomputer is intended to provide processing power, but not data storage. For that reason, we do what we can to get the data up for computation, then back down and off of the disk as soon as we can.

### cluster scripts

#### regularly.sh

regularly.sh is just the simple script you would call from a cron job on the cluster supercomputer. See https://www.digitalocean.com/community/tutorials/how-to-use-cron-to-automate-tasks-on-a-vps for cron examples. We run ours on the 40th minute of every hour with the following cron entry (stored with the command "crontab -e" on the cluster).

    40 * * * * /home/.../bin/regularly.sh

It simply calls the other two scripts in this folder: top_off_queue.sh; and package_completed_jobs.sh.

#### top_off_queue.sh

This script determines how many spots are available to run more subjects, then how many subjects are waiting to be run, then submits enough waiting jobs to keep the queue full.

#### package_completed_jobs.sh

This script determines how many jobs have completed since its last run. It then packages them up, with their log files, and moves them to the outbox folder so the liaison computer can download them later.

## Liaison

The computer that houses all of the data, both raw MRI data and processed FreeSurfer data, is called the "liaison" computer. It acts as a liaison between the many MR images on its disks, and the supercomputer that processes them.  It is responsible for packaging up the jobs for submission to the supercomputer, uploading and downloading files, and for unpacking results for long term storage and later analysis. The following scripts manage the packaging, uploading, and downloading of data between machines.

Liaison code has two jobs.

1. Prepares packages and feed them to the supercomputer.
2. Download results from the supercomputer and unpackage them for storage and further analysis.

### Prerequisites

Using RSA public and private keys to allow scripted ssh logins, secure copy of files, etc without having to manually enter a password. It is very strongly recommended that you generate a key pair on the liaison machine and copy the public key to the supercomputer. The scripts in this project are all written assuming this has been done. Digital Ocean has a great guide on the process at https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2. You can then define everything you need about the connection in a configuration file. Add this snippet to your /home/$USER/.ssh/config file on your liaison machine.

    Host cluster
    	User [your username on the remote cluster]
    	Hostname [node.example.com]
    	Port 22
    	IdentityFile /home/$USER/.ssh/id_rsa

Use your own username and url of the cluster to replace items in brackets. If you named your key something else, just change the path/name for your IdentityFile. And change the port if necessary. Now, you can just type

    ssh cluster

and be logged in without all the mess and fuss of specifying ports and servers and other usernames and passwords. More importantly, you can have scripts copy files over the same encrypted ssh connection without entering passwords.

### Scripts

#### create_pbs_script.sh

Compute clusters typically are set up with a queuing system to manage the jobs and the hardware allocation for them. This script writes another script that informs the cluster what kind of environment to set up, what hardware requirements are necessary, and what to execute.

#### do_push.sh

Push all necessary files up to the cluster from the liaison machine through an ssh tunnel via the scp command. As written, the script finds all *.tgz files in the specified folder and secure copies them (along with a pbs script for each) to the specified folder on the remote machine. Paths and quantities are set at the top of the do_push.sh script, so once set, you can just run the script from the liaison computer's command line.

    $ do_push.sh

#### do_pull.sh

Pulls all completed files from the cluster down to the liaison machine. This script queries the cluster with the ls command over ssh to determine what to download, then it secure copies results down to its own disks and removes the copy on the cluster. Once paths are set at the top of do_pull.sh, just run the command from your the linux command line on the liaison computer.

    $ do_pull.sh

#### pack.spgr.sh

Before any of this can happen, you need to package your files to upload. Because there are so many image formats possible, most are not yet scripted, but should be done manually. For our specific case, the pack.spgr.sh script zips up the images, creates the pbs script, and moves them to the output folder.

    $ pack.spgr.sh X000000
    
The manual options that do the same job follow:

For an Analyze image:

    $ cd /var/originals/X000000
    $ tar -czvf /var/queue/X000000.tgz X000000*spgr.{hdr,img}
    $ create_pbs_script.sh X000000*spgr.img
    $ cp *.pbs /var/queue/
    
For a set of DICOM images:

    $ cd /var/originals/X000000
    $ tar -czvf /var/queue/X000000.tgz X000000*001+*0*.dcm
    $ create_pbs_script.sh X000000*001+*001.dcm
    $ cp *.pbs /var/queue/
    
or, if you have more than a few images, something like this to get them all:

    $ cd /var/originals
    $ for sid in $(ls -1d X*); do cd $sid; tar -czvf /var/queue/$sid.tgz $sid*spgr.{hdr,img}; create_pbs_script.sh $sid*spgr.img; cp *.pbs /var/queue; cd -; done

## Utility

The utility scripts are used to interpret and manage the processed FreeSurfer data above and beyond the tools that are supplied with the FreeSurfer package. We use them to extract specific items of interest, to convert FreeSurfer text files into other formats that are easier to analyze, etc. This code is often run on the liaison computer, but can be run anywhere you have a freesurfer dataset you would like to query.

### Utility scripts

#### bash_mind_functions.sh

This script simply defines some functions that are useful in other scripts; it does nothing by itself. From another script, or your own, simply

    source [your path]/freesurfer-management/bash_mind_functions.sh

or, if it's already in your $PATH,

    source $(which bash_mind_functions.sh)

then use the following functions as you like.

* has_mipav_data() returns 1 if xml files are available. This indicates VOI data from MIPAV in our case.
* has_freesurfer_data() returns 1 if it finds 8 of the 11 possible freesurfer subdirectories. Older versions of freesurfer had 10 subdirectories; version 6 has 9, but one is new and two old ones no longer exist.
* has_analyze_data() returns 1 if *.hdr and *.img files are in the directory.
* has_mipav_data() returns 1 if any of the files return dicom header information to the AFNI dicom_hinfo() function. AFNI must be installed and initialized for this to work.

These could be used profitably to find all directories with freesurfer data in the /var/mri directory tree. Directories and subdirectories that do not have the expected structure within would not be printed.

    source $(which bash_mind_functions.sh)
    for d in $(find /var/mri -type d); do
        has_freesurfer_data "$d"
        if [ $? ]; then
            echo "$d"
        fi
    done

#### dir_contents.sh

This builds on bash_mind_functions.sh to report what is probably in a folder. Rather than doing the whole several lines above, you can just enter from the commandline:

    dir_contents.sh X000000

and it will check for each type of data in bash_mind_functions.sh, reporting what it found.

#### fssig

This reports a json-formatted collection of information about the freesurfer data contained in the folder specified. It includes the subject-id and the datetime run so it is very likely unique to each freesurfer run, even if you ran the same subject many times. It's a quick way to ask freesurfer data what subject, version, and datetime exist in its directories. It also lists left and right hippocampal volume since that's our primary data point of interest.

    fssig X000000

returns something like

    {"id":"X000000","v":"6.0.0-2beb96c","done":"2017-03-30 16:08","hv":"L=4321.0,R=4567.8"}

#### fs411

This is the general purpose swiss army knife for querying freesurfer data. It's gaining functionality all the time, so ask it what it can do from the command line:

    fs411 -h

It basically allows you to query the freesurfer data for specific items. Want to know how long it took for FreeSurfer to process this data set?

    fs411 -t X000000

gives you:

    X000000 : 57901 seconds (16.1 hrs)

And there are more. And more are needed. So if you want to implement one, write it into the script and let me know about it.

## Notes:

These scripts represent a balance between good software engineering practice and rapidly automating tasks. For example, most paths are specific to our configuration and will not work for you as written (rapidly automating OUR tasks). We have tried to put all of the paths at the top of the scripts rather than sprinkled throughout as hard-coded strings(good software engineering practice). But we haven't gone so far as to create an initialization package or setup script to define them all and allow their administration centrally (great software engineering practice).

These scripts have cost us time in development, saved us time overall in processing and execution, and we hope they make other researchers' lives easier. But they are not polished commercial software and will require a minimal investment for their correct usage. I imagine anyone using FreeSurfer is doing research, and therefore appreciates they need to understand your methods, read through the scripts and know what they're doing in the first place rather than just executing code and hoping for the best.

