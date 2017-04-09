#!/bin/bash

# compare_segs_for_subject.sh
#
# This script will outsource mask generation for the subject specified and compare
# those masks to all other tracings or segmentations of this subject.
VERBOSE=1

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

if [ $VERBOSE ]; then
	echo "In      : $1"
	echo "SID     : $SID"
	echo "INDIR   : $INDIR"
	echo "Initials: $INITIALS"
	echo "Out to  : $OUTDIR"
	#exit 0
fi


F_LOCI="/mri/gmbi.rochester.fs600/ \
        /mri/gmbi.rochester.fs530/ \
        /mri/gmbi.rochester.fs520/ \
        /mri/gmbi.jackson.fs600/ \
        /mri/gmbi.jackson.fs530/ \
        /mri/gmbi.jackson.fs520/"
T_LOCI="/mri/gmbi.rochester.trace/ \
        /mri/gmbi.jackson.trace/"
O_LOCI="/mri/gmbi.rochester.original/ \
        /mri/gmbi.jackson.original/"

# We want to compare the specified freesurfer tracing(s) with all others.
# 1. What complete manual tracings do we have?
T_CANDIDATES=$(2>/dev/null find $T_LOCI -type d -name $SID)
for C in $T_CANDIDATES; do
	if [ "$(dir_contents.sh $C)" == "mipav" ]; then
		echo "Got manual tracings at $C"
		#gen_masks_from_xmls.sh $C $OUTDIR
	fi
done

# 2. What freesurfer segmentations do we have?
F_CANDIDATES=$(2>/dev/null find $F_LOCI -type d -name $SID)
for C in $F_CANDIDATES; do
	if [ "$(dir_contents.sh $C)" == "freesurfer" ]; then
		echo "Got FreeSurfer segmentation at $C"
		#gen_masks_from_freesurfer.sh $C $OUTDIR
	fi
done

# 3. And do we have the original images?
O_CANDIDATES=$(2>/dev/null find $O_LOCI -type d -name $SID)
for C in $O_CANDIDATES; do
	if [ "$(dir_contents.sh $C)" == "analyze" ]; then
		echo "Got original images at $C"
	fi
done

exit 0

ORIG_IMG=""
ORIG_HDR=""
COR_IMG=""
COR_HDR=""
TRACE_L=""
TRACE_R=""
ASEG=""

# First, find all data for this subject.
CANDIDATES=$(2>/dev/null find $LOCI -type d -name $1)

for CANDIDATE in $CANDIDATES; do
	CONTENTS=$(dir_contents.sh $CANDIDATE)
	for CONTENT in "$CONTENTS"; do
		case "$CONTENT" in
			"freesurfer" )
				if [ -f "$CONTENT/mri/aseg.mgz" ]; then
					ASEG="$CONTENT/mri/aseg.mgz"
					gen_masks_from_freesurfer.sh "$CONTENT" "$OUTDIR";;
				fi
			"mipav" )
				if [ -f "" ]; then
					gen_masks_from_xmls.sh "$CONTENT" "$OUTDIR";;
				fi
			"analyze" )
				;;
		esac
	done
done


#gen_masks_from_freesurfer.sh /mri/gmbi.rochester.fs600/$sid /mri/gmbi.rochester.comparisons/$sid
