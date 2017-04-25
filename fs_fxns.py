#!/usr/bin/python3

from collections import OrderedDict

import os
import datetime
from dateutil.tz import gettz
from dateutil import parser
import re  # Regular expression support

from mrs_dicts import *

tzinfos = {"CST": gettz("America/Chicago"), "CDT": gettz("America/Chicago"),
           "EST": gettz("America/New_York"), "EDT": gettz("America/New_York")}


# Map short strings to file paths within FreeSurfer heierarchy
def fs_file(which_file):
    file_dict = OrderedDict([
        ('log', '/scripts/recon-all.log'),
        ('stamp', '/scripts/build-stamp.txt'),
        ('cmd', '/scripts/recon-all.cmd'),
        ('aseg', '/stats/aseg.stats'),
        ('wmparc', '/stats/wmparc.stats'),
        ('aparc1l', '/stats/lh.aparc.stats'),
        ('aparc1r', '/stats/rh.aparc.stats'),
        ('aparc2l', '/stats/lh.aparc.a2009s.stats'),
        ('aparc2r', '/stats/rh.aparc.a2009s.stats'),
        ('aparc3l', '/stats/lh.aparc.DKTatlas40.stats'),
        ('aparc3r', '/stats/rh.aparc.DKTatlas40.stats'),
        ('err', '/scripts/recon-all.error'),
        ('done', '/scripts/recon-all.done'),
    ])
    if which_file == "all":
        del file_dict['err']
        del file_dict['done']
        return file_dict
    else:
        return file_dict.get(which_file, "")


# Extract the version information
def get_fs_version(subject_root, verbosity="short"):
    stampfile = subject_root + fs_file('stamp')
    version_string = ""
    if not os.path.isfile(stampfile):
        return ("N/A")
    f = open(stampfile)
    for line in f:
        if '\n' == line[-1]:
            line = line[:-1]
        version_string = line
    f.close()
    if verbosity == "short":
        short_version_string = version_string[version_string.find("pub-v") + len("pub-v"):]
        return (short_version_string[:5])
    else:
        return version_string


# Extract the elapsed time
def get_fs_time(subject_root, verbosity="short", timetype="elapsed", sparsity=False):
    cmdfile = subject_root + fs_file('cmd')
    if not os.path.isfile(cmdfile):
        return "N/A"
    timestrings = []
    # tfstring="%a %b %d %X %Z %Y"
    first_time = datetime.datetime.now()
    last_time = datetime.datetime.now()
    this_time = datetime.datetime.now()
    td_large = this_time - first_time
    td_small = this_time - first_time
    reg_tstamp = re.compile(r'^#@# (?P<task>.*) (?P<stmp>\w{3}\s+\w+\s+\d+\s+\d\d:\d\d:\d\d\s+\w{3}\s+\d{4})')
    f = open(cmdfile)
    n = 0
    for line in f:
        mat_tstamp = reg_tstamp.match(line)
        if mat_tstamp:
            if n == 0:
                first_time = parser.parse(mat_tstamp.group('stmp'), tzinfos=tzinfos)
                last_time = first_time
            n += 1
            this_time = parser.parse(mat_tstamp.group('stmp'), tzinfos=tzinfos)
            td_small = this_time - last_time
            td_large = this_time - first_time
            if verbosity == "long":
                if sparsity:
                    timestrings.append("{:2} : {:5.0f}\n".format(
                        n, td_small.total_seconds()
                    ))
                else:
                    timestrings.append("{:2} : {:28} : {} ({:5.0f}, {:5.0f})\n".format(
                        n, mat_tstamp.group('task'), mat_tstamp.group('stmp'),
                        td_small.total_seconds(), td_large.total_seconds()
                    ))
            last_time = this_time
    f.close()
    if verbosity == "short":
        if sparsity:
            timestrings.append("{:5.0f}".format(
                td_large.total_seconds()
            ))
        else:
            timestrings.append("{:5.0f} seconds ({:2.1f} hrs)".format(
                td_large.total_seconds(), td_large.total_seconds() / 3600.0
            ))
    if timetype == "elapsed":
        return ''.join(timestrings)
    if timetype == "begin":
        return first_time.strftime("%Y-%m-%dT%H:%M:%S%z")
    if timetype == "end":
        return last_time.strftime("%Y-%m-%dT%H:%M:%S%z")


# Extract the hostname on which FreeSurfer was run
def get_fs_hostname(subject_root):
    retval = ""
    if os.path.isfile(subject_root + fs_file("done")):
        reg_machine = re.compile(r'.*HOST (?P<machine>\w*).*')
        f = open(subject_root + fs_file("done"))
        for line in f:
            mat_machine = reg_machine.match(line)
            if mat_machine:
                retval = mat_machine.group('machine')
        f.close()
    return retval


