#!/usr/bin/python3

## Input:
#    a full path to a folder containing Freesurfer output
#    This would usually look something like "/home/mike/Brains/Rochester/R000001"
#

## Output:
#    The subject, start date, duration, and completion state of the Freesurfer process
#         Without arguments, reports all on one line
#      -v reports much more data, on multiple lines,
#           including hippocampal, brain, and intracranial volumes.

## We expect to find certain folders and files within any of these structures.
## Differences in filecounts here can indicate failure at differnent places
## through the pipeline.
#    ./bem             ?
#    ./label           ~69 files (.ctab, .annot, .label) containing labels for regions within images
#    ./mri             ~34 files, 24 output images with .mgz extensions
#         /orig        The mgz version of the input image
#         /transforms  Talairach transformations of the original
#    ./scripts         ~12 log files, useful for determining environment and commands issued
#    ./src             ?
#    ./stats           18 .stats files, quantitative results for volumes, areas, etc.
#    ./surf            ~70 files
#    ./tmp             ?
#    ./touch           Records of some commands in the pipeline
#    ./trash           ?

## We may have added some additional folders not generated by Freesurfer
#    ./SOURCES         Contains the original sources used for analysis
#                      To contain an entire subject in one place, we just move the
#                      original files into this framework.
#    ./MANUAL          We also move the results of manual MIPAV segmentations here


## Use others' code to make our lives easier
import sys  # To get command-line arguments
import argparse  # A framework for parsing command-line arguments
import os  # For digging through directories and files
import re  # Regular expression support
import datetime  # To handle dates and times
import dateutil.parser  # strptime is awful. It cannot recognize other timezones

## Define any constants

## Define any globals
errors = []
ts_begin = datetime.datetime(1975, 3, 11, 0, 0, 0)
ts_end = ts_begin
StartedOver = ' '
left_hcv = ''
right_hcv = ''
hcvfile = 0

## Define any functions


## Parse command-line arguments
#    We only need one, the path to check, and it will default to pwd if not supplied.
parser = argparse.ArgumentParser(description='Scan Freesurfer output to summarize it')
parser.add_argument('output_path', nargs='?', default='.',
                    help='the Freesurfer output path for a particular subject')
parser.add_argument('-v', '--verbose', help='display the results on multiple lines', action='store_true')
parser.add_argument('--hcv', type=str, default='',
                    help='Append the id and hippocampal volumes (left, right) to this file.')
args = parser.parse_args()

full_output_path = os.path.abspath(args.output_path)  # in the case of 'pwd' or '.', we want a full path to display

if args.verbose:
    print('Checking ' + full_output_path)
if args.hcv != '':
    if os.path.isfile(args.hcv):
        hcvfile = open(args.hcv, 'a')
    else:
        hcvfile = open(args.hcv, 'w')
        hcvfile.write("subject,left_hcv,right_hcv,brainvol,tiv\n")
else:
    hcvfile = open("/dev/null", 'a')

##-----------------------------------------------------------------------------
## Check expectations of directory structure, logging violations to a list of errors
folders_counted = 0
folders_added = 0
folders_expected = 10
expected_folders = ['bem', 'label', 'mri', 'scripts', 'src', 'stats', 'surf', 'tmp', 'touch', 'trash']
added_folders = ['SOURCES', 'MANUAL']
for d in expected_folders:
    if os.path.isdir(full_output_path + '/' + d):
        folders_counted += 1
    else:
        errors.append('No ./' + d + ' folder')
for d in added_folders:
    if os.path.isdir(full_output_path + '/' + d):
        folders_added += 1

if args.verbose:
    print('  Found (%02d+%02d)/%02d expected folders.' % (folders_counted, folders_added, folders_expected))
    if len(errors) > 0:
        for e in errors:
            print('  %s' % e)
        errors = []

##-----------------------------------------------------------------------------
## Now check for some specific files we're going to want to look into
files_counted = 0
files_expected = 6
files_found = list('           ')  # like a bitmask, only characters stand in for files found.
expected_files = [[2, 'O', '/mri/orig/001.mgz'], \
                  [6, 'S', '/mri/aseg.mgz'], \
                  [8, 's', '/stats/aseg.stats'], \
                  [0, 'b', '/scripts/build-stamp.txt'], \
                  [4, 'l', '/scripts/recon-all.log'], \
                  [10, 'e', '/scripts/recon-all.done']]
for trio in expected_files:
    if os.path.isfile(full_output_path + trio[2]):
        files_counted += 1
        files_found[trio[0]] = trio[1]
    else:
        files_found[trio[0]] = '-'
        errors.append('No %s file' % trio[2])

if args.verbose:
    print('  Found %02d/%02d expected files: < %s >' % (files_counted, files_expected, "".join(files_found)))
    if len(errors) > 0:
        for e in errors:
            print('  %s' % e)
        errors = []

