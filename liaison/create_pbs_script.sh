#!/bin/bash

# Receive an argument for the ID and another for 
# and generate a script to run FreeSurfer on a remote PBS cluster

# The first argument is the subject ID
SID="$1"
# The second argument is the image used for FreeSurfer processing:
IMG="$2"
# The username may differ locally vs on the remote cluster. Specify it here
UID="r1774"
# Path names should be specific to the installation on the remote cluster.
FSH="/home/ums/${UID}/freesurfer"
FSS="/home/ums/${UID}/subjects"
# You can change where the script is stored here
SCRIPT="./${SID}-freesurfer.pbs"

echo "#!/usr/bin/bash\n\n" >> $SCRIPT
echo "#PBS -N ${SID}-FS6\n\n" >> $SCRIPT
echo "#PBS -v FREESURFER_HOME=${FSH}\n" >> $SCRIPT
echo "#PBS -v SUBJECTS_DIR=${FSS}\n" >> $SCRIPT
echo "#PBS -l nodes=1:ppn=1,mem=4gb\n" >> $SCRIPT
echo "source ${FSH}/SetUpFreeSurfer.sh\n\n" >> $SCRIPT
echo "recon-all -i ${IMG} -subjid ${SID}\n" >> $SCRIPT
echo "recon-all -subjid ${SID} -all -hippo-subfields\n" >> $SCRIPT

echo "Script complete for subject ${SID}."

