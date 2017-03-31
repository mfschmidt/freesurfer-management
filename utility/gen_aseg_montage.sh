#!/bin/bash

## gen_aseg_montage.sh

if [ $# -lt "1" ]; then
  echo ""
  echo "USAGE: ${0} <Subject ID> [output_directory]"
  echo ""
  echo "Note: SUBJECTS_DIR must be set to directory of Freesurfer data"
  echo "      It is currently '${SUBJECTS_DIR}'"
  echo ""
  echo " If output-directory is specified, the final image will be saved there."
  echo " otherwise, it will be saved into a '_snapshots' subdirectory under"
  echo " the subjects original freesurfer output directory."
  exit;
fi

# Make sure we have a subject
if [ ! -d ${SUBJECTS_DIR}/${1} ]; then
	echo "I expect freesurfer data at ${SUBJECTS_DIR}/${1}"
	echo "I'm quitting because I can't find it."
	echo "Try setting the \$SUBJECTS_DIR environment variable."
	exit 1
fi

# Make sure our output directory exists
OUTDIR=""
if [ $# -eq 2 ]; then
	if [ -d ${2} ]; then
		OUTDIR=${2}
	else
		echo "The output directory, ${2}, does not exist."
		echo "Please create it or try a different output directory."
		exit 1
	fi
else
	OUTDIR=${SUBJECTS_DIR}/${1}/_snapshots
  if [ ! -d ${OUTDIR} ]; then
    mkdir ${OUTDIR}
  fi
fi

# And there's no point overwriting good images
if [ -f ${OUTDIR}/${1}_3x4.png ]; then
	echo "     ${1}_3x4.png exists, skip it.";
	exit 0
fi

# make sure our script is ready
SCT=tkm_gensnapshots.tcl
TCL=~/bin/${SCT}
if [ ! -f ${TCL} ]; then
	TCL=$(find . ~ -name ${SCT} -nowarn 2>/dev/null)
	if [ ${#TCL} -eq 0 ]; then
		echo "Cannot find ${SCT} file, quitting in desperation."
		exit 1
	fi
fi

# make sure imagemagick is installed
MAG=$(which convert)
if [ ${#MAG} -eq 0 ]; then
	echo "This script requires imagemagick to run. Install it first."
	exit 1
fi

# make sure tkmedit is in the path or otherwise available
TKE=$(which tkmedit)
if [ ${#TKE} -eq 0 ]; then
	if [ ${#FREESURFER_HOME} -eq 0 ]; then
		echo "This script requires tkmedit, usually found in the freesurfer directory."
		echo "Please add it to your path or set \$FREESURFER_HOME."
		exit 1
	else
		if [ -f ${FREESURFER_HOME}/bin/tkmedit ]; then
			TKE=${FREESURFER_HOME}/bin/tkmedit
		else
			echo "This script requires tkmedit, usually found in the freesurfer directory."
			echo "Please add it to your path or update \$FREESURFER_HOME."
		fi
	fi
fi

# debugging output for double-checking our dependencies
#echo "     Found subject ${1} at ${SUBJECTS_DIR}/${1},"
#echo "           script at ${TCL},"
#echo "           imagemagick at ${MAG}."
#echo "     Ready to go."

#Set up a working directory (must match in TCL script)
if [ ! -d ~/tmp_tkm_tifs ]; then
	mkdir ~/tmp_tkm_tifs;
fi
OLDPWD=$(pwd)
cd ~/tmp_tkm_tifs

# generate the slices and individual images
#echo "    CMD: ${TKE} ${1} brainmask.mgz -aseg -tcl $TCL"
${TKE} ${1} brainmask.mgz -aseg -tcl $TCL
if [ $? -gt 0 ]; then
  echo "Bailing out on ${1} from error with tkmedit"
  exit 1
fi

# crop them all to avoid wasted margins
for f in $(ls -1f [012]-*.tif); do
	# Originals are 512 x 512 : center-cropping: 96 + 320 + 96 = 512
	convert $f -crop 320x320+96+96 ${f:0: -4}.png
done

# stitch them all together into a single image
IMGS=""
for ori in 0 1 2; do
	for slice in 100 120 140 160; do
		IMGS="${IMGS} ${ori}-${slice}.png"
	done
done
#echo "montaging ${IMGS}"
montage ${IMGS} -tile 4x3 -geometry 320x320+1+1 ${OUTDIR}/${1}_3x4.png

# clean up our mess
cd ${OLDPWD}
rm -rf ~/tmp_tkm_tifs


