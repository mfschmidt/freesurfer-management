## Supporting bash functions

##------------------------------------------------------------------------------
## Determine whether the path given contains mipav tracing data
has_mipav_data(  ) {
	hits=0
	if [ -f ${1}/*.*[Ll]eft*.xml ]; then
		#echo "      : : found left"
		let hits++
	fi
	if [ -f ${1}/*.*[Rr]ight*.xml ]; then
		#echo "      : : found right"
		let hits++
	fi
	
	# If all is good and we find the two expected files, return 0
	return $hits
}

##------------------------------------------------------------------------------
## Determine whether the path given contains freesurfer segmentation data
has_freesurfer_data(  ) {
	hits=0
	exp_dirs="bem label mri scripts src stats surf tmp touch trash"
	for s in $exp_dirs; do
		if [ -d $1/$s ]; then
			let hits++
		fi
	done
	
	if [[ ($hits > 0) && ($hits < 10) ]] ; then
		echo "     $1 has $hits of 10 folders expected in a freesurfer output directory."
	fi

	return $hits
}

##------------------------------------------------------------------------------
## Determine whether the path given contains freesurfer segmentation data
has_analyze_data(  ) {
	hits=0
	exp_exts="hdr img"
	for s in $exp_exts; do
		imgs=$(2>/dev/null ls -1f ${1}/${1##*/}*.${exp_exts} | wc -l)
		let hits+=$imgs
	done
	
	return $hits
}

