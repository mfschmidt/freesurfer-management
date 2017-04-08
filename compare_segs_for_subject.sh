#!/bin/bash

# compare_segs_for_subject.sh
#
# This script will generate masks for the subject specified and compare
# those masks to all other tracings or segmentations of this subject.

# First, figure out whether we're asked to deal with a particular tracing
# or a folder full of them.
INTYPE=""
if [ -f "$1" ]; then
	INTYPE="FILE"
	BASE="${1##*/}"
	SID="${BASE%%.*}"
	if [ *"TrueLeft"* == "$BASE" ]; then
		TL="${1}"
		TR="${1/Left/Right/}"
		TI="${1/TrueLeft/COR/}"
		TI="${TC/xml/img/}"
		TH="${TI/img/hdr/}"
elif [ -d "$1" ]; then
	INTYPE="DIR"
	SID="${1##*/}"
else
	echo "$1 is neither a file nor a directory. Nothing I can do."
	exit 1
fi

OUTDIR=/mri/gmbi.rochester.comparisons/$SID

echo "In     : $1"
echo "SID    : $SID"
echo "Out to : $OUTDIR"
exit 0

if [ ! -d $OUTDIR ]; then
	echo "making new directory, $OUTDIR"
	mkdir $OUTDIR
	if [ ! -d $OUTDIR ]; then
		echo "$OUTDIR does not exist and I can't seem to create it. I can't go on."
		exit 1
	fi
fi
echo "Putting all comparison files in $OUTDIR"

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

# We want to compare all freesurfer segmentations and tracings with each other.
# 1. What freesurfer segmentations do we have?
F_CANDIDATES=$(2>/dev/null find $F_LOCI -type d -name $1)
for C in $F_CANDIDATES; do
	if [ "$(dir_contents.sh $C)" == "freesurfer" ]; then
		echo "Got FreeSurfer segmentation at $C"
		gen_masks_from_freesurfer.sh $C $OUTDIR
	fi
done

# 2. What manual tracings do we have?
T_CANDIDATES=$(2>/dev/null find $T_LOCI -type d -name $1)
for C in $T_CANDIDATES; do
	if [ "$(dir_contents.sh $C)" == "mipav" ]; then
		echo "Got manual tracings at $C"
		gen_masks_from_xmls.sh $C $OUTDIR
	fi
done

# 3. And do we have the original images?
O_CANDIDATES=$(2>/dev/null find $O_LOCI -type d -name $1)
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