# Extract the username under which freesurfer was run
def get_fs_username(subject_root):
    retval = ""
    if os.path.isfile(subject_root + fs_file("done")):
        reg_username = re.compile(r'.*USER (?P<username>\w*).*')
        f = open(subject_root + fs_file("done"))
        for line in f:
            mat_username = reg_username.match(line)
            if mat_username:
                retval = mat_username.group('username')
        f.close()
    return retval


# Retrieve data from FreeSurfer stats file
def get_fs_data(subject_root, stats_file):
    my_dict = OrderedDict()
    # Each stats file has two sections with data, a head section and
    # a body section (called CORT for aparcs). We need to check and mine both.
    re_head = re.compile(r'^#\s+Measure\s+[\w_\-]+,\s+(?P<Name>[\w_\-]+),.+?(?P<Volume>[\d\.]+),\s(?P<Dim>.+)$')
    re_body = re.compile(r'^\s*\d+\s+\d+\s+\d+\s+(?P<Volume>[\d\.]+)\s+(?P<Name>[\w_\-]+).+')
    re_cort = re.compile(r'^(?P<Name>[\w_\-]+)\s+\d+\s+\d+\s+(?P<Volume>[\d\.]+).+')
    if os.path.isfile(subject_root + fs_file(stats_file)):
        f = open(subject_root + fs_file(stats_file))
        for line in f:
            mat_measure_head = re_head.match(line)
            mat_measure_body = re_body.match(line)
            mat_measure_cort = re_cort.match(line)
            if mat_measure_head:
                # print("HEAD: {Name}={Volume}".format(
                #     Name=mat_measure_head.group('Name'),
                #     Volume = mat_measure_head.group('Volume')
                # ))
                my_dict[mat_measure_head.group('Name')] = mat_measure_head.group('Volume')
            if mat_measure_body:
                # print("BODY: {Name}={Volume}".format(
                #     Name=mat_measure_body.group('Name'),
                #     Volume = mat_measure_body.group('Volume')
                # ))
                my_dict[mat_measure_body.group('Name')] = mat_measure_body.group('Volume')
            if mat_measure_cort:
                # print("CORT: {Name}={Volume}".format(
                #     Name=mat_measure_cort.group('Name'),
                #     Volume = mat_measure_cort.group('Volume')
                # ))
                my_dict[mat_measure_cort.group('Name')] = mat_measure_cort.group('Volume')
        f.close()
    else:
        print("Cannot find file {0}.".format(subject_root + fs_file(stats_file)))
    return my_dict


# Extract a volume or area
def get_fs_item(subject_root, which_item=""):
    retval = ""
    # Merge dictionaries
    dict_whole = get_fs_data(subject_root, 'aseg')
    dict_whole.update(get_fs_data(subject_root, 'wmparc'))
    dict_whole.update(OrderedDict([(k + '_L', v) for k, v in get_fs_data(subject_root, 'aparc1l').items()]))
    dict_whole.update(OrderedDict([(k + '_R', v) for k, v in get_fs_data(subject_root, 'aparc1r').items()]))
    try:
        retval = dict_whole[which_item]
    except KeyError:
        print("{0} cannot be found as a StructName in {1}".format(which_item, subject_root))
        retval = "0.00"
    return retval


# Join left and right aparc data without duplicating shared fields
def fs_join_aparc_dicts(left_dict, right_dict, which_version="6.0.0"):
    ambi_dict = OrderedDict()
    # Use the ordered clean index dictionary as an index, pull data from arguments
    for k, v in get_aparc_dict(which_version).items():
        if k in get_shared_aparc_items():
            # duplicated items are only stored once
            # print("Found {0} as joint item.".format(k))
            if left_dict[k] == right_dict[k]:
                ambi_dict[k] = left_dict[k]
            else:
                print("ERROR: Joining aparc: lh ({lh}) and rh ({rh}) disagree on {v}".format(
                    lh = left_dict[k], rh = right_dict[k], v=k,
                ))
        else:
            # items with one for left and one for right are each stored independently
            # print("Found {0} as independent aparc item".format(k))
            try:
                ambi_dict[k + '_L'] = left_dict[k]
            except KeyError:
                # print("   keyerror, can't find {0} in lh {1}".format(k, 'aparc'))
                ambi_dict[k + '_L'] = "NA"
            try:
                ambi_dict[k + '_R'] = right_dict[k]
            except KeyError:
                # print("   keyerror, can't find {0} in rh {1}".format(k, 'aparc'))
                ambi_dict[k + '_R'] = "NA"

    return ambi_dict
