#!/bin/bash

# Receive an argument for the ID and another for 
# and generate a script to run FreeSurfer on a remote PBS cluster

# The first argument is the subject ID
SID="$1"
# The second argument is the image used for FreeSurfer processing:
IMG="$2"
# The username may differ locally vs on the remote cluster. Specify it here
REM_USER="r1774"
# Path names should be specific to the installation on the remote cluster.
FSQ="/ptmp/${REM_USER}/inbox"
FSH="/home/ums/${REM_USER}/freesurfer"
FSS="/home/ums/${REM_USER}/subjects"
# You can change where the script is stored here
SCRIPT="./${SID}-freesurfer.pbs"

echo -e "#!/usr/bin/bash\n" >> $SCRIPT
echo -e "#PBS -N ${SID}-FS6" >> $SCRIPT
echo -e "#PBS -v FREESURFER_HOME=${FSH}" >> $SCRIPT
echo -e "#PBS -v SUBJECTS_DIR=${FSS}" >> $SCRIPT
echo -e "#PBS -l nodes=1:ppn=1,mem=4gb\n" >> $SCRIPT
echo -e "source ${FSH}/SetUpFreeSurfer.sh\n" >> $SCRIPT
# The IMG parameter expansion just strips the file portion from the path to the image.
echo -e "recon-all -i ${FSQ}/${IMG##*/} -subjid ${SID}" >> $SCRIPT
echo -e "recon-all -subjid ${SID} -all -hippo-subfields -brainstem-structures\n" >> $SCRIPT

echo -e "Script ${SCRIPT} complete for subject ${SID}."
