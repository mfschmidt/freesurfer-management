Utility files can be used on any linux machine, and help to automate many of the tasks a researcher will do with Freesurfer data. Quick one-line summaries of the whole FreeSurfer run, without having to dig into the many logs, can be very convenient.

## Files

### bash_mind_functions.sh

This script simply defines some functions that are useful in other scripts; it does nothing by itself. From another script, or your own, simply

    source [your path]/freesurfer-management/utility/bash_mind_functions.sh

then use the following functions as you like.

* has_mipav_data() returns the number of xml trace files available. If it returns 2, you have a tracing. If it returns 4, you might have two. An odd number would indicate a partial or some other problem to be looked into.
* has_freesurfer_data() returns the number of subdirectories found that match the expected directory structure of freesurfer output. A complete freesurfer run ought to have 10 folders that match.
* has_analyze_data() returns the number of *.hdr and *.img files in the directory. A result greater than or equal to 2 would indicate that you probably have at least one Analyze image set.

These could be used profitably to find all directories with freesurfer data in a particular directory tree. Directories and subdirectories that do not have the expected structure within would not be printed.

    source ~/bin/freesurfer-management/utility/bash_mind_functions.sh
    for d in $(find /mri -type d); do
        has_freesurfer_data "$d"
        if [ $? -ge 10 ]; then
            echo "$d"
        fi
    done

