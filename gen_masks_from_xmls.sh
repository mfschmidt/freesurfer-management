#!/bin/bash

# gen_masks_from_xmls.sh trace_directory output_directory
#
# X000000.TrueLeft.YYY.xml + X000000.TrueRight.YYY.xml => X000000.mipav.both.ubyte.nii
# X000000/mri/aseg.mgz => tmp.aseg.nii.gz => X000000.aseg.{hdr,img}


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


# First, find the traces.
cd "$INPUTDIR"
for f in *.COR.*.hdr; do
	if [[ "$f" =~ ^(.*).COR.(.*).hdr$ ]]; then
		# A coronal header file indicates there is a tracing here.
		# Check for other components of a full tracing.
		SID=${BASH_REMATCH[1]}
		TID=${BASH_REMATCH[2]}
		TID0=${TID}
		case "${TID: -1}" in
			*[-_]* ) TID0="${TID}0";;
			*[a-zA-Z]* ) TID0="${TID}0";;
		esac
		if [ -f "${SID}.COR.${TID}.hdr" ] &&
		   [ -f "${SID}.COR.${TID}.img" ] &&
		   [ -f "${SID}.TrueLeft.${TID}.xml" ] &&
		   [ -f "${SID}.TrueRight.${TID}.xml" ]; then
			echo "${SID} has a complete trace by ${TID0} at $INPUTDIR."
			
			# We have all four files needed, build masks from the xmls
			if [ -f "${OUPUTDIR}/${SID}.${TID0}.mipavmask.nii" ]; then
				echo "${SID}.${TID0}.mipavmask.nii already exists at ${OUTPUTDIR}."
			else
				$MIPAV \
					-inputdir "${INPUTDIR}" -i "${INPUTDIR}/${SID}.COR.${TID}.img" \
					-v "${INPUTDIR}/${SID}.TrueLeft.${TID}.xml" \
					-v "${INPUTDIR}/${SID}.TrueRight.${TID}.xml" \
					-outputdir "${OUTPUTDIR}" -o "${SID}.${TID0}.mipavmask.nii" \
					-s "$MIPAVSCRIPT" -hide
			fi
		else
			echo "     - partial for ${SID} by ${TID0} at $1 -"
		fi
	else
		echo "Improperly named header, \"$f\", looking for something like \"SubjectID.COR.TracerID.hdr\""
	fi
	
	
done
