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


