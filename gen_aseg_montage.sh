#!/bin/bash

## gen_aseg_montage.sh

if [ $# -lt "1" ]; then
 echo ""
 echo "USAGE: ${0} <Subject ID>"
 echo ""
 echo "Note: SUBJECTS_DIR must be set to directory of Freesurfer data"
 exit;
fi

# Make sure we have a subject
if [ ! -d $SUBJECTS_DIR/${1} ]; then
	echo "I expect freesurfer data at ${SUBJECTS_DIR}/${1}"
	echo "I'm quitting because I can't find it."
	echo "Try setting the \$SUBJECTS_DIR environment variable."
	exit 1
fi

# make sure our script is ready
SCT=tkm_gensnapshots.tcl
TCL=~/bin/${SCT}
if [ ! -f ${TCL} ]; then
	TCL=$(find . ~ -name ${SCT} -nowarn 2>/dev/null)
	if [ ${#TCL} -eq 0 ]; then
		echo "Can't find ${SCT} file, quitting in desperation."
		exit 1
	fi
fi

# make sure imagemagick is installed
MAG=$(which convert)
if [ ${#MAG} -eq 0 ]; then
	echo "This script requires imagemagick to run. Install it first."
	exit 1
fi

# debugging output for double-checking our dependencies
#echo "Found subject ${1} at ${SUBJECTS_DIR}/${1},"
#echo "      script at ${TCL},"
#echo "      imagemagick at ${MAG}."
#echo "Ready to go."

#Set up a working directory (must match in TCL script)
mkdir tmp_tkm_tifs
OLDPWD=$(pwd)
cd tmp_tkm_tifs

# generate the slices and individual images
tkmedit ${1} brainmask.mgz -aseg -tcl $TCL

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
montage ${IMGS} -tile 4x3 -geometry 320x320+1+1 ../${1}/${1}.png

# clean up our mess
cd ${OLDPWD}
rm -rf tmp_tkm_tifs


