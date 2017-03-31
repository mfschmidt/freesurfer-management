## Supporting bash functions

##------------------------------------------------------------------------------
## Determine whether the path given contains mipav tracing data
function has_mipav_data(  ) {
	hits=0
	for f in ${1}/*.*{[Ll]eft,[Rr]ight}*.xml; do
		if [ -f "$f" ]; then
			#echo "      : : found left : $f"
			let hits++
		fi
	done
	for f in ${1}/*.*COR*.{hdr,img}; do
		if [ -f "$f" ]; then
			#echo "      : : found right : $f"
			let hits++
		fi
	done
	
	# If all is good and we find the two expected files, return 0
	if [[ $hits -ge 2 ]]; then
      return 1
   fi
   return 0
}

##------------------------------------------------------------------------------
## Determine whether the path given contains freesurfer segmentation data
function has_freesurfer_data(  ) {
	hits=0
	# 10 of these are found in FreeSurfer data prior to v6 (all but logs)
	# 9 of them (different subset) are found in FreeSurfer v6 (all but bem and src)
	exp_dirs="bem label logs mri scripts src stats surf tmp touch trash"
	for s in $exp_dirs; do
		if [ -d $1/$s ]; then
			let hits++
		fi
	done
	
	#if [[ ($hits > 0) && ($hits < 10) ]] ; then
	#	echo "     $1 has $hits folders in a freesurfer output directory."
	#fi

	if [[ $hits -ge 8 ]]; then
      return 1
   fi
   return 0

}

##------------------------------------------------------------------------------
## Determine whether the path given contains Analyze style image and header data
function has_analyze_data(  ) {
	hits=0
	exp_exts="hdr img"
	for s in $exp_exts; do
		imgs=$(2>/dev/null ls -1f ${1}/${1##*/}*.${exp_exts} | wc -l)
		let hits+=$imgs
	done
	
	if [[ $hits -ge 2 ]]; then
      return 1
   fi
   return 0

}

##------------------------------------------------------------------------------
## Determine whether the path given contains DICOM images
function has_dicom_data(  ) {
	hits=0
	
	if [ ! -x "$(which dicom_hinfo)" ]; then
		echo "AFNI must be installed, and /etc/afni/afni.sh must be sourced to check dicoms. No DICOMs found, but only because I can't look."
		return 0
	fi

	R=$(find ${1} -type f | xargs dicom_hinfo -tag 0008,103e 0028,0010 -no_name)
	if [ ! "$R" == "" ]; then
		return 1
	fi
   return 0

}


