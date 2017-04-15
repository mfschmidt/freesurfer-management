#!/bin/bash

# compare_segs_for_subject.sh [-fv] {indir/infile} outdir
#
# This script will outsource mask generation for the subject specified and compare
# those masks to all other tracings or segmentations of this subject.

# Parse command-line options
VERBOSE=0
FORCE=0
while getopts ":f:v:" opt; do
	case $opt in
		f)
			# Force new masks, overwriting existing masks
			FORCE=1
			;;
		v)
			# echo anything relevant
			VERBOSE=1
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			echo "quitting to make sure you've asked for what you want first."
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

# First, figure out whether we're asked to deal with a particular tracing
# or a folder full of them.
INTYPE=""
INDIR=""
INITIALS=""
if [ -f "$1" ]; then
	INTYPE="FILE"
	INDIR="${1%/*}"
	BASE="${1##*/}"
	#SID="${BASE%%.*}"
	IFS=. read SID stuff1 INITIALS stuff2 <<<"${BASE}"
elif [ -d "$1" ]; then
	INTYPE="DIR"
	INDIR="${1%/}"
	SID="${INDIR##*/}"
else
	echo "$1 is neither a file nor a directory. I assume it is the subject ID."
	SID="$1"
fi

# Second, determine where to put our masks and results
OUTDIR=/mri/gmbi.rochester.comparisons/$SID
if [ "$2" != "" ]; then
	if [ -d "$2" ]; then
		OUTDIR="$2"
	else
		2>/dev/null mkdir "$2"
		if [ -d "$2" ]; then
			OUTDIR="$2"
		else
			echo "$2 does not exist and I cannot create it. Using default."
		fi
	fi
fi
if [ ! -d $OUTDIR ]; then
	echo "making new directory, $OUTDIR"
	mkdir $OUTDIR
	if [ ! -d $OUTDIR ]; then
		echo "$OUTDIR does not exist and I can't seem to create it. I can't go on."
		exit 1
	fi
fi

# Report our interpretation of inputs for debugging, if necessary
if [ $VERBOSE ]; then
	echo "In      : $1"
	echo "SID     : $SID"
	echo "INDIR   : $INDIR"
	echo "Initials: $INITIALS"
	echo "Out to  : $OUTDIR"
	#exit 0
fi

# Set up default locations to find MRI data for comparisons
F_LOCI="/mri/gmbi.rochester.fs600/ \
        /mri/gmbi.rochester.fs530/ \
        /mri/gmbi.rochester.fs520/ \
        /mri/gmbi.jackson.fs600/ \
        /mri/gmbi.jackson.fs530/ \
        /mri/gmbi.jackson.fs520/"
T_LOCI="/mri/gmbi.rochester.trace/ \
        /mri/gmbi.jackson.trace/"

cd "$OUTDIR"

# 3. What freesurfer segmentations do we have?
# FreeSurfer must come before manual tracing because the manual tracing
# is saved as a mask in FreeSurfer coordinates, derived from this snippet's
# output.
if [ $VERBOSE ]; then echo ">>>=== $SID --- FreeSurfer segmentations"; fi
F_CANDIDATES=$(2>/dev/null find $F_LOCI -type d -name $SID)
for C in $F_CANDIDATES; do
	if [ "$(dir_contents.sh $C)" == "freesurfer" ]; then
		echo "Got FreeSurfer segmentation at $C"
		gen_masks_from_freesurfer.sh $C $OUTDIR
	fi
done

# 4. What complete manual tracings do we have?
# Generate masks for the specified files.
if [ $VERBOSE ]; then echo ">>>=== $SID --- manual tracings"; fi
if [ "$INDIR" != "" ] && [ "$INITIALS" != "" ]; then
	if [ $VERBOSE ]; then echo "A specific $INITIALS tracing from $INDIR was specified; making masks for it."; fi
	if [ $FORCE ]; then rm -f "$OUTDIR/$SID.mipavmask.$INITIALS*.nii"; fi
	gen_masks_from_xmls.sh "$INDIR" "$INITIALS" "$OUTDIR"
else
	T_CANDIDATES=$(2>/dev/null find $T_LOCI -type d -name $SID)
	for C in $T_CANDIDATES; do
		if [ $VERBOSE ]; then echo ">>>===    $SID --- candidate $C"; fi
		if [ "$(dir_contents.sh $C)" == "mipav" ]; then
			echo "Got manual tracings at $C"
			if [ $FORCE ]; then rm -f "$OUTDIR/$SID.mipavmask.*.nii"; fi
			if [ $VERBOSE ]; then echo "Making mask(s) from $C"; fi
			gen_masks_from_xmls.sh $C '*' $OUTDIR
		fi
	done
fi

# 5. Compare all masks to each other
if [ $VERBOSE ]; then echo ">>>=== $SID --- comparisons"; fi
for T1 in $(ls -1 ${OUTDIR}/${SID}.mask*.img); do
	if [ $VERBOSE ]; then echo ">>>===    $SID --- candidate $T1"; fi
	if [[ "$T1" =~ ^(.*)\.mask.(.*)_(.*).img$ ]]; then
		tr1=${BASH_REMATCH[2]}
		v1=${BASH_REMATCH[3]}
		for T2 in $(ls -1 ${OUTDIR}/${SID}.mask.*_${v1}.img); do
			if [ $VERBOSE ]; then echo ">>>===    $SID --- candidate $T1 vs $T2"; fi
			if [ "$T1" != "$T2" ]; then
				if [[ "$T2" =~ ^(.*)\.mask.(.*)_(.*).img$ ]]; then
					tr2=${BASH_REMATCH[2]}
					summarize_overlap.m "$T1" "$T2" "${SID}.comp.${tr1}-${v1}.${tr2}-${v1}"
				else
					echo "No regex match for $T2"
				fi
			fi
		done
	else
		echo "No regex match for $T1"
	fi
	for F2 in $(ls -1 ${OUTDIR}/${SID}.aseg.${v1}.img); do
		if [ $VERBOSE ]; then echo ">>>===    $SID --- candidate $T1 vs $F2"; fi
		if [[ "$F2" =~ ^(.*)\.aseg.(.*).img$ ]]; then
			v2=${BASH_REMATCH[2]}
			summarize_overlap.m "$T1" "$F2" "${SID}.comp.${tr1}.${v2}"
		else
			echo "No regex match for $F2"
		fi
	done
done

# 6. Consolidate the csv files into one
cat ${OUTDIR}/${SID}.comp.*.histo.csv >> "${OUTDIR}/${SID}.comparisons.csv"
rm ${OUTDIR}/${SID}.comp.*.histo.csv

cd -
echo "Done"
