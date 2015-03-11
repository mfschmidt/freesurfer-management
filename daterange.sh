#!/bin/bash

# From the freesurfer $SUBJECTS_DIR directory, this will report the duration of
# creation timestamps on files found in a particular subject's subdirectory,
# reporting the duration of the freesurfer run, start to finish

# Usage: daterange.sh subjectname
if [ $# -eq 0 ]
  then
    echo "Which subject?"
    echo "Usage:"
    echo "$ daterange.sh subjectname"
    exit 1
fi

# Set a grossly over- and under- estimated date as bookends
min_d="9999-99-99"
max_d="0000-00-00"

# Go through each file in specified directory, ascertaining modified date
# then output the range found
for f in $(ls -1f $1/*)
do
    whole_d=$(stat -c%y $f)
    d=${whole_d:0:10}
    #echo "$f => $d"
    if [[ "$d" > "$max_d" ]]
    then
        max_d=$d
    fi
    if [[ "$d" < "$min_d" ]]
    then
        min_d=$d
    fi
done

if [[ "$min_d" == "$max_d" ]]
then
    echo "$min_d"
else
    echo "$min_d - $max_d"
fi
