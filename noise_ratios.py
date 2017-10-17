#!/usr/bin/python3

# noise_ratios.py
# See argparse section below for details on input and output.
# This script uses existing freesurfer software to get SNR and CNR data

# Use others' code to make our lives easier
import sys  # To get command-line arguments
import argparse  # A framework for parsing command-line arguments
import os  # For digging through directories and files
import shutil  # to find external applications
import subprocess  # to execute external applications
import re  # Regular expression support
import datetime  # To handle dates and times
import csv  # To write the final csv mrs file easily
from collections import OrderedDict  # for named dictionaries of volumes and such
from datetime import date
from datetime import timedelta
import time
import glob  # for searching for original spgr files, fullname unknown


# ------------------------------------------------------------------------------
# -- Define constants and globals for later use
# ------------------------------------------------------------------------------
TS_Format = "%a %b %d %H:%M:%S %Z %Y"

subject_root = ""

snr_cmd = "wm-anat-snr"
snr_output = "stats/tmp.wmsnr.e3.dat"
cnr_cmd = "mri_cnr"
cnr_output = "stats/tmp.wmcnr.dat"

# Parse command-line arguments
# ------------------------------------------------------------------------------
# -- Define expected command-line arguments
# ------------------------------------------------------------------------------


# Parse command-line arguments
argparser = argparse.ArgumentParser(description='Get SNR and CNR from FreeSurfer output')
argparser.add_argument('-s', '--subject',
                       help='Provide the subject id, and rely on SUBJECTS_DIR to find it.')
argparser.add_argument('-p', '--path',
                       help='Provide a path to FreeSurfer data.')
argparser.add_argument('-o', '--output',
                       help='Append information to the specified file.')
argparser.add_argument('-v', '--verbose', action='store_true',
                       help='Output all data to stdout.')
argparser.add_argument('-q', '--quiet', action='store_true',
                       help='Don\'t output anything to stdout.')

args = argparser.parse_args()

if args.path and os.path.isdir(args.path):
    subject_root = args.path
elif args.subject and os.path.isdir(os.path.join(os.environ["SUBJECTS_DIR"], args.subject)):
    subject_root = os.path.join(os.environ["SUBJECTS_DIR"], args.subject)
else:
    print("I cannot find a subject.")
    print("'{0}' is not a valid directory".format(args.path))
    print("and neither is '{0}'".format(os.path.join(os.environ["SUBJECTS_DIR"], args.subject)))
    print("You can specify a subject (relative to SUBJECTS_DIR) with the -s flag.")
    print("You can specify a full path to a subject with the -p flag.")
    sys.exit(0)
subject_id = os.path.basename(subject_root)


# ------------------------------------------------------------------------------
# -- Define functions
# ------------------------------------------------------------------------------


# Generate data, if necessary
def generate_ratio(which_cmd, which_file):
    if not os.path.isfile(os.path.join(subject_root, which_file)):
        if args.verbose:
            print("{0} not found, making it...".format(os.path.join(subject_root, which_file)))
        if shutil.which(which_cmd[0]):
            local_output = subprocess.run(
                which_cmd,
                stdout=subprocess.PIPE, sterr=subprocess.PIPE)
            if len(local_output.stdout) > 0 and len(local_output.stderr) == 0:
                f = open(os.path.join(subject_root, which_file), "a")
                f.write(local_output.stdout)
                f.close()
            else:
                print("Warning: output not as expected:")
                print("    stdout : {}".format(local_output.stdout))
                print("    stderr : {}".format(local_output.stderr))
        else:
            print("No CNR data can be found at '{0}'.".format(
                os.path.join(subject_root, "stats", "wmcnr.dat")))
            print("No {0} available. Check your FREESURFER_HOME environment variable.".format(
                cnr_cmd))


# Extract data
def extract_cnr(cnr_path):
    return (1.01, 1.02, 1.03, )


def extract_snr(snr_path):
    return (20.00, )


def output_ratios(sub_id, cnr_tuple, snr_tuple):
    print("ID,snr,cnr,left_cnr,right_cnr")
    print("{i},{s},{c},{cl},{cr}".format(
        i=sub_id, s=snr_tuple[1],
        c=cnr_tuple[1], cl=cnr_tuple[2], cr=cnr_tuple[3]))


# ------------------------------------------------------------------------------
# -- Finally, with functions and arguments ready, do our thing...
# ------------------------------------------------------------------------------


# If the CNR data are not already there, generate them
generate_ratio(
    [cnr_cmd, os.path.join(subject_root, "surf"), os.path.join(subject_root, "mri/orig.mgz"), ],
    cnr_output)

generate_ratio(
    [snr_cmd, "--s", subject_id, ],
    snr_output)

# Now extract the data
my_cnr = extract_cnr(cnr_output)
my_snr = extract_snr(snr_output)

# And kick out the summary
output_ratios(subject_id, my_cnr, my_snr)
