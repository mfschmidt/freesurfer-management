freesurfer-management
===============

I use bash on various flavors of linux to run freesurfer, despite the freesurfer devs' recommentation of tcsh. This works great, and since I've run thousands of subjects, I like to have additional scripts to automate the process and add efficiencies to managing this large collection of output. I run freesurfer on a remote supercomputer that expects jobs to be specified with pbs scripts, so I've laid out the code to run on my local machine, housing the images, separately from the supercomputer.

* liaison-code:
  lives on the liaison box, manages MRI images and their transport

* cloud-code:
  lives on the remote machine running freesurfer

* node-code:
  lives on the liaison box, allows naive collaborators to see meta-information about the MRI collection via port 80 and a browser
  (This project is still to be built when I have a greater supply of time or greater demand for easy-to-digest data)
