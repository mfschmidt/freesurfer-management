#!/usr/bin/octave

# version 3: only writes out a single one-line file rather than the crosstab
# table from version 1. This allows easy concatenation into a full set of
# all comparisons csv file.

## Inputs
arg_list = argv () ;
file_L = arg_list{1} ;  ## left hippo, could be something like R000000.lhsubs.600.img
file_R = arg_list{2} ;  ## right hippo, could be something like R000000.rhsubs.600.img
file_O = arg_list{3} ;  ## the output, usually something like R000000.aseg.subfields.img

fprintf("Octave is merging and converting %s and %s into %s.\n", file_L, file_R, file_O) ;

Nx = 256 ;
Ny = 256 ;
Nz = 256 ;

## FreeSurfer hippocampus subfields are labeled different values than asegs.
## We will save one image with the tail and one without.
fs_l = 17 ;
fs_r = 53 ;
hsf_min = 230 ;
hsf_max = 255 ;
hsf_tail = 255 ;


## Read in first file's data block (uint8)
##------------------------------------------------------------------------------
f = fopen(file_L, "r") ;
L_data = fread(f, Nx*Ny*Nz, "uint8") ;
L_data = reshape(L_data,Nx,Ny,Nz) ;
f = fclose(f) ;

## Read in second file's data block (uint8)
##------------------------------------------------------------------------------
f = fopen(file_R, "r") ;
R_data = fread(f, Nx*Ny*Nz, "uint8") ;
R_data = reshape(R_data,Nx,Ny,Nz) ;
f = fclose(f) ;


## Consolidate and merge whole hippocampi from subfields
##------------------------------------------------------------------------------
L_wtail = L_data>=hsf_min & L_data<=hsf_max ;
R_wtail = R_data>=hsf_min & R_data<=hsf_max ;
yes_tail = cast((L_wtail * fs_l) + (R_wtail * fs_r), "uint8") ;
mask_filename = strrep(file_O, "subf", "subfytail") ;
f = fopen(mask_filename, "w") ;
fwrite(f, yes_tail) ;
fclose(f) ;
copyfile(strrep(file_L, "img", "hdr"), strrep(mask_filename, "img", "hdr")) ;

L_wotail = L_data>=hsf_min & L_data<hsf_max ;
R_wotail = R_data>=hsf_min & R_data<hsf_max ;
no_tail = cast((L_wotail * fs_l) + (R_wotail * fs_r), "uint8") ;
mask_filename = strrep(file_O, "subf", "subfntail") ;
f = fopen(mask_filename, "w") ;
fwrite(f, no_tail) ;
fclose(f) ;
copyfile(strrep(file_R, "img", "hdr"), strrep(mask_filename, "img", "hdr")) ;



clear all
close all
