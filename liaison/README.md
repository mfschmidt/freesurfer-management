Liaison code has two jobs.

1. Prepares packages and feed them to the supercomputer.
2. Download results from the supercomputer and unpackage them for storage and further analysis.

## Prerequisites

Using RSA public and private keys to allow scripted ssh logins, secure copy of files, etc without having to manually enter a password. It is very strongly recommended that you generate a key pair on the liaison machine and copy the public key to the supercomputer. The scripts in this project are all written assuming this has been done. Digital Ocean has a great guide on the process at https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2. You can then define everything you need about the connection in a configuration file. Add this snippet to your /home/$USER/.ssh/config file on your liaison machine.

    Host cluster
    	User [your username on the remote cluster]
    	Hostname [node.example.com]
    	Port 22
    	IdentityFile /home/$USER/.ssh/id_rsa

Use your own username and url of the cluster to replace items in brackets. If you named your key something else, just change the path/name for your IdentityFile. And change the port if necessary. Now, you can just type

    ssh cluster

and be logged in without all the mess and fuss of specifying ports and servers and other usernames and passwords. More importantly, you can have scripts copy files over the same encrypted ssh connection without entering passwords.

## Scripts

### create_pbs_script.sh

Compute clusters typically are set up with a queuing system to manage the jobs and the hardware allocation for them. This script writes another script that informs the cluster what kind of environment to set up, what hardware requirements are necessary, and what to execute.

### do_push.sh

Push all necessary files up to the cluster from the liaison machine through an ssh tunnel via the scp command. As written, the script finds all *.tgz files in the specified folder and secure copies them (along with a pbs script for each) to the specified folder on the remote machine. Paths and quantities are set at the top of the do_push.sh script, so once set, you can just run the script from the liaison computer's command line.

    $ do_push.sh

Before any of this can happen, you need to package your files to upload. Because there are so many image formats possible, this is not scripted, but should be done manually. Two options that work for us follow:

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


    

### do_pull.sh

Pulls all completed files from the cluster down to the liaison machine. This script queries the cluster with the ls command over ssh to determine what to download, then it secure copies results down to its own disks and removes the copy on the cluster. Once paths are set at the top of do_pull.sh, just run the command from your the linux command line on the liaison computer.

    $ do_pull.sh



