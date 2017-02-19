# freesurfer-management
===============

This project contains many scripts to manage FreeSurfer processing and data. Due to the volume of participants in our data set, we house the data on a file server and run FreeSurfer on a separate supercomputer where we are granted the usage of 35 concurrent processors. Managing the data flow and processing burden can be a huge job, but is made pretty easy with these scripts. These scripts are written for the bash shell, even though the FreeSurfer devs seem to prefer tcsh. This has been successful for thousands of participants' data so far on Ubuntu, Debian, and CentOS. Any standard linux distribution with bash should work without issue. Code for each computer is in a separate directory making it easy to use git or scp to put the appropriate code into an executable location on the proper machine.

## cloud

The supercomputer is termed the "cloud" computer. It could be an institutional cluster, an extra laptop, an amazon compute instance, a home-built server, or anything else capable of running linux and FreeSurfer. These scripts are written to submit the jobs to a PBS job management system. They can be modified to run on SGE software or with a little more work, just as threads on the OS. In our circumstance, the supercomputer is intended to provide processing power, but not data storage. For that reason, we do what we can to get the data up for computation, then back down and off of the disk as soon as we can.

## liaison

The computer that houses all of the data, both raw MRI data and processed FreeSurfer data, is called the "liaison" computer. It acts as a liaison between the many MR images on its disks, and the supercomputer that processes them.  It is responsible for packaging up the jobs for submission to the supercomputer, uploading and downloading files, and for unpacking results for long term storage and later analysis.

## utility

The utility scripts are used to interpret and manage the processed FreeSurfer data above and beyond the tools that are supplied with the FreeSurfer package. We use them to extract specific items of interest, to convert FreeSurfer text files into other formats that are easier to analyze, etc.


The basic idea is that each subject will take about a day to process, but I don't want to manually log in and queue up the next one each time one finishes. So this system allows me to queue up ALL subjects (as many as I can fit on a disk) for an entire project. The cloud system can check its queue and grab a new job whenever it has capacity, with no interaction from me. This way, I can make better use of my time over the months it can take to run many hundreds of subjects.

## Notes:

These scripts represent a balance between good software engineering practice and rapidly automating tasks. For example, most paths are specific to our configuration and will not work for you as written. We have tried to put all of the paths at the top of the scripts rather than sprinkled throughout as hard-coded strings. But we haven't gone so far as to create an initialization package or setup script to define them all and allow their administration centrally.

These scripts have cost us time in development, saved us time overall in processing and execution, and we hope they make other researchers' lives easier. But they are not polished commercial software and will require a minimal investment for their correct usage. I imagine anyone using FreeSurfer is doing research, and therefore appreciates they need to understand your methods, read through the scripts and know what they're doing in the first place rather than just executing code and hoping for the best.

