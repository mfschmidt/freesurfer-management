#!/bin/bash

if [ ! -e "$1" ]; then
	echo "\"$1\" not found"
	exit 0
fi

source $(which bash_mind_functions.sh)

RESPONSE=""
has_mipav_data "${1}"
if [ "$?" == "1" ]; then
	RESPONSE="$RESPONSE mipav"
fi
has_freesurfer_data "${1}"
if [ "$?" == "1" ]; then
	RESPONSE="$RESPONSE freesurfer"
fi
has_analyze_data "${1}"
if [ "$?" == "1" ]; then
	RESPONSE="$RESPONSE analyze"
fi
has_dicom_data "${1}"
if [ "$?" == "1" ]; then
	RESPONSE="$RESPONSE dicom"
fi

echo -e "${RESPONSE}" | sed -e 's/[[:space:]]*//'