##-----------------------------------------------------------------------------
## Pull some data from inside of the files found
reg_subjid = re.compile(r'^subjid ([^\s]*)')
reg_end = re.compile(r'^recon-all -s ([^\s]*) finished without error at (.*)')
reg_new = re.compile(r'^New invocation of recon-all')
subject_id = ''
#  The 'l' character indicates the recon-all.log file.
if 'l' in files_found:
    whichline = 0
    StartingOver = False
    StartedOver = ' '
    for line in open(full_output_path + expected_files[4][2]):
        # recon-all gets called twice on each subject. In that situation,
        # we have to skip blank lines, then start over.
        if (StartingOver):
            # if args.verbose:
            # print(' SO : %05d : %03d chars long : "%s"' % (whichline, len(line.rstrip()), line.rstrip()))
            if (len(line.rstrip()) > 0):
                StartingOver = False
                StartedOver = '*'
                whichline = 0
        # The first line is a timestamp, grab it.
        if (whichline == 0):
            if args.verbose:
                print('  BEGL: %05d : "%s"' % (whichline, line.rstrip()))
            ts_begin = dateutil.parser.parse(line.rstrip())
        else:
            match_subjid = reg_subjid.match(line)
            if match_subjid:
                if args.verbose:
                    print('  SUBL: %05d : "%s"' % (whichline, line.rstrip()))
                subject_id = reg_subjid.match(line).group(1)
            match_end = reg_end.match(line)
            if match_end:
                if args.verbose:
                    print('  ENDL: %05d : "%s"' % (whichline, line.rstrip()))
                ts_end = dateutil.parser.parse(reg_end.match(line).group(2))
                if args.verbose:
                    print('  Time: BEGIN @  %s' % ts_begin.strftime("%m/%d/%Y %H:%M:%S"))
                    print('  Time:   END @  %s' % ts_end.strftime("%m/%d/%Y %H:%M:%S"))
                    print('  Time:         ', ts_end - ts_begin)
            match_new = reg_new.match(line)
            if match_new:
                if args.verbose:
                    print('  RSET: %05d : "%s"' % (whichline, line.rstrip()))
                StartingOver = True
        whichline += 1
else:
    subject_id = '?######'

reg_hcv = re.compile(r' *[0-9]* *[0-9]* *[0-9]* *([0-9]*\.[0-9])  ([LR])[a-z]*t-Hippocampus')
reg_tiv = re.compile(r'.*(EstimatedTotalIntraCranialVol).*[\s]([0-9]+[\.][0-9]+), mm\^3')
reg_tbv = re.compile(r'.*(BrainSeg),.*[\s]([0-9]+[\.][0-9]+), mm\^3')
#  The 's' character indicates the aseg.stats file.
if 's' in files_found:
    whichline = 0
    for line in open(full_output_path + expected_files[2][2]):
        match_hcv = reg_hcv.match(line)
        match_tiv = reg_tiv.match(line)
        match_tbv = reg_tbv.match(line)
        if match_hcv:
            if reg_hcv.match(line).group(2) == 'L':
                left_hcv = reg_hcv.match(line).group(1)
            if reg_hcv.match(line).group(2) == 'R':
                right_hcv = reg_hcv.match(line).group(1)
            if args.verbose:
                print('   HCV: %4.1f : %s' % (float(reg_hcv.match(line).group(1)), reg_hcv.match(line).group(2)))
        if match_tiv:
            if reg_tiv.match(line).group(1) == 'EstimatedTotalIntraCranialVol':
                tiv = reg_tiv.match(line).group(2)
            if args.verbose:
                print('  eTIV: %4.1f' % (float(reg_tiv.match(line).group(2))))
        if match_tbv:
            if reg_tbv.match(line).group(1) == 'BrainSeg':
                tbv = reg_tbv.match(line).group(2)
            if args.verbose:
                print(' BrVol: %4.1f' % (float(reg_tbv.match(line).group(2))))
        whichline += 1
    try:
        hcvfile.write(subject_id + "," + left_hcv + "," + right_hcv + "," + tbv + "," + tiv + "\n")
        hcvfile.close()
    except (OSError, NameError) as e:
        sys.stdout.write(subject_id + "," + left_hcv + "," + right_hcv + "," + tbv + "," + tiv + "\n")

##-----------------------------------------------------------------------------
## Wrap it up
if args.verbose:
    print("Done")
else:
    print('S:%s %s D:(%02d+%02d)/%02d  F:%02d/%02d < %s >  %08s %08s  %s' % (
    subject_id, StartedOver, folders_counted, folders_added, folders_expected, files_counted, files_expected,
    "".join(files_found), ts_begin.strftime("%m/%d/%y"), (ts_end - ts_begin), full_output_path))
