#!/bin/bash

freeview \
	-v \
  $1/mri/T1.mgz \
  $1/mri/wm.mgz \
  $1/mri/brainmask.mgz \
  $1/mri/aparc+aseg.mgz:colormap=lut:opacity=0.2 \
  -f \
  $1/surf/lh.white:edgecolor=blue \
  $1/surf/lh.pial:edgecolor=red \
  $1/surf/rh.white:edgecolor=blue \
  $1/surf/rh.pial:edgecolor=red
