#!/bin/bash

## ----- aggregate_images.sh -----
#
# This script will seek out everything related to a particular subject
# specified on the command line and put it all in its suggested location.
#
## ----- -----

# Import some functions we'll use later
source bash_mind_functions.sh

# Defaults
src_base=/media/mike/R06_MIKE
tgt_base=/home/mike/Brains
tmp_base=/home/mike/temp

# 01 Testing prereqs, make sure our environment is set up appropriately.
ok=1
if [ ! -d $src_base ]; then
	echo "$src_base does not exist. There's no place for me to search for files."
	ok=0
fi
if [ ! -d $tgt_base ]; then
	echo "$tgt_base does not exist. There's no place for me to put files."
	ok=0
fi
if [ ! -d $tmp_base ]; then
	mkdir $tmp_base
	if [ $? -ne 0 ]; then
		echo "$tmp_base does not exist and I cannot create it. There's no place for me to buffer intermediate files."
		ok=0
	else
		echo "$tmp_base did not exist, so I created it."
	fi
fi

if [ $ok == 0 ]; then
	echo "Bailing out before even looking for files."
	exit
else
	# Prepare an empty file to dump commands into
	rm --force $tmp_base/moveall.sh
	echo "#!/bin/bash" > $tmp_base/moveall.sh
fi

# 02 Gathering source locations for file mining
ok=1
src_dirs=$(find $src_base -type d -name $1*)
echo "--------------------------------------------------------------------------------"
echo "${1}:"
for line in $src_dirs; do
	echo "  : $line"
	
	has_mipav_data $line
	retval1=$?
	#echo "  + has_mipav_data returned $retval1"
	if [ $retval1 -gt 0 ]; then
		echo "  : : MIPAV data, check for dupes and copy xml files and coronal orientation."
	fi
	
	has_freesurfer_data $line
	retval2=$?
	#echo "  + has_freesurfer_data returned $retval2"
	if [ $retval2 -gt 0 ]; then
		echo "  : : FreeSurfer data, check for dupes and copy whole mess over."
	fi
	
	has_analyze_data $line
	retval3=$?
	#echo "  + has_analyze_data returned $retval3"
	if [ $retval3 -gt 0 ]; then
		echo "  : : Analyze data, check for dupes and copy original images."
	fi
	
done

# 03 

echo "Done!"
