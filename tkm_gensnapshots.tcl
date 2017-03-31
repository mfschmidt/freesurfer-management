# Set up a particular subject's freesurfer data to screenshot the
# aseg data for rapid review later.

# This script is required and utilized by gen_aseg_montage.sh

# Be sure we are in a coronal orientation (should already be)
SetOrientation 0

# Put the cursor dead-center in the 3D volume
SetCursor 0 128 128 128

foreach orientation { 0 1 2 } label { coronal horizontal sagittal } {
	SetOrientation $orientation
	
	foreach slice { 100 120 140 160 } {
		SetSlice $slice
		RedrawScreen
		SaveTIFF $orientation-$slice.tif
	}
}

# And exit. We don't need windows building up and keeping memory
exit
