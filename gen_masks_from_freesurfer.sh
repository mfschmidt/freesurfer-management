#!/bin/bash

# gen_masks_from_freesurfer.sh freesurfer_directory output_directory

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
FSV="${FSV//./}"

# Make sure expected files are in place
if [ ! -f "${INPUTDIR}/mri/aseg.mgz" ]; then
	echo "No aseg.mgz in ${INPUTDIR}/mri/"
	exit 1
fi
if [ -f "${OUTPUTDIR}/${SID}.aseg.${FSV}.nii.gz" ]; then
	echo "${OUTPUTDIR}/${SID}.aseg.${FSV}.nii.gz already exists."
	exit 1
fi
if [ -f "${OUTPUTDIR}/${SID}.aseg.${FSV}.hdr" ]; then
	echo "${OUTPUTDIR}/${SID}.aseg.${FSV}.hdr already exists."
	exit 1
fi
if [ ! -f $(which mri_convert) ]; then
    echo "FreeSurfer must be installed to convert mgz segmentation to img mask."
    echo "I cannot find FreeSurfer's mri_convert executable, so cannot continue."
    exit 1
fi
#if [ ! -f $(which nifti_tool) ]; then
#    echo "AFNI must be installed to convert nii.gz segmentation to Analyze header."
#    echo "I cannot find AFNI's nifti_tool executable, so cannot continue."
#    exit 1
#fi

mri_convert \
	--in_type mgz \
	--out_type nifti1 --out_orientation LPI -odt uchar \
	"${INPUTDIR}/mri/aseg.mgz" \
	"${OUTPUTDIR}/${SID}.aseg.${FSV}.img"

if [ -f "${INPUTDIR}/mri/lh.hippoSfLabels-T1.v10.FSvoxelSpace.mgz" ]; then
    mri_convert \
    	--in_type mgz \
    	--out_type nifti1 --out_orientation LPI -odt uchar \
    	"${INPUTDIR}/mri/lh.hippoSfLabels-T1.v10.FSvoxelSpace.mgz" \
    	"${OUTPUTDIR}/${SID}.lhsubs.${FSV}.img"
fi

if [ -f "${INPUTDIR}/mri/rh.hippoSfLabels-T1.v10.FSvoxelSpace.mgz" ]; then
    mri_convert \
    	--in_type mgz \
    	--out_type nifti1 --out_orientation LPI -odt uchar \
    	"${INPUTDIR}/mri/rh.hippoSfLabels-T1.v10.FSvoxelSpace.mgz" \
    	"${OUTPUTDIR}/${SID}.rhsubs.${FSV}.img"
fi

# no longer necessary, covered by mri_convert in one step
#nifti_tool -copy_im \
#	-prefix "${OUTPUTDIR}/${SID}.aseg.${FSV}.hdr" \
#	-infiles "${OUTPUTDIR}/${SID}.aseg.${FSV}.nii.gz"

#rm -rf "${OUTPUTDIR}/${SID}.aseg.${FSV}.nii.gz"
