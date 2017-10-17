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
import csv  # To write the final csv mrs file easily


# ------------------------------------------------------------------------------
# -- Define constants and globals for later use
# ------------------------------------------------------------------------------

subject_root = ""

snr = {
    "name" : "snr", 
    "cmd" : "wm-anat-snr", 
    "datafile" : "stats/wmsnr.e3.dat", 
    "logfile" : "scripts/wmsnr.log", 
    "data" : (), 
}
cnr = {
    "name" : "cnr", 
    "cmd" : "mri_cnr", 
    "datafile" : "stats/wmcnr.t.dat", 
    "logfile" : "scripts/wmcnr.t.log", 
    "data" : (), 
}

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

cnr["cmd"] = [cnr["cmd"], os.path.join(subject_root, "surf"), os.path.join(subject_root, "mri/orig.mgz"), ]
snr["cmd"] = [snr["cmd"], "--s", subject_id, ]


# ------------------------------------------------------------------------------
# -- Define functions
# ------------------------------------------------------------------------------


# Generate data, if necessary
def generate_ratio(d):
    if not os.path.isfile(os.path.join(subject_root, d["datafile"])):
        if args.verbose:
            print("{0} not found, making it...".format(os.path.join(subject_root, d["datafile"])))
        if shutil.which(d["cmd"][0]):
            local_output = subprocess.run(d["cmd"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if local_output.returncode == 0:
                if args.verbose:
                    print(local_output.stdout.decode("utf-8"))
                    print(local_output.stderr.decode("utf-8"))
                if d["name"] == "cnr":
                    # Generate a log file
                    f = open(os.path.join(subject_root, d["logfile"]), "a")
                    f.write(" ".join(d["cmd"]))
                    f.write(str(local_output.stdout))
                    f.close()
                    # Generate the data file
                    f = open(os.path.join(subject_root, d["datafile"]), "w")
                    f.write(str(local_output.stdout))
                    f.close()
                elif d["name"] == "snr":
                    # The SNR application generates its own data file and log file.
                    # Just running it does everything.
                    pass
            else:
                print("Warning: {0} returned an error.".format(d["cmd"][0]))
                print("    stdout : {}".format(local_output.stdout.decode("utf-8")))
                print("    stderr : {}".format(local_output.stderr.decode("utf-8")))
        else:
            print("No CNR data can be found at '{0}'.".format(
                os.path.join(subject_root, d[datafile])))
            print("No {0} available. Check your FREESURFER_HOME environment variable.".format(
                cnr["cmd"]))


# Extract data
def extract_cnr(d):
    return (1.01, 1.02, 1.03, )


def extract_snr(d):
    return (20.00, )


def output_ratios(sub_id, dcnr, dsnr):
    print("ID,snr,whole_cnr,left_cnr,right_cnr")
    print("{i},{s},{cw},{cl},{cr}".format(
        i=sub_id, s=dsnr["data"][0],
        cw=dcnr["data"][0], cl=dcnr["data"][1], cr=dcnr["data"][2]))


# ------------------------------------------------------------------------------
# -- Finally, with functions and arguments ready, do our thing...
# ------------------------------------------------------------------------------


# If the CNR data are not already there, generate them
generate_ratio(cnr)
generate_ratio(snr)

# Now extract the data
cnr["data"] = extract_cnr(cnr)
snr["data"] = extract_snr(snr)

# And kick out the summary
output_ratios(subject_id, cnr, snr)
