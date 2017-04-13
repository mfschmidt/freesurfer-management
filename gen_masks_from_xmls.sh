#!/bin/bash

# gen_masks_from_xmls.sh trace_directory initials output_directory
#
# X000000.TrueLeft.YYY.xml + X000000.TrueRight.YYY.xml => X000000.mipav.both.ubyte.nii
# X000000/mri/aseg.mgz => tmp.aseg.nii.gz => X000000.aseg.{hdr,img}

ORIGINALS="/mri/gmbi.rochester.original /mri/gmbi.jackson.original"
MIPAV=/usr/local/mipav730/mipav
MIPAVSCRIPT=/home/mike/bin/mrcode/open_image_and_save_hf_mask.sct

# Ensure we have the software we need before beginning
if [ ! -f "$MIPAV" ]; then
    if [ -f $(which mipav) ]; then
        MIPAV="$(which mipav)"
    else
        echo "MIPAV must be installed to convert VOI points to mask."
        echo "I cannot find it, so cannot continue."
        exit 1
    fi
fi
if [ ! -f "$MIPAVSCRIPT" ]; then
    echo "MIPAV is installed, but the script ($MIPAVSCRIPT) to convert VOIs to masks cannot be found."
    echo "Exiting."
    exit 1
fi

# Check on input and output directories
INPUTDIR="$1"
if [ ! -e "$INPUTDIR" ]; then
	echo "\"$INPUTDIR\" does not exist."
	exit 1
fi

if [ "$3" == "" ]; then
	OUTPUTDIR="$INPUTDIR"
else
	OUTPUTDIR="$3"
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
for f in *.True*.$2.xml; do
	if [[ "$f" =~ ^(.*).TrueRight\.(.*).xml$ ]]; then
		# A properly named xml file indicates there is a tracing here.
		# Check for other components of a full tracing.
		SID=${BASH_REMATCH[1]}
		TID=${BASH_REMATCH[3]}
		TID0=${TID}
		case "${TID: -1}" in
			*[-_]* ) TID0="${TID}0";;
			*[a-zA-Z]* ) TID0="${TID}0";;
		esac
		ORIG=$(find $ORIGINALS -type f -name "${SID}*spgr.hdr" | head -1)
		if [ -f "${SID}.COR.${TID}.hdr" ] && [ -f "${SID}.COR.${TID}.img" ] &&
		   [ -f "${SID}.TrueLeft.${TID}.xml" ] && [ -f "${SID}.TrueRight.${TID}.xml" ] &&
		   [ -f "${ORIG}" ] && [ -f "${ORIG/hdr/img}" ]; then
			echo "${SID} has a complete trace by ${TID0} at $INPUTDIR."
			
			# We have all four files needed, build masks from the xmls
			if [ -f "${OUPUTDIR}/${SID}.${TID0}.mipavmask.nii" ]; then
				echo "${SID}.${TID0}.mipavmask.nii already exists at ${OUTPUTDIR}."
			else
				# ---------- The real work begins here. ----------
				# 1. Use MIPAV to convert original xml VOI points directly to nii mask
				$MIPAV \
					-inputdir "${INPUTDIR}" -i "${INPUTDIR}/${SID}.COR.${TID}.img" \
					-v "${INPUTDIR}/${SID}.TrueLeft.${TID}.xml" \
					-v "${INPUTDIR}/${SID}.TrueRight.${TID}.xml" \
					-outputdir "${OUTPUTDIR}" -o "${SID}.${TID0}.mipavmask.nii" \
					-s "$MIPAVSCRIPT" -hide

				# 2. Convert original and coronal headers to floating point and calculate the rotation difference
				3dcalc -datum float -prefix "${OUTPUTDIR}/tmp.${SID}.ORIG.hdr" -a "$ORIG" -expr a
				AFNI_ANALYZE_ORIENT=LIA 3dcalc -datum float -prefix "${OUTPUTDIR}/tmp.${SID}.COR.hdr" -a "${SID}.COR.${TID}.hdr" -expr a
				AFNI_ANALYZE_ORIENT=LIA 3daxialize -prefix "${OUTPUTDIR}/tmp2.${SID}.COR.hdr" -orient LPI "${OUTPUTDIR}/tmp.${SID}.COR.hdr"
			    3dAllineate -source "${OUTPUTDIR}/tmp.${SID}.ORIG.hdr" \
						    -base "${OUTPUTDIR}/tmp.${SID}.COR.hdr" \
						    -interp linear -nmatch 100% -conv 0.005 \
						    -cost ls -twopass -automask -warp shr \
						    -1Dmatrix_save "${OUTPUTDIR}/${SID}.inv.aff12.1D"

				# ---------- The real work ends here. ----------
			fi
		else
			echo "     - partial for ${SID} by ${TID0} at $1 -"
		fi
	else
		echo "Improperly named header, \"$f\", looking for something like \"SubjectID.COR.TracerID.hdr\""
	fi
	
	
done
