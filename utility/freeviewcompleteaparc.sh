#!/bin/bash

freeview \
	-f \
  $1/surf/lh.pial:annot=aparc.annot:name=pial_aparc:visible=0 \
  $1/surf/lh.inflated:overlay=lh.thickness:overlay_threshold=0.1,3::name=inflated_thickness:visible=0 \
  $1/surf/lh.inflated:visible=0 \
  $1/surf/lh.white:visible=0 \
  $1/surf/lh.pial