#!/bin/bash

# This script will probably have to be written custom for each project
# as image types may differ. This version grabs an Analyze formatted
# image set with two files, one the image data (*.img) and one the meta-
# or header information (*.hdr). In the modern world, it may be more
# common to use DICOM sets (hundreds of similarly named files, one per
# slice) or Nifti images (*.nii)

# Accept one input argument, which is both the subject's ID number and
# the name of the subdirectory where it is stored.
SID=$1
COLLECTION_DIR=/mri/gmbi.rochester.original
QUEUE_DIR=/mri/queue
PWD=$(pwd)

# Create a pbs script to run freesurfer on it, and package up the image.
cd ${COLLECTION_DIR}/${1}
# There should only ever be one file
IMG_FILE=$(2>/dev/null ls -1f ${SID}*spgr.img | head -1)
if [ "$IMG_FILE" == "" ]; then
	echo "ERROR: no img file found for ${SID} matching \"${SID}*spgr.img\""
	cd ${PWD}
	exit
fi

tar -czvf ${QUEUE_DIR}/${SID}.tgz ${IMG_FILE:: -4}.*
create_pbs_script.sh ${SID} ${IMG_FILE}
mv *.pbs ${QUEUE_DIR}/

cd ${PWD}
