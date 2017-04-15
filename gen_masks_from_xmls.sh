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
echo "Searching for tracings by $2"
for f in *.TrueRight.$2.xml; do
	if [[ "$f" =~ ^(.*)\.TrueRight\.(.*)\.xml$ ]]; then
		# A properly named xml file indicates there is a tracing here.
		# Check for other components of a full tracing.
		COMPLETE="True"
		SID=${BASH_REMATCH[1]}
		TID=${BASH_REMATCH[2]}
		TID0=${TID}
		echo "Tracing of $SID found from $TID (via $f)"
		case "${TID: -1}" in
			*[-_]* ) TID0="${TID}0";;
			*[a-zA-Z]* ) TID0="${TID}0";;
		esac
		ORIG=$(find $ORIGINALS -type f -name "${SID}*spgr.hdr" | head -1)
		
		# Ensure all the files we need are available and where we expect them.
		if [ -f "${SID}.COR.${TID}.hdr" ] && [ -f "${SID}.COR.${TID}.img" ]; then
		    echo "+ Found rotations: ${SID}.COR.${TID}.hdr and ${SID}.COR.${TID}.img"
		else
		    echo "- Cannot find rotations: ${SID}.COR.${TID}.hdr and ${SID}.COR.${TID}.img"
		    COMPLETE="False"
		fi
		if [ -f "${SID}.TrueLeft.${TID}.xml" ] && [ -f "${SID}.TrueRight.${TID}.xml" ]; then
		    echo "+ Found tracings: ${SID}.TrueLeft.${TID}.xml and ${SID}.TrueRight.${TID}.xml"
		else
		    echo "- Cannot find tracings: ${SID}.TrueLeft.${TID}.xml and ${SID}.TrueRight.${TID}.xml"
		    COMPLETE="False"
		fi
		if [ -f "${ORIG}" ] && [ -f "${ORIG/hdr/img}" ]; then
		    echo "+ Found originals: ${ORIG} and ${ORIG/hdr/img}"
		else
		    echo "- Cannot find originals: ${ORIG} and ${ORIG/hdr/img}"
		    COMPLETE="False"
		fi
		
		# If all 6 files are available...
		if [ "$COMPLETE" == "True" ]; then
			echo "${SID} has a complete trace by ${TID} at $INPUTDIR."
			
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
					-outputdir "${OUTPUTDIR}" -o "${SID}.mipavmask.${TID0}.nii" \
					-s "$MIPAVSCRIPT" -hide
				# generated X000000.YY0.mipavmask.nii
				
				# 2. Convert original & hippocampus-aligned headers to floating point,
				#    then calculate the rotation difference
				3dcalc -datum float -prefix "${OUTPUTDIR}/tmp.${SID}.ORIG.hdr" -a "$ORIG" -expr a
				AFNI_ANALYZE_ORIENT=LIA \
				3dcalc -datum float -prefix "${OUTPUTDIR}/tmp.${SID}.COR.${TID0}.hdr" \
				            -a "${SID}.COR.${TID}.hdr" -expr a
				AFNI_ANALYZE_ORIENT=LIA \
				3daxialize -prefix "${OUTPUTDIR}/tmp2.${SID}.COR.${TID0}.hdr" \
				            -orient LPI "${OUTPUTDIR}/tmp.${SID}.COR.${TID0}.hdr"
			    cp "${OUTPUTDIR}/tmp.${SID}.ORIG.hdr" "${OUTPUTDIR}/tmp.${SID}.COR.${TID0}.hdr"
			    mv "${OUTPUTDIR}/tmp2.${SID}.COR.${TID0}.img" "${OUTPUTDIR}/tmp.${SID}.COR.${TID0}.img"
			    rm "${OUTPUTDIR}/tmp2.${SID}.COR.${TID0}.hdr"
			    3dAllineate -source "${OUTPUTDIR}/tmp.${SID}.ORIG.hdr" \
						    -base "${OUTPUTDIR}/tmp.${SID}.COR.${TID0}.hdr" \
						    -interp linear -nmatch 100% -conv 0.005 \
						    -cost ls -twopass -automask -warp shr \
						    -1Dmatrix_save "${OUTPUTDIR}/${SID}.aff12.inv.${TID0}.1D"
				cat_matvec -ONELINE "${OUTPUTDIR}/${SID}.aff12.inv.${TID0}.1D" -I >  "${OUTPUTDIR}/${SID}.aff12.${TID0}.1D"
				rm ${OUTPUTDIR}/tmp.*
				# generated 2 tmp*.{img,hdr} pairs and 2 X000000.*.1D files
				
				# 3. Rotate tracing mask so it matches original spgr image rather than the hippocampus-
				#    aligned image it was traced from.
				3daxialize -prefix "${OUTPUTDIR}/tmp.${SID}.mipavmask.${TID0}.hdr" \
				        -orient RPI "${OUTPUTDIR}/${SID}.mipavmask.${TID0}.nii"
				3dcalc -prefix "${OUTPUTDIR}/tmp.${SID}.orig.hdr" -a "${ORIG}" -datum byte -expr 0
				mv "${OUTPUTDIR}/tmp.${SID}.orig.hdr" "${OUTPUTDIR}/tmp.${SID}.mipavmask.${TID0}.hdr"
				rm "${OUTPUTDIR}/tmp.${SID}.orig.img"
				for f in $(find $OUTPUTDIR -type f -name "${SID}.aseg.*.hdr"); do
					# This is overkill, but we want to match the tracing to every
					# version of FreeSurfer used, so we repeat the process.
					if [[ "$f" =~ ^(.*)\.aseg\.(.*)\.hdr$ ]]; then
						V=${BASH_REMATCH[2]}
						3dAllineate -prefix "${OUTPUTDIR}/${SID}.mask.${TID0}_${V}.hdr" \
								-source "${OUTPUTDIR}/tmp.${SID}.mipavmask.${TID0}.hdr" \
								-master "${f}" \
								-final NN \
								-1Dmatrix_apply "${OUTPUTDIR}/${SID}.aff12.${TID0}.1D"
					else
						echo "$f doesn't match the regex somehow."
					fi
				done
				rm ${OUTPUTDIR}/tmp.${SID}.mipavmask.*.{hdr,img}


				# ---------- The real work ends here. ----------
			fi
		else
			echo "     - partial for ${SID} by ${TID0} at $1 -"
		fi
	else
		echo "Improperly named tracing, \"$f\", looking for something like \"SubjectID.TrueRight.TracerID.xml\""
	fi
	
	
done
