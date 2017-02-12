freesurfer-management
===============

I use bash on various flavors of linux to run freesurfer, despite the freesurfer devs' recommentation of tcsh. This works great, and since I've run thousands of subjects, I like to have additional scripts to automate the process and add efficiencies to managing this large collection of output. I run freesurfer on a remote supercomputer that expects jobs to be specified with pbs scripts, but I don't store all of the data there; it lives on my local machine. So I refer to my local machine as the "liaison" and the supercomputer as the "cloud." I've laid out the code separately for each role.

* liaison:
  lives on the liaison box, manages MRI images and their transport

* cloud:
  lives on the remote machine running freesurfer

The basic idea is that each subject will take about a day to process, but I don't want to manually log in and queue up the next one each time one finishes. So this system allows me to queue up ALL subjects (as many as I can fit on a disk) locally for an entire project. The cloud system can check my local queue over ssh and grab a new job whenever it likes, with no interaction from me. This way, I can make good use of my time over the months it can take to run many hundreds of subjects.
