#!/bin/bash

# gen_masks_from_freesurfer.sh freesurfer_directory output_directory

ASEG="aseg"
MIPAV=/usr/local/mipav730/mipav
MIPAVSCRIPT=/home/mike/bin/mrcode/open_image_and_save_hf_mask.sct

# Check on input and output directories
INPUTDIR="$1"
if [ ! -e "$INPUTDIR" ]; then
	echo "\"$INPUTDIR\" does not exist."
	exit 1
fi

if [ "$2" == "" ]; then
	OUTPUTDIR="$INPUTDIR"
else
	OUTPUTDIR="$2"
fi
if [ ! -e "$OUTPUTDIR" ]; then
	# Make an attempt to create the output directory, and give up if we can't.
	2>/dev/null mkdir "$OUTPUTDIR"
	if [ ! -e "$OUTPUTDIR" ]; then
		echo "\"$OUTPUTDIR\" does not exist, and I cannot create it."
		exit 1
	fi
fi

SID="${INPUTDIR##*/}"
FSV="$(fs411 -vs "$INPUTDIR")"

# Make sure expected files are in place
if [ ! -f "${INPUTDIR}/mri/${ASEG}.mgz" ]; then
	echo "No aseg.mgz in ${INPUTDIR}/mri/"
	exit 1
fi
if [ -f "${OUTPUTDIR}/${SID}.${ASEG}.${FSV}.nii.gz" ]; then
	echo "${OUTPUTDIR}/${SID}.${ASEG}.${FSV}.nii.gz already exists."
	exit 1
fi
if [ -f "${OUTPUTDIR}/${SID}.${ASEG}.${FSV}.hdr" ]; then
	echo "${OUTPUTDIR}/${SID}.${ASEG}.${FSV}.hdr already exists."
	exit 1
fi

mri_convert \
	--in_type mgz --out_type nii --out_orientation LPI \
	"${INPUTDIR}/mri/${ASEG}.mgz" \
	"${OUTPUTDIR}/${SID}.${ASEG}.${FSV}.nii.gz"

nifti_tool -copy_im \
	-prefix "${OUTPUTDIR}/${SID}.${ASEG}.${FSV}.hdr" \
	-infiles "${OUTPUTDIR}/${SID}.${ASEG}.${FSV}.nii.gz"

rm -rf "${OUTPUTDIR}/${SID}.${ASEG}.${FSV}.nii.gz"
