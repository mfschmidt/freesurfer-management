#!/usr/bin/octave

# version 3: only writes out a single one-line file rather than the crosstab
# table from version 1. This allows easy concatenation into a full set of
# all comparisons csv file.

## Inputs
arg_list = argv () ;
file_a = arg_list{1} ;  ## file a, could be something like R000000.aseg.img
file_b = arg_list{2} ;  ## file b, could be something like R000000_20000101_spgr_mipav.img
s_id = arg_list{3} ;    ## the id, usually somethign like R000000, but could be any string without spaces

fprintf("Octave is comparing %s to %s for subject %s.\n", file_a, file_b, s_id) ;

Nx = 256 ;
Ny = 256 ;
Nz = 256 ;

## FreeSurfer files and manually traced masks label the hippocampus with different values.
## Figure out the filetype and remember the value appropriately.
fs_l = 17 ;
fs_r = 53 ;
tr_l = 1 ;
tr_r = 2 ;
if (strfind(file_a, "aseg"))
	fprintf("%s is a FreeSurfer mask.\n", file_a) ;
	a_L_hc = fs_l ;
	a_R_hc = fs_r ;
elseif (strfind(file_a, "mask"))
	fprintf("%s is a manual trace mask.\n", file_a) ;
	a_L_hc = tr_l ;
	a_R_hc = tr_r ;
else
	fprintf("I don't understand what %s is.\n", file_a) ;
	exit ;
endif

if (strfind(file_b, "aseg"))
	fprintf("%s is a FreeSurfer mask.\n", file_b) ;
	b_L_hc = fs_l ;
	b_R_hc = fs_r ;
elseif (strfind(file_b, "mask"))
	fprintf("%s is a manual trace mask.\n", file_b) ;
	b_L_hc = tr_l ;
	b_R_hc = tr_r ;
else
	fprintf("I don't understand what %s is.\n", file_b) ;
	exit ;
endif

## Read in first file's data block (uint8)
##------------------------------------------------------------------------------
f = fopen(file_a, "r") ;
a_data = fread(f, Nx*Ny*Nz, "char") ;
a_data = reshape(a_data,Nx,Ny,Nz) ;
f = fclose(f) ;

## Read in second file's data block (uint8)
##------------------------------------------------------------------------------
f = fopen(file_b,"r") ;
b_data = fread(f, Nx*Ny*Nz, "char") ;
b_data = reshape(b_data,Nx,Ny,Nz) ;
f = fclose(f) ;

## The two masks could each have different hippocampus coding
##------------------------------------------------------------------------------
a_l = a_data==a_L_hc ;
a_r = a_data==a_R_hc ;
b_l = b_data==b_L_hc ;
b_r = b_data==b_R_hc ;

## Multiply each overlapping voxel (marked by a 1) by a bitmask value.
data = 8*b_r + 4*b_l + 2*a_r + a_l ;

mask_filename = sprintf("%s_octave_masks.mat.gz", s_id) ;
save("-z", "-binary", mask_filename, "data") ;

clear data
close all

load(mask_filename) ;

## Originally, we output a 2 row, 3 column table, but no more

#table = zeros(2,4) ;
                                 ## Right:
#table(1,1) = nnz(data == 8+2) ;  ## Both masks label it HC
#table(1,2) = nnz(data ==   2) ;  ## Only a labels it HC
#table(2,1) = nnz(data == 8  ) ;  ## Only b labels it HC
                                 ## Left:
#table(1,3) = nnz(data == 4+1) ;  ## Both masks label it HC
#table(1,4) = nnz(data ==   1) ;  ## Only a labels it HC
#table(2,3) = nnz(data == 4  ) ;  ## Only b labels it HC

#result_filename = sprintf("%s.crosstab.txt", s_id) ;
#f = fopen(result_filename, "w") ;
#fprintf(f, "%d\t%d\t%d\t%d\n", table) ;
#fflush(f) ;
#fclose(f) ;

## A wide-format one-row table is easier to aggregate

histotable = zeros(1,6) ;
histotable(1,1) = nnz(data == 1) ; ## L: a only
histotable(1,2) = nnz(data == 4) ; ## L: b only
histotable(1,3) = nnz(data == 5) ; ## L: both overlap
histotable(1,4) = nnz(data == 2) ; ## R: a only
histotable(1,5) = nnz(data == 8) ; ## R: b only
histotable(1,6) = nnz(data == 10) ; ## R: both overlap

histo_filename = sprintf("%s.histo.csv", s_id) ;
f = fopen(histo_filename, "w") ;
fprintf(f, "%s,%d,%d,%d,%d,%d,%d\n", s_id, histotable) ;
fflush(f) ;
fclose(f) ;

clear all
close all
